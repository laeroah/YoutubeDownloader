//
//  YDErrorUtil.m
//  YoutubeDownloader
//
//  Created by Hao Wang  on 13-11-24.
//  Copyright (c) 2013年 HAO WANG. All rights reserved.
//

#import "YDErrorUtil.h"

NSString * kxYDErrorDomain = @"com.youtubedownload";

@implementation YDErrorUtil

+ (NSError*)errorWithCode:(NSInteger)code info:(id)info
{
    NSDictionary *userInfo = nil;
    
    if ([info isKindOfClass: [NSDictionary class]]) {
        
        userInfo = info;
        
    } else if ([info isKindOfClass: [NSString class]]) {
        
        userInfo = @{ NSLocalizedDescriptionKey : info };
    }
    return [NSError errorWithDomain:kxYDErrorDomain
                               code:code
                           userInfo:userInfo];
}

+ (NSString*)errorMsgWithCode:(NSInteger)errorCode
{
    switch (errorCode)
    {
        case kYDErrorNone:
            return @"";
        case kYDErrorOpenFileFailed:
            return NSLocalizedString(@"Could not open source file", nil);
        case kYDErrorStreamNotFound:
            return NSLocalizedString(@"Could not find stream information", nil);
        case kYDErrorCodecNotFound:
            return NSLocalizedString(@"Could not find codec", nil);
        case kYDErrorOpenCodecFailed:
            return NSLocalizedString(@"Could not open codec", nil);
        case kYDErrorAllocateFrame:
            return NSLocalizedString(@"Could not allocate frame", nil);
        case kYDErrorBitmapSubtitleNotSupport:
            return NSLocalizedString(@"Could not support bitmap subtitle", nil);
        case kYDErrorSetupVideoScalerFailed:
            return NSLocalizedString(@"Could not setup video scaler", nil);
        case kYDErrorResampleFailed:
            return NSLocalizedString(@"Could not resample audio", nil);
        case kYDErrorEncoderNotSupportFormat:
            return NSLocalizedString(@"Encoder does not support sample format", nil);
        case kYDErrorAllocateBuffer:
            return NSLocalizedString(@"Could not allocate buffer", nil);
        case kYDErrorFillFrameFailed:
            return NSLocalizedString(@"Could not fill frame failed", nil);
        case kYDErrorEncodeAudioFailed:
            return NSLocalizedString(@"Could not fill frame failed", nil);
        case KYDErrorOpenMovieFailed:
            return NSLocalizedString(@"Could not open movie", nil);
        case kYDErrorTaskExecutorNotFound:
            return NSLocalizedString(@"Could not find the task executor", nil);
        case KYDErrorInvalidParam:
            return NSLocalizedString(@"Invalid parameters", nil);
        case kYDErrorResourceIsBusy:
            return NSLocalizedString(@"Resource is busy", nil);
        case KYDErrorFacebookShareError:
            return NSLocalizedString(@"Facebook share error", nil);
        default:
            return @"";
    }
}

@end
