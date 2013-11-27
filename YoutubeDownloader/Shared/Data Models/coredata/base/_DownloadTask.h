// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to DownloadTask.h instead.

#import <CoreData/CoreData.h>


extern const struct DownloadTaskAttributes {
	__unsafe_unretained NSString *createDate;
	__unsafe_unretained NSString *downloadID;
	__unsafe_unretained NSString *downloadPageUrl;
	__unsafe_unretained NSString *downloadPriority;
	__unsafe_unretained NSString *downloadProgress;
	__unsafe_unretained NSString *downloadTaskStatus;
	__unsafe_unretained NSString *qualityType;
	__unsafe_unretained NSString *videoDescription;
	__unsafe_unretained NSString *videoDownloadUrl;
	__unsafe_unretained NSString *videoFilePath;
	__unsafe_unretained NSString *videoFileSize;
	__unsafe_unretained NSString *videoImagePath;
	__unsafe_unretained NSString *videoTitle;
} DownloadTaskAttributes;

extern const struct DownloadTaskRelationships {
	__unsafe_unretained NSString *relationship;
} DownloadTaskRelationships;

extern const struct DownloadTaskFetchedProperties {
} DownloadTaskFetchedProperties;

@class Video;















@interface DownloadTaskID : NSManagedObjectID {}
@end

@interface _DownloadTask : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (DownloadTaskID*)objectID;





@property (nonatomic, strong) NSDate* createDate;



//- (BOOL)validateCreateDate:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* downloadID;



@property int32_t downloadIDValue;
- (int32_t)downloadIDValue;
- (void)setDownloadIDValue:(int32_t)value_;

//- (BOOL)validateDownloadID:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* downloadPageUrl;



//- (BOOL)validateDownloadPageUrl:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* downloadPriority;



@property int16_t downloadPriorityValue;
- (int16_t)downloadPriorityValue;
- (void)setDownloadPriorityValue:(int16_t)value_;

//- (BOOL)validateDownloadPriority:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* downloadProgress;



@property float downloadProgressValue;
- (float)downloadProgressValue;
- (void)setDownloadProgressValue:(float)value_;

//- (BOOL)validateDownloadProgress:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* downloadTaskStatus;



@property int16_t downloadTaskStatusValue;
- (int16_t)downloadTaskStatusValue;
- (void)setDownloadTaskStatusValue:(int16_t)value_;

//- (BOOL)validateDownloadTaskStatus:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* qualityType;



//- (BOOL)validateQualityType:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* videoDescription;



//- (BOOL)validateVideoDescription:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* videoDownloadUrl;



//- (BOOL)validateVideoDownloadUrl:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* videoFilePath;



//- (BOOL)validateVideoFilePath:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* videoFileSize;



@property int64_t videoFileSizeValue;
- (int64_t)videoFileSizeValue;
- (void)setVideoFileSizeValue:(int64_t)value_;

//- (BOOL)validateVideoFileSize:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* videoImagePath;



//- (BOOL)validateVideoImagePath:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* videoTitle;



//- (BOOL)validateVideoTitle:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) Video *relationship;

//- (BOOL)validateRelationship:(id*)value_ error:(NSError**)error_;





@end

@interface _DownloadTask (CoreDataGeneratedAccessors)

@end

@interface _DownloadTask (CoreDataGeneratedPrimitiveAccessors)


- (NSDate*)primitiveCreateDate;
- (void)setPrimitiveCreateDate:(NSDate*)value;




- (NSNumber*)primitiveDownloadID;
- (void)setPrimitiveDownloadID:(NSNumber*)value;

- (int32_t)primitiveDownloadIDValue;
- (void)setPrimitiveDownloadIDValue:(int32_t)value_;




- (NSString*)primitiveDownloadPageUrl;
- (void)setPrimitiveDownloadPageUrl:(NSString*)value;




- (NSNumber*)primitiveDownloadPriority;
- (void)setPrimitiveDownloadPriority:(NSNumber*)value;

- (int16_t)primitiveDownloadPriorityValue;
- (void)setPrimitiveDownloadPriorityValue:(int16_t)value_;




- (NSNumber*)primitiveDownloadProgress;
- (void)setPrimitiveDownloadProgress:(NSNumber*)value;

- (float)primitiveDownloadProgressValue;
- (void)setPrimitiveDownloadProgressValue:(float)value_;




- (NSNumber*)primitiveDownloadTaskStatus;
- (void)setPrimitiveDownloadTaskStatus:(NSNumber*)value;

- (int16_t)primitiveDownloadTaskStatusValue;
- (void)setPrimitiveDownloadTaskStatusValue:(int16_t)value_;




- (NSString*)primitiveQualityType;
- (void)setPrimitiveQualityType:(NSString*)value;




- (NSString*)primitiveVideoDescription;
- (void)setPrimitiveVideoDescription:(NSString*)value;




- (NSString*)primitiveVideoDownloadUrl;
- (void)setPrimitiveVideoDownloadUrl:(NSString*)value;




- (NSString*)primitiveVideoFilePath;
- (void)setPrimitiveVideoFilePath:(NSString*)value;




- (NSNumber*)primitiveVideoFileSize;
- (void)setPrimitiveVideoFileSize:(NSNumber*)value;

- (int64_t)primitiveVideoFileSizeValue;
- (void)setPrimitiveVideoFileSizeValue:(int64_t)value_;




- (NSString*)primitiveVideoImagePath;
- (void)setPrimitiveVideoImagePath:(NSString*)value;




- (NSString*)primitiveVideoTitle;
- (void)setPrimitiveVideoTitle:(NSString*)value;





- (Video*)primitiveRelationship;
- (void)setPrimitiveRelationship:(Video*)value;


@end
