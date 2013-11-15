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
#import "YDMediaLibraryViewController.h"

@interface YDSearchViewController ()
{
    //control buttons
    UIButton *_backButton;
    UIButton *_homeButton;
    UIButton *_downloadButton;
    UIButton *_libraryButton;
    NSURL *_downloadUrl;
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
    NSString *theTitle=[self.webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    theTitle = [theTitle stringByReplacingOccurrencesOfString:@" - YouTube" withString:@""];
    return  [theTitle stringByAppendingString:@".mp4"];
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
    
    _libraryButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_libraryButton setImage:[UIImage imageNamed:@"ic_library"] forState:UIControlStateNormal];
    _libraryButton.frame = CGRectMake(0, 0, NAVIGATION_BUTTON_WIDTH, NAVIGATION_BUTTON_HEIGHT);
    [_libraryButton addTarget:self action:@selector(toProgramLibrary:) forControlEvents:UIControlEventTouchUpInside];
    
    self.navigationButtons = @[_backButton, _homeButton, _downloadButton, _libraryButton];
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
    
    NSString *orgUrl = [self  getURL];
    _urlExtractor = [[YDVideoLinksExtractorManager alloc] initWithURL:[NSURL URLWithString:orgUrl] quality:YDYouTubeVideoQualityMedium];
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

    ActionStringDoneBlock done = ^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
        NSString *videoFileDownloadUrl = downloadableVideos[selectedValue];
        NSLog(@"selectdValue = %@",videoFileDownloadUrl);

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
