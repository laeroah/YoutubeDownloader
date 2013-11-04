//
//  YDViewController.m
//  YoutubeDownloader
//
//  Created by HAO WANG on 11/3/13.
//  Copyright (c) 2013 HAO WANG. All rights reserved.
//

#import "YDViewController.h"

@interface YDViewController ()

@end

@implementation YDViewController

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
    
    UIButton *startVideoPlayerButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    
    startVideoPlayerButton.frame = CGRectMake(0,0, 100, 40);
    
    [self.view addSubview:startVideoPlayerButton];
    
    [startVideoPlayerButton setTitle:@"Show Player" forState:UIControlStateNormal];
    
    startVideoPlayerButton.center = self.view.center;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
