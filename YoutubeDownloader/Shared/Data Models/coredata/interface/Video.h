#import "_Video.h"
#import "CoreData+MagicalRecord.h"


@interface Video : _Video {}

// Custom logic goes here.
+ (Video *)createVideoWithContext:(NSManagedObjectContext *)context;
+ (NSArray*)findAll;
- (void)updateWithContext:(NSManagedObjectContext *)context completion:(MRSaveCompletionHandler)completion;
+ (Video*)findByVideoID:(NSNumber*)videoID inContext:(NSManagedObjectContext *)context;
+ (NSInteger)getNewVideosCountWithContext:(NSManagedObjectContext *)context;
+ (void)removeVideo:(NSNumber*)videoID inContext:(NSManagedObjectContext *)context completion:(MRSaveCompletionHandler)completion;
- (NSString *)formattedVideoDuration;

@end
