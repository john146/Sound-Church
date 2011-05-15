//
//  RootViewController.h
//  Sound-Church
//
//  Created by John Ahrens on 5/14/11.
//  Copyright 2011 John Ahrens, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <CoreData/CoreData.h>

@interface RootViewController : UITableViewController <NSFetchedResultsControllerDelegate> {

}

@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

@end
