//
//  FirstViewController.m
//  InPerth
//
//  Created by Callum Jones on 4/07/11.
//  Copyright 2011 mullac.org. All rights reserved.
//

#import "LatestViewController.h"


@implementation LatestViewController
@synthesize tableViewOutlet;


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    stubManager = [[[StubManager alloc] initWithNewContext] retain];
    latestStubs = [[[NSMutableArray alloc] initWithArray:[stubManager getStubsWithLimit:20]] retain];
    
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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(delegateHasFinishedUpdate:) name:kDataRefreshCompleteNotification object:nil];
    [super viewDidLoad];
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
    NSString *cellID = [NSString stringWithFormat:@"%@%@", kStubCellsIndentifier, [stub ServerKey]];
    
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
    if (diff >= 0.6)
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
            [latestStubs removeAllObjects];
            [latestStubs addObjectsFromArray:[stubManager getStubsWithLimit:20]];
            [tableViewOutlet reloadData];
        }
    }
}

-(void)getOlderDataInTimer:(NSTimer *)timer
{
    [self fetchOlderStubs];
}

-(void)fetchOlderStubs
{
    if ([latestStubs count] >= 60)
        return;
    
    NSArray *olderStubs = [stubManager getStubsWithLimit:20 olderThanDate:oldestStubDate];
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
