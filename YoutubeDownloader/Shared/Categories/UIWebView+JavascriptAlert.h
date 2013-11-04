//
//  UIWebView+JavascriptAlert.h
//  YoutubeDownloader
//
//  Created by Hao Wang  on 13-11-4.
//  Copyright (c) 2013年 HAO WANG. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIWebView (JavascriptAlert)

- (void)webView:(UIWebView *)sender runJavaScriptAlertPanelWithMessage:(NSString *)message;

@end
