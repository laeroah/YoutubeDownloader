//
//  YDAlbumManager.h
//  YoutubeDownloader
//
//  Created by Hao Wang  on 13-11-24.
//  Copyright (c) 2013年 HAO WANG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface YDAlbumManager : NSObject

@property (nonatomic, strong) ALAssetsLibrary *assetLibrary;

+ (YDAlbumManager *)sharedInstance;


@end
