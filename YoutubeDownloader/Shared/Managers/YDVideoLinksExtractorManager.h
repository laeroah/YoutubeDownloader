//
//  YDVideoLinksExtractorManager.h
//  YoutubeDownloader
//
//  Created by Hao Wang  on 13-11-4.
//  Copyright (c) 2013年 HAO WANG. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString* const YDYouTubePlayerExtractorErrorDomain;
extern NSInteger const YDYouTubePlayerExtractorErrorCodeInvalidHTML;
extern NSInteger const YDYouTubePlayerExtractorErrorCodeNoStreamURL;
extern NSInteger const YDYouTubePlayerExtractorErrorCodeNoJSONData;

typedef void (^YDYouTubeExtractorCompletionBlock)(NSURL *videoURL, NSError *error);

typedef enum {
    YDYouTubeVideoQualitySmall    = 0,
    YDYouTubeVideoQualityMedium   = 1,
    YDYouTubeVideoQualityLarge    = 2,
} YDYouTubeVideoQuality;

@protocol YDYouTubeExtractorDelegate;

@interface YDVideoLinksExtractorManager : NSObject

@property (nonatomic, assign) YDYouTubeVideoQuality quality;
@property (nonatomic, strong) NSURL* youTubeURL;
@property (nonatomic, strong) NSURL *extractedURL;
@property (nonatomic, weak) IBOutlet id <YDYouTubeExtractorDelegate> delegate;
@property (nonatomic, strong) YDYouTubeExtractorCompletionBlock completionBlock;
@property (nonatomic, strong) NSString* extractionExpression;

-(id)initWithURL:(NSURL*)videoURL quality:(YDYouTubeVideoQuality)quality;
-(id)initWithID:(NSString*)videoID quality:(YDYouTubeVideoQuality)quality;

-(void)startExtracting;
-(void)stopExtracting;

-(void)extractVideoURLWithCompletionBlock:(YDYouTubeExtractorCompletionBlock)completionBlock;

@end

@protocol YDYouTubeExtractorDelegate <NSObject>

-(void)youTubeExtractor:(YDVideoLinksExtractorManager *)extractorManager didSuccessfullyExtractYouTubeURL:(NSURL *)videoURL;
-(void)youTubeExtractor:(YDVideoLinksExtractorManager *)extractorManager failedExtractingYouTubeURLWithError:(NSError *)error;

@end
