//
//  Item.h
//  Sound-Church
//
//  Created by John Ahrens on 6/30/11.
//  Copyright (c) 2011 John Ahrens, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Channel;

@interface Item : NSManagedObject {
@private
}

@property (nonatomic, retain) NSString * itemDescription;
@property (nonatomic, retain) NSString * category;
@property (nonatomic, retain) NSString * subtitle;
@property (nonatomic, retain) NSData * message;
@property (nonatomic, retain) NSString * author;
@property (nonatomic, retain) NSString * link;
@property (nonatomic, retain) NSDate * pubDate;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * summary;
@property (nonatomic, retain) NSString * guid;
@property (nonatomic, retain) NSString * contentUrl;
@property (nonatomic, retain) NSSet* item;

@end
