//
//  RSSDownloader.h
//  Sound-Church
//
//  Created by John Ahrens on 5/21/11.
//  Copyright 2011 John Ahrens, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface RSSDownloader : NSObject {
    
@private
    NSURLConnection *podcastFeedConnection;
    NSMutableData *podcastData;
    NSOperationQueue *parseQueue;
}

@end

@protocol RSSDownloaderDelegate <NSObject>

- (void)downloadStarted;

@end