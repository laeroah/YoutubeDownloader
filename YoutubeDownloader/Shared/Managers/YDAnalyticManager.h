//
//  YDAnalyticManager.h
//  YoutubeDownloader
//
//  Created by HAO WANG on 11/21/13.
//  Copyright (c) 2013 HAO WANG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GAI.h"

// event categories
static NSString *EVENT_CATEGORY_SEARCH_VIEW = @"youtube webview events";
static NSString *EVENT_CATEGORY_LIBRARY_VIEW = @"library view events";
static NSString *EVENT_CATEGORY_VIDEO_DOWNLOAD = @"video download events";
static NSString *EVENT_CATEGORY_RESULT_FEEDBACK = @"result feedback events";
static NSString *EVENT_CATEGORY_VIDEO_PLAYER_CONTROL = @"video player control events";

// event actions
static NSString *EVENT_ACTION_NAVIGATION_BACK = @"go back";
static NSString *EVENT_ACTION_NAVIGATION_LIBRARY = @"go to library";
static NSString *EVENT_ACTION_NAVIGATION_HOME = @"webview go home";
static NSString *EVENT_ACTION_NAVIGATION_DOWNLOAD = @"try download video";
static NSString *EVENT_ACTION_USE_THUMBNAILVIEW = @"use thumbnail layout";
static NSString *EVENT_ACTION_SEARCH_LIBRARY = @"search in library";
static NSString *EVENT_ACTION_ENTER_EDIT_LIBRARY = @"enter edit mode";
static NSString *EVENT_ACTION_FINISH_EDIT_LIBRARY = @"finish edit mode";
static NSString *EVENT_ACTION_FINISH_DELETE_DOWNLOADING_VIDEO = @"delete a downloading video";
static NSString *EVENT_ACTION_FINISH_DELETE_COMPLETED_VIDEO = @"delete a completed video";
static NSString *EVENT_ACTION_CHOOSE_VIDEO_QUALITY = @"choose video quality";
static NSString *EVENT_ACTION_ADJUST_PLAYER_BRIGHTNESS = @"adjust brightness";
static NSString *EVENT_ACTION_ADJUST_AUDIO_DELAY = @"adjust audio delay";


// screen names
static NSString *SCREEN_NAME_SEARCH_VIEW = @"search view";
static NSString *SCREEN_NAME_LIBRARY_VIEW = @"library view";

@interface YDAnalyticManager : NSObject

@property(nonatomic, strong) id<GAITracker> tracker;

+ (YDAnalyticManager*) sharedInstance;

/**
 * @discussion set the User Type dimension on GA, it is a USER scope dimension
 */
- (void)setUserType;

- (void)trackWithCategory:(NSString *)category
                   action:(NSString *)action
                    label:(NSString *)label
                    value:(NSNumber *)value;

@end
