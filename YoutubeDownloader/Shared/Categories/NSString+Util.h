//
//  NSString+Util.h
//  YoutubeDownloader
//
//  Created by Hao Wang  on 13-11-10.
//  Copyright (c) 2013年 HAO WANG. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Util)

+ (BOOL)isEmpty:(NSString *)string;
- (NSString *)truncatedToLength:(NSUInteger)maxLength;

@end