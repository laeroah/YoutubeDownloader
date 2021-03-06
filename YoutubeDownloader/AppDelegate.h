//
//  AppDelegate.h
//  YoutubeDownloader
//
//  Created by HAO WANG on 10/31/13.
//  Copyright (c) 2013 HAO WANG. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Reachability.h"
#import "GAI.h"

typedef void (^DownloadTaskBlock)();

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;


@property (nonatomic, assign) BOOL networkAvailable;

@property (strong, nonatomic) Reachability *internetConnectionReachability;
@property (strong, nonatomic) DownloadTaskBlock backgroundURLSessionCompletionHandler;


- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

@end
