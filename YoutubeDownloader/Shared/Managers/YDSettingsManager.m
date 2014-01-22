//
//  YDSettingsManager.m
//  YoutubeDownloader
//
//  Created by HAO WANG on 12/3/13.
//  Copyright (c) 2013 HAO WANG. All rights reserved.
//

#import "YDSettingsManager.h"

@implementation YDSettingsManager

+ (YDSettingsManager*) sharedInstance {
    static YDSettingsManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[YDSettingsManager alloc] init];
        [instance performSelector:@selector(registerDefaults) withObject:nil];
    });
    return instance;
}

- (void)registerDefaults
{
    NSString *userDefaultsValuesPath =[[NSBundle mainBundle] pathForResource:@"DefaultSettings"
                                                                      ofType:@"plist"];
    
    NSDictionary *userDefaultsValuesDict = [NSDictionary dictionaryWithContentsOfFile:userDefaultsValuesPath];
    
	// set them in the standard user defaults
	[[NSUserDefaults standardUserDefaults] registerDefaults:userDefaultsValuesDict];
    
	if (![[NSUserDefaults standardUserDefaults] synchronize]) {
		NSLog(@"not successful in writing the default prefs");
    }
}

- (NSTimeInterval)timeToDeleteAfterDownload
{
    NSNumber *timeToDelete = [[NSUserDefaults standardUserDefaults]valueForKey:@"VideoDeleteDuration"];
    return [timeToDelete integerValue] * 60;
}

- (BOOL)shouldDeleteAfterWatch
{
    BOOL deleteAfterWatch = [[NSUserDefaults standardUserDefaults]boolForKey:@"DeleteVideoAfterWatch"];
    return deleteAfterWatch;
}

- (BOOL)shouldDeleteAfterDuration
{
    BOOL deleteAfterDuration = [[NSUserDefaults standardUserDefaults]boolForKey:@"DeleteVideoAfterDuration"];
    return deleteAfterDuration;
}

- (void)setShouldDeleteAfterWatch:(BOOL)deleteAfterWatch
{
    [[NSUserDefaults standardUserDefaults] setBool:deleteAfterWatch forKey:@"DeleteVideoAfterWatch"];
	if (![[NSUserDefaults standardUserDefaults] synchronize]) {
		NSLog(@"failed to save settings");
    }
}

@end
