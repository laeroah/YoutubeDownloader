//
//  YDVideoLifeManager.h
//  YoutubeDownloader
//
//  Created by HAO WANG on 1/1/14.
//  Copyright (c) 2014 HAO WANG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Video.h"

/**
 * video life manager manages deleting a video, and how long a video is allowed to live after it's downloaded.
 *
 */
@interface YDVideoLifeManager : NSObject

+ (YDVideoLifeManager*) sharedInstance;
- (void)deleteVideo:(Video *)video;

@end
