//
//  CancelButtonViewController.h
//  InPerth
//
//  Created by Callum Jones on 14/08/11.
//  Copyright 2011 mullac.org. All rights reserved.
//

#define kCancelButtonWasSelected @"CancelButtonWasSelected"

@interface CancelButtonViewController : UIViewController {
    UIButton *cancelButton;
}
@property (nonatomic, retain) IBOutlet UIButton *cancelButton;
- (IBAction)cancelSelected:(id)sender;

@end
