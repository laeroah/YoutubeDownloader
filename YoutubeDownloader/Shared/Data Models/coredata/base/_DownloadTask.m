// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to DownloadTask.m instead.

#import "_DownloadTask.h"

const struct DownloadTaskAttributes DownloadTaskAttributes = {
	.createDate = @"createDate",
	.downloadID = @"downloadID",
	.downloadPageUrl = @"downloadPageUrl",
	.downloadPriority = @"downloadPriority",
	.downloadProgress = @"downloadProgress",
	.downloadTaskStatus = @"downloadTaskStatus",
	.qualityType = @"qualityType",
	.videoDescription = @"videoDescription",
	.videoDownloadUrl = @"videoDownloadUrl",
	.videoFilePath = @"videoFilePath",
	.videoFileSize = @"videoFileSize",
	.videoImagePath = @"videoImagePath",
	.videoTitle = @"videoTitle",
	.youtubeVideoID = @"youtubeVideoID",
};

const struct DownloadTaskRelationships DownloadTaskRelationships = {
	.video = @"video",
};

const struct DownloadTaskFetchedProperties DownloadTaskFetchedProperties = {
};

@implementation DownloadTaskID
@end

@implementation _DownloadTask

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"DownloadTask" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"DownloadTask";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"DownloadTask" inManagedObjectContext:moc_];
}

- (DownloadTaskID*)objectID {
	return (DownloadTaskID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
	if ([key isEqualToString:@"downloadIDValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"downloadID"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"downloadPriorityValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"downloadPriority"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"downloadProgressValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"downloadProgress"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"downloadTaskStatusValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"downloadTaskStatus"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"videoFileSizeValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"videoFileSize"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}




@dynamic createDate;






@dynamic downloadID;



- (int32_t)downloadIDValue {
	NSNumber *result = [self downloadID];
	return [result intValue];
}

- (void)setDownloadIDValue:(int32_t)value_ {
	[self setDownloadID:[NSNumber numberWithInt:value_]];
}

- (int32_t)primitiveDownloadIDValue {
	NSNumber *result = [self primitiveDownloadID];
	return [result intValue];
}

- (void)setPrimitiveDownloadIDValue:(int32_t)value_ {
	[self setPrimitiveDownloadID:[NSNumber numberWithInt:value_]];
}





@dynamic downloadPageUrl;






@dynamic downloadPriority;



- (int16_t)downloadPriorityValue {
	NSNumber *result = [self downloadPriority];
	return [result shortValue];
}

- (void)setDownloadPriorityValue:(int16_t)value_ {
	[self setDownloadPriority:[NSNumber numberWithShort:value_]];
}

- (int16_t)primitiveDownloadPriorityValue {
	NSNumber *result = [self primitiveDownloadPriority];
	return [result shortValue];
}

- (void)setPrimitiveDownloadPriorityValue:(int16_t)value_ {
	[self setPrimitiveDownloadPriority:[NSNumber numberWithShort:value_]];
}





@dynamic downloadProgress;



- (float)downloadProgressValue {
	NSNumber *result = [self downloadProgress];
	return [result floatValue];
}

- (void)setDownloadProgressValue:(float)value_ {
	[self setDownloadProgress:[NSNumber numberWithFloat:value_]];
}

- (float)primitiveDownloadProgressValue {
	NSNumber *result = [self primitiveDownloadProgress];
	return [result floatValue];
}

- (void)setPrimitiveDownloadProgressValue:(float)value_ {
	[self setPrimitiveDownloadProgress:[NSNumber numberWithFloat:value_]];
}





@dynamic downloadTaskStatus;



- (int16_t)downloadTaskStatusValue {
	NSNumber *result = [self downloadTaskStatus];
	return [result shortValue];
}

- (void)setDownloadTaskStatusValue:(int16_t)value_ {
	[self setDownloadTaskStatus:[NSNumber numberWithShort:value_]];
}

- (int16_t)primitiveDownloadTaskStatusValue {
	NSNumber *result = [self primitiveDownloadTaskStatus];
	return [result shortValue];
}

- (void)setPrimitiveDownloadTaskStatusValue:(int16_t)value_ {
	[self setPrimitiveDownloadTaskStatus:[NSNumber numberWithShort:value_]];
}





@dynamic qualityType;






@dynamic videoDescription;






@dynamic videoDownloadUrl;






@dynamic videoFilePath;






@dynamic videoFileSize;



- (int64_t)videoFileSizeValue {
	NSNumber *result = [self videoFileSize];
	return [result longLongValue];
}

- (void)setVideoFileSizeValue:(int64_t)value_ {
	[self setVideoFileSize:[NSNumber numberWithLongLong:value_]];
}

- (int64_t)primitiveVideoFileSizeValue {
	NSNumber *result = [self primitiveVideoFileSize];
	return [result longLongValue];
}

- (void)setPrimitiveVideoFileSizeValue:(int64_t)value_ {
	[self setPrimitiveVideoFileSize:[NSNumber numberWithLongLong:value_]];
}





@dynamic videoImagePath;






@dynamic videoTitle;






@dynamic youtubeVideoID;






@dynamic video;

	






@end
