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

@interface YDSearchViewController ()
{

}

@property (nonatomic, weak) IBOutlet UIWebView *webView;

@end

@implementation YDSearchViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)configureNavigationBarTitleAndButtons
{
    if (self.webView.canGoBack)
        self.navigationItem.leftBarButtonItem.enabled = YES;
    else
        self.navigationItem.leftBarButtonItem.enabled = NO;
}

- (void)goHomePage
{
    [self.webView stringByEvaluatingJavaScriptFromString:@"document.body.innerHTML = ''"];
    NSString *homeUrl = @"http://m.youtube.com";
    [self loadUrl:[NSURL URLWithString:homeUrl]];
}

- (void)loadUrl:(NSURL *)url
{
    [self.webView loadRequest:[NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:30]];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem barButtonItemWithImageInCustomView:[UIImage imageNamed:@"ic_backButton"] target:self action:@selector(goPrevPage:)];
    
    UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, 44)];
    
    UIButton *homeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [homeButton setImage:[UIImage imageNamed:@"ic_home"]  forState:UIControlStateNormal];
    [homeButton addTarget:self action:@selector(goHomePage) forControlEvents:UIControlEventTouchUpInside];
    homeButton.frame = CGRectMake(0, 6, 32, 32);
    [titleView addSubview:homeButton];
    
    UIButton *downloadButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [downloadButton setImage:[UIImage imageNamed:@"ic_download"]  forState:UIControlStateNormal];
    [downloadButton addTarget:self action:@selector(downloadProcess:) forControlEvents:UIControlEventTouchUpInside];
    downloadButton.frame = CGRectMake(160, 6, 32, 32);
    [titleView addSubview:downloadButton];
    
    self.navigationItem.titleView = titleView;
    
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem barButtonItemWithImageInCustomView:[UIImage imageNamed:@"ic_library"]
                                target:self
                                                action:@selector(toProgramLibrary:)];
    
    [NSTimer scheduledTimerWithTimeInterval:0.9 target:self selector:@selector(configureNavigationBarTitleAndButtons) userInfo:nil repeats:YES];
    
    [self goHomePage];
}

- (IBAction)goPrevPage:(id)sender
{
    [self.webView goBack];
}

- (IBAction)toProgramLibrary:(id)sender
{
    
}

- (IBAction)downloadProcess:(id)sender
{
    
}

#pragma mark UIWebViewDelegate methods

- (BOOL)webView:(UIWebView *)wv shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)pWebView
{
}

- (void)webViewDidFinishLoad:(UIWebView *)pWebView
{
}


- (void)webView:(UIWebView *)pWebView didFailLoadWithError:(NSError *)error
{
    if (error)
    {
        NSLog(@"error = %@",[error description]);
    }
}


@end
