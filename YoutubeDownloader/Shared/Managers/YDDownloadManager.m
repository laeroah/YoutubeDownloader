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
#import "YDVideoLinksExtractorManager.h"

@interface YDDownloadManager ()
{
    NSTimer *_getVideoInfoTimer;
    NSTimer *_clearTimer;
    YDVideoLinksExtractorManager *_urlExtractor;
}

@property (atomic, strong)      NSDate *lastWriteProgressTime;
@property (atomic, strong)      NSNumber *currentGetVideoInfoID;
@property (atomic, assign)      BOOL isClearing;
@property (nonatomic, strong)   YDNetworkUtility *networkUtility;

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
        [self processForWaitingDownloadTasks];//may be some task will be skipped for some issue then force to download it
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
    NSString *imagePath = [[YDFileUtil documentDirectoryPath] stringByAppendingPathComponent:@"images"];
    [YDFileUtil createAbsoluteDirectory:imagePath];
    NSString *imageFileName = [NSString stringWithFormat:@"%@.jpeg", self.currentGetVideoInfoID];
    NSString *imageFilePath = [imagePath stringByAppendingPathComponent:imageFileName];
    [YDFileUtil removeFile:imageFilePath];
    NSString *imageUrlString = [NSString stringWithFormat:@"http://img.youtube.com/vi/%@/default.jpg",youtubeVideoID];
    NSURL *imageUrl = [NSURL URLWithString:imageUrlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:imageUrl];
    AFHTTPRequestOperation *postOperation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    postOperation.responseSerializer = [AFImageResponseSerializer serializer];
    [postOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
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
    NSString *downloadPageUrl = downloadTask.downloadPageUrl;
    NSString *qualityType = downloadTask.qualityType;
    [manager HEAD:downloadFileUrl parameters:nil success:^(AFHTTPRequestOperation *operation) {
        if ([operation.response respondsToSelector:@selector(expectedContentLength)])
        {
            long long contentLength = [operation.response expectedContentLength];
            NSManagedObjectContext *privateQueueContext = [NSManagedObjectContext MR_contextForCurrentThread];
            DownloadTask *downloadTask =  [DownloadTask findByDownloadID:self.currentGetVideoInfoID inContext:privateQueueContext];
            downloadTask.videoFileSize = @(contentLength);
            NSNumber *downloadTaskID = downloadTask.downloadID;
            [downloadTask updateWithContext:privateQueueContext completion:^(BOOL success, NSError *error) {
                if (success)
                {
                    [self sendTotalVideoSizeChangeNotification];
                    [self checkNewDownloadTaskWithDownloadTaskID:downloadTaskID];
                    self.currentGetVideoInfoID = nil;
                    [self checkVideoInfoNotBeDownloaded:nil];
                }
            }];
        }
        else
        {
            NSLog(@"no content length found");
            self.currentGetVideoInfoID = nil;
            [self startGetVideoInfoTimer];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        _urlExtractor = [[YDVideoLinksExtractorManager alloc] initWithURL:[NSURL URLWithString:downloadPageUrl] quality:YDYouTubeVideoQualityMedium];
        [_urlExtractor extractVideoURLWithCompletionBlock:^(NSURL *videoUrl, NSString *youtubeVideoID, NSNumber *duration, NSDictionary *dictionary, NSError *error) {
             NSManagedObjectContext *privateQueueContext = [NSManagedObjectContext MR_contextForCurrentThread];
             DownloadTask *downloadTask =  [DownloadTask findByDownloadID:self.currentGetVideoInfoID inContext:privateQueueContext];
            if (dictionary[qualityType]) {
                downloadTask.videoDownloadUrl = dictionary[qualityType];
            }
            else
            {
                 downloadTask.downloadTaskStatus = @(DownloadTaskFailed);
            }
            [downloadTask updateWithContext:privateQueueContext completion:^(BOOL success, NSError *error) {
                self.currentGetVideoInfoID = nil;
                [self startGetVideoInfoTimer];
            }];

    }];
       
           }];
}

- (void)checkNewDownloadTaskWithDownloadTaskID:(NSNumber*)downloadTaskID
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSManagedObjectContext *privateQueueContext = [NSManagedObjectContext MR_contextForCurrentThread];
        DownloadTask   *downloadingTask = [DownloadTask findByDownloadID:downloadTaskID inContext:privateQueueContext];
        if (!downloadingTask || (downloadingTask.downloadTaskStatusValue != DownloadTaskDownloading && downloadingTask.downloadTaskStatusValue != DownloadTaskWaiting))
        {
            return;
        }
        
        if (downloadingTask.downloadTaskStatusValue == DownloadTaskDownloading)
        {
            if (downloadingTask.videoFileSizeValue > 0 && [YDFileUtil getFileSizeWithPath:downloadingTask.videoFilePath] >= downloadingTask.videoFileSizeValue) {
                [self setDownloadTaskStatus:YES downloadUrl:downloadingTask.videoDownloadUrl];
                return;
            }
        }
        
        downloadingTask.downloadTaskStatus = @(DownloadTaskDownloading);
        NSString *downloadUrl = downloadingTask.videoDownloadUrl;
        NSNumber *videoID = downloadingTask.video.videoID;
        [downloadingTask updateWithContext:privateQueueContext completion:^(BOOL success, NSError *error) {
                
                [self sendDownloadStatusChangeNotificationWithVideoID:videoID statusKey:@"downloadTaskStatus" statusValue:@(DownloadTaskDownloading)];
                
                if (![self createBackgroundTaskWithUrl:downloadUrl resumeDataPath:downloadingTask.resumeDataPath])
                {
                    [self setDownloadTaskStatus:NO downloadUrl:downloadUrl];
                }
                
        }];
        
    
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
    task.videoFilePath = [self getDownloadFileDestPathWithDownloadTaskID:downloadTaskID];
    task.resumeDataPath = [self getDownloadResumeDataPathWithDownloadTaskID:downloadTaskID];
    
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

- (void)updateDownloadTask:(DownloadTask*)task downloadPageUrl:(NSString*)downloadPageUrl youtubeVideoID:(NSString*)youtubeVideoID videoDuration:(NSNumber*)duration qualityType:(NSString*)qualityType videoDescription:(NSString*)videoDescription videoTitle:(NSString*)videoTitle videoDownloadUrl:(NSString*)videoDownloadUrl inContext:(NSManagedObjectContext *)context completion:(void(^)(BOOL success, NSNumber *downloadTaskID))completion
{
    
    task.downloadPageUrl = downloadPageUrl;
	task.downloadPriority = DOWNLOAD_TASK_DEFAULT_PRIORITY;
	task.downloadTaskStatus = @(DownloadTaskWaiting);
	task.qualityType = qualityType;
    task.videoTitle = videoTitle;
	task.videoDescription = videoDescription;
	task.videoImagePath = nil;
	task.videoDownloadUrl = videoDownloadUrl;
    task.youtubeVideoID = youtubeVideoID;
    
    Video *video = task.video;
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
            completion(YES,task.downloadID);
        }
    }];
}

- (BOOL)createBackgroundTaskWithUrl:(NSString*)url resumeDataPath:(NSString*)resumeDataPath
{
    if (![url hasPrefix:@"http"] && ![url hasPrefix:@"https"])
    {
        return NO;
    }
    [self.networkUtility  downloadFileFromUrl:url resumeDataPath:resumeDataPath];
    return YES;
}


- (void)setDownloadTaskStatus:(BOOL)success downloadUrl:(NSString*)downloadUrl
{
    
    NSManagedObjectContext *privateQueueContext = [NSManagedObjectContext MR_contextForCurrentThread];
    DownloadTask *downloadingTask = [DownloadTask getDownloadingTaskWithDownloadUrl:downloadUrl inContext:privateQueueContext];
    if (success) {
        downloadingTask.downloadProgress = @(1.0);
        downloadingTask.downloadTaskStatus = @(DownloadTaskFinished);
        Video *video = downloadingTask.video;
        video.videoFilePath = downloadingTask.videoFilePath;
        video.isNew = @(YES);
        video.createDate = [NSDate date];
    }
    
    if (!success)
    {
//        [downloadingTask updateWithContext:privateQueueContext completion:^(BOOL success, NSError *error) {
//            [self sendDownloadStatusChangeNotificationWithVideoID:downloadingTask.video.videoID statusKey:@"downloadTaskStatus" statusValue:downloadingTask.downloadTaskStatus];
//        }];
        
      
        [self retryToDownloadWithTaskID:downloadingTask.downloadID];
        return;
    }
    
    [downloadingTask updateWithContext:privateQueueContext completion:^(BOOL success, NSError *error) {
        [self sendDownloadStatusChangeNotificationWithVideoID:downloadingTask.video.videoID statusKey:@"downloadTaskStatus" statusValue:downloadingTask.downloadTaskStatus];
    }];
    
}

- (NSString*)getDownloadFileDestPathWithDownloadTaskID:(NSNumber*)downloadTaskID
{
    NSString *videoDirectory = [[YDFileUtil documentDirectoryPath] stringByAppendingPathComponent:@"videos"];
    [YDFileUtil createAbsoluteDirectory:videoDirectory];
    NSString *fileName = [NSString stringWithFormat:@"%@.mp4",downloadTaskID];
    return [videoDirectory stringByAppendingPathComponent:fileName];
}

- (NSString*)getDownloadResumeDataPathWithDownloadTaskID:(NSNumber*)downloadTaskID
{
    NSString *videoDirectory = [[YDFileUtil documentDirectoryPath] stringByAppendingPathComponent:@"videos"];
    [YDFileUtil createAbsoluteDirectory:videoDirectory];
    NSString *fileName = [NSString stringWithFormat:@"%@.data",downloadTaskID];
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
        
        for (DownloadTask *downloadTask in removedTasks)
        {
            [self.networkUtility cancelDownloadTaskDownloadUrl:downloadTask.videoDownloadUrl];
        }
        
        for (DownloadTask *downloadTask in removedTasks)
        {
            //remove image
            NSString *imagePath = downloadTask.videoImagePath;
            if (imagePath) {
                [YDFileUtil removeFileWithFilePath:imagePath];
            }
            
            //remove video file
            [YDFileUtil removeFileWithFilePath:downloadTask.videoFilePath];
            [YDFileUtil removeFileWithFilePath:downloadTask.resumeDataPath];
            Video *video = downloadTask.video;
            [privateQueueContext deleteObject:video];
            [privateQueueContext deleteObject:downloadTask];
        }
        
        [privateQueueContext MR_saveToPersistentStoreWithCompletion:^(BOOL success, NSError *error) {
            [self sendTotalVideoSizeChangeNotification];
            self.isClearing = NO;
        }];

    });
}

- (void)retryToDownloadWithTaskID:(NSNumber*)downloadTaskID
{
    NSManagedObjectContext *privateQueueContext = [NSManagedObjectContext MR_contextForCurrentThread];
    DownloadTask   *downloadingTask = [DownloadTask findByDownloadID:downloadTaskID inContext:privateQueueContext];
    if (!downloadingTask) {
        return;
    }
    [YDFileUtil removeFile:downloadingTask.videoFilePath];
    [YDFileUtil removeFile:downloadingTask.resumeDataPath];
    downloadingTask.videoFileSize = 0;
    downloadingTask.downloadProgress = @(0);
    if (downloadingTask.downloadTaskStatusValue != DownloadTaskPaused)
        downloadingTask.downloadTaskStatus = @(DownloadTaskWaiting);
    [downloadingTask updateWithContext:privateQueueContext completion:^(BOOL success, NSError *error) {
        [self sendDownloadStatusChangeNotificationWithVideoID:downloadingTask.video.videoID statusKey:@"downloadTaskStatus" statusValue:@(DownloadTaskWaiting)];
    }];
}

- (void)sendTotalVideoSizeChangeNotification
{
    NSManagedObjectContext *privateQueueContext = [NSManagedObjectContext MR_contextForCurrentThread];
    NSNumber *totalVideoSize = [DownloadTask getTotalVideoSizeWithContext:privateQueueContext];
    if (!totalVideoSize) {
        return;
    }
    
    NSDictionary *userInfo = @{
                               @"videoSize" : [totalVideoSize copy],
                               };
    [[NSNotificationCenter defaultCenter] postNotificationName: kTotalVideoSizeChangeNotification object: nil userInfo:userInfo];
    
}

- (void)pauseDownloadTaskWithDownloadTaskID:(NSNumber *)downloadTaskID completion:(void(^)())completion
{
    NSManagedObjectContext *privateQueueContext = [NSManagedObjectContext MR_contextForCurrentThread];
    DownloadTask *downloadTask  = [DownloadTask findByDownloadID:downloadTaskID inContext:privateQueueContext];
    if (!downloadTask || downloadTask.downloadTaskStatusValue != DownloadTaskDownloading) {
        return;
    }
    
    [self.networkUtility pauseDownloadTaskWithDownloadUrl:downloadTask.videoDownloadUrl saveResumeDataPath:downloadTask.resumeDataPath];
    
    downloadTask.downloadTaskStatus = @(DownloadTaskPaused);
    
    if (!completion) {
        [downloadTask updateWithContext:privateQueueContext];
        return;
    }
    
    [downloadTask updateWithContext:privateQueueContext completion:^(BOOL success, NSError *error) {
        if (completion) {
            completion();
        }
    }];
}

- (void)resumeDownloadTaskWithDownloadTaskID:(NSNumber *)downloadTaskID completion:(void(^)())completion
{
    NSManagedObjectContext *privateQueueContext = [NSManagedObjectContext MR_contextForCurrentThread];
    DownloadTask *downloadTask  = [DownloadTask findByDownloadID:downloadTaskID inContext:privateQueueContext];
    if (!downloadTask || downloadTask.downloadTaskStatusValue != DownloadTaskPaused) {
        return;
    }
    
    downloadTask.downloadTaskStatus = @(DownloadTaskDownloading);
    NSString *downloadUrl = downloadTask.videoDownloadUrl;
    NSNumber *videoID = downloadTask.video.videoID;
    
    if (!completion) {
        [downloadTask updateWithContext:privateQueueContext];
        if (![self createBackgroundTaskWithUrl:downloadUrl resumeDataPath:downloadTask.resumeDataPath])
        {
            [self setDownloadTaskStatus:NO downloadUrl:downloadUrl];
        }
        else
        {
            [self sendDownloadStatusChangeNotificationWithVideoID:videoID statusKey:@"downloadTaskStatus" statusValue:@(DownloadTaskDownloading)];
        }
        return;
    }
    [downloadTask updateWithContext:privateQueueContext completion:^(BOOL success, NSError *error) {
        if (![self createBackgroundTaskWithUrl:downloadUrl resumeDataPath:downloadTask.resumeDataPath])
        {
            [self setDownloadTaskStatus:NO downloadUrl:downloadUrl];
        }
        else
        {
            [self sendDownloadStatusChangeNotificationWithVideoID:videoID statusKey:@"downloadTaskStatus" statusValue:@(DownloadTaskDownloading)];
        }
        
        if (completion) {
            completion();
        }
    }];
}


- (void)processForWaitingDownloadTasks
{
    NSManagedObjectContext *privateQueueContext = [NSManagedObjectContext MR_contextForCurrentThread];
    NSArray *downloadTasks = [DownloadTask getAllWaitingTasksInContext:privateQueueContext];
    for (DownloadTask *downloadTask in downloadTasks)
    {
        [self checkNewDownloadTaskWithDownloadTaskID:downloadTask.downloadID];
    }
}


- (void)processForPendingDownloadTasks
{
    NSManagedObjectContext *privateQueueContext = [NSManagedObjectContext MR_contextForCurrentThread];
    NSArray *downloadTasks = [DownloadTask getAllWaitingOrDownloadingTasksInContext:privateQueueContext];
    for (DownloadTask *downloadTask in downloadTasks)
    {
        [self checkNewDownloadTaskWithDownloadTaskID:downloadTask.downloadID];
    }
}

- (void)initializeProcess
{
    self.networkUtility = [[YDNetworkUtility alloc] initWithConfigureName:kVideoDownloadConfigureName delegate:self completion:^{
        [self processForPendingDownloadTasks];
        [self startGetVideoInfoTimer];
        [self startClearTimer];
    }];
    
    return;
}

- (void)downloadSuccessWithUrl:(NSString*)url downloadToUrl:(NSURL*)toLocation
{
    NSManagedObjectContext *privateQueueContext = [NSManagedObjectContext MR_contextForCurrentThread];
    DownloadTask *task = [DownloadTask getDownloadingTaskWithDownloadUrl:url inContext:privateQueueContext];
    NSURL *toURL = [NSURL fileURLWithPath:task.videoFilePath];
    [YDFileUtil moveFileFrom:toLocation to:toURL error:nil];
    [self setDownloadTaskStatus:YES downloadUrl:url];
}

- (void)downloadFailureWithUrl:(NSString*)url error:(NSError*)error
{
    [self setDownloadTaskStatus:NO downloadUrl:url];
}

- (void)downloadProgressWithUrl:(NSString*)url totalBytesDownload:(int64_t)totalBytesDownload totalBytesExpectedDownload:(int64_t)totalBytesExpectedDownload
{
    NSManagedObjectContext *privateQueueContext = [NSManagedObjectContext MR_contextForCurrentThread];
    DownloadTask *downloadingTask = [DownloadTask getDownloadingTaskWithDownloadUrl:url  inContext:privateQueueContext];
    float currentProgress = (float)totalBytesDownload /totalBytesExpectedDownload;
    if (downloadingTask) {
        downloadingTask.downloadProgress = @(currentProgress);
        downloadingTask.videoFileSize = @(totalBytesExpectedDownload);
        [downloadingTask updateWithContext:privateQueueContext completion:^(BOOL success, NSError *error) {
        }];
        [self sendDownloadStatusChangeNotificationWithVideoID:downloadingTask.video.videoID statusKey:@"downloadProgress" statusValue:@(currentProgress)];
    }

}


@end
