//
//  YDIntroAnimationView.h
//  YoutubeDownloader
//
//  Created by HAO WANG on 1/4/14.
//  Copyright (c) 2014 HAO WANG. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YDIntroAnimationView : UIView

- (void)presentOnView:(UIViewController *)viewController withCompletion:(void (^)(void))complete;

@end

