//
//  YDFileUtil.m
//  YoutubeDownloader
//
//  Created by Hao Wang  on 13-11-24.
//  Copyright (c) 2013年 HAO WANG. All rights reserved.
//

#import "YDFileUtil.h"

@implementation YDFileUtil

+ (NSString *)documentDirectoryPath
{
	//Search for standard documents using NSSearchPathForDirectoriesInDomains
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory , NSUserDomainMask, YES) lastObject];
}

+ (BOOL)createDirectory:(NSString *)directoryName
{
    // Make sure FileUtil release memory
    @autoreleasepool
    {
        BOOL success = YES;
        // DO NOT use defaultManager as that is NOT thread safe
        NSFileManager *fileManager = [[NSFileManager alloc] init];
        NSString *dir = [[self documentDirectoryPath] stringByAppendingPathComponent:directoryName];
        NSError *error;
        if (![fileManager fileExistsAtPath:dir])
        {
            success = [fileManager createDirectoryAtPath:dir withIntermediateDirectories:YES attributes:nil error:&error];
        }
        return success;
    }
}

+(NSString*)tempPath
{
    return NSTemporaryDirectory();
}

+ (BOOL)createTempDirectory:(NSString *)directoryName
{
    // Make sure FileUtil release memory
    @autoreleasepool
    {
        BOOL success = YES;
        // DO NOT use defaultManager as that is NOT thread safe
        NSFileManager *fileManager = [[NSFileManager alloc] init];
        NSString *dir = [[self tempPath] stringByAppendingPathComponent:directoryName];
        NSError *error;
        if (![fileManager fileExistsAtPath:dir])
        {
            success = [fileManager createDirectoryAtPath:dir withIntermediateDirectories:NO attributes:nil error:&error];
        }
        return success;
    }
}

+ (NSString *)pathForTempDirectory:(NSString *)directoryName
{
    return [[self tempPath] stringByAppendingPathComponent:directoryName];
}

+ (NSString *)pathForDirectory:(NSString *)directoryName
{
    return [[self documentDirectoryPath] stringByAppendingPathComponent:directoryName];
}

+ (void)removeDirectory:(NSString *)directoryName
{
    // DO NOT USE defaultManager as it is NOT thread safe
    @autoreleasepool
    {
        NSFileManager *manager = [[NSFileManager alloc] init];
        NSError *error;
        if ([manager fileExistsAtPath:[self pathForDirectory:directoryName]])
            [manager removeItemAtPath:[self pathForDirectory:directoryName] error:&error];
        if (error)
            NSLog(@"%@", error);
    }
}

+ (void)removeTempDirectory:(NSString *)directoryName
{
    // DO NOT USE defaultManager as it is NOT thread safe
    @autoreleasepool
    {
        NSFileManager *manager = [[NSFileManager alloc] init];
        NSError *error;
        if ([manager fileExistsAtPath:[self pathForTempDirectory:directoryName]])
            [manager removeItemAtPath:[self pathForTempDirectory:directoryName] error:&error];
        if (error)
            NSLog(@"%@", error);
    }
}

+ (BOOL)fileExistWithFilePath:(NSString*)filePath
{
    NSFileManager *manager = [[NSFileManager alloc] init];
    return [manager fileExistsAtPath:filePath];
}

+ (BOOL)removeFileWithFilePath:(NSString*)filePath
{
    // Make sure FileUtil release memory
    @autoreleasepool
    {
        NSFileManager *manager = [[NSFileManager alloc] init];
        NSError *error;
        if ([manager fileExistsAtPath:filePath])
            [manager removeItemAtPath:filePath error:&error];
        if (error)
        {
            NSLog(@"%@", error);
            return NO;
        }
        return YES;
    }
}

+ (BOOL)removeFileWithFilePathURL:(NSURL*)fileURL
{
    NSString *filePath = [fileURL absoluteString];
    return [self removeFileWithFilePath:filePath];
}

+ (BOOL)createAbsoluteDirectory:(NSString *)directoryName
{
    // Make sure FileUtil release memory
    @autoreleasepool
    {
        BOOL success = YES;
        // DO NOT use defaultManager as that is NOT thread safe
        NSFileManager *fileManager = [[NSFileManager alloc] init];
        NSError *error;
        if (![fileManager fileExistsAtPath:directoryName])
        {
            success = [fileManager createDirectoryAtPath:directoryName withIntermediateDirectories:YES attributes:nil error:&error];
        }
        return success;
    }
}

+ (void)removeFile:(NSString *)filePath
{
    // DO NOT USE defaultManager as it is NOT thread safe
    @autoreleasepool
    {
        NSFileManager *manager = [[NSFileManager alloc] init];
        NSError *error;
        if ([manager fileExistsAtPath:filePath])
            [manager removeItemAtPath:filePath error:&error];
        if (error)
            NSLog(@"%@", error);
    }
}


+ (BOOL)moveFileFrom:(NSURL*)fromLocation to:(NSURL*)toLocation error:(NSError**)perror
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:[toLocation path]])
        [fileManager removeItemAtPath:[toLocation path] error:nil];
        
    if ([fileManager moveItemAtURL:fromLocation
                             toURL:toLocation
                             error: perror])
    {
       return YES;
    }
    
    return NO;
}

+ (NSData*)getDataFromFilePath:(NSString*)filePath
{
    if (!filePath) {
        return nil;
    }
    return [NSData dataWithContentsOfFile:filePath];
}

+ (void)appendData:(NSData*)data intoFileWithFilePath:(NSString*)filePath
{
    NSFileHandle *myHandle = [NSFileHandle fileHandleForWritingAtPath:filePath];
    [myHandle seekToEndOfFile];
    [myHandle writeData:data];
}

+ (void)writeData:(NSData*)data intoFileWithFilePath:(NSString*)filePath
{
    [data writeToFile:filePath atomically:YES];
}

+ (int64_t)getFileSizeWithPath:(NSString*)filePath
{
    NSError *attributesError;
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:filePath])
    {
        return 0;
    }
        
    NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:[NSURL fileURLWithPath:filePath]error:&attributesError];
    if (!fileAttributes) {
        return 0;
    }
    NSNumber *fileSizeNumber = [fileAttributes objectForKey:NSFileSize];
    return [fileSizeNumber longLongValue];
}

@end
