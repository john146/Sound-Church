//
//  Sound_ChurchAppDelegate.h
//  Sound-Church
//
//  Created by John Ahrens on 5/14/11.
//  Copyright 2011 John Ahrens, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "RSSDownloader.h"

@class NSURLConnection;
@class FMDatabase;

@interface Sound_ChurchAppDelegate : NSObject <UIApplicationDelegate> {

    FMDatabase *podcastDatabase;

@private
    NSMutableData *podcastData;
    NSOperationQueue *parseQueue;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

@property (nonatomic, retain) IBOutlet UINavigationController *navigationController;
@property (nonatomic, retain) FMDatabase *podcastDatabase;

@end
