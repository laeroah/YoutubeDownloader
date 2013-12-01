//
//  YDDownloadManager.m
//  YoutubeDownloader
//
//  Created by Hao Wang  on 13-11-17.
//  Copyright (c) 2013年 HAO WANG. All rights reserved.
//

#import "YDDownloadManager.h"
#import "DownloadTask.h"
#import "Video.h"
#import "YDMedia.h"
#import "YDFileUtil.h"
#import "AFNetworking.h"
#import "WebUtility.h"
#import "YDImageUtil.h"
#import "YDConstants.h"

@interface YDDownloadManager ()
{
    NSTimer *_refreshPlayStatusTimer;
    NSTimer *_getVideoInfoTimer;
}

@property (atomic, strong)      NSNumber *downloadTaskID;
@property (atomic, strong)      AFHTTPRequestOperation *downloadOperation;
@property (atomic, strong)      NSDate *lastWriteProgressTime;

@property (atomic, strong)      NSString *currentGetVideoInfoID;

@end

@implementation YDDownloadManager

+ (YDDownloadManager *)sharedInstance
{
    static YDDownloadManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[YDDownloadManager alloc] init];
        NSString *videoDirectory = [[YDFileUtil documentDirectoryPath] stringByAppendingPathComponent:@"videos"];
        [YDFileUtil createAbsoluteDirectory:videoDirectory];
    });
    return instance;
}

- (void)stopRefreshTimer
{
    if (_refreshPlayStatusTimer)
    {
        [_refreshPlayStatusTimer invalidate];
        _refreshPlayStatusTimer = nil;
    }
}

- (void)startRefreshTimer
{
    [self  stopRefreshTimer];
    _refreshPlayStatusTimer = [NSTimer timerWithTimeInterval:5 target:self selector:@selector(checkNewDownloadTask:) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:_refreshPlayStatusTimer forMode:NSRunLoopCommonModes];
}



- (void)checkNewDownloadTask:(NSTimer*)timer
{
    if (self.downloadTaskID)
    {
        return;
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if (self.downloadTaskID)
        {
            return;
        }
        
        NSManagedObjectContext *privateQueueContext = [NSManagedObjectContext MR_contextForCurrentThread];
        DownloadTask   *downloadingTask = [DownloadTask getDownloadingTaskInContext:privateQueueContext];
        if (!downloadingTask) {
            downloadingTask = [DownloadTask getWaitingDownloadTaskInContext:privateQueueContext];
        }
        
        if (downloadingTask)
        {
            self.downloadTaskID = downloadingTask.downloadID;
            self.lastWriteProgressTime = [NSDate date];
            downloadingTask.downloadTaskStatus = @(DownloadTaskDownloading);
            NSString *downloadUrl = downloadingTask.videoDownloadUrl;
            NSNumber *videoID = downloadingTask.video.videoID;
            [downloadingTask updateWithContext:privateQueueContext completion:^(BOOL success, NSError *error) {
                
                [self sendDownloadStatusChangeNotificationWithVideoID:videoID statusKey:@"downloadTaskStatus" statusValue:@(DownloadTaskDownloading)];
                
                if (![self createBackgroundTaskWithUrl:downloadUrl])
                {
                    [self setDownloadTaskStatus:NO];
                }
                
             }];
        }
    
    });
}

- (void)createDownloadTaskWithDownloadPageUrl:(NSString*)downloadPageUrl youtubeVideoID:(NSString*)youtubeVideoID qualityType:(NSString*)qualityType videoDescription:(NSString*)videoDescription videoTitle:(NSString*)videoTitle videoDownloadUrl:(NSString*)videoDownloadUrl inContext:(NSManagedObjectContext *)context completion:(void(^)(BOOL success))completion
{
    DownloadTask *task = [DownloadTask createDownloadTaskInContext:context];
    if (!task)
    {
        if (completion)
            completion(NO);
        return;
    }
    
    task.downloadPageUrl = downloadPageUrl;
	task.downloadPriority = DOWNLOAD_TASK_DEFAULT_PRIORITY;
	task.downloadTaskStatus = @(DownloadTaskWaiting);
	task.qualityType = qualityType;
    task.videoTitle = videoTitle;
	task.videoDescription = videoDescription;
	task.videoImagePath = nil;
	task.videoDownloadUrl = videoDownloadUrl;
    task.youtubeVideoID = youtubeVideoID;
    
    Video *video = [Video createVideoWithContext:context];
    video.createDate = [NSDate date];
    video.duration = @(0);
    video.isNew = @(NO);
    video.isRemoved = @(NO);
    video.qualityType = qualityType;
    video.videoDescription = videoDescription;
    video.videoFilePath = nil;
    video.videoImagePath = nil;
    video.videoTitle = videoTitle;
    
    task.video = video;
    video.downloadTask = task;
    
    [context MR_saveToPersistentStoreWithCompletion:^(BOOL success, NSError *error) {
        if (completion)
        {
            completion(YES);
        }
    }];
}

- (BOOL)createBackgroundTaskWithUrl:(NSString*)url
{
    if (![url hasPrefix:@"http"] && ![url hasPrefix:@"https"])
    {
        return NO;
    }
    NSURL *downloadUrl = [NSURL URLWithString:url];
    NSURLRequest *requestVid = [NSURLRequest requestWithURL:downloadUrl];
    __weak YDDownloadManager *weakSelf = self;
    self.downloadOperation = [[AFHTTPRequestOperation alloc] initWithRequest:requestVid];
    self.downloadOperation.outputStream = [NSOutputStream outputStreamToFileAtPath:[self getCurrentDownloadFileDestPath:self.downloadTaskID] append:NO];
    [self.downloadOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        [weakSelf setDownloadTaskStatus:YES];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [weakSelf setDownloadTaskStatus:NO];
    }];
    
    [self.downloadOperation setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
        NSDate *currentTime = [NSDate date];
        if ([currentTime compare:[weakSelf.lastWriteProgressTime dateByAddingTimeInterval:1]] == NSOrderedAscending)
        {
            return;
        }
        float currentProgress = totalBytesExpectedToRead > 0 ? (float)totalBytesRead / totalBytesExpectedToRead : 0.0;
        weakSelf.lastWriteProgressTime = currentTime;
        NSManagedObjectContext *privateQueueContext = [NSManagedObjectContext MR_contextForCurrentThread];
        DownloadTask *downloadingTask = [DownloadTask findByDownloadID:weakSelf.downloadTaskID inContext:privateQueueContext];
        if (downloadingTask) {
            downloadingTask.downloadProgress = @(currentProgress);
            downloadingTask.videoFileSize = @(totalBytesExpectedToRead);
            [downloadingTask updateWithContext:privateQueueContext completion:^(BOOL success, NSError *error) {
            }];
            [weakSelf sendDownloadStatusChangeNotificationWithVideoID:downloadingTask.video.videoID statusKey:@"downloadProgress" statusValue:@(currentProgress)];
        }
    }];
   
    [self.downloadOperation start];
 
    return YES;
}

- (void)createCurrentDownloadVideoThumbWithDownloadTask:(DownloadTask*)downloadTask
{
    YDMedia *media = [[YDMedia alloc] init];
    media.mediaType = ALAssetTypeVideo;
    media.mediaUrl = [self getCurrentDownloadFileDestPath:downloadTask.downloadID];
    [media duration];
    NSString *imagePath = [[YDFileUtil documentDirectoryPath] stringByAppendingPathComponent:@"images"];
    [YDFileUtil createAbsoluteDirectory:imagePath];
    NSString *imageFileName = [NSString stringWithFormat:@"%@.jpeg", self.downloadTaskID];
    NSString *imageFilePath = [imagePath stringByAppendingPathComponent:imageFileName];
    UIImage *thumbnail = [media getThumbNailFromDocumentMedia:media.mediaUrl];
    if (thumbnail)
    {
        thumbnail = [YDImageUtil scaleImage:thumbnail maxSize:CGSizeMake(80,80)];
        NSData* imageData = UIImageJPEGRepresentation(thumbnail, 1.0);
        [imageData writeToFile:imageFilePath atomically:YES];
    }
    
    NSManagedObjectContext * privateQueueContext = [NSManagedObjectContext MR_contextForCurrentThread];
        DownloadTask *downloadingTask = [DownloadTask findByDownloadID:self.downloadTaskID inContext:privateQueueContext];
        Video *video = downloadingTask.video;
        video.createDate = [NSDate date];
        video.duration = @([media duration]);
        video.isNew = @(YES);
        video.isRemoved = @(NO);
        video.qualityType = downloadingTask.qualityType;
        video.videoDescription = downloadingTask.videoDescription;
        video.videoFilePath = media.mediaUrl;
        video.videoImagePath = imageFilePath;
        video.videoTitle = downloadingTask.videoTitle;
        [video updateWithContext:privateQueueContext completion:^(BOOL success, NSError *error) {
            self.downloadTaskID = nil;
            self.downloadOperation = nil;
        }];
}

- (void)setDownloadTaskStatus:(BOOL)success
{
    NSManagedObjectContext *privateQueueContext = [NSManagedObjectContext MR_contextForCurrentThread];
    DownloadTask *downloadingTask = [DownloadTask findByDownloadID:self.downloadTaskID inContext:privateQueueContext];
    if (success) {
        downloadingTask.downloadProgress = @(1.0);
        downloadingTask.downloadTaskStatus = @(DownloadTaskFinished);
    }
    else {
        downloadingTask.downloadTaskStatus = @(DownloadTaskFailed);
    }
    
    if (!success)
    {
        [downloadingTask updateWithContext:privateQueueContext completion:^(BOOL success, NSError *error) {
            [self sendDownloadStatusChangeNotificationWithVideoID:downloadingTask.video.videoID statusKey:@"downloadTaskStatus" statusValue:downloadingTask.downloadTaskStatus];
            self.downloadTaskID = nil;
            self.downloadOperation = nil;
        }];
        return;
    }
    [downloadingTask updateWithContext:privateQueueContext completion:^(BOOL success, NSError *error) {
        [self createCurrentDownloadVideoThumbWithDownloadTask:downloadingTask];
        [self sendDownloadStatusChangeNotificationWithVideoID:downloadingTask.video.videoID statusKey:@"downloadTaskStatus" statusValue:downloadingTask.downloadTaskStatus];
    }];
}

- (NSString*)getCurrentDownloadFileDestPath:(NSNumber*)downloadTaskID
{
    NSString *videoDirectory = [[YDFileUtil documentDirectoryPath] stringByAppendingPathComponent:@"videos"];
    [YDFileUtil createAbsoluteDirectory:videoDirectory];
    NSString *fileName = [NSString stringWithFormat:@"%@.mp4",downloadTaskID];
    return [videoDirectory stringByAppendingPathComponent:fileName];
}

- (void)cancelDownloadTaskWithID:(NSNumber *)downloadID
{
    if (!self.downloadTaskID)
        return;
    
    if (![self.downloadTaskID isEqualToNumber:downloadID])
        return;
    
    if (self.downloadOperation)
    {
        [self.downloadOperation cancel];
        self.downloadOperation = nil;
    }
}

- (void)sendDownloadStatusChangeNotificationWithVideoID:(NSNumber*)videoID statusKey:(NSString *)statusKeyName statusValue:(NSNumber *)statusKeyValue
{
    NSDictionary *userInfo = @{
                               @"videoID" : videoID,
                               statusKeyName : statusKeyValue
                               };
    [[NSNotificationCenter defaultCenter] postNotificationName: kDownloadTaskStatusChangeNotification object: nil userInfo:userInfo];
}


@end
