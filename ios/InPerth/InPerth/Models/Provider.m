//
//  Provider.m
//  InPerth
//
//  Created by Callum Jones on 4/07/11.
//  Copyright (c) 2011 mullac.org. All rights reserved.
//

#import "Provider.h"
#import "Stub.h"


@implementation Provider
@dynamic ServerKey;
@dynamic Title;
@dynamic Stubs;

- (void)addStubsObject:(Stub *)value {    
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    [self willChangeValueForKey:@"Stubs" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    [[self primitiveValueForKey:@"Stubs"] addObject:value];
    [self didChangeValueForKey:@"Stubs" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    [changedObjects release];
}

- (void)removeStubsObject:(Stub *)value {
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    [self willChangeValueForKey:@"Stubs" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    [[self primitiveValueForKey:@"Stubs"] removeObject:value];
    [self didChangeValueForKey:@"Stubs" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    [changedObjects release];
}

- (void)addStubs:(NSSet *)value {    
    [self willChangeValueForKey:@"Stubs" withSetMutation:NSKeyValueUnionSetMutation usingObjects:value];
    [[self primitiveValueForKey:@"Stubs"] unionSet:value];
    [self didChangeValueForKey:@"Stubs" withSetMutation:NSKeyValueUnionSetMutation usingObjects:value];
}

- (void)removeStubs:(NSSet *)value {
    [self willChangeValueForKey:@"Stubs" withSetMutation:NSKeyValueMinusSetMutation usingObjects:value];
    [[self primitiveValueForKey:@"Stubs"] minusSet:value];
    [self didChangeValueForKey:@"Stubs" withSetMutation:NSKeyValueMinusSetMutation usingObjects:value];
}


@end
