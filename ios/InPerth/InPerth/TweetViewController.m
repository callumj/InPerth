//
//  ShareViewController.m
//  InPerth
//
//  Created by Callum Jones on 14/08/11.
//  Copyright 2011 mullac.org. All rights reserved.
//

#import "TweetViewController.h"

@implementation TweetViewController

@synthesize webView;
@synthesize messageText;
@synthesize locationURI;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - View lifecycle


- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (void)viewDidAppear:(BOOL)animated
{
    NSString *tweetString = [NSString stringWithFormat:@"http://twitter.com/share?text=%@&url=%@", self.messageText, self.locationURI];
    NSURL *tweetShareLocation = [NSURL URLWithString:[tweetString stringByAddingPercentEscapesUsingEncoding:
                                                      NSASCIIStringEncoding]];
    [webView loadRequest:[NSURLRequest requestWithURL:tweetShareLocation]];
    [webView setDelegate:self];
    
    CancelButtonViewController *button = [[CancelButtonViewController alloc] init];
    CGRect frame = button.view.frame;
    frame.origin.y = self.webView.frame.size.height;
    frame.origin.x = 10;
    [button.view setFrame:frame];
    [self.view addSubview:button.view];
    
    [UIView beginAnimations:@"AnimateCancelButton" context:nil];
    [UIView setAnimationDuration:0.5];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
    frame.origin.y = self.webView.frame.size.height - frame.size.height;
    [button.view setFrame:frame];
    [UIView commitAnimations];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cancelButtonSelected:) name:kCancelButtonWasSelected object:nil];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)cancelButtonSelected:(NSNotification *)note
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kCancelButtonWasSelected object:nil];
    [self dismissModalViewControllerAnimated:YES];
}

- (void)webViewDidFinishLoad:(UIWebView *)webViewObject
{
    NSURLRequest *currentRequest = [webViewObject request];
    NSURL *currentURL = [currentRequest URL];
    NSString *urlOfString = [currentURL absoluteString];
    
    if ([urlOfString rangeOfString:@"tweet/complete"].location != NSNotFound)
        [self dismissModalViewControllerAnimated:YES];
}
                         

@end
