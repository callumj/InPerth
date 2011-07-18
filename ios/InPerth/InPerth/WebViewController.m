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
@synthesize titleLabel;
@synthesize subLabel;
@synthesize detailTitle;

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
    [titleLabel release];
    [subLabel release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

-(void)viewWillAppear:(BOOL)animated
{
    [self.titleLabel setText:self.toolbarTitle];
    if (self.detailTitle != nil && [self.detailTitle length] > 0)
    {
        [self.subLabel setText:self.detailTitle];
    }
    else
    {
        CGRect curFrame = [self.titleLabel frame];
        curFrame.origin.y += 5;
        [self.titleLabel setFrame:curFrame];
        [self.subLabel setHidden:YES];
    }
}

-(void)viewDidAppear:(BOOL)animated
{
    NSURL *urlObj = [NSURL URLWithString:urlToNavigateTo];
    NSURLRequest *urlReq = [NSURLRequest requestWithURL:urlObj];
    [self.webViewOutlet loadRequest:urlReq];
    [self.webViewOutlet setScalesPageToFit:YES];
    [self.webViewOutlet setDelegate:self];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

- (void)viewDidUnload
{
    [self setWebViewOutlet:nil];
    [self setTitleLabel:nil];
    [self setSubLabel:nil];
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

-(void)webViewDidStartLoad:(UIWebView *)webView
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
}

-(void)webViewDidFinishLoad:(UIWebView *)webView
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}
@end
