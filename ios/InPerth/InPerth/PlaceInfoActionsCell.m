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
    if (location.x >= shareLabel.frame.origin.x)
        shareTapped = YES;
    
    if (shareTapped)
    {
        [shareIcon setAlpha:0.5];
        [shareLabel setAlpha:0.5];
        [[NSNotificationCenter defaultCenter] 
         postNotificationName:kActionsCellWasSelected 
         object:self 
         userInfo:[NSDictionary 
                   dictionaryWithObject:[NSString stringWithString:kActionsCellShareAction] 
                   forKey:@"action"]
         ];
    }
    else
    {
        [saveIcon setAlpha:0.5];
        [saveLabel setAlpha:0.5];
        [[NSNotificationCenter defaultCenter] 
         postNotificationName:kActionsCellWasSelected 
         object:self 
         userInfo:[NSDictionary 
                   dictionaryWithObject:[NSString stringWithString:kActionsCellSaveAction] 
                   forKey:@"action"]
         ];
    }
    
    [UIView beginAnimations:@"AnimateIcon" context:nil];
    [UIView setAnimationDelay:0.4];
    [UIView setAnimationDuration:0.5];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
    
    if (shareTapped)
    {
        [shareIcon setAlpha:1.0];
        [shareLabel setAlpha:1.0];
        
    }
    else
    {
        [saveIcon setAlpha:1.0];
        [saveLabel setAlpha:1.0];
    }
    
    [UIView commitAnimations];
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
