//
//  Channel.m
//  Sound-Church
//
//  Created by John Ahrens on 6/30/11.
//  Copyright (c) 2011 John Ahrens, LLC. All rights reserved.
//

#import "Channel.h"
#import "Item.h"


@implementation Channel
@dynamic link;
@dynamic title;
@dynamic lastBuildDate;
@dynamic pubDate;
@dynamic desc;
@dynamic items;

- (void)addItemObject:(Item *)value {    
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    [self willChangeValueForKey:@"item" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    [[self primitiveValueForKey:@"item"] addObject:value];
    [self didChangeValueForKey:@"item" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    [changedObjects release];
}

- (void)removeItemObject:(Item *)value {
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
