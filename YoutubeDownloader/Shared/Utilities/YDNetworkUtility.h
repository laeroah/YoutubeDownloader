//
//  YDNetworkUtility.h
//  YoutubeDownloader
//
//  Created by Hao Wang  on 13-12-4.
//  Copyright (c) 2013年 HAO WANG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"
#import "YDConstants.h"


@protocol YDNetworkUtilityDelegate <NSObject>

- (void)downloadSuccessWithUrl:(NSString*)url downloadToUrl:(NSURL*)toLocation;
- (void)downloadFailureWithUrl:(NSString*)url error:(NSError*)error;
- (void)downloadProgressWithUrl:(NSString*)url totalBytesDownload:(int64_t)totalBytesDownload totalBytesExpectedDownload:(int64_t)totalBytesExpectedDownload;

@end

@interface YDNetworkUtility : NSObject <NSURLSessionDownloadDelegate>

- (id)initWithConfigureName:(NSString*)configureName delegate:(id<YDNetworkUtilityDelegate>)delegate completion:(void(^)())completion;
- (void)downloadFileFromUrl:(NSString*)downloadUrlString resumeDataPath:(NSString*)resumeDataPath;
- (void)cancelDownloadTaskDownloadUrl:(NSString*)downloadUrlString;

- (void)pauseDownloadTaskWithDownloadUrl:(NSString*)downloadUrlString saveResumeDataPath:(NSString*)saveResumeDataPath;
- (void)pauseDownloadTaskWithDownloadUrl:(NSString*)downloadUrlString saveResumeDataPath:(NSString*)saveResumeDataPath;

@end


