//
//  YDDownloadManager.h
//  YoutubeDownloader
//
//  Created by Hao Wang  on 13-11-17.
//  Copyright (c) 2013年 HAO WANG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DownloadTask.h"


@interface YDDownloadManager : NSObject<NSURLSessionDelegate>
{
    
}



+ (YDDownloadManager *)sharedInstance;
- (void)createDownloadTaskWithDownloadPageUrl:(NSString*)downloadPageUrl qualityType:(NSString*)qualityType videoDescription:(NSString*)videoDescription videoTitle:(NSString*)videoTitle videoDownloadUrl:(NSString*)videoDownloadUrl inContext:(NSManagedObjectContext *)context completion:(void(^)(BOOL success))completion;
- (void)startRefreshTimer;

@end
