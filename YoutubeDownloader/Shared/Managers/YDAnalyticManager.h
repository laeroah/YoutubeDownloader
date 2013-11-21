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
static NSString *EVENT_CATEGORY_NAVIGATION = @"ui_navigation";

// event actions
static NSString *EVENT_ACTION_NAVIGATION = @"navigation button tapped";

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
