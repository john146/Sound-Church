//
//  Sound_ChurchAppDelegate.h
//  Sound-Church
//
//  Created by John Ahrens on 5/14/11.
//  Copyright 2011 John Ahrens, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class NSURLConnection;

@interface Sound_ChurchAppDelegate : NSObject <UIApplicationDelegate> {

@private
    NSURLConnection *podcastFeedConnection;
    NSOperationQueue *parseQueue;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;

@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

@property (nonatomic, retain) IBOutlet UINavigationController *navigationController;

@end
