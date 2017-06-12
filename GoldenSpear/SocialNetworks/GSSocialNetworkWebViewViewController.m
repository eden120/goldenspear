//
//  GSSocialNetworkWebViewViewController.m
//  GoldenSpear
//
//  Created by Adria Vernetta Rubio on 27/5/16.
//  Copyright © 2016 GoldenSpear. All rights reserved.
//

#import "GSSocialNetworkWebViewViewController.h"

@interface GSSocialNetworkWebViewViewController ()

@end

@implementation GSSocialNetworkWebViewViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.translatesAutoresizingMaskIntoConstraints = NO;
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self showLoadingIndicator:YES];
}

- (void)showLoadingIndicator:(BOOL)show{
    if(show){
        [self.loadingIndicator startAnimating];
        [self.loadingIndicator.superview bringSubviewToFront:self.loadingIndicator];
    }else{
        [self.loadingIndicator.superview sendSubviewToBack:self.loadingIndicator];
    }
}

@end
