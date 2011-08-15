//
//  HorizontalDividerCell.m
//  InPerth
//
//  Created by Callum Jones on 15/08/11.
//  Copyright 2011 mullac.org. All rights reserved.
//

#import "HorizontalDividerCell.h"

@implementation HorizontalDividerCell

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

+(HorizontalDividerCell *)loadFromBundle
{
    NSArray *objectsInBundle = [[NSBundle mainBundle] loadNibNamed:@"HorizontalDividerCell" owner:nil options:nil];
    
    for (id viewObj in objectsInBundle)
    {
        if ([viewObj isKindOfClass:[UITableViewCell class]])
        {
            return (HorizontalDividerCell *)viewObj;
        }
    }
    
    return nil;
}

@end
