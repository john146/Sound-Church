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
        //      NSURLRequest *request = [NSURLRequest requestWithURL: [NSURL URLWithString: rssFeedURLString]];
        //NSURLConnection *connection = [[[NSURLConnection alloc] initWithRequest: request delegate: self] autorelease];
    }
    
    return self;
}

- (NSURLConnection *)initializeConnection: (NSURLRequest *)request {
    return nil;
}

@end
