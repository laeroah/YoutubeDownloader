//
//  YDMedia.m
//  YoutubeDownloader
//
//  Created by Hao Wang  on 13-11-24.
//  Copyright (c) 2013年 HAO WANG. All rights reserved.
//

#import "YDMedia.h"
#import "YDImageUtil.h"
#import "SDImageCache.h"
#import "YDAlbumManager.h"
#import "YDErrorUtil.h"
#import "YDFileUtil.h"

@interface YDMedia()
{
    
    
}
@property (nonatomic, strong) AVAssetImageGenerator *imageGenerator;


@property (atomic, assign) NSInteger requestImagesCount;
@property (atomic, assign) NSInteger finishImagesCount;
@property (atomic, assign) NSInteger errorImagesCount;
@end

@implementation YDMedia

- (id)copyWithZone:(NSZone *)zone
{
    YDMedia *result = [[[self class] allocWithZone:zone] init];
    
    result.createDate = [self.createDate copy];
    result.mediaUrl = [self.mediaUrl copy];
    result.mediaType = [self.mediaType copy];
    return result;
}

- (NSString*)getThumbnailKeyWithWidth:(NSInteger)width height:(NSInteger)height
{
    return [NSString stringWithFormat:@"%@&size=%dx%d",self.mediaUrl,width,height];
}

- (UIImage*)genThumbnailImageWithAsset:(ALAsset*)asset width:(NSInteger)width height:(NSInteger)height
{
    NSString *key = [self getThumbnailKeyWithWidth:width height:height];
    UIImage *image = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:key];
    if (image)
        return image;
    
    image = [UIImage imageWithCGImage:[asset thumbnail]];
    UIImage *scaledImage = [YDImageUtil scaleImage:image maxSize:CGSizeMake(width , height)];
    [[SDImageCache sharedImageCache] storeImage:scaledImage forKey:key];
    return scaledImage;
}


- (void)getThumbnailImageWithCompletion:(YDMediaGetThumbnailCallback)completion WithWidth:(NSInteger)width height:(NSInteger)height
{
    NSString *key = [self getThumbnailKeyWithWidth:width height:height];
    UIImage *image = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:key];
    if (image)
    {
        if (completion)
            completion(image);
        return;
    }
    ALAssetsLibrary *library = [YDAlbumManager sharedInstance].assetLibrary;
    NSURL *fileURL = [NSURL fileURLWithPath:self.mediaUrl];
    [library assetForURL:fileURL
             resultBlock:^(ALAsset *asset){
                 if (!asset)
                 {
                     if (completion)
                         completion(nil);
                     return;
                 }
                 UIImage *image = [UIImage imageWithCGImage:[asset thumbnail]];
                 UIImage *scaledImage = [YDImageUtil scaleImage:image maxSize:CGSizeMake(width , height)];
                 [[SDImageCache sharedImageCache] storeImage:scaledImage forKey:key];
                 if (completion)
                     completion(scaledImage);
             }
            failureBlock:^(NSError *error) {
                NSLog(@"error = %@", [error description]);
                if (completion) {
                    completion(nil);
                }
            }];
}

- (void)getALAssetWithCompletion:(YDMediaGetALAssetCallback)completion
{
    ALAssetsLibrary *library = [YDAlbumManager sharedInstance].assetLibrary;
    [library assetForURL:
     [NSURL URLWithString:self.mediaUrl]
             resultBlock:^(ALAsset *asset){
                 if (completion)
                     completion(asset);
                 return;
             }
            failureBlock:^(NSError *error) {
                if (completion)
                    completion(nil);
            }];
}

- (BOOL)isAssetLoaded
{
    return self.asset != nil;
}

- (AVURLAsset *)asset
{
    if (!_asset)
    {
        if ([YDFileUtil fileExistWithFilePath:self.mediaUrl])
            _asset = [[AVURLAsset alloc] initWithURL:[NSURL fileURLWithPath:self.mediaUrl] options:nil];
        
        else
            _asset = [[AVURLAsset alloc] initWithURL:[NSURL URLWithString:self.mediaUrl] options:nil];
    }
    return _asset;
}

- (float)duration
{
    return CMTimeGetSeconds([self.asset duration]);
}

- (BOOL)hasAudio
{
    NSArray *tracks = [self.asset tracksWithMediaType:AVMediaTypeAudio];
    if (!tracks || [tracks count] <= 0)
        return NO;
    return YES;
}

- (BOOL)hasVideo
{
    NSArray *tracks = [self.asset tracksWithMediaType:AVMediaTypeVideo];
    if (!tracks || [tracks count] <= 0)
        return NO;
    return YES;
}

- (NSString*)getFirstTrackEncodeingNameWithType:(NSString *)mediaType
{
    NSArray *tracks = [self.asset tracksWithMediaType:mediaType];
    if (!tracks || [tracks count] <= 0)
        return nil;
    
    AVAssetTrack *track = [tracks objectAtIndex:0];
    if ([track.formatDescriptions count] <= 0)
        return nil;
    
    CMFormatDescriptionRef desc = (__bridge CMFormatDescriptionRef)track.formatDescriptions[0];
    CMVideoCodecType codec = CMFormatDescriptionGetMediaSubType(desc);
    return [NSString stringWithCString:(const char *)FourCC2Str(codec) encoding:NSUTF8StringEncoding];
}

- (YDVideoEncoding)getFirstTrackVideoEncoding
{
    NSString *encodingName = [self getFirstTrackEncodeingNameWithType:AVMediaTypeVideo];
    if ([encodingName isEqualToString:@"avc1"])
    {
        return YDVideoEncodingH264;
    }
    return YDVideoEncodingUnknown;
}

- (YDVideoAudioEncoding)getFirstTrackAudioEncoding
{
    NSString *encodingName = [self getFirstTrackEncodeingNameWithType:AVMediaTypeAudio];
    if ([encodingName isEqualToString:@"aac"])
    {
        return YDVideoAudioEncodingAAC;
    }
    if ([encodingName isEqualToString:@"ac3"])
    {
        return YDVideoAudioEncodingAC3;
    }
    return YDVideoAudioEncodingUnknown;
}

- (CGSize)getFirstVideoTrackSize
{
    NSArray *tracks = [self.asset tracksWithMediaType:AVMediaTypeVideo];
    if (!tracks || [tracks count] <= 0)
    {
        return CGSizeZero;
    }
    AVAssetTrack *track = [tracks objectAtIndex:0];
    return [track naturalSize];
}

- (CGSize)getPhotoTrackSize
{
    if (![self.mediaType isEqualToString:ALAssetTypePhoto])
    {
        return CGSizeZero;
    }
    
    UIImage *image = [UIImage imageWithContentsOfFile:self.mediaUrl];
    return [image size];
}

- (AVAssetImageGenerator *)imageGenerator
{
    if (!_imageGenerator)
        _imageGenerator = [[AVAssetImageGenerator alloc] initWithAsset:self.asset];
    return _imageGenerator;
}

- (void)getThumbnailsForTimes:(NSArray *)timesArray maxSize:(CGSize)maxSize success:(void(^)(NSNumber *requestTime , NSNumber *actTime , UIImage *image))success failure:(void(^)(NSError *error))failure
{
    if (!timesArray || [timesArray count] <= 0)
    {
        if (failure)
        {
            NSString* errorMsg = [NSString stringWithFormat:@"%@",
                                  [YDErrorUtil errorMsgWithCode:kYDErrorResourceIsBusy]];
            NSError *error = [YDErrorUtil errorWithCode:kYDErrorEncoderNotSupportFormat info:errorMsg];
            failure(error);
        }
        return;
    }
    
    if (_isGeneratingImage)
    {
        if (failure)
        {
            NSString* errorMsg = [NSString stringWithFormat:@"%@",
                                  [YDErrorUtil errorMsgWithCode:kYDErrorResourceIsBusy]];
            NSError *error = [YDErrorUtil errorWithCode:kYDErrorEncoderNotSupportFormat info:errorMsg];
            failure(error);
        }
        return;
    }
    
    self.isGeneratingImage = YES;
    self.requestImagesCount = [timesArray count];
    self.finishImagesCount = 0;
    self.errorImagesCount = 0;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        self.imageGenerator.maximumSize = maxSize;
        __block NSMutableArray *cmtimesArray = [NSMutableArray arrayWithCapacity:_requestImagesCount];
        [timesArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            cmtimesArray[idx] = [NSValue valueWithCMTime:CMTimeMakeWithSeconds([(NSNumber*)obj floatValue], 600)];
        }];
        
        [self.imageGenerator generateCGImagesAsynchronouslyForTimes:cmtimesArray
                                                  completionHandler:^(CMTime requestedTime, CGImageRef image, CMTime actualTime,
                                                                      AVAssetImageGeneratorResult result, NSError *error)
         {
             NSInteger finishCount = 0, errorCount = 0;
             if (result == AVAssetImageGeneratorSucceeded)
             {
                 UIImage *outImage = [UIImage imageWithCGImage:image];
                 NSNumber *outRequestTime = @(CMTimeGetSeconds(requestedTime));
                 NSNumber *outActTime = @(CMTimeGetSeconds(actualTime));
                 finishCount = ++self.finishImagesCount;
                 dispatch_async(dispatch_get_main_queue(), ^{
                     if (success)
                         success(outRequestTime, outActTime, outImage);
                 });
             }
             else if (result == AVAssetImageGeneratorFailed)
             {
                 errorCount = ++self.errorImagesCount;
                 dispatch_async(dispatch_get_main_queue(), ^{
                     if (failure)
                         failure(error);
                 });
             }
             
             if (finishCount + errorCount >= self.requestImagesCount)
             {
                 self.isGeneratingImage = NO;
             }
         }
         ];
    });
}


- (void)stopAsyncJobs
{
    if  (self.isGeneratingImage)
    {
        [_imageGenerator cancelAllCGImageGeneration];
        self.isGeneratingImage = NO;
    }
}

- (float)getFirstAudioVolume
{
    NSArray *tracks = [self.asset tracksWithMediaType:AVMediaTypeAudio];
    if (!tracks || [tracks count] <= 0)
        return 0;
    
    AVAssetTrack *track = [tracks objectAtIndex:0];
    if ([track.formatDescriptions count] <= 0)
        return 0;
    return [track preferredVolume];
}

@end
