//
//  Channel.h
//  Sound-Church
//
//  Created by John Ahrens on 6/30/11.
//  Copyright (c) 2011 John Ahrens, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Channel : NSManagedObject {
@private
}

@property (nonatomic, retain) NSString * link;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSDate * lastBuildDate;
@property (nonatomic, retain) NSDate * pubDate;
@property (nonatomic, retain) NSString * desc;
@property (nonatomic, retain) NSSet * items;

@end
