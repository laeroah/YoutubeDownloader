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
#import "MBProgressHUD.h"

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

- (void)viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
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


- (void)showToastMessage:(NSString *)msg hideAfterDelay:(NSTimeInterval)seconds
{
    [self showToastMessage:msg hideAfterDelay:seconds withProgress:NO];
}

- (void)showToastMessage:(NSString *)msg hideAfterDelay:(NSTimeInterval)seconds withProgress:(BOOL)useProgress
{
    [self showToastMessage:msg hideAfterDelay:seconds withProgress:useProgress backgroundColor:nil textColor:nil];
}

- (void)showToastMessage:(NSString *)msg
          hideAfterDelay:(NSTimeInterval)seconds
            withProgress:(BOOL)useProgress
         backgroundColor:(UIColor *)backgroundColor
               textColor:(UIColor *)textColor
{
    dispatch_async(dispatch_get_main_queue(), ^{
        MBProgressHUD *overlayMessageView = [[MBProgressHUD alloc] initWithView:self.view];
        overlayMessageView.removeFromSuperViewOnHide = YES;
        overlayMessageView.userInteractionEnabled = NO;
        
        if (useProgress)
        {
            overlayMessageView.mode = MBProgressHUDModeIndeterminate;
        }
        else
        {
            overlayMessageView.mode = MBProgressHUDModeText;
        }
        [self.view addSubview:overlayMessageView];
        [self.view bringSubviewToFront:overlayMessageView];
        
        overlayMessageView.yOffset = (![YDDeviceUtility isIPad] && ![YDDeviceUtility isIPhone5]) ? - 80.0f : -30.0f;
        
        
        if ([msg length] < 20) {
            overlayMessageView.labelText = msg;
        }else{
            overlayMessageView.detailsLabelText = msg;
        }
        
        if (backgroundColor && textColor) {
            overlayMessageView.label.textColor = backgroundColor;
            overlayMessageView.detailsLabel.textColor = backgroundColor;
            overlayMessageView.color = textColor;
        }
        
        [overlayMessageView show:YES];
        
        if (seconds > 0.0) {
            [overlayMessageView hide:YES afterDelay:seconds];
        }
    });
}

- (void)dismissToastMessage
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    });
}

- (void)dismissAllToastMessages
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    });
}

- (void)disableBarButton
{
    self.navigationItem.rightBarButtonItem.enabled = NO;
    self.navigationItem.leftBarButtonItem.enabled = NO;
}

- (void)enableBarButton
{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.navigationItem.rightBarButtonItem.enabled = YES;
        self.navigationItem.leftBarButtonItem.enabled = YES;
    });
}

// This allows the keyboard to hide when using the UIModalPresentationFormSheet style in iPad
- (BOOL)disablesAutomaticKeyboardDismissal
{
    return NO;
}


@end
