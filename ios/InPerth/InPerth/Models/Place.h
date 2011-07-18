//
//  Place.h
//  InPerth
//
//  Created by Callum Jones on 16/07/11.
//  Copyright (c) 2011 mullac.org. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface Place : NSManagedObject {
@private
}
@property (nonatomic, retain) NSString * ServerKey;
@property (nonatomic, retain) NSString * Title;
@property (nonatomic, retain) NSDate * CreatedAt;
@property (nonatomic, retain) NSDate * LastUpdated;
@property (nonatomic, retain) NSString * Phone;
@property (nonatomic, retain) NSString * Address;
@property (nonatomic, retain) NSString * Suburb;
@property (nonatomic, retain) NSString * Description;
@property (nonatomic, retain) NSString * Type;
@property (nonatomic, retain) NSString * UrbanspoonURI;
@property (nonatomic, retain) NSString * GoogleURI;
@property (nonatomic, retain) NSString * FoursquareURI;
@property (nonatomic, retain) NSString * SiteURI;
@property (nonatomic, retain) NSNumber * Latitude;
@property (nonatomic, retain) NSNumber * Longitude;
@property (nonatomic, retain) NSString * Tags;
@property (nonatomic, retain) NSSet* Stubs;

@end
