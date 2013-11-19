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
#import "YDDownloadManager.h"
#import "YDMediaLibraryViewController.h"
#import "BadgedButton.h"

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

@property (nonatomic, weak) IBOutlet UIWebView *webView;

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

// Get current page url
- (NSString *)getURL
{
    return [self.webView stringByEvaluatingJavaScriptFromString:@"document.URL"];
}

- (NSString *)getTitle
{
    return [self.webView stringByEvaluatingJavaScriptFromString:@"document.title"];
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
    
    /*debug, need to move this to whenever download finish notification is finish and when checking current new downloaded videos*/
    [_libraryButton setBadgeNumber:2];
}

#pragma mark - actions
- (IBAction)goPrevPage:(id)sender
{
    [self.webView goBack];
}

- (IBAction)toProgramLibrary:(id)sender
{
    YDMediaLibraryViewController *mediaLibraryViewController = [[YDMediaLibraryViewController alloc]init];
    [self.navigationController pushViewController:mediaLibraryViewController animated:YES];
}

- (void)downloadProcess:(id)sender
{
    [self showToastMessage:NSLocalizedString(@"Getting video information...", @"Parse the html page and get video information") hideAfterDelay:0.0 withProgress:YES];
    [self processForPageLoaded];
}

- (void)goHomePage
{
    [self.webView stringByEvaluatingJavaScriptFromString:@"document.body.innerHTML = ''"];
    NSString *homeUrl = @"http://m.youtube.com";
    [self loadUrl:[NSURL URLWithString:homeUrl]];
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
    [_urlExtractor extractVideoURLWithCompletionBlock:^(NSURL *videoUrl, NSDictionary *dictionary, NSError *error) {
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
            [self showToastMessage:NSLocalizedString(@"No downloadable video found.", @"No downloadable video found or the page was not loaded completly.") hideAfterDelay:2];
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
    
    [self showToastMessage:@"Please wait..." hideAfterDelay:0];
    ActionStringDoneBlock done = ^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
        NSString *videoFileDownloadUrl = downloadableVideos[selectedValue];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSManagedObjectContext *privateQueueContext = [NSManagedObjectContext MR_contextForCurrentThread];
            DownloadTask *downloadTask = [DownloadTask findByDownloadPageUrl:_downloadPageUrl qualityType:selectedValue inContext:privateQueueContext];
            if (downloadTask && [downloadTask.downloadTaskStatus integerValue] == DownloadTaskFailed)
            {
                downloadTask.downloadTaskStatus = @(DownloadTaskWaiting);
                dispatch_async(dispatch_get_main_queue(),^{
                    [self dismissAllToastMessages];
                });
                return;
            }
            if (downloadTask)
            {
                dispatch_async(dispatch_get_main_queue(),^{
                    [self dismissAllToastMessages];
                    [self showToastMessage:@"You have selected this video" hideAfterDelay:3.0];
                });
                return;
            }
            [[YDDownloadManager sharedInstance] createDownloadTaskWithDownloadPageUrl:_downloadPageUrl qualityType:selectedValue videoDescription:_title videoDownloadUrl:videoFileDownloadUrl inContext:privateQueueContext completion:^(BOOL success) {
                dispatch_async(dispatch_get_main_queue(),^{
                    [self dismissAllToastMessages];
                });
            }];
        });

    };
    
    ActionStringCancelBlock cancel = ^(ActionSheetStringPicker *picker) {
        
    };
    
    NSArray *mediaQualities = [NSArray arrayWithArray:[downloadableVideos allKeys]];                          
    [ActionSheetStringPicker showPickerWithTitle:@"Select a Media Quality" rows:mediaQualities initialSelection:0 doneBlock:done cancelBlock:cancel origin:_downloadButton];

}

#pragma mark UIWebViewDelegate methods
- (BOOL)webView:(UIWebView *)wv shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
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
