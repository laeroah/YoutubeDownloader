//
//  YDPlayerViewController.h
//  VideoPlayerSample
//
//  Created by HAO WANG on 11/4/13.
//  Copyright (c) 2013 HAO WANG. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YDBaseViewController.h"
#import "YDPlayer.h"

@interface YDPlayerViewController : UIViewController <YDPlayerDelegate>

@property (nonatomic, strong) YDPlayer *player;

/**
 * @discussion present a fullscreen video
 */
- (void)presentPlayerViewControllerFromViewController:(UIViewController *)containerViewController;
- (void)playLocalVideoWithPath:(NSString *)videoPath;


@end
