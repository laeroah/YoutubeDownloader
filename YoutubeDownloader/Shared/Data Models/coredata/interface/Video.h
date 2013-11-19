#import "_Video.h"
#import "CoreData+MagicalRecord.h"


@interface Video : _Video {}

// Custom logic goes here.
+ (Video *)createVideoWithVideoID:(NSNumber *)videoID inContext:(NSManagedObjectContext *)context completion:(MRSaveCompletionHandler)completion;
+ (NSArray*)findAll;
- (void)updateWithContext:(NSManagedObjectContext *)context completion:(MRSaveCompletionHandler)completion;
+ (Video*)findByVideoID:(NSNumber*)videoID inContext:(NSManagedObjectContext *)context;

@end
