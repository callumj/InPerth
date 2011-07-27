//
//  WebViewController.h
//  InPerth
//
//  Created by Callum Jones on 9/07/11.
//  Copyright 2011 mullac.org. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface WebViewController : UIViewController <UIWebViewDelegate, UIActionSheetDelegate> {
    
    UIWebView *webViewOutlet;
    UINavigationItem *currentToolbar;
    UILabel *titleLabel;
    UILabel *subLabel;
    UIButton *infoButton;
}
@property (nonatomic, retain) IBOutlet UIWebView *webViewOutlet;
@property (nonatomic, retain) NSString *urlToNavigateTo;
@property (nonatomic, retain) NSString *toolbarTitle;
@property (nonatomic, retain) NSString *detailTitle;
@property (nonatomic, retain) IBOutlet UILabel *titleLabel;
@property (nonatomic, retain) IBOutlet UILabel *subLabel;
@property (nonatomic, retain) IBOutlet UIButton *infoButton;

- (IBAction)infoButtonTouched:(id)sender;
- (IBAction)backButtonTouched:(id)sender;
@end
