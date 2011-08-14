//
//  PlaceInfoViewController.h
//  InPerth
//
//  Created by Callum Jones on 2/08/11.
//  Copyright 2011 mullac.org. All rights reserved.
//
#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "InPerthAppDelegate.h"
#import "PlaceInfoActionsCell.h"
#import "ShareViewController.h"

@interface PlaceInfoViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate> {
    UILabel *placeTitle;
    MKMapView *mapView;
    UITableView *infoTable;
    
    Place *relatedPlace;
}
@property (nonatomic, retain) IBOutlet UILabel *placeTitle;
@property (nonatomic, retain) IBOutlet MKMapView *mapView;
@property (nonatomic, retain) IBOutlet UITableView *infoTable;
@property (nonatomic, retain) NSString *placeKey;

- (IBAction)backTouch:(id)sender;
- (void)actionCellWasSelectedAsNotification:(NSNotification *)note;

@end
