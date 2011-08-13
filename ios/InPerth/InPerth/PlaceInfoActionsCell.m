//
//  PlaceInfoActionsCell.m
//  InPerth
//
//  Created by Callum Jones on 4/08/11.
//  Copyright 2011 mullac.org. All rights reserved.
//

#import "PlaceInfoActionsCell.h"

@implementation PlaceInfoActionsCell
@synthesize saveLabel;
@synthesize saveIcon;
@synthesize shareLabel;
@synthesize shareIcon;

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

-(void)willMoveToSuperview:(UIView *)newSuperview
{
    UITapGestureRecognizer *tapDetection = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cellWasTappedInLocation:)];
    [tapDetection setNumberOfTouchesRequired:1];
    [tapDetection setEnabled:YES];
    [self addGestureRecognizer:tapDetection];
}
                                                                                                      
-(void)cellWasTappedInLocation:(UITapGestureRecognizer *)gesture
{
    CGPoint location = [gesture locationInView:self];
    
    BOOL shareTapped = NO;
    if (location.y >= shareIcon.frame.origin.y)
        shareTapped = YES;
}
                                                                                                

+(PlaceInfoActionsCell *)loadFromBundle
{
    NSArray *objectsInBundle = [[NSBundle mainBundle] loadNibNamed:@"PlaceInfoActionsCell" owner:nil options:nil];
    
    for (id viewObj in objectsInBundle)
    {
        if ([viewObj isKindOfClass:[UITableViewCell class]])
        {
            return (PlaceInfoActionsCell *)viewObj;
        }
    }
    
    return nil;
}
- (void)dealloc {
    [saveLabel release];
    [saveIcon release];
    [shareLabel release];
    [shareIcon release];
    [super dealloc];
}
@end
