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
@property (nonatomic, retain)NSMutableData *podcastData;
@property (nonatomic, retain)NSOperationQueue *parseQueue;

- (void)handleError:(NSError *)error;

@end

@implementation RSSDownloader

@synthesize podcastFeedConnection;
@synthesize podcastData;
@synthesize parseQueue;

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

#pragma mark - NSURLConnection Delegate Methods
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    NSLog(@"Response from connection: %@", [response MIMEType]);
    // check for HTTP status code for proxy authentication failures 7
    // anything in the 200 to 299 range is considered successful,
    // also make sure the MIMEType is correct:
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    if ((([httpResponse statusCode]/100) == 2) && [[response MIMEType] isEqual:@"application/rss+xml"]) {
        self.podcastData = [NSMutableData data];
    } else {
        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:
                                  NSLocalizedString(@"HTTP Error",
                                                    @"Error message displayed when receving a connection error.")
                                                             forKey:NSLocalizedDescriptionKey];
        NSError *error = [NSError errorWithDomain:@"HTTP" code:[httpResponse statusCode] userInfo:userInfo];
        [self handleError:error];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    // TODO: Need to feed a progress bar.
    [podcastData appendData: data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError: (NSError *)error {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;   
    if ([error code] == kCFURLErrorNotConnectedToInternet) {
        // if we can identify the error, we can present a more precise message to the user.
        NSDictionary *userInfo = [NSDictionary dictionaryWithObject: NSLocalizedString(@"No Connection Error",
                                                                                       @"Error message displayed when not connected to the Internet.")
                                                             forKey: NSLocalizedDescriptionKey];
        NSError *noConnectionError = [NSError errorWithDomain: NSCocoaErrorDomain
                                                         code: kCFURLErrorNotConnectedToInternet
                                                     userInfo: userInfo];
        [self handleError: noConnectionError];
    } else {
        // otherwise handle the error generically
        [self handleError: error];
    }
    
    //    self.podcastFeedConnection = nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    //    self.podcastFeedConnection = nil;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;   
    
    // Spawn an NSOperation to parse the earthquake data so that the UI is not blocked while the
    // application parses the XML data.
    //
    // IMPORTANT! - Don't access or affect UIKit objects on secondary threads.
    //
    ParseOperation *parseOperation = [[ParseOperation alloc] initWithData: self.podcastData];
    [self.parseQueue addOperation: parseOperation];
    [parseOperation release];   // once added to the NSOperationQueue it's retained, we don't need it anymore
    
    //  podcastData will be retained by the NSOperation until it has finished executing,
    // so we no longer need a reference to it in the main thread.
    self.podcastData = nil;
}

// TODO: Handle errors in the download by showing an alert to the user. This is a very
// simple way of handling the error, partly because this application does not have any offline
// functionality for the user. Most real applications should handle the error in a less obtrusive
// way and provide offline functionality to the user.
- (void)handleError:(NSError *)error {
    NSString *errorMessage = [error localizedDescription];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:
                              NSLocalizedString(@"Error Title",
                                                @"Title for alert displayed when download or parse error occurs.")
                                                        message:errorMessage
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
    [alertView show];
    [alertView release];
}

@end
