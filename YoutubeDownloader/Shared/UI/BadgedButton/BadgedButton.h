//
//  BadgedButton.h
//  YoutubeDownloader
//
//  Created by HAO WANG on 11/18/13.
//  Copyright (c) 2013 HAO WANG. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomBadge.h"

@interface BadgedButton : UIButton

@property (nonatomic, strong) CustomBadge *badgeView;

- (void)setBadgeNumber:(NSInteger)num;

@end
