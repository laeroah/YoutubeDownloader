// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Video.h instead.

#import <CoreData/CoreData.h>


extern const struct VideoAttributes {
	__unsafe_unretained NSString *bookmark;
	__unsafe_unretained NSString *createDate;
	__unsafe_unretained NSString *duration;
	__unsafe_unretained NSString *isNew;
	__unsafe_unretained NSString *isRemoved;
	__unsafe_unretained NSString *qualityType;
	__unsafe_unretained NSString *videoDescription;
	__unsafe_unretained NSString *videoFilePath;
	__unsafe_unretained NSString *videoID;
	__unsafe_unretained NSString *videoImagePath;
	__unsafe_unretained NSString *videoTitle;
} VideoAttributes;

extern const struct VideoRelationships {
	__unsafe_unretained NSString *relationship;
} VideoRelationships;

extern const struct VideoFetchedProperties {
} VideoFetchedProperties;

@class DownloadTask;













@interface VideoID : NSManagedObjectID {}
@end

@interface _Video : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (VideoID*)objectID;





@property (nonatomic, strong) NSNumber* bookmark;



@property float bookmarkValue;
- (float)bookmarkValue;
- (void)setBookmarkValue:(float)value_;

//- (BOOL)validateBookmark:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSDate* createDate;



//- (BOOL)validateCreateDate:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* duration;



@property int32_t durationValue;
- (int32_t)durationValue;
- (void)setDurationValue:(int32_t)value_;

//- (BOOL)validateDuration:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* isNew;



@property BOOL isNewValue;
- (BOOL)isNewValue;
- (void)setIsNewValue:(BOOL)value_;

//- (BOOL)validateIsNew:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* isRemoved;



@property BOOL isRemovedValue;
- (BOOL)isRemovedValue;
- (void)setIsRemovedValue:(BOOL)value_;

//- (BOOL)validateIsRemoved:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* qualityType;



//- (BOOL)validateQualityType:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* videoDescription;



//- (BOOL)validateVideoDescription:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* videoFilePath;



//- (BOOL)validateVideoFilePath:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* videoID;



@property int32_t videoIDValue;
- (int32_t)videoIDValue;
- (void)setVideoIDValue:(int32_t)value_;

//- (BOOL)validateVideoID:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* videoImagePath;



//- (BOOL)validateVideoImagePath:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* videoTitle;



//- (BOOL)validateVideoTitle:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) DownloadTask *relationship;

//- (BOOL)validateRelationship:(id*)value_ error:(NSError**)error_;





@end

@interface _Video (CoreDataGeneratedAccessors)

@end

@interface _Video (CoreDataGeneratedPrimitiveAccessors)


- (NSNumber*)primitiveBookmark;
- (void)setPrimitiveBookmark:(NSNumber*)value;

- (float)primitiveBookmarkValue;
- (void)setPrimitiveBookmarkValue:(float)value_;




- (NSDate*)primitiveCreateDate;
- (void)setPrimitiveCreateDate:(NSDate*)value;




- (NSNumber*)primitiveDuration;
- (void)setPrimitiveDuration:(NSNumber*)value;

- (int32_t)primitiveDurationValue;
- (void)setPrimitiveDurationValue:(int32_t)value_;




- (NSNumber*)primitiveIsNew;
- (void)setPrimitiveIsNew:(NSNumber*)value;

- (BOOL)primitiveIsNewValue;
- (void)setPrimitiveIsNewValue:(BOOL)value_;




- (NSNumber*)primitiveIsRemoved;
- (void)setPrimitiveIsRemoved:(NSNumber*)value;

- (BOOL)primitiveIsRemovedValue;
- (void)setPrimitiveIsRemovedValue:(BOOL)value_;




- (NSString*)primitiveQualityType;
- (void)setPrimitiveQualityType:(NSString*)value;




- (NSString*)primitiveVideoDescription;
- (void)setPrimitiveVideoDescription:(NSString*)value;




- (NSString*)primitiveVideoFilePath;
- (void)setPrimitiveVideoFilePath:(NSString*)value;




- (NSNumber*)primitiveVideoID;
- (void)setPrimitiveVideoID:(NSNumber*)value;

- (int32_t)primitiveVideoIDValue;
- (void)setPrimitiveVideoIDValue:(int32_t)value_;




- (NSString*)primitiveVideoImagePath;
- (void)setPrimitiveVideoImagePath:(NSString*)value;




- (NSString*)primitiveVideoTitle;
- (void)setPrimitiveVideoTitle:(NSString*)value;





- (DownloadTask*)primitiveRelationship;
- (void)setPrimitiveRelationship:(DownloadTask*)value;


@end
