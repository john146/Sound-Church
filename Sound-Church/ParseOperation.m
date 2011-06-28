//
//  ParseOperation.m
//  Sound-Church
//
//  Created by John Ahrens on 6/5/11.
//  Copyright 2011 John Ahrens, LLC. All rights reserved.
//

#import "ParseOperation.h"

// Notification string for sending podcast data back to the App_Delegate
NSString *kParsePodcastsNofification = @"parsePodcastsNotification";
NSString *kPodcastResultsKey = @"podcastResultsKey";
NSString *kAddPodcastsNotification = @"addPodcastsNotification";
NSString *kParsePodcastsError = @"parsePodcastsError";

@interface ParseOperation () <NSXMLParserDelegate>

@property (nonatomic, retain) Podcast *currentPodcastObject;
@property (nonatomic, retain) NSMutableArray *currentParseBatch;
@property (nonatomic, retain) NSMutableString *currentParsedCharacterData;

@end

@implementation ParseOperation

@synthesize podcastData;
@synthesize currentEarthquakeObject;
@synthesize currentParsedCharacterData;
@synthesize currentParseBatch;

-  (id)initWithData: (NSData *)data {
    if (self = [super init]) {
        podcastData = [data copy];
        
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
        [dateFormatter setLocale:[[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"] autorelease]];
        [dateFormatter setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ss'Z'"];
    }
    
    return self;
}

- (void)addPodcastsToList: (NSArray *)podcasts {
    assert([NSThread isMainThread]);
    
    [[NSNotificationCenter defaultCenter] postNotificationName: kAddPodcastsNotification
                                                        object: self
                                                      userInfo: [NSDictionary dictionaryWithObject: podcasts
                                                                                            forKey: kPodcastResultsKey]];
}

/**
 * The main function to start the processing the parsing
 */
- (void)main {
    self.currentParseBatch = [NSMutableArray array];
    self.currentParsedCharacterData = [NSMutableString string];
    
    // It's also possible to have NSXMLParser download the data, by passing it a URL, but this is
    // not desirable because it gives less control over the network, particularly in responding to
    // connection errors.
    NSXMLParser *parser = [[NSXMLParser alloc] initWithData: self.podcastData];
    [parser setDelegate:self];
    [parser parse];
    
    // depending on the total number of podcasts parsed, the last batch might not have been a
    // "full" batch, and thus not been part of the regular batch transfer. So, we check the count of
    // the array and, if necessary, send it to the main thread.
    if ([self.currentParseBatch count] > 0) {
        [self performSelectorOnMainThread: @selector(addPodcastsToList:)
                               withObject: self.currentParseBatch
                            waitUntilDone: NO];
    }
    
    self.currentParseBatch = nil;
    self.currendPodcastObject = nil;
    self.currentParsedCharacterData = nil;
    
    [parser release];
}

@end
