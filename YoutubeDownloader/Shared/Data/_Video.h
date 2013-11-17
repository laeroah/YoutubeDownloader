// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Video.h instead.

#import <CoreData/CoreData.h>


extern const struct VideoAttributes {
	__unsafe_unretained NSString *createDate;
	__unsafe_unretained NSString *qualityType;
	__unsafe_unretained NSString *videoDescription;
	__unsafe_unretained NSString *videoFilePath;
	__unsafe_unretained NSString *videoID;
	__unsafe_unretained NSString *videoImagePath;
} VideoAttributes;

extern const struct VideoRelationships {
} VideoRelationships;

extern const struct VideoFetchedProperties {
} VideoFetchedProperties;









@interface VideoID : NSManagedObjectID {}
@end

@interface _Video : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (VideoID*)objectID;





@property (nonatomic, strong) NSString* createDate;



//- (BOOL)validateCreateDate:(id*)value_ error:(NSError**)error_;





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






@end

@interface _Video (CoreDataGeneratedAccessors)

@end

@interface _Video (CoreDataGeneratedPrimitiveAccessors)


- (NSString*)primitiveCreateDate;
- (void)setPrimitiveCreateDate:(NSString*)value;




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




@end
