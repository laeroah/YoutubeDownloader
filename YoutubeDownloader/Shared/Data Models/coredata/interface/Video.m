#import "Video.h"



@interface Video ()

// Private interface goes here.

@end


@implementation Video

// Custom logic goes here.
+ (NSInteger)maxVideoID:(NSManagedObjectContext*)context
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Video"];
    fetchRequest.fetchLimit = 1;
    fetchRequest.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"videoID" ascending:NO]];
    NSError *error = nil;
    Video *video = [context executeFetchRequest:fetchRequest error:&error].lastObject;
    if (video != nil)
    {
        return [video.videoID integerValue];
    }
    return 0;
}


+ (Video *)createVideoWithContext:(NSManagedObjectContext *)context
{
    Video *video;
    @synchronized(self)
    {
        NSInteger videoID = [Video maxVideoID:context];
        videoID++;
        video = [Video MR_createInContext:context];
        video.videoID = @(videoID);
        [context MR_saveToPersistentStoreAndWait];
    }
    
    return video;
}

+ (NSInteger)getNewVideosCountWithContext:(NSManagedObjectContext *)context
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"isNew == 1"];
    return  [[Video MR_findAllWithPredicate:predicate] count];
}

+ (NSArray*)findAll
{
    return [Video MR_findAll];
}

+ (Video*)findByVideoID:(NSNumber*)videoID inContext:(NSManagedObjectContext *)context
{
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"videoID == %@", videoID];
    return  [Video MR_findFirstWithPredicate:predicate inContext:context];
}

+ (void)removeVideo:(NSNumber*)videoID inContext:(NSManagedObjectContext *)context completion:(MRSaveCompletionHandler)completion
{
    Video *video = [Video findByVideoID:videoID inContext:context];
    if (!video)
    {
        completion (YES, nil);
        return;
    }
    [video setIsRemovedValue:YES];
    [context MR_saveToPersistentStoreWithCompletion:^(BOOL success, NSError *error) {
        completion (success, error);
    }];
}

- (void)updateWithContext:(NSManagedObjectContext *)context completion:(MRSaveCompletionHandler)completion
{
    [context MR_saveToPersistentStoreWithCompletion:^(BOOL success, NSError *error) {
        if (completion)
        {
            completion(success, error);
        }
    }];
}


- (void)updateWithContext:(NSManagedObjectContext *)context
{
    [context MR_saveToPersistentStoreAndWait];
}


- (NSString *)formattedVideoDuration
{
    NSInteger videoDuration = self.durationValue;
    NSInteger min = videoDuration/60;
    NSInteger sec = videoDuration%60;
    return [NSString stringWithFormat:@"%d:%.2d", min, sec];
}

@end
