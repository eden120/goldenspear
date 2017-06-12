//
//  AvailabiliyView.m
//  GoldenSpear
//
//  Created by JCB on 9/19/16.
//  Copyright © 2016 GoldenSpear. All rights reserved.
//

#import "AvailabiliyView.h"
#import "AppDelegate.h"
#import <CoreLocation/CoreLocation.h>

#define LOCATIONVIEW_HEIGHT         74
#define ONLINEVIEW_HEIGHT           43
#define MAPVIEW_HEIGHT              300

@interface AvailabiliyView()

@property (weak, nonatomic) IBOutlet UIView *bgView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bgViewHeightConstraint;

@property (weak, nonatomic) IBOutlet UILabel *onlineLabel;
@property (weak, nonatomic) IBOutlet UILabel *instoreLabel;

@property (weak, nonatomic) IBOutlet UILabel *storeName;

@property (weak, nonatomic) IBOutlet UIView *locationView;

@property (weak, nonatomic) IBOutlet UILabel *streetLabel;
@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;
@property (weak, nonatomic) IBOutlet UILabel *centerLabel;
@property (weak, nonatomic) IBOutlet UILabel *countryLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *locationViewHeightConstraint;

@property (weak, nonatomic) IBOutlet UIView *onlineView;
@property (weak, nonatomic) IBOutlet UILabel *websiteLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *onlineViewHeightConstraint;

@property (weak, nonatomic) IBOutlet UIView *phoneView;
@property (weak, nonatomic) IBOutlet UILabel *phoneLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *phoneViewHeightConstraint;

@property (weak, nonatomic) IBOutlet UIView *timeView;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *timeViewHeightConstraint;

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *mapViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIButton *mapButton;

@property (weak, nonatomic) IBOutlet UIButton *seemoreButton;

@end

@implementation AvailabiliyView

-(void)viewDidLoad {
    [super viewDidLoad];
}

-(void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:YES];
    
    _isEnd = NO;
}

-(void)initView {
    
        if (_onlinestate == ONLINE_INSTORE) {
            _onlineLabel.text = @"AVAILABLE ONLINE";
            _instoreLabel.text = @"& IN - STORE";
        }
        else if (_onlinestate == ONLINE_ONLY) {
            _onlineLabel.text = @"AVAILABLE ONLINE";
            _instoreLabel.text = @"";
            _locationView.hidden = YES;
            _locationViewHeightConstraint.constant = 0;
            _phoneView.hidden = YES;
            _phoneViewHeightConstraint.constant = 0;
            _timeView.hidden = YES;
            _timeViewHeightConstraint.constant = 0;
            _mapView.hidden = YES;
            _mapViewHeightConstraint.constant = 0;
            _mapButton.hidden = YES;
        }
        else if (_onlinestate == INSTORE_ONLY) {
            _onlineLabel.text = @"AVAILABLE";
            _instoreLabel.text = @"IN - STORE";
            _onlineView.hidden = YES;
            _onlineViewHeightConstraint.constant = 0;
        }
    
        if (_onlineStore != nil) {
            if (_onlineStore.storename != nil && ![_onlineStore.storename isEqualToString:@""]) {
                _storeName.text = _onlineStore.storename;
            }
    
            if (_onlineStore.website != nil && ![_onlineStore.website isEqualToString:@""]) {
                _websiteLabel.text = _onlineStore.website;
                _onlineViewHeightConstraint.constant = ONLINEVIEW_HEIGHT;
                _onlineView.hidden = NO;
            }
            else {
                _onlineViewHeightConstraint.constant = 0;
                _onlineView.hidden = YES;
            }
    
    
        }
        if (_instoreStore != nil) {
    
    
            if (_instoreStore.address != nil) {
                _streetLabel.text = _instoreStore.address;
                _locationViewHeightConstraint.constant = LOCATIONVIEW_HEIGHT;
                _locationView.hidden = NO;
            }
            else {
                _locationViewHeightConstraint.constant = 0;
                _locationView.hidden = YES;
            }
    
            if (_instoreStore.shoppingcenter != nil) {
                _centerLabel.text = _instoreStore.shoppingcenter;
            }
            if (_instoreStore.distance != nil) {
                _distanceLabel.text = [NSString stringWithFormat:@"%f %@", [_instoreStore.distance doubleValue], _instoreStore.units];
            }
            else {
                _distanceLabel.text = @"";
            }
            if (_instoreStore.zipcode != nil && _instoreStore.city != nil && _instoreStore.state != nil) {
                _countryLabel.text = [NSString stringWithFormat:@"%@, %@ %@", _instoreStore.city, _instoreStore.state, _instoreStore.zipcode];
            }
    
            if (_instoreStore.telephone != nil && ![_instoreStore.telephone isEqualToString:@""]) {
                _phoneLabel.text = _instoreStore.telephone;
                _phoneViewHeightConstraint.constant = ONLINEVIEW_HEIGHT;
                _phoneView.hidden = NO;
            }
            else {
                _phoneViewHeightConstraint.constant = 0;
                _phoneView.hidden = YES;
            }
            if (![[self getTimeString:_instoreStore] isEqualToString:@""]) {
                _timeLabel.text = [NSString stringWithFormat:@"Open now : %@",[self getTimeString:_instoreStore]];
                _timeViewHeightConstraint.constant = ONLINEVIEW_HEIGHT;
                _timeView.hidden = NO;
            }
            else {
                _timeViewHeightConstraint.constant = 0;
                _timeView.hidden = YES;
            }
            if (_instoreStore.latitude != nil && _instoreStore.longitude != nil) {
                CLLocation *mylocation = [[CLLocation alloc] initWithLatitude:[_instoreStore.latitude doubleValue] longitude:[_instoreStore.longitude doubleValue]];
                MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(mylocation.coordinate, 200, 200);
                _mapView.region = region;
    
                MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
                annotation.coordinate = mylocation.coordinate;
    
                [_mapView addAnnotation:annotation];
    
                _mapViewHeightConstraint.constant = MAPVIEW_HEIGHT;
                _mapView.hidden = NO;
                _mapButton.hidden = NO;
            }
            else {
                _mapViewHeightConstraint.constant = 0;
                _mapView.hidden = YES;
                _mapButton.hidden = YES;
            }
    
    
        }
        _bgViewHeightConstraint.constant = [self getBackgroundHeight:_onlineStore instore:_instoreStore];
        if (_isShowSeeMore) {
            _seemoreButton.hidden = NO;
        }
        else {
            _seemoreButton.hidden = YES;
        }
}

-(NSInteger)getBackgroundHeight:(ProductAvailability*)online instore:(ProductAvailability*)instore {
    NSInteger height = 76;
    if (online != nil)
    {
        if (online.storename != nil && ![online.storename isEqualToString:@""]) {
            height = height + 27;
        }
        if (online.website != nil && ![online.website isEqualToString:@""]) {
            height = height + ONLINEVIEW_HEIGHT;
        }
    }
    if (instore != nil)
    {
        if (instore.address != nil && ![instore.address isEqualToString:@""]) {
            height = height + LOCATIONVIEW_HEIGHT;
        }
        if (instore.telephone != nil && ![instore.telephone isEqualToString:@""]) {
            height = height + ONLINEVIEW_HEIGHT;
        }
        if (![[self getTimeString:instore] isEqualToString:@""]) {
            height = height + ONLINEVIEW_HEIGHT;
        }
        if (instore.latitude != nil && instore.longitude != nil) {
            height = height + MAPVIEW_HEIGHT;
        }
    }

    if (height > self.view.bounds.size.height - 350) {
        _isFill = YES;
    }
    else {
        _isFill = NO;
    }
    return height;
}
-(void)swipeUp:(NSInteger)height {
    CGRect frame = self.bgView.frame;
    frame.origin.y = height - frame.size.height;

    [UIView animateWithDuration:0.8
                          delay:0
                        options: UIViewAnimationCurveEaseIn
                     animations:^{
                         [self.bgView setFrame:frame];
                     }
                     completion:^(BOOL finished){
                         [self.view setUserInteractionEnabled:YES];
                     }];
    _isEnd = YES;
}

-(void)swipeDown {
    CGRect frame = self.bgView.frame;
    frame.origin.y = 0;

    [UIView animateWithDuration:0.8
                          delay:0
                        options: UIViewAnimationCurveEaseIn
                     animations:^{
                         [self.bgView setFrame:frame];
                     }
                     completion:^(BOOL finished){
                         [self.view setUserInteractionEnabled:YES];
                     }];
    _isEnd = NO;
}
- (IBAction)onTapSeeMore:(id)sender {
    [_delegate onTapSeeMoreAvailability];
}

- (IBAction)onTabWebSite:(id)sender {
    [_delegate onTapWebSite];
}

- (IBAction)onTapMap:(id)sender {
    CLLocation *mylocation = [[CLLocation alloc] initWithLatitude:[_instoreStore.latitude doubleValue] longitude:[_instoreStore.longitude doubleValue]];
    NSString *ll = [NSString stringWithFormat:@"%f,%f",
                    mylocation.coordinate.latitude,
                    mylocation.coordinate.longitude];
    ll = [ll stringByAddingPercentEncodingWithAllowedCharacters:NSCharacterSet.URLQueryAllowedCharacterSet];
    NSString *url = [NSString stringWithFormat:@"http://maps.apple.com/?q=%@", ll];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
}

-(NSString*)getTimeString:(ProductAvailability*)availability {
    NSString *timeString = @"";

    NSDate *weekDate = [NSDate date];
    NSCalendar *myCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];

    NSDateComponents *currentComps = [myCalendar components:( NSWeekOfYearCalendarUnit | NSWeekdayCalendarUnit ) fromDate:weekDate];

    NSInteger weekday = currentComps.weekday;

    if (availability.timetables != nil) {
        NSArray *time_array = [availability.timetables allObjects];
        for (int j = 0; j < [time_array count]; j++) {
            ProductAvailabilityTimeTable *timetable = (ProductAvailabilityTimeTable*)[time_array objectAtIndex:j];

            if ([timetable.dayweek integerValue] == weekday - 1) {
                NSArray *hours_array = [timetable.hours allObjects];
                for (int i = 0; i < [hours_array count]; i++) {
                    ProductAvailabilityTimeTableIntervalTime *timetableIntervalTime = (ProductAvailabilityTimeTableIntervalTime*)[hours_array objectAtIndex:i];
                    
                    NSString *open = timetableIntervalTime.open;
                    NSString *close = timetableIntervalTime.close;
                    
                    timeString = [NSString stringWithFormat:@"%@ %@-%@", timeString, open, close];
                }
            }
        }
    }
    
    return timeString;
}

@end
