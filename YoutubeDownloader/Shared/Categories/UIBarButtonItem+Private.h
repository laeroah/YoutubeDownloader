//
//  UIBarButtonItem+Private.h
//  YoutubeDownloader
//
//  Created by Hao Wang  on 13-11-4.
//  Copyright (c) 2013年 HAO WANG. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIBarButtonItem (Private)

+ (UIBarButtonItem *)barButtonItemWithTitle:(NSString *)title target:(id)target action:(SEL)action color:(UIColor *)color;
+ (UIBarButtonItem *)barButtonItemWithImageInCustomView:(UIImage *)image target:(id)target action:(SEL)action;

@end
