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
static NSString *EVENT_CATEGORY_USER_ACTION = @"user action events";

// event actions
static NSString *EVENT_ACTION_NAVIGATION_BACK = @"back";
static NSString *EVENT_ACTION_NAVIGATION_LIBRARY = @"library";
static NSString *EVENT_ACTION_NAVIGATION_HOME = @"home";
static NSString *EVENT_ACTION_NAVIGATION_DOWNLOAD = @"download";

// event labels
static NSString *EVENT_LABEL_SEARCH_VIEW = @"search view";
static NSString *EVENT_LABEL_LIBRARY_VIEW = @"library view";
static NSString *EVENT_LABEL_DOWNLOAD = @"video download";

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
