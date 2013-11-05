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

@property (nonatomic, strong) YDPlayerView *playerView;
@property (nonatomic, strong) AVPlayerItem *playerItem;
@property (nonatomic, strong) AVPlayer *player;

@end

@implementation YDPlayer

static const NSString *ItemStatusContext = @"ItemStatusContext";

- (void)placeEmbeddedVideoOnView:(UIView *)view WithSize:(CGSize)size andVideoPath:(NSString *)videoPath
{
    NSURL * fileURL = [NSURL URLWithString:videoPath];
    
    AVURLAsset *asset;
    
    fileURL = [NSURL fileURLWithPath:videoPath];
    asset = [AVURLAsset URLAssetWithURL:fileURL options:nil];
    
    NSString *tracksKey = @"tracks";
    
    [asset loadValuesAsynchronouslyForKeys:@[tracksKey] completionHandler:
     ^{
         dispatch_async(dispatch_get_main_queue(),
                        ^{
                            NSError *error;
                            AVKeyValueStatus status = [asset statusOfValueForKey:tracksKey error:&error];
                            
                            if (status == AVKeyValueStatusLoaded) {
                                self.playerItem = [AVPlayerItem playerItemWithAsset:asset];
                                self.player = [[AVPlayer alloc]initWithPlayerItem:self.playerItem];
                                self.playerView = [[YDPlayerView alloc]initWithFrame:CGRectMake(0, 0, size.width, size.height)];
                                [self.playerView setPlayer:self.player];
                                [view addSubview:self.playerView];
                                
                                [self.playerItem addObserver:self forKeyPath:@"status"
                                                     options:0 context:&ItemStatusContext];
                                [[NSNotificationCenter defaultCenter] addObserver:self
                                                                         selector:@selector(playerItemDidReachEnd:)
                                                                             name:AVPlayerItemDidPlayToEndTimeNotification
                                                                           object:self.playerItem];
                                
                                
                            }
                            else {
                                // You should deal with the error appropriately.
                                NSLog(@"The asset's tracks were not loaded:\n%@", [error localizedDescription]);
                            }
                        });
     }];
}


- (void)placeEmbeddedVideoOnView:(UIView *)view WithSize:(CGSize)size avComposition:( AVMutableComposition *)composition videoComposition:(AVMutableVideoComposition*)videoComposition
{
    self.playerItem = [AVPlayerItem playerItemWithAsset:composition];
    self.playerItem.videoComposition = videoComposition;
    self.player = [[AVPlayer alloc]initWithPlayerItem:self.playerItem];
    self.playerView = [[YDPlayerView alloc]initWithFrame:CGRectMake(0, 0, size.width, size.height)];
    [self.playerView setPlayer:self.player];
    [view addSubview:self.playerView];
    
    [self.playerItem addObserver:self forKeyPath:@"status"
                         options:0 context:&ItemStatusContext];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playerItemDidReachEnd:)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
                                               object:self.playerItem];
    
}

- (void)playerItemDidReachEnd:(NSNotification *)notification {
    [self.player seekToTime:kCMTimeZero];
}

@end
