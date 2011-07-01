//
//  RSSDownloadTests.m
//  Sound-Church
//
//  Created by John Ahrens on 5/21/11.
//  Copyright 2011 John Ahrens, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OCMock/OCMock.h>

#import "RSSDownloadTests.h"
#import "RSSDownloader.h"

@implementation RSSDownloadTests

- (void)setUp {
    downloader = [[RSSDownloader alloc] initWithDelegate: nil];
    [super setUp];
}

- (void)tearDown {
    [downloader release];
    
    [super tearDown];
}

// Test Object Construction
- (void)testConstructor {
    id mock = [OCMockObject mockForProtocol:@protocol(RSSDownloaderDelegate)];
    RSSDownloader *myDownloader;
    NSData *data;
    [[mock expect] downloader: myDownloader didReceiveData: data];
    myDownloader = [[[RSSDownloader alloc] initWithDelegate: mock] autorelease];
    STAssertNotNil(myDownloader, @"Could not initialize RSSDownloader");
}

// Test connection:didReceiveResponse:
-  (void)testConnectionDidReceiveResponse {
    
}

#pragma mark - OCMock Methods
- (NSURLConnection *)fakeInitWithRequest: (NSURLRequest *)request delegate: (id)delegate {
    STAssertNotNil(request, @"Failed to get valid NSURLRequest object");
    NSString *urlStringExpected = @"feed://feeds.feedburner.com/SoundChurch";
    NSString *urlStringActual = [request.URL absoluteString];
    STAssertTrue(urlStringActual == urlStringExpected, 
                 @"Failed to set correct string. Expected %@, but got %@", urlStringExpected, urlStringActual);
    
    return nil;
}

@end
