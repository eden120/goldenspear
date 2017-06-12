//
//  AvailabilityTableView.m
//  GoldenSpear
//
//  Created by JCB on 8/6/16.
//  Copyright © 2016 GoldenSpear. All rights reserved.
//

#import "AvailabilityTableView.h"
#import "Product+Manage.h"
#import "AppDelegate.h"
#import "ProductSheetViewController.h"


#define STORENAMEVIEW_HEIGHT        25
#define LOCATIONVIEW_HEIGHT         74
#define ONLINEVIEW_HEIGHT           45
#define MAPVIEW_HEIGHT              200

@implementation storeNameCell

@end

@implementation locationCell

@end

@implementation onlineCell

@end

@implementation phoneCell

@end

@implementation timetableCell

@end

@implementation mapCell

@end

@interface AvailabilityTableView() <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *storeListView;
@property (weak, nonatomic) IBOutlet UIButton *instoreButton;
@property (weak, nonatomic) IBOutlet UIButton *onlineButton;

@end

@implementation AvailabilityTableView {
    NSInteger viewstate;
}

-(void)viewDidLoad {
    [super viewDidLoad];
    viewstate = ONLINE_INSTORE;
    
    _onlinelist = [[NSMutableArray alloc] init];
    _instorelist = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < [_availabilities count]; i ++) {
        ProductAvailability *availability = (ProductAvailability*) [_availabilities objectAtIndex:i];
        if ([availability.online boolValue]) {
            [_onlinelist addObject:availability];
        }
        else {
            [_instorelist addObject:availability];
        }
    }
    
    switch (viewstate) {
        case ONLINE_INSTORE:
            _datalist = _availabilities;
            break;
        case ONLINE_ONLY:
            _datalist = _onlinelist;
            break;
        case INSTORE_ONLY:
            _datalist = _instorelist;
            break;
        default:
            break;
    }
    [_storeListView reloadData];
}

-(void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - TableView Delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return [_datalist count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    ProductAvailability *availability = (ProductAvailability*) [_datalist objectAtIndex:section];
    return [self getRows:availability];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    ProductAvailability *availability = (ProductAvailability*) [_datalist objectAtIndex:indexPath.section];
    
    NSInteger height = 0;
    switch (indexPath.row) {
        case 0:
            height = STORENAMEVIEW_HEIGHT;
            break;
        case 1:
            if ([availability.online boolValue]) {
                height = ONLINEVIEW_HEIGHT;
            }
            else {
                height = LOCATIONVIEW_HEIGHT;
            }
            break;
        case 2:
            if (![availability.online boolValue]) {
                height = ONLINEVIEW_HEIGHT;
            }
            break;
        case 3:
            if (![availability.online boolValue]) {
                if (![[self getTimeString:availability] isEqualToString:@""]){
                    height = ONLINEVIEW_HEIGHT;
                }
                else {
                    height = MAPVIEW_HEIGHT;
                }
            }
            break;
        case 4:
            if (![availability.online boolValue]) {
                height = MAPVIEW_HEIGHT;
            }
            break;
        default:
            break;
    }
    return height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    ProductAvailability *availability = (ProductAvailability*) [_datalist objectAtIndex:indexPath.section];
    
    if (indexPath.row == 0) {
        storeNameCell *cell = [tableView dequeueReusableCellWithIdentifier:@"storeNameCell"];
        if (availability.storename != nil && ![availability.storename isEqualToString:@""]) {
            cell.storeName.text = availability.storename;
        }
        return cell;
    }
    else if (indexPath.row == 1) {
        if ([availability.online boolValue]) {
            onlineCell *cell = [tableView dequeueReusableCellWithIdentifier:@"onlineCell"];
            if (availability.website != nil && ![availability.website isEqualToString:@""]) {
                cell.websiteLabel.text = availability.website;
            }
            return cell;
        }
        else {
            locationCell *cell = [tableView dequeueReusableCellWithIdentifier:@"locationCell"];
            if (availability.address != nil) {
                cell.streetLabel.text = availability.address;
            }
            if (availability.shoppingcenter != nil) {
                cell.centerLabel.text = availability.shoppingcenter;
            }
            if (availability.distance != nil) {
                cell.distanceLabel.text = [NSString stringWithFormat:@"%f %@", [availability.distance doubleValue], availability.units];
            }
            else {
                cell.distanceLabel.text = @"";
            }
            if (availability.zipcode != nil && availability.city != nil && availability.state != nil) {
                cell.countryLabel.text = [NSString stringWithFormat:@"%@, %@ %@", availability.city, availability.state, availability.zipcode];
            }
            cell.locationButton.tag = indexPath.section;
            return cell;
        }
    }
    else if (indexPath.row == 2) {
        phoneCell *cell = [tableView dequeueReusableCellWithIdentifier:@"phoneCell"];
        if (availability.telephone != nil && ![availability.telephone isEqualToString:@""]) {
            cell.phoneLabel.text = availability.telephone;
        }
        return cell;
    }
    else if (indexPath.row == 3) {
        if (![[self getTimeString:availability] isEqualToString:@""]) {
            timetableCell *cell = [tableView dequeueReusableCellWithIdentifier:@"timeCell"];
            cell.timeLabel.text = [NSString stringWithFormat:@"Open now : %@",[self getTimeString:availability]];
            return cell;
        }
        else {
            mapCell *cell = [tableView dequeueReusableCellWithIdentifier:@"mapCell"];
            if (availability.latitude != nil && availability.longitude != nil) {
                CLLocation *mylocation = [[CLLocation alloc] initWithLatitude:[availability.latitude doubleValue] longitude:[availability.longitude doubleValue]];
                MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(mylocation.coordinate, 200, 200);
                cell.mapView.region = region;
                
                MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
                annotation.coordinate = mylocation.coordinate;
                
                [cell.mapView addAnnotation:annotation];
                
                NSString *ll = [NSString stringWithFormat:@"%f,%f",
                                mylocation.coordinate.latitude,
                                mylocation.coordinate.longitude];
                
                cell.mapButton.accessibilityLabel = ll;
            }
            return cell;

        }
    }
    else if (indexPath.row == 4) {
        mapCell *cell = [tableView dequeueReusableCellWithIdentifier:@"mapCell"];
        if (availability.latitude != nil && availability.longitude != nil) {
            CLLocation *mylocation = [[CLLocation alloc] initWithLatitude:[availability.latitude doubleValue] longitude:[availability.longitude doubleValue]];
            MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(mylocation.coordinate, 200, 200);
            cell.mapView.region = region;
            
            MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
            annotation.coordinate = mylocation.coordinate;
            
            [cell.mapView addAnnotation:annotation];
            
            NSString *ll = [NSString stringWithFormat:@"%f,%f",
                            mylocation.coordinate.latitude,
                            mylocation.coordinate.longitude];
            
            cell.mapButton.accessibilityLabel = ll;
        }
        return cell;
    }
    
    return nil;
}

-(NSInteger)getRows:(ProductAvailability*)availability {
    NSInteger row = 0;
    switch (viewstate) {
        case ONLINE_INSTORE:
        {
            if (availability.storename != nil && ![availability.storename isEqualToString:@""]) {
                row = row + 1;
            }
            if (availability.address != nil && ![availability.address isEqualToString:@""]) {
                row = row + 1;
            }
            if (availability.website != nil && ![availability.website isEqualToString:@""]) {
                row = row + 1;
            }
//            if (availability.telephone != nil && ![availability.telephone isEqualToString:@""]) {
//                row = row + 1;
//            }
//            if (![[self getTimeString:availability] isEqualToString:@""]) {
//                row = row + 1;
//            }
//            if (availability.latitude != nil && availability.longitude != nil) {
//                row = row + 1;
//            }
            break;
        }
        case ONLINE_ONLY:
        {
            if (availability.storename != nil && ![availability.storename isEqualToString:@""]) {
                row = row + 1;
            }
            if (availability.website != nil && ![availability.website isEqualToString:@""]) {
                row = row + 1;
            }
            break;
        }
        case INSTORE_ONLY:
        {
            if (availability.storename != nil && ![availability.storename isEqualToString:@""]) {
                row = row + 1;
            }
            if (availability.address != nil && ![availability.address isEqualToString:@""]) {
                row = row + 1;
            }
//            if (availability.telephone != nil && ![availability.telephone isEqualToString:@""]) {
//                row = row + 1;
//            }
//            if (![[self getTimeString:availability] isEqualToString:@""]) {
//                row = row + 1;
//            }
//            if (availability.latitude != nil && availability.longitude != nil) {
//                row = row + 1;
//            }
            break;
        }
        default:
            break;
    }
    return row;
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
- (IBAction)onTapLocation:(id)sender {
    ProductAvailability *availability = [_datalist objectAtIndex:((UIButton *)sender).tag];
    {
        [((ProductSheetViewController *)[self parentViewController]) showFullViewAvailability:availability];
    }
}
- (IBAction)onTapWebSite:(id)sender {
    if ([[self parentViewController] isKindOfClass: [ProductSheetViewController class]])
    {
        [((ProductSheetViewController *)[self parentViewController]) showWebsite];
    }

}
- (IBAction)onTapClose:(id)sender {
    if ([[self parentViewController] isKindOfClass: [ProductSheetViewController class]])
    {
        [((ProductSheetViewController *)[self parentViewController]) closeSeeMoreAvailability];
    }
}
- (IBAction)onTapInStore:(id)sender {
    if (viewstate == INSTORE_ONLY) {
        viewstate = ONLINE_INSTORE;
        _instoreButton.backgroundColor = [UIColor lightGrayColor];
        _onlineButton.backgroundColor = [UIColor lightGrayColor];
        _datalist = _availabilities;
    }
    else {
        viewstate = INSTORE_ONLY;
        _instoreButton.backgroundColor = [UIColor blackColor];
        _onlineButton.backgroundColor = [UIColor lightGrayColor];
        _datalist = _instorelist;
    }
    [_storeListView reloadData];
}
- (IBAction)onTapOnline:(id)sender {
    if (viewstate == ONLINE_ONLY) {
        viewstate = ONLINE_INSTORE;
        _instoreButton.backgroundColor = [UIColor lightGrayColor];
        _onlineButton.backgroundColor = [UIColor lightGrayColor];
        _datalist = _availabilities;
    }
    else {
        viewstate = ONLINE_ONLY;
        _onlineButton.backgroundColor = [UIColor blackColor];
        _instoreButton.backgroundColor = [UIColor lightGrayColor];
        _datalist = _onlinelist;
    }
    [_storeListView reloadData];
}
- (IBAction)openMap:(id)sender {
    UIButton *button = (UIButton *)sender;
    NSString *ll = button.accessibilityLabel;
    ll = [ll stringByAddingPercentEncodingWithAllowedCharacters:NSCharacterSet.URLQueryAllowedCharacterSet];
    NSString *url = [NSString stringWithFormat:@"http://maps.apple.com/?q=%@", ll];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
}

@end