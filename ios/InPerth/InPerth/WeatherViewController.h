//
//  WeatherView.h
//  InPerth
//
//  Created by Callum Jones on 10/07/11.
//  Copyright 2011 mullac.org. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "InPerthAppDelegate.h"

@interface WeatherViewController : UIViewController {
    
    UIImageView *weatherImage;
    NSMutableString *previousType;
    UILabel *temperatureText;
    
    NSMutableArray *activeWeatherIcons;
}
@property (nonatomic, retain) IBOutlet UIImageView *weatherImage;
@property (nonatomic, retain) IBOutlet UILabel *temperatureText;

-(void)refreshWeatherStatus:(NSNotification *)note;
-(void)setWeatherTypeForString:(NSString *)type;
@end
