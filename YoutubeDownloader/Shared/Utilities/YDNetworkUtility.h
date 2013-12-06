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

- (void)downloadFileFromUrl:(NSString*)downloadUrlString toDestination:(NSString*)destinationPath
                    success:(YDDownloadSuccess)success failure:(YDDownloadFailuer)failure progress:(YDDownloadProgress)progress;

@end
