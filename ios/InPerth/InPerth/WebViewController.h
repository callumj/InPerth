//
//  WebViewController.h
//  InPerth
//
//  Created by Callum Jones on 9/07/11.
//  Copyright 2011 mullac.org. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Stub.h"

enum modalOperationType
{
    kPlace,
    kEmail,
    kTweet
};

@interface WebViewController : UIViewController <UIWebViewDelegate, UIActionSheetDelegate> {
    
    UIWebView *webViewOutlet;
    UINavigationItem *currentToolbar;
    UILabel *titleLabel;
    UILabel *subLabel;
    UIButton *infoButton;
    
    BOOL didTryCache;
    
    Stub *relatedStub;
}
@property (nonatomic, retain) IBOutlet UIWebView *webViewOutlet;
@property (nonatomic, retain) NSString *urlToNavigateTo;
@property (nonatomic, retain) NSString *alternativeURL;
@property (nonatomic, retain) NSString *toolbarTitle;
@property (nonatomic, retain) NSString *detailTitle;
@property (nonatomic, retain) NSString *relatedStubKey;
@property (nonatomic, retain) IBOutlet UILabel *titleLabel;
@property (nonatomic, retain) IBOutlet UILabel *subLabel;
@property (nonatomic, retain) IBOutlet UIButton *infoButton;

- (IBAction)infoButtonTouched:(id)sender;
- (IBAction)backButtonTouched:(id)sender;
@end
