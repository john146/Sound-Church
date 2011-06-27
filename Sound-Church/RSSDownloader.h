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
    RSSDownloaderDelegate *delegate;
}

- (id)initWithDelegate: (id)delegate;

@end

@protocol RSSDownloaderDelegate <NSObject>
/**
 * if connection:didReceiveResponse: returns a bad response (anything other than HTTP 2xx),
 * this method will include an error with the conditions in it. Otherwise, the error field will be null.
 */
- (void)downloader: (RSSDownloader *)downloader didReceiveResponseError: (NSError *)error;
- (void)downloader:(RSSDownloader *)downloader didReceiveData: (NSData *)data;
- (void)downloader:(RSSDownloader *)downloader didFailWithError: (NSError *)error;

@end