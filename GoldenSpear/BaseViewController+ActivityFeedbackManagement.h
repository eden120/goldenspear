//
//  BaseViewController+ActivityFeedbackManagement.h
//  GoldenSpear
//
//  Created by Jose Antonio Sanchez Martinez on 16/04/15.
//  Copyright (c) 2015 GoldenSpear. All rights reserved.
//

#import "BaseViewController.h"


@interface BaseViewController (ActivityFeedbackManagement)

// Activity feedback management
@property UILabel *activityLabel;
@property UIActivityIndicatorView *activityIndicator;
- (void)initActivityFeedback;
- (void)startActivityFeedbackWithMessage:(NSString *) activityMessage;
- (void)stopActivityFeedback;

@end
