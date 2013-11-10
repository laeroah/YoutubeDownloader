//
//  YDBaseViewController.h
//  YoutubeDownloader
//
//  Created by Hao Wang  on 13-11-4.
//  Copyright (c) 2013年 HAO WANG. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YDBaseViewController : UIViewController

@property (nonatomic, strong) NSArray *navigationButtons;

- (void)showToastMessage:(NSString *)msg hideAfterDelay:(NSTimeInterval)seconds;
- (void)showToastMessage:(NSString *)msg hideAfterDelay:(NSTimeInterval)seconds withProgress:(BOOL)useProgress;
- (void)showToastMessage:(NSString *)msg
          hideAfterDelay:(NSTimeInterval)seconds
            withProgress:(BOOL)useProgress
         backgroundColor:(UIColor *)backgroundColor
               textColor:(UIColor *)textColor;
- (void)dismissToastMessage;
- (void)dismissAllToastMessages;

@end
