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
    // get url_encoded_fmt_stream_map
    NSString *streamMappingString = @"\\\"url_encoded_fmt_stream_map\\\"";
    NSRange streamMappingRange = [html rangeOfString:streamMappingString];
    if (streamMappingRange.location == NSNotFound)
    {
        if (self.completionBlock)
            self.completionBlock(self.youTubeURL, nil, nil,nil);
        return;
    }
    
    // get begin \"
    NSString *newString = [html substringFromIndex:streamMappingRange.location + streamMappingRange.length];
    NSRange beginRange = [ newString rangeOfString:@"\\\""];
    if (beginRange.location == NSNotFound)
    {
        if (self.completionBlock)
            self.completionBlock(self.youTubeURL, nil, nil,nil);
        return;
    }
    
    // get end \"
    NSString *newString1 = [newString substringFromIndex:beginRange.location + beginRange.length];
    NSRange endRange = [ newString1 rangeOfString:@"\\\""];
    if (endRange.location == NSNotFound)
    {
        if (self.completionBlock)
            self.completionBlock(self.youTubeURL, nil, nil,nil);
        return;
    }
    
    NSMutableString* allStreamURL = [NSMutableString stringWithString: [newString1 substringToIndex:endRange.location]];
    [allStreamURL replaceOccurrencesOfString:@"\\\\u0026" withString:@"&" options:NSCaseInsensitiveSearch range:NSMakeRange(0, allStreamURL.length)];
    [allStreamURL replaceOccurrencesOfString:@"\\\\\\" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, allStreamURL.length)];
    NSString *unescapeAllStreamUrl = [allStreamURL stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    //NSString *unescapeAllStreamUrl = allStreamURL;
    
    NSRange range;
    NSInteger lastIndex = 0;
    Boolean startQuotation = NO;
    NSMutableArray *urlsArray = [NSMutableArray array];
    for(NSInteger index = 0; index < [unescapeAllStreamUrl length]; index++)
    {
        range.length = 1;
        range.location = index;
        NSString *currentChar = [unescapeAllStreamUrl substringWithRange:range];
        
        if ([currentChar isEqualToString:@"\""])
        {
            startQuotation = startQuotation ? NO : YES
            ;
        }
        
        if ([currentChar isEqualToString:@","] && !startQuotation)
        {
            range.length = index - lastIndex;
            range.location = lastIndex;
            [urlsArray addObject:[unescapeAllStreamUrl substringWithRange:range]];
            lastIndex = index + 1;
        }
    }
    
    if (lastIndex < [unescapeAllStreamUrl length])
    {
        range.length = [unescapeAllStreamUrl length] - lastIndex;
        range.location = lastIndex;
        [urlsArray addObject:[unescapeAllStreamUrl substringWithRange:range]];
    }
    self.resultDict = [NSMutableDictionary dictionaryWithCapacity:3];
    NSInteger index;
    NSString *resultUrl;
    NSString *youtubeVideoID;
    for (NSString *videoUrl in urlsArray)
    {
        if ([NSString isEmpty:videoUrl])
            continue;
        
        NSMutableArray *components = [NSMutableArray arrayWithArray:[videoUrl componentsSeparatedByString:@"&"]];
        NSString *beginString;
        NSMutableArray *removeObjects = [NSMutableArray array];
        BOOL removeItag= NO;
        NSString *iTagComponent;
        for (index = 0; index < [components count]; index++)
        {
            NSString *componetString = [components objectAtIndex:index];
            if ([componetString hasPrefix:@"url=http"])
            {
                beginString = componetString;
                [removeObjects addObject:componetString];
            }
            else if ([componetString hasPrefix:@"fallback_host="])
            {
                [removeObjects addObject:componetString];
            }
            else if ([componetString hasPrefix:@"pcm2fr="])
            {
                [removeObjects addObject:componetString];
            }
            else if ([componetString hasPrefix:@"type="])
            {
                [removeObjects addObject:componetString];
            }
            else if  ([componetString hasPrefix:@"itag="])
            {
                if (!removeItag) {
                    iTagComponent = componetString;
                    removeItag = YES;
                }
                [removeObjects addObject:componetString];
            }
        }
        
        [components removeObjectsInArray:removeObjects];
        [components addObject:iTagComponent];
        
        resultUrl = [NSString stringWithFormat:@"%@&%@",beginString,[components componentsJoinedByString:@"&"]];
        
        NSDictionary *queryItems = [WebUtility parseQueryStringToDictionary:resultUrl];
        NSString *quality = queryItems[@"quality"];
        if (!quality)
        {
            continue;
        }
        
        if (!youtubeVideoID)
        {
            youtubeVideoID = queryItems[@"id"];
        }
        
        self.resultDict[quality] = [resultUrl substringFromIndex:4];
    }
    
    if (!youtubeVideoID)
    {
        if (self.completionBlock)
            self.completionBlock(self.youTubeURL, nil, nil,nil);
        return;
    }
    
    if ([self.resultDict count] <= 0)
    {
        if (self.completionBlock)
            self.completionBlock(self.youTubeURL, nil, nil,nil);
        return;
    }
    
    if (self.completionBlock)
        self.completionBlock(self.youTubeURL, youtubeVideoID, self.resultDict,nil);
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
            self.completionBlock(self.youTubeURL, nil, nil, [NSError errorWithDomain:kYDYouTubePlayerExtractorErrorDomain code:1 userInfo:[NSDictionary dictionaryWithObject:@"Couldn't download the HTML source code. URL might be invalid." forKey:NSLocalizedDescriptionKey]]);
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
        self.completionBlock(self.youTubeURL , nil, nil, error);
    }
}

@end
