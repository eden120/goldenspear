//
//  CollectionViewFooterReusableView.m
//  GoldenSpear
//
//  Created by Jose Antonio Sanchez Martinez on 22/06/15.
//  Copyright (c) 2015 GoldenSpear. All rights reserved.
//

#import "CollectionViewFooterReusableView.h"


@implementation CollectionViewFooterReusableView


#pragma mark - Accessors


- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        self.backgroundColor = [UIColor colorWithRed:255/255 green:255/255 blue:255/255 alpha:0.4];
    }
    
    return self;
}

@end
