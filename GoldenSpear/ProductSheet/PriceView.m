//
//  PriceView.m
//  AnimationSample
//
//  Created by jcb on 7/16/16.
//  Copyright © 2016 dikwessels. All rights reserved.
//

#import "PriceView.h"

@interface PriceView()

@end

@implementation PriceView

-(void)viewDidLoad {
	[super viewDidLoad];

	_priceLabel.text = _price;
    _priceLabel.adjustsFontSizeToFitWidth = YES;
}

-(void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
}

@end