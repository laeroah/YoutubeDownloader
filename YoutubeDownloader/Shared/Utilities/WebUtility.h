//
//  WebUtility.h
//  YoutubeDownloader
//
//  Created by Hao Wang  on 13-11-10.
//  Copyright (c) 2013年 HAO WANG. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WebUtility : NSObject

+ (NSDictionary *)parseQueryStringToDictionary:(NSString *)query;

@end
