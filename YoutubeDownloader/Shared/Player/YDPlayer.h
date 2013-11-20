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

@property (nonatomic, weak) id delegate;

#pragma mark - create player view
- (void)placeEmbeddedVideoOnView:(UIView *)view WithSize:(CGSize)size andVideoPath:(NSString *)videoPath;
- (void)placeEmbeddedAudioAdjustableVideoOnView:(UIView *)view WithSize:(CGSize)size andVideoPath:(NSString *)videoPath;
- (void)placeEmbeddedVideoOnView:(UIView *)view WithSize:(CGSize)size avComposition:(AVMutableComposition *)composition;

/**
 * @discussion resize the player view to the frame specified
 * @param frame is the new frame which you want to resize the player to
 * @param animated is the flag to tell if the transition should be animated
 */
- (void)resizePlayerViewToFrame:(CGRect)frame animated:(BOOL)animated;

#pragma mark - player control
- (void)start;
- (void)pause;
- (void)resume;
- (void)rewind;

/**
 * @discussion the audio offset is normally used to correct audio and video out of sync problem of some videos
 * @param offset when is positive, the audio will be advanced, and when it's negative, the audio will be delayed
 */
- (void)addAudioOffset:(CMTime)offset;
- (void)seekToTime:(CMTime)time;

/**
 * @discussion this property only becomes available after didBecomeReadyToPlayForPlayItem: callback is invoked
 */
- (CMTime)duration;

@end

@protocol YDPlayerDelegate <NSObject>

@optional
- (void)didPlausPlayer:(YDPlayer *)player;
- (void)didStartPlayer:(YDPlayer *)player;
- (void)didBecomeReadyToPlayForPlayItem:(AVPlayerItem *)playerItem;
- (void)updateCurrentPlayerTime:(CMTime)time;
- (void)playerViewTapped:(YDPlayer *)player;

@end