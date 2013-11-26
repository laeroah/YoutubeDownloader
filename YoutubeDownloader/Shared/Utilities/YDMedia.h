//
//  YDMedia.h
//  YoutubeDownloader
//
//  Created by Hao Wang  on 13-11-24.
//  Copyright (c) 2013年 HAO WANG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <AVFoundation/AVFoundation.h>

typedef NS_ENUM(NSInteger, YDVideoQuality)
{
    YDVideoQualityLow,
    YDVideoQualityMedium,
    YDVideoQualityHigh
};

typedef NS_ENUM(NSInteger, YDVideoEncodingStatus)
{
    YDVideoEncodingStatusUnknown,
    YDVideoEncodingStatusPaused,
    YDVideoEncodingStatusEncoding,
    YDVideoEncodingStatusFinished,
    YDVideoEncodingStatusError
};

typedef NS_ENUM(NSInteger, YDVideoAudioEncoding)
{
    YDVideoAudioEncodingAC3,
    YDVideoAudioEncodingAAC,
    YDVideoAudioEncodingUnknown
};

typedef NS_ENUM(NSInteger, YDVideoEncoding)
{
    YDVideoEncodingH264,
    YDVideoEncodingUnknown
};

typedef NS_ENUM(NSInteger, YDVideoQualityType)
{
    YDVideoQualityTypeSD, // 4:3
    YDVideoQualityTypeHD  // 16:9
};

typedef enum
{
    YDMediaTypeALL = 0,
    YDMediaTypeVideo = 1,
    YDMediaTypePhoto = 2,
    YDMediaTypeTitle = 3,
    YDMediaTypeAudio = 4
}YDMediaType;

#define FourCC2Str(code) (char[5]){(code >> 24) & 0xFF, (code >> 16) & 0xFF, (code >> 8) & 0xFF, code & 0xFF, 0}

typedef void (^YDMediaGetThumbnailCallback)(UIImage *thumbnail);
typedef void (^YDMediaGetALAssetCallback)(ALAsset *aasset);

@interface YDMedia : NSObject<NSCopying>
@property (nonatomic, strong) NSDate *createDate;
@property (nonatomic, strong) NSString *mediaUrl;
@property (nonatomic, strong) NSString *mediaType;
@property (nonatomic, strong) AVURLAsset *asset;
@property (atomic, assign) BOOL isGeneratingImage;

- (UIImage*)genThumbnailImageWithAsset:(ALAsset*)asset width:(NSInteger)width height:(NSInteger)height;
- (void)getThumbnailImageWithCompletion:(YDMediaGetThumbnailCallback)completion WithWidth:(NSInteger)width height:(NSInteger)height;
- (float)duration;
- (YDVideoAudioEncoding)getFirstTrackAudioEncoding;
- (YDVideoEncoding)getFirstTrackVideoEncoding;
- (BOOL)hasAudio;
- (BOOL)hasVideo;
- (CGSize)getFirstVideoTrackSize;
- (CGSize)getPhotoTrackSize;
- (float)getFirstAudioVolume;
- (void)getALAssetWithCompletion:(YDMediaGetALAssetCallback)completion;
- (void)stopAsyncJobs;
- (void)getThumbnailsForTimes:(NSArray *)timesArray maxSize:(CGSize)maxSize success:(void(^)(NSNumber *requestTime ,NSNumber *actTime , UIImage *image))success failure:(void(^)(NSError *error))failure;
@end
