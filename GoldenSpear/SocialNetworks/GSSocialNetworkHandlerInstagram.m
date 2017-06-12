//
//  GSSocialNetworkHandlerInstagram.m
//  GoldenSpear
//
//  Created by Adria Vernetta Rubio on 27/5/16.
//  Copyright © 2016 GoldenSpear. All rights reserved.
//

#import "GSSocialNetworkHandlerInstagram.h"
#import "AppDelegate.h"
#import "BaseViewController+StoryboardManagement.h"
#import "GSSocialNetworkWebViewViewController.h"
#import "BaseViewController+ActivityFeedbackManagement.h"

#define KAUTHURL @"https://api.instagram.com/oauth/authorize/"
#define kAPIURl @"https://api.instagram.com/v1/users/"
#define KCLIENTID @"2eb51e81ebfd42e58f1e38b0cf49433c"
#define KCLIENTSERCRET @"c9773872b1ec4a8499f953c4cc6be4ae"
#define kREDIRECTURI @"https://app.goldenspear.com"

@implementation GSSocialNetworkHandlerInstagram{
    GSSocialNetworkWebViewViewController *nextViewController;
}

- (void)loginUserToSocialNetwork{
    NSHTTPCookie *cookie;
    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (cookie in [storage cookies])
    {
        NSString* domainName = [cookie domain];
        NSRange domainRange = [domainName rangeOfString:@"instagram.com"];
        if(domainRange.length > 0)
        {
            [storage deleteCookie:cookie];
        }
    }
    
    NSString *fullURL = [NSString stringWithFormat:@"%@?sig=%@&client_id=%@&redirect_uri=%@&response_type=code&scope=follower_list",KAUTHURL,KCLIENTSERCRET,KCLIENTID,kREDIRECTURI];
    
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
            [self makePostRequest:strAccessToken];
        }else{
            [self.delegate loginDidFailedWithError:nil];
        }
        [(BaseViewController*)self.delegate dismissControllerModal];
        return NO;
    }
    return YES;
}

-(void)makePostRequest:(NSString *)code
{
    
    NSString *post = [NSString stringWithFormat:@"client_id=%@&client_secret=%@&grant_type=authorization_code&redirect_uri=%@&code=%@",KCLIENTID,KCLIENTSERCRET,kREDIRECTURI,code];
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[postData length]];
    
    NSMutableURLRequest *requestData = [NSMutableURLRequest requestWithURL:
                                        [NSURL URLWithString:@"https://api.instagram.com/oauth/access_token"]];
    [requestData setHTTPMethod:@"POST"];
    [requestData setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [requestData setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [requestData setHTTPBody:postData];
    
    NSURLResponse *response = NULL;
    NSError *requestError = NULL;
    NSData *responseData = [NSURLConnection sendSynchronousRequest:requestData returningResponse:&response error:&requestError];
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments error:nil];
    [self handleAuth:dict];
    
}

- (void) handleAuth: (NSDictionary*) dict
{
    NSString* authToken = [dict valueForKey:@"access_token"];
    NSDictionary* user = [dict valueForKey:@"user"];
    NSString* userId = [user objectForKey:@"id"];
    [self.delegate loginSuccessfulWithData:@{kSNLoginToken:authToken,kSNLoginId:userId}];
}

- (void)searchUserFriendsInNetwork:(NSString *)query{
    if([query isEqualToString:@""]){
        if([self.searchResults count]>0){
            [self.delegate searchSucceedWithStatus:GSSocialNetworkSearchStatusSuccess andResults:self.searchResults];
        }else{
            self.searchResults = [NSMutableArray new];
            [self downloadFriendsFromCursor:-1];
        }
    }else{
        [self searchBetweenResultsWithName:[query lowercaseString]];
    }
}

- (void)downloadFriendsFromCursor:(NSInteger)cursor{
    User* theUser = ((AppDelegate*)[UIApplication sharedApplication].delegate).currentUser;
    NSString *userID = theUser.instagram_id;
    NSString *friendsURL = [NSString stringWithFormat:@"https://api.instagram.com/v1/users/self/follows?access_token=%@",userID];
    
    NSMutableURLRequest *requestData = [NSMutableURLRequest requestWithURL:
                                        [NSURL URLWithString:friendsURL]];
    [requestData setHTTPMethod:@"GET"];
    
    NSURLResponse *response = NULL;
    NSError *requestError = NULL;
    NSData *responseData = [NSURLConnection sendSynchronousRequest:requestData returningResponse:&response error:&requestError];
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments error:nil];

    if (dict) {
        NSArray* friends = [dict objectForKey:@"data"];
        NSMutableArray* friendsArray = [NSMutableArray new];
        for (NSDictionary* user in friends) {
            GSSocialNetworkFriend* friend = [self getSocialNetworkFriendWithEntry:user];
            [friendsArray addObject:friend];
        }
        [self.searchResults addObjectsFromArray:friendsArray];
        [self.delegate searchSucceedWithStatus:GSSocialNetworkSearchStatusSuccess andResults:friendsArray];
    }
    else {
        [self.delegate searchFailedWithStatus:GSSocialNetworkSearchStatusNotConnected];
    }
}

- (void)searchBetweenResultsWithName:(NSString*)query{
    NSMutableArray* queryResults = [NSMutableArray new];
    for(GSSocialNetworkFriend* f in self.searchResults){
        if([f.title rangeOfString:query].location!=NSNotFound ||
           [f.subtitle rangeOfString:query].location!=NSNotFound){
            [queryResults addObject:f];
        }
    }
    [self.delegate searchSucceedWithStatus:GSSocialNetworkSearchStatusSuccess andResults:queryResults];
}

- (GSSocialNetworkFriend*)getSocialNetworkFriendWithEntry:(NSDictionary*)result{
    GSSocialNetworkFriend* aFriend = [GSSocialNetworkFriend new];
    aFriend.socialNetwork = GSSocialNetworkOriginInstagram;
    aFriend.title = [result objectForKey:@"full_name"];
    aFriend.subtitle = [NSString stringWithFormat:@"@%@",[result objectForKey:@"username"]];
    aFriend.imgUrl = [result objectForKey:@"profile_picture"];
    aFriend.userId =[result objectForKey:@"id"];
    return aFriend;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView{
    [nextViewController showLoadingIndicator:NO];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    NSLog(@"%@",error.description);
    [(BaseViewController*)self.delegate dismissControllerModal];
}

@end
