//
//  AvailabilityTableView.h
//  GoldenSpear
//
//  Created by JCB on 8/6/16.
//  Copyright © 2016 GoldenSpear. All rights reserved.
//


#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

@interface AvailabilityTableView : UIViewController

@property (nonatomic) NSMutableArray *availabilities;
@property (nonatomic) NSMutableArray *onlinelist;
@property (nonatomic) NSMutableArray *instorelist;
@property (nonatomic) NSMutableArray *datalist;

@end

@interface storeNameCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *storeName;
@end

@interface locationCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *streetLabel;
@property (weak, nonatomic) IBOutlet UILabel *centerLabel;
@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;
@property (weak, nonatomic) IBOutlet UILabel *countryLabel;
@property (weak, nonatomic) IBOutlet UIButton *locationButton;
@end

@interface onlineCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *websiteLabel;
@end

@interface phoneCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *phoneLabel;
@end

@interface timetableCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@end

@interface mapCell : UITableViewCell
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UIButton *mapButton;
@end

