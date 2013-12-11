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
#import "YDNetworkUtility.h"

@interface YDDownloadManager ()
{
    NSTimer *_refreshPlayStatusTimer;
    NSTimer *_getVideoInfoTimer;
    NSTimer *_clearTimer;
}

@property (atomic, strong)      NSNumber *downloadTaskID;
@property (atomic, strong)      NSDate *lastWriteProgressTime;
@property (atomic, strong)      YDNetworkUtility *networkUtility;
@property (atomic, strong)      NSNumber *currentGetVideoInfoID;
@property (atomic, assign)      BOOL isClearing;

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

- (void)stopClearTimer
{
    if (_clearTimer)
    {
        [_clearTimer invalidate];
        _clearTimer = nil;
    }
}

- (void)startClearTimer
{
    [self  stopClearTimer];
    _clearTimer = [NSTimer timerWithTimeInterval:5 target:self selector:@selector(doClearTask:) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:_clearTimer forMode:NSRunLoopCommonModes];
}

- (void)startGetVideoInfoTimer
{
    [self  stopGetVideoInfoTimer];
    _getVideoInfoTimer = [NSTimer timerWithTimeInterval:5 target:self selector:@selector(checkVideoInfoNotBeDownloaded:) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:_getVideoInfoTimer forMode:NSRunLoopCommonModes];
}

- (void)stopGetVideoInfoTimer
{
    if (_getVideoInfoTimer)
    {
        [_getVideoInfoTimer invalidate];
        _getVideoInfoTimer = nil;
    }
}

- (void)checkVideoInfoNotBeDownloaded:(NSTimer*)timer
{
    if (self.isClearing) {
        return;
    }
    [self stopGetVideoInfoTimer];
    NSManagedObjectContext *privateQueueContext = [NSManagedObjectContext MR_contextForCurrentThread];
    DownloadTask *downloadTask = [DownloadTask findVideoInfoNotDownloadTaskWithContext:privateQueueContext];
    if (!downloadTask) {
        [self startGetVideoInfoTimer];
        return;
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self downloadVideoInfoWithDownloadTaskID:downloadTask.downloadID];
    });
}

- (void)downloadVideoInfoWithDownloadTaskID:(NSNumber *)downloadTaskID
{
    if (self.currentGetVideoInfoID || self.isClearing)
    {
        return;
    }
    
    self.currentGetVideoInfoID = downloadTaskID;
    NSManagedObjectContext *privateQueueContext = [NSManagedObjectContext MR_contextForCurrentThread];
    
    DownloadTask *downloadTask =  [DownloadTask findByDownloadID:downloadTaskID inContext:privateQueueContext];
    
    if (!downloadTask || downloadTask.video.isRemoved.integerValue == 1)
    {
        [self checkVideoInfoNotBeDownloaded:nil];
        return;
    }
    
    if (!downloadTask.videoImagePath) {
        [self downloadVideoImageWithVideoID:downloadTask.youtubeVideoID];
        return;
    }
    
    if (downloadTask.videoFileSizeValue == 0){
        [self getVideoFileSize];
        return;
    }
}

- (void)downloadVideoImageWithVideoID:(NSString *)youtubeVideoID
{
    NSString *imageUrlString = [NSString stringWithFormat:@"http://img.youtube.com/vi/%@/default.jpg",youtubeVideoID];
    NSURL *imageUrl = [NSURL URLWithString:imageUrlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:imageUrl];
    AFHTTPRequestOperation *postOperation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    postOperation.responseSerializer = [AFImageResponseSerializer serializer];
    [postOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSString *imagePath = [[YDFileUtil documentDirectoryPath] stringByAppendingPathComponent:@"images"];
        [YDFileUtil createAbsoluteDirectory:imagePath];
        NSString *imageFileName = [NSString stringWithFormat:@"%@.jpeg", self.currentGetVideoInfoID];
        NSString *imageFilePath = [imagePath stringByAppendingPathComponent:imageFileName];
        UIImage *thumbnail = [YDImageUtil scaleImage:responseObject maxSize:CGSizeMake(80,80)];
        NSData* imageData = UIImageJPEGRepresentation(thumbnail, 1.0);
        [imageData writeToFile:imageFilePath atomically:YES];
        NSManagedObjectContext *privateQueueContext = [NSManagedObjectContext MR_contextForCurrentThread];
        DownloadTask *downloadingTask = [DownloadTask findByDownloadID:self.currentGetVideoInfoID inContext:privateQueueContext];
        if (downloadingTask.video.isRemoved.integerValue)
        {
            self.currentGetVideoInfoID = nil;
            [self startGetVideoInfoTimer];
            return;
        }
        downloadingTask.videoImagePath = imageFilePath;
        Video *video = downloadingTask.video;
        video.videoImagePath = imageFilePath;
        [video updateWithContext:privateQueueContext completion:^(BOOL success, NSError *error) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [self getVideoFileSize];
            });
        }];

    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        self.currentGetVideoInfoID = nil;
        [self startGetVideoInfoTimer];
        return;
    }];
    
    [postOperation start];
}

- (void)getVideoFileSize
{
    NSManagedObjectContext *privateQueueContext = [NSManagedObjectContext MR_contextForCurrentThread];
    
    DownloadTask *downloadTask =  [DownloadTask findByDownloadID:self.currentGetVideoInfoID inContext:privateQueueContext];
    
    if (!downloadTask || downloadTask.video.isRemoved.integerValue)
    {
        self.currentGetVideoInfoID = nil;
        [self checkVideoInfoNotBeDownloaded:nil];
        return;
    }
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    NSLog(@"downloadUrl = %@",downloadTask.videoDownloadUrl);
    NSString *downloadFileUrl = downloadTask.videoDownloadUrl;
    [manager HEAD:downloadFileUrl parameters:nil success:^(AFHTTPRequestOperation *operation) {
        if ([operation.response respondsToSelector:@selector(expectedContentLength)])
        {
            long long contentLength = [operation.response expectedContentLength];
            NSManagedObjectContext *privateQueueContext = [NSManagedObjectContext MR_contextForCurrentThread];
            DownloadTask *downloadTask =  [DownloadTask findByDownloadID:self.currentGetVideoInfoID inContext:privateQueueContext];
            downloadTask.videoFileSize = @(contentLength);
            [downloadTask updateWithContext:privateQueueContext completion:^(BOOL success, NSError *error) {
                self.currentGetVideoInfoID = nil;
                [self checkVideoInfoNotBeDownloaded:nil];
            }];
        }
        else
        {
            NSLog(@"no content length found");
            self.currentGetVideoInfoID = nil;
            [self startGetVideoInfoTimer];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        self.currentGetVideoInfoID = nil;
        [self startGetVideoInfoTimer];
    }];
}

- (void)checkNewDownloadTask:(NSTimer*)timer
{
    if (self.isClearing)
    {
        return;
    }
    
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

- (void)createDownloadTaskWithDownloadPageUrl:(NSString*)downloadPageUrl youtubeVideoID:(NSString*)youtubeVideoID videoDuration:(NSNumber*)duration qualityType:(NSString*)qualityType videoDescription:(NSString*)videoDescription videoTitle:(NSString*)videoTitle videoDownloadUrl:(NSString*)videoDownloadUrl inContext:(NSManagedObjectContext *)context completion:(void(^)(BOOL success, NSNumber *downloadTaskID))completion
{
    
    DownloadTask *task = [DownloadTask createDownloadTaskInContext:context];
    if (!task)
    {
        if (completion)
            completion(NO,nil);
        return;
    }
    NSNumber *downloadTaskID = task.downloadID;
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
    video.duration = duration;
    
    task.video = video;
    video.downloadTask = task;
    
    [context MR_saveToPersistentStoreWithCompletion:^(BOOL success, NSError *error) {
        if (completion)
        {
            completion(YES,downloadTaskID);
        }
    }];
}

- (BOOL)createBackgroundTaskWithUrl:(NSString*)url
{
    if (![url hasPrefix:@"http"] && ![url hasPrefix:@"https"])
    {
        return NO;
    }
    
    if (!self.networkUtility)
        self.networkUtility = [[YDNetworkUtility alloc] init];
    __weak YDDownloadManager *weakSelf = self;
    [self.networkUtility downloadFileFromUrl:url toDestination:[self getCurrentDownloadFileDestPath:self.downloadTaskID] success:^{
        [weakSelf setDownloadTaskStatus:YES];
    } failure:^(NSError *error) {
        [weakSelf setDownloadTaskStatus:NO];
    } progress:^(int64_t totalBytesDownload, int64_t totalBytesExpectedDownload) {
        NSDate *currentTime = [NSDate date];
        if ([currentTime compare:[weakSelf.lastWriteProgressTime dateByAddingTimeInterval:1]] == NSOrderedAscending)
        {
            return;
        }
        float currentProgress = totalBytesExpectedDownload > 0 ? (float)totalBytesDownload / totalBytesExpectedDownload : 0.0;
        weakSelf.lastWriteProgressTime = currentTime;
        NSManagedObjectContext *privateQueueContext = [NSManagedObjectContext MR_contextForCurrentThread];
        DownloadTask *downloadingTask = [DownloadTask findByDownloadID:weakSelf.downloadTaskID inContext:privateQueueContext];
        if (downloadingTask) {
            downloadingTask.downloadProgress = @(currentProgress);
            downloadingTask.videoFileSize = @(totalBytesExpectedDownload);
            [downloadingTask updateWithContext:privateQueueContext completion:^(BOOL success, NSError *error) {
            }];
            [weakSelf sendDownloadStatusChangeNotificationWithVideoID:downloadingTask.video.videoID statusKey:@"downloadProgress" statusValue:@(currentProgress)];
        }
    }];
    
    return YES;
}


- (void)setDownloadTaskStatus:(BOOL)success
{
    NSManagedObjectContext *privateQueueContext = [NSManagedObjectContext MR_contextForCurrentThread];
    DownloadTask *downloadingTask = [DownloadTask findByDownloadID:self.downloadTaskID inContext:privateQueueContext];
    if (success) {
        downloadingTask.downloadProgress = @(1.0);
        downloadingTask.downloadTaskStatus = @(DownloadTaskFinished);
        downloadingTask.videoFilePath = [self getCurrentDownloadFileDestPath:self.downloadTaskID];
        Video *video = downloadingTask.video;
        video.videoFilePath = [self getCurrentDownloadFileDestPath:self.downloadTaskID];
    }
    else {
        downloadingTask.downloadTaskStatus = @(DownloadTaskFailed);
    }
    
    if (!success)
    {
        [downloadingTask updateWithContext:privateQueueContext completion:^(BOOL success, NSError *error) {
            [self sendDownloadStatusChangeNotificationWithVideoID:downloadingTask.video.videoID statusKey:@"downloadTaskStatus" statusValue:downloadingTask.downloadTaskStatus];
            self.downloadTaskID = nil;
        }];
        return;
    }
    [downloadingTask updateWithContext:privateQueueContext completion:^(BOOL success, NSError *error) {
        [self sendDownloadStatusChangeNotificationWithVideoID:downloadingTask.video.videoID statusKey:@"downloadTaskStatus" statusValue:downloadingTask.downloadTaskStatus];
        self.downloadTaskID = nil;
    }];
    
}

- (NSString*)getCurrentDownloadFileDestPath:(NSNumber*)downloadTaskID
{
    NSString *videoDirectory = [[YDFileUtil documentDirectoryPath] stringByAppendingPathComponent:@"videos"];
    [YDFileUtil createAbsoluteDirectory:videoDirectory];
    NSString *fileName = [NSString stringWithFormat:@"%@.mp4",downloadTaskID];
    return [videoDirectory stringByAppendingPathComponent:fileName];
}

- (void)sendDownloadStatusChangeNotificationWithVideoID:(NSNumber*)videoID statusKey:(NSString *)statusKeyName statusValue:(NSNumber *)statusKeyValue
{
    NSDictionary *userInfo = @{
                               @"videoID" : videoID,
                               statusKeyName : statusKeyValue
                               };
    [[NSNotificationCenter defaultCenter] postNotificationName: kDownloadTaskStatusChangeNotification object: nil userInfo:userInfo];
}


- (void)doClearTask:(NSTimer*)timer
{
    if( self.isClearing)
    {
        return;
    }

    dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        
        NSManagedObjectContext *privateQueueContext = [NSManagedObjectContext MR_contextForCurrentThread];
        NSArray *removedTasks = [DownloadTask getRemovedTasksWithContext:privateQueueContext];
        
        if ([removedTasks count] <= 0) {
            return;
        }
        
        self.isClearing = YES;

        while (self.currentGetVideoInfoID)
        {
            [NSThread sleepForTimeInterval:0.5];
        }
        
        NSNumber *downloadTaskID = self.downloadTaskID;
        if (downloadTaskID)
        {
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"downloadID = %@", downloadTaskID];
            if ([[removedTasks filteredArrayUsingPredicate:predicate] count] > 0)
            {
               [self.networkUtility cancelCurrentDownloadTask];
                while (self.downloadTaskID)
                {
                    [NSThread sleepForTimeInterval:0.5];
                }
            }
        }
        
        for (DownloadTask *downloadTask in removedTasks)
        {
            //remove image
            NSString *imagePath = downloadTask.videoImagePath;
            if (imagePath) {
                [YDFileUtil removeFileWithFilePath:imagePath];
            }
            
            //remove video file
            NSString *videoPath = downloadTask.videoFilePath;
            if (videoPath) {
                 [YDFileUtil removeFileWithFilePath:videoPath];
            }
            
            Video *video = downloadTask.video;
            [privateQueueContext deleteObject:video];
            [privateQueueContext deleteObject:downloadTask];
        }
        
        [privateQueueContext MR_saveToPersistentStoreWithCompletion:^(BOOL success, NSError *error) {
            self.isClearing = NO;
        }];

    });
}



@end
