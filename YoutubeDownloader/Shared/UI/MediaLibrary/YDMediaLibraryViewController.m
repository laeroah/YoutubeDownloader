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

typedef enum
{
    YDMediaLibraryViewControllerLayoutRow,
    YDMediaLibraryViewControllerLayoutThumbnail
}YDMediaLibraryViewControllerLayout;

@interface YDMediaLibraryViewController ()
{
    //control buttons
    UIButton *_backButton;
    UIButton *_thumbnailButton;
    UIButton *_searchButton;
    UIButton *_deleteButton;
    YDMediaLibraryViewControllerLayout _currentLayout;
    BOOL _editMode;
}

@property (weak, nonatomic) IBOutlet UIView *deviceSpaceStatusBar;
@property (weak, nonatomic) IBOutlet UICollectionView *mediaCollectionView;

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
    //[_searchButton addTarget:self action:@selector(downloadProcess:) forControlEvents:UIControlEventTouchUpInside];
    
    _deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_deleteButton setImage:[UIImage imageNamed:@"ic_delete"] forState:UIControlStateNormal];
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
    if (_editMode) {
        
    }else{
        
    }
    _editMode = !_editMode;
}

@end
