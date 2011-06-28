//
//  ParseOperation.h
//  Sound-Church
//
//  Created by John Ahrens on 6/5/11.
//  Copyright 2011 John Ahrens, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *kAddPodcastsNotification;
extern NSString *kPodcastResultsKey;

extern NSString *kParsePodcastsNofification;
extern NSString *kParsePodcastsError;

@interface ParseOperation : NSOperation {
    NSData *podcastData;
    
@private
    NSDateFormatter *dateFormatter;
    
    // These variables are used during parsing
    Podcast *currentPodcastObject;
    NSMutableArray *currentParseBatch;
    NSMutableString *currentParsedCharacterData;

    BOOL accumulatingParsedCharacterData;
    BOOL didAbortParsing;
    NSUInteger parsedPodcastsCounter;
}

@property (copy, readonly)NSData *podcastData;

@end
