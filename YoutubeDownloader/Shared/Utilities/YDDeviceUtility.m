//
//  YDDeviceUtility.m
//  YoutubeDownloader
//
//  Created by Hao Wang  on 13-11-4.
//  Copyright (c) 2013年 HAO WANG. All rights reserved.
//

#import "YDDeviceUtility.h"
#import <sys/sysctl.h>
#import <mach/mach.h>
#import <mach/host_info.h>
#import <mach/mach_host.h>
#import <mach/task_info.h>
#import <mach/task.h>
#import <mach/thread_info.h>
#import "Reachability.h"
#import "AppDelegate.h"


@implementation VSDeviceStatus

@end

@implementation VSDeviceSpace

@end

@implementation YDDeviceUtility

+ (BOOL)isIOS7orAbove {
    
    NSString * versionString;
    
    versionString = [[ UIDevice currentDevice ] systemVersion];
    
    return ( NSUInteger )[ versionString doubleValue ] >= 7;
}

+ (CGFloat)currentCPUUsage
{
    kern_return_t kr;
    task_info_data_t tinfo;
    mach_msg_type_number_t task_info_count;
    task_info_count = TASK_INFO_MAX;
    kr = task_info(mach_task_self(), TASK_BASIC_INFO, (task_info_t)tinfo, &task_info_count);
    if (kr != KERN_SUCCESS)
    {
        return -1;
    }
    task_basic_info_t      basic_info;
    thread_array_t         thread_list;
    mach_msg_type_number_t thread_count;
    thread_info_data_t     thinfo;
    mach_msg_type_number_t thread_info_count;
    thread_basic_info_t basic_info_th;
    uint32_t stat_thread = 0; // Mach threads
    basic_info = (task_basic_info_t)tinfo;
    
    // get threads in the task
    kr = task_threads(mach_task_self(), &thread_list, &thread_count);
    if (kr != KERN_SUCCESS)
    {
        return -1;
    }
    
    if (thread_count > 0)
        stat_thread += thread_count;
    
    long tot_sec = 0;
    long tot_usec = 0;
    float tot_cpu = 0;
    int j;
    
    for (j = 0; j < thread_count; j++)
    {
        thread_info_count = THREAD_INFO_MAX;
        kr = thread_info(thread_list[j], THREAD_BASIC_INFO,
                         (thread_info_t)thinfo, &thread_info_count);
        if (kr != KERN_SUCCESS)
        {
            return -1;
        }
        
        basic_info_th = (thread_basic_info_t)thinfo;
        
        if (!(basic_info_th->flags & TH_FLAGS_IDLE))
        {
            tot_sec = tot_sec + basic_info_th->user_time.seconds + basic_info_th->system_time.seconds;
            tot_usec = tot_usec + basic_info_th->system_time.microseconds + basic_info_th->system_time.microseconds;
            tot_cpu = tot_cpu + basic_info_th->cpu_usage / (float)TH_USAGE_SCALE * 100.0;
        }
    } // for each thread
    
    kr = vm_deallocate(mach_task_self(), (vm_offset_t)thread_list, thread_count * sizeof(thread_t));
    assert(kr == KERN_SUCCESS);
    return tot_cpu;
}

+ (BOOL) isIPad
{
    return ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad);
}

+ (BOOL) isIPhone5
{
    return ( fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height - ( double )568 ) < DBL_EPSILON );
}

+ (BOOL) isRetina
{
    return [[UIScreen mainScreen] respondsToSelector:@selector(scale)] && [[UIScreen mainScreen] scale] == 2.0;
}

+ (BOOL) isLandscape
{
    return UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation]);
}

+ (VSDeviceSpace *)getDeviceSpace
{
    VSDeviceSpace *deviceSpace = [[VSDeviceSpace alloc]init];
    uint64_t totalSpace = 0;
    uint64_t totalFreeSpace = 0;
    NSError *error = nil;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSDictionary *dictionary = [[NSFileManager defaultManager] attributesOfFileSystemForPath:[paths lastObject] error: &error];
    
    if (dictionary) {
        NSNumber *fileSystemSizeInBytes = [dictionary objectForKey: NSFileSystemSize];
        NSNumber *freeFileSystemSizeInBytes = [dictionary objectForKey:NSFileSystemFreeSize];
        totalSpace = [fileSystemSizeInBytes unsignedLongLongValue];
        totalFreeSpace = [freeFileSystemSizeInBytes unsignedLongLongValue];
//        NSLog(@"Memory Capacity of %llu MiB with %llu MiB Free memory available.", ((totalSpace/1024ll)/1024ll), ((totalFreeSpace/1024ll)/1024ll));
        deviceSpace.totalSpace = (totalSpace/1024ll)/1024ll;
        deviceSpace.availableSpace = (totalFreeSpace/1024ll)/1024ll;
        return deviceSpace;
    } else {
        return nil;
    }
}

+ (VSDeviceStatus*)getDeviceStatus
{
    UIDevice *device = [UIDevice currentDevice];
    device.batteryMonitoringEnabled = YES;
    VSDeviceStatus *deviceStatus = [[VSDeviceStatus alloc] init];
    deviceStatus.CPUUsage = [YDDeviceUtility currentCPUUsage];
    deviceStatus.batteryState = device.batteryState;
    deviceStatus.batteryLevel = device.batteryLevel;
    return deviceStatus;
}

+ (VSNetworkType)getCurrentNetworkType
{
    AppDelegate *appdelegate = [UIApplication sharedApplication].delegate;
    NetworkStatus status = [[appdelegate internetConnectionReachability] currentReachabilityStatus];
    if(status == NotReachable)
    {
        //No internet
        return VSNetworkTypeNoInternet;
    }
    else if (status == ReachableViaWiFi)
    {
        //WiFi
        return VSNetworkTypeWifi;
    }
    else if (status == ReachableViaWWAN)
    {
        return VSNetworkType3G;
    }
    
    return VSNetworkTypeNoInternet;
}

@end

