//
//  FirstViewController.h
//  InPerth
//
//  Created by Callum Jones on 4/07/11.
//  Copyright 2011 mullac.org. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StubManager.h"
#import "Stub.h"
#import "InPerthAppDelegate.h"
#import "StubCell.h"
#import "WebViewController.h"

#define kStubCellsIndentifier @"StubCellsIndentifier"

@interface LatestViewController : UIViewController <UITableViewDataSource, UITableViewDelegate> {

    UITableView *tableViewOutlet;
    NSMutableArray *latestStubs;
    NSDate *newestStubDate;
    NSDate *oldestStubDate;
    
    NSDateFormatter *hourFormatter;
    NSDateFormatter *fullFormatter;
    
    NSDate *startOfDay;
    
    StubManager *stubManager;
}
@property (nonatomic, retain) IBOutlet UITableView *tableViewOutlet;

-(void)delegateHasFinishedUpdate:(NSNotification *)note;
-(void)getOlderDataInTimer:(NSTimer *)timer;
-(void)fetchOlderStubs;

@end
