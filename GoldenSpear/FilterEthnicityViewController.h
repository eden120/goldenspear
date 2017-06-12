//
//  FilterEthnicityViewController.h
//  GoldenSpear
//
//  Created by Crane on 9/21/16.
//  Copyright © 2016 GoldenSpear. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "GSEthnyView.h"
@protocol FilterEthnicityDelegate;
@interface FilterEthnicityViewController : BaseViewController<GSEthnyViewDelegate>
@property (weak, nonatomic) IBOutlet UIView *ethnicitiesContainer;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *ethnicitiesContainerHeight;
@property (weak, nonatomic) IBOutlet UIScrollView *mainScroll;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *scrollBottomDistanceConstraint;
@property (weak, nonatomic) IBOutlet UIView *ethnicityView;
@property (nonatomic, assign) id <FilterEthnicityDelegate> filterEthnicityDelegate;
@property int type;
@property NSMutableArray *selectedEthy;

@property (weak, nonatomic) id<GSRelatedViewControllerDelegate> relatedDelegate;

- (void)fixLayout;

- (IBAction)savePushed:(id)sender;
@end

@protocol FilterEthnicityDelegate <NSObject>
@optional
-(void) setEthnicity:(NSMutableArray*)ethnicties type:(int)type;
@end