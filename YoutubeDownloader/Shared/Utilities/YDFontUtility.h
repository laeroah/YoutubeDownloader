//
//  YDFontUtility.h
//  YoutubeDownloader
//
//  Created by Hao Wang  on 13-11-4.
//  Copyright (c) 2013年 HAO WANG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreText/CoreText.h>

@interface MockFont : NSObject <NSCopying>
@property (nonatomic, copy) NSString *familyName;
@property (nonatomic, copy) NSString *fontName;
@property (nonatomic) CGFloat pointSize;
@property (nonatomic) BOOL bold;
@property (nonatomic) BOOL italic;
@end

/**
 * @abstract Since UIFont can't be used in unit tests, this class provides a workaround to return
 *           mock font objects that can be used in place of actual UIFont objects for the sake
 *           of building NSAttributedStrings.
 */
@interface YDFontUtility : NSObject

+ (void)useMockFontObjects;

/**
 * @abstract Returns a mock font object if useMockFontObjects has been called, otherwise it
 *           forwards the call to UIFont.
 * @return a UIFont or a mock font object that behaves like a UIFont object
 */
+ (id)fontWithName:(NSString *)name size:(CGFloat)size;

/**
 * @abstract Returns a UIFont or mock font object with the appropriate traits,
 *           depending on the type of the font parameter passed in.
 * @param font a UIFont or mock font object
 * @return a UIFont or mock font object
 */
+ (id)fontFromFont:(id)font withTraits:(CTFontSymbolicTraits)traits;

+ (id)systemFontOfSize:(CGFloat)size;
+ (id)boldSystemFontOfSize:(CGFloat)size;
+ (id)italicSystemFontOfSize:(CGFloat)size;

+ (id)helveticaNeueFontOfSize:(CGFloat)size;
+ (id)helveticaNeueBoldFontOfSize:(CGFloat)size;
+ (id)helveticaNeueItalicFontOfSize:(CGFloat)size;
+ (id)helveticaNeueBoldItalicFontOfSize:(CGFloat)size;
+ (id)helveticaNeueLightFontOfSize:(CGFloat)size;
+ (id)helveticaNeueLightItalicFontOfSize:(CGFloat)size;
+ (id)helveticaNeueMediumFontOfSize:(CGFloat)size;

@end