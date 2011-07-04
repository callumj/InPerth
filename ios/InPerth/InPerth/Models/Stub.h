//
//  Stub.h
//  InPerth
//
//  Created by Callum Jones on 4/07/11.
//  Copyright (c) 2011 mullac.org. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Stub : NSManagedObject {
@private
}
@property (nonatomic, retain) NSString * Title;
@property (nonatomic, retain) NSString * ServerKey;
@property (nonatomic, retain) NSString * URI;
@property (nonatomic, retain) NSString * Description;
@property (nonatomic, retain) NSString * Tags;
@property (nonatomic, retain) NSDate * Date;
@property (nonatomic, retain) NSManagedObject * ContentProvider;

@end
