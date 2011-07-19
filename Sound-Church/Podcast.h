//
//  Podcast.h
//  Sound-Church
//
//  Created by John Ahrens on 7/18/11.
//  Copyright 2011 John Ahrens, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Podcast : NSObject 
{
    NSString *title;
    NSString *author;
    NSString *guid;
    NSString *summary;
    NSString *fileName;
    double playes; 
    BOOL isDisplayed; 
}

/// The title of the podcast
@property (nonatomic, readonly, retain)NSString *title;

/// The author (speaker) of the podcast
@property (nonatomic, readonly, retain)NSString *author;

/// The unique identifier for the podcast
@property (nonatomic, readonly, retain)NSString *guid;

/// A summary of the podcast.
@property (nonatomic, readonly, retain)NSString *summary;

/// The name of the mp3 file
@property (nonatomic, readonly, retain)NSString *fileName;

/// The amount of this podcast that's been played, 0.0-1.0 (0.0 means nothing played)
@property (assign)double played;

/// YES if the podcast is displayed on the list. otherwise NO
@property (assign)BOOL isDisplayed;

/**
 * Initializer that returns an autoreleased Podcast object
 *
 * @param title The title of the podcast
 * @param author The author (speaker) in the podcast
 * @param guid The unique identifier for the podcast
 * @param summary A summary of the podcast message
 * @param fileName The name of the mp3 file
 *
 * @return Newly initialized Podcast object
 */
+ (id)podcastWithTitle: (NSString *)title
                author: (NSString *)author
                  guid: (NSString *)guid
               summary: (NSString *)summary
                  file: (NSString *)fileName;

/**
 * Initializer that returns a Podcast object
 *
 * @param title The title of the podcast
 * @param author The author (speaker) in the podcast
 * @param guid The unique identifier for the podcast
 * @param summary A summary of the podcast message
 * @param fileName The name of the mp3 file
 *
 * @return Newly initialized Podcast object
 */
- (id)initWithTitle: (NSString *)title
             author: (NSString *)author
               guid: (NSString *)guid
            summary: (NSString *)summary
               file: (NSString *)fileName;

@end
