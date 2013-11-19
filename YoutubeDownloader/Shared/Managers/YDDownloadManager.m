//
//  YDDownloadManager.m
//  YoutubeDownloader
//
//  Created by Hao Wang  on 13-11-17.
//  Copyright (c) 2013年 HAO WANG. All rights reserved.
//

#import "YDDownloadManager.h"
@interface YDDownloadManager ()
{
    NSTimer *_refreshPlayStatusTimer;
}

@end

@implementation YDDownloadManager

+ (YDDownloadManager *)sharedInstance
{
    static YDDownloadManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[YDDownloadManager alloc] init];
    });
    return instance;
}

-(NSURLSession *)backgroundSession
{
    static NSURLSession *backgroundSession = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration backgroundSessionConfiguration:@"com.shinobicontrols.BackgroundDownload.BackgroundSession"];
        backgroundSession = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:nil];
    });
    return backgroundSession;
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
    _refreshPlayStatusTimer = [NSTimer timerWithTimeInterval:2 target:self selector:@selector(checkNewDownloadTask:) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:_refreshPlayStatusTimer forMode:NSRunLoopCommonModes];
    
}

- (void)checkNewDownloadTask:(NSTimer*)timer
{
    if (self.backgroundTask)
    {
        return;
    }
    
    
}

- (void)createDownloadTaskWithDownloadPageUrl:(NSString*)downloadPageUrl qualityType:(NSString*)qualityType videoDescription:(NSString*)videoDescription videoDownloadUrl:(NSString*)videoDownloadUrl inContext:(NSManagedObjectContext *)context completion:(void(^)(BOOL success))completion
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
	task.videoDescription = videoDescription;
	task.videoImagePath = nil;
	task.videoDownloadUrl = videoDownloadUrl;
    [context MR_saveToPersistentStoreWithCompletion:^(BOOL success, NSError *error) {
        if (completion)
        {
            completion(YES);
        }
    }];
}

- (void)createBackgroundTaskWithUrl:(NSString*)url
{
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    self.backgroundTask = [self.backgroundSession downloadTaskWithRequest:request];
    [self.backgroundTask resume];
}


-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location
{
    // We've successfully finished the download. Let's save the file
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *URLs = [fileManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask];
    NSURL *documentsDirectory = URLs[0];
    NSURL *destinationPath = [documentsDirectory URLByAppendingPathComponent:[location lastPathComponent]];
    
    NSError *error;
    // Make sure we overwrite anything that's already there
    [fileManager removeItemAtURL:destinationPath error:NULL];
    BOOL success = [fileManager copyItemAtURL:location toURL:destinationPath error:&error];
    if (success)
    {
    }
    else
    {
        NSLog(@"Couldn't copy the downloaded file");
    }
    
    if(downloadTask == self.backgroundTask)
    {
        self.backgroundTask = nil;
    }
}

-(void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
    if (error)
    {
         self.backgroundTask = nil;
    }
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten BytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
{
    double currentProgress = totalBytesWritten / (double)totalBytesExpectedToWrite;
    dispatch_async(dispatch_get_main_queue(), ^{
        //self.progressIndicator.progress = currentProgress;
    });
}

-(IBAction)cancelCancellable:(id)sender
{
    if (self.backgroundTask)
    {
        [self.backgroundTask cancel];
        self.backgroundTask = nil;
    }
}

@end
