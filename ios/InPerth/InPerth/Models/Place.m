//
//  Place.m
//  InPerth
//
//  Created by Callum Jones on 16/07/11.
//  Copyright (c) 2011 mullac.org. All rights reserved.
//

#import "Place.h"


@implementation Place
@dynamic ServerKey;
@dynamic Title;
@dynamic CreatedAt;
@dynamic LastUpdated;
@dynamic Phone;
@dynamic Address;
@dynamic Suburb;
@dynamic Description;
@dynamic Type;
@dynamic UrbanspoonURI;
@dynamic GoogleURI;
@dynamic FoursquareURI;
@dynamic SiteURI;
@dynamic Latitude;
@dynamic Longitude;
@dynamic Tags;
@dynamic Stubs;

-(PlaceAnnotation *)generatePlaceData
{
    PlaceAnnotation *anno = [PlaceAnnotation buildFromLatitude:[self.Latitude doubleValue] withLongitude:[self.Longitude doubleValue]];
    [anno setPlaceTitle:[self Title]];
    [anno setPlaceSubtitle:[self Address]];
    return anno;
}

@end
