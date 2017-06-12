//
//  ReviewTableView.h
//  GoldenSpear
//
//  Created by JCB on 8/10/16.
//  Copyright © 2016 GoldenSpear. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RateView.h"
#import "Review.h"
#import "ReviewView.h"
#import "ReviewTableViewCell.h"

@protocol Delegate <NSObject>

-(void)onTapWriteReview;

@end

@interface ReviewTableView : UIViewController

@property(nonatomic, retain) id<Delegate> delegate;

@property (weak, nonatomic) IBOutlet UITableView *reviewList;

@property (nonatomic) NSMutableArray *reviews;

@end
