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

#define kStubCellsIndentifier @"StubCellsIndentifier"

@interface LatestViewController : UIViewController <UITableViewDataSource, UITableViewDelegate> {

    UITableView *tableViewOutlet;
    NSMutableArray *latestStubs;
    
    StubManager *stubManager;
}
@property (nonatomic, retain) IBOutlet UITableView *tableViewOutlet;

-(void)delegateHasFinishedUpdate:(NSNotification *)note;

@end
