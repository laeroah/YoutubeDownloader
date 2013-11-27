//
//  YDVideoLinksExtractorManager.m
//  YoutubeDownloader
//
//  Created by Hao Wang  on 13-11-4.
//  Copyright (c) 2013年 HAO WANG. All rights reserved.
//

#import "YDVideoLinksExtractorManager.h"
#import "NSString+Util.h"
#import "WebUtility.h"

static NSString* const kUserAgent = @"Mozilla/5.0 (iPhone; CPU iPhone OS 5_0 like Mac OS X) AppleWebKit/534.46 (KHTML, like Gecko) Version/5.1 Mobile/9A334 Safari/7534.48.3";
NSString* const kYDYouTubePlayerExtractorErrorDomain = @"YDYouTubeExtractorErrorDomain";

@interface YDVideoLinksExtractorManager ()

@property (nonatomic, strong) NSURLConnection* connection;
@property (nonatomic, strong) NSMutableData* buffer;

@end

@implementation YDVideoLinksExtractorManager

#pragma mark Initialization

-(id)initWithURL:(NSURL *)videoURL quality:(YDYouTubeVideoQuality)videoQuality
{
    self = [super init];
    if (self)
    {
        self.youTubeURL = videoURL;
        self.quality = videoQuality;
        self.extractionExpression = @"(?!\\\\\")url=http[^\"]*?itag=[^\"]*?(?=\\\\\")";

    }
    return self;
}

-(id)initWithID:(NSString *)videoID quality:(YDYouTubeVideoQuality)quality
{
    NSURL* URL = (videoID) ? [NSURL URLWithString:[NSString stringWithFormat:@"http://m.youtube.com/watch?v=%@", videoID]] : nil;
    return [self initWithURL:URL quality:quality];
}

#pragma mark -
#pragma mark Other Methods

-(void)startExtracting {
    NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    NSArray *cookies = [cookieStorage cookies];
    for (NSHTTPCookie *cookie in cookies) {
        if ([cookie.domain rangeOfString:@"youtube"].location != NSNotFound) {
            [cookieStorage deleteCookie:cookie];
        }
    }
    
    if (!self.buffer || !self.resultDict)
    {
        NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:self.youTubeURL];
        [request setValue:kUserAgent forHTTPHeaderField:@"User-Agent"];
        
        self.connection = [NSURLConnection connectionWithRequest:request delegate:self];
        [self.connection start];
    }
}

-(void)stopExtracting
{
    [self closeConnection];
}

- (void)extractVideoURLWithCompletionBlock:(YDYouTubeExtractorCompletionBlock)completionBlock
{
    self.completionBlock = completionBlock;
    [self startExtracting];
}

#pragma mark -
#pragma mark Private

-(void)closeConnection {
    [self.connection cancel];
    self.connection = nil;
    self.buffer = nil;
}

-(void)extractYouTubeURLFromFile:(NSString *)html
{
    NSError *error;
    
    NSRegularExpression* regex = [[NSRegularExpression alloc] initWithPattern:self.extractionExpression options:NSRegularExpressionCaseInsensitive error:&error];
    
    if (error)
    {
        if (self.completionBlock)
        {
            self.completionBlock(self.youTubeURL, nil,error);
        }
        return;
    }
    
    NSArray* videos = [regex matchesInString:html options:0 range:NSMakeRange(0, [html length])];
    if ([videos count] <= 0)
    {
        if (self.completionBlock)
            self.completionBlock(self.youTubeURL, nil,nil);
        return;
    }
    
    NSTextCheckingResult *video = videos[0];
    NSMutableString* allStreamURL = [NSMutableString stringWithString: [html substringWithRange:video.range]];
    [allStreamURL replaceOccurrencesOfString:@"\\\\u0026" withString:@"&" options:NSCaseInsensitiveSearch range:NSMakeRange(0, allStreamURL.length)];
    [allStreamURL replaceOccurrencesOfString:@"\\\\\\" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, allStreamURL.length)];
    NSString *unescapeAllStreamUrl = [allStreamURL stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"unescapeAllStreamUrl = %@", unescapeAllStreamUrl);

    NSArray *videoLists = [unescapeAllStreamUrl componentsSeparatedByString:@"url="];
    
    self.resultDict = [NSMutableDictionary dictionaryWithCapacity:3];
    for (NSString *videoUrl in videoLists)
    {
        if ([NSString isEmpty:videoUrl])
            continue;
        NSDictionary *queryItems = [WebUtility parseQueryStringToDictionary:videoUrl];
        NSString *quality = queryItems[@"quality"];
        if (!quality)
        {
            continue;
        }
        NSString *playUrl;
        if ([videoUrl rangeOfString:@",type="].location != NSNotFound)
        {
            playUrl = [videoUrl substringToIndex:[videoUrl rangeOfString:@",type="].location];
        }
        else if ([videoUrl rangeOfString:@"&type="].location != NSNotFound)
        {
            playUrl = [videoUrl substringToIndex:[videoUrl rangeOfString:@"&type="].location];
        }
        else
            playUrl = videoUrl;
        
        playUrl = [playUrl stringByReplacingOccurrencesOfString:@"," withString:@"&"];
        self.resultDict[quality] = playUrl;
        //[videoUrl stringByReplacingOccurrencesOfString:@"%2C" withString:@","];
    }
    
    if ([self.resultDict count] <= 0)
    {
        if (self.completionBlock)
            self.completionBlock(self.youTubeURL, nil,nil);
        return;
    }
    
    if (self.completionBlock)
        self.completionBlock(self.youTubeURL, self.resultDict,nil);
}

#pragma mark -
#pragma mark NSURLConnectionDelegate

-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    long long capacity;
    if (response.expectedContentLength != NSURLResponseUnknownLength)
        capacity = response.expectedContentLength;
    else
        capacity = 0;
    
    self.buffer = [[NSMutableData alloc] initWithCapacity:capacity];
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.buffer appendData:data];
}

-(void)connectionDidFinishLoading:(NSURLConnection *) connection
{
    NSString* html = [[NSString alloc] initWithData:self.buffer encoding:NSASCIIStringEncoding];
    [self closeConnection];
    
    if (html.length <= 0)
    {
        if (self.completionBlock)
        {
            self.completionBlock(self.youTubeURL, nil, [NSError errorWithDomain:kYDYouTubePlayerExtractorErrorDomain code:1 userInfo:[NSDictionary dictionaryWithObject:@"Couldn't download the HTML source code. URL might be invalid." forKey:NSLocalizedDescriptionKey]]);
        }
        return;
    }
    
    NSLog(@"html = %@",html);
    
    [self extractYouTubeURLFromFile:html];
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [self closeConnection];
    
    if (self.completionBlock)
    {
        self.completionBlock(self.youTubeURL , nil, error);
    }
}

@end
