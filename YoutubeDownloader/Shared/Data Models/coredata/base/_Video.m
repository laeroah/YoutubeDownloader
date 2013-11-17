// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Video.m instead.

#import "_Video.h"

const struct VideoAttributes VideoAttributes = {
	.createDate = @"createDate",
	.qualityType = @"qualityType",
	.videoDescription = @"videoDescription",
	.videoFilePath = @"videoFilePath",
	.videoID = @"videoID",
	.videoImagePath = @"videoImagePath",
};

const struct VideoRelationships VideoRelationships = {
};

const struct VideoFetchedProperties VideoFetchedProperties = {
};

@implementation VideoID
@end

@implementation _Video

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"Video" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"Video";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"Video" inManagedObjectContext:moc_];
}

- (VideoID*)objectID {
	return (VideoID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
	if ([key isEqualToString:@"videoIDValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"videoID"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}




@dynamic createDate;






@dynamic qualityType;






@dynamic videoDescription;






@dynamic videoFilePath;






@dynamic videoID;



- (int32_t)videoIDValue {
	NSNumber *result = [self videoID];
	return [result intValue];
}

- (void)setVideoIDValue:(int32_t)value_ {
	[self setVideoID:[NSNumber numberWithInt:value_]];
}

- (int32_t)primitiveVideoIDValue {
	NSNumber *result = [self primitiveVideoID];
	return [result intValue];
}

- (void)setPrimitiveVideoIDValue:(int32_t)value_ {
	[self setPrimitiveVideoID:[NSNumber numberWithInt:value_]];
}





@dynamic videoImagePath;











@end
