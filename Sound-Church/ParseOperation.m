//
//  ParseOperation.m
//  Sound-Church
//
//  Created by John Ahrens on 6/5/11.
//  Copyright ©2011 John Ahrens, LLC. All rights reserved.
//

#import "ParseOperation.h"
#import "Item.h"

static NSString *rssFeedURLString = @"http://feeds.feedburner.com/SoundChurch";

// Notification string for sending podcast data back to the App_Delegate
NSString *kParsePodcastsNofification = @"parsePodcastsNotification";
NSString *kPodcastResultsKey = @"podcastResultsKey";
NSString *kAddPodcastsNotification = @"addPodcastsNotification";
NSString *kParsePodcastsError = @"parsePodcastsError";
NSString *kPodcastsMsgErrorKey = @"PodcastsMsgErrorKey";

@interface ParseOperation () <NSXMLParserDelegate>

@property (nonatomic, retain) NSMutableArray *currentParseBatch;
@property (nonatomic, retain) NSMutableString *currentParsedCharacterData;
@property (nonatomic, assign) NSManagedObjectContext *context;
@property (nonatomic, retain) NSMutableSet *podcasts;
@property (nonatomic, assign) BOOL isInItem;

@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *author;
@property (nonatomic, retain) NSString *summary;
@property (nonatomic, retain) NSDate *pubDate;
@property (nonatomic, retain) NSString *contentURL;
@property (nonatomic, retain) NSString *guid;
@property (nonatomic, retain) NSString *imageURL;

@end

@implementation ParseOperation

@synthesize podcastData;
@synthesize currentParsedCharacterData;
@synthesize currentParseBatch;
@synthesize context;
@synthesize podcasts;
@synthesize isInItem;
@synthesize title;
@synthesize author;
@synthesize summary;
@synthesize pubDate;
@synthesize contentURL;
@synthesize guid;
@synthesize imageURL;

-  (id)initWithManagedObjectContext:(NSManagedObjectContext *)inContext 
{
    if ((self = [super init])) 
    {
        self.context = inContext;
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:-28800]]; // Pacific Standard Time
        [dateFormatter setLocale:[[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"] autorelease]];
        [dateFormatter setDateFormat: @"EEE, dd MMM yyyy HH:MM:ss ZZZ"];
        self.isInItem = NO;
    }
    
    return self;
}

- (void)addPodcastsToList: (Item *)inPodcast 
{
    NSLog(@"Entering [ParseOperation addPodcastsToList: %@]", inPodcast.title);
    
    assert([NSThread isMainThread]);
    
    [[NSNotificationCenter defaultCenter] postNotificationName: kAddPodcastsNotification
                                                        object: self
                                                      userInfo: [NSDictionary dictionaryWithObject: inPodcast
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
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    self.currentParseBatch = nil;
    self.currentParsedCharacterData = nil;
}

- (void)dealloc 
{
    [podcastData release];
    
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
static NSString *const kLinkElementName = @"link";
static NSString *const kTitleElementName = @"title";
static NSString *const kLastBuildDateElementName = @"lastBuildDate";
static NSString *const kPubDateElementName = @"pubDate";
static NSString *const kItemElementName = @"item";
static NSString *const kSubtitleElementName = @"itunes:subtitle";
static NSString *const kAuthorElementName = @"itunes:author";
static NSString *const kSummaryElementName = @"itunes:summary";
static NSString *const kGUIDElementName = @"guid";
static NSString *const kContentURLElementName = @"media:content";
static NSString *const kImageURLElementName = @"media:thumbnail";

#pragma mark - NSXMLParser delegate methods

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI
 qualifiedName:(NSString *)qName
    attributes:(NSDictionary *)attributeDict 
{
    if ([elementName isEqualToString: kItemElementName]) 
    {
        // Nothing to do here right now.
        self.isInItem = YES;
    } 
    else if ([elementName isEqualToString: kTitleElementName] ||
               [elementName isEqualToString: kLastBuildDateElementName] ||
               [elementName isEqualToString: kPubDateElementName] ||
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
        self.contentURL = [attributeDict valueForKey:@"url"];
    }
    else if ([elementName isEqualToString: kImageURLElementName])
    {
        self.imageURL = [attributeDict valueForKey: @"url"];
    }
    else
    {
        // Nothing to do here.
    }
}

- (void)parser:(NSXMLParser *)parser 
 didEndElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI
 qualifiedName:(NSString *)qName 
{    
    if (!self.isInItem)
    {
        // We are not creating an Item, so skip ahead
        return;
    }
    
    if ([elementName isEqualToString: kItemElementName]) 
    {
        NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
        NSPredicate *predicate = [NSPredicate predicateWithFormat: @"guid MATCHES %@", self.guid];
        [request setPredicate: predicate];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Item" 
                                                  inManagedObjectContext:self.context];
        [request setEntity: entity];
        NSError *error = [[[NSError alloc] init] autorelease];
        NSArray *items = [[self.context executeFetchRequest: request error: &error] copy];
        if (!items)
        {
            // TODO: Need to do better error handling.
            NSLog(@"Error fetching items. %@", [error localizedDescription]);
            [items release];
            return;
        }
        
        if (0 < [items count]) 
        {
            for (id item in items)
            {
                if (NSOrderedSame == [self.guid compare: ((Item *)item).guid])
                {
                    // This is a duplicate element, we don't want to save it.
                    [items release];
                    return;
                }
            }
            
            // If you get here, the currentItemObject is not in the managedObjectStore so continue
        }
        
        [items release];
        Item *item = [NSEntityDescription insertNewObjectForEntityForName: @"Item"
                                                   inManagedObjectContext: context];
        item.author = self.author;
        item.pubDate = self.pubDate;
        item.title = self.title;
        item.summary = self.summary;
        item.guid = self.guid;
        item.contentUrl = self.contentURL;
        item.imageUrl = self.imageURL;
        if (![[contentURL pathExtension] isEqualToString: @"mp3"])
        {
            item.deleted = [NSNumber numberWithBool: YES];
        }
        
        [self.context insertObject: item];
        if (![self.context save: &error])
        {
            NSLog(@"Error with saving: %@, %@", [error localizedDescription], [error userInfo]);
        }
        
        self.author = nil;
        self.pubDate = nil;
        self.title = nil;
        self.summary = nil;
        self.guid = nil;
        self.contentURL = nil;
        self.imageURL = nil;
    } 
    else if ([elementName isEqualToString: kAuthorElementName]) 
    {
        self.author = [self.currentParsedCharacterData copy];
    }
    else if ([elementName isEqualToString: kPubDateElementName]) 
    {
        struct tm timestruct;
        const char *formatString = "%a, %d %b %Y %k:%M:%S %z";
        (void)strptime([self.currentParsedCharacterData cStringUsingEncoding: NSUTF8StringEncoding], formatString, &timestruct);
        self.pubDate = [NSDate dateWithTimeIntervalSince1970: mktime(&timestruct)];
    }
    else if ([elementName isEqualToString: kTitleElementName]) 
    {
        self.title = [self.currentParsedCharacterData copy];
    }
    else if ([elementName isEqualToString: kSummaryElementName]) 
    {
        self.summary = [self.currentParsedCharacterData copy];
    }
    else if ([elementName isEqualToString: kGUIDElementName]) 
    {
        self.guid = [self.currentParsedCharacterData copy];
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
    if ([parseError code] != NSXMLParserDelegateAbortedParseError)
    {
        [self performSelectorOnMainThread:@selector(handlePodcastsError:)
                               withObject:parseError
                            waitUntilDone:NO];
    }
}

@end
