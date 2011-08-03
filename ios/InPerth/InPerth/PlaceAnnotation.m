//
//  PlaceAnnotation.m
//  InPerth
//
//  Created by Callum Jones on 3/08/11.
//  Copyright 2011 mullac.org. All rights reserved.
//

#import "PlaceAnnotation.h"

@implementation PlaceAnnotation
@synthesize coordinate;
@synthesize placeTitle;
@synthesize placeSubtitle;

- (id)initWithCoordinate:(CLLocationCoordinate2D)coord
{   
    coordinate = coord;
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

-(NSString *)title
{
    if (self.placeTitle != nil)
        return [self placeTitle];
    
    return @"";
}

-(NSString *)subtitle
{
    if (self.placeSubtitle != nil)
        return [self placeSubtitle];
    
    return @"";
}

+(PlaceAnnotation *)buildFromLatitude:(double)latVal withLongitude:(double)longVal
{
    CLLocationCoordinate2D coord = CLLocationCoordinate2DMake(latVal, longVal);
    PlaceAnnotation *anno = [[PlaceAnnotation alloc] initWithCoordinate:coord];
    return anno;
}

@end
