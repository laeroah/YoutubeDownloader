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

@interface YDNetworkUtility()

@property (nonatomic, strong) NSMutableDictionary *sessionManagerDict;
@property (nonatomic, strong) NSMutableDictionary *downloadTasksMap;
@property (nonatomic, strong) NSMutableDictionary *downloadTasksProgressMap;

@end

@implementation YDNetworkUtility

+ (YDNetworkUtility *)sharedInstance
{
    static YDNetworkUtility *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[YDNetworkUtility alloc] init];
    });
    return instance;
}

- (id)init
{
    self = [super init];
    if (self) {
        self.sessionManagerDict = [NSMutableDictionary dictionary];
        self.downloadTasksMap = [NSMutableDictionary dictionary];
        self.downloadTasksProgressMap = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)initializeForConfigureName:(NSString*)configureName
{
    AFURLSessionManager *sessionManager = self.sessionManagerDict[configureName];
    
    if  (sessionManager)
    {
        return;
    }
    
    //for one configure name there should be only on session manager
     NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration backgroundSessionConfiguration:configureName];
    
    sessionManager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    
    self.downloadTasksMap[configureName] = [NSMutableDictionary dictionary];
    self.downloadTasksProgressMap[configureName] = [NSMutableDictionary dictionary];
    
    [sessionManager setDidFinishEventsForBackgroundURLSessionBlock:^(NSURLSession *session) {
        
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        if (appDelegate.backgroundURLSessionCompletionHandler) {
            void (^completionHandler)() = appDelegate.backgroundURLSessionCompletionHandler;
            appDelegate.backgroundURLSessionCompletionHandler = nil;
            completionHandler();
        }
    }];
    self.sessionManagerDict[configureName] = sessionManager;
}

- (void)downloadFileFromUrl:(NSString*)downloadUrlString toDestination:(NSString*)destinationPath configureName:(NSString*)configureName
                    success:(YDDownloadSuccess)success failure:(YDDownloadFailuer)failure progress:(YDDownloadProgress)progress
{
    
    NSURL *downloadUrl = [NSURL URLWithString:downloadUrlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:downloadUrl];
    if (!downloadUrl || !request) {
        if (failure) {
            failure([NSError errorWithDomain:@"kYoutubeDownloadErrorDomain" code:kYDErrorInvalidUrl userInfo:nil]);
        }
        return;
    }
    
    if (!configureName) {
        if (failure) {
                failure([NSError errorWithDomain:@"kYoutubeDownloadErrorDomain" code:kYDErrorConfigureNameMustProvide userInfo:nil]);
        }
        return;
    }
    
    AFURLSessionManager *sessionManager = nil;
    @synchronized(self)
    {
        sessionManager = self.sessionManagerDict[configureName];
        if  (!sessionManager)
        {
            [self initializeForConfigureName:configureName];
        }
    }
        
    NSMutableDictionary *urlTaskMap = self.downloadTasksMap[configureName];
    if (urlTaskMap[downloadUrlString]) {
        return;
    }
        
    __weak YDNetworkUtility *weakSelf = self;
    NSURLSessionDownloadTask  *downloadTask;
    
    NSData *resumeData = [YDFileUtil getDataFromFilePath:destinationPath];
    if (resumeData && [resumeData length] > 0) {
        [YDFileUtil removeFile:destinationPath];
        [sessionManager downloadTaskWithResumeData:resumeData progress:nil destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
            return [NSURL fileURLWithPath:destinationPath];
        }
        completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
            if (error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (failure) {
                        failure(error);
                    }
                    @synchronized(self)
                    {
                        [weakSelf.downloadTasksMap[configureName] removeObjectForKey:downloadUrlString];
                    }
                });
                return;
            }
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (success) {
                        success();
                    }
                    @synchronized(self)
                    {
                        [weakSelf.downloadTasksMap[configureName] removeObjectForKey:downloadUrlString];
                    }
                });
            });
            return;
        }];
    }
    else
    {
        downloadTask = [sessionManager downloadTaskWithRequest:request progress:nil
            destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
                return [NSURL fileURLWithPath:destinationPath];
            } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
                if (error) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if (failure) {
                                failure(error);
                            }
                        @synchronized(self)
                        {
                            [weakSelf.downloadTasksMap[configureName] removeObjectForKey:downloadUrlString];
                        }
                    });
                    return;
                }
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (success) {
                            success();
                        }
                        @synchronized(self)
                        {
                            [weakSelf.downloadTasksMap[configureName] removeObjectForKey:downloadUrlString];
                        }
                    });
                });
                return;
            }];
    }
    
    [sessionManager setDownloadTaskDidWriteDataBlock:^(NSURLSession *session, NSURLSessionDownloadTask *downloadTask, int64_t bytesWritten, int64_t totalBytesWritten, int64_t totalBytesExpectedToWrite) {
            if (progress) {
                @synchronized(self)
                {
                    NSString *downloadUrl = [downloadTask.originalRequest.URL absoluteString];
                    NSDate *lastReportProgressTime = self.downloadTasksProgressMap[configureName][downloadUrl];
                
                    NSDate *currentTime = [NSDate date];
                    if (lastReportProgressTime && [currentTime compare:[lastReportProgressTime dateByAddingTimeInterval:1]] == NSOrderedAscending)
                    {
                        return;
                    }
                    weakSelf.downloadTasksProgressMap[configureName][downloadUrl] = currentTime;
                }
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    progress(totalBytesWritten, totalBytesExpectedToWrite);
                });
            }
            return;
        }];
        
    [downloadTask resume];
    
    return;
}

- (void)cancelDownloadTaskWithConfigureName:(NSString*)configureName downloadUrl:(NSString*)downloadUrlString
{
    NSURLSessionDownloadTask *downloadTask = self.downloadTasksMap[configureName][downloadUrlString];
    if (!downloadTask) {
            return;
    }
    [downloadTask cancelByProducingResumeData:^(NSData *resumeData) {
        @synchronized(self)
        {
            [self.downloadTasksMap[configureName] removeObjectForKey:downloadUrlString];
        }
    }];
    return;
}

- (void)pauseDownloadTaskWithConfigureName:(NSString*)configureName downloadUrl:(NSString*)downloadUrlString saveResumeDataPath:(NSString*)saveResumeDataPath

{
    NSURLSessionDownloadTask *downloadTask = self.downloadTasksMap[configureName][downloadUrlString];
    if (!downloadTask) {
        return;
    }
    
    [downloadTask cancelByProducingResumeData:^(NSData *resumeData) {
        [YDFileUtil writeData:resumeData intoFileWithFilePath:saveResumeDataPath];
        @synchronized(self)
        {
            [self.downloadTasksMap[configureName] removeObjectForKey:downloadUrlString];
        }
    }];
    return;
}
@end
