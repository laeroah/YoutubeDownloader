//
//  YDAnalyticManager.m
//  YoutubeDownloader
//
//  Created by HAO WANG on 11/21/13.
//  Copyright (c) 2013 HAO WANG. All rights reserved.
//

#import "YDAnalyticManager.h"
#import "GAIDictionaryBuilder.h"
#import "GAIFields.h"
#import "GAITracker.h"
#import "UIDevice-Hardware.h"

static NSString *const kTrackingId = @"UA-31727751-2";

@implementation YDAnalyticManager

+ (YDAnalyticManager*) sharedInstance {
    static YDAnalyticManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[YDAnalyticManager alloc] init];
        [instance initializeGoogleAnalytics];
    });
    return instance;
}

- (void)initializeGoogleAnalytics
{
    [GAI sharedInstance].dispatchInterval = 20;
    [GAI sharedInstance].trackUncaughtExceptions = YES;
    if (DEBUG) {
        // Optional: set Logger to VERBOSE for debug information.
        [[[GAI sharedInstance] logger] setLogLevel:kGAILogLevelVerbose];
    }
    self.tracker = [[GAI sharedInstance] trackerWithTrackingId:kTrackingId];
}

- (void)setUserType
{
    // need to add logic here to see if the user is paying user or normal user
    // also track if the user is developer or beta user
    NSString *userTypeValue = nil;
    if (DEBUG) {
        userTypeValue = @"Developer";
    }else{
        userTypeValue = @"Customer";
    }
    [self.tracker set:[GAIFields customDimensionForIndex:1] value:userTypeValue];
}

- (void)trackWithCategory:(NSString *)category
                   action:(NSString *)action
                    label:(NSString *)label
                    value:(NSNumber *)value
{
    [self.tracker send:[[GAIDictionaryBuilder createEventWithCategory:category
                                                          action:action
                                                           label:label
                                                           value:value] build]];
}


@end
