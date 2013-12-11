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

@property (nonatomic, strong) AFURLSessionManager *sessionManager;
@property (nonatomic, strong) NSURLSessionDownloadTask *downloadTask;
@property (nonatomic, strong) AFHTTPRequestOperation *httpRequestOperation;
@end

@implementation YDNetworkUtility

- (void)downloadFileFromUrl:(NSString*)downloadUrlString toDestination:(NSString*)destinationPath
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

    if ([YDDeviceUtility isIOS7orAbove]) {
        
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration backgroundSessionConfiguration:@"YDNetworkBackground"];
        
        if  (!self.sessionManager)
            self.sessionManager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
        
        //[self.sessionManager invalidateSessionCancelingTasks:YES];
        
        self.downloadTask = [self.sessionManager downloadTaskWithRequest:request progress:nil
            destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
                return [NSURL fileURLWithPath:destinationPath];
            } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
                if (error) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                            if (failure) {
                                failure(error);
                            }
                            self.downloadTask = nil;
                    });
                    return;
                }
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (success) {
                            success();
                        }
                        self.downloadTask = nil;
                    });
                });
                return;
            }];
        
        __weak YDNetworkUtility *weakSelf = self;
        [self.sessionManager setDownloadTaskDidWriteDataBlock:^(NSURLSession *session, NSURLSessionDownloadTask *downloadTask, int64_t bytesWritten, int64_t totalBytesWritten, int64_t totalBytesExpectedToWrite) {
            if (weakSelf.downloadTask == downloadTask && progress) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    progress(totalBytesWritten, totalBytesExpectedToWrite);
                });
            }
            return;
        }];
        
        [self.downloadTask resume];
        
        return;
    }
    
    __weak YDNetworkUtility *weakSelf = self;
    self.httpRequestOperation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    self.httpRequestOperation.outputStream = [NSOutputStream outputStreamToFileAtPath:destinationPath append:NO];
    [self.httpRequestOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (success) {
            success();
        }
        weakSelf.httpRequestOperation = nil;
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (failure){
            failure(error);
        }
        weakSelf.httpRequestOperation = nil;
    }];
    
    [self.httpRequestOperation setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
        if (progress) {
            progress(totalBytesRead, totalBytesExpectedToRead);
        }
    }];
    
    [self.httpRequestOperation start];
    
    return;
}

- (void)cancelCurrentDownloadTask
{
    if ([YDDeviceUtility isIOS7orAbove]) {
         [self.downloadTask cancel];
         return;
    }
    
    [self.httpRequestOperation cancel];
}
@end
