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
    }else{
        [self enterEditMode:enter];
    }
}

- (void)enterEditMode:(BOOL)enter
{
    if (enter) {
        self.deleteButton.hidden = NO;
    }else{
        self.deleteButton.hidden = YES;
    }
}

- (void)enterDownloadMode:(BOOL)enter
{
    self.currentProgressLabel.hidden = !enter;
    self.downloadProgressBar.hidden = !enter;
    self.downloadControlButton.hidden = !enter;
}

- (IBAction)deleteButtonTapped:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(didChooseToRemoveCell:)]) {
        [self.delegate didChooseToRemoveCell:self];
    }
}

- (IBAction)pauseButtonTapped:(id)sender {
    self.downloadControlButton.selected = !self.downloadControlButton.selected;
    if (self.delegate && [self.delegate respondsToSelector:@selector(didTappOnPauseButtonFromCell:)]) {
        [self.delegate didTappOnPauseButtonFromCell:self];
    }
}

@end
