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

@property (atomic, strong)      NSNumber *currentGetVideoInfoID;

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

- (void)startGetVideoInfoTimer
{
    [self  stopGetVideoInfoTimer];
    _getVideoInfoTimer = [NSTimer timerWithTimeInterval:10 target:self selector:@selector(checkVideoInfoNotBeDownloaded:) userInfo:nil repeats:YES];
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
    [self stopGetVideoInfoTimer];
    NSManagedObjectContext *privateQueueContext = [NSManagedObjectContext MR_contextForCurrentThread];
    DownloadTask *downloadTask = [DownloadTask getWaitingDownloadTaskInContext:privateQueueContext];
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
    if (self.currentGetVideoInfoID)
    {
        return;
    }
    
    self.currentGetVideoInfoID = downloadTaskID;
    NSManagedObjectContext *privateQueueContext = [NSManagedObjectContext MR_contextForCurrentThread];
    
    DownloadTask *downloadTask =  [DownloadTask findByDownloadID:downloadTaskID inContext:privateQueueContext];
    
    if (!downloadTask || downloadTask.downloadTaskStatusValue == DownloadTaskDeleting)
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
    NSString *imageUrlString = [NSString stringWithFormat:@"http://img.youtube.com/vi/%@/sddefault.jpg",youtubeVideoID];
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
        downloadingTask.videoImagePath = imageFilePath;
        Video *video = downloadingTask.video;
        video.videoImagePath = imageFilePath;
        [video updateWithContext:privateQueueContext completion:^(BOOL success, NSError *error) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [self getVideoFileSize];
            });
        }];

    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self startGetVideoInfoTimer];
        return;
    }];
    
    [postOperation start];
}

- (void)getVideoFileSize
{
    NSManagedObjectContext *privateQueueContext = [NSManagedObjectContext MR_contextForCurrentThread];
    
    DownloadTask *downloadTask =  [DownloadTask findByDownloadID:self.currentGetVideoInfoID inContext:privateQueueContext];
    
    if (!downloadTask)
    {
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
                [self checkVideoInfoNotBeDownloaded:nil];
            }];
        }
        else
        {
            NSLog(@"no content length found");
            [self startGetVideoInfoTimer];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self startGetVideoInfoTimer];
    }];
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

- (void)createDownloadTaskWithDownloadPageUrl:(NSString*)downloadPageUrl youtubeVideoID:(NSString*)youtubeVideoID qualityType:(NSString*)qualityType videoDescription:(NSString*)videoDescription videoTitle:(NSString*)videoTitle videoDownloadUrl:(NSString*)videoDownloadUrl inContext:(NSManagedObjectContext *)context completion:(void(^)(BOOL success, NSNumber *downloadTaskID))completion
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
