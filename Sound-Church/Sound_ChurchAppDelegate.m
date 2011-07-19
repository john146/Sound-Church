//
//  Sound_ChurchAppDelegate.m
//  Sound-Church
//
//  Created by John Ahrens on 5/14/11.
//  Copyright 2011 John Ahrens, LLC. All rights reserved.
//

#import "Sound_ChurchAppDelegate.h"

#import "ParseOperation.h"
#import "RootViewController.h"
#import "FMDatabase.h"

@interface Sound_ChurchAppDelegate () 

@property (nonatomic, retain)NSMutableData *podcastData;
@property (nonatomic, retain)NSOperationQueue *parseQueue;

- (void) handleError: (NSError *)error;
- (void)podcastsError: (NSNotification *)notification;
- (FMDatabase *)setDatabase;

@end

@implementation Sound_ChurchAppDelegate

@synthesize window=_window;
@synthesize navigationController=_navigationController;

@synthesize podcastDatabase;
@synthesize podcastData;
@synthesize parseQueue;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    // Add the navigation controller's view to the window and display.
    self.window.rootViewController = self.navigationController;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
 
    parseQueue = [NSOperationQueue new];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(addPodcasts:)
                                                 name:kAddPodcastsNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(podcastsError:)
                                                 name:kParsePodcastsError
                                               object:nil];
    podcastDatabase = self.podcastDatabase;
    ParseOperation *parseOperation = [[[ParseOperation alloc] initWithManagedObjectContext: self.managedObjectContext] autorelease];
    [self.parseQueue addOperation: parseOperation];

    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    /* TODO:
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
    NSLog(@"Entering applicationWillResignActive:");
    [self saveContext];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /* TODO:
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
    NSLog(@"Entering applicationDidEnterBackground:");
    [self saveContext];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /* TODO:
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /* TODO:
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Saves changes in the application's managed object context before the application terminates.
    NSLog(@"Entering applicationWillTerminate:");
    [self saveContext];
}

- (void)dealloc
{
    [_window release];
    [__managedObjectContext release];
    [__managedObjectModel release];
    [__persistentStoreCoordinator release];
    [_navigationController release];
    [podcastData release];
    [parseQueue release];
    
    
    [super dealloc];
}

- (void)awakeFromNib
{
    RootViewController *rootViewController = (RootViewController *)[self.navigationController topViewController];
    rootViewController.managedObjectContext = self.managedObjectContext;
}

- (void)saveContext
{
    NSLog(@"Entering saveContext");
    
    NSError *error = [[[NSError alloc] init] autorelease];
    if (self.managedObjectContext != nil)
    {
        if ([self.managedObjectContext hasChanges] && ![self.managedObjectContext save:&error])
        {
            /* TODO:
             Replace this implementation with code to handle the error appropriately.
             
             abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
             */
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        } 
    }
}

#pragma mark - Database
- (FMDatabase *)podcastDatabase
{
    NSString *path = [NSHomeDirectory() stringByAppendingPathComponent: @"soundchurch.sqlite"];
    podcastDatabase = [FMDatabase databaseWithPath: path];
    if (!podcastDatabase)
    {
        UIAlertView *alert = [[[UIAlertView alloc] initWithTitle: @"Database Failure"
                                                         message: @"Could not create database"
                                                        delegate: nil
                                               cancelButtonTitle: @"Close"
                                               otherButtonTitles: nil] autorelease];
        [alert show];
    }
    
    if (![podcastDatabase open])
    {
        UIAlertView *alert = [[[UIAlertView alloc] initWithTitle: @"Database Failure"
                                                         message: @"Could not open database"
                                                        delegate: nil
                                               cancelButtonTitle: @"Close"
                                               otherButtonTitles: nil] autorelease];
        [alert show];
    }
}

#pragma mark - Application's Documents directory

/**
 Returns the URL to the application's Documents directory.
 */
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

#pragma mark - NSOperationCenter Callbacks
// Our NSNotification callback from the running NSOperation to add the earthquakes
- (void)addPodcasts:(NSNotification *)notification 
{
    assert([NSThread isMainThread]);
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [self addPodcastsToList:[[notification userInfo] valueForKey: kPodcastResultsKey]];
}

// Our NSNotification callback from the running NSOperation when a parsing error has occurred
- (void)podcastsError: (NSNotification *)notification 
{
    assert([NSThread isMainThread]);
    
    [self handleError:[[notification userInfo] valueForKey: kPodcastsMsgErrorKey]];
}

// The NSOperation "ParseOperation" calls addPodcasts: via NSNotification, on the main thread
// which in turn calls this method, with batches of parsed objects.
- (void)addPodcastsToList:(Item *)item 
{
    NSLog(@"Entering addPodcastsToList: %@.", item.title);
    // insert the podcasts into our rootViewController's data source (for KVO purposes)
    [self.managedObjectContext insertObject: item];
    [self saveContext];
 }

// TODO: Handle errors in the download by showing an alert to the user. This is a very
// simple way of handling the error, partly because this application does not have any offline
// functionality for the user. Most real applications should handle the error in a less obtrusive
// way and provide offline functionality to the user.
- (void)handleError:(NSError *)error 
{
    NSString *errorMessage = [error localizedDescription];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:
                              NSLocalizedString(@"Error Title",
                                                @"Title for alert displayed when download or parse error occurs.")
                                                        message:errorMessage
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
    [alertView show];
    [alertView release];
}

@end
