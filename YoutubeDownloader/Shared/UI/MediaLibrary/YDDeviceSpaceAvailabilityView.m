//
//  YDDeviceSpaceAvailabilityView.m
//  YoutubeDownloader
//
//  Created by HAO WANG on 11/17/13.
//  Copyright (c) 2013 HAO WANG. All rights reserved.
//

#import "YDDeviceSpaceAvailabilityView.h"
#import "YDDeviceUtility.h"
#import "YDConstants.h"

@interface YDDeviceSpaceAvailabilityView ()
{
    CGFloat _barHeight;
}

@property (nonatomic, strong) UIView *otherAppSpaceBar;
@property (nonatomic, strong) UIView *thisAppSpaceBar;
@property (nonatomic, strong) UIView *availableSpaceBar;

@end

@implementation YDDeviceSpaceAvailabilityView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _barHeight = frame.size.height;
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self layoutColoredSpaceBarAnimated:NO];
}

- (void)layoutColoredSpaceBarAnimated:(BOOL)animated
{
    if (animated) {
        [UIView animateWithDuration:0.2f animations:^{
            [self layoutColoredSpaceBar];
        }];
    }else{
        [self layoutColoredSpaceBar];
    }
}

- (void)layoutColoredSpaceBar
{
    VSDeviceSpace *deviceSpace = [YDDeviceUtility getDeviceSpace];
    
    uint64_t totalSpace = deviceSpace.totalSpace;
    uint64_t availableSpace = deviceSpace.availableSpace;
    uint64_t usedSpace = totalSpace - availableSpace;
    
    CGFloat totalLength = self.frame.size.width;
    CGFloat otherAppSpaceBarWidth = 1.0*usedSpace/totalSpace * totalLength;
    CGFloat availableSpaceBarWidth = 1.0*availableSpace/totalSpace * totalLength;
    
    if (!self.otherAppSpaceBar) {
        self.otherAppSpaceBar = [[UIView alloc]initWithFrame:CGRectMake(0, 0, otherAppSpaceBarWidth, _barHeight)];
        self.otherAppSpaceBar.backgroundColor = DEVICE_SPACE_OTHER_APP_BAR_COLOR;
    }else{
        self.otherAppSpaceBar.frame = CGRectMake(0, 0, otherAppSpaceBarWidth, _barHeight);
    }
    
    if (!self.availableSpaceBar) {
        self.availableSpaceBar = [[UIView alloc]initWithFrame:CGRectMake(otherAppSpaceBarWidth, 0, availableSpaceBarWidth, _barHeight)];
        self.availableSpaceBar.backgroundColor = DEVICE_SPACE_AVAILABLE_BAR_COLOR;
    }else{
        self.availableSpaceBar.frame = CGRectMake(otherAppSpaceBarWidth, 0, availableSpaceBarWidth, _barHeight);
    }
    
    [self addSubview:self.otherAppSpaceBar];
    [self addSubview:self.availableSpaceBar];
}

@end
