//
//  BadgedButton.m
//  YoutubeDownloader
//
//  Created by HAO WANG on 11/18/13.
//  Copyright (c) 2013 HAO WANG. All rights reserved.
//

#import "BadgedButton.h"

@implementation BadgedButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setBadgeNumber:(NSInteger)num
{
    if (!self.badgeView) {
        _badgeView = [CustomBadge customBadgeWithString:@"2"
                                        withStringColor:[UIColor whiteColor]
                                         withInsetColor:[UIColor redColor]
                                         withBadgeFrame:YES
                                    withBadgeFrameColor:[UIColor whiteColor]
                                              withScale:1.0
                                            withShining:YES];
        _badgeView.userInteractionEnabled = NO;
        
        CGRect badgeFrame = _badgeView.frame;
        badgeFrame.origin.x -= 5;
        badgeFrame.origin.y -= 5;
        _badgeView.frame = badgeFrame;
        [self addSubview:_badgeView];
    }
    
    _badgeView.hidden = num == 0;
    _badgeView.badgeText = [NSString stringWithFormat:@"%d", num];
    [_badgeView setNeedsDisplay];
}

@end
