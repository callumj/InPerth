//
//  WebViewController.h
//  InPerth
//
//  Created by Callum Jones on 9/07/11.
//  Copyright 2011 mullac.org. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface WebViewController : UIViewController {
    
    UIWebView *webViewOutlet;
    UINavigationItem *currentToolbar;
}
@property (nonatomic, retain) IBOutlet UIWebView *webViewOutlet;
@property (nonatomic, retain) NSString *urlToNavigateTo;
@property (nonatomic, retain) NSString *toolbarTitle;
@property (nonatomic, retain) IBOutlet UINavigationItem *currentToolbar;

- (IBAction)backButtonTouched:(id)sender;
@end
