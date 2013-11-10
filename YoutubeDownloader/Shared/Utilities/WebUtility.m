//
//  WebUtility.m
//  YoutubeDownloader
//
//  Created by Hao Wang  on 13-11-10.
//  Copyright (c) 2013年 HAO WANG. All rights reserved.
//

#import "WebUtility.h"

@implementation WebUtility

+ (NSDictionary *)parseQueryStringToDictionary:(NSString *)query
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    NSArray *pairs = [query componentsSeparatedByString:@"&"];
    for (NSString *pair in pairs)
    {
        NSArray *elements = [pair componentsSeparatedByString:@"="];
        if ([elements count] == 2)
        {
            NSString *key = [elements[0] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            NSString *val = [elements[1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            dict[key] = val;
        }
    }
    return dict;
}


@end
