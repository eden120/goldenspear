//
//  ReviewTableView.m
//  GoldenSpear
//
//  Created by JCB on 8/10/16.
//  Copyright © 2016 GoldenSpear. All rights reserved.
//

#import "ReviewTableView.h"

@interface ReviewTableView()

@end

@implementation ReviewTableView

-(void)viewDidLoad {
    [super viewDidLoad];
    [_reviewList reloadData];
}

-(void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
- (IBAction)onTapAddReview:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
    [_delegate onTapWriteReview];
}
- (IBAction)onTapClose:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)initView {
    [_reviewList reloadData];
}

#pragma mark - TableView Delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [_reviews count];
}

//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
//    return 85;
//}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    Review *review = [_reviews objectAtIndex:indexPath.row];
    ReviewTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ReviewTableViewCell"];
    cell.userNameLabel.text = review.user.name;
    cell.rateView.rating = [review.overall_rating floatValue];
    cell.commentLabel.text = review.text;
    cell.rateView.notSelectedImage = [UIImage imageNamed:@"notSelectedImage.png"];
    cell.rateView.halfSelectedImage = [UIImage imageNamed:@"halfSelectedImage.png"];
    cell.rateView.fullSelectedImage = [UIImage imageNamed:@"fullSelectedImage.png"];
    cell.rateView.editable = NO;
    cell.rateView.maxRating = 5;
    cell.rateView.midMargin = 0;
    cell.rateView.userInteractionEnabled = NO;
    
    int thirdDays = (int) [self getDays:review.date];
    if (thirdDays > 30) {
        cell.dateLabel.text = [NSString stringWithFormat:@"%i%@", thirdDays/30, @"M"];
    }
    else if (thirdDays == 0) {
        if ([self getHour:review.date] == 0) {
            cell.dateLabel.text = [NSString stringWithFormat:@"%i%@", (int)[self getMin:review.date], @"MM"];
        }
        else {
            cell.dateLabel.text = [NSString stringWithFormat:@"%i%@", (int)[self getHour:review.date], @"H"];
        }
    }
    else {
        cell.dateLabel.text = [NSString stringWithFormat:@"%i%@", thirdDays, @"D"];
    }
    
    return cell;
}

-(NSInteger)getDays:(NSDate*)date {
    NSDate *now = [[NSDate alloc] init];
    
    NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *components = [gregorianCalendar components:NSCalendarUnitDay
                                                        fromDate:date
                                                          toDate:now
                                                         options:0];
    return [components day];
}

-(NSInteger)getHour:(NSDate*)date {
    NSDate *now = [[NSDate alloc] init];
    
    NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *components = [gregorianCalendar components:NSCalendarUnitHour
                                                        fromDate:date
                                                          toDate:now
                                                         options:0];
    return [components hour];
}

-(NSInteger)getMin:(NSDate*)date {
    NSDate *now = [[NSDate alloc] init];
    
    NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *components = [gregorianCalendar components:NSCalendarUnitMinute
                                                        fromDate:date
                                                          toDate:now
                                                         options:0];
    if ([components minute] < 0) {
        return 0;
    }
    return [components minute];
}

@end
