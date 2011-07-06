//
//  Provider.h
//  InPerth
//
//  Created by Callum Jones on 4/07/11.
//  Copyright (c) 2011 mullac.org. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Stub;

@interface Provider : NSManagedObject {
@private
}
@property (nonatomic, retain) NSString * ServerKey;
@property (nonatomic, retain) NSString * Title;
@property (nonatomic, retain) NSSet* Stubs;

@end
