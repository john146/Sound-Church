//
//  Item.h
//  Sound-Church
//
//  Created by John Ahrens on 7/25/11.
//  Copyright (c) 2011 John Ahrens, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Item : NSManagedObject {
@private
}
@property (nonatomic, retain) NSString * author;
@property (nonatomic, retain) NSString * contentUrl;
@property (nonatomic, retain) NSNumber * deleted;
@property (nonatomic, retain) NSString * summary;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * message;
@property (nonatomic, retain) NSString * imageUrl;
@property (nonatomic, retain) NSDate * pubDate;
@property (nonatomic, retain) NSNumber * listenedTo;
@property (nonatomic, retain) NSString * guid;
@property (nonatomic, retain) NSString * image;

@end
