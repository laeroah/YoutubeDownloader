//
//  YDMediaLibraryRowCell.m
//  YoutubeDownloader
//
//  Created by HAO WANG on 11/16/13.
//  Copyright (c) 2013 HAO WANG. All rights reserved.
//

#import "YDMediaLibraryRowCell.h"
#import "Video.h"
#import "DownloadTask.h"

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

- (void)updateVideoDownloadProgress:(NSNotification *) notification
{
    if ([notification.userInfo objectForKey:@"downloadProgress"]) {
        if (self.videoID) {
            NSManagedObjectContext *context = [NSManagedObjectContext MR_contextForCurrentThread];
            Video *video = [Video findByVideoID:self.videoID inContext:context];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                self.downloadProgressBar.progress = video.downloadTask.downloadProgress.floatValue;
            
            CGFloat fileSize = video.downloadTask.videoFileSize.integerValue;
            CGFloat downloadedSize = video.downloadTask.downloadProgress.floatValue * fileSize / 1024 / 1024; //in MB
            
            self.currentProgressLabel.text = [NSString stringWithFormat:NSLocalizedString(@"%.1fMB/%.1fMB", nil), downloadedSize, fileSize/1024/1024];
            });
        }
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
