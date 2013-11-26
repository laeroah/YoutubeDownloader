//
//  YDErrorUtil.h
//  YoutubeDownloader
//
//  Created by Hao Wang  on 13-11-24.
//  Copyright (c) 2013年 HAO WANG. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, VSErrorCode)
{
    kYDErrorNone,
    kYDErrorOpenFileFailed,
    kYDErrorStreamNotFound,
    kYDErrorCodecNotFound,
    kYDErrorOpenCodecFailed,
    kYDErrorAllocateFrame,
    kYDErrorBitmapSubtitleNotSupport,
    kYDErrorSetupVideoScalerFailed,
    kYDErrorResampleFailed,
    kYDErrorEncoderNotSupportFormat,
    kYDErrorAllocateBuffer,
    kYDErrorFillFrameFailed,
    kYDErrorEncodeAudioFailed,
    KYDErrorOpenMovieFailed,
    kYDErrorTaskExecutorNotFound,
    KYDErrorInvalidParam,
    kYDErrorResourceIsBusy,
    KYDErrorFacebookShareError,
    kYDErrorEncodingOutputError,
};


@interface YDErrorUtil : NSObject

+ (NSError*)errorWithCode:(NSInteger)code info:(id)info;
+ (NSString*)errorMsgWithCode:(NSInteger)code;

@end

