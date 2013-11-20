//
//  YDPlayerView.m
//  YoutubeDownloader
//
//  Created by HAO WANG on 11/4/13.
//  Copyright (c) 2013 HAO WANG. All rights reserved.
//

#import "YDPlayer.h"

@interface YDPlayerView : UIView

@property (nonatomic) AVPlayer *player;

@end

@implementation YDPlayerView

+ (Class)layerClass {
    return [AVPlayerLayer class];
}
- (AVPlayer*)player {
    return [(AVPlayerLayer *)[self layer] player];
}
- (void)setPlayer:(AVPlayer *)player {
    [(AVPlayerLayer *)[self layer] setPlayer:player];
}
@end

@interface YDPlayer ()
{
    CMTime _audioDelay;
}

@property (nonatomic, strong) YDPlayerView *playerView;
@property (nonatomic, strong) AVPlayerItem *playerItem;
@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, strong) AVPlayer *audioPlayer;

@end

@implementation YDPlayer

static const NSString *ItemStatusContext = @"ItemStatusContext";

- (void)placeEmbeddedAudioAdjustableVideoOnView:(UIView *)view WithSize:(CGSize)size andVideoPath:(NSString *)videoPath
{
    _audioDelay = kCMTimeZero;
    
    AVURLAsset *asset;
    
    NSURL *fileURL = [NSURL fileURLWithPath:videoPath];
    NSDictionary *options = @{ AVURLAssetPreferPreciseDurationAndTimingKey : @YES };
    asset = [AVURLAsset URLAssetWithURL:fileURL options:options];
    
    //create the video player
    AVMutableComposition *mutableVideoComposition = [AVMutableComposition composition];
    NSArray *videoTracks = [self videoTracksFromAsset:asset];
    [self addVideoTracks:videoTracks toComposition:mutableVideoComposition];
    [self placeEmbeddedVideoOnView:view WithSize:size avComposition:mutableVideoComposition];
    
    //create the audio player
    AVMutableComposition *mutableAudioComposition = [AVMutableComposition composition];
    NSArray *audioTracks = [self audioTracksFromAsset:asset];
    [self addAudioTracks:audioTracks toComposition:mutableAudioComposition];
    
    AVPlayerItem* audioItem = [AVPlayerItem playerItemWithAsset:mutableAudioComposition];
    self.audioPlayer = [[AVPlayer alloc]initWithPlayerItem:audioItem];
    
    
}


- (void)placeEmbeddedVideoOnView:(UIView *)view WithSize:(CGSize)size andVideoPath:(NSString *)videoPath
{
    
    _audioDelay = kCMTimeZero;
    
    AVURLAsset *asset;
    
    NSURL *fileURL = [NSURL fileURLWithPath:videoPath];
    NSDictionary *options = @{ AVURLAssetPreferPreciseDurationAndTimingKey : @YES };
    asset = [AVURLAsset URLAssetWithURL:fileURL options:options];
    
    NSString *tracksKey = @"tracks";
    
    [asset loadValuesAsynchronouslyForKeys:@[tracksKey] completionHandler:
     ^{
         dispatch_async(dispatch_get_main_queue(),
                        ^{
                            NSError *error;
                            AVKeyValueStatus status = [asset statusOfValueForKey:tracksKey error:&error];
                            
                            __weak YDPlayer *weakSelf = self;
                            if (status == AVKeyValueStatusLoaded) {
                                self.playerItem = [AVPlayerItem playerItemWithAsset:asset];
                                self.player = [[AVPlayer alloc]initWithPlayerItem:self.playerItem];
                                self.player.allowsExternalPlayback = YES;
                                //update progress every 1/2 second
                                [self.player addPeriodicTimeObserverForInterval:CMTimeMake(5, 10) queue:dispatch_get_main_queue() usingBlock:^(CMTime time)
                                {
                                    if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(didStartPlayer:)]) {
                                        [weakSelf.delegate updateCurrentPlayerTime:weakSelf.player.currentTime];
                                    }
                                }];
                                self.playerView = [[YDPlayerView alloc]initWithFrame:CGRectMake(0, 0, size.width, size.height)];
                                [self.playerView setPlayer:self.player];
                                [view addSubview:self.playerView];
                                
                                [self.playerItem addObserver:self forKeyPath:@"status"
                                                     options:0 context:&ItemStatusContext];
                                [[NSNotificationCenter defaultCenter] addObserver:self
                                                                         selector:@selector(playerItemDidReachEnd:)
                                                                             name:AVPlayerItemDidPlayToEndTimeNotification
                                                                           object:self.playerItem];
                                
                                [self addTapGestureReceiver];
                                
                            }
                            else {
                                // You should deal with the error appropriately.
                                NSLog(@"The asset's tracks were not loaded:\n%@", [error localizedDescription]);
                            }
                        });
     }];
}


- (void)placeEmbeddedVideoOnView:(UIView *)view WithSize:(CGSize)size avComposition:( AVMutableComposition *)composition
{
    _audioDelay = kCMTimeZero;
    
    self.playerItem = [AVPlayerItem playerItemWithAsset:composition];
    //self.playerItem.videoComposition = videoComposition;
    self.player = [[AVPlayer alloc]initWithPlayerItem:self.playerItem];
    self.player.allowsExternalPlayback = YES;
    
    //update progress every 1/2 second
    __weak YDPlayer *weakSelf = self;
    [self.player addPeriodicTimeObserverForInterval:CMTimeMake(5, 10) queue:dispatch_get_main_queue() usingBlock:^(CMTime time)
     {
         if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(didStartPlayer:)]) {
             [weakSelf.delegate updateCurrentPlayerTime:weakSelf.player.currentTime];
         }
     }];
    
    self.playerView = [[YDPlayerView alloc]initWithFrame:CGRectMake(0, 0, size.width, size.height)];
    [self.playerView setPlayer:self.player];
    [view addSubview:self.playerView];
    
    [self.playerItem addObserver:self forKeyPath:@"status"
                         options:0 context:&ItemStatusContext];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playerItemDidReachEnd:)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
                                               object:self.playerItem];
    
    [self addTapGestureReceiver];
}

#pragma mark - separate video and audio
- (NSArray *)videoTracksFromAsset:(AVAsset *)asset
{
    return [asset tracksWithMediaType:AVMediaTypeVideo];
}

- (NSArray *)audioTracksFromAsset:(AVAsset *)asset
{
    return [asset tracksWithMediaType:AVMediaTypeAudio];
}

- (void)addVideoTracks:(NSArray *)tracks toComposition:(AVMutableComposition *)mutableComposition
{
    for (AVAssetTrack *videoAssetTrack in tracks)
    {
        // Create the video composition track.
        AVMutableCompositionTrack *mutableCompositionVideoTrack = [mutableComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
        [mutableCompositionVideoTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero,videoAssetTrack.timeRange.duration) ofTrack:videoAssetTrack atTime:kCMTimeZero error:nil];
    }
}

- (void)addAudioTracks:(NSArray *)tracks toComposition:(AVMutableComposition *)mutableComposition
{
    for (AVAssetTrack *audioAssetTrack in tracks)
    {
        // Create the video composition track.
        AVMutableCompositionTrack *mutableCompositionAudioTrack = [mutableComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
        [mutableCompositionAudioTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero,audioAssetTrack.timeRange.duration) ofTrack:audioAssetTrack atTime:kCMTimeZero error:nil];
    }
}

#pragma mark - player screen transition
- (void)resizePlayerViewToFrame:(CGRect)frame animated:(BOOL)animated
{
    if (animated) {
        [UIView animateWithDuration:0.3f animations:^{
            [self resizePlayerViewToFrame:frame];
        } completion:nil];
    }else{
        [self resizePlayerViewToFrame:frame];
    }
}

- (void)resizePlayerViewToFrame:(CGRect)frame
{
    self.playerView.frame = frame;
}

#pragma mark - initialize guesture controls
- (void)addTapGestureReceiver
{
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapped:)];
    [self.playerView addGestureRecognizer:tapGestureRecognizer];
}

- (void)tapped:(UITapGestureRecognizer *)tapGestureRecognizer
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(playerViewTapped:)]) {
        [self.delegate playerViewTapped:self];
    }
}


#pragma mark - controls
- (void)start
{
    [self rewind];
    [self.player play];
    [self.audioPlayer play];
    if (self.player.rate > 0 ) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(didStartPlayer:)]) {
            [self.delegate didStartPlayer:self];
        }
    }
}

- (void)pause
{
    [self.player pause];
    [self.audioPlayer pause];

    if (self.player.rate == 0 ) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(didPlausPlayer:)]) {
            [self.delegate didPlausPlayer:self];
        }
    }
}

- (void)resume
{
    [self.player play];
    [self.audioPlayer play];
    if (self.player.rate > 0 ) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(didStartPlayer:)]) {
            [self.delegate didStartPlayer:self];
        }
    }
}

- (void)rewind
{
    [self.player seekToTime:kCMTimeZero];
}

- (void)addAudioOffset:(CMTime)delay
{
    _audioDelay = delay;
    [self.audioPlayer seekToTime:CMTimeAdd(self.player.currentTime, _audioDelay)];
}

- (void)seekToTime:(CMTime)time
{
    [self.player seekToTime:time];
    [self.audioPlayer seekToTime:CMTimeAdd(time, _audioDelay)];
}

- (CMTime)duration
{
    return self.player.currentItem.duration;
}

#pragma mark - VSVideoPlayerControlViewDelegate
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object
                        change:(NSDictionary *)change context:(void *)context
{
    
    if (context == &ItemStatusContext) {
        dispatch_async(dispatch_get_main_queue(),
                       ^{
                           if (self.player.currentItem.status == AVPlayerItemStatusReadyToPlay) {
                               if (self.delegate && [self.delegate respondsToSelector:@selector(didBecomeReadyToPlayForPlayItem:)]) {
                                   [self.delegate didBecomeReadyToPlayForPlayItem:self.player.currentItem];
                               }
                           }
                       });
        return;
    }
    [super observeValueForKeyPath:keyPath ofObject:object
                           change:change context:context];
    return;
}

- (void)playerItemDidReachEnd:(NSNotification *)notification
{
    [self rewind];
    [self pause];
}

- (void)dealloc
{
    [self.playerView removeFromSuperview];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.playerItem removeObserver:self forKeyPath:@"status"];
    [self.player cancelPendingPrerolls];
    [self.audioPlayer cancelPendingPrerolls];
}

@end
