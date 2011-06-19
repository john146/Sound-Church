//
//  RSSDownloader.m
//  Sound-Church
//
//  Created by John Ahrens on 5/21/11.
//  Copyright 2011 John Ahrens, LLC. All rights reserved.
//

#import "RSSDownloader.h"

static NSString *rssFeedURLString = @"feed://feeds.feedburner.com/SoundChurch";

@interface RSSDownloader ()
@property (nonatomic, retain)NSURLConnection *podcastFeedConnection;

@end

@implementation RSSDownloader

@synthesize podcastFeedConnection;

- (id)init {
    if ((self = [super init])) {
        NSURLRequest *request = [NSURLRequest requestWithURL: [NSURL URLWithString: rssFeedURLString]];
        self.podcastFeedConnection = [[[NSURLConnection alloc] initWithRequest: request delegate: self] autorelease];
    }
    
    return self;
}

- (void)dealloc {
    [podcastFeedConnection cancel];
    [podcastFeedConnection release];
    
    [super dealloc];
}

#pragma mark -
#pragma mark NSURLConnection Delegate Methods
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    NSLog(@"Response from connection: %@", [response MIMEType]);
}

@end
