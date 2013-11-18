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

@property (weak, nonatomic) IBOutlet UIView *deviceSpaceStatusBar;
@property (weak, nonatomic) IBOutlet UICollectionView *mediaCollectionView;
@property (weak, nonatomic) IBOutlet UILabel *totalSpaceLabel;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

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
    
    UINib *nib = [UINib nibWithNibName:@"YDMediaLibraryRowCell" bundle:nil];
    [self.mediaCollectionView registerNib:nib forCellWithReuseIdentifier:@"YDMediaLibraryRowCell"];
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc]init];
    [self.mediaCollectionView setCollectionViewLayout:flowLayout];
    
    [self layoutDeviceSpaceBar];
    
    CGRect searchBarFrame = self.searchBar.frame;
    searchBarFrame.origin.y = -SEARCH_BAR_HEIGHT;
    self.searchBar.frame = searchBarFrame;
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
    _thumbnailButton.frame = CGRectMake(0, 0, NAVIGATION_BUTTON_WIDTH, NAVIGATION_BUTTON_HEIGHT);
    [_thumbnailButton addTarget:self action:@selector(toggleLayout) forControlEvents:UIControlEventTouchUpInside];
    
    _searchButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_searchButton setImage:[UIImage imageNamed:@"ic_search"] forState:UIControlStateNormal];
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

#pragma mark - UICollectionViewDelegate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 5;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    YDMediaLibraryRowCell *mediaCell =
    [collectionView dequeueReusableCellWithReuseIdentifier:@"YDMediaLibraryRowCell"
                                              forIndexPath:indexPath];
    
    
    if (_currentLayout == YDMediaLibraryViewControllerLayoutRow) {
        mediaCell.downloadControlButton.hidden = NO;
        mediaCell.downloadProgressBar.hidden = NO;
        mediaCell.videoTitleLabel.hidden = NO;
    }else{
        mediaCell.downloadControlButton.hidden = YES;
        mediaCell.downloadProgressBar.hidden = YES;
        mediaCell.videoTitleLabel.hidden = YES;
    }
    mediaCell.delegate = self;
    [mediaCell enterEditMode:_editMode animated:NO];
    
    return mediaCell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    // Adjust cell size for orientation
    if (_currentLayout == YDMediaLibraryViewControllerLayoutRow) {
        return CGSizeMake(self.view.frame.size.width, MEDIA_LIBRARY_ROW_HEIGHT);
    }else{
        return CGSizeMake(MEDIA_LIBRARY_THUMBNAIL_WIDTH, MEDIA_LIBRARY_ROW_HEIGHT);
    }
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section

{
    return UIEdgeInsetsZero;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 2;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 0;
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

- (void)toggleLayout
{
    if (_currentLayout == YDMediaLibraryViewControllerLayoutRow) {
        _currentLayout = YDMediaLibraryViewControllerLayoutThumbnail;
    }else{
        _currentLayout = YDMediaLibraryViewControllerLayoutRow;
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
}

- (void)toggleSearchBar
{
    CGRect searchBarFrame = self.searchBar.frame;
    CGRect mediaLibraryTableFrame = self.mediaCollectionView.frame;
    _searchBarShowing = !_searchBarShowing;
    
    if (_searchBarShowing) {
        searchBarFrame.origin.y = 0.0f;
        mediaLibraryTableFrame.origin.y = SEARCH_BAR_HEIGHT;
        mediaLibraryTableFrame.size.height -= SEARCH_BAR_HEIGHT;
    }else{
        searchBarFrame.origin.y -= SEARCH_BAR_HEIGHT;
        mediaLibraryTableFrame.origin.y = 0.0f;
        mediaLibraryTableFrame.size.height += SEARCH_BAR_HEIGHT;
    }
    [UIView animateWithDuration:0.2f animations:^{
        self.searchBar.frame = searchBarFrame;
        self.mediaCollectionView.frame = mediaLibraryTableFrame;
    }];
}

#pragma mark - YDMediaLibraryRowCellDelegate
- (void)didChooseToRemoveCell:(YDMediaLibraryRowCell *)cell
{
    
}

@end
