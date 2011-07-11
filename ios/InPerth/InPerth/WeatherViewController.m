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
    UIImage *imageToRender;
    if ([type isEqualToString:@"clouds"])
    {
        imageToRender = [UIImage imageNamed:@"weather_cloudy.png"];
    }
    else if ([type isEqualToString:@"rain"])
    {
        imageToRender = [UIImage imageNamed:@"weather_rain.png"];
    }
    else
    {
        imageToRender = [UIImage imageNamed:@"weather_sun.png"];
    }
    
    [self.weatherImage setImage:imageToRender];
}

@end
