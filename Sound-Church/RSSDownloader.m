//
//  RSSDownloader.m
//  Sound-Church
//
//  Created by John Ahrens on 5/21/11.
//  Copyright 2011 John Ahrens, LLC. All rights reserved.
//

#import "RSSDownloader.h"
#import "ParseOperation.h"

static NSString *rssFeedURLString = @"http://feeds.feedburner.com/SoundChurch";

@interface RSSDownloader()

@property (nonatomic, retain)NSURLConnection *podcastFeedConnection;
@property (nonatomic, retain)RSSDownloaderDelegate *delegate;

- (void)handleError:(NSError *)error;

@end

@implementation RSSDownloader

@synthesize podcastFeedConnection;
@synthesize delegate;

- (id)initWithDelegate: (id)delegate {
    if ((self = [super init])) {
        self.delegate = delegate;
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

#pragma mark - NSURLConnection Delegate Methods
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    NSLog(@"Response from connection: %@", [response MIMEType]);
    // check for HTTP status code for proxy authentication failures 7
    // anything in the 200 to 299 range is considered successful,
    // also make sure the MIMEType is correct:
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    if ((([httpResponse statusCode]/100) == 2) && [[response MIMEType] isEqual:@"application/rss+xml"]) {
        [delegate downloader: self didReceiveResponseError: nil];
    } else {
        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:
                                  NSLocalizedString(@"HTTP Error",
                                                    @"Error message displayed when receving a connection error.")
                                                             forKey:NSLocalizedDescriptionKey];
        NSError *error = [NSError errorWithDomain:@"HTTP" code:[httpResponse statusCode] userInfo:userInfo];
        [delegate downloader: self didReceiveResponseError: error];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [delegate downloader: self didReceiveData: data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError: (NSError *)error {
    if ([error code] == kCFURLErrorNotConnectedToInternet) {
        // if we can identify the error, we can present a more precise message to the user.
        NSDictionary *userInfo = [NSDictionary dictionaryWithObject: NSLocalizedString(@"No Connection Error",
                                                                                       @"Error message displayed when not connected to the Internet.")
                                                             forKey: NSLocalizedDescriptionKey];
        NSError *noConnectionError = [NSError errorWithDomain: NSCocoaErrorDomain
                                                         code: kCFURLErrorNotConnectedToInternet
                                                     userInfo: userInfo];
        [delegate downloader: self didFailWithError: noConnectionError];
    } else {
        // otherwise handle the error generically
        [delegate downloader: self didFailWithError: error];
    }
    
    self.podcastFeedConnection = nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    self.podcastFeedConnection = nil;
    [downloaderDidFinishLoading: (RSSDownloader *)downloader];
}

@end
