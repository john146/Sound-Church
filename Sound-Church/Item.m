//
//  Item.m
//  Sound-Church
//
//  Created by John Ahrens on 6/30/11.
//  Copyright (c) 2011 John Ahrens, LLC. All rights reserved.
//

#import "Item.h"
#import "Channel.h"


@implementation Item
@dynamic itemDescription;
@dynamic category;
@dynamic subtitle;
@dynamic message;
@dynamic author;
@dynamic link;
@dynamic pubDate;
@dynamic title;
@dynamic summary;
@dynamic guid;
@dynamic contentUrl;
@dynamic channel;

- (void)addItemObject:(Channel *)value {    
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    [self willChangeValueForKey:@"item" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    [[self primitiveValueForKey:@"item"] addObject:value];
    [self didChangeValueForKey:@"item" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    [changedObjects release];
}

- (void)removeItemObject:(Channel *)value {
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    [self willChangeValueForKey:@"item" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    [[self primitiveValueForKey:@"item"] removeObject:value];
    [self didChangeValueForKey:@"item" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    [changedObjects release];
}

- (void)addItem:(NSSet *)value {    
    [self willChangeValueForKey:@"item" withSetMutation:NSKeyValueUnionSetMutation usingObjects:value];
    [[self primitiveValueForKey:@"item"] unionSet:value];
    [self didChangeValueForKey:@"item" withSetMutation:NSKeyValueUnionSetMutation usingObjects:value];
}

- (void)removeItem:(NSSet *)value {
    [self willChangeValueForKey:@"item" withSetMutation:NSKeyValueMinusSetMutation usingObjects:value];
    [[self primitiveValueForKey:@"item"] minusSet:value];
    [self didChangeValueForKey:@"item" withSetMutation:NSKeyValueMinusSetMutation usingObjects:value];
}


@end
