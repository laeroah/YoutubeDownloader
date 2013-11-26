//
//  YDFileUtil.h
//  YoutubeDownloader
//
//  Created by Hao Wang  on 13-11-24.
//  Copyright (c) 2013年 HAO WANG. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YDFileUtil : NSObject

+ (NSString *)documentDirectoryPath;

+ (BOOL)createDirectory:(NSString *)directoryName;
+ (NSString *)pathForDirectory:(NSString *)directoryName;
+ (void)removeDirectory:(NSString *)directoryName;
+ (BOOL)fileExistWithFilePath:(NSString*)filePath;
+ (BOOL)removeFileWithFilePath:(NSString*)filePath;
+ (void)removeTempDirectory:(NSString *)directoryName;
+ (BOOL)createTempDirectory:(NSString *)directoryName;
+ (NSString *)pathForTempDirectory:(NSString *)directoryName;
+ (BOOL)createAbsoluteDirectory:(NSString *)directoryName;
+ (void)removeFile:(NSString *)filePath;


@end
