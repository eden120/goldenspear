//
//  ReviewView.m
//  GoldenSpear
//
//  Created by jcb on 7/24/16.
//  Copyright © 2016 GoldenSpear. All rights reserved.
//

#import "ReviewView.h"
#import "Review.h"
#import "ReviewCell.h"
#import <AFNetworking.h>

#define NOREVIEW_HEIGHT         99
#define RATINGVIEW_HEIGHT       139
#define WRITEREVIEW_TOP_MIN     15
#define WRITEREVIEW_TOP_MAX     130

@interface ReviewView()

@end

@implementation ReviewView 

@synthesize availableWriteReview;

-(void)viewDidLoad {
	[super viewDidLoad];
	
	//_hasReview = NO;
	availableWriteReview = YES;
    _isShownReview = NO;
    
    _overallView.notSelectedImage = [UIImage imageNamed:@"notSelectedImage.png"];
    _overallView.halfSelectedImage = [UIImage imageNamed:@"halfSelectedImage.png"];
    _overallView.fullSelectedImage = [UIImage imageNamed:@"fullSelectedImage.png"];
    _overallView.rating = 2;
    _overallView.editable = NO;
    _overallView.maxRating = 5;
    _overallView.midMargin = 0;
    _qualityView.userInteractionEnabled = NO;
    
    _comfortView.notSelectedImage = [UIImage imageNamed:@"notSelectedImage.png"];
    _comfortView.halfSelectedImage = [UIImage imageNamed:@"halfSelectedImage.png"];
    _comfortView.fullSelectedImage = [UIImage imageNamed:@"fullSelectedImage.png"];
    _comfortView.rating = 3;
    _comfortView.editable = NO;
    _comfortView.maxRating = 5;
    _comfortView.midMargin = 0;
    _comfortView.userInteractionEnabled = NO;
    
    _qualityView.notSelectedImage = [UIImage imageNamed:@"notSelectedImage.png"];
    _qualityView.halfSelectedImage = [UIImage imageNamed:@"halfSelectedImage.png"];
    _qualityView.fullSelectedImage = [UIImage imageNamed:@"fullSelectedImage.png"];
    _qualityView.rating = 5;
    _qualityView.editable = NO;
    _qualityView.maxRating = 5;
    _qualityView.midMargin = 0;
    _qualityView.userInteractionEnabled = NO;
    
    _firstReviewView.hidden = YES;
    _secondReviewView.hidden = YES;
    _thirdReviewView.hidden = YES;
}

-(void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
}

-(void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:YES];
    
    _isShownReview = NO;
    
    [self initView];
}

-(void)initView {
    _isShownReview = NO;
    
    CGRect frame = self.totalView.frame;
    frame.origin.y = 0;
    [self.totalView setFrame: frame];
    
    _userReviewView.hidden = YES;
    
    
    [_reviewList reloadData];
    
    if ([_reviews count] > 0) {
        _hasReview = YES;
    }
    else {
        _hasReview = NO;
    }
    if (!availableWriteReview) {
        _writeReviewBTN.hidden = YES;
    }
    
    if (_hasReview) {
        _noReviewTxt.hidden = YES;
        _noReviewHeightConstraint.constant = 0;
        _ratingView.hidden = NO;
        _ratingViewHeightConstraint.constant = RATINGVIEW_HEIGHT;
        
        if (_reviewCount > 3) {
            _seemoreButton.hidden = NO;
        }
        else {
            _seemoreButton.hidden = YES;
        }
    }
    else {
        _noReviewHeightConstraint.constant = NOREVIEW_HEIGHT;
        _noReviewTxt.hidden = NO;
        _ratingView.hidden = YES;
        _ratingViewHeightConstraint.constant = 0;
    }
}

- (IBAction)onTapWriteReview:(id)sender {
	[_delegate onTapWriteReview];
}

- (IBAction)onTapSeeMore:(id)sender {
    [_delegate onTapSeeMoreReviews];
}

-(void)shownUserReviews:(NSInteger)height {
    CGRect frame = _totalView.frame;
    frame.origin.y = height - _totalView.frame.size.height - 50;
    
    [UIView animateWithDuration:1
                          delay:0.1
                        options: UIViewAnimationCurveEaseIn
                     animations:^{
                         [_totalView setFrame:frame];
                     }
                     completion:^(BOOL finished){
                         _userReviewView.hidden = NO;
                     }];
    
    [_reviewList reloadData];
    _isShownReview = YES;
}

-(void)hiddenUserReview {
    CGRect frame = self.totalView.frame;
    frame.origin.y = 0;
    
    [UIView animateWithDuration:0.8
                          delay:0
                        options: UIViewAnimationCurveEaseIn
                     animations:^{
                         [self.totalView setFrame:frame];
                     }
                     completion:^(BOOL finished){
                         _userReviewView.hidden = YES;
                     }];
    
    _isShownReview = NO;
}

#pragma mark - TableView Delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if ([_reviews count] > 3) {
        return 3;
    }
    return [_reviews count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    Review *review = [_reviews objectAtIndex:indexPath.row];
    ReviewTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ReviewViewCell"];
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