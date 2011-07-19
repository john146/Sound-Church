//
//  Podcast.m
//  Sound-Church
//
//  Created by John Ahrens on 7/18/11.
//  Copyright 2011 John Ahrens, LLC. All rights reserved.
//

#import "Podcast.h"

NSString *sqlCreate = @"CREATE TABLE IF NOT EXISTS podcast (id INTEGER PRIMARY KEY, title TEXT, author TEXT, guid TEXT, summary TEXT, file_name TEXT, played REAL DEFAULT 0.0, is_displayed TEXT DEFAULT 'YES');";

@implementation Podcast

@synthesize title = _title;
@synthesize author = _author;
@synthesize guid = _guid;
@synthesize summary = _summary;
@synthesize fileName = _fileName;
@synthesize played;
@synthesize isDisplayed;

+ (id)podcastWithTitle:(NSString *)title 
                author:(NSString *)author
                  guid:(NSString *)guid
               summary:(NSString *)summary
                  file:(NSString *)fileName
{
    return [[[Podcast alloc] initWithTitle: title 
                                    author: author
                                      guid: guid
                                   summary: summary
                                      file: fileName] autorelease];
}

- (id)initWithTitle:(NSString *)title
             author:(NSString *)author
               guid:(NSString *)guid
            summary:(NSString *)summary
               file:(NSString *)fileName
{
    if ((self = [super init]))
    {
        _title = title;
        _author = author;
        _guid = guid;
        _summary = summary;
        _fileName = fileName;
        self.played = 0.0;
        self.isDisplayed = YES;
    }
    
    return self;
}

- (void)dealloc
{
    [title release];
    [author release];
    [guid release];
    [summary release];
    [fileName release];
    
    [super dealloc];
}

@end
