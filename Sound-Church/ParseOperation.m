//
//  ParseOperation.m
//  Sound-Church
//
//  Created by John Ahrens on 6/5/11.
//  Copyright 2011 John Ahrens, LLC. All rights reserved.
//

#import "ParseOperation.h"
#import "Channel.h"
#import "Item.h"

static NSString *rssFeedURLString = @"http://feeds.feedburner.com/SoundChurch";

// Notification string for sending podcast data back to the App_Delegate
NSString *kParsePodcastsNofification = @"parsePodcastsNotification";
NSString *kPodcastResultsKey = @"podcastResultsKey";
NSString *kAddPodcastsNotification = @"addPodcastsNotification";
NSString *kParsePodcastsError = @"parsePodcastsError";
NSString *kPodcastsMsgErrorKey = @"PodcastsMsgErrorKey";

@interface ParseOperation () <NSXMLParserDelegate>

@property (nonatomic, assign) Channel *currentChannelObject; 
@property (nonatomic, retain) Item *currentItemObject;
@property (nonatomic, retain) NSMutableArray *currentParseBatch;
@property (nonatomic, retain) NSMutableString *currentParsedCharacterData;
@property (nonatomic, assign) NSManagedObjectContext *context;
@property (nonatomic, retain) NSMutableSet *podcasts;

@end

@implementation ParseOperation

@synthesize podcastData;
@synthesize currentChannelObject;
@synthesize currentItemObject;
@synthesize currentParsedCharacterData;
@synthesize currentParseBatch;
@synthesize context;
@synthesize podcasts;

-  (id)initWithManagedObjectContext:(NSManagedObjectContext *)inContext 
{
    if ((self = [super init])) 
    {
        self.context = inContext;
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:-28800]]; // Pacific Standard Time
        [dateFormatter setLocale:[[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"] autorelease]];
        [dateFormatter setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ss'Z'"];
    }
    
    return self;
}

- (void)addPodcastsToList: (NSArray *)inPodcasts 
{
    assert([NSThread isMainThread]);
    
    [[NSNotificationCenter defaultCenter] postNotificationName: kAddPodcastsNotification
                                                        object: self
                                                      userInfo: [NSDictionary dictionaryWithObject: inPodcasts
                                                                                            forKey: kPodcastResultsKey]];
}

/**
 * The main function to start the processing the parsing
 */
- (void)main
{
    self.currentParseBatch = [NSMutableArray array];
    self.currentParsedCharacterData = [NSMutableString string];
    self.podcasts = [NSMutableSet set];
    
    // It's also possible to have NSXMLParser download the data, by passing it a URL, but this is
    // not desirable because it gives less control over the network, particularly in responding to
    // connection errors.
    NSXMLParser *parser = 
                [[[NSXMLParser alloc] initWithContentsOfURL: [NSURL URLWithString: rssFeedURLString]] autorelease];
    [parser setDelegate:self];
    [parser parse];
    
    // depending on the total number of podcasts parsed, the last batch might not have been a
    // "full" batch, and thus not been part of the regular batch transfer. So, we check the count of
    // the array and, if necessary, send it to the main thread.
    if (self.currentItemObject) 
    {
        [self performSelectorOnMainThread: @selector(addPodcastsToList:)
                               withObject: self.currentParseBatch
                            waitUntilDone: NO];
    }
    
    self.currentParseBatch = nil;
    self.currentItemObject = nil;
    self.currentParsedCharacterData = nil;
}

- (void)dealloc 
{
    [podcastData release];
    
    [currentItemObject release];
    [currentParsedCharacterData release];
    [currentParseBatch release];
    [dateFormatter release];
    [podcasts release];
    
    [super dealloc];
}

#pragma mark - Parser constants

// Limit the number of parsed podcasts to 50
// (a given day may have more than 50 podcasts around the world, so we only take the first 50)
static const const NSUInteger kMaximumNumberOfPodcastsToParse = 50;

// When a Podcast object has been fully constructed, it must be passed to the main thread and
// the table view in RootViewController must be reloaded to display it. It is not efficient to do
// this for every Podcast object - the overhead in communicating between the threads and reloading
// the table exceed the benefit to the user. Instead, we pass the objects in batches, sized by the
// constant below. In your application, the optimal batch size will vary 
// depending on the amount of data in the object and other factors, as appropriate.
static NSUInteger const kSizeOfPodcastBatch = 10;

// Reduce potential parsing errors by using string constants declared in a single place.
static NSString *const kChannelElementName = @"channel";
static NSString *const kLinkElementName = @"link";
static NSString *const kTitleElementName = @"title";
static NSString *const kLastBuildDateElementName = @"lastBuildDate";
static NSString *const kPubDateElementName = @"pubDate";
static NSString *const kDescriptionElementName = @"description";
static NSString *const kItemElementName = @"item";
static NSString *const kItemDescriptionElementName = @"description";
static NSString *const kCategoryElementName = @"category";
static NSString *const kSubtitleElementName = @"itunes:subtitle";
static NSString *const kAuthorElementName = @"itunes:author";
static NSString *const kSummaryElementName = @"itunes:summary";
static NSString *const kGUIDElementName = @"guid";
static NSString *const kContentURLElementName = @"media:content";

#pragma mark - NSXMLParser delegate methods

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI
 qualifiedName:(NSString *)qName
    attributes:(NSDictionary *)attributeDict 
{
    // If the number of parsed earthquakes is greater than
    // kMaximumNumberOfPodcastsToParse, abort the parse.
    if (parsedPodcastsCounter >= kMaximumNumberOfPodcastsToParse) 
    {
        // Use the flag didAbortParsing to distinguish between this deliberate stop
        // and other parser errors.
        didAbortParsing = YES;
        [parser abortParsing];
    }
    
    if ([elementName isEqualToString: kChannelElementName]) 
    {
        parsingItem = NO;
        NSManagedObject *channel = [NSEntityDescription insertNewObjectForEntityForName: @"Channel" 
                                                                 inManagedObjectContext:context];
        self.currentChannelObject = (Channel *)channel;
        [channel release];
    } 
    else if ([elementName isEqualToString: kItemElementName]) 
    {
        parsingItem = YES;
        NSManagedObject *item = [NSEntityDescription insertNewObjectForEntityForName: @"Item"
                                                              inManagedObjectContext: context];
        self.currentItemObject = (Item *)item;
        [item release];
    } 
    else if (nil == currentItemObject && [elementName isEqualToString: kLinkElementName]) 
    {
        // if currentItemObject is nil, we must be dealing with the Channel object.
        // The link element is different for the Channel than it is in the Item, so parsed differently.
        // If currentItemObject is nil, we must be dealing with the channel object.
        // For the 'link', element begin accumulationg parsed character data. 
        // The contents are collected in parser:foundCharacters.
        accumulatingParsedCharacterData = YES;
        // The mutable string needs to be reset to empty.
        [currentParsedCharacterData setString: @""];
    } 
    else if ([elementName isEqualToString: kTitleElementName] ||
               [elementName isEqualToString: kLastBuildDateElementName] ||
               [elementName isEqualToString: kPubDateElementName] ||
               [elementName isEqualToString: kDescriptionElementName] ||
               [elementName isEqualToString: kItemDescriptionElementName] ||
               [elementName isEqualToString: kCategoryElementName] ||
               [elementName isEqualToString: kSubtitleElementName] ||
               [elementName isEqualToString: kAuthorElementName] ||
               [elementName isEqualToString: kLinkElementName] ||
               [elementName isEqualToString: kSummaryElementName] ||
               [elementName isEqualToString: kGUIDElementName]) 
    {
        accumulatingParsedCharacterData = YES;
        // The mutable string needs to be reset to empty.
        [currentParsedCharacterData setString: @""];
    } 
    else if ([elementName isEqualToString:kContentURLElementName]) 
    {
        self.currentItemObject.contentUrl = [attributeDict valueForKey:@"url"];
    }
    else
    {
        // Nothing to do here.
    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI
 qualifiedName:(NSString *)qName 
{     
    if ([elementName isEqualToString: kChannelElementName]) 
    {
        // self.currentChannelObject.items = self.podcasts;
        // According to my understanding, this should automatically be assigned to the correct store.
    } else if (NO == parsingItem) 
    {
        if ([elementName isEqualToString: kLinkElementName]) 
        {
            self.currentChannelObject.link = self.currentParsedCharacterData;
        }
        else if ([elementName isEqualToString: kTitleElementName]) 
        {
            self.currentChannelObject.title = self.currentParsedCharacterData;
        } 
        else if ([elementName  isEqualToString: kLastBuildDateElementName]) 
        {
            self.currentChannelObject.lastBuildDate = [dateFormatter dateFromString: self.currentParsedCharacterData];
        } 
        else if ([elementName isEqualToString: kPubDateElementName]) 
        {
            self.currentChannelObject.pubDate = [dateFormatter dateFromString: self.currentParsedCharacterData];
        } 
        else if ([elementName isEqualToString: kDescriptionElementName]) 
        {
            self.currentChannelObject.desc = self.currentParsedCharacterData;
        } 
        else 
        {
            // Do nothing here as we don't care about these values.
        }
    } 
    else if ([elementName isEqualToString: kItemElementName]) 
    {
        self.currentItemObject.channel = self.currentChannelObject;
        [self.currentParseBatch addObject: self.currentItemObject];
        // [self.podcasts addObject: self.currentItemObject];
    } 
    else if (YES ==  parsingItem)
    {
        if ([elementName isEqualToString: kItemDescriptionElementName]) 
        {
            self.currentItemObject.itemDescription = self.currentParsedCharacterData;
        } 
        else if ([elementName isEqualToString: kCategoryElementName]) 
        {
            self.currentItemObject.category = self.currentParsedCharacterData;
        } 
        else if ([elementName isEqualToString: kSubtitleElementName]) 
        {
            self.currentItemObject.subtitle = self.currentParsedCharacterData;
        } 
        else if ([elementName isEqualToString: kAuthorElementName]) 
        {
            self.currentItemObject.author  = self.currentParsedCharacterData;
        }
        else if ([elementName isEqualToString: kLinkElementName]) 
        {
            self.currentItemObject.link = self.currentParsedCharacterData;
        }
        else if ([elementName isEqualToString: kPubDateElementName]) 
        {
            self.currentItemObject.pubDate = [dateFormatter dateFromString: self.currentParsedCharacterData];
        }
        else if ([elementName isEqualToString: kTitleElementName]) 
        {
            self.currentItemObject.title = self.currentParsedCharacterData;
        }
        else if ([elementName isEqualToString: kSummaryElementName]) 
        {
            self.currentItemObject.summary = self.currentParsedCharacterData;
        }
        else if ([elementName isEqualToString: kGUIDElementName]) 
        {
            self.currentItemObject.guid = self.currentParsedCharacterData;
        }
    }
    
    // Stop accumulating parsed character data. We won't start again until specific elements begin.
    accumulatingParsedCharacterData = NO;
}

// This method is called by the parser when it find parsed character data ("PCDATA") in an element.
// The parser is not guaranteed to deliver all of the parsed character data for an element in a single
// invocation, so it is necessary to accumulate character data until the end of the element is reached.
- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string 
{
    if (accumulatingParsedCharacterData) 
    {
        // If the current element is one whose content we care about, append 'string'
        // to the property that holds the content of the current element.
        [self.currentParsedCharacterData appendString:string];
    }
}

// an error occurred while parsing the podcast data,
// post the error as an NSNotification to our app delegate.
- (void)handlePodcastsError:(NSError *)parseError 
{
    [[NSNotificationCenter defaultCenter] postNotificationName: kParsePodcastsError
                                                        object: parseError
                                                      userInfo: [NSDictionary dictionaryWithObject:parseError
                                                                                            forKey:kPodcastsMsgErrorKey]];
}

// an error occurred while parsing the earthquake data,
// pass the error to the main thread for handling.
// (note: don't report an error if we aborted the parse due to a max limit of earthquakes)
- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError 
{
    if ([parseError code] != NSXMLParserDelegateAbortedParseError && !didAbortParsing)
    {
        [self performSelectorOnMainThread:@selector(handlePodcastsError:)
                               withObject:parseError
                            waitUntilDone:NO];
    }
}

@end
