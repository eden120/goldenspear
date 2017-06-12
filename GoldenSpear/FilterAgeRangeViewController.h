//
//  FilterAgeRangeViewController.h
//  GoldenSpear
//
//  Created by Crane on 9/21/16.
//  Copyright © 2016 GoldenSpear. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SearchBaseViewController.h"
@protocol FilterAgeRangeDelegate;

@interface FilterAgeRangeViewController : SearchBaseViewController
@property (weak, nonatomic) IBOutlet UIView *ageView;
@property (weak, nonatomic) IBOutlet UITextField *maxAgeText;
@property (weak, nonatomic) IBOutlet UITextField *minAgeText;
@property (nonatomic) followingRelationships userListMode;
@property (nonatomic, assign) id <FilterAgeRangeDelegate> filterAgeDelegate;
@property NSMutableArray *ageArry;
@property int type;
@end


@protocol FilterAgeRangeDelegate <NSObject>
@optional
-(void) setAgeRange:(NSMutableArray*)ages type:(int)type;
@end