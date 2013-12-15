//
//  YDDownloadManager.h
//  YoutubeDownloader
//
//  Created by Hao Wang  on 13-11-17.
//  Copyright (c) 2013年 HAO WANG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DownloadTask.h"
#import "YDNetworkUtility.h"

@interface YDDownloadManager : NSObject<YDNetworkUtilityDelegate>
{
    
}

+ (YDDownloadManager *)sharedInstance;
- (void)createDownloadTaskWithDownloadPageUrl:(NSString*)downloadPageUrl youtubeVideoID:(NSString*)youtubeVideoID videoDuration:(NSNumber*)duration qualityType:(NSString*)qualityType videoDescription:(NSString*)videoDescription videoTitle:(NSString*)videoTitle videoDownloadUrl:(NSString*)videoDownloadUrl inContext:(NSManagedObjectContext *)context completion:(void(^)(BOOL success, NSNumber *downloadTaskID))completion;
- (void)downloadVideoImageWithVideoID:(NSString *)youtubeVideoID;
- (void)getVideoFileSize;
- (void)downloadVideoInfoWithDownloadTaskID:(NSNumber *)downloadTaskID;
- (void)startGetVideoInfoTimer;
- (void)startClearTimer;
- (void)updateDownloadTask:(DownloadTask*)task downloadPageUrl:(NSString*)downloadPageUrl youtubeVideoID:(NSString*)youtubeVideoID videoDuration:(NSNumber*)duration qualityType:(NSString*)qualityType videoDescription:(NSString*)videoDescription videoTitle:(NSString*)videoTitle videoDownloadUrl:(NSString*)videoDownloadUrl inContext:(NSManagedObjectContext *)context completion:(void(^)(BOOL success, NSNumber *downloadTaskID))completion;
- (void)retryToDownloadWithTaskID:(NSNumber*)downloadTaskID;
- (void)pauseDownloadTaskWithDownloadTaskID:(NSNumber *)downloadTaskID completion:(void(^)())completion;
- (void)resumeDownloadTaskWithDownloadTaskID:(NSNumber *)downloadTaskID completion:(void(^)())completion;
- (void)initializeProcess;


@end
