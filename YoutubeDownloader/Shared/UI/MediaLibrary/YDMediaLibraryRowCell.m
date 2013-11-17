//
//  YDMediaLibraryRowCell.m
//  YoutubeDownloader
//
//  Created by HAO WANG on 11/16/13.
//  Copyright (c) 2013 HAO WANG. All rights reserved.
//

#import "YDMediaLibraryRowCell.h"

@implementation YDMediaLibraryRowCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)enterEditMode:(BOOL)enter animated:(BOOL)animated
{
    if (animated) {
        [UIView animateWithDuration:0.2f animations:^{
            [self enterEditMode:enter];
        }];
    }
}

- (void)enterEditMode:(BOOL)enter
{
    if (enter) {
        
    }else{
        
    }
}

@end
