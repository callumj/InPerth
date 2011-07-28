//
//  SecondViewController.m
//  InPerth
//
//  Created by Callum Jones on 4/07/11.
//  Copyright 2011 mullac.org. All rights reserved.
//

#import "FoodViewController.h"


@implementation FoodViewController
@synthesize tableViewOutlet;

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    stubManager = [[[StubManager alloc] initWithNewContext] retain];
    latestStubs = [[[NSMutableArray alloc] initWithArray:[stubManager getStubsForClassifier:@"food" withLimit:20]] retain];
    
    if ([latestStubs count] > 0)
    {
        newestStubDate = [[(Stub *)[latestStubs objectAtIndex:0] Date] retain];
        oldestStubDate = [[(Stub *)[latestStubs objectAtIndex:([latestStubs count] - 1)] Date] retain];
    }    
    
    hourFormatter = [[[NSDateFormatter alloc] init] retain];
    [hourFormatter setDateFormat:@"h:mm a"];
    
    fullFormatter = [[[NSDateFormatter alloc] init] retain];
    [fullFormatter setDateFormat:@"E h:mm a"];
    
    NSDate *today = [NSDate date];
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *todayComponents = [gregorian components:(NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit) fromDate:today];
    [todayComponents setHour:0];
    [todayComponents setMinute:0];
    
    startOfDay = [[gregorian dateFromComponents:todayComponents] retain];
    [gregorian release];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(delegateHasFinishedUpdate:) name:kStubDataRefreshCompleteNotification object:nil];
    
    [self.tableViewOutlet setSeparatorColor:[UIColor clearColor]];
    [self.tableViewOutlet setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
    [super viewDidLoad];
}

-(void)viewWillAppear:(BOOL)animated
{
    /* DANGEROUS
    [latestStubs removeAllObjects];
    [latestStubs addObjectsFromArray:[stubManager getStubsForClassifier:@"food" withLimit:20]];
    
    if ([latestStubs count] > 0)
    {
        newestStubDate = [[(Stub *)[latestStubs objectAtIndex:0] Date] retain];
        oldestStubDate = [[(Stub *)[latestStubs objectAtIndex:([latestStubs count] - 1)] Date] retain];
    } */
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}


- (void)viewDidUnload
{
    [self setTableViewOutlet:nil];
    [super viewDidUnload];
    
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)dealloc
{
    [tableViewOutlet release];
    [super dealloc];
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Stub *stub = [latestStubs objectAtIndex:[indexPath row]];
    NSString *cellID = nil;
    
    StubCell *cell = (StubCell *)[tableView dequeueReusableCellWithIdentifier:cellID];
    
    if (cell == nil)
        cell = [StubCell loadFromBundle];
    
    [cell.titleLabel setText:[stub Title]];
    [cell.detailLabel setText:[stub Description]];
    [cell.providerLabel setText:[[stub ContentProvider] Title]];
    if ([startOfDay compare:[stub Date]] == NSOrderedDescending)
        [cell.dateLabel setText:[fullFormatter stringFromDate:[stub Date]]];
    else
        [cell.dateLabel setText:[hourFormatter stringFromDate:[stub Date]]];
    UIImageView* vwimg = [ [ UIImageView alloc] initWithFrame: cell.bounds];
    UIImage* img = [ UIImage imageNamed: @"Stub.png"];
    vwimg.image = img;
    cell.backgroundView = vwimg;
    double diff = ((double)indexPath.row / (double)[latestStubs count]);
    if (diff >= 0.9)
    {
        [self performSelectorOnMainThread:@selector(fetchOlderStubs) withObject:nil waitUntilDone:NO];
    }
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [latestStubs count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 55.0;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Stub *stub = [latestStubs objectAtIndex:[indexPath row]];
    
    InPerthAppDelegate *delegate = (InPerthAppDelegate *)[[UIApplication sharedApplication] delegate];
    WebViewController *webController = [[WebViewController alloc] init];
    [webController setUrlToNavigateTo:[stub URI]];
    [webController setToolbarTitle:[stub Title]];
    PlaceManager *pManager = [[PlaceManager alloc] initWithNewContext];
    Place *related = [pManager getPlaceForStubKey:[stub ServerKey]];
    if (related != nil)
    {
        [webController setDetailTitle:[NSString stringWithFormat:@"at %@ - %@", [related Title], [related Suburb]]];
    }
    if ([stub OfflineArchive] != nil)
    {
        [webController setAlternativeURL:[NSString stringWithFormat:@"%@/%@/%@", delegate.offlineCacheDir, [stub ServerKey], [stub OfflineArchive]]];
    }
    [delegate.navigationController pushViewController:webController animated:YES];
    [webController release];
    UITableViewCell *cell = [tableViewOutlet cellForRowAtIndexPath:indexPath];
    [cell setSelected:NO];
    
}

-(void)delegateHasFinishedUpdate:(NSNotification *)note
{
    NSNumber *status = [note object];
    if (status != nil)
    {
        if ([status boolValue])
        {
            //we are performing important CD operations that need to be accessible from the main thread
            [self performSelectorOnMainThread:@selector(reloadStubsFromSource) withObject:nil waitUntilDone:YES];
        }
    }
}

-(void)reloadStubsFromSource
{
    //this could be called in a background thread
    NSArray *newObjs = [stubManager getStubsForClassifier:@"food" withLimit:20];
    [latestStubs removeAllObjects];
    [latestStubs addObjectsFromArray:newObjs];
    
    if ([latestStubs count] > 0)
    {
        newestStubDate = [[(Stub *)[latestStubs objectAtIndex:0] Date] retain];
        oldestStubDate = [[(Stub *)[latestStubs objectAtIndex:([latestStubs count] - 1)] Date] retain];
    } 
    
    [tableViewOutlet reloadData];
    
}

-(void)getOlderDataInTimer:(NSTimer *)timer
{
    [self fetchOlderStubs];
}

-(void)fetchOlderStubs
{
    if ([latestStubs count] >= 120)
        return;
    
    NSArray *olderStubs = [stubManager getStubsForClassifier:@"food" withLimit:20 olderThanDate:oldestStubDate];
    NSLog(@"Fetching for date %@", oldestStubDate);
    if ([olderStubs count] > 0)
    {
        /*[tableViewOutlet beginUpdates];
         int curDataSize = [latestStubs count];
         NSMutableArray *newPaths = [NSMutableArray array];
         for (int index = 0; index < [olderStubs count]; index++)
         {
         NSIndexPath *path = [NSIndexPath indexPathForRow:(curDataSize + index) inSection:0];
         [newPaths addObject:path];
         }
         [tableViewOutlet insertRowsAtIndexPaths:newPaths withRowAnimation:UITableViewRowAnimationNone];*/
        [latestStubs addObjectsFromArray:olderStubs];
        
        [oldestStubDate release];
        oldestStubDate = nil;
        oldestStubDate = [[(Stub *)[latestStubs objectAtIndex:([latestStubs count] - 1)] Date] retain];
        
        [tableViewOutlet reloadData];
    }
}


@end
