//
//  YDMediaLibraryViewController.m
//  YoutubeDownloader
//
//  Created by HAO WANG on 11/15/13.
//  Copyright (c) 2013 HAO WANG. All rights reserved.
//

#import "YDMediaLibraryViewController.h"
#import "YDConstants.h"

@interface YDMediaLibraryViewController ()
{
    //control buttons
    UIButton *_backButton;
    UIButton *_thumbnailButton;
    UIButton *_searchButton;
    UIButton *_deleteButton;
}

@property (weak, nonatomic) IBOutlet UIView *deviceSpaceStatusBar;

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
    //[_thumbnailButton addTarget:self action:@selector(goHomePage) forControlEvents:UIControlEventTouchUpInside];
    
    _searchButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_searchButton setImage:[UIImage imageNamed:@"ic_search"] forState:UIControlStateNormal];
    _searchButton.frame = CGRectMake(0, 0, NAVIGATION_BUTTON_WIDTH, NAVIGATION_BUTTON_HEIGHT);
    //[_searchButton addTarget:self action:@selector(downloadProcess:) forControlEvents:UIControlEventTouchUpInside];
    
    _deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_deleteButton setImage:[UIImage imageNamed:@"ic_delete"] forState:UIControlStateNormal];
    _deleteButton.frame = CGRectMake(0, 0, NAVIGATION_BUTTON_WIDTH, NAVIGATION_BUTTON_HEIGHT);
    //[_deleteButton addTarget:self action:@selector(toProgramLibrary:) forControlEvents:UIControlEventTouchUpInside];
    
    self.navigationButtons = @[_backButton, _thumbnailButton, _searchButton, _deleteButton];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - navigation control
- (void)dismiss
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
