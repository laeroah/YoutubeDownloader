//
//  YDImageUtil.m
//  YoutubeDownloader
//
//  Created by Hao Wang  on 13-11-24.
//  Copyright (c) 2013年 HAO WANG. All rights reserved.
//

#import "YDImageUtil.h"

@implementation YDImageUtil

+ (UIImage*)scaleImage:(UIImage*)image maxSize:(CGSize)size
{
    CGFloat orgWidth = image.size.width;
    CGFloat orgHeight = image.size.height;
    if (orgHeight <= size.height && orgWidth <= size.width)
        return image;
    
    CGFloat xScale = orgWidth / size.width;
    CGFloat yScale = orgHeight / size.height;
    CGFloat scale = xScale > yScale ? xScale : yScale;
    UIImage *result = [[UIImage alloc] initWithCGImage:[image CGImage] scale:scale orientation:image.imageOrientation];
    return result;
}

+ (UIImage*)scaleImage:(UIImage*)image withSize:(CGSize)newSize
{
    UIGraphicsBeginImageContext(newSize);
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}


@end
