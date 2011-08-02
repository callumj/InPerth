//
//  WebViewController.m
//  InPerth
//
//  Created by Callum Jones on 9/07/11.
//  Copyright 2011 mullac.org. All rights reserved.
//

#import "WebViewController.h"
#import "InPerthAppDelegate.h"
#import "PlaceInfoViewController.h"

@implementation WebViewController
@synthesize webViewOutlet;
@synthesize urlToNavigateTo;
@synthesize toolbarTitle;
@synthesize titleLabel;
@synthesize subLabel;
@synthesize infoButton;
@synthesize detailTitle;
@synthesize alternativeURL;

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
    [infoButton release];
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
    didTryCache = NO;
}

-(void)viewDidLoad
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
    [self setInfoButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)infoButtonTouched:(id)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Close" destructiveButtonTitle:nil otherButtonTitles:@"Place info", @"Email", @"Tweet", nil];
    
    [actionSheet showInView:self.view];
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

-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    //load cache copy
    if (!didTryCache)
    {
        if (alternativeURL != nil)
        {
            NSURL *urlObj = [NSURL URLWithString:self.alternativeURL];
            NSURLRequest *urlReq = [NSURLRequest requestWithURL:urlObj];
            [webView loadRequest:urlReq];
        }
        didTryCache = YES;
    }
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0)
    {
        PlaceInfoViewController *placeInfo = [[PlaceInfoViewController alloc] init];
        InPerthAppDelegate *delegate = (InPerthAppDelegate *)[[UIApplication sharedApplication] delegate];
        [delegate.navigationController pushViewController:placeInfo animated:YES];
    }
}
@end
