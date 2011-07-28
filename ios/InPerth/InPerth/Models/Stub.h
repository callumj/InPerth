//
//  Stub.h
//  InPerth
//
//  Created by Callum Jones on 4/07/11.
//  Copyright (c) 2011 mullac.org. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Provider.h"
#import "Place.h"

@interface Stub : NSManagedObject {
@private
}
@property (nonatomic, retain) NSString * Title;
@property (nonatomic, retain) NSString * ServerKey;
@property (nonatomic, retain) NSString * URI;
@property (nonatomic, retain) NSString * Description;
@property (nonatomic, retain) NSString * Tags;
@property (nonatomic, retain) NSString * Classifier;
@property (nonatomic, retain) NSDate * Date;
@property (nonatomic, retain) NSString * OfflineArchive;
@property (nonatomic, retain) NSNumber * OfflineDownloaded;
@property (nonatomic, retain) Provider * ContentProvider;
@property (nonatomic, retain) Place * Place;

@end
