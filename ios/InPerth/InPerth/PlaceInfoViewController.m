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
    relatedStubs = [[pManager getStubsForPlace:self.placeKey] retain];
    [self buildCellList];
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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(actionCellWasSelectedAsNotification:) name:kActionsCellWasSelected object:nil];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kActionsCellWasSelected object:nil];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)buildCellList
{
    if (assignedCellList == nil)
        assignedCellList = [[[NSMutableArray alloc] init] retain];
    
    [assignedCellList addObject:[NSNumber numberWithInt:kPlaceInfoBlankCell]];
    
    if (relatedPlace.Phone != nil)
        [assignedCellList addObject:[NSNumber numberWithInt:kPlaceInfoPhoneCell]];
    
    if (relatedPlace.Address != nil)
        [assignedCellList addObject:[NSNumber numberWithInt:kPlaceInfoAddressCell]];
    
    if (relatedPlace.SiteURI != nil)
        [assignedCellList addObject:[NSNumber numberWithInt:kPlaceInfoWebAddressCell]];
    
    if (relatedPlace.UrbanspoonURI != nil)
        [assignedCellList addObject:[NSNumber numberWithInt:kPlaceInfoUrbanspoonAddressCell]];
    
    [assignedCellList addObject:[NSNumber numberWithInt:kPlaceInfoActionsCell]];
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
    if (section == 0)
        return [assignedCellList count];
    
    if (section == 1)
    {
        int size = [relatedStubs count];
        
        if (size > 0)
            return size + 1;
    }
    
    return 0;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2; //place data + place posts
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    enum kPlaceInfoCellType type = [self cellTypeForIndexPath:indexPath];
    
    if ([indexPath section] == 0)
    {
        switch (type) {
            case kPlaceInfoBlankCell:
            {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"addressCell"];
                [cell setHidden:YES];
                break;
            }
                
            case kPlaceInfoPhoneCell:
            {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"phoneCell"];
                [cell.textLabel setTextColor:[UIColor colorWithHue:(203.0/359.0) saturation:(3.0/100.0) brightness:(97.0/100.0) alpha:1.0]];
                [cell.textLabel setText:[relatedPlace Phone]];
                
                break;
            }
            
            case kPlaceInfoAddressCell:
            {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"addressCell"];
                [cell.textLabel setTextColor:[UIColor colorWithHue:(203.0/359.0) saturation:(4.0/100.0) brightness:(93.0/100.0) alpha:1.0]];
                [cell.textLabel setText:[relatedPlace Address]];
                [cell.detailTextLabel setTextColor:[UIColor colorWithHue:(203.0/359.0) saturation:(8.0/100.0) brightness:(77.0/100.0) alpha:1.0]];
                [cell.detailTextLabel setText:[relatedPlace Suburb]];
                
                break;
            }
                
            case kPlaceInfoWebAddressCell:
            {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"webAddressCell"];
                [[cell textLabel] setFont:[UIFont systemFontOfSize:18.0]];
                [cell.textLabel setTextColor:[UIColor colorWithHue:(203.0/359.0) saturation:(5.0/100.0) brightness:(91.0/100.0) alpha:1.0]];
                [cell.textLabel setText:[relatedPlace SiteURI]];
                break;   
            }
                
            case kPlaceInfoActionsCell:
            {
                cell = [PlaceInfoActionsCell loadFromBundle];
                [[(PlaceInfoActionsCell *)cell saveLabel] setTextColor:[UIColor colorWithHue:(203.0/359.0) saturation:(5.0/100.0) brightness:(91.0/100.0) alpha:1.0]];
                [[(PlaceInfoActionsCell *)cell shareLabel] setTextColor:[UIColor colorWithHue:(203.0/359.0) saturation:(5.0/100.0) brightness:(91.0/100.0) alpha:1.0]];
                [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
                break;
            }
                
            case kPlaceInfoUrbanspoonAddressCell:
            {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"urbanspoonCell"];
                [[cell textLabel] setFont:[UIFont systemFontOfSize:18.0]];
                [cell.textLabel setTextColor:[UIColor colorWithHue:(203.0/359.0) saturation:(5.0/100.0) brightness:(91.0/100.0) alpha:1.0]];
                [cell.textLabel setText:[NSString stringWithFormat:@"%@ on Urbanspoon", [relatedPlace Title]]];
                break;
            }
                
            default:
                break;
        }
    }
    else if ([indexPath section] == 1)
    {
        if ([indexPath row] == 0)
        {
            cell = [HorizontalDividerCell loadFromBundle];
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        }
        else
        {
            Stub *stub = [relatedStubs objectAtIndex:([indexPath row] - 1)];
            
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"detailCell"];
            [[cell textLabel] setFont:[UIFont systemFontOfSize:15.0]];
            [cell.textLabel setTextColor:[UIColor colorWithHue:(203.0/359.0) saturation:(10.0/100.0) brightness:(91.0/100.0) alpha:1.0]];
            [cell.textLabel setText:[stub Title]]; 
        }
    }
    if (cell == nil)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"default"];
    
    return cell;
}

- (enum kPlaceInfoCellType)cellTypeForIndexPath:(NSIndexPath *)indexPath
{
    if ([indexPath section] != 0)
        return kPlaceInfoBlankCell;
    
    if ([assignedCellList count] > [indexPath row])
    {
        NSNumber *typeObj = [assignedCellList objectAtIndex:[indexPath row]];
        return [typeObj intValue];
    }
    return kPlaceInfoBlankCell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *selected = [tableView cellForRowAtIndexPath:indexPath];
    [selected setSelected:NO];
    
    if ([indexPath section] == 0)
    {
        enum kPlaceInfoCellType type = [self cellTypeForIndexPath:indexPath];
        
        switch (type) {
            case kPlaceInfoPhoneCell:
            {
                //dial number
                NSString *phoneNo = [NSString stringWithFormat:@"tel:%@", [[relatedPlace Phone] stringByReplacingOccurrencesOfString:@" " withString:@"-"]];
                NSURL *url = [[NSURL alloc] initWithString:phoneNo];
                [[UIApplication sharedApplication] openURL:url];
                break;
            }
                
            case kPlaceInfoAddressCell:
            {
                //show real Maps
                NSString *mapAddr = [NSString stringWithFormat:@"http://maps.google.com/maps?q=%@,%@", [relatedPlace Address], [relatedPlace Suburb]];
                NSURL *url = [[NSURL alloc] initWithString:[mapAddr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
                [[UIApplication sharedApplication] openURL:url];
                break;
            }
                
            case kPlaceInfoWebAddressCell:
            {
                NSURL *url = [[NSURL alloc] initWithString:[[relatedPlace SiteURI] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
                [[UIApplication sharedApplication] openURL:url];
                break;
            }
                
            case kPlaceInfoUrbanspoonAddressCell:
            {
                NSURL *url = [[NSURL alloc] initWithString:[[relatedPlace UrbanspoonURI] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
                [[UIApplication sharedApplication] openURL:url];
                break;
            }
                
                
            default:
                break;
        }
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    enum kPlaceInfoCellType type = [self cellTypeForIndexPath:indexPath];
    
    if ([indexPath section] == 0)
    {
        switch (type) {
            case kPlaceInfoBlankCell:
                return 5.0;
                break;
            
            case kPlaceInfoWebAddressCell:
                return 30.0;
                break;
                
            case kPlaceInfoUrbanspoonAddressCell:
                return 30.0;
                break;
            
            default:
                return 44.0;
                break;
        }
    }
    else if ([indexPath section] == 1)
    {
        if ([indexPath row] == 0)
            return 10.0;
        
        return 33.0;
    }
    
    return 44.0;
}

-(void)actionCellWasSelectedAsNotification:(NSNotification *)note
{
    NSDictionary *userInfo = [note userInfo];
    NSString *action = [userInfo objectForKey:@"action"];
    if (action != nil)
    {
        if ([action isEqualToString:kActionsCellShareAction])
        {
            UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Close" destructiveButtonTitle:nil otherButtonTitles:@"Email", @"Tweet", nil];
            [actionSheet setDelegate:self];
            [actionSheet showInView:self.view];
        }
        else
        {
            
        }
    }
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    InPerthAppDelegate *delegate = (InPerthAppDelegate *)[[UIApplication sharedApplication] delegate];
    if (buttonIndex == 0)
    {
        //show mail
        NSMutableString *messageBody = [[NSMutableString alloc] init];
        
        if (relatedPlace.Phone != nil)
            [messageBody appendFormat:@"%@\r\n", relatedPlace.Phone];
        
        if (relatedPlace.Address != nil)
            [messageBody appendFormat:@"%@\r\n", relatedPlace.Address];
        
        if (relatedPlace.Suburb != nil)
            [messageBody appendFormat:@"%@\r\n", relatedPlace.Suburb];
        
        if (relatedPlace.GoogleURI != nil)
            [messageBody appendFormat:@"%@\r\n", relatedPlace.GoogleURI];
        else
        {
            NSString *mapAddr = nil;
            if ([relatedPlace Address] != nil && [relatedPlace Suburb] != nil)
                mapAddr = [NSString stringWithFormat:@"http://maps.google.com/maps?q=%@,%@", [relatedPlace Address], [relatedPlace Suburb]];
            else if ([relatedPlace Latitude] != nil && [relatedPlace Longitude] != nil)
                mapAddr = [NSString stringWithFormat:@"http://maps.google.com/maps?ll=%@,%@", [[relatedPlace Latitude] stringValue], [[relatedPlace Longitude] stringValue]];
            
            if (mapAddr != nil)
                [messageBody appendFormat:@"\r\n%@\r\n", [mapAddr stringByAddingPercentEscapesUsingEncoding:
                                                  NSASCIIStringEncoding]];
        }
        
        if (relatedPlace.UrbanspoonURI != nil)
            [messageBody appendFormat:@"%@\r\n", relatedPlace.UrbanspoonURI];
            
        
        [delegate presentMailControlWithSubject:relatedPlace.Title andMessageBody:messageBody];
    }
    else if (buttonIndex == 1)
    {
        NSString *url = relatedPlace.SiteURI;
        if (url == nil)
            url = relatedPlace.UrbanspoonURI;
        
        if (url == nil)
            url = relatedPlace.GoogleURI;
        
        if (url == nil && [relatedPlace Address] != nil && [relatedPlace Suburb] != nil)
            url = [NSString stringWithFormat:@"http://maps.google.com/maps?q=%@,%@", [relatedPlace Address], [relatedPlace Suburb]];
            
        [delegate presentTweetControlerWithText:relatedPlace.Title andURL:url];
    }
}
@end
