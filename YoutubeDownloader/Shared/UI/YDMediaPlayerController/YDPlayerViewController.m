//
//  YDPlayerViewController.m
//  VideoPlayerSample
//
//  Created by HAO WANG on 11/4/13.
//  Copyright (c) 2013 HAO WANG. All rights reserved.
//

#import "YDPlayerViewController.h"
#import "YDBaseNavigationViewController.h"
#import "YDConstants.h"
#import "YDDeviceUtility.h"
#import "YDAnalyticManager.h"
#import <MediaPlayer/MediaPlayer.h>

@interface YDPlayerViewController ()
{
    NSTimer *_chromeTimer;
}

@property (nonatomic, weak) UIViewController *containerViewController;
@property (weak, nonatomic) IBOutlet UIButton *playPauseButton;
@property (weak, nonatomic) IBOutlet UIView *playerControlBarView;
@property (weak, nonatomic) IBOutlet UIView *playerContainerView;
@property (weak, nonatomic) IBOutlet UISlider *playerProgressBar;
@property (weak, nonatomic) IBOutlet UILabel *currentProgressTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *remainingProgressTimeLabel;
@property (weak, nonatomic) IBOutlet UIView *playerSettingContainerView;
@property (weak, nonatomic) IBOutlet UISlider *brightnessSlider;
@property (weak, nonatomic) IBOutlet UISlider *audioDelaySlider;
@property (weak, nonatomic) IBOutlet UILabel *audioOffsetLabel;
@property (weak, nonatomic) IBOutlet UIView *airplayButtonView;

@property (assign, nonatomic) BOOL isPlayingWhenEnterBackground;
@end

@implementation YDPlayerViewController

- (void)presentPlayerViewControllerFromViewController:(UIViewController *)containerViewController
{
    YDBaseNavigationViewController *navigationViewController = [[YDBaseNavigationViewController alloc]initWithRootViewController:self];
    self.containerViewController = containerViewController;
    [containerViewController presentViewController:navigationViewController animated:YES completion:nil];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setNeedsStatusBarAppearanceUpdate];
    
    self.view.backgroundColor = [UIColor blackColor];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"ic_backButton"] style:UIBarButtonItemStylePlain target:self action:@selector(minize)];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"ic_playerSettings"] style:UIBarButtonItemStylePlain target:self action:@selector(showPlayerSettings)];
    
    self.navigationItem.leftBarButtonItem.tintColor = NAVIGATINO_BUTTON_TINT_COLOR;
    self.navigationItem.rightBarButtonItem.tintColor = NAVIGATINO_BUTTON_TINT_COLOR;
    
    _chromeTimer = [NSTimer scheduledTimerWithTimeInterval:3.0f target:self selector:@selector(hideChrome) userInfo:nil repeats:NO];
    
    self.brightnessSlider.value = [UIScreen mainScreen].brightness;
    
    [self colorNavigationBar];
    
    [self layoutAirplayButton];
    
    if(&UIApplicationWillResignActiveNotification != nil)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willEnterBackground) name:UIApplicationWillResignActiveNotification object:nil];
    }
    
    // On iOS 4.0+ only, listen for foreground notification
    if(&UIApplicationDidBecomeActiveNotification != nil)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didEnterForeGround) name:UIApplicationDidBecomeActiveNotification object:nil];
    }
}

- (void)willEnterBackground
{
    self.isPlayingWhenEnterBackground = NO;
    if (_player && _player.isPlaying)
    {
        [_player pause];
        self.isPlayingWhenEnterBackground = YES;
    }
}

- (void)didEnterForeGround
{
    if (_player && self.isPlayingWhenEnterBackground) {
        [_player resume];
    }
    self.isPlayingWhenEnterBackground = NO;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
    if (_chromeTimer) {
        [_chromeTimer invalidate];
    }
}

- (void)layoutAirplayButton
{
    MPVolumeView *volumeView = [ [MPVolumeView alloc] init] ;
    [volumeView setShowsVolumeSlider:NO];
    [volumeView sizeToFit];
    [self.airplayButtonView addSubview:volumeView];
}

- (void)colorNavigationBar
{
    if ([YDDeviceUtility isIOS7orAbove]) {
        self.navigationController.navigationBar.barTintColor = BAR_TINT_COLOR;
        self.navigationController.navigationBar.translucent = YES;
        
    }else {
        self.navigationController.navigationBar.tintColor = BAR_TINT_COLOR;
    }
}

- (UIStatusBarStyle) preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

#pragma mark - helper
- (NSString *)formattedTimeStringFromTime:(CMTime)time
{
    Float64 dur = CMTimeGetSeconds(time);
    int min = dur/60;
    int sec = (int)dur%60;
    
    return [NSString stringWithFormat:@"%.2d:%.2d", min, sec];
}

#pragma mark - chrome hide/show
- (void)hideChrome
{
    [UIView animateWithDuration:0.3f animations:^{
        self.playerControlBarView.alpha = 0.0f;
    }];
    
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
}

- (void)showChrome
{
    [UIView animateWithDuration:0.3f animations:^{
        self.playerControlBarView.alpha = 1.0f;
    }];
    //start the chrome timer
    if (_chromeTimer) {
        [_chromeTimer invalidate];
    }
    _chromeTimer = [NSTimer scheduledTimerWithTimeInterval:3.0f target:self selector:@selector(hideChrome) userInfo:nil repeats:NO];

    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
}

#pragma mark - player control
- (IBAction)playPauseButtonTapped:(id)sender {
    if (self.playPauseButton.selected) { //selected == paused
        [self.player pause];
    }else{
        [self.player resume];
    }
}

- (IBAction)playerProgressBarValueChanged:(id)sender {
    //seek to the time
    Float64 dur = CMTimeGetSeconds([self.player duration]);
    Float64 seekToProgress = self.playerProgressBar.value * dur;
    [self.player seekToTime:CMTimeMakeWithSeconds(seekToProgress, 1)];
}

#pragma mark - settings control
- (IBAction)closeSettingsButtonTapped:(id)sender {
    [self hidePlayerSettings];
}

- (IBAction)brightnessSliderValueChanged:(id)sender {
    [UIScreen mainScreen].brightness = self.brightnessSlider.value;
    [[YDAnalyticManager sharedInstance]trackWithCategory:EVENT_CATEGORY_VIDEO_PLAYER_CONTROL action:EVENT_ACTION_ADJUST_PLAYER_BRIGHTNESS label:nil value:nil];
}

- (IBAction)audioDelaySliderValueChanged:(id)sender {
    [[YDAnalyticManager sharedInstance]trackWithCategory:EVENT_CATEGORY_VIDEO_PLAYER_CONTROL action:EVENT_ACTION_ADJUST_AUDIO_DELAY label:nil value:nil];
    CGFloat offsetValue = self.audioDelaySlider.value;
    NSString *audioLabelTextFormat = NSLocalizedString(@"Audio Offset: %.2f", @"the label for audio offset");
    self.audioOffsetLabel.text = [NSString stringWithFormat:audioLabelTextFormat, offsetValue];
    
    offsetValue *= 100;
    CMTime offset = CMTimeMake(offsetValue, 100);
    [self.player addAudioOffset:offset];
    
}

//- (IBAction)airplayButtonTapped:(id)sender {
//    MPVolumeView *volumeView = [ [MPVolumeView alloc] init] ;
//    [volumeView setShowsVolumeSlider:NO];
//    [volumeView sizeToFit];
//    [self.view addSubview:volumeView];
//}

#pragma mark - player initialization
- (YDPlayer *)player
{
    if (!_player){
        _player = [[YDPlayer alloc]init];
        _player.delegate = self;
    }
    return _player;
}

#pragma mark - YDPlayerDelegate
- (void)playerViewTapped:(YDPlayer *)player
{
    if (!self.navigationController.navigationBarHidden)
    {
        [self hideChrome];
    }else{
        [self showChrome];
    }
}

- (void)didPlausPlayer:(YDPlayer *)player
{
    self.playPauseButton.selected = NO;
}

- (void)didStartPlayer:(YDPlayer *)player
{
    self.playPauseButton.selected = YES;
}

- (void)didBecomeReadyToPlayForPlayItem:(AVPlayerItem *)playerItem
{
    CMTime duration = playerItem.duration;
    NSString *totalDurationString = [self formattedTimeStringFromTime:duration];
    
    self.remainingProgressTimeLabel.text = totalDurationString;
}

- (void)updateCurrentPlayerTime:(CMTime)time
{
    NSString *currentTimeString = [self formattedTimeStringFromTime:time];
    self.currentProgressTimeLabel.text = currentTimeString;
    
    Float64 dur = CMTimeGetSeconds([self.player duration]);
    Float64 progress = CMTimeGetSeconds(time);
    
    [self.playerProgressBar setValue:progress/dur animated:YES];
}

#pragma mark - public interface
- (void)playLocalVideoWithPath:(NSString *)videoPath
{
    CGSize playerSize = CGSizeMake(self.view.frame.size.width, self.view.frame.size.height);
    UIInterfaceOrientation currentOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    if (UIDeviceOrientationIsLandscape(currentOrientation))
    {
        playerSize.width = self.view.frame.size.height;
        playerSize.height = self.view.frame.size.width;
    }
    [self.player placeEmbeddedAudioAdjustableVideoOnView:self.playerContainerView WithSize:playerSize andVideoPath:videoPath];
    
}

#pragma mark - Full Screen Toggles
- (void)minize
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Player Settings
- (void)showPlayerSettings
{
    [UIView animateWithDuration:0.2f animations:^{
        self.playerSettingContainerView.alpha = 1.0f;
    } completion:nil];
}

- (void)hidePlayerSettings
{
    [UIView animateWithDuration:0.2f animations:^{
        self.playerSettingContainerView.alpha = 0.0f;
    } completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    if (_chromeTimer) {
        [_chromeTimer invalidate];
    }
}

#pragma mark - rotation handling

 - (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    UIInterfaceOrientation currentOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    if (UIDeviceOrientationIsLandscape(currentOrientation))
    {
    }
    [self.player resizePlayerViewToFrame:self.view.frame animated:YES];
}

@end
