#import "_Video.h"
#import "CoreData+MagicalRecord.h"


@interface Video : _Video {}

// Custom logic goes here.
+ (Video *)createVideoWithContext:(NSManagedObjectContext *)context;
+ (NSArray*)findAll;
- (void)updateWithContext:(NSManagedObjectContext *)context completion:(MRSaveCompletionHandler)completion;
+ (Video*)findByVideoID:(NSNumber*)videoID inContext:(NSManagedObjectContext *)context;

@end
