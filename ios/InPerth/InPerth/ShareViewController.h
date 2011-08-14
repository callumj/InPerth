//
//  ShareViewController.h
//  InPerth
//
//  Created by Callum Jones on 14/08/11.
//  Copyright 2011 mullac.org. All rights reserved.
//

#import "CancelButtonViewController.h"

@interface ShareViewController : UIViewController <UIWebViewDelegate> {
    IBOutlet UIWebView *webView;
}

@property (nonatomic, retain) IBOutlet UIWebView *webView;
@property (nonatomic, retain) NSString *messageText;
@property (nonatomic, retain) NSString *locationURI;

- (void)cancelButtonSelected:(NSNotification *)note;
@end
