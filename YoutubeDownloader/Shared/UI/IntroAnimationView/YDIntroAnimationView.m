//
//  YDIntroAnimationView.m
//  YoutubeDownloader
//
//  Created by HAO WANG on 1/4/14.
//  Copyright (c) 2014 HAO WANG. All rights reserved.
//

#import "YDIntroAnimationView.h"

typedef void (^IntroAnimationCompletionBlock) (void);

@interface YDIntroAnimationView ()

@property (nonatomic, retain) UIImageView *downloadArrow;
@property (nonatomic, retain) UIImageView *playArrow;
@property (nonatomic, strong) IntroAnimationCompletionBlock complete;

@end

@implementation YDIntroAnimationView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = [UIColor whiteColor];
        self.downloadArrow = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"redTriangle"]];
        self.playArrow = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"blueTriangle"]];
        self.downloadArrow.alpha = 0.0f;
        self.playArrow.alpha = 0.0f;
        
    }
    return self;
}

- (void)presentOnView:(UIViewController *)viewController withCompletion:(void (^)(void))complete
{
    [viewController.view addSubview:self];
    self.complete = complete;
    [self addSubview:self.downloadArrow];
    [self addSubview:self.playArrow];
    CGRect rightArrowFrame = self.playArrow.frame;
    rightArrowFrame.origin.y = self.frame.size.height/2 - rightArrowFrame.size.height;
    self.playArrow.frame = rightArrowFrame;
    CGRect downArrowFrame = self.downloadArrow.frame;
    downArrowFrame.origin.x = (self.frame.size.width - downArrowFrame.size.width)/2;
    self.downloadArrow.frame = downArrowFrame;
    [self performAnimationWithCompletion:self.complete];
}

- (void)performAnimationWithCompletion:(void(^)(void))complete
{
    [self performDownloadArrowAnimationWithCompletion:^{
        [self performRightArrowAnimationWithCompletion:^{
            [self performFadeOutAnimationWithCompletion:complete];
        }];
    }];
}

- (void)performDownloadArrowAnimationWithCompletion:(void(^)(void))complete
{
    CGRect downArrowFrame = self.downloadArrow.frame;
    downArrowFrame.origin.x = (self.frame.size.width - downArrowFrame.size.width)/2;
    self.downloadArrow.frame = downArrowFrame;
    downArrowFrame.origin.y = self.frame.size.height/2 - downArrowFrame.size.height;
    [UIView animateWithDuration:1 animations:^{
        self.downloadArrow.frame = downArrowFrame;
        self.downloadArrow.alpha = 1.0f;
    } completion:^(BOOL finished) {
        complete();
    }];
}

- (void)performRightArrowAnimationWithCompletion:(void(^)(void))complete
{
    CGRect rightArrowFrame = self.playArrow.frame;
    rightArrowFrame.origin.y = self.frame.size.height/2 - rightArrowFrame.size.height;
    rightArrowFrame.origin.x = self.frame.size.width/2;
    [UIView animateWithDuration:1 animations:^{
        self.playArrow.frame = rightArrowFrame;
        self.playArrow.alpha = 0.8f;
    } completion:^(BOOL finished) {
        complete();
    }];
}

- (void)performFadeOutAnimationWithCompletion:(void(^)(void))complete
{
    [UIView animateWithDuration:1 animations:^{
        self.alpha = 0.0f;
        self.transform = CGAffineTransformMakeScale(1.5,1.5);
    } completion:^(BOOL finished) {
        complete();
    }];;
}

@end
