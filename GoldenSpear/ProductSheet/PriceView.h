//
//  PriceView.h
//  AnimationSample
//
//  Created by jcb on 7/16/16.
//  Copyright © 2016 dikwessels. All rights reserved.
//


#import <UIKit/UIKit.h>

@interface PriceView : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (nonatomic) NSString *price;

@end