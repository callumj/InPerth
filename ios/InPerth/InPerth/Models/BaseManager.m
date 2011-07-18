//
//  BaseManager.m
//  InPerth
//
//  Created by Callum Jones on 16/07/11.
//  Copyright 2011 mullac.org. All rights reserved.
//

#import "BaseManager.h"


@implementation BaseManager

-(id)init
{
    self = [super init];
    if (self != nil)
    {
        InPerthAppDelegate *delegate = (InPerthAppDelegate *)[[UIApplication sharedApplication] delegate]; 
        dataContext = [[delegate managedObjectContext] retain];
        instanceCache = [[[NSMutableDictionary alloc] init] retain];
        dateFormatter = [[[NSDateFormatter alloc] init] retain];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss ZZZ"];
        //[dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"Perth"]];
    }
    
    return self;
}

-(id)initWithExistingContext:(NSManagedObjectContext *)context
{
    self = [super init];
    if (self != nil)
    {
        dataContext = [context retain];
        instanceCache = [[[NSMutableDictionary alloc] init] retain];
        dateFormatter = [[[NSDateFormatter alloc] init] retain];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss ZZZ"];
        //[dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"Perth"]];
    }
    return self;
}

-(id)initWithNewContext
{
    self = [super init];
    if (self != nil)
    {
        dataContext = [[CoreDataHelper managedObjectContext] retain];
        instanceCache = [[[NSMutableDictionary alloc] init] retain];
        dateFormatter = [[[NSDateFormatter alloc] init] retain];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss ZZZ"];
        //[dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"Perth"]];
    }
    return self;
}

@end
