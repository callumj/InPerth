//
//  WebViewController.m
//  InPerth
//
//  Created by Callum Jones on 9/07/11.
//  Copyright 2011 mullac.org. All rights reserved.
//

#import "WebViewController.h"
#import "InPerthAppDelegate.h"

@implementation WebViewController
@synthesize webViewOutlet;
@synthesize urlToNavigateTo;
@synthesize toolbarTitle;
@synthesize currentToolbar;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    [webViewOutlet release];
    [currentToolbar release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

-(void)viewDidAppear:(BOOL)animated
{
    NSURL *urlObj = [NSURL URLWithString:urlToNavigateTo];
    NSURLRequest *urlReq = [NSURLRequest requestWithURL:urlObj];
    [self.webViewOutlet loadRequest:urlReq];
    [self.webViewOutlet setScalesPageToFit:YES];
    [self.currentToolbar setTitle:self.toolbarTitle];
}

- (void)viewDidUnload
{
    [self setWebViewOutlet:nil];
    [self setCurrentToolbar:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)backButtonTouched:(id)sender {
    InPerthAppDelegate *delegate = (InPerthAppDelegate *)[[UIApplication sharedApplication] delegate];
    [delegate.navigationController popViewControllerAnimated:YES];
}
@end
