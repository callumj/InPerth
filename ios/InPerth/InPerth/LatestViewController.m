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
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kStubCellsIndentifier];
    
    if (cell != nil)
        return cell;
    
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:kStubCellsIndentifier];
    
    [cell.textLabel setText:[stub Title]];
    [cell.detailTextLabel setText:[stub Description]];
    
    return [cell autorelease];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [latestStubs count];
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
