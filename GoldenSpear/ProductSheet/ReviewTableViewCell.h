//
//  ReviewTableViewCell.h
//  GoldenSpear
//
//  Created by JCB on 8/10/16.
//  Copyright © 2016 GoldenSpear. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RateView.h"

@interface ReviewTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *commentLabel;
@property (weak, nonatomic) IBOutlet RateView *rateView;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@end