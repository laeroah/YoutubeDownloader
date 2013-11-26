//
//  YDAlbumManager.m
//  YoutubeDownloader
//
//  Created by Hao Wang  on 13-11-24.
//  Copyright (c) 2013年 HAO WANG. All rights reserved.
//

#import "YDAlbumManager.h"

@implementation YDAlbumManager

+ (YDAlbumManager *)sharedInstance
{
    static YDAlbumManager *sharedAlbumManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedAlbumManager = [[YDAlbumManager alloc] init];
        sharedAlbumManager.assetLibrary = [[ALAssetsLibrary alloc] init];
    });
    return sharedAlbumManager;
}

@end
