//
//  GSSocialNetworkWebViewViewController.h
//  GoldenSpear
//
//  Created by Adria Vernetta Rubio on 27/5/16.
//  Copyright © 2016 GoldenSpear. All rights reserved.
//

#import "BaseViewController.h"

@interface GSSocialNetworkWebViewViewController : BaseViewController

@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingIndicator;

- (void)showLoadingIndicator:(BOOL)show;

@end
