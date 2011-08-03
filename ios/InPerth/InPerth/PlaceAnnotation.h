//
//  PlaceAnnotation.h
//  InPerth
//
//  Created by Callum Jones on 3/08/11.
//  Copyright 2011 mullac.org. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface PlaceAnnotation : NSObject<MKAnnotation>

@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property (nonatomic, retain) NSString *placeTitle;
@property (nonatomic, retain) NSString *placeSubtitle;

+(PlaceAnnotation *)buildFromLatitude:(double)latVal withLongitude:(double)longVal;

- (id)initWithCoordinate:(CLLocationCoordinate2D)coord;

@end
