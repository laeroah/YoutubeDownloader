//
//  YDImageUtil.h
//  YoutubeDownloader
//
//  Created by Hao Wang  on 13-11-24.
//  Copyright (c) 2013年 HAO WANG. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YDImageUtil : NSObject

+ (UIImage*)scaleImage:(UIImage*)image maxSize:(CGSize)size;
+ (UIImage*)scaleImage:(UIImage*)image withSize:(CGSize)newSize;

@end
