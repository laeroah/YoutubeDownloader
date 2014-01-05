//
//  YDSearchViewController.m
//  YoutubeDownloader
//
//  Created by Hao Wang  on 13-11-4.
//  Copyright (c) 2013年 HAO WANG. All rights reserved.
//

#import "YDSearchViewController.h"
#import "YDDeviceUtility.h"
#import "UIBarButtonItem+Private.h"
#import "YDConstants.h"
#import "YDVideoLinksExtractorManager.h"
#import "ActionSheetStringPicker.h"
#import "DownloadTask.h"
#import "Video.h"
#import "YDDownloadManager.h"
#import "YDMediaLibraryViewController.h"
#import "BadgedButton.h"
#import "YDAnalyticManager.h"

@interface YDSearchViewController ()
{
    //control buttons
    UIButton *_backButton;
    UIButton *_homeButton;
    UIButton *_downloadButton;
    BadgedButton *_libraryButton;
    NSString *_downloadPageUrl;
    NSURL *_downloadUrl;
    NSString *_title;
    YDVideoLinksExtractorManager *_urlExtractor;
    NSDictionary *downloadableVideos;
}

@property (nonatomic, strong) NSString *youtubeVideoID;
@property (nonatomic, strong) NSNumber *youtubeVideoDuration;
@end

@implementation YDSearchViewController

- (void)configureNavigationBarTitleAndButtons
{
    if (self.webView.canGoBack)
        self.navigationItem.leftBarButtonItem.enabled = YES;
    else
        self.navigationItem.leftBarButtonItem.enabled = NO;
}

- (void)loadUrl:(NSURL *)url
{
    [self.webView loadRequest:[NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:30]];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    [self createControlButtons];
    self.webView.mediaPlaybackRequiresUserAction = YES;
    [self goHomePage];
    
    // setup the screen name for GA tracking
    self.screenName = SCREEN_NAME_SEARCH_VIEW;
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivesVideoDownloadStatusChangeNotification:)
                                                 name:kDownloadTaskStatusChangeNotification
                                               object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if (_urlExtractor)
    {
        [_urlExtractor stopExtracting];
        _urlExtractor = nil;
    }
    [self dismissAllToastMessages];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self updateNewVideoBadge];
}

// Get current page url
- (NSString *)getURL
{
    return [self.webView stringByEvaluatingJavaScriptFromString:@"document.URL"];
}

- (NSString *)getTitle
{
    return [self.webView stringByEvaluatingJavaScriptFromString:@"document.title"];
}

- (void)receivesVideoDownloadStatusChangeNotification:(NSNotification *) notification
{
    [self updateNewVideoBadge];
}

- (void)createControlButtons
{
    _backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_backButton setImage:[UIImage imageNamed:@"ic_backButton"] forState:UIControlStateNormal];
    _backButton.frame = CGRectMake(0, 0, NAVIGATION_BUTTON_WIDTH, NAVIGATION_BUTTON_HEIGHT);
    [_backButton addTarget:self action:@selector(goPrevPage:) forControlEvents:UIControlEventTouchUpInside];
    
    _homeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_homeButton setImage:[UIImage imageNamed:@"ic_home"] forState:UIControlStateNormal];
    _homeButton.frame = CGRectMake(0, 0, NAVIGATION_BUTTON_WIDTH, NAVIGATION_BUTTON_HEIGHT);
    [_homeButton addTarget:self action:@selector(goHomePage) forControlEvents:UIControlEventTouchUpInside];
    
    _downloadButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_downloadButton setImage:[UIImage imageNamed:@"ic_download"] forState:UIControlStateNormal];
    _downloadButton.frame = CGRectMake(0, 0, NAVIGATION_BUTTON_WIDTH, NAVIGATION_BUTTON_HEIGHT);
    [_downloadButton addTarget:self action:@selector(downloadProcess:) forControlEvents:UIControlEventTouchUpInside];
    
    _libraryButton = [BadgedButton buttonWithType:UIButtonTypeCustom];
    [_libraryButton setImage:[UIImage imageNamed:@"ic_library"] forState:UIControlStateNormal];
    _libraryButton.frame = CGRectMake(0, 0, NAVIGATION_BUTTON_WIDTH, NAVIGATION_BUTTON_HEIGHT);
    [_libraryButton addTarget:self action:@selector(toProgramLibrary:) forControlEvents:UIControlEventTouchUpInside];
    
    self.navigationButtons = @[_backButton, _homeButton, _downloadButton, _libraryButton];
    
    [self updateNewVideoBadge];
}

- (void)updateNewVideoBadge
{
    NSInteger numberOfNewVideos = [Video getNewVideosCountWithContext:[NSManagedObjectContext MR_contextForCurrentThread]];
    [_libraryButton setBadgeNumber:numberOfNewVideos];
}

#pragma mark - actions
- (IBAction)goPrevPage:(id)sender
{
    [self.webView goBack];
    
    [[YDAnalyticManager sharedInstance]trackWithCategory:EVENT_CATEGORY_SEARCH_VIEW action:EVENT_ACTION_NAVIGATION_BACK label:SCREEN_NAME_SEARCH_VIEW value:nil];
}

- (IBAction)toProgramLibrary:(id)sender
{
    YDMediaLibraryViewController *mediaLibraryViewController = [[YDMediaLibraryViewController alloc]init];
    [self.navigationController pushViewController:mediaLibraryViewController animated:YES];
    
    [[YDAnalyticManager sharedInstance]trackWithCategory:EVENT_CATEGORY_SEARCH_VIEW action:EVENT_ACTION_NAVIGATION_LIBRARY label:SCREEN_NAME_SEARCH_VIEW value:nil];
}

- (void)downloadProcess:(id)sender
{
    [self showToastMessage:NSLocalizedString(@"Getting video information...", @"Parse the html page and get video information") hideAfterDelay:0.0 withProgress:YES];
    [self processForPageLoaded];
    
    [[YDAnalyticManager sharedInstance]trackWithCategory:EVENT_CATEGORY_SEARCH_VIEW action:EVENT_ACTION_NAVIGATION_HOME label:SCREEN_NAME_SEARCH_VIEW value:nil];
}

- (void)goHomePage
{
    [self.webView stringByEvaluatingJavaScriptFromString:@"document.body.innerHTML = ''"];
    //NSString *homeUrl = @"http://m.youtube.com";
    NSString *homeUrl = @"http://m.youtube.com";
    [self loadUrl:[NSURL URLWithString:homeUrl]];
    
    [[YDAnalyticManager sharedInstance]trackWithCategory:EVENT_CATEGORY_SEARCH_VIEW action:EVENT_ACTION_NAVIGATION_DOWNLOAD label:SCREEN_NAME_SEARCH_VIEW value:nil];
}

- (void)processForPageLoaded
{
    if (_urlExtractor)
    {
        [_urlExtractor stopExtracting];
        _urlExtractor = nil;
    }
    
    _downloadPageUrl = [self  getURL];
    _title = [self getTitle];
    _urlExtractor = [[YDVideoLinksExtractorManager alloc] initWithURL:[NSURL URLWithString:_downloadPageUrl] quality:YDYouTubeVideoQualityMedium];
    [_urlExtractor extractVideoURLWithCompletionBlock:^(NSURL *videoUrl, NSString *youtubeVideoID, NSNumber *duration, NSDictionary *dictionary, NSError *error) {
        self.youtubeVideoID = youtubeVideoID;
        self.youtubeVideoDuration = duration;
        [self dismissAllToastMessages];
        if(!error && dictionary)
        {
            //show sheet
            _downloadUrl = videoUrl;
            downloadableVideos = [NSDictionary dictionaryWithDictionary:dictionary];
            [self showMediaPickers];
        }
        else
        {
            [self showToastMessage:NSLocalizedString(@"No video found.", @"No downloadable video found or the page was not loaded completly.") hideAfterDelay:2];
            
            [[YDAnalyticManager sharedInstance]trackWithCategory:EVENT_CATEGORY_VIDEO_DOWNLOAD action:EVENT_ACTION_CHOOSE_VIDEO_QUALITY label:SCREEN_NAME_SEARCH_VIEW value:nil];
        }
    }];

}

- (void)showMediaPickers
{
    if (![[NSThread currentThread] isMainThread])
    {
        [self performSelectorOnMainThread:@selector(showMediaPickers) withObject:nil waitUntilDone:NO];
        return;
    }
    
    NSArray *mediaQualities = [NSArray arrayWithArray:[downloadableVideos allKeys]];                          
  
    UIActionSheet *actionSheet = [[UIActionSheet alloc] init];
    actionSheet.title = @"Select a Media Quality";
    actionSheet.delegate = self;
    for (NSString *quality in mediaQualities) {
        [actionSheet addButtonWithTitle:quality];
    }
    actionSheet.cancelButtonIndex = [actionSheet addButtonWithTitle:@"Cancel"];
    
    actionSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [actionSheet showFromRect:[self.view convertRect:_downloadButton.frame fromView:_downloadButton.superview] inView:self.view animated:YES]; //this need to show from the button for iPad
    }else{
        [actionSheet showInView:self.view];
    }

}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == actionSheet.cancelButtonIndex)
    {
        return;
    }
    NSString *selectedValue = [actionSheet buttonTitleAtIndex:buttonIndex];
    
    [self showToastMessage:@"Please wait..." hideAfterDelay:0 withProgress:YES];
    NSString *videoFileDownloadUrl = downloadableVideos[selectedValue];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        [[YDAnalyticManager sharedInstance]trackWithCategory:EVENT_CATEGORY_SEARCH_VIEW action:EVENT_ACTION_CHOOSE_VIDEO_QUALITY label:SCREEN_NAME_SEARCH_VIEW value:@(buttonIndex)];
        
        NSManagedObjectContext *privateQueueContext = [NSManagedObjectContext MR_contextForCurrentThread];
        DownloadTask *downloadTask = [DownloadTask findByDownloadPageUrl:_downloadPageUrl qualityType:selectedValue inContext:privateQueueContext];
        
        if (downloadTask && downloadTask.downloadTaskStatusValue == DownloadTaskFailed) {
            [[YDDownloadManager sharedInstance] updateDownloadTask:downloadTask downloadPageUrl:_downloadPageUrl youtubeVideoID:self.youtubeVideoID videoDuration:self.youtubeVideoDuration qualityType:selectedValue videoDescription:_title videoTitle:_title videoDownloadUrl:videoFileDownloadUrl inContext:privateQueueContext completion:^(BOOL success, NSNumber *downloadTaskID) {
                [[YDDownloadManager sharedInstance] downloadVideoInfoWithDownloadTaskID:downloadTaskID];
                dispatch_async(dispatch_get_main_queue(),^{
                    [self dismissAllToastMessages];
                });
            }];
            
            return;
        }
        
        if (downloadTask)
        {
            dispatch_async(dispatch_get_main_queue(),^{
                [self dismissAllToastMessages];
                [self showToastMessage:@"This video is already buffered for you" hideAfterDelay:3.0];
            });
            return;
        }
        [[YDDownloadManager sharedInstance] createDownloadTaskWithDownloadPageUrl:_downloadPageUrl youtubeVideoID:self.youtubeVideoID videoDuration:self.youtubeVideoDuration qualityType:selectedValue videoDescription:_title videoTitle:_title videoDownloadUrl:videoFileDownloadUrl inContext:privateQueueContext completion:^(BOOL success, NSNumber *downloadTaskID) {
            [[YDDownloadManager sharedInstance] downloadVideoInfoWithDownloadTaskID:downloadTaskID];
            dispatch_async(dispatch_get_main_queue(),^{
                [self dismissAllToastMessages];
            });
        }];
    });

    
}
- (void)actionSheetCancel:(UIActionSheet *)actionSheet{
    
}

#pragma mark UIWebViewDelegate methods
- (BOOL)webView:(UIWebView *)wv shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSLog(@"load url %@", [request.URL absoluteString]);
    return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)pWebView
{
//    NSString* js = @"window.alert = function(message) {alert(message);}";
//    [self.webView stringByEvaluatingJavaScriptFromString: js];
//    
//    // trigger an alert.  for demonstration only:
//    [self.webView stringByEvaluatingJavaScriptFromString: @"alert('hello, world');" ];
    [self.webView stringByEvaluatingJavaScriptFromString:@"window.alert=null;"];
}

- (void)webView:(UIWebView *)pWebView didFailLoadWithError:(NSError *)error
{
    if (error)
    {
        NSLog(@"error = %@",[error description]);
    }
}



@end
