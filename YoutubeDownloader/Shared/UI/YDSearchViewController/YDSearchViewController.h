//
//  YDSearchViewController.h
//  YoutubeDownloader
//
//  Created by Hao Wang  on 13-11-4.
//  Copyright (c) 2013年 HAO WANG. All rights reserved.
//

#import "YDBaseViewController.h"
#import "YDAnalyticManager.h"

@interface YDSearchViewController : YDBaseViewController<UIWebViewDelegate,UIActionSheetDelegate>

@property (nonatomic, strong) UIButton *downloadButton;
@property (nonatomic, weak) IBOutlet UIWebView *webView;

@end
