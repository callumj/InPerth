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
    UIImageView* vwimg = [ [ UIImageView alloc] initWithFrame: cell.bounds];
    UIImage* img = [ UIImage imageNamed: @"Stub.png"];
    vwimg.image = img;
    cell.backgroundView = vwimg;
    
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

@end
