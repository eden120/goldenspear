//
//  GSHelpSupportViewController.h
//  GoldenSpear
//
//  Created by Adria Vernetta Rubio on 23/5/16.
//  Copyright © 2016 GoldenSpear. All rights reserved.
//

#import "BaseViewController.h"

@interface GSHelpSupportViewController : BaseViewController<MFMailComposeViewControllerDelegate,UIWebViewDelegate>

- (IBAction)buttonSupportPush:(id)sender;
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityLoader;

@end
