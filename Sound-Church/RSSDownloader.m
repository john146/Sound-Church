//
//  RSSDownloader.m
//  Sound-Church
//
//  Created by John Ahrens on 5/21/11.
//  Copyright 2011 John Ahrens, LLC. All rights reserved.
//

#import "RSSDownloader.h"

static NSString *rssFeedURLString = @"feed://feeds.feedburner.com/SoundChurch";

@implementation RSSDownloader

- (id)init {
    if ((self = [super init])) {
        NSURLRequest *request = [NSURLRequest requestWithURL: [NSURL URLWithString: rssFeedURLString]];
        [self initializeConnection: request];
    }
    
    return self;
}

- (NSURLConnection *)initializeConnection: (NSURLRequest *)request {
    NSURLConnection *connection = [[[NSURLConnection alloc] initWithRequest: request delegate: self] autorelease];
    
    return connection;
}

- (void)dealloc {
    [super dealloc];
}

#pragma mark -
#pragma mark NSURLConnection Delegate Methods
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    NSLog(@"Response from connection: %@", [response MIMEType]);
}

@end
