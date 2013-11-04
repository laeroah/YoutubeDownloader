//
//  UIBarButtonItem+Private.m
//  YoutubeDownloader
//
//  Created by Hao Wang  on 13-11-4.
//  Copyright (c) 2013年 HAO WANG. All rights reserved.
//

#import "UIBarButtonItem+Private.h"
#import "YDConstants.h"
#import "YDFontUtility.h"

@implementation UIBarButtonItem (Private)

+ (UIBarButtonItem *)barButtonItemWithTitle:(NSString *)title target:(id)target action:(SEL)action color:(UIColor *)color
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.titleLabel.font = [YDFontUtility helveticaNeueMediumFontOfSize:13];
    button.titleLabel.textAlignment = NSTextAlignmentCenter;
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:color forState:UIControlStateNormal];
    [button setTitleColor:[UIColor colorWithWhite:1 alpha:0.2] forState:UIControlStateHighlighted];
    [button setTitleColor:[UIColor colorWithWhite:1 alpha:0.2] forState:UIControlStateDisabled];
    [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    
    CGSize titleSize = [title sizeWithFont:button.titleLabel.font];
    if (!SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0"))
    {
        titleSize = CGSizeMake(titleSize.width + 10, titleSize.height);
    }
    button.frame = CGRectMake(0, 0, titleSize.width, titleSize.height);
    
    return [[UIBarButtonItem alloc] initWithCustomView:button];
}

+ (UIBarButtonItem *)barButtonItemWithImageInCustomView:(UIImage *)image target:(id)target action:(SEL)action
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    CGFloat buttonSize = 24;
    if (!SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0"))
    {
        buttonSize = 32;
    }
    button.frame = CGRectMake(0, 0, buttonSize, buttonSize);
    [button setImage:image forState:UIControlStateNormal];
    [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    return [[UIBarButtonItem alloc] initWithCustomView:button];
}

@end