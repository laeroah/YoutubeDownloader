//
//  YDVideoLinksExtractorManager.h
//  YoutubeDownloader
//
//  Created by Hao Wang  on 13-11-4.
//  Copyright (c) 2013年 HAO WANG. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString* const kYDYouTubePlayerExtractorErrorDomain;
extern NSInteger const YDYouTubePlayerExtractorErrorCodeInvalidHTML;
extern NSInteger const YDYouTubePlayerExtractorErrorCodeNoStreamURL;
extern NSInteger const YDYouTubePlayerExtractorErrorCodeNoJSONData;

typedef void (^YDYouTubeExtractorCompletionBlock)(NSURL *videoUrl , NSDictionary *videoURLDict, NSError *error);

typedef enum {
    YDYouTubeVideoQualitySmall    = 0,
    YDYouTubeVideoQualityMedium   = 1,
    YDYouTubeVideoQualityLarge    = 2,
} YDYouTubeVideoQuality;

@protocol YDYouTubeExtractorDelegate;

@interface YDVideoLinksExtractorManager : NSObject

@property (nonatomic, assign) YDYouTubeVideoQuality quality;
@property (nonatomic, strong) NSURL* youTubeURL;
@property (nonatomic, strong) NSMutableDictionary *resultDict;
@property (nonatomic, weak) IBOutlet id <YDYouTubeExtractorDelegate> delegate;
@property (nonatomic, strong) YDYouTubeExtractorCompletionBlock completionBlock;
@property (nonatomic, strong) NSString* extractionExpression;

-(id)initWithURL:(NSURL*)videoURL quality:(YDYouTubeVideoQuality)quality;
-(id)initWithID:(NSString*)videoID quality:(YDYouTubeVideoQuality)quality;

-(void)startExtracting;
-(void)stopExtracting;

-(void)extractVideoURLWithCompletionBlock:(YDYouTubeExtractorCompletionBlock)completionBlock;

@end
