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
#import "YDSettingsManager.h"

@interface YDMediaLibraryRowCell()
{
    NSTimer *deleteTimer;
    NSDate *deleteDate;
}

@end

@implementation YDMediaLibraryRowCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setVideoID:(NSNumber *)videoID
{
    _videoID = videoID;
    NSManagedObjectContext *context = [NSManagedObjectContext MR_contextForCurrentThread];
    Video *video = [Video findByVideoID:videoID inContext:context];
    
    deleteDate = [video.createDate dateByAddingTimeInterval:[YDSettingsManager sharedInstance].timeToDeleteAfterDownload];
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
    self.timeToDeleteLabel.hidden = enter;
    
    if (!enter) {
        // start the delete timer after the video is downloaded
        if (!deleteTimer) {
            deleteTimer = [NSTimer scheduledTimerWithTimeInterval:0.5f target:self selector:@selector(checkDeleteDate) userInfo:nil repeats:YES];
        }
    }else{
        if (deleteTimer) {
            [deleteTimer invalidate];
            deleteTimer = nil;
        }
    }
}

- (void)checkDeleteDate
{
    NSTimeInterval timeInterval = [deleteDate timeIntervalSinceDate:[NSDate date]];
    self.timeToDeleteLabel.text = [self timeDeleteLabelTextFromTimeInterval:timeInterval];
    
    if (timeInterval <= 0) { // delete the video when the delete time reaches
        [self deleteButtonTapped:nil];
        [deleteTimer invalidate];
        deleteTimer = nil;
    }
}

- (NSString *)timeDeleteLabelTextFromTimeInterval:(NSTimeInterval)timeToDelete
{
    NSInteger hours = timeToDelete/3600;
    NSInteger mins = (long)timeToDelete%3600/60;
    NSInteger secs = (long)timeToDelete%60;
    
    return [NSString stringWithFormat:@"expires in %.2d:%.2d:%.2d", hours, mins, secs];
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
    if (deleteTimer) {
        [deleteTimer invalidate];
        deleteTimer = nil;
    }
}

@end
