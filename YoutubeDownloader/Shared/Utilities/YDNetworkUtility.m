//
//  YDNetworkUtility.m
//  YoutubeDownloader
//
//  Created by Hao Wang  on 13-12-4.
//  Copyright (c) 2013年 HAO WANG. All rights reserved.
//

#import "YDNetworkUtility.h"
#import "YDDeviceUtility.h"
#import "YDFileUtil.h"
#import "DownloadTask.h"

@interface YDNetworkUtility()

@property (nonatomic, strong) NSURLSession *session;
@property (nonatomic, strong) id<YDNetworkUtilityDelegate> delegate;
@property (nonatomic, strong) NSMutableDictionary *downloadTasksMap;
@property (nonatomic, strong) NSMutableDictionary *downloadTasksProgressMap;


@end

@implementation YDNetworkUtility

- (id)initWithConfigureName:(NSString*)configureName delegate:(id<YDNetworkUtilityDelegate>)delegate completion:(void(^)())completion

{
    self = [super init];
    if (self) {
        self.downloadTasksMap = [NSMutableDictionary dictionary];
        self.downloadTasksProgressMap = [NSMutableDictionary dictionary];
        
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration backgroundSessionConfiguration:configureName];
        self.session =  [NSURLSession sessionWithConfiguration:configuration
                                      delegate:self
                                 delegateQueue:nil];
        self.delegate = delegate;
        
        [self.session getTasksWithCompletionHandler:^(NSArray *dataTasks, NSArray *uploadTasks, NSArray *downloadTasks) {
            
            if (!downloadTasks || [downloadTasks count] <= 0) {
                if (completion){
                    completion();
                }
                return;
            }
            
            for (NSURLSessionDownloadTask *downloadTask in downloadTasks) {
                NSString *urlString = [downloadTask.originalRequest.URL absoluteString];
                self.downloadTasksMap[urlString] = downloadTask;
            }
            
            if (completion){
                completion();
            }
        }];
    }
    return self;
}

- (void)downloadFileFromUrl:(NSString*)downloadUrlString resumeDataPath:(NSString*)resumeDataPath
{
    
    NSURL *downloadUrl = [NSURL URLWithString:downloadUrlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:downloadUrl];
    if (!downloadUrl || !request) {
        if (self.delegate) {
            [self.delegate downloadFailureWithUrl:downloadUrlString error:[NSError errorWithDomain:@"kYoutubeDownloadErrorDomain" code:kYDErrorInvalidUrl userInfo:nil]];
        }
        return;
    }
    
    @synchronized(self)
    {
        NSURLSessionDownloadTask  *downloadTask = self.downloadTasksMap[downloadUrlString];
        if (downloadTask) {
            if (downloadTask.state == NSURLSessionTaskStateSuspended) {
                [downloadTask resume];
            }
            return;
        }
        
        NSData *resumeData = [YDFileUtil getDataFromFilePath:resumeDataPath];
        if (resumeData && [resumeData length] > 0)
        {
            //delete resume data
            [YDFileUtil removeFile:resumeDataPath];
            downloadTask = [self.session downloadTaskWithResumeData:resumeData];
        }
        else
        {
            downloadTask = [self.session downloadTaskWithRequest:request];
        }
        
        [downloadTask resume];
        self.downloadTasksMap[downloadUrlString] = downloadTask;
    }
    
    return;
}

#pragma mark - URLSession delegate
-(void)URLSession:(NSURLSession *)session
     downloadTask:(NSURLSessionDownloadTask *)downloadTask
didFinishDownloadingToURL:(NSURL *)location
{
    NSString *downloadUrl = [downloadTask.originalRequest.URL absoluteString];
    @synchronized(self)
    {
        [self.downloadTasksMap removeObjectForKey:downloadUrl];
        [self.downloadTasksProgressMap removeObjectForKey:downloadUrl];
    }
    
    if (self.delegate) {
        [self.delegate downloadSuccessWithUrl:downloadUrl downloadToUrl:location];
    }
    return;
}

- (void) URLSession:(NSURLSession *)session
               task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
    if ([error.domain isEqualToString:NSURLErrorDomain] && error.code == NSURLErrorCancelled) {
        // !!Note:-cancel method resumeData is empty!
        if (error.userInfo && [error.userInfo objectForKey:NSURLSessionDownloadTaskResumeData]) {
            NSData *resumeData = [error.userInfo objectForKey:NSURLSessionDownloadTaskResumeData];
            NSString *downloadUrl = [task.originalRequest.URL absoluteString];
             NSManagedObjectContext *privateQueueContext = [NSManagedObjectContext MR_contextForCurrentThread];
            DownloadTask *downloadTask = [DownloadTask getDownloadingTaskWithDownloadUrl:downloadUrl inContext:privateQueueContext];
            if (downloadTask.downloadTaskStatusValue != DownloadTaskFinished) {
                [YDFileUtil writeData:resumeData intoFileWithFilePath:downloadTask.videoFilePath];
            }
        }
        return;
    }
    
    if (error == nil)
    {
        return;
    }
    
    NSString *downloadUrlString = [task.originalRequest.URL absoluteString];
    @synchronized(self)
    {
            [self.downloadTasksMap removeObjectForKey:downloadUrlString];
            [self.downloadTasksProgressMap removeObjectForKey:downloadUrlString];
    }
        
    if (self.delegate) {
            [self.delegate downloadFailureWithUrl:downloadUrlString error:error];
    }
    
}

-(void)URLSession:(NSURLSession *)session
     downloadTask:(NSURLSessionDownloadTask *)downloadTask
     didWriteData:(int64_t)bytesWritten
totalBytesWritten:(int64_t)totalBytesWritten
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
{
    NSString *downloadUrl = [downloadTask.originalRequest.URL absoluteString];
    @synchronized(self)
    {
        NSDate *lastReportProgressTime = self.downloadTasksProgressMap[downloadUrl];
    
        NSDate *currentTime = [NSDate date];
        if (lastReportProgressTime && [currentTime compare:[lastReportProgressTime dateByAddingTimeInterval:1]] == NSOrderedAscending)
        {
            return;
        }
        self.downloadTasksProgressMap[downloadUrl] = currentTime;
    }
    
    if (self.delegate) {
        [self.delegate downloadProgressWithUrl:downloadUrl totalBytesDownload:totalBytesWritten totalBytesExpectedDownload:totalBytesExpectedToWrite];
    }
    return;
}

- (void)URLSessionDidFinishEventsForBackgroundURLSession:(NSURLSession *)session

{
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if (appDelegate.backgroundURLSessionCompletionHandler) {
        
        void (^completionHandler)() = appDelegate.backgroundURLSessionCompletionHandler;
        
        appDelegate.backgroundURLSessionCompletionHandler = nil;
        
        completionHandler();
        
    }
    
    NSLog(@"All tasks are finished");
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didResumeAtOffset:(int64_t)fileOffset expectedTotalBytes:(int64_t)expectedTotalBytes
{
    
}

- (void)cancelDownloadTaskDownloadUrl:(NSString*)downloadUrlString
{
    NSURLSessionDownloadTask *downloadTask = self.downloadTasksMap[downloadUrlString];
    if (!downloadTask) {
            return;
    }
    [downloadTask cancelByProducingResumeData:^(NSData *resumeData) {
        @synchronized(self)
        {
            [self.downloadTasksMap removeObjectForKey:downloadUrlString];
            [self.downloadTasksProgressMap removeObjectForKey:downloadUrlString];
        }
    }];
    return;
}

- (void)pauseDownloadTaskWithDownloadUrl:(NSString*)downloadUrlString saveResumeDataPath:(NSString*)saveResumeDataPath

{
    NSURLSessionDownloadTask *downloadTask = self.downloadTasksMap[downloadUrlString];
    if (!downloadTask) {
        return;
    }
    
    [downloadTask cancelByProducingResumeData:^(NSData *resumeData) {
        [YDFileUtil writeData:resumeData intoFileWithFilePath:saveResumeDataPath];
        @synchronized(self)
        {
            [self.downloadTasksMap removeObjectForKey:downloadUrlString];
            [self.downloadTasksProgressMap removeObjectForKey:downloadUrlString];
        }
    }];
    return;
}

@end
