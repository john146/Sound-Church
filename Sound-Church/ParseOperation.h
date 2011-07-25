//
//  ParseOperation.h
//  Sound-Church
//
//  Created by John Ahrens on 6/5/11.
//  Copyright ©2011 John Ahrens, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *kAddPodcastsNotification;
extern NSString *kPodcastResultsKey;

extern NSString *kParsePodcastsNofification;
extern NSString *kParsePodcastsError;
extern NSString *kPodcastsMsgErrorKey;

@class Item;

@interface ParseOperation : NSOperation {
    NSData *podcastData;
    
@private
    NSDateFormatter *dateFormatter;
    
    // These variables are used during parsing
    NSMutableString *currentParsedCharacterData;
    NSManagedObjectContext *context;

    BOOL accumulatingParsedCharacterData;
    BOOL isInItem;
    
    // Fields
    NSString *title;
    NSString *author;
    NSString *summary;
    NSDate *pubDate;
    NSString *contentURL;
    NSString *guid;
    NSString *imageURL;
}

@property (copy, readonly)NSData *podcastData;

- (id)initWithManagedObjectContext: (NSManagedObjectContext *)context;

@end
