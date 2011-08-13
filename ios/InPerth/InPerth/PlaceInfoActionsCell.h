//
//  PlaceInfoActionsCell.h
//  InPerth
//
//  Created by Callum Jones on 4/08/11.
//  Copyright 2011 mullac.org. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PlaceInfoActionsCell : UITableViewCell {
    UILabel *saveLabel;
    UIImageView *saveIcon;
    UILabel *shareLabel;
    UIImageView *shareIcon;
}

@property (nonatomic, retain) IBOutlet UILabel *saveLabel;
@property (nonatomic, retain) IBOutlet UIImageView *saveIcon;
@property (nonatomic, retain) IBOutlet UILabel *shareLabel;
@property (nonatomic, retain) IBOutlet UIImageView *shareIcon;

+(PlaceInfoActionsCell *)loadFromBundle;

-(void)cellWasTappedInLocation:(UITapGestureRecognizer *)gesture;
@end
