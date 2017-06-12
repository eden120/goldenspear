//
//  BaseViewController+ActivityFeedbackManagement.m
//  GoldenSpear
//
//  Created by Jose Antonio Sanchez Martinez on 16/04/15.
//  Copyright (c) 2015 GoldenSpear. All rights reserved.
//

#import "BaseViewController+ActivityFeedbackManagement.h"
#import "BaseViewController+TopBarManagement.h"
#import "BaseViewController+BottomControlsManagement.h"
#import "BaseViewController+StoryboardManagement.h"

#import <objc/runtime.h>

#define kScreenPortionForActivityIndicatorVerticalCenter 0.35
#define kActivityLabelBackgroundColor grayColor
#define kActivityLabelAlpha 0.1
#define kFontInActivityLabel "Avenir-Light"
#define kFontSizeInActivityLabel 16

static char ACTIVITYLABEL_KEY;
static char ACTIVITYINDICATOR_KEY;


@implementation BaseViewController (ActivityFeedbackManagement)


#pragma mark - Activity feedback managememt

// Getter and setter for Activity Label
- (UILabel *)activityLabel
{
    return objc_getAssociatedObject(self, &ACTIVITYLABEL_KEY);
}

- (void)setActivityLabel:(UILabel *)activityLabel
{
    objc_setAssociatedObject(self, &ACTIVITYLABEL_KEY, activityLabel, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

// Getter and setter for Activity Indicator
- (UIActivityIndicatorView *)activityIndicator
{
    return objc_getAssociatedObject(self, &ACTIVITYINDICATOR_KEY);
}

- (void)setActivityIndicator:(UIActivityIndicatorView *)activityIndicator
{
    objc_setAssociatedObject(self, &ACTIVITYINDICATOR_KEY, activityIndicator, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

// Initialize activity feedback
- (void)initActivityFeedback
{
    if (self.activityIndicator == nil)
    {
    
       // Init, position and hide the activity indicator
        self.activityIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [self.activityIndicator setCenter:CGPointMake(self.view.frame.size.width / 2.0, self.view.frame.size.height * kScreenPortionForActivityIndicatorVerticalCenter)];
        [self.activityIndicator setHidesWhenStopped:YES];
        [self.activityIndicator stopAnimating];
        
        [self.view addSubview: self.activityIndicator];
        
        // Init, position and hide the activity label
        self.activityLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
        //[[self.activityLabel layer] setCornerRadius:5];
        [self.activityLabel setBackgroundColor:[UIColor kActivityLabelBackgroundColor]];
        [self.activityLabel setAlpha:kActivityLabelAlpha];
        //[self.activityLabel setCenter:CGPointMake(self.view.frame.size.width / 2.0, self.view.frame.size.height / 2.0)];
        [self.activityLabel setText:nil];
        [self.activityLabel setFont:[UIFont fontWithName:@kFontInActivityLabel size:kFontSizeInActivityLabel]];
        [self.activityLabel setTextAlignment:NSTextAlignmentCenter];
        [self.activityLabel setHidden:YES];
        self.activityLabel.userInteractionEnabled = YES;
        self.activityLabel.opaque = YES;
        [self.view addSubview: self.activityLabel];
    }
}

// Start activity feedback
- (void)startActivityFeedbackWithMessage:(NSString *) activityMessage
{
    if (self.activityIndicator.hidden)
    {
        [self.activityLabel setText:activityMessage];
        [self.activityLabel setHidden:NO];
        [self.view bringSubviewToFront:self.activityLabel];
        
        [self.activityIndicator startAnimating];
        [self.activityIndicator setHidden:NO];
        self.activityLabel.opaque = YES;
        CGFloat height = self.view.frame.size.height;
        if(!(self.topBarView.hidden||!self.topBarView||self.currentPresenterViewController))
        {
            height -= 60;
        }
        if([self shouldCreateBottomButtons]){
            height -= 60;
        }
        self.activityLabel.frame = CGRectMake(0, 0, self.view.frame.size.width, height);
        self.activityLabel.center = self.view.center;
        
        [self.view bringSubviewToFront:self.activityLabel];
        [self.view bringSubviewToFront:self.activityIndicator];
    }
    else
    {
        // actualiar el label del activity indicator
        [self.activityLabel setText:activityMessage];
    }
}

// Stop activity feedback
- (void)stopActivityFeedback
{
    [self.activityIndicator setHidden:YES];
    [self.activityIndicator stopAnimating];
    //[self.view setUserInteractionEnabled:YES];
    
    [self.activityLabel setHidden:YES];
    [self.activityLabel setText:nil];
}

@end
