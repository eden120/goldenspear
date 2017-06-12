//
//  GSHelpSupportViewController.m
//  GoldenSpear
//
//  Created by Adria Vernetta Rubio on 23/5/16.
//  Copyright © 2016 GoldenSpear. All rights reserved.
//

#import "GSHelpSupportViewController.h"

@interface GSHelpSupportViewController ()

@end

@implementation GSHelpSupportViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    NSURL *websiteUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@/terms_conditions.html",IMAGESBASEURL]];
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:websiteUrl];
    [self.webView loadRequest:urlRequest];
    [self.activityLoader startAnimating];
}

- (BOOL)shouldCenterTitle{
    return YES;
}

- (BOOL)shouldCreateHintButton{
    return NO;
}

- (IBAction)buttonSupportPush:(id)sender {
    [self showEmail];
}

- (void)showEmail
{
    // Get the Global Mail Composer
    AppDelegate * appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    
    if ([MFMailComposeViewController canSendMail])
    {
        [appDelegate cycleGlobalMailComposer];
        
        // Compose Email
        [appDelegate.globalMailComposer setSubject:NSLocalizedString(@"_SUPPORT_EMAIL_TITLE_", nil)];
        
        [appDelegate.globalMailComposer setToRecipients:[NSArray arrayWithObject:@"support@goldenspear.com"]];
        
        // Present mail view controller on screen
        appDelegate.globalMailComposer.mailComposeDelegate = self;
        
        [self presentViewController:appDelegate.globalMailComposer animated:YES completion:NULL];
        
    }
    else
    {
        [appDelegate cycleGlobalMailComposer];
    }
}
- (void)mailComposeController:(MFMailComposeViewController *)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError *)error
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView{
    [self.activityLoader.superview sendSubviewToBack:self.activityLoader];
    self.activityLoader.hidden = YES;
}

@end
