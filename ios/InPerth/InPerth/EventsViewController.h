//
//  EventsViewController.h
//  InPerth
//
//  Created by Callum Jones on 6/07/11.
//  Copyright 2011 mullac.org. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Stub.h"
#import "StubManager.h"
#import "StubCell.h"
#import "WebViewController.h"

@interface EventsViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
    
    NSMutableArray *latestStubs;
    StubManager *stubManager;
    
    NSDateFormatter *hourFormatter;
    NSDateFormatter *fullFormatter;
    NSDate *startOfDay;
    NSDate *newestStubDate;
    NSDate *oldestStubDate;
    UITableView *tableViewOutlet;
}
@property (nonatomic, retain) IBOutlet UITableView *tableViewOutlet;

-(void)fetchOlderStubs;
-(void)getOlderDataInTimer:(NSTimer *)timer;
-(void)delegateHasFinishedUpdate:(NSNotification *)note;
-(void)reloadStubsFromSource;

@end
