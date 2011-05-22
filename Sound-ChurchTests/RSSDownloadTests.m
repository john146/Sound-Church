//
//  RSSDownloadTests.m
//  Sound-Church
//
//  Created by John Ahrens on 5/21/11.
//  Copyright 2011 John Ahrens, LLC. All rights reserved.
//

#import "RSSDownloadTests.h"
#import "RSSDownloader.h"


@implementation RSSDownloadTests

- (void)setUp {
    
    [super setUp];
}

- (void)tearDown {
    
    [super tearDown];
}

// Test Object Construction
- (void)testConstructor {
    RSSDownloader *downloader = [[[RSSDownloader alloc] init] autorelease];
    STAssertNotNil(downloader, @"Could not initialize RSSDownloader");
}

@end
