//
//  StubCell.h
//  InPerth
//
//  Created by Callum Jones on 8/07/11.
//  Copyright 2011 mullac.org. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface StubCell : UITableViewCell {
    
    UILabel *titleLabel;
    UILabel *detailLabel;
    UILabel *dateLabel;
}
@property (nonatomic, retain) IBOutlet UILabel *titleLabel;
@property (nonatomic, retain) IBOutlet UILabel *detailLabel;
@property (nonatomic, retain) IBOutlet UILabel *dateLabel;

+(StubCell *)loadFromBundle;
@end
