//
//  YDVideoLifeManager.m
//  YoutubeDownloader
//
//  Created by HAO WANG on 1/1/14.
//  Copyright (c) 2014 HAO WANG. All rights reserved.
//

#import "YDVideoLifeManager.h"

@implementation YDVideoLifeManager

+ (YDVideoLifeManager* ) sharedInstance
{
    static YDVideoLifeManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[YDVideoLifeManager alloc] init];
    });
    return instance;
}

- (void)deleteVideo:(Video *)video
{
    NSManagedObjectContext *context = [NSManagedObjectContext MR_contextForCurrentThread];
    [Video removeVideo:video.videoID inContext:context completion:^(BOOL success, NSError *error) {
        if (!success) {

#ifdef DEBUG
            NSLog(@"Failed to remove video: %@", video.videoID);
#endif
            
        }
    }];
}

@end
