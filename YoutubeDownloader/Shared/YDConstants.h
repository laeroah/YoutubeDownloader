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
#define NAVIGATINO_BUTTON_TINT_COLOR               [UIColor colorWithRed:21/255.0f green:158/255.0f blue:209/255.0f alpha:1.0]
#define BAR_TINT_COLOR                             [UIColor colorWithRed:47/255.0f green:47/255.0f blue:47/255.0f alpha:1.0]
#define MEDIA_LIBRARY_THUMBNAIL_WIDTH_IPHONE                158.0f
#define MEDIA_LIBRARY_THUMBNAIL_WIDTH_IPAD_PORTRAIT         384.0f
#define MEDIA_LIBRARY_THUMBNAIL_WIDTH_IPAD_LANDSCAPE        512.0f
#define MEDIA_LIBRARY_ROW_HEIGHT                   100.0f
#define DEVICE_SPACE_OTHER_APP_BAR_COLOR           [UIColor colorWithRed:32/255.0f green:32/255.0f blue:32/255.0f alpha:1.0]
#define DEVICE_SPACE_THIS_APP_BAR_COLOR            [UIColor colorWithRed:4/255.0f green:174/255.0f blue:218/255.0f alpha:1.0]
#define DEVICE_SPACE_AVAILABLE_BAR_COLOR           [UIColor colorWithRed:241/255.0f green:242/255.0f blue:242/255.0f alpha:1.0]

#pragma mark - Persistent User Defaults
#define IS_RETURNING_USER_KEY                       @"IS_RETURNING_USER_KEY"

#pragma mark - Google Analytics

#define kDownloadTaskStatusChangeNotification       @"kDownloadTaskStatusChangeNotification"

#define kYoutubeDownloadErrorDomain @"YDErrorDomain"

#define kYDErrorInvalidUrl 1000

