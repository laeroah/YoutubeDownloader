//
//  YDConstants.h
//  YoutubeDownloader
//
//  Created by Hao Wang  on 13-11-4.
//  Copyright (c) 2013年 HAO WANG. All rights reserved.
//
#import "AppDelegate.h"

#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v) ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v) ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)


#define APP_DELEGATE (AppDelegate *)[UIApplication sharedApplication].delegate


#pragma mark - UI constants
#define NAVIGATION_BUTTON_WIDTH                    32.0f
#define NAVIGATION_BUTTON_HEIGHT                   32.0f
#define NAVIGATION_BUTTON_OFFSET                   0.0f
#define BAR_TINT_COLOR                             [UIColor colorWithRed:47/255.0f green:47/255.0f blue:47/255.0f alpha:1.0]
#define MEDIA_LIBRARY_THUMBNAIL_WIDTH              158.0f
#define MEDIA_LIBRARY_ROW_HEIGHT                   100.0f