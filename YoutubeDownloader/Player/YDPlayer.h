//
//  YDPlayerView.h
//  YoutubeDownloader
//
//  Created by HAO WANG on 11/4/13.
//  Copyright (c) 2013 HAO WANG. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface YDPlayer : NSObject

#pragma mark - create player view
- (void)placeEmbeddedVideoOnView:(UIView *)view WithSize:(CGSize)size andVideoPath:(NSString *)videoPath;
- (void)placeEmbeddedVideoOnView:(UIView *)view WithSize:(CGSize)size avComposition:(AVMutableComposition *)composition videoComposition:(AVMutableVideoComposition*)videoComposition;

#pragma mark - player control
- (void)pause;
- (void)resume;
- (void)rewind;

@end
