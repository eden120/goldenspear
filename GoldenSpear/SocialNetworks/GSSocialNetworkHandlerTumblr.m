//
//  GSSocialNetworkHandlerTumblr.m
//  GoldenSpear
//
//  Created by Adria Vernetta Rubio on 1/6/16.
//  Copyright © 2016 GoldenSpear. All rights reserved.
//

#import "GSSocialNetworkHandlerTumblr.h"
#import "TMTumblrAuthenticator.h"
#import "TMSDKFunctions.h"
#import "TMOAuth.h"
#import "BaseViewController+StoryboardManagement.h"
#import "GSSocialNetworkWebViewViewController.h"
#import "BaseViewController+ActivityFeedbackManagement.h"
#import "TMAPIClient.h"

#define kCallBackURL @"www.goldenspear.com"

typedef void (^NSURLConnectionCompletionHandler)(NSURLResponse *, NSData *, NSError *);

@implementation GSSocialNetworkHandlerTumblr{
    NSString* userOAuthToken;
    NSString* userOAuthTokenSecret;
    
    GSSocialNetworkWebViewViewController *nextViewController;
}

NSDictionary *formEncodedDataToDictionaryLocal(NSData *data) {
    NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSDictionary *dictionary = TMQueryStringToDictionary(string);
    
    return dictionary;
}

NSMutableURLRequest *mutableRequestWithURLStringLocal(NSString *URLString) {
    return [NSMutableURLRequest requestWithURL:[NSURL URLWithString:URLString]];
}

NSError *errorWithStatusCodeLocal(NSInteger statusCode) {
    return [NSError errorWithDomain:@"Authentication request failed" code:statusCode userInfo:nil];
}

- (void)loginUserToSocialNetwork{
    TMTumblrAuthenticator* instance = [TMTumblrAuthenticator sharedInstance];
    instance.OAuthConsumerKey = @"uvltXK5tVaxDVcrn7iD5zTZ8LQh507Bobae22TukBCfUGqNa07";
    instance.OAuthConsumerSecret = @"geg0BUG859DNjDhpJyujMhwkIOVv5v5dLHPWANfTCW6LfmJxbV";
    userOAuthToken = @"";
    userOAuthTokenSecret = @"";
    
    UIStoryboard *nextStoryboard = [UIStoryboard storyboardWithName:@"UserAccount" bundle:nil];
    nextViewController = [nextStoryboard instantiateViewControllerWithIdentifier:[@(SOCIALNETWORKWEBVIEW_VC) stringValue]];
    
    [nextViewController prepareViewController:nextViewController withParameters:nil];
    
    [(BaseViewController*)self.delegate showViewControllerModal:nextViewController withTopBar:YES];
    [nextViewController setTitleForModal:@"LINK ACCOUNT"];
    nextViewController.webView.delegate = self;
    [(BaseViewController*)self.delegate stopActivityFeedback];
    
    [self authenticateWithWebView:nextViewController.webView];
}

- (void)authenticateWithWebView:(UIWebView *)webView{
    NSHTTPCookie *cookie;
    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (cookie in [storage cookies])
    {
        NSString* domainName = [cookie domain];
        NSRange domainRange = [domainName rangeOfString:@"tumblr.com"];
        if(domainRange.length > 0)
        {
            [storage deleteCookie:cookie];
        }
    }

    [[NSUserDefaults standardUserDefaults] synchronize];
    NSString *fullURL = @"https://www.tumblr.com/oauth/request_token";
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:fullURL]];
    [self signRequest:request withParameters:nil];

    NSURLConnectionCompletionHandler handler = ^(NSURLResponse *response, NSData *data, NSError *error) {
        if (error) {
            [self.delegate loginDidFailedWithError:error];
            return;
        }
        
        int statusCode = ((NSHTTPURLResponse *)response).statusCode;
        
        if (statusCode == 200) {
            
            NSDictionary *responseParameters = formEncodedDataToDictionaryLocal(data);
            userOAuthTokenSecret = responseParameters[@"oauth_token_secret"];
            userOAuthToken = responseParameters[@"oauth_token"];
            NSURL *authURL = [NSURL URLWithString:
                              [NSString stringWithFormat:@"https://www.tumblr.com/oauth/authorize?oauth_token=%@",
                               responseParameters[@"oauth_token"]]];
            
            [webView loadRequest:[NSURLRequest requestWithURL:authURL]];
            
        } else {
            [self.delegate loginDidFailedWithError:error];
        }
    };
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:handler];
}

- (void)signRequest:(NSMutableURLRequest *)request withParameters:(NSDictionary *)parameters {
    [request setValue:@"TMTumblrSDK" forHTTPHeaderField:@"User-Agent"];
    
    [request setValue:[TMOAuth headerForURL:request.URL
                                     method:request.HTTPMethod
                             postParameters:parameters
                                      nonce:[[NSProcessInfo processInfo] globallyUniqueString]
                                consumerKey:[TMTumblrAuthenticator sharedInstance].OAuthConsumerKey
                             consumerSecret:[TMTumblrAuthenticator sharedInstance].OAuthConsumerSecret
                                      token:userOAuthToken
                                tokenSecret:userOAuthTokenSecret] forHTTPHeaderField:@"Authorization"];
}

-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    [nextViewController showLoadingIndicator:YES];
    NSURL* url = request.URL;
    if ([[url absoluteString] rangeOfString:[NSString stringWithFormat:@"oauth/%@",kCallBackURL]].location==NSNotFound)
        return YES;
    
    void(^clearState)() = ^ {
        userOAuthToken = nil;
        userOAuthTokenSecret = nil;
    };
    
    NSDictionary *URLParameters = TMQueryStringToDictionary(url.query);
    
    if ([[URLParameters allKeys] count] == 0) {
        [self.delegate loginDidFailedWithError:[NSError errorWithDomain:@"Permission denied by user" code:0 userInfo:nil]];
        clearState();
        return NO;
    }
    
    userOAuthToken = URLParameters[@"oauth_token"];
    
    NSDictionary *requestParameters = @{ @"oauth_verifier" : URLParameters[@"oauth_verifier"] };
    
    NSMutableURLRequest *nextRequest = mutableRequestWithURLStringLocal(@"https://www.tumblr.com/oauth/access_token");
    nextRequest.HTTPMethod = @"POST";
    nextRequest.HTTPBody = [TMDictionaryToQueryString(requestParameters) dataUsingEncoding:NSUTF8StringEncoding];
    [self signRequest:nextRequest withParameters:requestParameters];
    
    NSURLConnectionCompletionHandler handler = ^(NSURLResponse *response, NSData *data, NSError *error) {
        if (error) {
            [self.delegate loginDidFailedWithError:error];
        } else {
            int statusCode = ((NSHTTPURLResponse *)response).statusCode;
            if (statusCode == 200) {
                NSDictionary *responseParameters = formEncodedDataToDictionaryLocal(data);
                TMAPIClient* instance = [TMAPIClient sharedInstance];
                instance.OAuthToken = responseParameters[@"oauth_token"];
                instance.OAuthTokenSecret = responseParameters[@"oauth_token_secret"];
                instance.OAuthConsumerKey = @"uvltXK5tVaxDVcrn7iD5zTZ8LQh507Bobae22TukBCfUGqNa07";
                instance.OAuthConsumerSecret = @"geg0BUG859DNjDhpJyujMhwkIOVv5v5dLHPWANfTCW6LfmJxbV";
                [instance userInfo:^(id info, NSError *error) {
                    if (error) {
                        [self.delegate loginDidFailedWithError:error];
                    }else{
                        NSDictionary* user = [info objectForKey:@"user"];
                        [self.delegate loginSuccessfulWithData:@{kSNLoginToken:[NSString stringWithFormat:@"%@_--_%@",[TMAPIClient sharedInstance].OAuthToken,[TMAPIClient sharedInstance].OAuthTokenSecret],kSNLoginId:[user objectForKey:@"name"]}];
                    }
                }];
                
            } else {
                [self.delegate loginDidFailedWithError:errorWithStatusCodeLocal(statusCode)];
            }
        }
        
        clearState();
    };
    
    [NSURLConnection sendAsynchronousRequest:nextRequest queue:[NSOperationQueue mainQueue] completionHandler:handler];
    
    return NO;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView{
    [nextViewController showLoadingIndicator:NO];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    NSLog(@"%@",error.description);
    [nextViewController showLoadingIndicator:NO];
    //[(BaseViewController*)self.delegate dismissControllerModal];
}

@end
