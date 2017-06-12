//
//  GSSocialNetworkHandlerFlicker.m
//  GoldenSpear
//
//  Created by Adria Vernetta Rubio on 2/6/16.
//  Copyright © 2016 GoldenSpear. All rights reserved.
//

#import "GSSocialNetworkHandlerFlicker.h"
#import "FlickrKit.h"
#import "BaseViewController+StoryboardManagement.h"
#import "GSSocialNetworkWebViewViewController.h"
#import "BaseViewController+ActivityFeedbackManagement.h"

#define kFlickerAPIKey @"ab8d759490a865db9f8f00819c43e641"
#define kFlickerAPISecret @"68ff83a6a3de9fed"
#define kFKStoredTokenKey @"kFKStoredTokenKey"
#define kFKStoredTokenSecret @"kFKStoredTokenSecret"

@implementation GSSocialNetworkHandlerFlicker{
    FKDUNetworkOperation *authOp;
    GSSocialNetworkWebViewViewController *nextViewController;
}

- (void)loginUserToSocialNetwork{
    NSHTTPCookie *cookie;
    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (cookie in [storage cookies])
    {
        NSString* domainName = [cookie domain];
        NSRange domainRange = [domainName rangeOfString:@"flickr.com"];
        if(domainRange.length > 0)
        {
            [storage deleteCookie:cookie];
        }
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userAuthenticateCallback:) name:@"UserAuthCallbackNotification" object:nil];
    
    [[FlickrKit sharedFlickrKit] initializeWithAPIKey:kFlickerAPIKey sharedSecret:kFlickerAPISecret];
    NSString *callbackURLString = @"flickrkitdemo://auth";
    
    UIStoryboard *nextStoryboard = [UIStoryboard storyboardWithName:@"UserAccount" bundle:nil];
    nextViewController = [nextStoryboard instantiateViewControllerWithIdentifier:[@(SOCIALNETWORKWEBVIEW_VC) stringValue]];
    
    [nextViewController prepareViewController:nextViewController withParameters:nil];
    
    [(BaseViewController*)self.delegate showViewControllerModal:nextViewController withTopBar:YES];
    [nextViewController setTitleForModal:@"LINK ACCOUNT"];
    nextViewController.webView.delegate = self;
    [(BaseViewController*)self.delegate stopActivityFeedback];
    
    // Begin the authentication process
    authOp = [[FlickrKit sharedFlickrKit] beginAuthWithCallbackURL:[NSURL URLWithString:callbackURLString]
                                                        permission:FKPermissionDelete
                                                        completion:^(NSURL *flickrLoginPageURL, NSError *error) {
                                                            dispatch_async(dispatch_get_main_queue(), ^{
                                                                if (!error) {
                                                                    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:flickrLoginPageURL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30];
                                                                    [nextViewController.webView loadRequest:urlRequest];
                                                                } else {
                                                                    [self.delegate loginDidFailedWithError:error];
                                                                }
                                                            });
                                                        }];
}

- (void) userAuthenticateCallback:(NSURL *)callbackURL {
    [[FlickrKit sharedFlickrKit] completeAuthWithURL:callbackURL
                                          completion:^(NSString *userName, NSString *userId, NSString *fullName, NSError *error) {
                                              dispatch_async(dispatch_get_main_queue(), ^{
                                                  if (!error) {
                                                      NSString* authToken = [[NSUserDefaults standardUserDefaults] valueForKey:kFKStoredTokenKey];
                                                      NSString* authSecret = [[NSUserDefaults standardUserDefaults] valueForKey:kFKStoredTokenSecret];
                                                      [self.delegate loginSuccessfulWithData:@{kSNLoginToken:[NSString stringWithFormat:@"%@_--_%@",authToken,authSecret],kSNLoginId:userId}];
                                                  } else {
                                                      [self.delegate loginDidFailedWithError:error];
                                                  }
                                              });
                                          }];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    //If they click NO DONT AUTHORIZE, this is where it takes you by default... maybe take them to my own web site, or show something else
    
    NSURL *url = [request URL];
    
    // If it's the callback url, then lets trigger that
    if (![url.scheme isEqual:@"http"] && ![url.scheme isEqual:@"https"]) {
        [self userAuthenticateCallback:url];
        return NO;
    }
    
    return YES;
    
}

- (void)webViewDidFinishLoad:(UIWebView *)webView{
    [nextViewController showLoadingIndicator:NO];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    NSLog(@"%@",error.description);
    [(BaseViewController*)self.delegate dismissControllerModal];
}

@end
