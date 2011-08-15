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
#import "TweetViewController.h"

enum kPlaceInfoCellType {
    kPlaceInfoBlankCell = 1,
    kPlaceInfoPhoneCell,
    kPlaceInfoAddressCell,
    kPlaceInfoWebAddressCell,
    kPlaceInfoUrbanspoonAddressCell,
    kPlaceInfoActionsCell
};

@interface PlaceInfoViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate> {
    UILabel *placeTitle;
    MKMapView *mapView;
    UITableView *infoTable;
    
    Place *relatedPlace;
    
    NSMutableArray *assignedCellList;
    NSArray *relatedStubs;
}
@property (nonatomic, retain) IBOutlet UILabel *placeTitle;
@property (nonatomic, retain) IBOutlet MKMapView *mapView;
@property (nonatomic, retain) IBOutlet UITableView *infoTable;
@property (nonatomic, retain) NSString *placeKey;

- (IBAction)backTouch:(id)sender;
- (void)actionCellWasSelectedAsNotification:(NSNotification *)note;
- (void)buildCellList;
- (enum kPlaceInfoCellType)cellTypeForIndexPath:(NSIndexPath *)indexPath;

@end
