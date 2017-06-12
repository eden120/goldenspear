//
//  AvailabiliyView.h
//  GoldenSpear
//
//  Created by JCB on 9/19/16.
//  Copyright © 2016 GoldenSpear. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Product+Manage.h"

@import MapKit;

@protocol AvailabilityDelegate <NSObject>

-(void)onTapSeeMoreAvailability;
-(void)onTapWebSite;
@end

@interface AvailabiliyView : UIViewController

@property(nonatomic, retain) id<AvailabilityDelegate> delegate;
@property(nonatomic) BOOL isEnd;
@property(nonatomic) BOOL isFill;
@property(nonatomic) BOOL isShowSeeMore;
@property (nonatomic) CLLocationCoordinate2D coordinate;
@property (nonatomic) ProductAvailability *onlineStore;
@property (nonatomic) ProductAvailability *instoreStore;
@property (nonatomic) NSInteger onlinestate;

-(void)initView;
-(void)swipeUp:(NSInteger)height;
-(void)swipeDown;

@end

