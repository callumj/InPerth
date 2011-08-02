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


@interface PlaceInfoViewController : UIViewController {
    UILabel *placeTitle;
    MKMapView *mapView;
}
@property (nonatomic, retain) IBOutlet UILabel *placeTitle;
@property (nonatomic, retain) IBOutlet MKMapView *mapView;

- (IBAction)backTouch:(id)sender;

@end
