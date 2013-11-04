//
//  YDDeviceUtility.h
//  YoutubeDownloader
//
//  Created by Hao Wang  on 13-11-4.
//  Copyright (c) 2013年 HAO WANG. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum
{
    VSNetworkTypeNoInternet,
    VSNetworkTypeWifi,
    VSNetworkType3G
}VSNetworkType;

@interface VSDeviceStatus : NSObject

@property (nonatomic,assign) float CPUUsage;
@property (nonatomic,assign) UIDeviceBatteryState batteryState;
@property (nonatomic,assign) float batteryLevel;

@end

@interface YDDeviceUtility : NSObject

/**
 * @abstract tell if the current iOS is iOS7 or above
 * @return YES if iOS7 or above
 */
+ (BOOL)isIOS7orAbove;

/**
 * @abstract get the current CPU usage
 * @return the current CPU usage in float (%)
 */
+ (CGFloat)currentCPUUsage;

/**
 * @abstract Check if current device is iPad
 * @return YES if current device is iPad
 */
+ (BOOL) isIPad;

/**
 * @abstract Check if current device is iPhone5 with height of 568
 * @return YES if current device is iPhone5
 */
+ (BOOL) isIPhone5;

/**
 * @abstract check if current device is retina display
 * @return YES if current device is retina display
 */
+ (BOOL) isRetina;

/**
 * @abstract test if the current device orientation is landscape
 * @return YES if the current device orientation is landscape
 */
+ (BOOL) isLandscape;

+ (VSDeviceStatus*)getDeviceStatus;
+ (VSNetworkType)getCurrentNetworkType;

@end

