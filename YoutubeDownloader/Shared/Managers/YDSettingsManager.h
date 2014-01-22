//
//  YDSettingsManager.h
//  YoutubeDownloader
//
//  Created by HAO WANG on 12/3/13.
//  Copyright (c) 2013 HAO WANG. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YDSettingsManager : NSObject

+ (YDSettingsManager*) sharedInstance;

- (BOOL)shouldDeleteAfterWatch;
- (BOOL)shouldDeleteAfterDuration;
- (void)setShouldDeleteAfterWatch:(BOOL)deleteAfterWatch;
- (NSTimeInterval)timeToDeleteAfterDownload;

@end
