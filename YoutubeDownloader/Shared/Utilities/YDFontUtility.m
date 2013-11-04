//
//  YDFontUtility.m
//  YoutubeDownloader
//
//  Created by Hao Wang  on 13-11-4.
//  Copyright (c) 2013年 HAO WANG. All rights reserved.
//

#import "YDFontUtility.h"



@implementation MockFont

- (NSUInteger)hash
{
    NSUInteger value = [self.familyName hash];
    CGFloat pointSize = self.pointSize;
    // XOR with pointSize's binary representation
#if CGFLOAT_IS_DOUBLE
    NSUInteger size = (NSUInteger) *((uint64_t *)&pointSize);
#else
    NSUInteger size = (NSUInteger) *((uint32_t *)&pointSize);
#endif
    value ^= size;
    // Flip every 2nd bit starting with the 1st
    if (self.bold)
        value ^= 0xAAAAAAAA;
    // Flip every 2nd bit starting with the 2nd
    if (self.italic)
        value ^= 0x55555555;
    return value;
}

- (BOOL)isEqual:(id)object
{
    if (![object isKindOfClass:[MockFont class]])
        return NO;
    MockFont *other = (MockFont *)object;
    return [self.familyName isEqualToString:other.familyName] && self.pointSize == other.pointSize && self.bold == other.bold && self.italic == other.italic;
}

- (id)copyWithZone:(NSZone *)zone
{
    MockFont *font = [[MockFont allocWithZone:zone] init];
    font.familyName = self.familyName;
    font.fontName = self.fontName;
    font.pointSize = self.pointSize;
    font.bold = self.bold;
    font.italic = self.italic;
    return font;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<MockFont %p ; family = %@ ; bold = %@ ; italic = %@>",
            self, self.familyName, self.bold ? @"YES" : @"NO", self.italic ? @"YES" : @"NO"];
}

@end

@implementation YDFontUtility

static BOOL s_useMocks;

+ (void)useMockFontObjects
{
    s_useMocks = YES;
}

+ (id)systemFontOfSize:(CGFloat)size
{
    if (s_useMocks)
        return [self fontWithName:@"Helvetica" size:12.0f];
    else
        return [UIFont systemFontOfSize:size];
}

+ (id)boldSystemFontOfSize:(CGFloat)size
{
    if (s_useMocks)
        return [self fontWithName:@"Helvetica-Bold" size:12.0f];
    else
        return [UIFont boldSystemFontOfSize:size];
}

+ (id)italicSystemFontOfSize:(CGFloat)size
{
    if (s_useMocks)
        return [self fontWithName:@"Helvetica-Oblique" size:12.0f];
    else
        return [UIFont italicSystemFontOfSize:size];
}

+ (id)fontWithName:(NSString *)name size:(CGFloat)size
{
    if (!s_useMocks)
        return [UIFont fontWithName:name size:size];
    
    MockFont *font = [[MockFont alloc] init];
    NSArray *nameParts = [name componentsSeparatedByString:@"-"];
    font.familyName = nameParts[0];
    font.fontName = name;
    font.pointSize = size;
    if ([nameParts count] > 1)
    {
        if ([nameParts[1] rangeOfString:@"Bold"].location != NSNotFound)
            font.bold = YES;
        if ([nameParts[1] rangeOfString:@"Oblique"].location != NSNotFound ||
            [nameParts[1] rangeOfString:@"Italic"].location != NSNotFound)
            font.italic = YES;
    }
    return font;
}

+ (id)fontFromFont:(id)font withTraits:(CTFontSymbolicTraits)traits
{
    if ([font isKindOfClass:[MockFont class]])
    {
        MockFont *traitFont = [font copy];
        traitFont.bold = (traits & kCTFontBoldTrait) ? YES : NO;
        traitFont.italic = (traits & kCTFontItalicTrait) ? YES : NO;
        return traitFont;
    }
    
    UIFont *baseFont = (UIFont *)font;
    NSString *familyName = baseFont.familyName;
    CGFloat size = baseFont.pointSize;
    CTFontRef ctFont = CTFontCreateWithName((__bridge CFStringRef)familyName, size, NULL);
    if (!ctFont)
        return nil;
    CTFontRef ctTraitFont = CTFontCreateCopyWithSymbolicTraits(ctFont, size, NULL, traits, traits);
    CFRelease(ctFont);
    if (!ctTraitFont)
        return nil;
    NSString *postScriptName = (__bridge_transfer NSString *)CTFontCopyPostScriptName(ctTraitFont);
    CFRelease(ctTraitFont);
    return [UIFont fontWithName:postScriptName size:size];
}

+ (id)helveticaNeueFontOfSize:(CGFloat)size
{
    return [self fontWithName:@"HelveticaNeue" size:size];
}

+ (id)helveticaNeueBoldFontOfSize:(CGFloat)size
{
    return [self fontWithName:@"HelveticaNeue-Bold" size:size];
}

+ (id)helveticaNeueItalicFontOfSize:(CGFloat)size
{
    return [self fontWithName:@"HelveticaNeue-Italic" size:size];
}

+ (id)helveticaNeueBoldItalicFontOfSize:(CGFloat)size
{
    return [self fontWithName:@"HelveticaNeue-BoldItalic" size:size];
}

+ (id)helveticaNeueLightFontOfSize:(CGFloat)size
{
    return [self fontWithName:@"HelveticaNeue-Light" size:size];
}

+ (id)helveticaNeueLightItalicFontOfSize:(CGFloat)size
{
    return [self fontWithName:@"HelveticaNeue-LightItalic" size:size];
}

+ (id)helveticaNeueMediumFontOfSize:(CGFloat)size
{
    return [self fontWithName:@"HelveticaNeue-Medium" size:size];
}

@end