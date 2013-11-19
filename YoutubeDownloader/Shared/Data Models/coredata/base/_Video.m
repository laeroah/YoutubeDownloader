// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Video.m instead.

#import "_Video.h"

const struct VideoAttributes VideoAttributes = {
	.bookmark = @"bookmark",
	.createDate = @"createDate",
	.duration = @"duration",
	.isNew = @"isNew",
	.isRemoved = @"isRemoved",
	.qualityType = @"qualityType",
	.videoDescription = @"videoDescription",
	.videoFilePath = @"videoFilePath",
	.videoID = @"videoID",
	.videoImagePath = @"videoImagePath",
	.videoTitle = @"videoTitle",
};

const struct VideoRelationships VideoRelationships = {
	.relationship = @"relationship",
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
	
	if ([key isEqualToString:@"bookmarkValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"bookmark"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"durationValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"duration"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"isNewValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"isNew"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"isRemovedValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"isRemoved"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"videoIDValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"videoID"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}




@dynamic bookmark;



- (float)bookmarkValue {
	NSNumber *result = [self bookmark];
	return [result floatValue];
}

- (void)setBookmarkValue:(float)value_ {
	[self setBookmark:[NSNumber numberWithFloat:value_]];
}

- (float)primitiveBookmarkValue {
	NSNumber *result = [self primitiveBookmark];
	return [result floatValue];
}

- (void)setPrimitiveBookmarkValue:(float)value_ {
	[self setPrimitiveBookmark:[NSNumber numberWithFloat:value_]];
}





@dynamic createDate;






@dynamic duration;



- (int32_t)durationValue {
	NSNumber *result = [self duration];
	return [result intValue];
}

- (void)setDurationValue:(int32_t)value_ {
	[self setDuration:[NSNumber numberWithInt:value_]];
}

- (int32_t)primitiveDurationValue {
	NSNumber *result = [self primitiveDuration];
	return [result intValue];
}

- (void)setPrimitiveDurationValue:(int32_t)value_ {
	[self setPrimitiveDuration:[NSNumber numberWithInt:value_]];
}





@dynamic isNew;



- (BOOL)isNewValue {
	NSNumber *result = [self isNew];
	return [result boolValue];
}

- (void)setIsNewValue:(BOOL)value_ {
	[self setIsNew:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveIsNewValue {
	NSNumber *result = [self primitiveIsNew];
	return [result boolValue];
}

- (void)setPrimitiveIsNewValue:(BOOL)value_ {
	[self setPrimitiveIsNew:[NSNumber numberWithBool:value_]];
}





@dynamic isRemoved;



- (BOOL)isRemovedValue {
	NSNumber *result = [self isRemoved];
	return [result boolValue];
}

- (void)setIsRemovedValue:(BOOL)value_ {
	[self setIsRemoved:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveIsRemovedValue {
	NSNumber *result = [self primitiveIsRemoved];
	return [result boolValue];
}

- (void)setPrimitiveIsRemovedValue:(BOOL)value_ {
	[self setPrimitiveIsRemoved:[NSNumber numberWithBool:value_]];
}





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






@dynamic videoTitle;






@dynamic relationship;

	






@end
