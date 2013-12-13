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

typedef void (^YDDownloadSuccess)();
typedef void (^YDDownloadFailuer)(NSError *error);
typedef void (^YDDownloadProgress)(int64_t totalBytesDownload, int64_t totalBytesExpectedDownload);

@interface YDNetworkUtility : NSObject
+ (YDNetworkUtility *)sharedInstance;
- (void)downloadFileFromUrl:(NSString*)downloadUrlString toDestination:(NSString*)destinationPath configureName:(NSString*)configureName
                    success:(YDDownloadSuccess)success failure:(YDDownloadFailuer)failure progress:(YDDownloadProgress)progress;
- (void)cancelDownloadTaskWithConfigureName:(NSString*)configureName downloadUrl:(NSString*)downloadUrlString;
- (void)pauseDownloadTaskWithConfigureName:(NSString*)configureName downloadUrl:(NSString*)downloadUrlString saveResumeDataPath:(NSString*)saveResumeDataPath;
- (void)initializeForConfigureName:(NSString*)configureName;

@end
