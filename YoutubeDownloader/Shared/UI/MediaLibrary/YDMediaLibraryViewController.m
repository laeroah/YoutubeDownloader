//
//  YDMediaLibraryViewController.m
//  YoutubeDownloader
//
//  Created by HAO WANG on 11/15/13.
//  Copyright (c) 2013 HAO WANG. All rights reserved.
//

#import "YDMediaLibraryViewController.h"
#import "YDConstants.h"
#import "YDDeviceUtility.h"
#import "YDMediaLibraryRowCell.h"
#import "YDDeviceSpaceAvailabilityView.h"
#import "AFNetworking.h"
#import "YDPlayerViewController.h"
#import "Video.h"
#import "DownloadTask.h"
#import "UIImageView+WebCache.h"
#import "CoreData+MagicalRecord.h"
#import "YDDownloadManager.h"

typedef enum
{
    YDMediaLibraryViewControllerLayoutRow,
    YDMediaLibraryViewControllerLayoutThumbnail
}YDMediaLibraryViewControllerLayout;

#define SEARCH_BAR_HEIGHT 44.0f

@interface YDMediaLibraryViewController ()
{
    //control buttons
    UIButton *_backButton;
    UIButton *_thumbnailButton;
    UIButton *_searchButton;
    UIButton *_deleteButton;
    YDDeviceSpaceAvailabilityView *_availableView;
    YDMediaLibraryViewControllerLayout _currentLayout;
    BOOL _editMode;
    BOOL _searchBarShowing;
}

@property (nonatomic, strong) NSFetchedResultsController *fetchResultController;
@property (nonatomic, strong) NSString *searchString;

@property (weak, nonatomic) IBOutlet UIView *deviceSpaceStatusBar;
@property (weak, nonatomic) IBOutlet UICollectionView *mediaCollectionView;
@property (weak, nonatomic) IBOutlet UILabel *totalSpaceLabel;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UIView *noVideoView;


@end

@implementation YDMediaLibraryViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.hidesBackButton = YES;
    [self createControlButtons];
    
    [self.mediaCollectionView registerClass:[YDMediaLibraryRowCell class] forCellWithReuseIdentifier:@"YDMediaLibraryRowCell"];
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc]init];
    [self.mediaCollectionView setCollectionViewLayout:flowLayout];
    
    [self layoutDeviceSpaceBar];
    
    CGRect searchBarFrame = self.searchBar.frame;
    searchBarFrame.origin.y = -SEARCH_BAR_HEIGHT;
    self.searchBar.frame = searchBarFrame;
    
    [self loadVideos];
    
    // setup the screen name for GA tracking
    self.screenName = SCREEN_NAME_LIBRARY_VIEW;
    
    [Video removeExpiredVideos];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.mediaCollectionView.collectionViewLayout invalidateLayout];
    
}

#pragma mark - layout subviews
- (void)layoutDeviceSpaceBar
{
    VSDeviceSpace *deviceSpace = [YDDeviceUtility getDeviceSpace];
    uint64_t totalSpace = deviceSpace.totalSpace;
    self.totalSpaceLabel.text = [NSString stringWithFormat:@"%.2fG", 0.001 * totalSpace];
    
    YDDeviceSpaceAvailabilityView *availableView = [[YDDeviceSpaceAvailabilityView alloc]initWithFrame:CGRectMake(66, 10, self.deviceSpaceStatusBar.frame.size.width - 80, 10)];
    [self.deviceSpaceStatusBar addSubview:availableView];
    availableView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    _availableView = availableView;
}

- (void)createControlButtons
{
    _backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_backButton setImage:[UIImage imageNamed:@"ic_backButton"] forState:UIControlStateNormal];
    _backButton.frame = CGRectMake(0, 0, NAVIGATION_BUTTON_WIDTH, NAVIGATION_BUTTON_HEIGHT);
    [_backButton addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
    
    _thumbnailButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_thumbnailButton setImage:[UIImage imageNamed:@"ic_thumbnail"] forState:UIControlStateNormal];
    [_thumbnailButton setImage:[UIImage imageNamed:@"ic_list"] forState:UIControlStateSelected];
    _thumbnailButton.frame = CGRectMake(0, 0, NAVIGATION_BUTTON_WIDTH, NAVIGATION_BUTTON_HEIGHT);
    [_thumbnailButton addTarget:self action:@selector(toggleLayout) forControlEvents:UIControlEventTouchUpInside];
    
    _searchButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_searchButton setImage:[UIImage imageNamed:@"ic_search"] forState:UIControlStateNormal];
    //[_searchButton setImage:[UIImage imageNamed:@"ic_search_highlighted"] forState:UIControlStateHighlighted];
    _searchButton.frame = CGRectMake(0, 0, NAVIGATION_BUTTON_WIDTH, NAVIGATION_BUTTON_HEIGHT);
    [_searchButton addTarget:self action:@selector(toggleSearchBar) forControlEvents:UIControlEventTouchUpInside];
    
    _deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_deleteButton setImage:[UIImage imageNamed:@"ic_delete"] forState:UIControlStateNormal];
    [_deleteButton setImage:[UIImage imageNamed:@"ic_finish"] forState:UIControlStateSelected];
    _deleteButton.frame = CGRectMake(0, 0, NAVIGATION_BUTTON_WIDTH, NAVIGATION_BUTTON_HEIGHT);
    [_deleteButton addTarget:self action:@selector(toggleEditMode) forControlEvents:UIControlEventTouchUpInside];
    
    self.navigationButtons = @[_backButton, _thumbnailButton, _searchButton, _deleteButton];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - load downloaded videos
- (void)loadVideos
{
	NSError *error = nil;
	if (![[self fetchResultController] performFetch:&error]) {
        NSLog(@"Core Data Error %@, %@", error, [error userInfo]);
        exit(0);
    }
    [self.mediaCollectionView reloadData];
}

#pragma mark - fetch result controller and delegate
- (NSFetchedResultsController *)fetchResultController
{
 	NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"videoID"
                                                         ascending:NO
                                                          selector:@selector(compare:)];
    
    NSMutableArray *predicates = [NSMutableArray array];
    
    //only show the call if it's terminated
    NSManagedObjectContext *context = [NSManagedObjectContext MR_contextForCurrentThread];
    NSPredicate *createTimePredicate = [NSPredicate predicateWithFormat:@"%K != %@", @"createDate", nil];
    NSPredicate *deletedPredicate = [NSPredicate predicateWithFormat:@"%K != %@", @"isRemoved", @(YES)];
    [predicates addObject:createTimePredicate];
    [predicates addObject:deletedPredicate];
    
    if (self.searchString && [self.searchString length] > 0) {
        NSPredicate *searchVideoTitlePredicate = [NSPredicate predicateWithFormat:@"%K CONTAINS[cd] %@", @"videoTitle", self.searchString];
        [predicates addObject:searchVideoTitlePredicate];
    }
    
    NSPredicate *fetchPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:predicates];
    NSFetchRequest *request = [Video MR_requestAllWithPredicate:fetchPredicate inContext:context];
    
    [request setSortDescriptors:[NSArray arrayWithObject:sort]];
    
    
    if (_fetchResultController != nil) {
        [_fetchResultController.fetchRequest setPredicate:fetchPredicate];
        [NSFetchedResultsController deleteCacheWithName:@"Videos"];
        return _fetchResultController;
    }
    
    [NSFetchedResultsController deleteCacheWithName:@"Videos"];
    _fetchResultController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:context sectionNameKeyPath:nil cacheName:@"Videos"];
    _fetchResultController.delegate = self;
    [_fetchResultController.fetchRequest setFetchLimit:30];
    
    return _fetchResultController;
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath
{
	//Video *videoObject = (Video *)anObject;
	switch(type) {
		case NSFetchedResultsChangeInsert:
			break;
			
		case NSFetchedResultsChangeDelete:
            [self.mediaCollectionView deleteItemsAtIndexPaths:@[indexPath]];
			break;
			
		case NSFetchedResultsChangeUpdate:
            [self.mediaCollectionView reloadItemsAtIndexPaths:@[indexPath]];
			break;
			
		case NSFetchedResultsChangeMove:
            break;
	}
}

// deal with secion
- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    
}

#pragma mark - UICollectionViewDelegate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    self.noVideoView.hidden = [self.fetchResultController.fetchedObjects count] != 0;
    return [self.fetchResultController.fetchedObjects count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    YDMediaLibraryRowCell *mediaCell = nil;
    static NSString *cellReusedID = @"YDMediaLibraryThumbnailCell";
    if (_currentLayout == YDMediaLibraryViewControllerLayoutRow) {
        cellReusedID = @"YDMediaLibraryRowCell";
    }else{
        cellReusedID = @"YDMediaLibraryThumbnailCell";
    }
    
    UINib *nib = [UINib nibWithNibName:cellReusedID bundle:nil];
    [collectionView registerNib:nib forCellWithReuseIdentifier:cellReusedID];
    mediaCell = [collectionView dequeueReusableCellWithReuseIdentifier:cellReusedID
                                                          forIndexPath:indexPath];
    
    Video *video = [self.fetchResultController.fetchedObjects objectAtIndex:indexPath.item];
    mediaCell.videoTitleLabel.text = video.videoTitle;
    mediaCell.ribbonImageView.hidden = !video.isNewValue;
    if (video.videoImagePath)
    {
        mediaCell.videoThumbnailImageView.image = [UIImage imageWithContentsOfFile:video.videoImagePath];
    }else{
        mediaCell.videoThumbnailImageView.image = nil;
    }
    mediaCell.videoID = video.videoID;
    
    mediaCell.delegate = self;
    [mediaCell enterEditMode:_editMode animated:NO];
    
    DownloadTask *downloadTask = video.downloadTask;
    BOOL isDownloading = ![downloadTask.downloadTaskStatus isEqualToNumber: @(DownloadTaskFinished)];
    [mediaCell enterDownloadMode:isDownloading];
    
    mediaCell.downloadControlButton.enabled = YES;
    mediaCell.downloadControlButton.hidden = NO;
    mediaCell.downloadControlState = YDDownloadControlDisable;
    if (isDownloading) {
        [mediaCell.downloadControlButton setImage:[UIImage imageNamed:@"btn_downloadpause"]  forState:UIControlStateNormal];
        mediaCell.downloadControlState = YDDownloadControlPause;
    }
    else
    if ([downloadTask.downloadTaskStatus isEqualToNumber: @(DownloadTaskPaused)])
    {
        [mediaCell.downloadControlButton setImage:[UIImage imageNamed:@"btn_downloadResume"]  forState:UIControlStateNormal];
        mediaCell.downloadControlState = YDDownloadControlResume;
    }
    else
    {
        mediaCell.downloadControlButton.hidden = YES;
    }
    
    mediaCell.videoDurationLabel.text = [video formattedVideoDuration];
    
    mediaCell.downloadProgressBar.progress = downloadTask.downloadProgress.floatValue;
    if (downloadTask.downloadProgressValue >= 1.0)
    {
        mediaCell.downloadProgressBar.hidden = YES;
    }
    else
    {
        mediaCell.downloadProgressBar.hidden = NO;
    }
    
    //register the cell to receive the download status update notification
    [[NSNotificationCenter defaultCenter] addObserver:mediaCell
                                             selector:@selector(updateVideoDownloadProgress:)
                                                 name:kDownloadTaskStatusChangeNotification
                                               object:nil];
    
    return mediaCell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    // Adjust cell size for orientation
    if (_currentLayout == YDMediaLibraryViewControllerLayoutRow) {
        return CGSizeMake(self.view.frame.size.width, MEDIA_LIBRARY_ROW_HEIGHT);
    }else{
        if ([YDDeviceUtility isIPad]) {
            if ([YDDeviceUtility isLandscape]) {
                return CGSizeMake(MEDIA_LIBRARY_THUMBNAIL_WIDTH_IPAD_LANDSCAPE, MEDIA_LIBRARY_ROW_HEIGHT);
            }else{
                return CGSizeMake(MEDIA_LIBRARY_THUMBNAIL_WIDTH_IPAD_PORTRAIT, MEDIA_LIBRARY_ROW_HEIGHT);
            }
        }else{
            return CGSizeMake(MEDIA_LIBRARY_THUMBNAIL_WIDTH_IPHONE, MEDIA_LIBRARY_ROW_HEIGHT);
        }
    }
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section

{
    if ([YDDeviceUtility isLandscape] && ![YDDeviceUtility isIPad]) {
        return UIEdgeInsetsMake(0, 25, 0, 25);
    }else{
        return UIEdgeInsetsZero;
    }
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 2;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 0;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    Video *video = [self.fetchResultController.fetchedObjects objectAtIndex:indexPath.item];
    DownloadTask *downloadTask = video.downloadTask;
    BOOL downloadFinished = [downloadTask.downloadTaskStatus isEqualToNumber: @(DownloadTaskFinished)];
    
    if (downloadFinished) {
        YDPlayerViewController *playerViewController = [[YDPlayerViewController alloc]init];
        [playerViewController presentPlayerViewControllerFromViewController:self];
        if (video.videoFilePath) {
            [playerViewController playLocalVideoWithPath:video.videoFilePath];
        }
        
        [video setIsNewValue:NO];
        [[NSManagedObjectContext MR_contextForCurrentThread]MR_saveOnlySelfWithCompletion:nil];
    }
    
    
}

#pragma mark - rotation
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self.mediaCollectionView.collectionViewLayout invalidateLayout];
    [_availableView layoutColoredSpaceBarAnimated:YES];
}

#pragma mark - navigation control
- (void)dismiss
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)findVideoButtonTapped:(id)sender {
    [self dismiss];
}

- (void)toggleLayout
{
    if (_currentLayout == YDMediaLibraryViewControllerLayoutRow) {
        _thumbnailButton.selected = YES;
        _currentLayout = YDMediaLibraryViewControllerLayoutThumbnail;
        [[YDAnalyticManager sharedInstance]trackWithCategory:EVENT_CATEGORY_LIBRARY_VIEW action:EVENT_ACTION_USE_THUMBNAILLAYOUT label:SCREEN_NAME_LIBRARY_VIEW value:nil];
    }else{
        _thumbnailButton.selected = NO;
        _currentLayout = YDMediaLibraryViewControllerLayoutRow;
        [[YDAnalyticManager sharedInstance]trackWithCategory:EVENT_CATEGORY_LIBRARY_VIEW action:EVENT_ACTION_USE_ROWLAYOUT label:SCREEN_NAME_LIBRARY_VIEW value:nil];
    }
    [self.mediaCollectionView.collectionViewLayout invalidateLayout];
    [self.mediaCollectionView reloadData];
    
}

- (void)toggleEditMode
{
    NSArray *visibleCells = [self.mediaCollectionView visibleCells];
    _editMode = !_editMode;
    for (YDMediaLibraryRowCell *cell in visibleCells) {
        [cell enterEditMode:_editMode animated:YES];
    }
    _deleteButton.selected = _editMode;
    
    if (_editMode) {
        [[YDAnalyticManager sharedInstance]trackWithCategory:EVENT_CATEGORY_LIBRARY_VIEW action:EVENT_ACTION_ENTER_EDIT_LIBRARY label:SCREEN_NAME_LIBRARY_VIEW value:nil];
    }else{
        [[YDAnalyticManager sharedInstance]trackWithCategory:EVENT_CATEGORY_LIBRARY_VIEW action:EVENT_ACTION_FINISH_EDIT_LIBRARY label:SCREEN_NAME_LIBRARY_VIEW value:nil];
    }
}

- (void)toggleSearchBar
{
    CGRect searchBarFrame = self.searchBar.frame;
    CGRect mediaLibraryTableFrame = self.mediaCollectionView.frame;
    _searchBarShowing = !_searchBarShowing;
    _searchButton.highlighted = _searchBarShowing;
    
    if (_searchBarShowing) {
        //show search bar
        searchBarFrame.origin.y = 0.0f;
        mediaLibraryTableFrame.origin.y = SEARCH_BAR_HEIGHT;
        mediaLibraryTableFrame.size.height -= SEARCH_BAR_HEIGHT;
        [self.searchBar becomeFirstResponder];
        
        [[YDAnalyticManager sharedInstance]trackWithCategory:EVENT_CATEGORY_LIBRARY_VIEW action:EVENT_ACTION_SEARCH_LIBRARY label:SCREEN_NAME_LIBRARY_VIEW value:nil];
        
    }else{
        //hide search bar
        searchBarFrame.origin.y -= SEARCH_BAR_HEIGHT;
        mediaLibraryTableFrame.origin.y = 0.0f;
        mediaLibraryTableFrame.size.height += SEARCH_BAR_HEIGHT;
        [self.searchBar resignFirstResponder];
    }
    [UIView animateWithDuration:0.2f animations:^{
        self.searchBar.frame = searchBarFrame;
        self.mediaCollectionView.frame = mediaLibraryTableFrame;
    }];
}

#pragma mark - YDMediaLibraryRowCellDelegate
- (void)didChooseToRemoveCell:(YDMediaLibraryRowCell *)cell
{
    NSManagedObjectContext *context = [NSManagedObjectContext MR_contextForCurrentThread];
    [Video removeVideo:cell.videoID inContext:context completion:^(BOOL success, NSError *error) {
        if (!success) {
#ifdef DEBUG
            NSLog(@"Failed to remove video : %@", cell.videoID);
#endif
        }
    }];
}

- (void)refreshCellWithVideoID:(NSNumber*)videoID
{
    NSManagedObjectContext *privateQueueContext = [NSManagedObjectContext MR_contextForCurrentThread];
    Video  *video = [Video findByVideoID:videoID inContext:privateQueueContext];
    NSIndexPath *indexPath = [_fetchResultController indexPathForObject:video];
    [self.mediaCollectionView reloadItemsAtIndexPaths:@[indexPath]];
}

- (void)didTappOnPauseButtonFromCell:(YDMediaLibraryRowCell *)cell
{
    if (cell.downloadControlState == YDDownloadControlDisable) {
        return;
    }
    NSManagedObjectContext *privateQueueContext = [NSManagedObjectContext MR_contextForCurrentThread];
    NSNumber *videoID = cell.videoID;
    Video  *video = [Video findByVideoID:videoID inContext:privateQueueContext];
    if (!video) {
        return;
    }
    DownloadTask *downloadTask = video.downloadTask;
    NSNumber *downloadID = downloadTask.downloadID;
    if (cell.downloadControlState == YDDownloadControlPause) {
        [[YDDownloadManager sharedInstance] pauseDownloadTaskWithDownloadTaskID:downloadID completion:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                [self refreshCellWithVideoID:videoID];
                           });
        }];
        cell.downloadControlState = YDDownloadControlResume;
    }
    else
    {
        [[YDDownloadManager sharedInstance] resumeDownloadTaskWithDownloadTaskID:downloadID completion:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                [self refreshCellWithVideoID:videoID];
            });
        }];
        cell.downloadControlState = YDDownloadControlPause;
    }
}

#pragma mark - UISearchBarDelegate
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    self.searchString = searchText;
    [self loadVideos];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    //hide the search bar when cancel is tapped
    [self toggleSearchBar];
    self.searchString = @"";
    [self loadVideos];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
}

@end
