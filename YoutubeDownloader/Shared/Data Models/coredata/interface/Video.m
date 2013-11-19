#import "Video.h"



@interface Video ()

// Private interface goes here.

@end


@implementation Video

// Custom logic goes here.

+ (Video *)createVideoWithVideoID:(NSNumber *)videoID inContext:(NSManagedObjectContext *)context completion:(MRSaveCompletionHandler)completion
{
    Video *video = [Video findByVideoID:videoID inContext:context];
    if (video) {
        return video;
    }
    
    // Get the local context
    video = [Video MR_createInContext:context];
    video.videoID = videoID;
    // Save the modification in the local context
    [context MR_saveToPersistentStoreWithCompletion:^(BOOL success, NSError *error) {
        if (completion)
        {
            completion(success, error);
        }
    }
    ];
    
    return video;
}

+ (NSArray*)findAll
{
    return [Video MR_findAll];
}

+ (Video*)findByVideoID:(NSNumber*)videoID inContext:(NSManagedObjectContext *)context
{
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"videoID == %@"];
    return  [Video MR_findFirstWithPredicate:predicate inContext:context];
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

- (void)deleteWithContext:(NSManagedObjectContext *)context completion:(MRSaveCompletionHandler)completion
{
    [self MR_inContext:context];
    [context MR_saveToPersistentStoreWithCompletion:^(BOOL success, NSError *error) {
        if (completion)
        {
            completion(success, error);
        }
    }];
}

@end
