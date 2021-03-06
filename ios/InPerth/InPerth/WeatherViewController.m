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
    InPerthAppDelegate *delegate = (InPerthAppDelegate *)[[UIApplication sharedApplication] delegate];
    if ([previousType isEqualToString:type] && ![delegate mustAnimateWeather])
        return;
    
    if (![previousType isEqualToString:type])
    {
        for (UIView *view in activeWeatherIcons)
        {
            [view removeFromSuperview];
        }
        
        [activeWeatherIcons removeAllObjects];
    }
    
    if ([type isEqualToString:@"clouds"])
    {
        UIImageView *sun = nil;
        UIImageView *clouds = nil;
        CGRect cloudsFrame;
        if ([previousType isEqualToString:type])
        {
            for (UIView *view in activeWeatherIcons)
            {
                if ([view tag] == kCloudImageViewTag)
                {
                    clouds = (UIImageView *)view;
                    cloudsFrame = clouds.frame;
                }
            }
        }
        else
        {
            sun = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Ani_Sun.png"]];
            [sun setTag:kSunImageViewTag];
            CGRect sunFrame = sun.frame;
            sunFrame.origin.y += 2;
            [sun setFrame:sunFrame];
            [self.view addSubview:sun];
            [sun release];
            [activeWeatherIcons addObject:sun];
            
            clouds = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Ani_Clouds.png"]];
            [clouds setTag:kCloudImageViewTag];
            cloudsFrame = clouds.frame;
            cloudsFrame.origin.x = ((320 / 5) - (cloudsFrame.size.width / 5));
            [clouds setFrame:cloudsFrame];
            [self.view addSubview:clouds];
            [clouds release];
            [activeWeatherIcons addObject:clouds];
        }
        
        [UIView beginAnimations:@"moveCloud" context:nil];
        [UIView setAnimationDuration:2.0];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
        if (cloudsFrame.origin.x == 20.0)
           cloudsFrame.origin.x = ((320 / 5) - (cloudsFrame.size.width / 5));
        else
            cloudsFrame.origin.x = 20;
        [clouds setFrame:cloudsFrame];
        [UIView commitAnimations];
        
    }
    else if ([type isEqualToString:@"rain"])
    {
        UIImageView *clouds = nil;
        CGRect cloudsFrame;
        for (UIView *view in activeWeatherIcons)
        {
            if ([view tag] == kCloudImageViewTag)
            {
                clouds = (UIImageView *)view;
                cloudsFrame = clouds.frame;
            }
        }
        
        if (clouds == nil)
        {
            clouds = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Ani_Rain.png"]];
            [clouds setTag:kCloudImageViewTag];
            cloudsFrame = clouds.frame;
            cloudsFrame.origin.x = ((320 / 4) - (cloudsFrame.size.width / 4));
            [clouds setFrame:cloudsFrame];
            [self.view addSubview:clouds];
            [clouds release];
            [activeWeatherIcons addObject:clouds];
        }
        
        [UIView beginAnimations:@"moveCloud" context:nil];
        [UIView setAnimationDuration:2.0];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
        if (cloudsFrame.origin.x != 12)
            cloudsFrame.origin.x = 12;
        else
            cloudsFrame.origin.x = 20;
        [clouds setFrame:cloudsFrame];
        [UIView commitAnimations];
    }
    else
    {
        UIImageView *sun = nil;
        CGRect sunFrame;
        for (UIView *view in activeWeatherIcons)
        {
            if ([view tag] == kSunImageViewTag)
            {
                sun = (UIImageView *)view;
                sunFrame = sun.frame;
            }
        }
        
        if (sun == nil)
        {
            sun = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Ani_Sun.png"]];
            [sun setTag:kSunImageViewTag];
            CGRect sunFrame = sun.frame;
            sunFrame.origin.y += 2;
            sunFrame.origin.x += 10;
            [sun setFrame:sunFrame];
            [self.view addSubview:sun];
            [sun release];
            [activeWeatherIcons addObject:sun];
        }
    }
    
    [delegate setMustAnimateWeather:NO];
    [previousType setString:type];
}

@end
