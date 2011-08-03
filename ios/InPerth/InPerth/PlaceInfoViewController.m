//
//  PlaceInfoViewController.m
//  InPerth
//
//  Created by Callum Jones on 2/08/11.
//  Copyright 2011 mullac.org. All rights reserved.
//

#import "PlaceInfoViewController.h"

@implementation PlaceInfoViewController
@synthesize placeTitle;
@synthesize mapView;
@synthesize infoTable;
@synthesize placeKey;

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
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    PlaceManager *pManager = [[PlaceManager alloc] init];
    relatedPlace = [pManager getPlaceForKey:self.placeKey];
    [self.placeTitle setText:[relatedPlace Title]];
    [self.placeTitle setAdjustsFontSizeToFitWidth:YES];
    self.placeTitle.numberOfLines = 1;
    self.placeTitle.minimumFontSize = 20.0;
    self.placeTitle.adjustsFontSizeToFitWidth = YES;
    [self.infoTable setBackgroundColor:[UIColor clearColor]];
    //setup table
    UIImage *backImage = [UIImage imageNamed:@"PlaceFooter.png"];
    UIImageView *backImageView = [[UIImageView alloc] initWithImage:backImage];
    [self.infoTable setBackgroundView:backImageView];
    [self.infoTable setSeparatorColor:[UIColor clearColor]];
    [self.infoTable setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
    
    [super viewDidLoad];
}

- (void)viewDidUnload
{
    [self setPlaceTitle:nil];
    [self setMapView:nil];
    [self setInfoTable:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

-(void)viewWillAppear:(BOOL)animated
{
    //set lat/long
    if ([relatedPlace Latitude] != nil)
    {
        PlaceAnnotation *anno = [relatedPlace generatePlaceData];
        MKCoordinateSpan span = {.latitudeDelta =  0.008, .longitudeDelta =  0.008};
        MKCoordinateRegion region = {anno.coordinate, span};
        
        [mapView setRegion:region animated:YES];
        [mapView addAnnotation:anno];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc {
    [placeTitle release];
    [mapView release];
    [infoTable release];
    [super dealloc];
}

- (IBAction)backTouch:(id)sender {
    InPerthAppDelegate *delegate = (InPerthAppDelegate *)[[UIApplication sharedApplication] delegate];
    [delegate.navigationController popViewControllerAnimated:YES];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    int totalCount = 3;
    if (relatedPlace.SiteURI != nil)
        totalCount++;
    
    return totalCount;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    switch (indexPath.row) {
        case 0:
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"addressCell"];
            [cell setHidden:YES];
            break;
        }
            
        case 1:
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"phoneCell"];
            [cell.textLabel setTextColor:[UIColor colorWithHue:(203.0/359.0) saturation:(3.0/100.0) brightness:(97.0/100.0) alpha:1.0]];
            [cell.textLabel setText:[relatedPlace Phone]];
            
            break;
        }
        
        case 2:
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"addressCell"];
            [cell.textLabel setTextColor:[UIColor colorWithHue:(203.0/359.0) saturation:(4.0/100.0) brightness:(93.0/100.0) alpha:1.0]];
            [cell.textLabel setText:[relatedPlace Address]];
            [cell.detailTextLabel setTextColor:[UIColor colorWithHue:(203.0/359.0) saturation:(8.0/100.0) brightness:(77.0/100.0) alpha:1.0]];
            [cell.detailTextLabel setText:[relatedPlace Suburb]];
            
            break;
        }
            
        case 3:
        {
            if (relatedPlace.SiteURI != nil)
            {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"webAddressCell"];
                [cell.textLabel setTextColor:[UIColor colorWithHue:(203.0/359.0) saturation:(5.0/100.0) brightness:(91.0/100.0) alpha:1.0]];
                [cell.textLabel setText:[relatedPlace SiteURI]];
            }
                
        }
            
        default:
            break;
    }
    if (cell == nil)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"default"];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *selected = [tableView cellForRowAtIndexPath:indexPath];
    [selected setSelected:NO];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
        case 0:
            return 10.0;
            break;
            
        default:
            return 44.0;
            break;
    }
}
@end
