//
//  YDBaseViewController.m
//  YoutubeDownloader
//
//  Created by Hao Wang  on 13-11-4.
//  Copyright (c) 2013年 HAO WANG. All rights reserved.
//

#import "YDBaseViewController.h"
#import "YDConstants.h"
#import "YDDeviceUtility.h"

@interface YDBaseViewController ()
{
    UIView *_navigationBarControlAreaView;
}

@end

@implementation YDBaseViewController

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
    [self colorNavigationBar];
    
	// Do any additional setup after loading the view.
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    [self addButtonsToCenterNavigationBar];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - navigation bar and its style
// add the buttons inside leftNavigationButtons to left side of the navigation bar
// add the buttons inside rightNavigationButtons to right side of the navigation bar
- (void)addButtonsToCenterNavigationBar
{
    if (!self.navigationButtons || [self.navigationButtons count] <= 0) return;
    
    _navigationBarControlAreaView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, NAVIGATION_BUTTON_HEIGHT)];
    
    for (UIButton *controlButton in self.navigationButtons)
    {
        controlButton.frame = CGRectMake(NAVIGATION_BUTTON_OFFSET, 0, NAVIGATION_BUTTON_WIDTH, NAVIGATION_BUTTON_HEIGHT);
        [_navigationBarControlAreaView addSubview:controlButton];
    }
    
    [self adjustNavigationButtonsAnimated:NO];
    
    self.navigationItem.titleView = _navigationBarControlAreaView;
}

- (void)colorNavigationBar
{
    if ([YDDeviceUtility isIOS7orAbove]) {
        self.navigationController.navigationBar.barTintColor = BAR_TINT_COLOR;
        self.navigationController.navigationBar.translucent = NO;
        
    }else {
        self.navigationController.navigationBar.tintColor = BAR_TINT_COLOR;
    }
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

// adjust navigation buttons based on orientation and device
- (void)adjustNavigationButtonsAnimated:(BOOL)animated
{
    if (animated) {
        [UIView animateWithDuration:0.5f animations:^{
            [self adjustNavigationButtons];
        } completion:nil];
    }else{
        [self adjustNavigationButtons];
    }
}

- (void)adjustNavigationButtons
{
    CGFloat controlViewWidth = NAVIGATION_BUTTON_OFFSET;
    CGFloat buttonSpan, buttonSpacing;
    
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    
    if ([YDDeviceUtility isIPad])
    {
        if (UIInterfaceOrientationIsPortrait(orientation))
        {
            buttonSpacing = 208.0f;
        }
        else
        {
            buttonSpacing = 294.0f;
        }
    } else
    {
        if (UIInterfaceOrientationIsPortrait(orientation))
        {
            buttonSpacing = 59.0f;
        }
        else
        {
            buttonSpacing = 142.0f;
        }
    }
    
    for (UIButton *controlButton in self.navigationButtons)
    {
        CGRect controlButtonFrame = controlButton.frame;
        controlButton.frame = CGRectMake(controlViewWidth, controlButtonFrame.origin.y, NAVIGATION_BUTTON_WIDTH, NAVIGATION_BUTTON_HEIGHT);
        buttonSpan = NAVIGATION_BUTTON_WIDTH + buttonSpacing;
        controlViewWidth += buttonSpan;
    }
    
    CGRect controlAreaViewFrame = _navigationBarControlAreaView.frame;
    _navigationBarControlAreaView.frame = CGRectMake(controlAreaViewFrame.origin.x, controlAreaViewFrame.origin.y, controlViewWidth, controlAreaViewFrame.size.height);
}

#pragma mark - orienation change
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self adjustNavigationButtonsAnimated:YES];
}

@end
