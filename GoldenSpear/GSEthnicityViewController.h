//
//  GSEthnicityViewController.h
//  GoldenSpear
//
//  Created by Adria Vernetta Rubio on 9/5/16.
//  Copyright © 2016 GoldenSpear. All rights reserved.
//

#import "BaseViewController.h"
#import "GSEthnyView.h"

@interface GSEthnicityViewController : BaseViewController<GSEthnyViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *ethnicitiesContainer;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *ethnicitiesContainerHeight;
@property (weak, nonatomic) IBOutlet UIScrollView *mainScroll;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *scrollBottomDistanceConstraint;

@property (weak, nonatomic) id<GSRelatedViewControllerDelegate> relatedDelegate;

- (void)fixLayout;

- (IBAction)savePushed:(id)sender;

@end
