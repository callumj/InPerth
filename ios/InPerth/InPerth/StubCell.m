//
//  StubCell.m
//  InPerth
//
//  Created by Callum Jones on 8/07/11.
//  Copyright 2011 mullac.org. All rights reserved.
//

#import "StubCell.h"


@implementation StubCell
@synthesize titleLabel;
@synthesize detailLabel;
@synthesize dateLabel;
@synthesize providerLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)dealloc
{
    [titleLabel release];
    [detailLabel release];
    [dateLabel release];
    [providerLabel release];
    [super dealloc];
}

+(StubCell *)loadFromBundle
{
    NSArray *objectsInBundle = [[NSBundle mainBundle] loadNibNamed:@"StubCell" owner:nil options:nil];
    
    for (id viewObj in objectsInBundle)
    {
        if ([viewObj isKindOfClass:[UITableViewCell class]])
        {
            return (StubCell *)viewObj;
        }
    }
    
    return nil;
}
@end
