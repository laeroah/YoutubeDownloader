//
//  NSString+Util.m
//  YoutubeDownloader
//
//  Created by Hao Wang  on 13-11-10.
//  Copyright (c) 2013年 HAO WANG. All rights reserved.
//

#import "NSString+Util.h"

@implementation NSString (Util)

+ (BOOL)isEmpty:(id)string
{
    return string == nil
	|| string == NULL
	|| ([string respondsToSelector:@selector(length)]
		&& [(NSData *)string length] == 0)
	|| ([string respondsToSelector:@selector(count)]
		&& [(NSArray *)string count] == 0)
	|| [string isKindOfClass:[NSNull class]]
	|| ![string isKindOfClass:[NSString class]]
	|| [string isEqualToString:@"\u200d"]
	|| [string isEqualToString:@"\n"];
}

- (NSString *)truncatedToLength:(NSUInteger)maxLength
{
    const NSUInteger length = [self length];
    if (length <= maxLength)
        return self;
    // Don't break composed character sequences, stop before the last sequence that doesn't fit
    NSRange endRange = [self rangeOfComposedCharacterSequenceAtIndex:maxLength];
    return [self substringToIndex:endRange.location];
}

+ (NSDictionary *)parseQueryString:(NSURL *)url
{
	NSString *query = [url query];
	NSArray *parts = [query componentsSeparatedByString:@"&"];
    
	NSMutableDictionary *toReturn = [NSMutableDictionary dictionary];
	for (id part in parts)
    {
        // For each URL Parameter, separate into key and value
		NSArray *keyValue = [(NSString *)part componentsSeparatedByString:@"="];
        
		NSString *key;
		NSString *value;
		if ([keyValue count] == 0)
		{
			key = [(NSString *) keyValue[0] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            toReturn[key] = @"";
		}
		else if ([keyValue count] == 2)
		{
			key = [(NSString *) keyValue[0] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
			value = [(NSString *) keyValue[1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            toReturn[key] = value;
		}
	}
	return toReturn;
}

@end
