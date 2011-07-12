//
//  WeatherView.m
//  InPerth
//
//  Created by Callum Jones on 10/07/11.
//  Copyright 2011 mullac.org. All rights reserved.
//

#import "WeatherViewController.h"


@implementation WeatherViewController
@synthesize weatherImage;
@synthesize temperatureText;

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
    [weatherImage release];
    [temperatureText release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    previousType = [[[NSMutableString alloc] init] retain];
    activeWeatherIcons = [[[NSMutableArray alloc] init] retain];
    [self.weatherImage setImage:[UIImage imageNamed:@"WeatherBar.png"]];
    [self refreshWeatherStatus:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshWeatherStatus:) name:kWeatherDataRefreshCompleteNotification object:nil];
    [super viewDidLoad];
}

- (void)viewDidUnload
{
    [self setWeatherImage:nil];
    [self setTemperatureText:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark data management

-(void)refreshWeatherStatus:(NSNotification *)note
{
    InPerthAppDelegate *delegate = (InPerthAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSDictionary *weatherStatus = [[delegate metaData] objectForKey:@"weather"];
    if (weatherStatus != nil)
    {
        NSDictionary *weatherNow = [weatherStatus objectForKey:@"day0"];
        if (weatherNow != nil)
        {
            NSString *temp = [weatherNow objectForKey:@"temp"];
            NSString *type = [weatherNow objectForKey:@"type"];
            [self setWeatherTypeForString:type];
            [self.temperatureText setText:temp];
        }
    }
}

-(void)setWeatherTypeForString:(NSString *)type
{
    if ([previousType isEqualToString:type])
        return;
    
    for (UIView *view in activeWeatherIcons)
    {
        [view removeFromSuperview];
    }
    
    [activeWeatherIcons removeAllObjects];
    
    if ([type isEqualToString:@"clouds"])
    {
        UIImageView *sun = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Ani_Sun.png"]];
        CGRect sunFrame = sun.frame;
        sunFrame.origin.y += 2;
        [sun setFrame:sunFrame];
        [self.view addSubview:sun];
        [activeWeatherIcons addObject:sun];
        
        UIImageView *clouds = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Ani_Clouds.png"]];
        CGRect cloudsFrame = clouds.frame;
        cloudsFrame.origin.x = ((320 / 2) - (cloudsFrame.size.width / 2));
        [clouds setFrame:cloudsFrame];
        [self.view addSubview:clouds];
        [activeWeatherIcons addObject:clouds];
        
        [UIView beginAnimations:@"moveCloud" context:nil];
        [UIView setAnimationDuration:2.0];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
        cloudsFrame.origin.x = 20;
        [clouds setFrame:cloudsFrame];
        [UIView commitAnimations];
        
    }
    else if ([type isEqualToString:@"rain"])
    {
        UIImageView *clouds = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Ani_Rain.png"]];
        CGRect cloudsFrame = clouds.frame;
        cloudsFrame.origin.x -= 10;
        [clouds setFrame:cloudsFrame];
        [self.view addSubview:clouds];
        [activeWeatherIcons addObject:clouds];
        
        [UIView beginAnimations:@"moveCloud" context:nil];
        [UIView setAnimationDuration:3.0];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        cloudsFrame.origin.x += 20;
        [clouds setFrame:cloudsFrame];
        [UIView commitAnimations];
    }
    else
    {
        UIImageView *sun = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Ani_Sun.png"]];
        CGRect sunFrame = sun.frame;
        sunFrame.origin.y += 2;
        [sun setFrame:sunFrame];
        [self.view addSubview:sun];
        [activeWeatherIcons addObject:sun];
    }
    
    [previousType setString:type];
}

@end
