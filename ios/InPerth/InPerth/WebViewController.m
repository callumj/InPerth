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
@synthesize relatedStubKey;

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
    if (self.relatedStubKey != nil)
    {
        StubManager *man = [[StubManager alloc] init];
        PlaceManager *pManager = [[PlaceManager alloc] init];
        relatedStub = [man getStubForKey:self.relatedStubKey];
        [self.titleLabel setText:[relatedStub Title]];
        
        if (relatedStub.Place != nil)
        {
            Place *related = [pManager getPlaceForStubKey:[relatedStub ServerKey]];
            if (related != nil)
            {
                [self setDetailTitle:[NSString stringWithFormat:@"at %@ - %@", [related Title], [related Suburb]]];
            }
        }
        
        [self setUrlToNavigateTo:[relatedStub URI]];
        
        NSString *offlinePath = [StubManager getOfflineLocationForStub:[relatedStub ServerKey]];
        if (offlinePath != nil)
        {
            [self setAlternativeURL:offlinePath];
        }
    }
    
    if (self.toolbarTitle != nil)
        [self.titleLabel setText:self.toolbarTitle];
    
    if (self.detailTitle != nil && [self.detailTitle length] > 0)
        [self.subLabel setText:self.detailTitle];
    
    
    if (self.detailTitle == nil)
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
    UIActionSheet *actionSheet = nil;
    
    PlaceManager *pManager = [[PlaceManager alloc] init];
    Place *related = [pManager getPlaceForStubKey:[relatedStub ServerKey]];
    if (related != nil)
        actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Close" destructiveButtonTitle:nil otherButtonTitles:@"Place info", @"Email", @"Tweet", nil];
    else
        actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Close" destructiveButtonTitle:nil otherButtonTitles:@"Email", @"Tweet", nil];
    
    [pManager release];
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
    enum modalOperationType selectedType; 
    
    InPerthAppDelegate *delegate = (InPerthAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    PlaceManager *pManager = [[PlaceManager alloc] init];
    Place *related = [pManager getPlaceForStubKey:[relatedStub ServerKey]];
    
    if (buttonIndex == 0)
    {
        if (related != nil)
            selectedType = kPlace;
        else
            selectedType = kEmail;
    }
    else if (buttonIndex == 1)
    {
        if (related != nil)
            selectedType = kEmail;
        else
            selectedType = kTweet;
    }
    else if (buttonIndex == 2)
    {
        selectedType = kTweet;
    }
    
    switch (selectedType) {
        case kPlace:
            {
                PlaceInfoViewController *placeInfo = [[PlaceInfoViewController alloc] init];
                [placeInfo setPlaceKey:[related ServerKey]];
                InPerthAppDelegate *delegate = (InPerthAppDelegate *)[[UIApplication sharedApplication] delegate];
                [delegate.navigationController pushViewController:placeInfo animated:YES];
            }
            break;
            
        case kEmail:
            {
                [delegate presentMailControlWithSubject:[relatedStub Title] andMessageBody:[relatedStub.URI stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
            }
            break;
        
        case kTweet:
            {
                [delegate presentTweetControlerWithText:[relatedStub Title] andURL:[relatedStub URI]];
            }
            break;
        default:
            break;
    }
}
@end
