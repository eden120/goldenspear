//
//  GSSocialNetworkHandlerFlicker.m
//  GoldenSpear
//
//  Created by Adria Vernetta Rubio on 2/6/16.
//  Copyright © 2016 GoldenSpear. All rights reserved.
//

#import "GSSocialNetworkHandlerPinterest.h"
#import "BaseViewController+StoryboardManagement.h"
#import "GSSocialNetworkWebViewViewController.h"
#import "BaseViewController+ActivityFeedbackManagement.h"

#define kPinterestAPPId @"4801888447887321576"
#define kPinterestAPPSecret @"44e1843844cae980913a69843132649327cafa8f2c35d40d4b573b01c9977e10"
#define kREDIRECTURI @"https://app.goldenspear.com"

typedef void (^NSURLConnectionCompletionHandler)(NSURLResponse *, NSData *, NSError *);

@implementation GSSocialNetworkHandlerPinterest{
    GSSocialNetworkWebViewViewController *nextViewController;
}

- (void)loginUserToSocialNetwork{
    NSHTTPCookie *cookie;
    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (cookie in [storage cookies])
    {
        NSString* domainName = [cookie domain];
        NSRange domainRange = [domainName rangeOfString:@"pinterest.com"];
        if(domainRange.length > 0)
        {
            [storage deleteCookie:cookie];
        }
    }
    
    NSString *fullURL = [NSString stringWithFormat:@"https://api.pinterest.com/oauth/?client_id=%@&response_type=code&scope=read_relationships&redirect_uri=%@",kPinterestAPPId,kREDIRECTURI];
    
    UIStoryboard *nextStoryboard = [UIStoryboard storyboardWithName:@"UserAccount" bundle:nil];
    nextViewController = [nextStoryboard instantiateViewControllerWithIdentifier:[@(SOCIALNETWORKWEBVIEW_VC) stringValue]];
    
    [nextViewController prepareViewController:nextViewController withParameters:nil];
    
    [(BaseViewController*)self.delegate showViewControllerModal:nextViewController withTopBar:YES];
    [nextViewController setTitleForModal:@"LINK ACCOUNT"];
    nextViewController.webView.delegate = self;
    [(BaseViewController*)self.delegate stopActivityFeedback];
    
    NSURL *url = [NSURL URLWithString:fullURL];
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
    [nextViewController.webView loadRequest:requestObj];
}

-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    [nextViewController showLoadingIndicator:YES];
    NSString* urlString = [[request URL] absoluteString];

    NSArray *UrlParts = [urlString componentsSeparatedByString:[NSString stringWithFormat:@"%@/", kREDIRECTURI]];
    if ([UrlParts count] > 1) {
        // do any of the following here
        urlString = [UrlParts objectAtIndex:1];
        NSRange accessToken = [urlString rangeOfString: @"code="];
        if (accessToken.location != NSNotFound) {
            NSString* strAccessToken = [urlString substringFromIndex: NSMaxRange(accessToken)];
            [self getAccessTokenWithCode:strAccessToken];
        }else{
            [self.delegate loginDidFailedWithError:nil];
        }
        [(BaseViewController*)self.delegate dismissControllerModal];
        return NO;
    }
    return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView{
    [nextViewController showLoadingIndicator:NO];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    NSLog(@"%@",error.description);
    //[(BaseViewController*)self.delegate dismissControllerModal];
}

- (void)getAccessTokenWithCode:(NSString*)code{
    NSString *fullURL = [NSString stringWithFormat:@"https://api.pinterest.com/v1/oauth/token?grant_type=authorization_code&client_id=%@&client_secret=%@&code=%@",kPinterestAPPId,kPinterestAPPSecret,code];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:fullURL]];
    request.HTTPMethod = @"POST";
    
    NSURLConnectionCompletionHandler handler = ^(NSURLResponse *response, NSData *data, NSError *error) {
        if (error) {
            [self.delegate loginDidFailedWithError:error];
            return;
        }
        
        int statusCode = ((NSHTTPURLResponse *)response).statusCode;
        
        if (statusCode == 200) {
            NSDictionary* responseParameters = [NSJSONSerialization JSONObjectWithData:data
                                                                               options:0
                                                                                 error:&error];
            if(!error){
            NSString* userOAuthTokenSecret = responseParameters[@"access_token"];
            [self.delegate loginSuccessfulWithData:@{kSNLoginToken:userOAuthTokenSecret,kSNLoginId:userOAuthTokenSecret}];
            }
        } else {
            [self.delegate loginDidFailedWithError:error];
        }
    };
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:handler];
}
@end
