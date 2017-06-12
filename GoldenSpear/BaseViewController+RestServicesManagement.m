	//
//  BaseViewController+RestServicesManagement.m
//  GoldenSpear
//
//  Created by Jose Antonio Sanchez Martinez on 13/04/15.
//  Copyright (c) 2015 GoldenSpear. All rights reserved.
//

#import "BaseViewController.h"
#import "BaseViewController+RestServicesManagement.h"
#import "BaseViewController+ActivityFeedbackManagement.h"
#import "BaseViewController+StoryboardManagement.h"
#import "BaseViewController+MainMenuManagement.h"
#import "BaseViewController+BottomControlsManagement.h"
#import "SearchBaseViewController.h"
#import "VisualSearchViewController.h"
#import "FashionistaPostViewController.h"
#import "FashionistaProfileViewController.h"
#import "UILabel+CustomCreation.h"
#import "Keyword+CoreDataProperties.h"
#import <objc/runtime.h>
#import "Ad.h"


static char SEARCH_RESULTS_KEY;

@implementation BaseViewController (RestServicesManagement)

//Getter and setter for searchResults
- (NSMutableArray *)searchResults
{
    return objc_getAssociatedObject(self, &SEARCH_RESULTS_KEY);
}

- (void)setSearchResults:(NSMutableArray *)searchResults
{
    objc_setAssociatedObject(self, &SEARCH_RESULTS_KEY, searchResults, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


NSMutableArray * _productContents;
NSMutableArray * _postContents;
NSMutableArray * _keywordsPostContent;
NSMutableArray * _wardrobeContents;
NSMutableArray * _productFeatures;
NSMutableArray * _productCategories;
NSMutableArray * _subProductCategories;
NSMutableArray * _featureGroupFeatures;
NSMutableArray * _productGroupFeaturesGroup;

NSMutableArray * _productAvailabilities;

// new approach
NSMutableArray * _allProductCategory;
NSMutableArray * _allFeatures;
NSMutableArray * _priorityBrands;
NSMutableArray * _allBrands;

int numRetries = 0;
#define MAX_RETRIES 60
#define SLEEPTIME 1



#pragma mark - Rest services management

// Given an array of terms, compose the string to be used in a request
- (NSString *)composeStringhWithTermsOfArray:(NSArray *)termsArray encoding:(BOOL)bEncoding
{
    //Setup string
    
    NSString *resultString = @"";
    
    if (!((termsArray == nil) || ([termsArray count] < 1)))
    {
        for (NSString *term in termsArray)
        {
            resultString = [resultString stringByAppendingString:[[NSString stringWithFormat:@"%@ ", term] lowercaseString]];
        }
    }
    
    // Check that the string is valid
    if (!((resultString == nil) || ([resultString isEqualToString:@""])))
    {
        // 'Clean' the string
        
        resultString = [resultString stringByReplacingOccurrencesOfString:@"\\s+"
                                                               withString:@" "
                                                                  options:NSRegularExpressionSearch
                                                                    range:NSMakeRange(0, resultString.length)];
        
        resultString = [resultString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        if(bEncoding)
        {
            // Encode the string
            resultString = [resultString urlEncodeUsingNSUTF8StringEncoding];
        }
    }
    
    return resultString;
}

// Given an array of terms, compose the string to be used in a request, comma separated
- (NSString *)composeCommaSeparatedStringWithTermsOfArray:(NSArray *)termsArray encoding:(BOOL)bEncoding
{
    //Setup string
    
    NSString *resultString = @"";
    
    if (!((termsArray == nil) || ([termsArray count] < 1)))
    {
        
        for (NSString *term in termsArray)
        {
            if([resultString isEqualToString:@""])
                resultString = [resultString stringByAppendingString:[[NSString stringWithFormat:@"'%@'", term] lowercaseString]];
            else
                resultString = [resultString stringByAppendingString:[[NSString stringWithFormat:@", '%@'", term] lowercaseString]];
        }
    }
    
    // Check that the string is valid
    if (!((resultString == nil) || ([resultString isEqualToString:@""])))
    {
        // 'Clean' the string
        
        resultString = [resultString stringByReplacingOccurrencesOfString:@"\\s+"
                                                               withString:@" "
                                                                  options:NSRegularExpressionSearch
                                                                    range:NSMakeRange(0, resultString.length)];
        
        resultString = [resultString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        if(bEncoding)
        {
            // Encode the string
            resultString = [resultString urlEncodeUsingNSUTF8StringEncoding];
        }
    }
    
    return resultString;
}

// Perform Rest Request
- (void) performRestGet:(connectionType)connection withParamaters:(NSArray *)parameters
{
    NSString * requestString;
    NSArray * dataClasses;
    NSArray *failedAnswerErrorMessage;
    
    switch (connection)
    {
        case VERIFY_FOLLOWER:
        {
            if(!(parameters == nil))
            {
                if ([parameters count] == 2)
                {
                    // 0 = Follower Id; 1 = setFollow object
                    // String to perform the post
                    
                    requestString = [NSString stringWithFormat:@"/user/%@/verifyFollower/%@", (NSString*)[parameters objectAtIndex:0],(NSString*)[parameters objectAtIndex:1]];
                    
                    dataClasses = [NSArray arrayWithObjects:[Follow class], nil];
                    
                    //Message to show if not succeed
                    failedAnswerErrorMessage = [NSArray arrayWithObjects:NSLocalizedString(@"_ERROR_", nil), NSLocalizedString(@"_NO_FOLLOW_ERROR_MSG_", nil), NSLocalizedString(@"_OK_", nil), nil];
                }
                else
                {
                    NSLog(@"XXXX Incorrect number of parameters to perform request! XXXX");
                    
                    [self processRestConnection: connection WithErrorMessage:nil forOperation:nil];
                    
                    return;
                }
            }
            break;
        }
        case GET_USER_DISCOVER:
        {
            if(!(parameters == nil))
            {
                if ([parameters count] == 4)
                {
                    self.searchResults = nil;
                    
                    NSMutableString* reqString = [NSMutableString stringWithFormat:@"/discover?user=%@",(NSString*)([parameters objectAtIndex:0])];
                    //Section String
                    NSString* aString = [parameters objectAtIndex:1];
                    if(![aString isEqualToString:@""]){
                        [reqString appendFormat:@"&postCategory=%@",aString];
                    }
                    //Sort string
                    aString = [parameters objectAtIndex:2];
                    if(![aString isEqualToString:@""]){
                        [reqString appendFormat:@"&sort=%@",aString];
                    }
                    //Search string
                    aString = [parameters objectAtIndex:3];
                    if(![aString isEqualToString:@""]){
                        [reqString appendFormat:@"&stringToSearch=%@",aString];
                    }
                    // String to perform the request
                    requestString = [NSString stringWithString:reqString];
                    
                    //Data classes to look for
                    dataClasses = [NSArray arrayWithObjects:[SearchQuery class], nil];
                    
                    //Message to show if no results were provided
                    failedAnswerErrorMessage = [NSArray arrayWithObjects:NSLocalizedString(@"_ERROR_", nil), NSLocalizedString(@"_NO_RESULTS_ERROR_MSG_", nil), NSLocalizedString(@"_OK_", nil), nil];
                }
                else
                {
                    NSLog(@"XXXX Incorrect number of parameters to perform request! XXXX");
                    
                    [self processRestConnection: connection WithErrorMessage:nil forOperation:nil];
                    
                    return;
                }
            }
            break;
        }
        case GET_CITIESOFSTATE:
        {
            if(!(parameters == nil))
            {
                if ([parameters count] == 5)
                {
                    int sSkip = [(NSNumber*)([parameters objectAtIndex:2]) intValue];
                    int sLimit = [(NSNumber*)([parameters objectAtIndex:3]) intValue];
                    
                    // 0 = Search string
                    //NSString * searchString = [self composeStringhWithTermsOfArray:[NSArray arrayWithObject:(NSString*)([parameters objectAtIndex:0])] encoding:YES];
                    
                    // String to perform the request
                    requestString = [NSString stringWithFormat:@"/city?where={\"country\":\"%@\",\"stateregiontop\":\"%@\",\"name\":{\"startsWith\":\"%@\"}}&skip=%d&limit=%d&sort=name&populate=stateregion",(NSString*)([parameters objectAtIndex:0]), (NSString*)([parameters objectAtIndex:1]), (NSString*)([parameters objectAtIndex:4]), sSkip, sLimit ];
                    requestString = [requestString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                    
                    
                    //Data classes to look for
                    dataClasses = [NSArray arrayWithObjects:[City class], nil];
                    
                    //Message to show if no results were provided
                    failedAnswerErrorMessage = [NSArray arrayWithObjects:NSLocalizedString(@"_ERROR_", nil), NSLocalizedString(@"_NO_RESULTS_ERROR_MSG_", nil), NSLocalizedString(@"_OK_", nil), nil];
                }
                else if ([parameters count] == 4)
                {
                    int sSkip = [(NSNumber*)([parameters objectAtIndex:1]) intValue];
                    int sLimit = [(NSNumber*)([parameters objectAtIndex:2]) intValue];
                    
                    // String to perform the request
                    requestString = [NSString stringWithFormat:@"/city?where={\"country\":\"%@\",\"name\":{\"startsWith\":\"%@\"}}&skip=%d&limit=%d&sort=name&populate=stateregion",(NSString*)([parameters objectAtIndex:0]), (NSString*)([parameters objectAtIndex:3]), sSkip, sLimit];
                    requestString = [requestString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                    
                    //Data classes to look for
                    dataClasses = [NSArray arrayWithObjects:[City class], nil];
                    
                    //Message to show if no results were provided
                    failedAnswerErrorMessage = [NSArray arrayWithObjects:NSLocalizedString(@"_ERROR_", nil), NSLocalizedString(@"_NO_RESULTS_ERROR_MSG_", nil), NSLocalizedString(@"_OK_", nil), nil];
                }
                else
                {
                    NSLog(@"XXXX Incorrect number of parameters to perform request! XXXX");
                    
                    [self processRestConnection: connection WithErrorMessage:nil forOperation:nil];
                    
                    return;
                }
            }
            break;
        }
        case GET_STATESOFCOUNTRY:
        {
            if(!(parameters == nil))
            {
                if ([parameters count] == 1)
                {
                    
                    // 0 = Search string
                    //NSString * searchString = [self composeStringhWithTermsOfArray:[NSArray arrayWithObject:(NSString*)([parameters objectAtIndex:0])] encoding:YES];
                    
                    // String to perform the request
                    requestString = [NSString stringWithFormat:@"/stateregion?country=%@&parentstateregion=null&limit=-1",(NSString*)([parameters objectAtIndex:0])];
                    
                    //Data classes to look for
                    dataClasses = [NSArray arrayWithObjects:[StateRegion class], nil];
                    
                    //Message to show if no results were provided
                    failedAnswerErrorMessage = [NSArray arrayWithObjects:NSLocalizedString(@"_ERROR_", nil), NSLocalizedString(@"_NO_RESULTS_ERROR_MSG_", nil), NSLocalizedString(@"_OK_", nil), nil];
                }
                else
                {
                    NSLog(@"XXXX Incorrect number of parameters to perform request! XXXX");
                    
                    [self processRestConnection: connection WithErrorMessage:nil forOperation:nil];
                    
                    return;
                }
            }
            break;
        }
        case GET_ALLCOUNTRIES:
        {
            
            // String to perform the request
            requestString = @"/country?limit=-1";
            
            //Data classes to look for
            dataClasses = [NSArray arrayWithObjects:[Country class], nil];
            
            //Message to show if no results were provided
            failedAnswerErrorMessage = [NSArray arrayWithObjects:NSLocalizedString(@"_ERROR_", nil), NSLocalizedString(@"_NO_RESULTS_ERROR_MSG_", nil), NSLocalizedString(@"_OK_", nil), nil];
            break;
        }
        case CHECK_SEARCH_STRING:
        case CHECK_SEARCH_STRING_AFTER_SEARCH:
        {
            if(!(parameters == nil))
            {
                if ([parameters count] == 1)
                {
                    
                    // 0 = Search string
                    //NSString * searchString = [self composeStringhWithTermsOfArray:[NSArray arrayWithObject:(NSString*)([parameters objectAtIndex:0])] encoding:YES];
                    
                    // String to perform the request
                    requestString = [NSString stringWithFormat:@"/checksearch/%@",(NSString*)([parameters objectAtIndex:0])];
                    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                    if ([appDelegate isConfigSearchCpp])
                    {
                        requestString = [NSString stringWithFormat:@"/checksearchcpp/%@",(NSString*)([parameters objectAtIndex:0])];
                    }
                    
                    //Data classes to look for
                    dataClasses = [NSArray arrayWithObjects:[CheckSearch class], nil];
                    
                    //Message to show if no results were provided
                    failedAnswerErrorMessage = [NSArray arrayWithObjects:NSLocalizedString(@"_ERROR_", nil), NSLocalizedString(@"_NO_RESULTS_ERROR_MSG_", nil), NSLocalizedString(@"_OK_", nil), nil];
                }
                else
                {
                    NSLog(@"XXXX Incorrect number of parameters to perform request! XXXX");
                    
                    [self processRestConnection: connection WithErrorMessage:nil forOperation:nil];
                    
                    return;
                }
            }
            break;
        }
        case CHECK_SEARCH_STRING_SUGGESTIONS:
        case CHECK_SEARCH_STRING_SUGGESTIONS_AFTER_SEARCH:
        {
            if(!(parameters == nil))
            {
                if ([parameters count] == 1)
                {
                    
                    // 0 = Search string
                    //NSString * searchString = [self composeStringhWithTermsOfArray:[NSArray arrayWithObject:(NSString*)([parameters objectAtIndex:0])] encoding:YES];
                    
                    // String to perform the request
                    requestString = [NSString stringWithFormat:@"/checksuggestionsextended/%@",(NSString*)([parameters objectAtIndex:0])];
                    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                    if ([appDelegate isConfigSearchCpp])
                    {
                        requestString = [NSString stringWithFormat:@"/checksuggestionsextendedcpp/%@",(NSString*)([parameters objectAtIndex:0])];
                    }
                    
                    //Data classes to look for
                    dataClasses = [NSArray arrayWithObjects:[CheckSearch class], nil];
                    
                    //Message to show if no results were provided
                    failedAnswerErrorMessage = [NSArray arrayWithObjects:NSLocalizedString(@"_ERROR_", nil), NSLocalizedString(@"_NO_RESULTS_ERROR_MSG_", nil), NSLocalizedString(@"_OK_", nil), nil];
                }
                else
                {
                    NSLog(@"XXXX Incorrect number of parameters to perform request! XXXX");
                    
                    [self processRestConnection: connection WithErrorMessage:nil forOperation:nil];
                    
                    return;
                }
            }
            break;
        }
        case PERFORM_SEARCH_WITHIN_PRODUCTS:
        case PERFORM_SEARCH_WITHIN_PRODUCTS_NUMS:
        case GET_BRAND_PRODUCTS:
        {
            if(!(parameters == nil))
            {
                if ([parameters count] == 1)
                {
                    self.searchResults = nil;
                    
                    // 0 = Search string
                    //NSString * searchString = [self composeStringhWithTermsOfArray:[NSArray arrayWithObject:(NSString*)([parameters objectAtIndex:0])] encoding:YES];
                    
                    // String to perform the request
                    requestString = [NSString stringWithFormat:@"/search/%@",(NSString*)([parameters objectAtIndex:0])];
                    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                    if ([appDelegate isConfigSearchCpp])
                    {
                        requestString = [NSString stringWithFormat:@"/searchcpp/%@",(NSString*)([parameters objectAtIndex:0])];
                    }
                    
                    //Data classes to look for
                    dataClasses = [NSArray arrayWithObjects:[SearchQuery class], nil];
                    
                    //Message to show if no results were provided
                    failedAnswerErrorMessage = [NSArray arrayWithObjects:NSLocalizedString(@"_ERROR_", nil), NSLocalizedString(@"_NO_RESULTS_ERROR_MSG_", nil), NSLocalizedString(@"_OK_", nil), nil];
                }
                else
                {
                    NSLog(@"XXXX Incorrect number of parameters to perform request! XXXX");
                    
                    [self processRestConnection: connection WithErrorMessage:nil forOperation:nil];
                    
                    return;
                }
            }
            
            break;
        }
        case PERFORM_SEARCH_WITHIN_TRENDING:
        {
            if(!(parameters == nil))
            {
                if ([parameters count] == 1)
                {
                    self.searchResults = nil;
                    
                    // 0 = Search string
                    //NSString * searchString = [self composeStringhWithTermsOfArray:[NSArray arrayWithObject:(NSString*)([parameters objectAtIndex:0])] encoding:YES];
                    
                    // String to perform the request
                    requestString = [NSString stringWithFormat:@"/newgettrending/%@",(NSString*)([parameters objectAtIndex:0])];
                    
                    //Data classes to look for
                    dataClasses = [NSArray arrayWithObjects:[SearchQuery class], nil];
                    
                    //Message to show if no results were provided
                    failedAnswerErrorMessage = [NSArray arrayWithObjects:NSLocalizedString(@"_ERROR_", nil), NSLocalizedString(@"_NO_RESULTS_ERROR_MSG_", nil), NSLocalizedString(@"_OK_", nil), nil];
                }
                else
                {
                    NSLog(@"XXXX Incorrect number of parameters to perform request! XXXX");
                    
                    [self processRestConnection: connection WithErrorMessage:nil forOperation:nil];
                    
                    return;
                }
            }
            
            break;
        }
        case PERFORM_SEARCH_WITHIN_HISTORY:
        {
            if(!(parameters == nil))
            {
                if ([parameters count] == 3)
                {
                    self.searchResults = nil;
                    
                    // 0 = User ID 1 = History period 2 = Search string
                    //NSString * searchString = [self composeStringhWithTermsOfArray:[NSArray arrayWithObject:(NSString*)([parameters objectAtIndex:0])] encoding:YES];
                    
                    // String to perform the request
                    requestString = [NSString stringWithFormat:@"/user/%@/newhistory/%@/%@",(NSString*)([parameters objectAtIndex:0]), (NSString*)([parameters objectAtIndex:1]), (NSString*)([parameters objectAtIndex:2])];
                    
                    //Data classes to look for
                    dataClasses = [NSArray arrayWithObjects:[SearchQuery class], nil];
                    
                    //Message to show if no results were provided
                    failedAnswerErrorMessage = [NSArray arrayWithObjects:NSLocalizedString(@"_ERROR_", nil), NSLocalizedString(@"_NO_RESULTS_ERROR_MSG_", nil), NSLocalizedString(@"_OK_", nil), nil];
                }
                else
                {
                    NSLog(@"XXXX Incorrect number of parameters to perform request! XXXX");
                    
                    [self processRestConnection: connection WithErrorMessage:nil forOperation:nil];
                    
                    return;
                }
            }
            
            break;
        }
        case PERFORM_SEARCH_WITHIN_FASHIONISTAPOSTS:
        {
            if(!(parameters == nil))
            {
                if ([parameters count] == 3)
                {
                    self.searchResults = nil;
                    
                    // 0 = Search string
                    //NSString * searchString = [self composeStringhWithTermsOfArray:[NSArray arrayWithObject:(NSString*)([parameters objectAtIndex:0])] encoding:YES];
                    
                    // String to perform the request
                    requestString = [NSString stringWithFormat:@"/searchfashionistapost/%@/%@/%@",(NSString*)([parameters objectAtIndex:0]),(NSString*)([parameters objectAtIndex:1]),(NSString*)([parameters objectAtIndex:2])];
                    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                    if ([appDelegate isConfigSearchCpp])
                    {
                        requestString = [NSString stringWithFormat:@"/searchfashionistapostcpp/%@/%@/%@",(NSString*)([parameters objectAtIndex:0]),(NSString*)([parameters objectAtIndex:1]),(NSString*)([parameters objectAtIndex:2])];
                    }
                    
                    //Data classes to look for
                    dataClasses = [NSArray arrayWithObjects:[SearchQuery class], nil];
                    
                    //Message to show if no results were provided
                    failedAnswerErrorMessage = [NSArray arrayWithObjects:NSLocalizedString(@"_ERROR_", nil), NSLocalizedString(@"_NO_RESULTS_ERROR_MSG_", nil), NSLocalizedString(@"_OK_", nil), nil];
                }
                else
                {
                    NSLog(@"XXXX Incorrect number of parameters to perform request! XXXX");
                    
                    [self processRestConnection: connection WithErrorMessage:nil forOperation:nil];
                    
                    return;
                }
            }
            
            break;
        }
        case PERFORM_SEARCH_WITHIN_FASHIONISTAS:
        {
            if(!(parameters == nil))
            {
                if ([parameters count] == 3)
                {
                    self.searchResults = nil;
                    
                    // 0 = Search string
                    //NSString * searchString = [self composeStringhWithTermsOfArray:[NSArray arrayWithObject:(NSString*)([parameters objectAtIndex:0])] encoding:YES];
                    
                    // String to perform the request
                    requestString = [NSString stringWithFormat:@"/searchfashionista/%@/%@?userid=%@",(NSString*)([parameters objectAtIndex:0]),(NSString*)([parameters objectAtIndex:1]), (NSString*)([parameters objectAtIndex:2])];
                    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                    if ([appDelegate isConfigSearchCpp])
                    {
                        requestString = [NSString stringWithFormat:@"/searchfashionistacpp/%@/%@?userid=%@",(NSString*)([parameters objectAtIndex:0]),(NSString*)([parameters objectAtIndex:1]), (NSString*)([parameters objectAtIndex:2])];
                    }
                    
                    //Data classes to look for
                    dataClasses = [NSArray arrayWithObjects:[SearchQuery class], nil];
                    NSLog(@"reuest param %@", requestString);
                    //Message to show if no results were provided
                    failedAnswerErrorMessage = [NSArray arrayWithObjects:NSLocalizedString(@"_ERROR_", nil), NSLocalizedString(@"_NO_RESULTS_ERROR_MSG_", nil), NSLocalizedString(@"_OK_", nil), nil];
                }
                else if([parameters count] == 4) {
                    self.searchResults = nil;
                    
                    if ([(NSString*)([parameters objectAtIndex:3]) isEqualToString:@"sort=tagged"]){
                        // 0 = Search string
                        //NSString * searchString = [self composeStringhWithTermsOfArray:[NSArray arrayWithObject:(NSString*)([parameters objectAtIndex:0])] encoding:YES];
                        
                        // String to perform the request
                        requestString = [NSString stringWithFormat:@"/searchfashionista/%@/%@?userid=%@&%@",(NSString*)([parameters objectAtIndex:0]),(NSString*)([parameters objectAtIndex:1]), (NSString*)([parameters objectAtIndex:2]), (NSString*)([parameters objectAtIndex:3])];
                        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                        if ([appDelegate isConfigSearchCpp])
                        {
                            requestString = [NSString stringWithFormat:@"/searchfashionistacpp/%@/%@?userid=%@&%@",(NSString*)([parameters objectAtIndex:0]),(NSString*)([parameters objectAtIndex:1]), (NSString*)([parameters objectAtIndex:2]), (NSString*)([parameters objectAtIndex:3])];
                        }
                        
                        //Data classes to look for
                        dataClasses = [NSArray arrayWithObjects:[SearchQuery class], nil];
                        
                        //Message to show if no results were provided
                        failedAnswerErrorMessage = [NSArray arrayWithObjects:NSLocalizedString(@"_ERROR_", nil), NSLocalizedString(@"_NO_RESULTS_ERROR_MSG_", nil), NSLocalizedString(@"_OK_", nil), nil];
                    }
                }
                
                else if([parameters count] == 5){
                    //Social Network Search
                    NSString* query = (NSString*)([parameters objectAtIndex:0]);
                    
                    requestString = [NSString stringWithFormat:@"/getfriendsfromsocialnetwork?idUser=%@&socialNetwork=%@&token=%@&stringToSearch=%@",(NSString*)([parameters objectAtIndex:2]),(NSString*)([parameters objectAtIndex:4]),(NSString*)([parameters objectAtIndex:3]),query];
                    
                    //Data classes to look for
                    dataClasses = [NSArray arrayWithObjects:[SearchQuery class], nil];
                    
                    //Message to show if no results were provided
                    failedAnswerErrorMessage = [NSArray arrayWithObjects:NSLocalizedString(@"_ERROR_", nil), NSLocalizedString(@"_NO_RESULTS_ERROR_MSG_", nil), NSLocalizedString(@"_OK_", nil), nil];
                }
                else
                {
                    NSLog(@"XXXX Incorrect number of parameters to perform request! XXXX");
                    
                    [self processRestConnection: connection WithErrorMessage:nil forOperation:nil];
                    
                    return;
                }
            }
            
            break;
        }
        case PERFORM_SEARCH_WITHIN_FASHIONISTAS_LIKE_POST:
        {
            if(!(parameters == nil))
            {
                if ([parameters count] == 1)
                {
                    self.searchResults = nil;
                    
                    // 0 = Search string
                    //NSString * searchString = [self composeStringhWithTermsOfArray:[NSArray arrayWithObject:(NSString*)([parameters objectAtIndex:0])] encoding:YES];
                    
                    // String to perform the request
                    requestString = [NSString stringWithFormat:@"/searchfashionistalikepostcpp/%@/",(NSString*)([parameters objectAtIndex:0])];
                    
                    //Data classes to look for
                    dataClasses = [NSArray arrayWithObjects:[SearchQuery class], nil];
                    
                    //Message to show if no results were provided
                    failedAnswerErrorMessage = [NSArray arrayWithObjects:NSLocalizedString(@"_ERROR_", nil), NSLocalizedString(@"_NO_RESULTS_ERROR_MSG_", nil), NSLocalizedString(@"_OK_", nil), nil];
                }
                else if ([parameters count] == 2)
                {
                    self.searchResults = nil;
                    
                    // 0 = Search string
                    //NSString * searchString = [self composeStringhWithTermsOfArray:[NSArray arrayWithObject:(NSString*)([parameters objectAtIndex:0])] encoding:YES];
                    
                    // String to perform the request
                    requestString = [NSString stringWithFormat:@"/searchfashionistalikepostcpp/%@/%@",(NSString*)([parameters objectAtIndex:0]),(NSString*)([parameters objectAtIndex:1])];
                    
                    //Data classes to look for
                    dataClasses = [NSArray arrayWithObjects:[SearchQuery class], nil];
                    
                    //Message to show if no results were provided
                    failedAnswerErrorMessage = [NSArray arrayWithObjects:NSLocalizedString(@"_ERROR_", nil), NSLocalizedString(@"_NO_RESULTS_ERROR_MSG_", nil), NSLocalizedString(@"_OK_", nil), nil];
                }
                else
                {
                    NSLog(@"XXXX Incorrect number of parameters to perform request! XXXX");
                    
                    [self processRestConnection: connection WithErrorMessage:nil forOperation:nil];
                    
                    return;
                }
            }
            
            break;
        }
        case PERFORM_SEARCH_USER_LIKE_POST:
        {
            if(!(parameters == nil))
            {
                if ([parameters count] == 1)
                {
                    self.searchResults = nil;
                    
                    // 0 = Search string
                    //NSString * searchString = [self composeStringhWithTermsOfArray:[NSArray arrayWithObject:(NSString*)([parameters objectAtIndex:0])] encoding:YES];
                    
                    // String to perform the request
                    requestString = [NSString stringWithFormat:@"/fashionistapost/%@/likesuser",(NSString*)([parameters objectAtIndex:0])];
                    
                    //Data classes to look for
                    dataClasses = [NSArray arrayWithObjects:[SearchQuery class], nil];
                    
                    //Message to show if no results were provided
                    failedAnswerErrorMessage = [NSArray arrayWithObjects:NSLocalizedString(@"_ERROR_", nil), NSLocalizedString(@"_NO_RESULTS_ERROR_MSG_", nil), NSLocalizedString(@"_OK_", nil), nil];
                }
                else
                {
                    NSLog(@"XXXX Incorrect number of parameters to perform request! XXXX");
                    
                    [self processRestConnection: connection WithErrorMessage:nil forOperation:nil];
                    
                    return;
                }
            }
            break;
        }
        case PERFORM_SEARCH_WITHIN_STYLES:
        case GET_THE_LOOK:
        {
            if(!(parameters == nil))
            {
                if ([parameters count] == 2)
                {
                    self.searchResults = nil;
                    
                    // 0 = GSBaseElement taken as the reference for the look 1 = Search string
                    //NSString * searchString = [self composeStringhWithTermsOfArray:[NSArray arrayWithObject:(NSString*)([parameters objectAtIndex:0])] encoding:YES];
                    
                    // String to perform the request
                    NSString * sParameter = (NSString*)([parameters objectAtIndex:1]);
                    if (sParameter.length == 0)
                    {
                        // String to perform the request
                        requestString = [NSString stringWithFormat:@"/getthelooks/%@",(NSString *)[((GSBaseElement *)([parameters objectAtIndex:0])) productId]];
                        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                        if ([appDelegate isConfigSearchCpp])
                        {
                            requestString = [NSString stringWithFormat:@"/getthelookscpp/%@",(NSString *)[((GSBaseElement *)([parameters objectAtIndex:0])) productId]];
                        }
                    }
                    else
                    {
                        // String to perform the request
                        requestString = [NSString stringWithFormat:@"/getthelooks/%@/%@",(NSString *)[((GSBaseElement *)([parameters objectAtIndex:0])) productId], (NSString*)([parameters objectAtIndex:1])];
                        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                        if ([appDelegate isConfigSearchCpp])
                        {
                            requestString = [NSString stringWithFormat:@"/getthelookscpp/%@/%@",(NSString *)[((GSBaseElement *)([parameters objectAtIndex:0])) productId], (NSString*)([parameters objectAtIndex:1])];
                        }
                    }
                    
                    //Data classes to look for
                    dataClasses = [NSArray arrayWithObjects:[SearchQuery class], nil];
                    
                    //Message to show if no results were provided
                    failedAnswerErrorMessage = [NSArray arrayWithObjects:NSLocalizedString(@"_ERROR_", nil), NSLocalizedString(@"_NO_RESULTS_ERROR_MSG_", nil), NSLocalizedString(@"_OK_", nil), nil];
                }
                else
                {
                    NSLog(@"XXXX Incorrect number of parameters to perform request! XXXX");
                    
                    [self processRestConnection: connection WithErrorMessage:nil forOperation:nil];
                    
                    return;
                }
            }
            
            break;
        }
        case PERFORM_SEARCH_WITHIN_BRANDS:
        {
            if(!(parameters == nil))
            {
                if ([parameters count] == 1)
                {
                    self.searchResults = nil;
                    
                    // 0 = Search string
                    //NSString * searchString = [self composeStringhWithTermsOfArray:[NSArray arrayWithObject:(NSString*)([parameters objectAtIndex:0])] encoding:YES];
                    
                    // String to perform the request
                    NSString * sParameter = (NSString*)([parameters objectAtIndex:0]);
                    if (sParameter.length == 1)
                    {
                        requestString = [NSString stringWithFormat:@"/searchbrand//%@",(NSString*)([parameters objectAtIndex:0])];
                    }
                    else
                    {
                        requestString = [NSString stringWithFormat:@"/searchbrand/%@",(NSString*)([parameters objectAtIndex:0])];
                    }
                    
                    
                    //Data classes to look for
                    dataClasses = [NSArray arrayWithObjects:[SearchQuery class], nil];
                    
                    //Message to show if no results were provided
                    failedAnswerErrorMessage = [NSArray arrayWithObjects:NSLocalizedString(@"_ERROR_", nil), NSLocalizedString(@"_NO_RESULTS_ERROR_MSG_", nil), NSLocalizedString(@"_OK_", nil), nil];
                }
                else
                {
                    NSLog(@"XXXX Incorrect number of parameters to perform request! XXXX");
                    
                    [self processRestConnection: connection WithErrorMessage:nil forOperation:nil];
                    
                    return;
                }
            }
            
            break;
        }
        case PERFORM_SEARCHINITIAL_WITHIN_BRANDS:
        {
            if(!(parameters == nil))
            {
                if ([parameters count] == 1)
                {
                    self.searchResults = nil;
                    
                    // 0 = Search string
                    //NSString * searchString = [self composeStringhWithTermsOfArray:[NSArray arrayWithObject:(NSString*)([parameters objectAtIndex:0])] encoding:YES];
                    
                    // String to perform the request
                    requestString = [NSString stringWithFormat:@"/searchbrandinitial/%@",(NSString*)([parameters objectAtIndex:0])];
                    
                    //Data classes to look for
                    dataClasses = [NSArray arrayWithObjects:[SearchQuery class], nil];
                    
                    //Message to show if no results were provided
                    failedAnswerErrorMessage = [NSArray arrayWithObjects:NSLocalizedString(@"_ERROR_", nil), NSLocalizedString(@"_NO_RESULTS_ERROR_MSG_", nil), NSLocalizedString(@"_OK_", nil), nil];
                }
                else
                {
                    NSLog(@"XXXX Incorrect number of parameters to perform request! XXXX");
                    
                    [self processRestConnection: connection WithErrorMessage:nil forOperation:nil];
                    
                    return;
                }
            }
            
            break;
        }
        case PERFORM_VISUAL_SEARCH:
        {
            if(!(parameters == nil))
            {
                if ([parameters count] == 1)
                {
                    self.searchResults = nil;
                    numRetries = 0;
                    
                    // 0 = Captured image
                    // String to perform the request
                    requestString = [NSString stringWithFormat:@"/detect"];
                    
                    //Data classes to look for
                    dataClasses = [NSArray arrayWithObjects:[SearchQuery class], nil];
                    
                    //Message to show if no results were provided
                    failedAnswerErrorMessage = [NSArray arrayWithObjects:NSLocalizedString(@"_ERROR_", nil), NSLocalizedString(@"_NO_RESULTS_ERROR_MSG_", nil), NSLocalizedString(@"_OK_", nil), nil];
                    
                    // Serialize the Article attributes then attach a file
                    NSMutableURLRequest *request = [[RKObjectManager sharedManager] multipartFormRequestWithObject:nil
                                                                                                            method:RKRequestMethodPOST
                                                                                                              path:[NSString stringWithFormat:@"/detect"]
                                                                                                        parameters:nil
                                                                                         constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
                                                                                             [formData appendPartWithFileData:UIImageJPEGRepresentation((UIImage*)[parameters objectAtIndex:0], 0.5)
                                                                                                                         name:@"picture"
                                                                                                                     fileName:@"image_to_detect.jpg"
                                                                                                                     mimeType:@"image/jpg"];
                                                                                         }];
                    
                    RKObjectRequestOperation *operation = [[RKObjectManager sharedManager] objectRequestOperationWithRequest:request
                                                                                                                     success:^(RKObjectRequestOperation * operation, RKMappingResult * mappingResult)
                                                           {
                                                               // If the GS server provided an answer, check wheter that answer could be mapped into our data classes
                                                               
                                                               [self processAnswerToRestConnection:connection WithResult:[mappingResult array] lookingForClasses:dataClasses andIfErrorMessage:failedAnswerErrorMessage];
                                                           }
                                                                                                                     failure:^(RKObjectRequestOperation * operation, NSError *error)
                                                           {
                                                               //Message to show if no results were provided
                                                               NSArray *errorMessage = [NSArray arrayWithObjects:NSLocalizedString(@"_ERROR_", nil), NSLocalizedString(@"_CONNECTION_ERROR_MSG_", nil), NSLocalizedString(@"_OK_", nil), nil];
                                                               
                                                               // If 'failedAnswerErrorMessage' is nil, it means that we don't want to provide messages to the user
                                                               if(failedAnswerErrorMessage == nil)
                                                               {
                                                                   errorMessage = nil;
                                                               }
                                                               
                                                               [self processRestConnection: connection WithErrorMessage:errorMessage forOperation:operation];
                                                           }];
                    
                    [[RKObjectManager sharedManager] enqueueObjectRequestOperation:operation]; // NOTE: Must be enqueued rather than started
                }
                else
                {
                    NSLog(@"XXXX Incorrect number of parameters to perform request! XXXX");
                    
                    [self processRestConnection: connection WithErrorMessage:nil forOperation:nil];
                    
                    return;
                }
                
                return;
            }
            
            break;
        }
        case GET_DETECTION_STATUS:
        {
            if(!(parameters == nil))
            {
                if ([parameters count] == 1)
                {
                    numRetries ++;
                    
                    // 0 = Detection Id
                    // String to perform the request
                    requestString = [NSString stringWithFormat:@"/detection/%@",(NSString*)[parameters objectAtIndex:0]];
                    
                    //Data classes to look for
                    dataClasses =  [NSArray arrayWithObjects:[SearchQuery class], nil];
                    
                    //Message to show if no results were provided
                    failedAnswerErrorMessage = [NSArray arrayWithObjects:NSLocalizedString(@"_ERROR_", nil), NSLocalizedString(@"_NO_RESULTS_ERROR_MSG_", nil), NSLocalizedString(@"_OK_", nil), nil];
                }
                else
                {
                    NSLog(@"XXXX Incorrect number of parameters to perform request! XXXX");
                    
                    [self processRestConnection: connection WithErrorMessage:nil forOperation:nil];
                    
                    return;
                }
            }
            
            break;
        }
        case GET_SEARCH_QUERY:
        {
            if(!(parameters == nil))
            {
                if ([parameters count] == 1)
                {
                    // 0 = SearchQuery Id
                    // String to perform the request
                    requestString = [NSString stringWithFormat:@"/statproductsquery/%@",(NSString*)[parameters objectAtIndex:0]];
                    
                    //Data classes to look for
                    dataClasses = [NSArray arrayWithObjects:[SearchQuery class], nil];
                    
                    //Message to show if no results were provided
                    failedAnswerErrorMessage = [NSArray arrayWithObjects:NSLocalizedString(@"_ERROR_", nil), NSLocalizedString(@"_NO_RESULTS_ERROR_MSG_", nil), NSLocalizedString(@"_OK_", nil), nil];
                }
                else
                {
                    NSLog(@"XXXX Incorrect number of parameters to perform request! XXXX");
                    
                    [self processRestConnection: connection WithErrorMessage:nil forOperation:nil];
                    
                    return;
                }
            }
            
            break;
        }
        case GET_SEARCH_RESULTS_WITHIN_DISCOVER:
        {
            if(!(parameters == nil))
            {
                if ([parameters count] == 2)
                {
                    if (self.searchResults == nil)
                    {
                        self.searchResults = [[NSMutableArray alloc] init];
                        [self.searchResults addObject:[parameters objectAtIndex:0]];
                    }
                    
                    // 0 = Search Id
                    // String to perform the request
                    requestString = [NSString stringWithFormat:@"/statproductsquery/%@/resultQueries?skip=%d&sort=order%%20asc",(NSString*)([((SearchQuery*)([parameters objectAtIndex:0])) idSearchQuery]),(int)([(NSNumber *)([parameters objectAtIndex:1]) intValue])];
                    
                    //Data classes to look for
                    dataClasses = [NSArray arrayWithObjects:[ResultsGroup class], nil];
                    
                    //Message to show if no results were provided
                    failedAnswerErrorMessage = [NSArray arrayWithObjects:NSLocalizedString(@"_ERROR_", nil), NSLocalizedString(@"_NO_RESULTS_ERROR_MSG_", nil), NSLocalizedString(@"_OK_", nil), nil];
                }
                else
                {
                    NSLog(@"XXXX Incorrect number of parameters to perform request! XXXX");
                    
                    [self processRestConnection: connection WithErrorMessage:nil forOperation:nil];
                    
                    return;
                }
            }
            
            break;
        }
        case GET_SEARCH_RESULTS_WITHIN_LIKES:
        {
            if(!(parameters == nil))
            {
                if ([parameters count] == 2)
                {
                    if (self.searchResults == nil)
                    {
                        self.searchResults = [[NSMutableArray alloc] init];
                        [self.searchResults addObject:[parameters objectAtIndex:0]];
                    }
                    
                    // 0 = Search Id
                    // String to perform the request
                    requestString = [NSString stringWithFormat:@"/resultQuery?statProductQuery=%@&populate=fashionistapost&skip=%d&sort=order%%20asc",(NSString*)([((SearchQuery*)([parameters objectAtIndex:0])) idSearchQuery]),(int)([(NSNumber *)([parameters objectAtIndex:1]) intValue])];
                    
                    //Data classes to look for
                    dataClasses = [NSArray arrayWithObjects:[ResultsGroup class], nil];
                    
                    //Message to show if no results were provided
                    failedAnswerErrorMessage = [NSArray arrayWithObjects:NSLocalizedString(@"_ERROR_", nil), NSLocalizedString(@"_NO_RESULTS_ERROR_MSG_", nil), NSLocalizedString(@"_OK_", nil), nil];
                }
                else
                {
                    NSLog(@"XXXX Incorrect number of parameters to perform request! XXXX");
                    
                    [self processRestConnection: connection WithErrorMessage:nil forOperation:nil];
                    
                    return;
                }
            }
            
            break;
            
        }
        case GET_SEARCH_GROUPS_WITHIN_PRODUCTS:
        case GET_SEARCH_GROUPS_WITHIN_TRENDING:
        case GET_SEARCH_GROUPS_WITHIN_HISTORY:
        case GET_SEARCH_GROUPS_WITHIN_FASHIONISTAPOSTS:
        case GET_SEARCH_GROUPS_WITHIN_FASHIONISTAS:
        case GET_SEARCH_GROUPS_WITHIN_STYLES:
        case GET_SEARCH_GROUPS_WITHIN_BRANDS:
        case GET_SEARCH_GROUPS_WITHIN_BRAND_PRODUCTS:
        case GET_SEARCH_GROUPS_WITHIN_NEWSFEED:
        case GET_SEARCH_GROUPS_WITHIN_DISCOVER:
        {
            if(!(parameters == nil))
            {
                if ([parameters count] == 1)
                {
                    if (self.searchResults == nil)
                    {
                        self.searchResults = [[NSMutableArray alloc] init];
                        [self.searchResults addObject:[parameters objectAtIndex:0]];
                    }
                    
                    // 0 = Search Id
                    // String to perform the request
                    requestString = [NSString stringWithFormat:@"/resultgroup?statProductQuery=%@&populate=keywords&limit=-1",(NSString*)([((SearchQuery*)([parameters objectAtIndex:0])) idSearchQuery])];
                    
                    //Data classes to look for
                    dataClasses = [NSArray arrayWithObjects:[ResultsGroup class], nil];
                    
                    //Message to show if no results were provided
                    failedAnswerErrorMessage = [NSArray arrayWithObjects:NSLocalizedString(@"_ERROR_", nil), NSLocalizedString(@"_NO_RESULTS_ERROR_MSG_", nil), NSLocalizedString(@"_OK_", nil), nil];
                }
                else
                {
                    NSLog(@"XXXX Incorrect number of parameters to perform request! XXXX");
                    
                    [self processRestConnection: connection WithErrorMessage:nil forOperation:nil];
                    
                    return;
                }
            }
            
            break;
        }
            //        case GET_SEARCH_GROUP_KEYWORDS:
            //        {
            //            if(!(parameters == nil))
            //            {
            //                if ([parameters count] == 1)
            //                {
            //                    // 0 = Search Group Id
            //                    // String to perform the request
            //                    requestString = [NSString stringWithFormat:@"/resultgroup/%@/keywords",(NSString*)[parameters objectAtIndex:0]];
            //
            //                    //Data classes to look for
            //                    dataClasses = [NSArray arrayWithObjects:[Keyword class], nil];
            //
            //                    //Message to show if no results were provided
            //                    failedAnswerErrorMessage = [NSArray arrayWithObjects:NSLocalizedString(@"_ERROR_", nil), NSLocalizedString(@"_NO_RESULTS_ERROR_MSG_", nil), NSLocalizedString(@"_OK_", nil), nil];
            //                }
            //                else
            //                {
            //            NSLog(@"XXXX Incorrect number of parameters to perform request! XXXX");
            //
            //            [self processRestConnection: connection WithErrorMessage:nil forOperation:nil];
            //
            //            return;
            //                }
            //            }
            //
            //            break;
            //        }
        case GET_SEARCH_RESULTS_WITHIN_PRODUCTS:
        {
            if(!(parameters == nil))
            {
                if ([parameters count] == 2)
                {
                    if (self.searchResults == nil)
                    {
                        self.searchResults = [[NSMutableArray alloc] init];
                        [self.searchResults addObject:[parameters objectAtIndex:0]];
                    }
                    
                    // 0 = Search Id; 1 = Skip
                    // String to perform the request
                    requestString = [NSString stringWithFormat:@"/statproductsquery/%@/resultQueries?skip=%d&sort=order%%20asc",(NSString*)([((SearchQuery*)([parameters objectAtIndex:0])) idSearchQuery]),(int)([(NSNumber *)([parameters objectAtIndex:1]) intValue])];
                    
                    //Data classes to look for
                    dataClasses = [NSArray arrayWithObjects:[GSBaseElement class], nil];
                    
                    //Message to show if no results were provided
                    failedAnswerErrorMessage = [NSArray arrayWithObjects:NSLocalizedString(@"_ERROR_", nil), NSLocalizedString(@"_NO_RESULTS_ERROR_MSG_", nil), NSLocalizedString(@"_OK_", nil), nil];
                }
                else
                {
                    NSLog(@"XXXX Incorrect number of parameters to perform request! XXXX");
                    
                    [self processRestConnection: connection WithErrorMessage:nil forOperation:nil];
                    
                    return;
                }
            }
            
            break;
        }
        case GET_SEARCH_RESULTS_WITHIN_BRAND_PRODUCTS:
        {
            if(!(parameters == nil))
            {
                if ([parameters count] == 2)
                {
                    if (self.searchResults == nil)
                    {
                        self.searchResults = [[NSMutableArray alloc] init];
                        [self.searchResults addObject:[parameters objectAtIndex:0]];
                    }
                    
                    // 0 = Search Id; 1 = Skip
                    // String to perform the request
                    requestString = [NSString stringWithFormat:@"/statproductsquery/%@/resultQueries?skip=%d&sort=order%%20asc",(NSString*)([((SearchQuery*)([parameters objectAtIndex:0])) idSearchQuery]),(int)([(NSNumber *)([parameters objectAtIndex:1]) intValue])];
                    
                    //Data classes to look for
                    dataClasses = [NSArray arrayWithObjects:[GSBaseElement class], nil];
                    
                    //Message to show if no results were provided
                    failedAnswerErrorMessage = [NSArray arrayWithObjects:NSLocalizedString(@"_ERROR_", nil), NSLocalizedString(@"_NO_RESULTS_ERROR_MSG_", nil), NSLocalizedString(@"_OK_", nil), nil];
                }
                else
                {
                    NSLog(@"XXXX Incorrect number of parameters to perform request! XXXX");
                    
                    [self processRestConnection: connection WithErrorMessage:nil forOperation:nil];
                    
                    return;
                }
            }
            
            break;
        }
        case GET_SEARCH_RESULTS_WITHIN_TRENDING:
        {
            if(!(parameters == nil))
            {
                if ([parameters count] == 2)
                {
                    if (self.searchResults == nil)
                    {
                        self.searchResults = [[NSMutableArray alloc] init];
                        [self.searchResults addObject:[parameters objectAtIndex:0]];
                    }
                    
                    // 0 = Search Id; 1 = Skip
                    // String to perform the request
                    requestString = [NSString stringWithFormat:@"/statproductsquery/%@/resultQueries?skip=%d&sort=stat_viewnumber%%20asc",(NSString*)([((SearchQuery*)([parameters objectAtIndex:0])) idSearchQuery]),(int)([(NSNumber *)([parameters objectAtIndex:1]) intValue])];
                    
                    //Data classes to look for
                    dataClasses = [NSArray arrayWithObjects:[GSBaseElement class], nil];
                    
                    //Message to show if no results were provided
                    failedAnswerErrorMessage = [NSArray arrayWithObjects:NSLocalizedString(@"_ERROR_", nil), NSLocalizedString(@"_NO_RESULTS_ERROR_MSG_", nil), NSLocalizedString(@"_OK_", nil), nil];
                }
                else
                {
                    NSLog(@"XXXX Incorrect number of parameters to perform request! XXXX");
                    
                    [self processRestConnection: connection WithErrorMessage:nil forOperation:nil];
                    
                    return;
                }
            }
            
            break;
        }
        case GET_SEARCH_RESULTS_WITHIN_NEWSFEED:
        {
            if(!(parameters == nil))
            {
                if ([parameters count] == 2)
                {
                    if (self.searchResults == nil)
                    {
                        self.searchResults = [[NSMutableArray alloc] init];
                        [self.searchResults addObject:[parameters objectAtIndex:0]];
                    }
                    
                    // 0 = Search Id; 1 = Skip
                    // String to perform the request
                    requestString = [NSString stringWithFormat:@"/statproductsquery/%@/resultQueries?skip=%d&sort=order%%20desc",(NSString*)([((SearchQuery*)([parameters objectAtIndex:0])) idSearchQuery]),(int)([(NSNumber *)([parameters objectAtIndex:1]) intValue])];
                    
                    //Data classes to look for
                    dataClasses = [NSArray arrayWithObjects:[GSBaseElement class], nil];
                    
                    //Message to show if no results were provided
                    failedAnswerErrorMessage = [NSArray arrayWithObjects:NSLocalizedString(@"_ERROR_", nil), NSLocalizedString(@"_NO_RESULTS_ERROR_MSG_", nil), NSLocalizedString(@"_OK_", nil), nil];
                }
                else
                {
                    NSLog(@"XXXX Incorrect number of parameters to perform request! XXXX");
                    
                    [self processRestConnection: connection WithErrorMessage:nil forOperation:nil];
                    
                    return;
                }
            }
            break;
        }
        case GET_SEARCH_RESULTS_WITHIN_HISTORY:
        case GET_SEARCH_RESULTS_WITHIN_FASHIONISTAPOSTS:
        case GET_SEARCH_RESULTS_WITHIN_FASHIONISTAWARDROBES:
        case GET_SEARCH_RESULTS_WITHIN_FASHIONISTAS:
        case GET_SEARCH_RESULTS_WITHIN_STYLES:
        case GET_SEARCH_RESULTS_WITHIN_BRANDS:
        {
            if(!(parameters == nil))
            {
                if ([parameters count] == 2)
                {
                    if (self.searchResults == nil)
                    {
                        self.searchResults = [[NSMutableArray alloc] init];
                        [self.searchResults addObject:[parameters objectAtIndex:0]];
                    }
                    
                    // 0 = Search Id; 1 = Skip
                    // String to perform the request
                    requestString = [NSString stringWithFormat:@"/statproductsquery/%@/resultQueries?skip=%d&sort=order%%20asc",(NSString*)([((SearchQuery*)([parameters objectAtIndex:0])) idSearchQuery]),(int)([(NSNumber *)([parameters objectAtIndex:1]) intValue])];
                    
                    //Data classes to look for
                    dataClasses = [NSArray arrayWithObjects:[GSBaseElement class], nil];
                    
                    //Message to show if no results were provided
                    failedAnswerErrorMessage = [NSArray arrayWithObjects:NSLocalizedString(@"_ERROR_", nil), NSLocalizedString(@"_NO_RESULTS_ERROR_MSG_", nil), NSLocalizedString(@"_OK_", nil), nil];
                }
                else
                {
                    NSLog(@"XXXX Incorrect number of parameters to perform request! XXXX");
                    
                    [self processRestConnection: connection WithErrorMessage:nil forOperation:nil];
                    
                    return;
                }
            }
            
            break;
        }
        case GET_ALL_KEYWORDS:
        {
            // String to perform the request
            //requestString = [NSString stringWithFormat:@"/keyword?limit=-1"];
            requestString = [NSString stringWithFormat:@"/keyword?where={\"$or\":[{\"feature\":{\"$exists\":1}},{\"productcategory\":{\"$exists\":1}},{\"brand\":{\"$exists\":1}}]}&limit=-1"];
            requestString = [requestString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            
            //Data classes to look for
            dataClasses = [NSArray arrayWithObjects:[Keyword class], nil];
            
            //Message to show if no results were provided
            failedAnswerErrorMessage = nil;
            
            break;
        }
        case GET_SEARCH_KEYWORDS:
        case GET_STYLESSEARCH_KEYWORDS:
        case GET_BRANDPRODUCTSSEARCH_KEYWORDS:
        {
            if(!(parameters == nil))
            {
                if ([parameters count] == 1)
                {
                    // 0 = Search Id
                    // String to perform the request
                    requestString = [NSString stringWithFormat:@"/statproductsquery/%@/keywords?limit=-1",(NSString*)[parameters objectAtIndex:0]];
                    
                    //Data classes to look for
                    dataClasses = [NSArray arrayWithObjects:[Keyword class], nil];
                    
                    //Message to show if no results were provided
                    failedAnswerErrorMessage = nil;
                }
                else
                {
                    NSLog(@"XXXX Incorrect number of parameters to perform request! XXXX");
                    
                    [self processRestConnection: connection WithErrorMessage:nil forOperation:nil];
                    
                    return;
                }
            }
            
            break;
        }
        case GET_PRODUCT_BRAND:
        case GET_SEARCHPRODUCTS_BRAND:
        {
            if(!(parameters == nil))
            {
                if ([parameters count] == 1)
                {
                    _productFeatures = nil;
                    _productFeatures = [[NSMutableArray alloc] init];
                    [_productFeatures addObject:[parameters objectAtIndex:0]];
                    
                    // 0 = Product Id
                    // String to perform the request
                    requestString = [NSString stringWithFormat:@"/product/%@/brand",(NSString*)[parameters objectAtIndex:0]];
                    
                    //Data classes to look for
                    dataClasses = [NSArray arrayWithObjects:[Brand class], nil];
                    
                    //Message to show if no results were provided
                    failedAnswerErrorMessage = nil;
                }
                else
                {
                    NSLog(@"XXXX Incorrect number of parameters to perform request! XXXX");
                    
                    [self processRestConnection: connection WithErrorMessage:nil forOperation:nil];
                    
                    return;
                }
            }
            
            break;
        }
        case GET_SIMILARPRODUCTS_BRAND:
        {
            if(!(parameters == nil))
            {
                if ([parameters count] == 1)
                {
                    // 0 = Product Id
                    // String to perform the request
                    requestString = [NSString stringWithFormat:@"/product/%@/brand",(NSString*)[parameters objectAtIndex:0]];
                    
                    //Data classes to look for
                    dataClasses = [NSArray arrayWithObjects:[Brand class], nil];
                    
                    //Message to show if no results were provided
                    failedAnswerErrorMessage = [NSArray arrayWithObjects:NSLocalizedString(@"_ERROR_", nil), NSLocalizedString(@"_NO_GROUPFEATURES_ERROR_MSG_", nil), NSLocalizedString(@"_OK_", nil), nil];
                }
                else
                {
                    NSLog(@"XXXX Incorrect number of parameters to perform request! XXXX");
                    
                    [self processRestConnection: connection WithErrorMessage:nil forOperation:nil];
                    
                    return;
                }
            }
            
            break;
        }
        case GET_SEARCH_SUGGESTEDFILTERKEYWORDS:
        {
            if(!(parameters == nil))
            {
                if ([parameters count] == 1)
                {
                    // 0 = Search Id
                    // String to perform the request
                    requestString = [NSString stringWithFormat:@"/statproductsquery/%@/suggestedKeywords?limit=-1&sort=order",(NSString *)[parameters objectAtIndex:0]];
                    
                    //Data classes to look for
                    dataClasses = [NSArray arrayWithObjects:[SuggestedKeyword class], nil];
                    
                    //Message to show if no results were provided
                    failedAnswerErrorMessage = [NSArray arrayWithObjects:NSLocalizedString(@"_ERROR_", nil), NSLocalizedString(@"_NO_RESULTS_ERROR_MSG_", nil), NSLocalizedString(@"_OK_", nil), nil];
                    
                    break;
                }
                else
                {
                    NSLog(@"XXXX Incorrect number of parameters to perform request! XXXX");
                    
                    [self processRestConnection: connection WithErrorMessage:nil forOperation:nil];
                    
                    return;
                }
            }
            
            break;
        }
        case GET_PRODUCT:
        {
            if(!(parameters == nil))
            {
                if ([parameters count] == 1)
                {
                    _productContents = nil;
                    _productContents = [[NSMutableArray alloc] init];
                    
                    // 0 = ProductID
                    // String to perform the request
                    requestString = [NSString stringWithFormat:@"/product/%@?populate=variantGroup",(NSString *)([parameters objectAtIndex:0])];
                    
                    //Data classes to look for
                    dataClasses = [NSArray arrayWithObjects:[Product class], nil];
                    
                    //Message to show if no results were provided
                    failedAnswerErrorMessage = [NSArray arrayWithObjects:NSLocalizedString(@"_ERROR_", nil), NSLocalizedString(@"_NO_CONTENTS_ERROR_MSG_", nil), NSLocalizedString(@"_OK_", nil), nil];
                }
                else
                {
                    NSLog(@"XXXX Incorrect number of parameters to perform request! XXXX");
                    
                    [self processRestConnection: connection WithErrorMessage:nil forOperation:nil];
                    
                    return;
                }
            }
            
            break;
        }
        case GET_PRODUCT_CONTENT:
        {
            if(!(parameters == nil))
            {
                if ([parameters count] == 1)
                {
                    _productAvailabilities = nil;
                    _productAvailabilities = [[NSMutableArray alloc] init];

                    // 0 = Product
                    // String to perform the request
                    requestString = [NSString stringWithFormat:@"/product/%@/contents?limit=-1",(NSString *)([parameters objectAtIndex:0])];
                    
                    //Data classes to look for
                    dataClasses = [NSArray arrayWithObjects:[Content class], nil];
                    
                    //Message to show if no results were provided
                    failedAnswerErrorMessage = [NSArray arrayWithObjects:NSLocalizedString(@"_ERROR_", nil), NSLocalizedString(@"_NO_CONTENTS_ERROR_MSG_", nil), NSLocalizedString(@"_OK_", nil), nil];
                }
                else
                {
                    NSLog(@"XXXX Incorrect number of parameters to perform request! XXXX");
                    
                    [self processRestConnection: connection WithErrorMessage:nil forOperation:nil];
                    
                    return;
                }
            }
            
            break;
        }
        case GET_PRODUCT_AVAILABILITY:
        {
            if(!(parameters == nil))
            {
                if ([parameters count] == 6)
                {
                    // 0 = ProductID
                    // String to perform the request
                    requestString = [NSString stringWithFormat:@"/product/%@/availability?countrycode=%@&zipcode=%@&radius=%@&lng=%@&ltd=%@", (NSString *)[parameters objectAtIndex:0], (NSString *)[parameters objectAtIndex:1], (NSString *)[parameters objectAtIndex:2], (NSString *)[parameters objectAtIndex:3], (NSString *)[parameters objectAtIndex:4], (NSString *)[parameters objectAtIndex:5]];
                    
                    //Data classes to look for
                    dataClasses = [NSArray arrayWithObjects:[ProductAvailability class], nil];
                    
                    //Message to show if no results were provided
                    failedAnswerErrorMessage = [NSArray arrayWithObjects:NSLocalizedString(@"_ERROR_", nil), NSLocalizedString(@"_NO_CONTENTS_ERROR_MSG_", nil), NSLocalizedString(@"_OK_", nil), nil];
                }
                else
                {
                    NSLog(@"XXXX Incorrect number of parameters to perform request! XXXX");
                    
                    [self processRestConnection: connection WithErrorMessage:nil forOperation:nil];
                    
                    return;
                }
            }
            
            break;
        }
        case GET_NEAREST_POI:
        {
            if(!(parameters == nil))
            {
                if ([parameters count] >= 2)
                {
                    // 0 = ProductID
                    // String to perform the request
                    NSNumber * param1 =(NSNumber *)[parameters objectAtIndex:0];
                    NSNumber * param2 =(NSNumber *)[parameters objectAtIndex:1];
                    requestString = [NSString stringWithFormat:@"/getNearestPois/%f/%f", param1.floatValue, param2.floatValue];
                    
                    //Data classes to look for
                    dataClasses = [NSArray arrayWithObjects:[POI class], nil];
                    
                    //Message to show if no results were provided
                    failedAnswerErrorMessage = [NSArray arrayWithObjects:NSLocalizedString(@"_ERROR_", nil), NSLocalizedString(@"_NO_CONTENTS_ERROR_MSG_", nil), NSLocalizedString(@"_OK_", nil), nil];
                }
                else
                {
                    NSLog(@"XXXX Incorrect number of parameters to perform request! XXXX");
                    
                    [self processRestConnection: connection WithErrorMessage:nil forOperation:nil];
                    
                    return;
                }
            }
            break;
        }
        case GET_USER:
        {
            if(!(parameters == nil))
            {
                if ([parameters count] == 1)
                {
                    // 0 = User ID
                    // String to perform the request
                    requestString = [NSString stringWithFormat:@"/user/%@",(NSString *)[parameters objectAtIndex:0]];
                    
                    //Data classes to look for
                    dataClasses = [NSArray arrayWithObjects:[User class], nil];
                    
                    //Message to show if no results were provided
                    failedAnswerErrorMessage = [NSArray arrayWithObjects:NSLocalizedString(@"_ERROR_", nil), NSLocalizedString(@"_NO_CONTENTS_ERROR_MSG_", nil), NSLocalizedString(@"_OK_", nil), nil];
                }
                else
                {
                    NSLog(@"XXXX Incorrect number of parameters to perform request! XXXX");
                    
                    [self processRestConnection: connection WithErrorMessage:nil forOperation:nil];
                    
                    return;
                }
            }
            
            break;
        }
        case GET_USERS_FOR_AUTOFILL:
        {
            if(!(parameters == nil))
            {
                if ([parameters count] >= 1)
                {
                    // 0 = User ID
                    NSMutableString * reqString = [NSMutableString stringWithFormat:@"/getuserstoautofill/%@",(NSString *)[parameters objectAtIndex:0]];
                    if ([parameters count] >= 2)
                    {
                        NSString* aString = [parameters objectAtIndex:1];
                        if(![aString isEqualToString:@""]){
                            [reqString appendFormat:@"?stringToSearch=%@",aString];
                        }
                        if ([parameters count] >= 3)
                        {
                            NSString* aString = [parameters objectAtIndex:2];
                            if(![aString isEqualToString:@""]){
                                [reqString appendFormat:@"&skip=%@",aString];
                            }
                            
                            if ([parameters count] >= 4)
                            {
                                NSString* aString = [parameters objectAtIndex:3];
                                if(![aString isEqualToString:@""]){
                                    [reqString appendFormat:@"&limit=%@",aString];
                                }
                                
                            }
                        }
                        
                    }
                    // String to perform the request
                    requestString = [NSString stringWithString:reqString];
                    
                    //Data classes to look for
                    dataClasses = [NSArray arrayWithObjects:[User class], nil];
                    
                    //Message to show if no results were provided
                    failedAnswerErrorMessage = [NSArray arrayWithObjects:NSLocalizedString(@"_ERROR_", nil), NSLocalizedString(@"_NO_CONTENTS_ERROR_MSG_", nil), NSLocalizedString(@"_OK_", nil), nil];
                }
                else
                {
                    NSLog(@"XXXX Incorrect number of parameters to perform request! XXXX");
                    
                    [self processRestConnection: connection WithErrorMessage:nil forOperation:nil];
                    
                    return;
                }
            }
            break;
        }
        case GET_POST_AUTHOR:
        {
            if(!(parameters == nil))
            {
                if ([parameters count] == 1)
                {
                    // 0 = User ID
                    // String to perform the request
                    requestString = [NSString stringWithFormat:@"/user/%@",(NSString *)[parameters objectAtIndex:0]];
                    
                    //Data classes to look for
                    dataClasses = [NSArray arrayWithObjects:[User class], nil];
                    
                    //Message to show if no results were provided
                    failedAnswerErrorMessage = [NSArray arrayWithObjects:NSLocalizedString(@"_ERROR_", nil), NSLocalizedString(@"_NO_CONTENTS_ERROR_MSG_", nil), NSLocalizedString(@"_OK_", nil), nil];
                }
                else
                {
                    NSLog(@"XXXX Incorrect number of parameters to perform request! XXXX");
                    
                    [self processRestConnection: connection WithErrorMessage:nil forOperation:nil];
                    
                    return;
                }
            }
            
            break;
        }
        case GET_PRODUCT_REVIEWS:
        {
            if(!(parameters == nil))
            {
                if ([parameters count] == 1)
                {
                    // 0 = Product ID
                    // String to perform the request
                    requestString = [NSString stringWithFormat:@"/product/%@/reviews?limit=-1&sort=createdAt%%20DESC",(NSString *)[parameters objectAtIndex:0]];
                    
                    //Data classes to look for
                    dataClasses = [NSArray arrayWithObjects:[Review class], nil];
                    
                    //Message to show if no results were provided
                    failedAnswerErrorMessage = [NSArray arrayWithObjects:NSLocalizedString(@"_ERROR_", nil), NSLocalizedString(@"_NO_CONTENTS_ERROR_MSG_", nil), NSLocalizedString(@"_OK_", nil), nil];
                }
                else
                {
                    NSLog(@"XXXX Incorrect number of parameters to perform request! XXXX");
                    
                    [self processRestConnection: connection WithErrorMessage:nil forOperation:nil];
                    
                    return;
                }
            }
            
            break;
        }
        case GET_PRODUCT_FEATURES:
        {
            if(!(parameters == nil))
            {
                if ([parameters count] == 1)
                {
                    _productFeatures = nil;
                    _productFeatures = [[NSMutableArray alloc] init];
                    [_productFeatures addObject:[parameters objectAtIndex:0]];
                    
                    // 0 = Product
                    // String to perform the request
                    requestString = [NSString stringWithFormat:@"/product/%@/features?limit=-1",(NSString *)[((Product *)([parameters objectAtIndex:0])) idProduct]];
                    
                    //Data classes to look for
                    dataClasses = [NSArray arrayWithObjects:[Feature class], nil];
                    
                    //Message to show if no results were provided
                    failedAnswerErrorMessage = [NSArray arrayWithObjects:NSLocalizedString(@"_ERROR_", nil), NSLocalizedString(@"_NO_FEATURES_ERROR_MSG_", nil), NSLocalizedString(@"_OK_", nil), nil];
                }
                else
                {
                    NSLog(@"XXXX Incorrect number of parameters to perform request! XXXX");
                    
                    [self processRestConnection: connection WithErrorMessage:nil forOperation:nil];
                    
                    return;
                }
            }
            
            break;
        }
        case GET_SIMILAR_PRODUCTS:
        {
            if(!(parameters == nil))
            {
                if ([parameters count] == 1)
                {
                    self.searchResults = nil;
                    
                    // 0 = Search string
                    //NSString * searchString = [self composeStringhWithTermsOfArray:[NSArray arrayWithObject:(NSString*)([parameters objectAtIndex:0])] encoding:YES];
                    
                    // String to perform the request
                    requestString = [NSString stringWithFormat:@"/similar/%@",(NSString *)[((Product *)([parameters objectAtIndex:0])) idProduct]];
                    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                    if ([appDelegate isConfigSearchCpp])
                    {
                        requestString = [NSString stringWithFormat:@"/similarcpp/%@",(NSString *)[((Product *)([parameters objectAtIndex:0])) idProduct]];
                    }
                    
                    //Data classes to look for
                    dataClasses = [NSArray arrayWithObjects:[SearchQuery class], nil];
                    
                    //Message to show if no results were provided
                    failedAnswerErrorMessage = [NSArray arrayWithObjects:NSLocalizedString(@"_ERROR_", nil), NSLocalizedString(@"_NO_RESULTS_ERROR_MSG_", nil), NSLocalizedString(@"_OK_", nil), nil];
                }
                else
                {
                    NSLog(@"XXXX Incorrect number of parameters to perform request! XXXX");
                    
                    [self processRestConnection: connection WithErrorMessage:nil forOperation:nil];
                    
                    return;
                }
            }
            
            break;
        }
        case GET_PRODUCT_GROUP:
        {
            if(!(parameters == nil))
            {
                if ([parameters count] == 1)
                {
                    _productFeatures = nil;
                    _productFeatures = [[NSMutableArray alloc] init];
                    [_productFeatures addObject:[parameters objectAtIndex:0]];
                    
                    // 0 = Product
                    // String to perform the request
                    requestString = [NSString stringWithFormat:@"/product/%@/category",(NSString *)[((Product *)([parameters objectAtIndex:0])) idProduct]];
                    
                    //Data classes to look for
                    dataClasses = [NSArray arrayWithObjects:[ProductGroup class], nil];
                    
                    //Message to show if no results were provided
                    failedAnswerErrorMessage = nil;
                }
                else
                {
                    NSLog(@"XXXX Incorrect number of parameters to perform request! XXXX");
                    
                    [self processRestConnection: connection WithErrorMessage:nil forOperation:nil];
                    
                    return;
                }
            }
            
            break;
        }
        case GET_SIMILARPRODUCTS_GROUP:
        {
            if(!(parameters == nil))
            {
                if ([parameters count] == 1)
                {
                    _productFeatures = nil;
                    _productFeatures = [[NSMutableArray alloc] init];
                    [_productFeatures addObject:[parameters objectAtIndex:0]];
                    
                    // 0 = Product
                    // String to perform the request
                    requestString = [NSString stringWithFormat:@"/product/%@/category",(NSString *)[((Product *)([parameters objectAtIndex:0])) idProduct]];
                    
                    //Data classes to look for
                    dataClasses = [NSArray arrayWithObjects:[ProductGroup class], nil];
                    
                    //Message to show if no results were provided
                    failedAnswerErrorMessage = [NSArray arrayWithObjects:NSLocalizedString(@"_ERROR_", nil), NSLocalizedString(@"_NO_FEATURES_ERROR_MSG_", nil), NSLocalizedString(@"_OK_", nil), nil];
                }
                else
                {
                    NSLog(@"XXXX Incorrect number of parameters to perform request! XXXX");
                    
                    [self processRestConnection: connection WithErrorMessage:nil forOperation:nil];
                    
                    return;
                }
            }
            
            break;
        }
        case GET_PRODUCTGROUP_FEATURES_FOR_ADVANCED_SEARCH:
        {
            if (_productGroupFeaturesGroup == nil)
            {
                // al pedir los featuresGroup de un productCategory a partir de productCategory con padre a null, y no a partir de una product
                _productGroupFeaturesGroup = [[NSMutableArray alloc] init];
            }
            
            if(!(parameters == nil))
            {
                if ([parameters count] == 1)
                {
                    // 0 = Product Group ID
                    // String to perform the request
                    requestString = [NSString stringWithFormat:@"/productCategory/%@/featuresGroup?sort=name%%20ASC&limit=-1&notblanks=1",(NSString *)[parameters objectAtIndex:0]];
                    
                    //Data classes to look for
                    dataClasses = [NSArray arrayWithObjects:[FeatureGroup class], nil];
                    
                    //Message to show if no results were provided
                    failedAnswerErrorMessage = [NSArray arrayWithObjects:NSLocalizedString(@"_ERROR_", nil), NSLocalizedString(@"_NO_FEATURES_ERROR_MSG_", nil), NSLocalizedString(@"_OK_", nil), nil];
                }
                else
                {
                    NSLog(@"XXXX Incorrect number of parameters to perform request! XXXX");
                    
                    [self processRestConnection: connection WithErrorMessage:nil forOperation:nil];
                    
                    return;
                }
            }
            
            break;
        }
        case GET_FULL_POST:
        {
            if(!(parameters == nil))
            {
                if ([parameters count] == 1) {
                    _postContents = nil;
                    _postContents = [[NSMutableArray alloc] init];
                    
                    
                    // 0 = PostID
                    // String to perform the request
                    requestString = [NSString stringWithFormat:@"/getFullPost/%@",(NSString *)([parameters objectAtIndex:0])];
                    
                    //Data classes to look for
                    dataClasses = [NSArray arrayWithObjects:[FashionistaPost class], nil];
                    
                    //Message to show if no results were provided
                    failedAnswerErrorMessage = [NSArray arrayWithObjects:NSLocalizedString(@"_ERROR_", nil), NSLocalizedString(@"_NO_CONTENTS_ERROR_MSG_", nil), NSLocalizedString(@"_OK_", nil), nil];

                }
                else if ([parameters count] == 2)
                {
                    _postContents = nil;
                    _postContents = [[NSMutableArray alloc] init];
                    
                    BOOL isMagazine = [[parameters objectAtIndex:1] boolValue];
                    
                    // 0 = PostID
                    // String to perform the request
                    if (isMagazine) {
                        requestString = [NSString stringWithFormat:@"/getFullPost/%@?limitContents=-1",(NSString *)([parameters objectAtIndex:0])];
                    }
                    else {
                        requestString = [NSString stringWithFormat:@"/getFullPost/%@",(NSString *)([parameters objectAtIndex:0])];
                    }
                    
                    //Data classes to look for
                    dataClasses = [NSArray arrayWithObjects:[FashionistaPost class], nil];
                    
                    //Message to show if no results were provided
                    failedAnswerErrorMessage = [NSArray arrayWithObjects:NSLocalizedString(@"_ERROR_", nil), NSLocalizedString(@"_NO_CONTENTS_ERROR_MSG_", nil), NSLocalizedString(@"_OK_", nil), nil];
                }
                else
                {
                    NSLog(@"XXXX Incorrect number of parameters to perform request! XXXX");
                    
                    [self processRestConnection: connection WithErrorMessage:nil forOperation:nil];
                    
                    return;
                }
            }
            
            break;
        }
        case GET_AD:
        {
            if (!(parameters == nil)) {
                if ([parameters count] == 2) {
                    requestString = [NSString stringWithFormat:@"/getAdForUser/%@/%@", (NSString*)([parameters objectAtIndex:0]), (NSString*)([parameters objectAtIndex:1])];
                    
                    NSLog(@"GET AD Request : %@", requestString);
                    
                    dataClasses = [NSArray arrayWithObjects:[Ad class], nil];
                    
                    failedAnswerErrorMessage = [NSArray arrayWithObjects:NSLocalizedString(@"_ERROR_", nil), NSLocalizedString(@"_NO_CONTENTS_ERROR_MSG_", nil), NSLocalizedString(@"_OK_", nil), nil];
                }
            }
            else {
                NSLog(@"XXXX Incorrect number of parameters to perform request! XXXX");
                
                [self processRestConnection:connection WithErrorMessage:nil forOperation:nil];
                
                return;
            }
            break;
        }
        case GET_POST:
        case GET_POST_FOR_SHARE:
        {
            if(!(parameters == nil))
            {
                if ([parameters count] == 1)
                {
                    _postContents = nil;
                    _postContents = [[NSMutableArray alloc] init];
                    
                    // 0 = PostID
                    // String to perform the request
                    requestString = [NSString stringWithFormat:@"/fashionistapost/%@",(NSString *)([parameters objectAtIndex:0])];
                    
                    //Data classes to look for
                    dataClasses = [NSArray arrayWithObjects:[FashionistaPost class], nil];
                    
                    //Message to show if no results were provided
                    failedAnswerErrorMessage = [NSArray arrayWithObjects:NSLocalizedString(@"_ERROR_", nil), NSLocalizedString(@"_NO_CONTENTS_ERROR_MSG_", nil), NSLocalizedString(@"_OK_", nil), nil];
                }
                else
                {
                    NSLog(@"XXXX Incorrect number of parameters to perform request! XXXX");
                    
                    [self processRestConnection: connection WithErrorMessage:nil forOperation:nil];
                    
                    return;
                }
            }
            
            break;
        }
        case GET_POST_CONTENT:
        {
            if(!(parameters == nil))
            {
                if ([parameters count] == 1)
                {
                    // 0 = Post
                    // String to perform the request
                    requestString = [NSString stringWithFormat:@"/fashionistapost/%@/fashionistaPostContents?limit=-1",(NSString *)([parameters objectAtIndex:0])];
                    
                    //Data classes to look for
                    dataClasses = [NSArray arrayWithObjects:[FashionistaContent class], nil];
                    
                    //Message to show if no results were provided
                    failedAnswerErrorMessage = [NSArray arrayWithObjects:NSLocalizedString(@"_ERROR_", nil), NSLocalizedString(@"_NO_CONTENTS_ERROR_MSG_", nil), NSLocalizedString(@"_OK_", nil), nil];
                }
                else
                {
                    NSLog(@"XXXX Incorrect number of parameters to perform request! XXXX");
                    
                    [self processRestConnection: connection WithErrorMessage:nil forOperation:nil];
                    
                    return;
                }
            }
            
            break;
        }
        case GET_POST_CONTENT_KEYWORDS:
        {
            if(!(parameters == nil))
            {
                if ([parameters count] == 1)
                {
                    //                    _keywordsPostContent = nil;
                    //                    _keywordsPostContent = [[NSMutableArray alloc] init];
                    //                    [_keywordsPostContent addObject:((NSString *)([parameters objectAtIndex:0]))];
                    
                    // 0 = Post
                    // String to perform the request
                    requestString = [NSString stringWithFormat:@"/fashionistaPostContent/%@/keywords?limit=-1",((NSString *)([parameters objectAtIndex:0]))];
                    
                    //Data classes to look for
                    dataClasses = [NSArray arrayWithObjects:[KeywordFashionistaContent class], nil];
                    
                    //Message to show if no results were provided
                    failedAnswerErrorMessage = [NSArray arrayWithObjects:NSLocalizedString(@"_ERROR_", nil), NSLocalizedString(@"_NO_CONTENTS_ERROR_MSG_", nil), NSLocalizedString(@"_OK_", nil), nil];
                }
                else
                {
                    NSLog(@"XXXX Incorrect number of parameters to perform request! XXXX");
                    
                    [self processRestConnection: connection WithErrorMessage:nil forOperation:nil];
                    
                    return;
                }
            }
            
            break;
        }
        case GET_POST_CONTENT_WARDROBE:
        {
            
            break;
        }
        case GET_POST_COMMENTS:
        {
            if(!(parameters == nil))
            {
                if ([parameters count] == 1)
                {
                    // 0 = Post ID
                    // String to perform the request
                    requestString = [NSString stringWithFormat:@"/fashionistaPost/%@/comments?limit=-1&sort=createdAt DESC",(NSString *)[parameters objectAtIndex:0]];
                    
                    //Data classes to look for
                    dataClasses = [NSArray arrayWithObjects:[Comment class], nil];
                    
                    //Message to show if no results were provided
                    failedAnswerErrorMessage = nil;
                }
                else
                {
                    NSLog(@"XXXX Incorrect number of parameters to perform request! XXXX");
                    
                    [self processRestConnection: connection WithErrorMessage:nil forOperation:nil];
                    
                    return;
                }
            }
            
            break;
        }
        case UNLIKE_POST:
        {
            if(!(parameters == nil))
            {
                if ([parameters count] == 2)
                {
                    // 0 = User ID 1 = Post ID
                    // String to perform the request
                    requestString = [NSString stringWithFormat:@"/user/%@/unlikepost/%@", (NSString*)([parameters objectAtIndex:0]), (NSString*)([parameters objectAtIndex:1])];
                    
                    //Data classes to look for
                    dataClasses = [NSArray arrayWithObjects:[PostLike class], nil];
                    
                    //Message to show if not succeed
                    failedAnswerErrorMessage = [NSArray arrayWithObjects:NSLocalizedString(@"_ERROR_", nil), NSLocalizedString(@"_UNLIKE_ERROR_MSG_", nil), NSLocalizedString(@"_OK_", nil), nil];
                }
                else
                {
                    NSLog(@"XXXX Incorrect number of parameters to perform request! XXXX");
                    
                    [self processRestConnection: connection WithErrorMessage:nil forOperation:nil];
                    
                    return;
                }
            }
            
            break;
        }
        case GET_PRODUCTGROUP_FEATURES:
        {
            if(!(parameters == nil))
            {
                if ([parameters count] == 2)
                {
                    _productFeatures = nil;
                    _productFeatures = [[NSMutableArray alloc] init];
                    [_productFeatures addObject:[parameters objectAtIndex:0]];
                    
                    // 0 = Product 1 = Product Group
                    // String to perform the request
                    ProductGroup * pg = (ProductGroup*)([parameters objectAtIndex:1]);
                    pg = [pg getTopParent];
                    
                    NSString * productGroupId = pg.idProductGroup;
                    /*
                     NSString * productGroupId = (NSString *)([(ProductGroup*)([parameters objectAtIndex:1]) idProductGroup]);
                     
                     if (!(((NSString *)([(ProductGroup*)([parameters objectAtIndex:1]) parentId])) == nil))
                     {
                     if (!([((NSString *)([(ProductGroup*)([parameters objectAtIndex:1]) parentId])) isEqualToString:@""]))
                     {
                     productGroupId = (NSString *)([(ProductGroup*)([parameters objectAtIndex:1]) parentId]);
                     }
                     }
                     */
                    requestString = [NSString stringWithFormat:@"/productCategory/%@/featuresGroup?sort=order%%20DESC",productGroupId];
                    
                    //Data classes to look for
                    dataClasses = [NSArray arrayWithObjects:[FeatureGroupOrderProductGroup class], nil];
                    
                    //Message to show if no results were provided
                    failedAnswerErrorMessage = [NSArray arrayWithObjects:NSLocalizedString(@"_ERROR_", nil), NSLocalizedString(@"_NO_FEATURES_ERROR_MSG_", nil), NSLocalizedString(@"_OK_", nil), nil];
                }
                else
                {
                    NSLog(@"XXXX Incorrect number of parameters to perform request! XXXX");
                    
                    [self processRestConnection: connection WithErrorMessage:nil forOperation:nil];
                    
                    return;
                }
            }
            
            break;
        }
        case GET_FEATUREGROUP_FEATURES:
        {
            if (_featureGroupFeatures == nil)
            {
                // al pedir los featuresGroup de un productCategory a partir de productCategory con padre a null, y no a partir de una product
                _featureGroupFeatures = [[NSMutableArray alloc] init];
            }
            
            if(!(parameters == nil))
            {
                if ([parameters count] == 2)
                {
                    // 0 = Feature Group ID; 1 = 'Verbose'
                    // String to perform the request
                    requestString = [NSString stringWithFormat:@"/featureGroup/%@/featuresrecursive", (NSString *)[parameters objectAtIndex:0]];
                    
                    //Data classes to look for
                    dataClasses = [NSArray arrayWithObjects:[Feature class], nil];
                    
                    //Message to show if no results were provided
                    failedAnswerErrorMessage = [NSArray arrayWithObjects:NSLocalizedString(@"_ERROR_", nil), NSLocalizedString(@"_NO_PROPERTIES_ERROR_MSG_", nil), NSLocalizedString(@"_OK_", nil), nil];
                    
                    // In some cases (when 2nd parameter is 'NO'), we don't want to message the user about the results of this request
                    if (((BOOL)[(NSNumber *)([parameters objectAtIndex:1]) boolValue]) == NO)
                    {
                        failedAnswerErrorMessage = nil;
                    }
                }
                else
                {
                    NSLog(@"XXXX Incorrect number of parameters to perform request! XXXX");
                    
                    [self processRestConnection: connection WithErrorMessage:nil forOperation:nil];
                    
                    return;
                }
            }
            
            break;
        }
        case GET_ALLPRODUCTCATEGORIES:
        {
            if (_allProductCategory == nil){
                _allProductCategory = [[NSMutableArray alloc] init];
            }
            else{
                [_allProductCategory removeAllObjects];
            }
            // String to perform the request
            //            requestString = [NSString stringWithFormat:@"/productcategory?parent=null&limit=-1&populate=featuresGroup,productCategories&sort=name"];
            requestString = [NSString stringWithFormat:@"/productcategory?limit=-1&populate=featuresGroup"];
            
            //Data classes to look for
            dataClasses = [NSArray arrayWithObjects:[ProductGroup class],[FeatureGroupOrderProductGroup class],
                           nil];
            
            //We don't want to show any message
            failedAnswerErrorMessage = nil;
            
            break;
        }
        case GET_ALLFEATURES:
        {
            if (_allFeatures == nil){
                _allFeatures = [[NSMutableArray alloc] init];
            }
            else{
                [_allFeatures removeAllObjects];
            }
            // String to perform the request
            requestString = [NSString stringWithFormat:@"/feature?limit=-1&visible=true"];
            //            requestString = [NSString stringWithFormat:@"/featureGroup?limit=-1&populate=features"];
            
            //Data classes to look for
            dataClasses = [NSArray arrayWithObjects:[Feature class],[FeatureGroup class],
                           nil];
            
            //We don't want to show any message
            failedAnswerErrorMessage = nil;
            
            break;
        }
        case GET_ALLFEATUREGROUPS:
        {
            if (_allFeatures == nil){
                _allFeatures = [[NSMutableArray alloc] init];
            }
            else{
                [_allFeatures removeAllObjects];
            }
            // String to perform the request
            requestString = [NSString stringWithFormat:@"/featureGroup?limit=-1"];
            
            //Data classes to look for
            dataClasses = [NSArray arrayWithObjects:[Feature class],[FeatureGroup class],
                           nil];
            
            //We don't want to show any message
            failedAnswerErrorMessage = nil;
            
            break;
        }
        case GET_PRIORITYBRANDS:
        {
            if (_priorityBrands == nil){
                _priorityBrands = [[NSMutableArray alloc] init];
            }
            else{
                [_priorityBrands removeAllObjects];
            }
            // String to perform the request
            requestString = [NSString stringWithFormat:@"/brand?where={\"priority\":{\"$gt\":0}}&limit=-1&populate=productCategories"];
            requestString = [requestString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            //Data classes to look for
            dataClasses = [NSArray arrayWithObjects:[ProductGroup class],[Brand class],nil];
            
            //We don't want to show any message
            failedAnswerErrorMessage = nil;
            break;
        }
        case GET_ALLBRANDS:
        {
            if (_allBrands == nil){
                _allBrands = [[NSMutableArray alloc] init];
            }
            else{
                [_allBrands removeAllObjects];
            }
            // String to perform the request
            requestString = [NSString stringWithFormat:@"/brand?where={\"with_products\":true}&limit=-1"];
            requestString = [requestString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            //Data classes to look for
            dataClasses = [NSArray arrayWithObjects:[Brand class], nil];
            
            //We don't want to show any message
            failedAnswerErrorMessage = nil;
            break;
        }
        case GET_PRODUCTCATEGORIES:
        {
            if (_productCategories == nil)
            {
                _productCategories = [[NSMutableArray alloc] init];
            }
            // String to perform the request
            requestString = [NSString stringWithFormat:@"/productcategory?parent=null&visible=true&sort=app_name%%20ASC&limit=-1"];
            
            //Data classes to look for
            dataClasses = [NSArray arrayWithObjects:[ProductGroup class],
                           nil];
            
            //Message to show if no results were provided
            failedAnswerErrorMessage = [NSArray arrayWithObjects:NSLocalizedString(@"_ERROR_", nil), NSLocalizedString(@"_NO_RESULTS_ERROR_MSG_", nil), NSLocalizedString(@"_OK_", nil), nil];
            
            break;
        }
        case GET_SUBPRODUCTSCATEGORIES:
        {
            if(!(parameters == nil))
            {
                if ([parameters count] == 1)
                {
                    if (_subProductCategories == nil)
                    {
                        _subProductCategories = [[NSMutableArray alloc] init];
                    }
                    else
                    {
                        [_subProductCategories removeAllObjects];
                    }
                    
                    // String to perform the request
                    requestString = [NSString stringWithFormat:@"/productcategory/%@/productCategories?sort=app_name%%20ASC&visible=true&limit=-1", (NSString*)[parameters objectAtIndex:0]];
                    
                    //Data classes to look for
                    dataClasses = [NSArray arrayWithObjects:[ProductGroup class],
                                   nil];
                    
                    //We don't want to show any message
                    failedAnswerErrorMessage = nil;
                }
                else
                {
                    NSLog(@"XXXX Incorrect number of parameters to perform request! XXXX");
                    
                    [self processRestConnection: connection WithErrorMessage:nil forOperation:nil];
                    
                    return;
                }
            }
            
            break;
        }
        case GET_USER_WARDROBES:
        {
            if(!(parameters == nil))
            {
                if ([parameters count] == 1)
                {
                    // 0 = User ID
                    // String to perform the request
                    requestString = [NSString stringWithFormat:@"/user/%@/wardrobes?limit=-1", (NSString*)[parameters objectAtIndex:0]];
                    
                    //Data classes to look for
                    dataClasses = [NSArray arrayWithObjects:[Wardrobe class], nil];
                    
                    //Message to show if no results were provided
                    failedAnswerErrorMessage = [NSArray arrayWithObjects:NSLocalizedString(@"_ERROR_", nil), NSLocalizedString(@"_NO_WARDROBES_ERROR_MSG_", nil), NSLocalizedString(@"_OK_", nil), nil];
                }
                else
                {
                    NSLog(@"XXXX Incorrect number of parameters to perform request! XXXX");
                    
                    [self processRestConnection: connection WithErrorMessage:nil forOperation:nil];
                    
                    return;
                }
            }
            
            break;
        }
        case GET_USER_WARDROBES_CONTENT:
        {
            if(!(parameters == nil))
            {
                if ([parameters count] == 1)
                {
                    // 0 = Wardrobe Id
                    // String to perform the request
                    requestString = [NSString stringWithFormat:@"/wardrobe/%@?populate=resultQueries&limit=-1", (NSString*)[parameters objectAtIndex:0]];
                    
                    //Data classes to look for
                    dataClasses = [NSArray arrayWithObjects:[GSBaseElement class], [Wardrobe class], nil];
                    
                    //Message to show if no results were provided
                    failedAnswerErrorMessage = [NSArray arrayWithObjects:NSLocalizedString(@"_ERROR_", nil), NSLocalizedString(@"_NO_RESULTS_ERROR_MSG_", nil), NSLocalizedString(@"_OK_", nil), nil];
                }
                else
                {
                    NSLog(@"XXXX Incorrect number of parameters to perform request! XXXX");
                    
                    [self processRestConnection: connection WithErrorMessage:nil forOperation:nil];
                    
                    return;
                }
            }
            
            break;
        }
        case GET_WARDROBE:
        {
            if(!(parameters == nil))
            {
                if ([parameters count] == 1)
                {
                    _wardrobeContents = nil;
                    _wardrobeContents = [[NSMutableArray alloc] init];
                    
                    // 0 = Wardrobe Id
                    // String to perform the request
                    requestString = [NSString stringWithFormat:@"/wardrobe/%@", (NSString*)[parameters objectAtIndex:0]];
                    
                    //Data classes to look for
                    dataClasses = [NSArray arrayWithObjects:[Wardrobe class], nil];
                    
                    //Message to show if no results were provided
                    failedAnswerErrorMessage = [NSArray arrayWithObjects:NSLocalizedString(@"_ERROR_", nil), NSLocalizedString(@"_NO_RESULTS_ERROR_MSG_", nil), NSLocalizedString(@"_OK_", nil), nil];
                }
                else
                {
                    NSLog(@"XXXX Incorrect number of parameters to perform request! XXXX");
                    
                    [self processRestConnection: connection WithErrorMessage:nil forOperation:nil];
                    
                    return;
                }
            }
            
            break;
        }
        case GET_WARDROBE_CONTENT:
        {
            if(!(parameters == nil))
            {
                if ([parameters count] == 1)
                {
                    if(_wardrobeContents == nil)
                    {
                        _wardrobeContents = nil;
                        _wardrobeContents = [[NSMutableArray alloc] init];
                    }
                    
                    // 0 = Wardrobe Id
                    // String to perform the request
                    requestString = [NSString stringWithFormat:@"/wardrobe/%@/resultqueries?limit=-1", (NSString*)[parameters objectAtIndex:0]];
                    
                    //Data classes to look for
                    dataClasses = [NSArray arrayWithObjects:[GSBaseElement class], nil];
                    
                    //Message to show if no results were provided
                    failedAnswerErrorMessage = [NSArray arrayWithObjects:NSLocalizedString(@"_ERROR_", nil), NSLocalizedString(@"_NO_RESULTS_ERROR_MSG_", nil), NSLocalizedString(@"_OK_", nil), nil];
                }
                else
                {
                    NSLog(@"XXXX Incorrect number of parameters to perform request! XXXX");
                    
                    [self processRestConnection: connection WithErrorMessage:nil forOperation:nil];
                    
                    return;
                }
            }
            
            break;
        }
        case GET_USER_FOLLOWS:
        {
            if(!(parameters == nil))
            {
                if ([parameters count] == 1)
                {
                    // 0 = User ID
                    // String to perform the request
                    requestString = [NSString stringWithFormat:@"/follower?following=%@", (NSString*)[parameters objectAtIndex:0]];
                    
                    //Data classes to look for
                    dataClasses = [NSArray arrayWithObjects:[User class], nil];
                    
                    //Message to show if no results were provided
                    failedAnswerErrorMessage = [NSArray arrayWithObjects:NSLocalizedString(@"_ERROR_", nil), NSLocalizedString(@"_NO_WARDROBES_ERROR_MSG_", nil), NSLocalizedString(@"_OK_", nil), nil];
                }
                else
                {
                    NSLog(@"XXXX Incorrect number of parameters to perform request! XXXX");
                    
                    [self processRestConnection: connection WithErrorMessage:nil forOperation:nil];
                    
                    return;
                }
            }
            
            break;
        }
        case GET_USER_NOTIFICATIONS:
        {
            if(!(parameters == nil))
            {
                if ([parameters count] == 1)
                {
                    // 0 = User ID
                    // String to perform the request
                    requestString = [NSString stringWithFormat:@"/user/%@/notifications", (NSString*)[parameters objectAtIndex:0]];
                    
                    //Data classes to look for
                    dataClasses = [NSArray arrayWithObjects:[Notification class], nil];
                    
                    //Message to show if no results were provided
                    failedAnswerErrorMessage = [NSArray arrayWithObjects:NSLocalizedString(@"_ERROR_", nil), NSLocalizedString(@"_NO_NOTIFICATIONS_ERROR_MSG_", nil), NSLocalizedString(@"_OK_", nil), nil];
                }
                else
                {
                    NSLog(@"XXXX Incorrect number of parameters to perform request! XXXX");
                    
                    [self processRestConnection: connection WithErrorMessage:nil forOperation:nil];
                    
                    return;
                }
            }
            
            break;
        }
        case GET_FASHIONISTAWITHMAIL:
        {
            if(!(parameters == nil))
            {
                if ([parameters count] == 1)
                {
                    // 0 = PageID
                    // String to perform the request
                    requestString = [NSString stringWithFormat:@"/user?email=%@",(NSString *)([parameters objectAtIndex:0])];
                    
                    //Data classes to look for
                    dataClasses = [NSArray arrayWithObjects:[User class], nil];
                    
                    //Message to show if no results were provided
                    failedAnswerErrorMessage = [NSArray arrayWithObjects:NSLocalizedString(@"_ERROR_", nil), NSLocalizedString(@"_NO_CONTENTS_ERROR_MSG_", nil), NSLocalizedString(@"_OK_", nil), nil];
                }
                else
                {
                    NSLog(@"XXXX Incorrect number of parameters to perform request! XXXX");
                    
                    [self processRestConnection: connection WithErrorMessage:nil forOperation:nil];
                    
                    return;
                }
            }
            
            break;
        }
        case GET_FASHIONISTAWITHNAME:
        {
            if(!(parameters == nil))
            {
                if ([parameters count] == 1)
                {
                    // 0 = PageID
                    // String to perform the request
                    requestString = [NSString stringWithFormat:@"/user?fashionista_name=%@",(NSString *)([parameters objectAtIndex:0])];
                    
                    //Data classes to look for
                    dataClasses = [NSArray arrayWithObjects:[User class], nil];
                    
                    //Message to show if no results were provided
                    failedAnswerErrorMessage = [NSArray arrayWithObjects:NSLocalizedString(@"_ERROR_", nil), NSLocalizedString(@"_NO_CONTENTS_ERROR_MSG_", nil), NSLocalizedString(@"_OK_", nil), nil];
                }
                else
                {
                    NSLog(@"XXXX Incorrect number of parameters to perform request! XXXX");
                    
                    [self processRestConnection: connection WithErrorMessage:nil forOperation:nil];
                    
                    return;
                }
            }
            
            break;
        }
        case GET_FASHIONISTA:
        {
            if(!(parameters == nil))
            {
                if ([parameters count] == 1)
                {
                    // 0 = PageID
                    // String to perform the request
                    requestString = [NSString stringWithFormat:@"/user/%@",(NSString *)([parameters objectAtIndex:0])];
                    
                    //Data classes to look for
                    dataClasses = [NSArray arrayWithObjects:[User class], nil];
                    
                    //Message to show if no results were provided
                    failedAnswerErrorMessage = [NSArray arrayWithObjects:NSLocalizedString(@"_ERROR_", nil), NSLocalizedString(@"_NO_CONTENTS_ERROR_MSG_", nil), NSLocalizedString(@"_OK_", nil), nil];
                }
                else
                {
                    NSLog(@"XXXX Incorrect number of parameters to perform request! XXXX");
                    
                    [self processRestConnection: connection WithErrorMessage:nil forOperation:nil];
                    
                    return;
                }
            }
            
            break;
        }
        case GET_PAGE:
        {
            if(!(parameters == nil))
            {
                if ([parameters count] == 1)
                {
                    // 0 = PageID
                    // String to perform the request
                    requestString = [NSString stringWithFormat:@"/fashionistapage/%@",(NSString *)([parameters objectAtIndex:0])];
                    
                    //Data classes to look for
                    dataClasses = [NSArray arrayWithObjects:[FashionistaPage class], nil];
                    
                    //Message to show if no results were provided
                    failedAnswerErrorMessage = [NSArray arrayWithObjects:NSLocalizedString(@"_ERROR_", nil), NSLocalizedString(@"_NO_CONTENTS_ERROR_MSG_", nil), NSLocalizedString(@"_OK_", nil), nil];
                }
                else
                {
                    NSLog(@"XXXX Incorrect number of parameters to perform request! XXXX");
                    
                    [self processRestConnection: connection WithErrorMessage:nil forOperation:nil];
                    
                    return;
                }
            }
            
            break;
        }
        case GET_USER_NEWSFEED:
        {
            if(!(parameters == nil))
            {
                if ([parameters count] == 1)
                {
                    self.searchResults = nil;
                    
                    // String to perform the request
                    requestString = [NSString stringWithFormat:@"/newsfeed/%@", (NSString*)[parameters objectAtIndex:0]];
                    
                    //Data classes to look for
                    dataClasses = [NSArray arrayWithObjects:[SearchQuery class], nil];
                    
                    //Message to show if no results were provided
                    failedAnswerErrorMessage = [NSArray arrayWithObjects:NSLocalizedString(@"_ERROR_", nil), NSLocalizedString(@"_ERROR_GETTING_FASHIONISTA_PAGES_", nil), NSLocalizedString(@"_OK_", nil), nil];
                }
                else
                {
                    NSLog(@"XXXX Incorrect number of parameters to perform request! XXXX");
                    
                    [self processRestConnection: connection WithErrorMessage:nil forOperation:nil];
                    
                    return;
                }
            }
            break;
        }
        case GET_USER_HISTORY:
        {
            if(!(parameters == nil))
            {
                if ([parameters count] > 2)
                {
                    self.searchResults = nil;
                    
                    requestString = [NSString stringWithFormat:@"/taghistory?usertagged=%@&skip=%d&limit=30&sort=createdAt%%20DESC", (NSString*)[parameters objectAtIndex:0],(int)([(NSNumber *)([parameters objectAtIndex:1]) intValue])];
                    NSString* searchString = [parameters objectAtIndex:2];
                    if(![searchString isEqualToString:@""]||[parameters count]>3){
                        NSMutableString* whereClause = [NSMutableString stringWithFormat:@"\"usertagged\":\"%@\"",(NSString*)[parameters objectAtIndex:0]];
                        if(![searchString isEqualToString:@""]){
                            [whereClause appendFormat:@",\"fashionista_name\":{\"contains\":\"%@\"}",searchString];
                        }
                        if ([parameters count]>3) {
                            [whereClause appendFormat:@",\"createdAt\":{\"$gte\":\"%@\",\"$lt\":\"%@\"}",[parameters objectAtIndex:3],[parameters objectAtIndex:4]];
                        }
                        requestString =[NSString stringWithFormat:@"/taghistory?where={%@}&skip=%d&limit=30&sort=createdAt DESC", whereClause,(int)([(NSNumber *)([parameters objectAtIndex:1]) intValue])];
                        requestString = [requestString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                    }
                    
                    //Data classes to look for
                    dataClasses = [NSArray arrayWithObjects:[PostLike class], nil];
                    
                    //Message to show if no results were provided
                    failedAnswerErrorMessage = [NSArray arrayWithObjects:NSLocalizedString(@"_ERROR_", nil), NSLocalizedString(@"_ERROR_GETTING_FASHIONISTA_PAGES_", nil), NSLocalizedString(@"_OK_", nil), nil];
                }
                else
                {
                    NSLog(@"XXXX Incorrect number of parameters to perform request! XXXX");
                    
                    [self processRestConnection: connection WithErrorMessage:nil forOperation:nil];
                    
                    return;
                }
            }
            break;
        }
        case GET_USER_LIKES:
        {
            if(!(parameters == nil))
            {
                if ([parameters count] == 2)
                {
                    self.searchResults = nil;
                    
                    // String to perform the request
                    
                    //                    requestString = [NSString stringWithFormat:@"/postlike?user=%@&populate=post&skip=%d&limit=30&sort=createdAt%%20DESC", (NSString*)[parameters objectAtIndex:0],(int)([(NSNumber *)([parameters objectAtIndex:1]) intValue])];
                    
                    requestString = [NSString stringWithFormat:@"/user/%@/getpostlikes?skip=%d&limit=30&sort=createdAt%%20DESC", (NSString*)[parameters objectAtIndex:0],(int)([(NSNumber *)([parameters objectAtIndex:1]) intValue])];
                    
                    //Data classes to look for
                    dataClasses = [NSArray arrayWithObjects:[PostLike class], nil];
                    
                    //Message to show if no results were provided
                    failedAnswerErrorMessage = [NSArray arrayWithObjects:NSLocalizedString(@"_ERROR_", nil), NSLocalizedString(@"_ERROR_GETTING_FASHIONISTA_PAGES_", nil), NSLocalizedString(@"_OK_", nil), nil];
                }
                else
                {
                    NSLog(@"XXXX Incorrect number of parameters to perform request! XXXX");
                    
                    [self processRestConnection: connection WithErrorMessage:nil forOperation:nil];
                    
                    return;
                }
            }
            break;
        }
        case GET_FASHIONISTAPAGES:
        {
            if(!(parameters == nil))
            {
                if ([parameters count] == 1)
                {
                    // String to perform the request
                    requestString = [NSString stringWithFormat:@"/user/%@/fashionistapages", (NSString*)[parameters objectAtIndex:0]];
                    
                    //Data classes to look for
                    dataClasses = [NSArray arrayWithObjects:[FashionistaPage class], nil];
                    
                    //Message to show if no results were provided
                    failedAnswerErrorMessage = [NSArray arrayWithObjects:NSLocalizedString(@"_ERROR_", nil), NSLocalizedString(@"_ERROR_GETTING_FASHIONISTA_PAGES_", nil), NSLocalizedString(@"_OK_", nil), nil];
                }
                else
                {
                    NSLog(@"XXXX Incorrect number of parameters to perform request! XXXX");
                    
                    [self processRestConnection: connection WithErrorMessage:nil forOperation:nil];
                    
                    return;
                }
            }
            break;
        }
        case GET_FASHIONISTAPOSTS:
        {
            if(!(parameters == nil))
            {
                if ([parameters count] == 6)
                {
                    self.searchResults = nil;
                    
                    NSMutableString* reqString = [NSMutableString stringWithFormat:@"/searchfashionistapostofuser/%@",(NSString*)([parameters objectAtIndex:0])];
                    BOOL hasParam = NO;
                    //Date String
                    NSString* aString = [parameters objectAtIndex:1];
                    if(![aString isEqualToString:@""]){
                        if(!hasParam){
                            hasParam = YES;
                            [reqString appendString:@"?"];
                        }else{
                            [reqString appendString:@"&"];
                        }
                        [reqString appendFormat:@"%@",aString];
                    }
                    //TypePost string
                    aString = [parameters objectAtIndex:2];
                    if(![aString isEqualToString:@""]){
                        if(!hasParam){
                            hasParam = YES;
                            [reqString appendString:@"?"];
                        }else{
                            [reqString appendString:@"&"];
                        }
                        [reqString appendFormat:@"typePost=%@",aString];
                    }
                    
                    //Category string
                    aString = [parameters objectAtIndex:3];
                    if(![aString isEqualToString:@""]){
                        if(!hasParam){
                            hasParam = YES;
                            [reqString appendString:@"?"];
                        }else{
                            [reqString appendString:@"&"];
                        }
                        [reqString appendFormat:@"postCategory=%@",aString];
                    }
                    //Sort string
                    aString = [parameters objectAtIndex:4];
                    if(![aString isEqualToString:@""]){
                        if(!hasParam){
                            hasParam = YES;
                            [reqString appendString:@"?"];
                        }else{
                            [reqString appendString:@"&"];
                        }
                        [reqString appendFormat:@"sort=%@",aString];
                    }
                    //Search string
                    aString = [parameters objectAtIndex:5];
                    if(![aString isEqualToString:@""]){
                        if(!hasParam){
                            hasParam = YES;
                            [reqString appendString:@"?"];
                        }else{
                            [reqString appendString:@"&"];
                        }
                        [reqString appendFormat:@"stringToSearch=%@",aString];
                    }
                    // String to perform the request
                    requestString = [NSString stringWithString:reqString];
                    
                    //Data classes to look for
                    dataClasses = [NSArray arrayWithObjects:[SearchQuery class], nil];
                    
                    //Message to show if no results were provided
                    failedAnswerErrorMessage = [NSArray arrayWithObjects:NSLocalizedString(@"_ERROR_", nil), NSLocalizedString(@"_NO_RESULTS_ERROR_MSG_", nil), NSLocalizedString(@"_OK_", nil), nil];
                    
                    //Data classes to look for
                    dataClasses = [NSArray arrayWithObjects:[FashionistaPost class], nil];
                    
                    //Message to show if no results were provided
                    failedAnswerErrorMessage = [NSArray arrayWithObjects:NSLocalizedString(@"_ERROR_", nil), NSLocalizedString(@"_ERROR_GETTING_FASHIONISTA_POSTS_", nil), NSLocalizedString(@"_OK_", nil), nil];
                }
                else
                {
                    NSLog(@"XXXX Incorrect number of parameters to perform request! XXXX");
                    
                    [self processRestConnection: connection WithErrorMessage:nil forOperation:nil];
                    
                    return;
                }
            }
            break;
        }
        case GET_FASHIONISTAWARDROBES:
        {
            if(!(parameters == nil))
            {
                if ([parameters count] == 3)
                {
                    self.searchResults = nil;
                    
                    NSMutableString* reqString = [NSMutableString stringWithFormat:@"/searchfashionistapostofuser/%@",(NSString*)([parameters objectAtIndex:0])];
                    BOOL hasParam = NO;
                    //Date String
                    NSString* aString = [parameters objectAtIndex:1];
                    if(![aString isEqualToString:@""]){
                        if(!hasParam){
                            hasParam = YES;
                            [reqString appendString:@"?"];
                        }else{
                            [reqString appendString:@"&"];
                        }
                        [reqString appendFormat:@"%@",aString];
                    }
                    //TypePost string
                    aString = [parameters objectAtIndex:2];
                    if(![aString isEqualToString:@""]){
                        if(!hasParam){
                            hasParam = YES;
                            [reqString appendString:@"?"];
                        }else{
                            [reqString appendString:@"&"];
                        }
                        [reqString appendFormat:@"typePost=%@",aString];
                    }
                    
//                    //Category string
//                    aString = [parameters objectAtIndex:3];
//                    if(![aString isEqualToString:@""]){
//                        if(!hasParam){
//                            hasParam = YES;
//                            [reqString appendString:@"?"];
//                        }else{
//                            [reqString appendString:@"&"];
//                        }
//                        [reqString appendFormat:@"postCategory=%@",aString];
//                    }
//                    //Sort string
//                    aString = [parameters objectAtIndex:4];
//                    if(![aString isEqualToString:@""]){
//                        if(!hasParam){
//                            hasParam = YES;
//                            [reqString appendString:@"?"];
//                        }else{
//                            [reqString appendString:@"&"];
//                        }
//                        [reqString appendFormat:@"sort=%@",aString];
//                    }
//                    //Search string
//                    aString = [parameters objectAtIndex:5];
//                    if(![aString isEqualToString:@""]){
//                        if(!hasParam){
//                            hasParam = YES;
//                            [reqString appendString:@"?"];
//                        }else{
//                            [reqString appendString:@"&"];
//                        }
//                        [reqString appendFormat:@"stringToSearch=%@",aString];
//                    }
                    // String to perform the request
                    requestString = [NSString stringWithString:reqString];
                    
                    //Data classes to look for
                    dataClasses = [NSArray arrayWithObjects:[SearchQuery class], nil];
                    
                    //Message to show if no results were provided
                    failedAnswerErrorMessage = [NSArray arrayWithObjects:NSLocalizedString(@"_ERROR_", nil), NSLocalizedString(@"_NO_RESULTS_ERROR_MSG_", nil), NSLocalizedString(@"_OK_", nil), nil];
                    
                    //Data classes to look for
                    dataClasses = [NSArray arrayWithObjects:[FashionistaPost class], nil];
                    
                    //Message to show if no results were provided
                    failedAnswerErrorMessage = [NSArray arrayWithObjects:NSLocalizedString(@"_ERROR_", nil), NSLocalizedString(@"_ERROR_GETTING_FASHIONISTA_POSTS_", nil), NSLocalizedString(@"_OK_", nil), nil];
                }
                else
                {
                    NSLog(@"XXXX Incorrect number of parameters to perform request! XXXX");
                    
                    [self processRestConnection: connection WithErrorMessage:nil forOperation:nil];
                    
                    return;
                }
            }
            break;

        }
        case GET_FASHIONISTAMAGAZINES:
        {
            if (!(parameters == nil)) {
                requestString = [NSString stringWithFormat:@"/fashionistapost?owner=%@&imit=3&sort=createdAt DESC&fashionistaPostType=magazine", (NSString*)[parameters objectAtIndex:0]];
                requestString = [requestString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                NSLog(@"Request String : %@", requestString);
                dataClasses = [NSArray arrayWithObjects:[FashionistaPost class], nil];
                
                failedAnswerErrorMessage = [NSArray arrayWithObjects:NSLocalizedString(@"_ERROR_", nil), NSLocalizedString(@"_ERROR_GETTING_FASHIONISTA_POSTS_", nil), NSLocalizedString(@"_OK_", nil), nil];
            }
            else
            {
                NSLog(@"XXXX Incorrect number of parameters to perform request! XXXX");
                
                [self processRestConnection: connection WithErrorMessage:nil forOperation:nil];
                
                return;
            }
            break;
        }
        case GET_FASHIONISTAMAGAZINES_RELATED:
        {
            if (!(parameters == nil)) {
                requestString = [NSString stringWithFormat:@"/fashionistapost?magazineCategory=%@&imit=3&sort=createdAt DESC&fashionistaPostType=magazine", (NSString*)[parameters objectAtIndex:0]];
                requestString = [requestString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                NSLog(@"Request String : %@", requestString);
                dataClasses = [NSArray arrayWithObjects:[FashionistaPost class], nil];
                
                failedAnswerErrorMessage = [NSArray arrayWithObjects:NSLocalizedString(@"_ERROR_", nil), NSLocalizedString(@"_ERROR_GETTING_FASHIONISTA_POSTS_", nil), NSLocalizedString(@"_OK_", nil), nil];
            }
            else
            {
                NSLog(@"XXXX Incorrect number of parameters to perform request! XXXX");
                
                [self processRestConnection: connection WithErrorMessage:nil forOperation:nil];
                
                return;
            }
            break;
        }
        case GET_FOLLOWERS_FOLLOWINGS_COUNT:
        {
            if(!(parameters == nil))
            {
                if ([parameters count] >= 1)
                {
                    // String to perform the request
                    requestString = [NSString stringWithFormat:@"/user/%@/followersfollowingcount", (NSString*)[parameters objectAtIndex:0]];
                    
                    //Data classes to look for
                    dataClasses = [NSArray arrayWithObjects:[NSMutableDictionary class], nil];
                    
                    //Message to show if no results were provided
                    failedAnswerErrorMessage = [NSArray arrayWithObjects:NSLocalizedString(@"_ERROR_", nil), NSLocalizedString(@"_ERROR_GETTING_FASHIONISTA_POSTS_", nil), NSLocalizedString(@"_OK_", nil), nil];
                }
                else
                {
                    NSLog(@"XXXX Incorrect number of parameters to perform request! XXXX");
                    
                    [self processRestConnection: connection WithErrorMessage:nil forOperation:nil];
                    
                    return;
                }
            }
            break;
        }
        case GET_FASHIONISTAPAGE_AUTHOR:
        {
            if(!(parameters == nil))
            {
                if ([parameters count] == 1)
                {
                    // String to perform the request
                    requestString = [NSString stringWithFormat:@"/fashionistapage/%@/user", (NSString*)[parameters objectAtIndex:0]];
                    
                    //Data classes to look for
                    dataClasses = [NSArray arrayWithObjects:[User class], nil];
                    
                    //Message to show if no results were provided
                    failedAnswerErrorMessage = nil;
                }
                else
                {
                    NSLog(@"XXXX Incorrect number of parameters to perform request! XXXX");
                    
                    [self processRestConnection: connection WithErrorMessage:nil forOperation:nil];
                    
                    return;
                }
            }
            break;
        }
        case GET_FASHIONISTAPAGE_POSTS:
        {
            if(!(parameters == nil))
            {
                if ([parameters count] == 2)
                {
                    // 0 = Fashionista Page Id; 1 = Skip
                    // String to perform the request
                    requestString = [NSString stringWithFormat:@"/fashionistapage/%@/fashionistaPosts?skip=%d&sort=order%%20asc",(NSString*)[parameters objectAtIndex:0],(int)([(NSNumber *)([parameters objectAtIndex:1]) intValue])];
                    
                    //Data classes to look for
                    dataClasses = [NSArray arrayWithObjects:[FashionistaPost class], nil];
                    
                    //Message to show if no results were provided
                    failedAnswerErrorMessage = [NSArray arrayWithObjects:NSLocalizedString(@"_ERROR_", nil), NSLocalizedString(@"_NO_RESULTS_ERROR_MSG_", nil), NSLocalizedString(@"_OK_", nil), nil];
                }
                else
                {
                    NSLog(@"XXXX Incorrect number of parameters to perform request! XXXX");
                    
                    [self processRestConnection: connection WithErrorMessage:nil forOperation:nil];
                    
                    return;
                }
            }
            
            break;
        }
        case GET_POST_LIKES:
        {
            if(!(parameters == nil))
            {
                if ([parameters count] == 1)
                {
                    // 0 = Post ID
                    // String to perform the request
                    requestString = [NSString stringWithFormat:@"/fashionistaPost/%@/likes?limit=-1" , (NSString*)[parameters objectAtIndex:0]];
                    
                    //Data classes to look for
                    dataClasses = [NSArray arrayWithObjects:[PostLike class], nil];
                    
                    //Message to show if no results were provided
                    failedAnswerErrorMessage = nil;
                }
                else
                {
                    NSLog(@"XXXX Incorrect number of parameters to perform request! XXXX");
                    
                    [self processRestConnection: connection WithErrorMessage:nil forOperation:nil];
                    
                    return;
                }
            }
            
            break;
        }
        case GET_ONLYPOST_LIKES_NUMBER:
        case GET_POST_LIKES_NUMBER:
        {
            if(!(parameters == nil))
            {
                if ([parameters count] == 1)
                {
                    // 0 = Post ID
                    // String to perform the request
                    requestString = [NSString stringWithFormat:@"/fashionistaPost/%@/likescount" , (NSString*)[parameters objectAtIndex:0]];
                    
                    //Data classes to look for
                    dataClasses = [NSArray arrayWithObjects:[NSMutableDictionary class], nil];
                    
                    //Message to show if no results were provided
                    failedAnswerErrorMessage = nil;
                }
                else
                {
                    NSLog(@"XXXX Incorrect number of parameters to perform request! XXXX");
                    
                    [self processRestConnection: connection WithErrorMessage:nil forOperation:nil];
                    
                    return;
                }
            }
            
            break;
        }
        case GET_USER_LIKES_POST:
        {
            if(!(parameters == nil))
            {
                if ([parameters count] == 2)
                {
                    // 0 = User ID 1 = Post ID
                    // String to perform the request
                    requestString = [NSString stringWithFormat:@"/user/%@/likepost/%@" , (NSString*)[parameters objectAtIndex:0], (NSString*)[parameters objectAtIndex:1]];
                    
                    //Data classes to look for
                    dataClasses = [NSArray arrayWithObjects:[NSMutableDictionary class], nil];
                    
                    //Message to show if no results were provided
                    failedAnswerErrorMessage = nil;
                }
                else
                {
                    NSLog(@"XXXX Incorrect number of parameters to perform request! XXXX");
                    
                    [self processRestConnection: connection WithErrorMessage:nil forOperation:nil];
                    
                    return;
                }
            }
            
            break;
        }
        case GET_FULLSCREENBACKGROUNDAD:
        {
            if(!(parameters == nil))
            {
                if ([parameters count] == 1)
                {
                    // 0 = User ID
                    // String to perform the request
                    requestString = [NSString stringWithFormat:@"/getFullScreenBackgroundAdForUser/%@", (NSString*)[parameters objectAtIndex:0]];
                    
                    //Data classes to look for
                    dataClasses = [NSArray arrayWithObjects:[BackgroundAd class], nil];
                    
                    //Message to show if no results were provided
                    failedAnswerErrorMessage = nil;
                }
            }
            
            break;
        }
        case GET_SEARCHADAPTEDBACKGROUNDAD:
        {
            if(!(parameters == nil))
            {
                if ([parameters count] == 1)
                {
                    // 0 = User ID
                    // String to perform the request
                    requestString = [NSString stringWithFormat:@"/getSearchAdaptedBackgroundAdForUser/%@", (NSString*)[parameters objectAtIndex:0]];
                    
                    //Data classes to look for
                    dataClasses = [NSArray arrayWithObjects:[BackgroundAd class], nil];
                    
                    //Message to show if no results were provided
                    failedAnswerErrorMessage = nil;
                }
            }
            
            break;
        }
        case GET_POSTADAPTEDBACKGROUNDAD:
        {
            if(!(parameters == nil))
            {
                if ([parameters count] == 1)
                {
                    // 0 = User ID
                    // String to perform the request
                    requestString = [NSString stringWithFormat:@"/getPostAdaptedBackgroundAdForUser/%@", (NSString*)[parameters objectAtIndex:0]];
                    
                    //Data classes to look for
                    dataClasses = [NSArray arrayWithObjects:[BackgroundAd class], nil];
                    
                    //Message to show if no results were provided
                    failedAnswerErrorMessage = nil;
                }
            }
            
            break;
        }
        case GET_SHARE:
        {
            if(!(parameters == nil))
            {
                if ([parameters count] == 1)
                {
                    // 0 = Share ID
                    // String to perform the request
                    requestString = [NSString stringWithFormat:@"/share/%@", (NSString*)[parameters objectAtIndex:0]];
                    
                    //Data classes to look for
                    dataClasses = [NSArray arrayWithObjects:[Share class], nil];
                    
                    //Message to show if no results were provided
                    failedAnswerErrorMessage = nil;
                }
            }
            
            break;
        }
        case GET_LIVESTREAMINGPRIVACY:
        {
            requestString = [NSString stringWithFormat:@"/LivestreamingPrivacy?limit=-1"];
            //Data object to post
            dataClasses = [NSArray arrayWithObjects:[LiveStreamingPrivacy class], nil];
            //Message to show if not succeed
            failedAnswerErrorMessage = nil;

            break;
        }
        case GET_LIVESTREAMINGCATEGORIES:
        {
            // String to perform the request
            requestString = @"/LivestreamingCategory?limit=-1";
            
            //Data classes to look for
            dataClasses = [NSArray arrayWithObjects:[LiveStreamingCategory class], nil];
            
            //Message to show if no results were provided
            failedAnswerErrorMessage = nil;
            
            break;
        }
        case GET_TYPELOOKS:
        {
            if (parameters == nil) {
                // String to perform the request
                requestString = @"/TypeLook?limit=-1";
            } else {
                if ([parameters count] == 1)
                {
                    requestString = [NSString stringWithFormat:@"/TypeLook?where={\"name\":{\"startsWith\":%@}}&limit=-1", [parameters objectAtIndex:0]];
                }
            }
            //Data classes to look for
            dataClasses = [NSArray arrayWithObjects:[TypeLook class], nil];
            
            //Message to show if no results were provided
            failedAnswerErrorMessage = nil;
            
            break;
        }
        case GET_LIVESTREAMING:
        {
            if(!(parameters == nil))
            {
                if ([parameters count] == 1)
                {
                    requestString = [NSString stringWithFormat:@"/Livestreaming/%@",  [((LiveStreaming*)[parameters objectAtIndex:0]) idLiveStreaming]];
                    
                    //Data classes to look for
                    dataClasses = [NSArray arrayWithObjects:[LiveStreaming class], nil];
                    
                    //Message to show if no results were provided
                    failedAnswerErrorMessage = nil;
                }
            }
            
            break;
        }
        case GET_MOST_POPULAR_HASHTAG:
        {
            if(!(parameters == nil))
            {
                if ([parameters count] == 3)
                {
                    NSString *startsWith = [parameters objectAtIndex:0];
                    NSNumber *skip = [parameters objectAtIndex:1];
                    NSNumber *iLimit = [parameters objectAtIndex:2];
                    requestString = [NSString stringWithFormat:@"/getMostPopularHashTags?startsWith=%@&skip=%@&limit=%@", startsWith, skip, iLimit];
                    
                    //Data classes to look for
                    dataClasses = [NSArray arrayWithObjects:[Keyword class], nil];
                    
                    //Message to show if no results were provided
                    failedAnswerErrorMessage = nil;
                }
            }
            
            break;
        }
        case GET_HASHTAG:
        {
            if(!(parameters == nil))
            {
                if ([parameters count] == 3)
                {
                    NSString *startsWith = [parameters objectAtIndex:0];
                    NSNumber *skip = [parameters objectAtIndex:1];
                    NSNumber *iLimit = [parameters objectAtIndex:2];
                    requestString = [NSString stringWithFormat:@"/keyword?where={\"name\":{\"startsWith\":\"%@\"}}&skip=%@&limit=%@&sort=name_lower", startsWith, skip, iLimit];
                    requestString = [requestString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                    //Data classes to look for
                    dataClasses = [NSArray arrayWithObjects:[Keyword class], nil];
                    
                    //Message to show if no results were provided
                    failedAnswerErrorMessage = nil;
                }
            }
            
            break;
        }
        default:
            break;
    }
    
    if(!(requestString == nil) && (!(dataClasses == nil)))
    {
        if ((!([requestString isEqualToString:@""])) && ([dataClasses count] > 0))
        {
            NSDate *methodStart = [NSDate date];
            
            [[RKObjectManager sharedManager] getObjectsAtPath:requestString
                                                   parameters:nil
                                                      success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult)
             {
                 // If the GS server provided an answer, check wheter that answer could be mapped into our data classes
                 
                 NSDate *methodFinish = [NSDate date];
                 
                 NSTimeInterval executionTime = [methodFinish timeIntervalSinceDate:methodStart];
                 
                 NSLog(@"Operation <%@> succeed!! It took: %f", operation.HTTPRequestOperation.request.URL, executionTime);
                 
                 [self processAnswerToRestConnection:connection WithResult:[mappingResult array] lookingForClasses:dataClasses andIfErrorMessage:failedAnswerErrorMessage];
             }
                                                      failure:^(RKObjectRequestOperation *operation, NSError *error)
             {
                 //Message to show if no results were provided
                 NSArray *errorMessage = [NSArray arrayWithObjects:NSLocalizedString(@"_ERROR_", nil), NSLocalizedString(@"_CONNECTION_ERROR_MSG_", nil), NSLocalizedString(@"_OK_", nil), nil];
                 
                 NSLog(@"Error: %@", error);
                 // If 'failedAnswerErrorMessage' is nil, it means that we don't want to provide messages to the user
                 if(failedAnswerErrorMessage == nil)
                 {
                     errorMessage = nil;
                 }
                 
                 NSLog(@"Operation <%@> failed with error: %ld", operation.HTTPRequestOperation.request.URL, (long)operation.HTTPRequestOperation.response.statusCode);
                 
                 [self processRestConnection: connection WithErrorMessage:errorMessage forOperation:operation];
             }];
            
            return;
        }
    }
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_ERROR_", nil) message:NSLocalizedString(@"_CONNECTION_ERROR_MSG_", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"_OK_", nil) otherButtonTitles:nil];
    
    [alertView show];
    
    [self processRestConnection: connection WithErrorMessage:nil forOperation:nil];
}


// Perform Rest Post
- (void) performRestPost:(connectionType)connection withParamaters:(NSArray *)parameters
{
    [self performRestPost:connection withParamaters:parameters retrying:YES];
}

- (void) performRestPost:(connectionType)connection withParamaters:(NSArray *)parameters retrying:(BOOL) bRetrying
{
    NSString * postString;
    id dataObject;
    NSArray *failedAnswerErrorMessage;
    
    switch (connection)
    {
        case POST_FOLLOW_SOCIALNETWORK_USERS:
        {
            if(!(parameters == nil))
            {
                if ([parameters count] == 2)
                {
                    // 0 = UserReport object
                    // String to perform the post
                    postString = [NSString stringWithFormat:@"/user/%@/followfriendsfromsocialnetwork/%@",(NSString*)[parameters objectAtIndex:0],((SearchQuery*)[parameters objectAtIndex:1]).idSearchQuery];
                    
                    //Data object to post
                    dataObject = (SearchQuery*)[parameters objectAtIndex:1];
                    
                    //Message to show if not succeed
                    failedAnswerErrorMessage = nil;
                }
                else
                {
                    NSLog(@"XXXX Incorrect number of parameters to perform request! XXXX");
                    
                    [self processRestConnection: connection WithErrorMessage:nil forOperation:nil];
                    
                    return;
                }
            }
            break;
        }
        case ADD_USERREPORT:
        {
            if(!(parameters == nil))
            {
                if ([parameters count] == 1)
                {
                    // 0 = UserReport object
                    // String to perform the post
                    postString = [NSString stringWithFormat:@"/reportUser"];
                    
                    //Data object to post
                    dataObject = (UserReport*)[parameters objectAtIndex:0];
                    
                    //Message to show if not succeed
                    failedAnswerErrorMessage = nil;
                }
                else
                {
                    NSLog(@"XXXX Incorrect number of parameters to perform request! XXXX");
                    
                    [self processRestConnection: connection WithErrorMessage:nil forOperation:nil];
                    
                    return;
                }
            }
            
            break;
        }
        case ADD_POSTCOMMENTREPORT:
        {
            if(!(parameters == nil))
            {
                if ([parameters count] == 1)
                {
                    // 0 = PostCommentReport object
                    // String to perform the post
                    postString = [NSString stringWithFormat:@"/reportPostComment"];
                    
                    //Data object to post
                    dataObject = (PostCommentReport*)[parameters objectAtIndex:0];
                    
                    //Message to show if not succeed
                    failedAnswerErrorMessage = nil;
                }
                else
                {
                    NSLog(@"XXXX Incorrect number of parameters to perform request! XXXX");
                    
                    [self processRestConnection: connection WithErrorMessage:nil forOperation:nil];
                    
                    return;
                }
            }
            
            break;
        }
        case ADD_POSTCONTENTREPORT:
        {
            if(!(parameters == nil))
            {
                if ([parameters count] == 1)
                {
                    // 0 = PostContentReport object
                    // String to perform the post
                    postString = [NSString stringWithFormat:@"/reportPostContent"];
                    
                    //Data object to post
                    dataObject = (PostContentReport*)[parameters objectAtIndex:0];
                    
                    //Message to show if not succeed
                    failedAnswerErrorMessage = nil;
                }
                else
                {
                    NSLog(@"XXXX Incorrect number of parameters to perform request! XXXX");
                    
                    [self processRestConnection: connection WithErrorMessage:nil forOperation:nil];
                    
                    return;
                }
            }
            
            break;
        }
        case ADD_PRODUCTREPORT:
        {
            if(!(parameters == nil))
            {
                if ([parameters count] == 1)
                {
                    // 0 = ProductReport object
                    // String to perform the post
                    postString = [NSString stringWithFormat:@"/reportProduct"];
                    
                    //Data object to post
                    dataObject = (ProductReport*)[parameters objectAtIndex:0];
                    
                    //Message to show if not succeed
                    failedAnswerErrorMessage = nil;
                }
                else
                {
                    NSLog(@"XXXX Incorrect number of parameters to perform request! XXXX");
                    
                    [self processRestConnection: connection WithErrorMessage:nil forOperation:nil];
                    
                    return;
                }
            }
            
            break;
        }
        case ADD_PRODUCTVIEW:
        {
            if(!(parameters == nil))
            {
                if ([parameters count] == 1)
                {
                    // 0 = ProductView object
                    // String to perform the post
                    postString = [NSString stringWithFormat:@"/statProductView"];
                    
                    //Data object to post
                    dataObject = (ProductView*)[parameters objectAtIndex:0];
                    
                    //Message to show if not succeed
                    failedAnswerErrorMessage = nil;
                }
                else
                {
                    NSLog(@"XXXX Incorrect number of parameters to perform request! XXXX");
                    
                    [self processRestConnection: connection WithErrorMessage:nil forOperation:nil];
                    
                    return;
                }
            }
            
            break;
        }
        case ADD_PRODUCTSHARED:
        {
            if(!(parameters == nil))
            {
                if ([parameters count] == 1)
                {
                    // 0 = ProductView object
                    // String to perform the post
                    postString = [NSString stringWithFormat:@"/statProductShared"];
                    
                    //Data object to post
                    dataObject = (ProductShared*)[parameters objectAtIndex:0];
                    
                    //Message to show if not succeed
                    failedAnswerErrorMessage = nil;
                }
                else
                {
                    NSLog(@"XXXX Incorrect number of parameters to perform request! XXXX");
                    
                    [self processRestConnection: connection WithErrorMessage:nil forOperation:nil];
                    
                    return;
                }
            }
            break;
        }
        case ADD_PRODUCTPURCHASE:
        {
            if(!(parameters == nil))
            {
                if ([parameters count] == 1)
                {
                    // 0 = ProductView object
                    // String to perform the post
                    postString = [NSString stringWithFormat:@"/statProductPurchase"];
                    
                    //Data object to post
                    dataObject = (ProductPurchase*)[parameters objectAtIndex:0];
                    
                    //Message to show if not succeed
                    failedAnswerErrorMessage = nil;
                }
                else
                {
                    NSLog(@"XXXX Incorrect number of parameters to perform request! XXXX");
                    
                    [self processRestConnection: connection WithErrorMessage:nil forOperation:nil];
                    
                    return;
                }
            }
            break;
        }
        case ADD_POSTVIEW:
        {
            if(!(parameters == nil))
            {
                if ([parameters count] == 1)
                {
                    // 0 = ProductView object
                    // String to perform the post
                    postString = [NSString stringWithFormat:@"/statpostview"];
                    
                    //Data object to post
                    dataObject = (FashionistaPostView*)[parameters objectAtIndex:0];
                    
                    //Message to show if not succeed
                    failedAnswerErrorMessage = nil;
                }
                else
                {
                    NSLog(@"XXXX Incorrect number of parameters to perform request! XXXX");
                    
                    [self processRestConnection: connection WithErrorMessage:nil forOperation:nil];
                    
                    return;
                }
            }
            
            break;
        }
        case ADD_POSTVIEWTIME:
        {
            if(!(parameters == nil))
            {
                if ([parameters count] == 1)
                {
                    // 0 = ProductView object
                    // String to perform the post
                    postString = [NSString stringWithFormat:@"/statPostViewTime"];
                    
                    //Data object to post
                    dataObject = (FashionistaPostViewTime*)[parameters objectAtIndex:0];
                    
                    //Message to show if not succeed
                    failedAnswerErrorMessage = nil;
                }
                else
                {
                    NSLog(@"XXXX Incorrect number of parameters to perform request! XXXX");
                    
                    [self processRestConnection: connection WithErrorMessage:nil forOperation:nil];
                    
                    return;
                }
            }
            
            break;        }
        case ADD_POSTSHARED:
        {
            if(!(parameters == nil))
            {
                if ([parameters count] == 1)
                {
                    // 0 = ProductView object
                    // String to perform the post
                    postString = [NSString stringWithFormat:@"/statPostShared"];
                    
                    //Data object to post
                    dataObject = (FashionistaPostShared*)[parameters objectAtIndex:0];
                    
                    //Message to show if not succeed
                    failedAnswerErrorMessage = nil;
                }
                else
                {
                    NSLog(@"XXXX Incorrect number of parameters to perform request! XXXX");
                    
                    [self processRestConnection: connection WithErrorMessage:nil forOperation:nil];
                    
                    return;
                }
            }
            
            break;
        }
        case ADD_FASHIONISTAVIEW:
        {
            if(!(parameters == nil))
            {
                if ([parameters count] == 1)
                {
                    // 0 = ProductView object
                    // String to perform the post
                    postString = [NSString stringWithFormat:@"/statFashionistaView"];
                    
                    //Data object to post
                    dataObject = (FashionistaView*)[parameters objectAtIndex:0];
                    
                    //Message to show if not succeed
                    failedAnswerErrorMessage = nil;
                }
                else
                {
                    NSLog(@"XXXX Incorrect number of parameters to perform request! XXXX");
                    
                    [self processRestConnection: connection WithErrorMessage:nil forOperation:nil];
                    
                    return;
                }
            }
            
            break;
        }
        case ADD_FASHIONISTAVIEWTIME:
        {
            if(!(parameters == nil))
            {
                if ([parameters count] == 1)
                {
                    // 0 = ProductView object
                    // String to perform the post
                    postString = [NSString stringWithFormat:@"/statFashionistaViewTime"];
                    
                    //Data object to post
                    dataObject = (FashionistaViewTime*)[parameters objectAtIndex:0];
                    
                    //Message to show if not succeed
                    failedAnswerErrorMessage = nil;
                }
                else
                {
                    NSLog(@"XXXX Incorrect number of parameters to perform request! XXXX");
                    
                    [self processRestConnection: connection WithErrorMessage:nil forOperation:nil];
                    
                    return;
                }
            }
            
            break;
        }
        case ADD_WARDROBEVIEW:
        {
            if(!(parameters == nil))
            {
                if ([parameters count] == 1)
                {
                    // 0 = ProductView object
                    // String to perform the post
                    postString = [NSString stringWithFormat:@"/statWardrobeView"];
                    
                    //Data object to post
                    dataObject = (WardrobeView*)[parameters objectAtIndex:0];
                    
                    //Message to show if not succeed
                    failedAnswerErrorMessage = nil;
                }
                else
                {
                    NSLog(@"XXXX Incorrect number of parameters to perform request! XXXX");
                    
                    [self processRestConnection: connection WithErrorMessage:nil forOperation:nil];
                    
                    return;
                }
            }
            
            break;
        }
        case ADD_COMMENTVIEW:
        {
            if(!(parameters == nil))
            {
                if ([parameters count] == 1)
                {
                    // 0 = ProductView object
                    // String to perform the post
                    postString = [NSString stringWithFormat:@"/statCommentView"];
                    
                    //Data object to post
                    dataObject = (CommentView*)[parameters objectAtIndex:0];
                    
                    //Message to show if not succeed
                    failedAnswerErrorMessage = nil;
                }
                else
                {
                    NSLog(@"XXXX Incorrect number of parameters to perform request! XXXX");
                    
                    [self processRestConnection: connection WithErrorMessage:nil forOperation:nil];
                    
                    return;
                }
            }
            
            break;
        }
        case ADD_REVIEWPRODUCTVIEW:
        {
            if(!(parameters == nil))
            {
                if ([parameters count] == 1)
                {
                    // 0 = ProductView object
                    // String to perform the post
                    postString = [NSString stringWithFormat:@"/statreviewproductview"];
                    
                    //Data object to post
                    dataObject = (ReviewProductView*)[parameters objectAtIndex:0];
                    
                    //Message to show if not succeed
                    failedAnswerErrorMessage = nil;
                }
                else
                {
                    NSLog(@"XXXX Incorrect number of parameters to perform request! XXXX");
                    
                    [self processRestConnection: connection WithErrorMessage:nil forOperation:nil];
                    
                    return;
                }
            }
            
            break;
        }
        case ADD_WARDROBE:
        {
            if(!(parameters == nil))
            {
                if ([parameters count] == 1)
                {
                    // 0 = Wardrobe object
                    // String to perform the post
                    postString = [NSString stringWithFormat:@"/wardrobe"];
                    
                    //Data object to post
                    dataObject = (Wardrobe*)[parameters objectAtIndex:0];
                    
                    //Message to show if not succeed
                    failedAnswerErrorMessage = [NSArray arrayWithObjects:NSLocalizedString(@"_ERROR_", nil), NSLocalizedString(@"_NO_WARDROBECREATION_ERROR_MSG_", nil), NSLocalizedString(@"_OK_", nil), nil];
                    
                }
                else
                {
                    NSLog(@"XXXX Incorrect number of parameters to perform request! XXXX");
                    
                    [self processRestConnection: connection WithErrorMessage:nil forOperation:nil];
                    
                    return;
                }
            }
            
            break;
        }
        case UPDATE_ITEM_TO_WARDROBE:
        {
            if(!(parameters == nil))
            {
                if ([parameters count] == 2)
                {
                    // 0 = Wardrobe Id; 1 = Product object
                    // String to perform the post
                    postString = [NSString stringWithFormat:@"/ResultQuery/%@", (NSString*)([((GSBaseElement*)([parameters objectAtIndex:1])) idGSBaseElement])];
                    
                    //Data object to post
                    dataObject = (GSBaseElement*)[parameters objectAtIndex:1];
                    
                    //Message to show if not succeed
                    failedAnswerErrorMessage = [NSArray arrayWithObjects:NSLocalizedString(@"_ERROR_", nil), NSLocalizedString(@"_NO_ITEMINSERTIONINWARDROBE_ERROR_MSG_", nil), NSLocalizedString(@"_OK_", nil), nil];
                }
                else
                {
                    NSLog(@"XXXX Incorrect number of parameters to perform request! XXXX");
                    
                    [self processRestConnection: connection WithErrorMessage:nil forOperation:nil];
                    
                    return;
                }
            }
            break;
        }
        case ADD_ITEM_TO_WARDROBE:
        {
            if(!(parameters == nil))
            {
                if ([parameters count] == 2)
                {
                    // 0 = Wardrobe Id; 1 = Product object
                    // String to perform the post
                    GSBaseElement *element = [parameters objectAtIndex:1];
                    postString = [NSString stringWithFormat:@"/wardrobe/%@/addElement/%@", (NSString*)[parameters objectAtIndex:0], element.idGSBaseElement];
                    
                    //Data object to post
                    dataObject = (GSBaseElement*)[parameters objectAtIndex:1];
                    
                    //Message to show if not succeed
                    failedAnswerErrorMessage = [NSArray arrayWithObjects:NSLocalizedString(@"_ERROR_", nil), NSLocalizedString(@"_NO_ITEMINSERTIONINWARDROBE_ERROR_MSG_", nil), NSLocalizedString(@"_OK_", nil), nil];
                }
                else
                {
                    NSLog(@"XXXX Incorrect number of parameters to perform request! XXXX");
                    
                    [self processRestConnection: connection WithErrorMessage:nil forOperation:nil];
                    
                    return;
                }
            }
            
            
            //  _productToAdd = nil; IF ERROR!!
            
            break;
        }
        case ADD_POST_TO_WARDROBE:
        {
            if(!(parameters == nil))
            {
                if ([parameters count] == 2)
                {
                    // 0 = Wardrobe Id; 1 = Product object
                    // String to perform the post
                    postString = [NSString stringWithFormat:@"/wardrobe/%@/addFashionistaPost/%@", (NSString*)[parameters objectAtIndex:0], (NSString*)([((FashionistaPost*)([parameters objectAtIndex:1])) idFashionistaPost])];
                    
                    //Data object to post
                    dataObject = (GSBaseElement*)[parameters objectAtIndex:1];
                    
                    //Message to show if not succeed
                    failedAnswerErrorMessage = [NSArray arrayWithObjects:NSLocalizedString(@"_ERROR_", nil), NSLocalizedString(@"_NO_ITEMINSERTIONINWARDROBE_ERROR_MSG_", nil), NSLocalizedString(@"_OK_", nil), nil];
                }
                else
                {
                    NSLog(@"XXXX Incorrect number of parameters to perform request! XXXX");
                    
                    [self processRestConnection: connection WithErrorMessage:nil forOperation:nil];
                    
                    return;
                }
            }
            
            break;
        }
        case ADD_KEYWORD_TO_CONTENT:
        {
            if(!(parameters == nil))
            {
                if ([parameters count] == 1)
                {
                    //                    // 0 = Content; 1 = Keyword
                    //                    // String to perform the post
                    //                    postString = [NSString stringWithFormat:@"/fashionistaPostContent/%@/keywords", (NSString*)([((FashionistaContent*)([parameters objectAtIndex:0])) idFashionistaContent])/*, (NSString*)([((Keyword*)([parameters objectAtIndex:1])) idKeyword])*/];
                    //
                    //                    //Data object to post
                    //                    dataObject = (KeywordFashionistaContent*)[parameters objectAtIndex:1];
                    
                    postString = [NSString stringWithFormat:@"/fashionistapostcontent_keywords__keyword_fashionistapostcontents"];
                    
                    //Data object to post
                    dataObject = (KeywordFashionistaContent*)[parameters objectAtIndex:0];
                    
                    //Message to show if not succeed
                    failedAnswerErrorMessage = [NSArray arrayWithObjects:NSLocalizedString(@"_ERROR_", nil), NSLocalizedString(@"_NO_KEYWORDADDITIONTOCONTENT_ERROR_MSG_", nil), NSLocalizedString(@"_OK_", nil), nil];
                }
                else
                {
                    NSLog(@"XXXX Incorrect number of parameters to perform request! XXXX");
                    
                    [self processRestConnection: connection WithErrorMessage:nil forOperation:nil];
                    
                    return;
                }
            }
            
            break;
        }
    /****
     Osama Petran
     update KeywordFashionistaContent
     ****/
        case UPDATE_KEYWORD_TO_CONTENT:
        {
            if(!(parameters == nil))
            {
                if ([parameters count] == 1)
                {
                   KeywordFashionistaContent *kconent = [parameters objectAtIndex:0];
                   
                   postString = [NSString stringWithFormat:@"/fashionistapostcontent_keywords__keyword_fashionistapostcontents/%@", kconent.idKeywordFashionistaContent];
                    
                    //Data object to post
                    dataObject = (KeywordFashionistaContent*)[parameters objectAtIndex:0];
                    
                    //Message to show if not succeed
                    failedAnswerErrorMessage = [NSArray arrayWithObjects:NSLocalizedString(@"_ERROR_", nil), NSLocalizedString(@"_NO_KEYWORDADDITIONTOCONTENT_ERROR_MSG_", nil), NSLocalizedString(@"_OK_", nil), nil];
                }
                else
                {
                    NSLog(@"XXXX Incorrect number of parameters to perform request! XXXX");
                    
                    [self processRestConnection: connection WithErrorMessage:nil forOperation:nil];
                    
                    return;
                }
            }
            
            break;
        }
        case UPDATE_WARDROBE_NAME:
        {
            if(!(parameters == nil))
            {
                if ([parameters count] == 2)
                {
                    // 0 = Wardrobe Id; 1 = Wardrobe object with new name
                    // String to perform the post
                    postString = [NSString stringWithFormat:@"/wardrobe/%@", (NSString*)[parameters objectAtIndex:0]];
                    
                    //Data object to post
                    dataObject = (Wardrobe*)[parameters objectAtIndex:1];
                    
                    //Message to show if not succeed
                    failedAnswerErrorMessage = [NSArray arrayWithObjects:NSLocalizedString(@"_ERROR_", nil), NSLocalizedString(@"_NO_WARDROBECREATION_ERROR_MSG_", nil), NSLocalizedString(@"_OK_", nil), nil];
                }
                else
                {
                    NSLog(@"XXXX Incorrect number of parameters to perform request! XXXX");
                    
                    [self processRestConnection: connection WithErrorMessage:nil forOperation:nil];
                    
                    return;
                }
            }
            
            break;
        }
        case ADD_REVIEW_TO_PRODUCT:
        {
            if(!(parameters == nil))
            {
                if ([parameters count] == 2)
                {
                    // 0 = Product Id; 1 = Review object
                    // String to perform the post
                    postString = [NSString stringWithFormat:@"/review"];
                    
                    //Data object to post
                    dataObject = (Review*)[parameters objectAtIndex:1];
                    
                    //Message to show if not succeed
                    failedAnswerErrorMessage = [NSArray arrayWithObjects:NSLocalizedString(@"_ERROR_", nil), NSLocalizedString(@"_NO_REVIEWCREATION_ERROR_MSG_", nil), NSLocalizedString(@"_OK_", nil), nil];
                }
                else
                {
                    NSLog(@"XXXX Incorrect number of parameters to perform request! XXXX");
                    
                    [self processRestConnection: connection WithErrorMessage:nil forOperation:nil];
                    
                    return;
                }
            }
            
            break;
        }
        case UPLOAD_FASHIONISTAPAGE:
        {
            if(!(parameters == nil))
            {
                if ([parameters count] == 2)
                {
                    // 0 = FashionistaPage object; 1 = TRUE is it's updating, FALSE if it's creating
                    // String to perform the post
                    if([((NSNumber *)[parameters objectAtIndex:1]) boolValue] == YES)
                    {
                        postString = [NSString stringWithFormat:@"/fashionistapage/%@", [((FashionistaPage*)[parameters objectAtIndex:0]) idFashionistaPage]];
                    }
                    else
                    {
                        postString = [NSString stringWithFormat:@"/fashionistapage"];
                    }
                    
                    //Data object to post
                    dataObject = (FashionistaPage*)[parameters objectAtIndex:0];
                    
                    //Message to show if not succeed
                    failedAnswerErrorMessage = [NSArray arrayWithObjects:NSLocalizedString(@"_ERROR_", nil), NSLocalizedString(@"_NO_FASHIONISTAPAGEUPLOAD_ERROR_MSG_", nil), NSLocalizedString(@"_OK_", nil), nil];
                }
                else
                {
                    NSLog(@"XXXX Incorrect number of parameters to perform request! XXXX");
                    
                    [self processRestConnection: connection WithErrorMessage:nil forOperation:nil];
                    
                    return;
                }
            }
            
            break;
        }
        case UPLOAD_FASHIONISTAPAGE_IMAGE:
        {
            if(!(parameters == nil))
            {
                if ([parameters count] == 2)
                {
                    // 0 = Fashionista Page header image; 1 = Fashionista Page Id
                    NSString * sError = [NSString stringWithFormat:@"%@\n\n%@", NSLocalizedString(@"_NO_FASHIONISTAPAGEUPLOAD_ERROR_MSG_", nil),NSLocalizedString(@"_CHECK_CONNECTION_", nil)];
                    
                    //Message to show if no results were provided
                    failedAnswerErrorMessage = [NSArray arrayWithObjects:NSLocalizedString(@"_ERROR_", nil), sError, NSLocalizedString(@"_OK_", nil), nil];
                    
                    //Message to show if no results were provided
                    //                    failedAnswerErrorMessage = [NSArray arrayWithObjects:NSLocalizedString(@"_ERROR_", nil), NSLocalizedString(@"_NO_FASHIONISTAPAGEUPLOAD_ERROR_MSG_", nil), NSLocalizedString(@"_OK_", nil), nil];
                    
                    // Serialize the Article attributes then attach a file
                    NSMutableURLRequest *request = [[RKObjectManager sharedManager] multipartFormRequestWithObject:nil
                                                                                                            method:RKRequestMethodPOST
                                                                                                              path:[NSString stringWithFormat:@"/fashionistapage/%@/upload-coverimage", [parameters objectAtIndex:1]]
                                                                                                        parameters:nil
                                                                                         constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
                                                                                             [formData appendPartWithFileData:UIImageJPEGRepresentation((UIImage*)[parameters objectAtIndex:0], 0.5)
                                                                                                                         name:@"coverimage"
                                                                                                                     fileName:@"header_image.jpg"
                                                                                                                     mimeType:@"image/jpg"];
                                                                                         }];
                    
                    RKObjectRequestOperation *operation = [[RKObjectManager sharedManager] objectRequestOperationWithRequest:request
                                                                                                                     success:^(RKObjectRequestOperation * operation, RKMappingResult * mappingResult)
                                                           {
                                                               // If the GS server provided an answer, check wheter that answer could be mapped into our data classes
                                                               
                                                               [self processAnswerToRestConnection:connection WithResult:[mappingResult array] lookingForClasses:[NSArray arrayWithObjects:[FashionistaPage class], nil] andIfErrorMessage:failedAnswerErrorMessage];
                                                           }
                                                                                                                     failure:^(RKObjectRequestOperation * operation, NSError *error)
                                                           {
                                                               //Message to show if no results were provided
                                                               NSArray *errorMessage = [NSArray arrayWithObjects:NSLocalizedString(@"_ERROR_", nil), NSLocalizedString(@"_NO_FASHIONISTAPAGEHEADERIMAGEUPLOAD_ERROR_MSG_", nil), NSLocalizedString(@"_OK_", nil), nil];
                                                               
                                                               // If 'failedAnswerErrorMessage' is nil, it means that we don't want to provide messages to the user
                                                               if(failedAnswerErrorMessage == nil)
                                                               {
                                                                   errorMessage = nil;
                                                               }
                                                               
                                                               if (bRetrying == NO)
                                                               {
                                                                   
                                                                   [self processRestConnection: connection WithErrorMessage:errorMessage forOperation:operation];
                                                               }
                                                               else
                                                               {
                                                                   [self askRetryingPostForConnection:connection withParameters:parameters withErrorMessage:errorMessage forOperation:operation];
                                                               }
                                                           }];
                    
                    [[RKObjectManager sharedManager] enqueueObjectRequestOperation:operation]; // NOTE: Must be enqueued rather than started
                }
                else
                {
                    NSLog(@"XXXX Incorrect number of parameters to perform request! XXXX");
                    
                    [self processRestConnection: connection WithErrorMessage:nil forOperation:nil];
                    
                    return;
                }
                
                return;
            }
            
            
            break;
        }
        case UPLOAD_FASHIONISTAPOST:
        case UPLOAD_FASHIONISTAPOST_LOCATION:
        {
            if(!(parameters == nil))
            {
                if ([parameters count] == 2)
                {
                    // 0 = FashionistaPost object; 1 = TRUE is it's updating, FALSE if it's creating
                    // String to perform the post
                    if([((NSNumber *)[parameters objectAtIndex:1]) boolValue] == YES)
                    {
                        postString = [NSString stringWithFormat:@"/fashionistapost/%@", [((FashionistaPost*)[parameters objectAtIndex:0]) idFashionistaPost]];
                    }
                    else
                    {
                        postString = [NSString stringWithFormat:@"/fashionistapost"];
                    }
                    
                    //Data object to post
                    dataObject = (FashionistaPost*)[parameters objectAtIndex:0];
                    
                    //Message to show if not succeed
                    failedAnswerErrorMessage = [NSArray arrayWithObjects:NSLocalizedString(@"_ERROR_", nil), NSLocalizedString(@"_NO_FASHIONISTAPOSTUPLOAD_ERROR_MSG_", nil), NSLocalizedString(@"_OK_", nil), nil];
                }
                else
                {
                    NSLog(@"XXXX Incorrect number of parameters to perform request! XXXX");
                    
                    [self processRestConnection: connection WithErrorMessage:nil forOperation:nil];
                    
                    return;
                }
            }
            
            break;
        }
        case UPLOAD_FASHIONISTAPOST_FORSHARE:
        {
            if(!(parameters == nil))
            {
                if ([parameters count] == 2)
                {
                    // 0 = FashionistaPost object; 1 = TRUE is it's updating, FALSE if it's creating
                    // String to perform the post
                    if([((NSNumber *)[parameters objectAtIndex:1]) boolValue] == YES)
                    {
                        postString = [NSString stringWithFormat:@"/fashionistapost/%@", [((FashionistaPost*)[parameters objectAtIndex:0]) idFashionistaPost]];
                    }
                    else
                    {
                        postString = [NSString stringWithFormat:@"/fashionistapost"];
                    }
                    
                    //Data object to post
                    dataObject = (FashionistaPost*)[parameters objectAtIndex:0];
                    
                    //Message to show if not succeed
                    failedAnswerErrorMessage = [NSArray arrayWithObjects:NSLocalizedString(@"_ERROR_", nil), NSLocalizedString(@"_NO_FASHIONISTAPOSTUPLOAD_ERROR_MSG_", nil), NSLocalizedString(@"_OK_", nil), nil];
                }
                else
                {
                    NSLog(@"XXXX Incorrect number of parameters to perform request! XXXX");
                    
                    [self processRestConnection: connection WithErrorMessage:nil forOperation:nil];
                    
                    return;
                }
            }
            
            break;
        }
        case UPLOAD_FASHIONISTAPOST_PREVIEWIMAGE:
        {
            if(!(parameters == nil))
            {
                if ([parameters count] == 2)
                {
                    // 0 = Fashionista Post preview image; 1 = Fashionista Post Id
                    NSString * sError = [NSString stringWithFormat:@"%@\n\n%@", NSLocalizedString(@"_NO_FASHIONISTAPOSTUPLOAD_ERROR_MSG_", nil),NSLocalizedString(@"_CHECK_CONNECTION_", nil)];
                    
                    //Message to show if no results were provided
                    failedAnswerErrorMessage = [NSArray arrayWithObjects:NSLocalizedString(@"_ERROR_", nil), sError, NSLocalizedString(@"_OK_", nil), nil];
                    //
                    //                    //Message to show if no results were provided
                    //                    failedAnswerErrorMessage = [NSArray arrayWithObjects:NSLocalizedString(@"_ERROR_", nil), NSLocalizedString(@"_NO_FASHIONISTAPOSTUPLOAD_ERROR_MSG_", nil), NSLocalizedString(@"_OK_", nil), nil];
                    
                    // Serialize the Article attributes then attach a file
                    NSMutableURLRequest *request = [[RKObjectManager sharedManager] multipartFormRequestWithObject:nil
                                                                                                            method:RKRequestMethodPOST
                                                                                                              path:[NSString stringWithFormat:@"/fashionistapost/%@/upload-coverimage", [parameters objectAtIndex:1]]
                                                                                                        parameters:nil
                                                                                         constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
                                                                                             [formData appendPartWithFileData:UIImageJPEGRepresentation((UIImage*)[parameters objectAtIndex:0], 0.5)
                                                                                                                         name:@"coverimage"
                                                                                                                     fileName:@"header_image.jpg"
                                                                                                                     mimeType:@"image/jpg"];
                                                                                         }];
                    
                    RKObjectRequestOperation *operation = [[RKObjectManager sharedManager] objectRequestOperationWithRequest:request
                                                                                                                     success:^(RKObjectRequestOperation * operation, RKMappingResult * mappingResult)
                                                           {
                                                               // If the GS server provided an answer, check wheter that answer could be mapped into our data classes
                                                               
                                                               [self processAnswerToRestConnection:connection WithResult:[mappingResult array] lookingForClasses:[NSArray arrayWithObjects:[FashionistaPost class], nil] andIfErrorMessage:failedAnswerErrorMessage];
                                                           }
                                                                                                                     failure:^(RKObjectRequestOperation * operation, NSError *error)
                                                           {
                                                               //Message to show if no results were provided
                                                               NSArray *errorMessage = [NSArray arrayWithObjects:NSLocalizedString(@"_ERROR_", nil), NSLocalizedString(@"_NO_FASHIONISTAPOSTPREVIEWIMAGEUPLOAD_ERROR_MSG_", nil), NSLocalizedString(@"_OK_", nil), nil];
                                                               
                                                               // If 'failedAnswerErrorMessage' is nil, it means that we don't want to provide messages to the user
                                                               if(failedAnswerErrorMessage == nil)
                                                               {
                                                                   errorMessage = nil;
                                                               }
                                                               
                                                               if (bRetrying == NO)
                                                               {
                                                                   
                                                                   [self processRestConnection: connection WithErrorMessage:errorMessage forOperation:operation];
                                                               }
                                                               else
                                                               {
                                                                   [self askRetryingPostForConnection:connection withParameters:parameters withErrorMessage:errorMessage forOperation:operation];
                                                               }
                                                           }];
                    
                    [[RKObjectManager sharedManager] enqueueObjectRequestOperation:operation]; // NOTE: Must be enqueued rather than started
                }
                else
                {
                    NSLog(@"XXXX Incorrect number of parameters to perform request! XXXX");
                    
                    [self processRestConnection: connection WithErrorMessage:nil forOperation:nil];
                    
                    return;
                }
                
                return;
            }
            
            
            break;
        }
        case UPLOAD_FASHIONISTACONTENT:
        {
            if(!(parameters == nil))
            {
                if ([parameters count] == 2)
                {
                    // 0 = FashionistaContent object; 1 = TRUE is it's updating, FALSE if it's creating
                    // String to perform the post
                    if([((NSNumber *)[parameters objectAtIndex:1]) boolValue] == YES)
                    {
                        postString = [NSString stringWithFormat:@"/fashionistaPostContent/%@", [((FashionistaContent*)[parameters objectAtIndex:0]) idFashionistaContent]];
                    }
                    else
                    {
                        postString = [NSString stringWithFormat:@"/fashionistaPostContent"];
                    }
                    
                    //Data object to post
                    dataObject = (FashionistaContent*)[parameters objectAtIndex:0];
                    
                    //Message to show if not succeed
                    failedAnswerErrorMessage = [NSArray arrayWithObjects:NSLocalizedString(@"_ERROR_", nil), NSLocalizedString(@"_NO_FASHIONISTACONTENTUPLOAD_ERROR_MSG_", nil), NSLocalizedString(@"_OK_", nil), nil];
                }
                else
                {
                    NSLog(@"XXXX Incorrect number of parameters to perform request! XXXX");
                    
                    [self processRestConnection: connection WithErrorMessage:nil forOperation:nil];
                    
                    return;
                }
            }
            
            break;
        }
        case UPLOAD_FASHIONISTACONTENT_IMAGE:
        {
            if(!(parameters == nil))
            {
                if ([parameters count] == 2)
                {
                    // 0 = Fashionista Content image; 1 = Fashionista Content Id
                    
                    NSString * sError = [NSString stringWithFormat:@"%@\n\n%@", NSLocalizedString(@"_NO_FASHIONISTACONTENTUPLOAD_ERROR_MSG_", nil),NSLocalizedString(@"_CHECK_CONNECTION_", nil)];
                    
                    //Message to show if no results were provided
                    failedAnswerErrorMessage = [NSArray arrayWithObjects:NSLocalizedString(@"_ERROR_", nil), sError, NSLocalizedString(@"_OK_", nil), nil];
                    
                    //                    failedAnswerErrorMessage = [NSArray arrayWithObjects:NSLocalizedString(@"_ERROR_", nil), NSLocalizedString(@"_NO_FASHIONISTACONTENTUPLOAD_ERROR_MSG_", nil), NSLocalizedString(@"_OK_", nil), nil];
                    
                    
                    // Serialize the Article attributes then attach a file
                    NSMutableURLRequest *request = [[RKObjectManager sharedManager] multipartFormRequestWithObject:nil
                                                                                                            method:RKRequestMethodPOST
                                                                                                              path:[NSString stringWithFormat:@"/fashionistaPostContent/%@/upload-image", [parameters objectAtIndex:1]]
                                                                                                        parameters:nil
                                                                                         constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
                                                                                             [formData appendPartWithFileData:UIImageJPEGRepresentation((UIImage*)[parameters objectAtIndex:0], 0.5)
                                                                                                                         name:@"image"
                                                                                                                     fileName:@"content_image.jpg"
                                                                                                                     mimeType:@"image/jpg"];
                                                                                         }];
                    
                    RKObjectRequestOperation *operation = [[RKObjectManager sharedManager] objectRequestOperationWithRequest:request
                                                                                                                     success:^(RKObjectRequestOperation * operation, RKMappingResult * mappingResult)
                                                           {
                                                               // If the GS server provided an answer, check wheter that answer could be mapped into our data classes
                                                               
                                                               [self processAnswerToRestConnection:connection WithResult:[mappingResult array] lookingForClasses:[NSArray arrayWithObjects:[FashionistaPage class], nil] andIfErrorMessage:failedAnswerErrorMessage];
                                                           }
                                                                                                                     failure:^(RKObjectRequestOperation * operation, NSError *error)
                                                           {
                                                               //Message to show if no results were provided
                                                               NSArray *errorMessage = [NSArray arrayWithObjects:NSLocalizedString(@"_ERROR_", nil), NSLocalizedString(@"_NO_FASHIONISTACONTENTIMAGEUPLOAD_ERROR_MSG_", nil), NSLocalizedString(@"_OK_", nil), nil];
                                                               
                                                               // If 'failedAnswerErrorMessage' is nil, it means that we don't want to provide messages to the user
                                                               if(failedAnswerErrorMessage == nil)
                                                               {
                                                                   errorMessage = nil;
                                                               }
                                                               
                                                               if (bRetrying == NO)
                                                               {
                                                                   
                                                                   [self processRestConnection: connection WithErrorMessage:errorMessage forOperation:operation];
                                                               }
                                                               else
                                                               {
#ifndef _OSAMA_
                                                                   [[NSNotificationCenter defaultCenter] postNotificationName:@"FailedItemToWardrobeNotification" object:self];
#endif
                                                                   [self askRetryingPostForConnection:connection withParameters:parameters withErrorMessage:failedAnswerErrorMessage forOperation:operation];
                                                               }
                                                           }];
                    
                    [[RKObjectManager sharedManager] enqueueObjectRequestOperation:operation]; // NOTE: Must be enqueued rather than started
                }
                else
                {
                    NSLog(@"XXXX Incorrect number of parameters to perform request! XXXX");
                    
                    [self processRestConnection: connection WithErrorMessage:nil forOperation:nil];
                    
                    return;
                }
                
                return;
            }
            
            
            break;
        }
        case ADD_COMMENT_TO_POST:
        {
            if(!(parameters == nil))
            {
                if ([parameters count] >= 2)
                {
                    // 0 = Post Id; 1 = Comment object
                    // String to perform the post
                    //Data object to post
                    dataObject = (Comment*)[parameters objectAtIndex:1];
                    
                    if([parameters count]>=3){
                        postString = [NSString stringWithFormat:@"/comment/%@",[(Comment*)dataObject idComment]];
                    }else{
                        postString = [NSString stringWithFormat:@"/comment"];
                    }
                    
                    
                    //Message to show if not succeed
                    failedAnswerErrorMessage = [NSArray arrayWithObjects:NSLocalizedString(@"_ERROR_", nil), NSLocalizedString(@"_NO_COMMENTCREATION_ERROR_MSG_", nil), NSLocalizedString(@"_OK_", nil), nil];
                }
                else
                {
                    NSLog(@"XXXX Incorrect number of parameters to perform request! XXXX");
                    
                    [self processRestConnection: connection WithErrorMessage:nil forOperation:nil];
                    
                    return;
                }
            }
            
            break;
        }
        case UPLOAD_REVIEW_VIDEO:
        {
            if(!(parameters == nil))
            {
                if ([parameters count] == 2)
                {
                    // 0 = Fashionista Content image; 1 = Fashionista Content Id
                    
                    NSString * sError = [NSString stringWithFormat:@"%@\n\n%@", NSLocalizedString(@"_NO_REVIEWVIDEO_ERROR_MSG_", nil),NSLocalizedString(@"_CHECK_CONNECTION_", nil)];
                    
                    //Message to show if no results were provided
                    failedAnswerErrorMessage = [NSArray arrayWithObjects:NSLocalizedString(@"_ERROR_", nil), sError, NSLocalizedString(@"_OK_", nil), nil];
                    
                    //                    //Message to show if no results were provided
                    //                    failedAnswerErrorMessage = [NSArray arrayWithObjects:NSLocalizedString(@"_ERROR_", nil), NSLocalizedString(@"_NO_REVIEWVIDEO_ERROR_MSG_", nil), NSLocalizedString(@"_OK_", nil), nil];
                    
                    // Serialize the Article attributes then attach a file
                    NSMutableURLRequest *request = [[RKObjectManager sharedManager] multipartFormRequestWithObject:nil
                                                                                                            method:RKRequestMethodPOST
                                                                                                              path:[NSString stringWithFormat:@"/review/%@/upload-video", [parameters objectAtIndex:1]]
                                                                                                        parameters:nil
                                                                                         constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
                                                                                             [formData appendPartWithFileData:(NSData*)[parameters objectAtIndex:0]
                                                                                                                         name:@"video"
                                                                                                                     fileName:@"content_video.m4v"
                                                                                                                     mimeType:@"video/mp4"];
                                                                                         }];
                    
                    RKObjectRequestOperation *operation = [[RKObjectManager sharedManager] objectRequestOperationWithRequest:request
                                                                                                                     success:^(RKObjectRequestOperation * operation, RKMappingResult * mappingResult)
                                                           {
                                                               // If the GS server provided an answer, check wheter that answer could be mapped into our data classes
                                                               
                                                               [self processAnswerToRestConnection:connection WithResult:[mappingResult array] lookingForClasses:[NSArray arrayWithObjects:[FashionistaPage class], nil] andIfErrorMessage:failedAnswerErrorMessage];
                                                           }
                                                                                                                     failure:^(RKObjectRequestOperation * operation, NSError *error)
                                                           {
                                                               //Message to show if no results were provided
                                                               NSArray *errorMessage = [NSArray arrayWithObjects:NSLocalizedString(@"_ERROR_", nil), NSLocalizedString(@"_NO_REVIEWVIDEO_ERROR_MSG_", nil), NSLocalizedString(@"_OK_", nil), nil];
                                                               
                                                               // If 'failedAnswerErrorMessage' is nil, it means that we don't want to provide messages to the user
                                                               if(failedAnswerErrorMessage == nil)
                                                               {
                                                                   errorMessage = nil;
                                                               }
                                                               
                                                               if (bRetrying == NO)
                                                               {
                                                                   
                                                                   [self processRestConnection: connection WithErrorMessage:errorMessage forOperation:operation];
                                                               }
                                                               else
                                                               {
                                                                   [self askRetryingPostForConnection:connection withParameters:parameters withErrorMessage:errorMessage forOperation:operation];
                                                               }
                                                           }];
                    
                    [[RKObjectManager sharedManager] enqueueObjectRequestOperation:operation]; // NOTE: Must be enqueued rather than started
                }
                else
                {
                    NSLog(@"XXXX Incorrect number of parameters to perform request! XXXX");
                    
                    [self processRestConnection: connection WithErrorMessage:nil forOperation:nil];
                    
                    return;
                }
                
                return;
            }
            
            
            break;
        }
        case UPLOAD_FASHIONISTACONTENT_VIDEO:
        {
            if(!(parameters == nil))
            {
                if ([parameters count] == 2)
                {
                    // 0 = Fashionista Content image; 1 = Fashionista Content Id
                    NSString * sError = [NSString stringWithFormat:@"%@\n\n%@", NSLocalizedString(@"_NO_FASHIONISTACONTENTUPLOAD_ERROR_MSG_", nil),NSLocalizedString(@"_CHECK_CONNECTION_", nil)];
                    
                    //Message to show if no results were provided
                    failedAnswerErrorMessage = [NSArray arrayWithObjects:NSLocalizedString(@"_ERROR_", nil), sError, NSLocalizedString(@"_OK_", nil), nil];
                    
                    //                    //Message to show if no results were provided
                    //                    failedAnswerErrorMessage = [NSArray arrayWithObjects:NSLocalizedString(@"_ERROR_", nil), NSLocalizedString(@"_NO_FASHIONISTACONTENTUPLOAD_ERROR_MSG_", nil), NSLocalizedString(@"_OK_", nil), nil];
                    
                    // Serialize the Article attributes then attach a file
                    NSMutableURLRequest *request = [[RKObjectManager sharedManager] multipartFormRequestWithObject:nil
                                                                                                            method:RKRequestMethodPOST
                                                                                                              path:[NSString stringWithFormat:@"/fashionistaPostContent/%@/upload-video", [parameters objectAtIndex:1]]
                                                                                                        parameters:nil
                                                                                         constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
                                                                                             [formData appendPartWithFileData:(NSData*)[parameters objectAtIndex:0]
                                                                                                                         name:@"video"
                                                                                                                     fileName:@"content_video.m4v"
                                                                                                                     mimeType:@"video/mp4"];
                                                                                         }];
                    
                    RKObjectRequestOperation *operation = [[RKObjectManager sharedManager] objectRequestOperationWithRequest:request
                                                                                                                     success:^(RKObjectRequestOperation * operation, RKMappingResult * mappingResult)
                                                           {
                                                               // If the GS server provided an answer, check wheter that answer could be mapped into our data classes
                                                               
                                                               [self processAnswerToRestConnection:connection WithResult:[mappingResult array] lookingForClasses:[NSArray arrayWithObjects:[FashionistaPage class], nil] andIfErrorMessage:failedAnswerErrorMessage];
                                                           }
                                                                                                                     failure:^(RKObjectRequestOperation * operation, NSError *error)
                                                           {
                                                               //Message to show if no results were provided
                                                               NSArray *errorMessage = [NSArray arrayWithObjects:NSLocalizedString(@"_ERROR_", nil), NSLocalizedString(@"_NO_FASHIONISTACONTENTIMAGEUPLOAD_ERROR_MSG_", nil), NSLocalizedString(@"_OK_", nil), nil];
                                                               
                                                               // If 'failedAnswerErrorMessage' is nil, it means that we don't want to provide messages to the user
                                                               if(failedAnswerErrorMessage == nil)
                                                               {
                                                                   errorMessage = nil;
                                                               }
                                                               
                                                               if (bRetrying == NO)
                                                               {
                                                                   
                                                                   [self processRestConnection: connection WithErrorMessage:errorMessage forOperation:operation];
                                                               }
                                                               else
                                                               {
                                                                   [self askRetryingPostForConnection:connection withParameters:parameters withErrorMessage:errorMessage forOperation:operation];
                                                               }
                                                           }];
                    
                    [[RKObjectManager sharedManager] enqueueObjectRequestOperation:operation]; // NOTE: Must be enqueued rather than started
                }
                else
                {
                    NSLog(@"XXXX Incorrect number of parameters to perform request! XXXX");
                    
                    [self processRestConnection: connection WithErrorMessage:nil forOperation:nil];
                    
                    return;
                }
                
                return;
            }
            
            
            break;
        }
        case UPLOAD_COMMENT_VIDEO:
        {
            if(!(parameters == nil))
            {
                if ([parameters count] == 2)
                {
                    // 0 = Fashionista Content image; 1 = Fashionista Content Id
                    NSString * sError = [NSString stringWithFormat:@"%@\n\n%@", NSLocalizedString(@"_NO_COMMENTVIDEO_ERROR_MSG_", nil),NSLocalizedString(@"_CHECK_CONNECTION_", nil)];
                    
                    //Message to show if no results were provided
                    failedAnswerErrorMessage = [NSArray arrayWithObjects:NSLocalizedString(@"_ERROR_", nil), sError, NSLocalizedString(@"_OK_", nil), nil];
                    
                    //                    //Message to show if no results were provided
                    //                    failedAnswerErrorMessage = [NSArray arrayWithObjects:NSLocalizedString(@"_ERROR_", nil), NSLocalizedString(@"_NO_COMMENTVIDEO_ERROR_MSG_", nil), NSLocalizedString(@"_OK_", nil), nil];
                    
                    // Serialize the Article attributes then attach a file
                    NSMutableURLRequest *request = [[RKObjectManager sharedManager] multipartFormRequestWithObject:nil
                                                                                                            method:RKRequestMethodPOST
                                                                                                              path:[NSString stringWithFormat:@"/comment/%@/upload-video", [parameters objectAtIndex:1]]
                                                                                                        parameters:nil
                                                                                         constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
                                                                                             [formData appendPartWithFileData:(NSData*)[parameters objectAtIndex:0]
                                                                                                                         name:@"video"
                                                                                                                     fileName:@"content_video.m4v"
                                                                                                                     mimeType:@"video/mp4"];
                                                                                         }];
                    
                    RKObjectRequestOperation *operation = [[RKObjectManager sharedManager] objectRequestOperationWithRequest:request
                                                                                                                     success:^(RKObjectRequestOperation * operation, RKMappingResult * mappingResult)
                                                           {
                                                               // If the GS server provided an answer, check wheter that answer could be mapped into our data classes
                                                               
                                                               [self processAnswerToRestConnection:connection WithResult:[mappingResult array] lookingForClasses:[NSArray arrayWithObjects:[FashionistaPage class], nil] andIfErrorMessage:failedAnswerErrorMessage];
                                                           }
                                                                                                                     failure:^(RKObjectRequestOperation * operation, NSError *error)
                                                           {
                                                               //Message to show if no results were provided
                                                               NSArray *errorMessage = [NSArray arrayWithObjects:NSLocalizedString(@"_ERROR_", nil), NSLocalizedString(@"_NO_COMMENTVIDEO_ERROR_MSG_", nil), NSLocalizedString(@"_OK_", nil), nil];
                                                               
                                                               // If 'failedAnswerErrorMessage' is nil, it means that we don't want to provide messages to the user
                                                               if(failedAnswerErrorMessage == nil)
                                                               {
                                                                   errorMessage = nil;
                                                               }
                                                               
                                                               if (bRetrying == NO)
                                                               {
                                                                   
                                                                   [self processRestConnection: connection WithErrorMessage:errorMessage forOperation:operation];
                                                               }
                                                               else
                                                               {
                                                                   [self askRetryingPostForConnection:connection withParameters:parameters withErrorMessage:errorMessage forOperation:operation];
                                                               }
                                                           }];
                    
                    [[RKObjectManager sharedManager] enqueueObjectRequestOperation:operation]; // NOTE: Must be enqueued rather than started
                }
                else
                {
                    NSLog(@"XXXX Incorrect number of parameters to perform request! XXXX");
                    
                    [self processRestConnection: connection WithErrorMessage:nil forOperation:nil];
                    
                    return;
                }
                
                return;
            }
            
            
            break;
        }
        case ADD_WARDROBE_TO_CONTENT:
        {
            if(!(parameters == nil))
            {
                if ([parameters count] == 2)
                {
                    // 0 = Content Id; 1 = Wardrobe object
                    // String to perform the post
                    postString = [NSString stringWithFormat:@"/fashionistaPostContent/%@/setWardrobe/%@", (NSString*)[parameters objectAtIndex:0], (NSString*)([((Wardrobe*)([parameters objectAtIndex:1])) idWardrobe])];
                    
                    //Data object to post
                    dataObject = (Wardrobe*)[parameters objectAtIndex:1];
                    
                    //Message to show if not succeed
                    failedAnswerErrorMessage = [NSArray arrayWithObjects:NSLocalizedString(@"_ERROR_", nil), NSLocalizedString(@"_NO_WARDROBEINSERTIONINCONTENT_ERROR_MSG_", nil), NSLocalizedString(@"_OK_", nil), nil];
                }
                else
                {
                    NSLog(@"XXXX Incorrect number of parameters to perform request! XXXX");
                    
                    [self processRestConnection: connection WithErrorMessage:nil forOperation:nil];
                    
                    return;
                }
            }
            
            
            //  _productToAdd = nil; IF ERROR!!
            
            break;
        }
        case FOLLOW_USER:
        {
            if(!(parameters == nil))
            {
                if ([parameters count] >= 2)
                {
                    // 0 = Follower Id; 1 = setFollow object
                    // String to perform the post
                    postString = [NSString stringWithFormat:@"/user/%@/followTo", (NSString*)[parameters objectAtIndex:0]];
                    if ([parameters count] == 4)
                    {
                        NSNumber * iTypeFollower = (NSNumber*)[parameters objectAtIndex:0];
                        if ([iTypeFollower intValue] == 0)
                        {
                            postString = [NSString stringWithFormat:@"/user/%@/followTo?post=%@", (NSString*)[parameters objectAtIndex:0], (NSString*)[parameters objectAtIndex:2]];
                        }
                        else if ([iTypeFollower intValue] == 1)
                        {
                            postString = [NSString stringWithFormat:@"/user/%@/followTo?comment=%@", (NSString*)[parameters objectAtIndex:0], (NSString*)[parameters objectAtIndex:2]];
                        }
                        else
                        {
                            postString = [NSString stringWithFormat:@"/user/%@/followTo", (NSString*)[parameters objectAtIndex:0]];
                        }
                    }
                    
                    //Data object to post
                    dataObject = (setFollow*)[parameters objectAtIndex:1];
                    
                    //Message to show if not succeed
                    failedAnswerErrorMessage = [NSArray arrayWithObjects:NSLocalizedString(@"_ERROR_", nil), NSLocalizedString(@"_NO_FOLLOW_ERROR_MSG_", nil), NSLocalizedString(@"_OK_", nil), nil];
                }
                else
                {
                    NSLog(@"XXXX Incorrect number of parameters to perform request! XXXX");
                    
                    [self processRestConnection: connection WithErrorMessage:nil forOperation:nil];
                    
                    return;
                }
            }
            
            
            //  _productToAdd = nil; IF ERROR!!
            
            break;
        }
        case UNFOLLOW_USER:
        {
            if(!(parameters == nil))
            {
                if ([parameters count] == 2)
                {
                    // 0 = Follower Id; 1 = setFollow object
                    // String to perform the post
                    postString = [NSString stringWithFormat:@"/user/%@/unfollowTo", (NSString*)[parameters objectAtIndex:0]];
                    
                    //Data object to post
                    dataObject = (unsetFollow*)[parameters objectAtIndex:1];
                    
                    //Message to show if not succeed
                    failedAnswerErrorMessage = [NSArray arrayWithObjects:NSLocalizedString(@"_ERROR_", nil), NSLocalizedString(@"_NO_UNFOLLOW_ERROR_MSG_", nil), NSLocalizedString(@"_OK_", nil), nil];
                }
                else
                {
                    NSLog(@"XXXX Incorrect number of parameters to perform request! XXXX");
                    
                    [self processRestConnection: connection WithErrorMessage:nil forOperation:nil];
                    
                    return;
                }
            }
            
            
            //  _productToAdd = nil; IF ERROR!!
            
            break;
        }
        case LIKE_POST:
        {
            if(!(parameters == nil))
            {
                if ([parameters count] == 1)
                {
                    // 0 = PostLike object
                    // String to perform the post
                    postString = [NSString stringWithFormat:@"/postlike"];
                    
                    //Data object to post
                    dataObject = (PostLike*)[parameters objectAtIndex:0];
                    
                    //Message to show if not succeed
                    failedAnswerErrorMessage = [NSArray arrayWithObjects:NSLocalizedString(@"_ERROR_", nil), NSLocalizedString(@"_NO_LIKECREATION_ERROR_MSG_", nil), NSLocalizedString(@"_OK_", nil), nil];
                }
                else
                {
                    NSLog(@"XXXX Incorrect number of parameters to perform request! XXXX");
                    
                    [self processRestConnection: connection WithErrorMessage:nil forOperation:nil];
                    
                    return;
                }
            }
            
            break;
        }
        case UPLOAD_SHARE:
        {
            if(!(parameters == nil))
            {
                if ([parameters count] == 1)
                {
                    // 0 = Share object
                    // String to perform the post
                    postString = [NSString stringWithFormat:@"/share"];
                    
                    //Data object to post
                    dataObject = (Share*)[parameters objectAtIndex:0];
                    
                    //Message to show if not succeed
                    failedAnswerErrorMessage = nil;
                }
                else
                {
                    NSLog(@"XXXX Incorrect number of parameters to perform request! XXXX");
                    
                    [self processRestConnection: connection WithErrorMessage:nil forOperation:nil];
                    
                    return;
                }
            }
            
            break;
        }
        case POST_UNFOLLOW:
        {
            if(!(parameters == nil))
            {
                if ([parameters count] == 1)
                {
                    // 0 = Share object
                    // String to perform the post
                    postString = [NSString stringWithFormat:@"/postunfollow"];
                    
                    //Data object to post
                    dataObject = (PostUserUnfollow*)[parameters objectAtIndex:0];
                    
                    //Message to show if not succeed
                    failedAnswerErrorMessage = nil;
                }
                else
                {
                    NSLog(@"XXXX Incorrect number of parameters to perform request! XXXX");
                    
                    [self processRestConnection: connection WithErrorMessage:nil forOperation:nil];
                    
                    return;
                }
            }
            break;
        }
        case POST_NO_NOTICES:
        {
            if(!(parameters == nil))
            {
                if ([parameters count] == 1)
                {
                    // 0 = Share object
                    // String to perform the post
                    postString = [NSString stringWithFormat:@"/postignorenotices"];
                    
                    //Data object to post
                    dataObject = (PostUserUnfollow*)[parameters objectAtIndex:0];
                    
                    //Message to show if not succeed
                    failedAnswerErrorMessage = nil;
                }
                else
                {
                    NSLog(@"XXXX Incorrect number of parameters to perform request! XXXX");
                    
                    [self processRestConnection: connection WithErrorMessage:nil forOperation:nil];
                    
                    return;
                }
            }
            break;
        }
        case USER_IGNORE_NOTICES:
        {
            if(!(parameters == nil))
            {
                if ([parameters count] == 1)
                {
                    // 0 = Share object
                    // String to perform the post
                    postString = [NSString stringWithFormat:@"/userignorenotices"];
                    
                    //Data object to post
                    dataObject = (UserUserUnfollow*)[parameters objectAtIndex:0];
                    
                    //Message to show if not succeed
                    failedAnswerErrorMessage = nil;
                }
                else
                {
                    NSLog(@"XXXX Incorrect number of parameters to perform request! XXXX");
                    
                    [self processRestConnection: connection WithErrorMessage:nil forOperation:nil];
                    
                    return;
                }
            }
            break;
            
            break;
        }
        case UPDATE_BASEELEMENT:
        {
            if(!(parameters == nil))
            {
                if ([parameters count] == 1)
                {
                    // 0 = Post Id; 1 = Comment object
                    // String to perform the post
                    //Data object to post
                    dataObject = (GSBaseElement*)[parameters objectAtIndex:0];
                    
                    postString = [NSString stringWithFormat:@"/resultquery/%@",[(GSBaseElement*)dataObject idGSBaseElement]];
                    
                    //Message to show if not succeed
                    failedAnswerErrorMessage = [NSArray arrayWithObjects:NSLocalizedString(@"_ERROR_", nil), NSLocalizedString(@"_NO_COMMENTCREATION_ERROR_MSG_", nil), NSLocalizedString(@"_OK_", nil), nil];
                }
                else
                {
                    NSLog(@"XXXX Incorrect number of parameters to perform request! XXXX");
                    
                    [self processRestConnection: connection WithErrorMessage:nil forOperation:nil];
                    
                    return;
                }
            }
            break;
        }
        case UPLOAD_LIVESTREAMING:
        {
            if(!(parameters == nil))
            {
                if ([parameters count] == 2)
                {
                    // 0 = LiveStreaming object; 1 = YES is it's updating, NO if it's creating
                    
                    // String to perform the post
                    if([((NSNumber *)[parameters objectAtIndex:1]) boolValue] == YES)
                    {
                        postString = [NSString stringWithFormat:@"/Livestreaming/%@", [((LiveStreaming*)[parameters objectAtIndex:0]) idLiveStreaming]];
                    }
                    else
                    {
                        postString = [NSString stringWithFormat:@"/Livestreaming"];
                    }
                    
                    //Data object to post
                    dataObject = (LiveStreaming*)[parameters objectAtIndex:0];
                    
                    //Message to show if not succeed
                    failedAnswerErrorMessage = [NSArray arrayWithObjects:NSLocalizedString(@"_ERROR_", nil), NSLocalizedString(@"_NO_LIVESTREAMINGUPLOAD_ERROR_MSG_", nil), NSLocalizedString(@"_OK_", nil), nil];
                }
            }
            else
            {
                NSLog(@"XXXX Incorrect number of parameters to perform request! XXXX");
                
                [self processRestConnection: connection WithErrorMessage:nil forOperation:nil];
                
                return;
            }

            break;
        }
        case UPLOAD_LIVESTREAMINGETHINICITY:
        {
            if(!(parameters == nil))
            {
                if ([parameters count] == 1)
                {
                    // 0 = LiveStreaming object; 1 = YES is it's updating, NO if it's creating
                    
                    postString = [NSString stringWithFormat:@"/LivestreamingEthnicity"];
                    
                    //Data object to post
                    dataObject = (LiveStreamingEthnicity*)[parameters objectAtIndex:0];
                    
                    //Message to show if not succeed
                    failedAnswerErrorMessage = [NSArray arrayWithObjects:NSLocalizedString(@"_ERROR_", nil), NSLocalizedString(@"_NO_LIVESTREAMINGETHNICITYUPLOAD_ERROR_MSG_", nil), NSLocalizedString(@"_OK_", nil), nil];
                }
            }
            else
            {
                NSLog(@"XXXX Incorrect number of parameters to perform request! XXXX");
                
                [self processRestConnection: connection WithErrorMessage:nil forOperation:nil];
                
                return;
            }
            
            break;
        }
        case ADD_LIVESTREAMINGCATEGORY_TO_LIVESTREAMING:
        {
            if(!(parameters == nil))
            {
                if ([parameters count] == 3)
                {
                    NSString *idStreaming = (NSString*)[parameters objectAtIndex:1];
                    NSString *idCategory = (NSString*)[parameters objectAtIndex:2];
                    
                    postString = [NSString stringWithFormat:@"/Livestreaming/%@/categories/%@", idStreaming, idCategory];
                    //Data object to post
                    dataObject = (LiveStreaming*)[parameters objectAtIndex:0];
                    
                    //Message to show if not succeed
                    failedAnswerErrorMessage = [NSArray arrayWithObjects:NSLocalizedString(@"_ERROR_", nil), NSLocalizedString(@"_NO_STREAMINGLINKCATEGORY_ERROR_MSG_", nil), NSLocalizedString(@"_OK_", nil), nil];
                }
            }
            else
            {
                NSLog(@"XXXX Incorrect number of parameters to perform request! XXXX");
                
                [self processRestConnection: connection WithErrorMessage:nil forOperation:nil];
                
                return;
            }
            
            break;
        }
 
        case ADD_COUNTRY_TO_LIVESTREAMING:
        {
            if(!(parameters == nil))
            {
                if ([parameters count] == 3)
                {
                    NSString *idStreaming = (NSString*)[parameters objectAtIndex:1];
                    NSString *idCountry = (NSString*)[parameters objectAtIndex:2];
                    
                    postString = [NSString stringWithFormat:@"/Livestreaming/%@/countries/%@", idStreaming, idCountry];
                    //Data object to post
                    dataObject = (LiveStreaming*)[parameters objectAtIndex:0];
                    
                    //Message to show if not succeed
                    failedAnswerErrorMessage = [NSArray arrayWithObjects:NSLocalizedString(@"_ERROR_", nil), NSLocalizedString(@"_NO_STREAMINGLINKCATEGORY_ERROR_MSG_", nil), NSLocalizedString(@"_OK_", nil), nil];
                }
            }
            else
            {
                NSLog(@"XXXX Incorrect number of parameters to perform request! XXXX");
                
                [self processRestConnection: connection WithErrorMessage:nil forOperation:nil];
                
                return;
            }
            
            break;
        }
        case ADD_STATEREGION_TO_LIVESTREAMING:
        {
            if(!(parameters == nil))
            {
                if ([parameters count] == 3)
                {
                    NSString *idStreaming = (NSString*)[parameters objectAtIndex:1];
                    NSString *idState = (NSString*)[parameters objectAtIndex:2];
                    
                    postString = [NSString stringWithFormat:@"/Livestreaming/%@/stateregions/%@", idStreaming, idState];
                    //Data object to post
                    dataObject = (LiveStreaming*)[parameters objectAtIndex:0];
                    
                    //Message to show if not succeed
                    failedAnswerErrorMessage = [NSArray arrayWithObjects:NSLocalizedString(@"_ERROR_", nil), NSLocalizedString(@"_NO_STREAMINGLINKCATEGORY_ERROR_MSG_", nil), NSLocalizedString(@"_OK_", nil), nil];
                }
            }
            else
            {
                NSLog(@"XXXX Incorrect number of parameters to perform request! XXXX");
                
                [self processRestConnection: connection WithErrorMessage:nil forOperation:nil];
                
                return;
            }
            
            break;
        }
        case ADD_CITY_TO_LIVESTREAMING:
        {
            if(!(parameters == nil))
            {
                if ([parameters count] == 3)
                {
                    NSString *idStreaming = (NSString*)[parameters objectAtIndex:1];
                    NSString *idCity = (NSString*)[parameters objectAtIndex:2];
                    
                    postString = [NSString stringWithFormat:@"/Livestreaming/%@/cities/%@", idStreaming, idCity];
                    //Data object to post
                    dataObject = (LiveStreaming*)[parameters objectAtIndex:0];
                    
                    //Message to show if not succeed
                    failedAnswerErrorMessage = [NSArray arrayWithObjects:NSLocalizedString(@"_ERROR_", nil), NSLocalizedString(@"_NO_STREAMINGLINKCATEGORY_ERROR_MSG_", nil), NSLocalizedString(@"_OK_", nil), nil];
                }
            }
            else
            {
                NSLog(@"XXXX Incorrect number of parameters to perform request! XXXX");
                
                [self processRestConnection: connection WithErrorMessage:nil forOperation:nil];
                
                return;
            }
            
            break;
        }
        case ADD_TYPELOOK_TO_LIVESTREAMING:
        {
            if(!(parameters == nil))
            {
                if ([parameters count] == 3)
                {
                    NSString *idStreaming = (NSString*)[parameters objectAtIndex:1];
                    NSString *idTypeLook = (NSString*)[parameters objectAtIndex:2];
                    
                    postString = [NSString stringWithFormat:@"/Livestreaming/%@/typelooks/%@", idStreaming, idTypeLook];
                    //Data object to post
                    dataObject = (LiveStreaming*)[parameters objectAtIndex:0];
                    
                    //Message to show if not succeed
                    failedAnswerErrorMessage = [NSArray arrayWithObjects:NSLocalizedString(@"_ERROR_", nil), NSLocalizedString(@"_NO_STREAMINGLINKCATEGORY_ERROR_MSG_", nil), NSLocalizedString(@"_OK_", nil), nil];
                }
            }
            else
            {
                NSLog(@"XXXX Incorrect number of parameters to perform request! XXXX");
                
                [self processRestConnection: connection WithErrorMessage:nil forOperation:nil];
                
                return;
            }
            
            break;
        }
        case ADD_HASHTAG_TO_LIVESTREAMING:
        {
            if(!(parameters == nil))
            {
                if ([parameters count] == 3)
                {
                    NSString *idStreaming = (NSString*)[parameters objectAtIndex:1];
                    NSString *idHashTag = (NSString*)[parameters objectAtIndex:2];
                    
                    postString = [NSString stringWithFormat:@"/Livestreaming/%@/hashtags/%@", idStreaming, idHashTag];
                    //Data object to post
                    dataObject = (LiveStreaming*)[parameters objectAtIndex:0];
                    
                    //Message to show if not succeed
                    failedAnswerErrorMessage = [NSArray arrayWithObjects:NSLocalizedString(@"_ERROR_", nil), NSLocalizedString(@"_NO_STREAMINGLINKCATEGORY_ERROR_MSG_", nil), NSLocalizedString(@"_OK_", nil), nil];
                }
            }
            else
            {
                NSLog(@"XXXX Incorrect number of parameters to perform request! XXXX");
                
                [self processRestConnection: connection WithErrorMessage:nil forOperation:nil];
                
                return;
            }
            
            break;
        }
        case ADD_PRODUCTCATEGORY_TO_LIVESTREAMING:
        {
            if(!(parameters == nil))
            {
                if ([parameters count] == 3)
                {
                    NSString *idStreaming = (NSString*)[parameters objectAtIndex:1];
                    NSString *idProductCategory = (NSString*)[parameters objectAtIndex:2];
                    
                    postString = [NSString stringWithFormat:@"/Livestreaming/%@/productcategories/%@", idStreaming, idProductCategory];
                    //Data object to post
                    dataObject = (LiveStreaming*)[parameters objectAtIndex:0];
                    
                    //Message to show if not succeed
                    failedAnswerErrorMessage = [NSArray arrayWithObjects:NSLocalizedString(@"_ERROR_", nil), NSLocalizedString(@"_NO_STREAMINGLINKCATEGORY_ERROR_MSG_", nil), NSLocalizedString(@"_OK_", nil), nil];
                }
            }
            else
            {
                NSLog(@"XXXX Incorrect number of parameters to perform request! XXXX");
                
                [self processRestConnection: connection WithErrorMessage:nil forOperation:nil];
                
                return;
            }
            
            break;
        }
        case ADD_BRAND_TO_LIVESTREAMING:
        {
            if(!(parameters == nil))
            {
                if ([parameters count] == 3)
                {
                    NSString *idStreaming = (NSString*)[parameters objectAtIndex:1];
                    NSString *idBrand = (NSString*)[parameters objectAtIndex:2];
                    
                    postString = [NSString stringWithFormat:@"/Livestreaming/%@/brands/%@", idStreaming, idBrand];
                    //Data object to post
                    dataObject = (LiveStreaming*)[parameters objectAtIndex:0];
                    
                    //Message to show if not succeed
                    failedAnswerErrorMessage = [NSArray arrayWithObjects:NSLocalizedString(@"_ERROR_", nil), NSLocalizedString(@"_NO_STREAMINGLINKCATEGORY_ERROR_MSG_", nil), NSLocalizedString(@"_OK_", nil), nil];
                }
            }
            else
            {
                NSLog(@"XXXX Incorrect number of parameters to perform request! XXXX");
                
                [self processRestConnection: connection WithErrorMessage:nil forOperation:nil];
                
                return;
            }
            
            break;
        }
        default:
            break;
    }
    
    if(!(postString == nil) && (!(dataObject == nil)))
    {
        if (!([postString isEqualToString:@""]))
        {
            NSDate *methodStart = [NSDate date];
            
            [[RKObjectManager sharedManager] postObject:dataObject
                                                   path:postString
                                             parameters:nil
                                                success:^(RKObjectRequestOperation * operation, RKMappingResult * mappingResult)
             {
                 // If the GS server provided an answer, check wheter that answer could be mapped into our data classes
                 
                 if((!(connection == ADD_ITEM_TO_WARDROBE)) && (!(connection == UPDATE_ITEM_TO_WARDROBE)) && (!(connection == ADD_POST_TO_WARDROBE)) && (!(connection == UPLOAD_FASHIONISTACONTENT)) && (!(connection == UPLOAD_FASHIONISTAPAGE)) && (!(connection == UPLOAD_FASHIONISTAPOST)) && (!(connection == ADD_KEYWORD_TO_CONTENT))&& (!(connection == UPDATE_KEYWORD_TO_CONTENT)) && (!(connection == ADD_WARDROBE_TO_CONTENT)) && (!(connection == ADD_POSTVIEW)) && (!(connection == ADD_PRODUCTVIEW)) && (!(connection == ADD_USERREPORT)) && (!(connection == ADD_POSTCONTENTREPORT))  && (!(connection == ADD_POSTCOMMENTREPORT)) && (!(connection == ADD_PRODUCTREPORT)) && (!(connection == ADD_FASHIONISTAVIEW)) && (!(connection == ADD_COMMENTVIEW)) && (!(connection == ADD_REVIEWPRODUCTVIEW)) && (!(connection == ADD_WARDROBEVIEW)) && (!(connection == FOLLOW_USER)) && (!(connection == UNFOLLOW_USER)) && (!(connection == LIKE_POST)) && (!(connection == POST_UNFOLLOW)) && (!(connection == POST_NO_NOTICES)) && (!(connection == USER_IGNORE_NOTICES)) && (!(connection == ADD_POSTVIEWTIME)) && (!(connection == ADD_POSTSHARED)) && (!(connection == ADD_PRODUCTSHARED)) && (!(connection == ADD_PRODUCTPURCHASE))&&    (!(connection == ADD_FASHIONISTAVIEWTIME)) && (!(connection == UPLOAD_LIVESTREAMING))  && (!(connection == ADD_LIVESTREAMINGCATEGORY_TO_LIVESTREAMING)) && (!(connection == ADD_COUNTRY_TO_LIVESTREAMING)) && (!(connection == ADD_STATEREGION_TO_LIVESTREAMING)) && (!(connection == ADD_CITY_TO_LIVESTREAMING)) && (!(connection == ADD_TYPELOOK_TO_LIVESTREAMING)) && (!(connection == ADD_HASHTAG_TO_LIVESTREAMING)) && (!(connection == ADD_PRODUCTCATEGORY_TO_LIVESTREAMING)) && (!(connection == ADD_BRAND_TO_LIVESTREAMING)) && (!(connection == UPLOAD_LIVESTREAMINGETHINICITY)))
                 {
                     NSManagedObjectContext *currentContext = [RKObjectManager sharedManager].managedObjectStore.mainQueueManagedObjectContext;
                     
                     [currentContext deleteObject:dataObject];
                     NSError * error = nil;
                     if (![currentContext save:&error])
                     {
                         NSLog(@"Error saving context! %@", error);
                     }
                     
                 }
                 
                 NSDate *methodFinish = [NSDate date];
                 
                 NSTimeInterval executionTime = [methodFinish timeIntervalSinceDate:methodStart];
                 
                 NSLog(@"Operation <%@> succeed!! It took: %f", operation.HTTPRequestOperation.request.URL, executionTime);
                 
                 [self processAnswerToRestConnection:connection WithResult: [mappingResult array] lookingForClasses:[NSArray arrayWithObject:dataObject] andIfErrorMessage:failedAnswerErrorMessage];
             }
                                                failure:^(RKObjectRequestOperation * operation, NSError *error)
             {
                 //Message to show if no results were provided
                 NSArray *errorMessage = [NSArray arrayWithObjects:NSLocalizedString(@"_ERROR_", nil), NSLocalizedString(@"_CONNECTION_ERROR_MSG_", nil), NSLocalizedString(@"_OK_", nil), nil];
                 
                 // If 'failedAnswerErrorMessage' is nil, it means that we don't want to provide messages to the user
                 if(failedAnswerErrorMessage == nil)
                 {
                     errorMessage = nil;
                 }
                 
                 NSManagedObjectContext *currentContext = [RKObjectManager sharedManager].managedObjectStore.mainQueueManagedObjectContext;
                 
                 if ([dataObject isKindOfClass:[NSManagedObject class]])
                 {
                     [currentContext deleteObject:dataObject];
                     NSError * error = nil;
                     if (![currentContext save:&error])
                     {
                         NSLog(@"Error saving context! %@", error);
                     }
                     
                 }
                 
                 NSLog(@"Operation <%@> failed with error: %ld", operation.HTTPRequestOperation.request.URL, (long)operation.HTTPRequestOperation.response.statusCode);
                 
                 
                 if(((long)operation.HTTPRequestOperation.response.statusCode) < 250)
                 {
                     [self processAnswerToRestConnection:connection WithResult: nil lookingForClasses:[NSArray arrayWithObject:dataObject] andIfErrorMessage:failedAnswerErrorMessage];
                 }
                 else
                 {
                     [self processRestConnection: connection WithErrorMessage:errorMessage forOperation:operation];
                 }
// #ifndef _OSAMA_
//                     [[NSNotificationCenter defaultCenter] postNotificationName:@"FailedItemToWardrobeNotification" object:self];
// #endif

             }];
            
            return;
        }
    }
    
#ifndef _OSAMA_
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"FailedItemToWardrobeNotification" object:self];
#endif

    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_ERROR_", nil) message:NSLocalizedString(@"_CONNECTION_ERROR_MSG_", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"_OK_", nil) otherButtonTitles:nil];
    
    [alertView show];
    
    [self processRestConnection: connection WithErrorMessage:nil forOperation:nil];
}

- (void) askRetryingPostForConnection: (connectionType)connection withParameters:(NSArray *)parameters withErrorMessage:(NSArray *) errorMessage forOperation:(RKObjectRequestOperation *)operation
{
    if ((connection == UPLOAD_COMMENT_VIDEO) ||
        (connection == UPLOAD_FASHIONISTACONTENT_IMAGE) ||
        (connection == UPLOAD_FASHIONISTACONTENT_VIDEO) ||
        (connection == UPLOAD_FASHIONISTAPAGE_IMAGE) ||
        (connection == UPLOAD_FASHIONISTAPOST_PREVIEWIMAGE) ||
        (connection == UPLOAD_REVIEW_VIDEO)
        )
    {
        // show message if you want to retry
        //                             UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_RETRY_", nil) message:NSLocalizedString(@"_CONNECTION_ERROR_MSG_RETRY_", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"_NO_", nil) otherButtonTitles:NSLocalizedString(@"_YES_", nil), nil ];
        //
        //                             [alertView show];
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"_RETRY_", nil)
                                                                                 message:NSLocalizedString(@"_CONNECTION_ERROR_MSG_RETRY_", nil)
                                                                          preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction * noRetryAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"_NO_", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            
            [self processRestConnection: connection WithErrorMessage:errorMessage forOperation:operation];
            
        }];
        
        UIAlertAction * retryAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"_YES_", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            
            [self performRestPost:connection withParamaters:parameters retrying:NO];
            
        }];
        
        [alertController addAction:noRetryAction];
        [alertController addAction:retryAction];
        
        [self presentViewController:alertController animated:YES completion:nil];
    }
    //    else
    //    {
    //        if(statuscode < 250)
    //        {
    //            [self processAnswerToRestConnection:connection WithResult: nil lookingForClasses:[NSArray arrayWithObject:dataObject] andIfErrorMessage:failedAnswerErrorMessage];
    //        }
    //        else{
    //            [self processRestConnection: connection WithErrorMessage:errorMessage forOperation:operation];
    //        }
    //    }
}

// Perform Rest Delete
- (void) performRestDelete:(connectionType)connection withParamaters:(NSArray *)parameters
{
    NSString * postString;
    id dataObject;
    NSArray *failedAnswerErrorMessage;
    
    switch (connection)
    {
        case USER_ACCEPT_NOTICES:
        {
            if(!(parameters == nil))
            {
                if ([parameters count] == 1)
                {
                    //Data object to post
                    dataObject = (UserUserUnfollow*)[parameters objectAtIndex:0];
                    
                    // 0 = Share object
                    // String to perform the post
                    postString = [NSString stringWithFormat:@"/userignorenotices/%@",[(UserUserUnfollow*)dataObject uufId]];
                    
                    //Message to show if not succeed
                    failedAnswerErrorMessage = nil;
                }
                else
                {
                    NSLog(@"XXXX Incorrect number of parameters to perform request! XXXX");
                    
                    [self processRestConnection: connection WithErrorMessage:nil forOperation:nil];
                    
                    return;
                }
            }
            break;
        }
        case POST_FOLLOW:
        {
            if(!(parameters == nil))
            {
                if ([parameters count] == 1)
                {
                    //Data object to post
                    dataObject = (PostUserUnfollow*)[parameters objectAtIndex:0];
                    
                    // 0 = Share object
                    // String to perform the post
                    postString = [NSString stringWithFormat:@"/postunfollow/%@",[(PostUserUnfollow*)dataObject pufId]];
                    
                    //Message to show if not succeed
                    failedAnswerErrorMessage = nil;
                }
                else
                {
                    NSLog(@"XXXX Incorrect number of parameters to perform request! XXXX");
                    
                    [self processRestConnection: connection WithErrorMessage:nil forOperation:nil];
                    
                    return;
                }
            }
            break;
        }
        case POST_YES_NOTICES:
        {
            if(!(parameters == nil))
            {
                if ([parameters count] == 1)
                {
                    //Data object to post
                    dataObject = (PostUserUnfollow*)[parameters objectAtIndex:0];
                    
                    // 0 = Share object
                    // String to perform the post
                    postString = [NSString stringWithFormat:@"/postignorenotices/%@",[(PostUserUnfollow*)dataObject pufId]];
                    
                    //Message to show if not succeed
                    failedAnswerErrorMessage = nil;
                }
                else
                {
                    NSLog(@"XXXX Incorrect number of parameters to perform request! XXXX");
                    
                    [self processRestConnection: connection WithErrorMessage:nil forOperation:nil];
                    
                    return;
                }
            }
            break;
        }
        case DELETE_WARDROBE:
        {
            if(!(parameters == nil))
            {
                if ([parameters count] == 1)
                {
                    // 0 = Wardrobe object
                    // String to perform the post
                    postString = [NSString stringWithFormat:@"/wardrobe/%@", (NSString*)([(Wardrobe *)([parameters objectAtIndex:0]) idWardrobe])];
                    
                    //Data object to post
                    dataObject = (Wardrobe*)[parameters objectAtIndex:0];
                    
                    //Message to show if not succeed
                    failedAnswerErrorMessage = [NSArray arrayWithObjects:NSLocalizedString(@"_ERROR_", nil), NSLocalizedString(@"_NO_WARDROBEDELETION_ERROR_MSG_", nil), NSLocalizedString(@"_OK_", nil), nil];
                }
                else
                {
                    NSLog(@"XXXX Incorrect number of parameters to perform request! XXXX");
                    
                    [self processRestConnection: connection WithErrorMessage:nil forOperation:nil];
                    
                    return;
                }
            }
            
            break;
        }
        case REMOVE_ITEM_FROM_WARDROBE:
        {
            if(!(parameters == nil))
            {
                if ([parameters count] == 2)
                {
                    // 0 = Wardrobe Id; 1 = Element ID
                    // String to perform the post
                    postString = [NSString stringWithFormat:@"/wardrobe/%@/resultQueries/%@", (NSString*)[parameters objectAtIndex:0], (NSString*)(/*[(GSBaseElement *)*/([parameters objectAtIndex:1])/* idGSBaseElement]*/)];
                    
                    //Data object to post
                    dataObject = (GSBaseElement*)[parameters objectAtIndex:1];
                    
                    //Message to show if not succeed
                    failedAnswerErrorMessage = [NSArray arrayWithObjects:NSLocalizedString(@"_ERROR_", nil), NSLocalizedString(@"_NO_ITEMREMOVALFROMWARDROBE_ERROR_MSG_", nil), NSLocalizedString(@"_OK_", nil), nil];
                }
                else
                {
                    NSLog(@"XXXX Incorrect number of parameters to perform request! XXXX");
                    
                    [self processRestConnection: connection WithErrorMessage:nil forOperation:nil];
                    
                    return;
                }
            }
            
            break;
        }
        case DELETE_FASHIONISTA_PAGE:
        {
            if(!(parameters == nil))
            {
                if ([parameters count] == 1)
                {
                    // 0 = Post object
                    // String to perform the post
                    postString = [NSString stringWithFormat:@"/fashionistapage/%@", (NSString*)([(FashionistaPage *)([parameters objectAtIndex:0]) idFashionistaPage])];
                    
                    //Data object to post
                    dataObject = (FashionistaPage*)[parameters objectAtIndex:0];
                    
                    //Message to show if not succeed
                    failedAnswerErrorMessage = [NSArray arrayWithObjects:NSLocalizedString(@"_ERROR_", nil), NSLocalizedString(@"_NO_PAGEDELETION_ERROR_MSG_", nil), NSLocalizedString(@"_OK_", nil), nil];
                }
                else
                {
                    NSLog(@"XXXX Incorrect number of parameters to perform request! XXXX");
                    
                    [self processRestConnection: connection WithErrorMessage:nil forOperation:nil];
                    
                    return;
                }
            }
            
            break;
        }
        case DELETE_POST:
        {
            if(!(parameters == nil))
            {
                if ([parameters count] == 1)
                {
                    //Data object to post
                    //Fetch post with id?
                    dataObject = (FashionistaPost*)[parameters objectAtIndex:0];
                    
                    // 0 = Post object
                    // String to perform the post
                    postString = [NSString stringWithFormat:@"/fashionistapost/%@", ((FashionistaPost*)dataObject).idFashionistaPost];
                    
                    //Message to show if not succeed
                    failedAnswerErrorMessage = [NSArray arrayWithObjects:NSLocalizedString(@"_ERROR_", nil), NSLocalizedString(@"_NO_POSTDELETION_ERROR_MSG_", nil), NSLocalizedString(@"_OK_", nil), nil];
                }
                else
                {
                    NSLog(@"XXXX Incorrect number of parameters to perform request! XXXX");
                    
                    [self processRestConnection: connection WithErrorMessage:nil forOperation:nil];
                    
                    return;
                }
            }
            
            break;
        }
        case DELETE_POST_CONTENT:
        {
            if(!(parameters == nil))
            {
                if ([parameters count] == 1)
                {
                    // 0 = Content object
                    // String to perform the post
                    postString = [NSString stringWithFormat:@"/fashionistaPostContent/%@", (NSString*)([(FashionistaContent *)([parameters objectAtIndex:0]) idFashionistaContent])];
                    
                    //Data object to post
                    dataObject = (FashionistaContent*)[parameters objectAtIndex:0];
                    
                    //Message to show if not succeed
                    failedAnswerErrorMessage = [NSArray arrayWithObjects:NSLocalizedString(@"_ERROR_", nil), NSLocalizedString(@"_NO_POSTCONTENTDELETION_ERROR_MSG_", nil), NSLocalizedString(@"_OK_", nil), nil];
                }
                else
                {
                    NSLog(@"XXXX Incorrect number of parameters to perform request! XXXX");
                    
                    [self processRestConnection: connection WithErrorMessage:nil forOperation:nil];
                    
                    return;
                }
            }
            
            break;
        }
        case REMOVE_KEYWORD_FROM_CONTENT:
        {
            if(!(parameters == nil))
            {
                if ([parameters count] == 1)
                {
                    //                    // 0 = FashionistaPostContent Id; 1 = Keyword Id
                    //                    // String to perform the post
                    //                    Keyword * keyToRemove = (Keyword *)[parameters objectAtIndex:1];
                    //
                    //                    postString = [NSString stringWithFormat:@"/fashionistaPostContent/%@/keywords/%@", (NSString*)[parameters objectAtIndex:0], keyToRemove.idKeyword];
                    
                    KeywordFashionistaContent * keyToRemove = (KeywordFashionistaContent *)[parameters objectAtIndex:0];
                    
                    postString = [NSString stringWithFormat:@"/fashionistapostcontent_keywords__keyword_fashionistapostcontents/%@", keyToRemove.idKeywordFashionistaContent];
                    
                    //Data object to post
                    dataObject = keyToRemove;
                    
                    //Message to show if not succeed
                    failedAnswerErrorMessage = [NSArray arrayWithObjects:NSLocalizedString(@"_ERROR_", nil), NSLocalizedString(@"_NO_ITEMREMOVALFROMWARDROBE_ERROR_MSG_", nil), NSLocalizedString(@"_OK_", nil), nil];
                }
                else
                {
                    NSLog(@"XXXX Incorrect number of parameters to perform request! XXXX");
                    
                    [self processRestConnection: connection WithErrorMessage:nil forOperation:nil];
                    
                    return;
                }
            }
            break;
        }
        case DELETE_COMMENT:
        {
            if(!(parameters == nil))
            {
                if ([parameters count] == 2)
                {
                    // 0 = Post Id; 1 = Comment object
                    // String to perform the post
                    //Data object to post
                    dataObject = (Comment*)[parameters objectAtIndex:1];
                    
                    postString = [NSString stringWithFormat:@"/comment/%@",[(Comment*)dataObject idComment]];
                    
                    //Message to show if not succeed
                    failedAnswerErrorMessage = [NSArray arrayWithObjects:NSLocalizedString(@"_ERROR_", nil), NSLocalizedString(@"_NO_COMMENTCREATION_ERROR_MSG_", nil), NSLocalizedString(@"_OK_", nil), nil];
                }
                else
                {
                    NSLog(@"XXXX Incorrect number of parameters to perform request! XXXX");
                    
                    [self processRestConnection: connection WithErrorMessage:nil forOperation:nil];
                    
                    return;
                }
            }
            
            break;
        }
        default:
            break;
    }
    
    if(!(postString == nil) && (!(dataObject == nil)))
    {
        if (!([postString isEqualToString:@""]))
        {
            NSDate *methodStart = [NSDate date];
            
            [[RKObjectManager sharedManager] deleteObject:dataObject
                                                     path:postString
                                               parameters:nil
                                                  success:^(RKObjectRequestOperation * operation, RKMappingResult * mappingResult)
             {
                 // If the GS server provided an answer, check wheter that answer could be mapped into our data classes
                 
                 NSDate *methodFinish = [NSDate date];
                 
                 NSTimeInterval executionTime = [methodFinish timeIntervalSinceDate:methodStart];
                 
                 NSLog(@"Operation <%@> succeed!! It took: %f", operation.HTTPRequestOperation.request.URL, executionTime);
                 
                 [self processAnswerToRestConnection:connection WithResult: [mappingResult array] lookingForClasses:[NSArray arrayWithObject:[dataObject class]] andIfErrorMessage:failedAnswerErrorMessage];
             }
                                                  failure:^(RKObjectRequestOperation * operation, NSError *error)
             {
                 //Message to show if no results were provided
                 NSArray *errorMessage = [NSArray arrayWithObjects:NSLocalizedString(@"_ERROR_", nil), NSLocalizedString(@"_CONNECTION_ERROR_MSG_", nil), NSLocalizedString(@"_OK_", nil), nil];
                 
                 // If 'failedAnswerErrorMessage' is nil, it means that we don't want to provide messages to the user
                 if(failedAnswerErrorMessage == nil)
                 {
                     errorMessage = nil;
                 }
                 
                 NSLog(@"Operation <%@> failed with error: %ld", operation.HTTPRequestOperation.request.URL, (long)operation.HTTPRequestOperation.response.statusCode);
                 
                 [self processRestConnection: connection WithErrorMessage:errorMessage forOperation:operation];
             }];
            
            return;
        }
    }
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_ERROR_", nil) message:NSLocalizedString(@"_CONNECTION_ERROR_MSG_", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"_OK_", nil) otherButtonTitles:nil];
    
    [alertView show];
    
    
    [self processRestConnection: connection WithErrorMessage:nil forOperation:nil];
}

// Rest answer not reached
- (void)processRestConnection:(connectionType)connection WithErrorMessage:(NSArray *)errorMessage forOperation:(RKObjectRequestOperation *)operation
{
    if((!(operation == nil)) && (!(operation.isCancelled)))
    {
        //NSLog(@"Ooops! Operation <%@> failed with error: %ld", operation.HTTPRequestOperation.request.URL, operation.HTTPRequestOperation.response.statusCode);
        
        if ( ((!(errorMessage == nil)) && (!(((long)operation.HTTPRequestOperation.response.statusCode) < 250))) || ((!(errorMessage == nil)) && (operation.HTTPRequestOperation.response == nil)) )
        {
            if ([errorMessage count] == 3)
            {
                if((connection == PERFORM_SEARCH_WITHIN_PRODUCTS) || (connection == PERFORM_SEARCH_WITHIN_PRODUCTS_NUMS) || (connection == PERFORM_SEARCH_WITHIN_TRENDING) || (connection == PERFORM_SEARCH_WITHIN_HISTORY) || (connection == PERFORM_SEARCH_WITHIN_FASHIONISTAS) || (connection == PERFORM_SEARCH_USER_LIKE_POST)|| (connection == PERFORM_SEARCH_WITHIN_FASHIONISTAPOSTS) || (connection == PERFORM_SEARCH_WITHIN_STYLES) || (connection == PERFORM_SEARCH_WITHIN_BRANDS) || (connection == PERFORM_SEARCHINITIAL_WITHIN_BRANDS) || (connection == PERFORM_VISUAL_SEARCH) ||
                   (connection == UPLOAD_REVIEW_VIDEO) || (connection == UPLOAD_COMMENT_VIDEO) || (connection == UPLOAD_FASHIONISTACONTENT_IMAGE) || (connection == UPLOAD_FASHIONISTACONTENT_VIDEO) || (connection == UPLOAD_FASHIONISTAPAGE_IMAGE) || (connection == UPLOAD_FASHIONISTAPOST_PREVIEWIMAGE) || (connection == GET_AD))
                {
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[errorMessage objectAtIndex:0]message:[errorMessage objectAtIndex:1] delegate:nil cancelButtonTitle:[errorMessage objectAtIndex:2] otherButtonTitles:nil];
                    
                    [alertView show];
                }
                
                if((connection == PERFORM_SEARCH_WITHIN_PRODUCTS) ||
                   
                   (connection == PERFORM_SEARCH_WITHIN_PRODUCTS_NUMS) ||
                   
                   (connection == GET_BRAND_PRODUCTS) ||
                   
                   (connection == PERFORM_SEARCH_WITHIN_TRENDING) ||
                   
                   (connection == PERFORM_SEARCH_WITHIN_HISTORY) ||
                   
                   (connection == PERFORM_SEARCH_WITHIN_FASHIONISTAS) ||
                   
                   (connection == PERFORM_SEARCH_WITHIN_FASHIONISTAS_LIKE_POST) ||
                   
                   (connection == PERFORM_SEARCH_USER_LIKE_POST) ||
                   
                   (connection == PERFORM_SEARCH_WITHIN_FASHIONISTAPOSTS) ||
                   
                   (connection == PERFORM_SEARCH_WITHIN_STYLES) ||
                   
                   (connection == PERFORM_SEARCH_WITHIN_BRANDS) ||
                   
                   (connection == PERFORM_SEARCHINITIAL_WITHIN_BRANDS) ||
                   
                   (connection == GET_SEARCH_GROUPS_WITHIN_PRODUCTS) ||
                   
                   (connection == GET_SEARCH_GROUPS_WITHIN_BRAND_PRODUCTS) ||
                   
                   (connection == GET_SEARCH_GROUPS_WITHIN_TRENDING) ||
                   
                   (connection == GET_SEARCH_GROUPS_WITHIN_HISTORY) ||
                   
                   (connection == GET_SEARCH_GROUPS_WITHIN_FASHIONISTAS) ||
                   
                   (connection == GET_SEARCH_GROUPS_WITHIN_FASHIONISTAPOSTS) ||
                   
                   (connection == GET_SEARCH_GROUPS_WITHIN_STYLES) ||
                   
                   (connection == GET_SEARCH_GROUPS_WITHIN_BRANDS) ||
                   
                   (connection == GET_SEARCH_RESULTS_WITHIN_PRODUCTS) ||
                   
                   (connection == GET_SEARCH_RESULTS_WITHIN_BRAND_PRODUCTS) ||
                   
                   (connection == GET_SEARCH_RESULTS_WITHIN_TRENDING) ||
                   
                   (connection == GET_SEARCH_RESULTS_WITHIN_HISTORY) ||
                   
                   (connection == GET_SEARCH_RESULTS_WITHIN_FASHIONISTAS) ||
                   
                   (connection == GET_SEARCH_RESULTS_WITHIN_FASHIONISTAPOSTS) ||
                   
                   (connection == GET_SEARCH_RESULTS_WITHIN_FASHIONISTAWARDROBES) ||
                   
                   (connection == GET_SEARCH_RESULTS_WITHIN_STYLES) ||
                   
                   (connection == PERFORM_VISUAL_SEARCH) ||
                   
                   (connection ==  GET_DETECTION_STATUS) ||
                   
                   (connection == GET_USER_NEWSFEED) ||
                   
                   (connection == GET_SEARCH_GROUPS_WITHIN_NEWSFEED) ||
                   
                   (connection == GET_SEARCH_RESULTS_WITHIN_NEWSFEED) ||
                   
                   (connection == GET_USER_DISCOVER) ||
                   
                   (connection == GET_SEARCH_GROUPS_WITHIN_DISCOVER) ||
                   
                   (connection == GET_SEARCH_RESULTS_WITHIN_DISCOVER) ||
                   
                   (connection == GET_USER_LIKES) ||
                   
                   (connection == GET_USER_HISTORY) ||
                   
                   (connection == GET_SEARCH_RESULTS_WITHIN_LIKES) ||
                   
                   (connection == GET_FASHIONISTAPOSTS) ||
                   (connection == GET_FASHIONISTAMAGAZINES) ||
                   (connection == GET_FASHIONISTAMAGAZINES_RELATED))
                {
                    [self actionAfterSuccessfulAnswerToRestConnection:FINISHED_SEARCH_WITHOUT_RESULTS WithResult:nil];
                }
                else if (connection == GET_FASHIONISTAWARDROBES) {
                    [self actionAfterSuccessfulAnswerToRestConnection:FINISHED_SEARCH_WITHOUT_WARDROBES WithResult:nil];
                    
                    return;
                }
                else if(connection == GET_SEARCH_SUGGESTEDFILTERKEYWORDS)
                {
                    [self actionAfterSuccessfulAnswerToRestConnection:GET_SEARCH_SUGGESTEDFILTERKEYWORDS WithResult:nil];
                    
                    return;
                }
                else if(connection == GET_PRODUCTCATEGORIES)
                {
                    [self actionAfterSuccessfulAnswerToRestConnection:GET_PRODUCTCATEGORIES WithResult:nil];
                    
                    return;
                }
                
                [self stopActivityFeedback];
                
                return;
            }
        }
    }
    else
    {
        NSLog(@"Ooops! Operation <%@> was cancelled!", operation.HTTPRequestOperation.request.URL);
    }
    
    [self stopActivityFeedback];
    
    
    switch (connection) {
        case GET_ALLPRODUCTCATEGORIES:
        {
            break;
        }
        case GET_PRIORITYBRANDS:
        {
            NSDictionary* userInfo = @{@"total": @"ErrorConnection"};
            [[NSNotificationCenter defaultCenter] postNotificationName:@"finishLoadingTask" object:nil userInfo:userInfo];
            
            break;
        }
        case GET_ALLBRANDS:
        {
            NSDictionary* userInfo = @{@"total": @"ErrorConnection"};
            [[NSNotificationCenter defaultCenter] postNotificationName:@"finishLoadingTask" object:nil userInfo:userInfo];
            
            break;
        }
        case GET_ALLFEATURES:
        {
            NSDictionary* userInfo = @{@"total": @"ErrorConnection"};
            [[NSNotificationCenter defaultCenter] postNotificationName:@"finishLoadingTask" object:nil userInfo:userInfo];
            
            break;
        }
        case GET_ALLFEATUREGROUPS:
        {
            NSDictionary* userInfo = @{@"total": @"ErrorConnection"};
            [[NSNotificationCenter defaultCenter] postNotificationName:@"finishLoadingTask" object:nil userInfo:userInfo];
            
            break;
        }
            
        default:
            
            //[self stopActivityFeedback];
            
            break;
    }
}

// Rest answer arrived. Check if it succeedded or not
- (void)processAnswerToRestConnection:(connectionType)connection WithResult:(NSArray *)mappingResult lookingForClasses:(NSArray *)dataClasses andIfErrorMessage:(NSArray *)errorMessage
{
    if ((!(connection == GET_PRODUCT_BRAND)) && (!(connection == GET_USER_WARDROBES_CONTENT)) && (!(connection == GET_SEARCHPRODUCTS_BRAND)) && (!(connection == GET_DETECTION_STATUS)))
    {
        [[RKObjectManager sharedManager] cancelAllObjectRequestOperationsWithMethod:RKRequestMethodAny matchingPathPattern:[self getPatternForConnectionType:connection intendedForStringFormat:NO]];
    }
    
    if (!(mappingResult == nil))
    {
        // Request succeed! Perform consequent action
        
        __block SearchQuery * searchQuery;
        NSString * product;
        NSString * post;
        NSString * wardrobe;
        NSString * author;
        NSManagedObjectContext *currentContext;
        
        switch (connection)
        {
            case UPDATE_BASEELEMENT:
            {
                NSLog(@"Updating BaseElement suceed!");
                [self actionAfterSuccessfulAnswerToRestConnection:UPDATE_BASEELEMENT WithResult:mappingResult];
                break;
            }
            case GET_NEAREST_POI:
            {
                NSLog(@"Getting nearest pois succeed!");
                [self actionAfterSuccessfulAnswerToRestConnection:GET_NEAREST_POI WithResult:mappingResult];
                break;
            }
            case GET_CITIESOFSTATE:
            {
                [self actionAfterSuccessfulAnswerToRestConnection:GET_CITIESOFSTATE WithResult:mappingResult];
                break;
            }
            case GET_STATESOFCOUNTRY:
            {
                [self actionAfterSuccessfulAnswerToRestConnection:GET_STATESOFCOUNTRY WithResult:mappingResult];
                break;
            }
            case GET_ALLCOUNTRIES:
            {
                [self actionAfterSuccessfulAnswerToRestConnection:GET_ALLCOUNTRIES WithResult:mappingResult];
                
                break;
            }
            case CHECK_SEARCH_STRING:
            {
                [self actionAfterSuccessfulAnswerToRestConnection:CHECK_SEARCH_STRING WithResult:mappingResult];
                
                break;
            }
            case CHECK_SEARCH_STRING_SUGGESTIONS:
            {
                [self actionAfterSuccessfulAnswerToRestConnection:CHECK_SEARCH_STRING_SUGGESTIONS WithResult:mappingResult];
                
                break;
            }
            case CHECK_SEARCH_STRING_AFTER_SEARCH:
            {
                [self actionAfterSuccessfulAnswerToRestConnection:CHECK_SEARCH_STRING_AFTER_SEARCH WithResult:mappingResult];
                
                break;
            }
            case CHECK_SEARCH_STRING_SUGGESTIONS_AFTER_SEARCH:
            {
                [self actionAfterSuccessfulAnswerToRestConnection:CHECK_SEARCH_STRING_SUGGESTIONS_AFTER_SEARCH WithResult:mappingResult];
                
                break;
            }
            case PERFORM_SEARCH_WITHIN_PRODUCTS:
            case GET_SIMILAR_PRODUCTS:
            case GET_SEARCH_QUERY:
            {
                self.searchResults = [[NSMutableArray alloc] init];
                
                // Get the number of total results that were provided
                // and the string of terms that didn't provide any results
                [mappingResult enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
                 {
                     if (([obj isKindOfClass:[SearchQuery class]]))
                     {
                         searchQuery = obj;
                         
                         [self.searchResults addObject:searchQuery];
                         
                         // Stop the enumeration
                         *stop = YES;
                     }
                 }];
                
                if (!(searchQuery == nil))
                {
                    if (searchQuery.numresults.intValue > 0)
                    {
                        // Once performed the search, request the results
                        
                        //                        [self stopActivityFeedback];
                        //                        [self startActivityFeedbackWithMessage:NSLocalizedString(@"_DOWNLOADING_ACTV_MSG_", nil)];
                        
                        NSArray * requestParameters = [[NSArray alloc] initWithObjects:searchQuery, nil];
                        
                        [self performRestGet:GET_SEARCH_GROUPS_WITHIN_PRODUCTS withParamaters:requestParameters];
                        
                        NSLog(@"Search succeed!");
                        
                        break;
                    }
                }
                
                self.searchResults = nil;
                
                if (searchQuery.numresults.intValue < 0)
                    [self actionAfterSuccessfulAnswerToRestConnection:FINISHED_SEARCH_WITHOUT_RESULTS_ONLY_BRAND WithResult:mappingResult];
                else
                    [self actionAfterSuccessfulAnswerToRestConnection:FINISHED_SEARCH_WITHOUT_RESULTS WithResult:mappingResult];
                
                break;
            }
                //            case GET_THE_LOOK:
                //            {
                //                self.searchResults = nil;
                //
                //                [self actionAfterSuccessfulAnswerToRestConnection:GET_THE_LOOK WithResult:mappingResult];
                //
                //                break;
                //            }
            case PERFORM_SEARCH_WITHIN_PRODUCTS_NUMS:
            {
                self.searchResults = [[NSMutableArray alloc] init];
                
                // Get the number of total results that were provided
                // and the string of terms that didn't provide any results
                [mappingResult enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
                 {
                     if (([obj isKindOfClass:[SearchQuery class]]))
                     {
                         searchQuery = obj;
                         
                         [self.searchResults addObject:searchQuery];
                         
                         // Stop the enumeration
                         *stop = YES;
                     }
                 }];
                
                if (!(searchQuery == nil))
                {
                    [self actionAfterSuccessfulAnswerToRestConnection:connection WithResult:self.searchResults];
                }
                
                self.searchResults = nil;
                
                break;

            }
            case GET_BRAND_PRODUCTS:
            {
                self.searchResults = [[NSMutableArray alloc] init];
                
                // Get the number of total results that were provided
                // and the string of terms that didn't provide any results
                [mappingResult enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
                 {
                     if (([obj isKindOfClass:[SearchQuery class]]))
                     {
                         searchQuery = obj;
                         
                         [self.searchResults addObject:searchQuery];
                         
                         // Stop the enumeration
                         *stop = YES;
                     }
                 }];
                
                if (!(searchQuery == nil))
                {
                    if (searchQuery.numresults > 0)
                    {
                        // Once performed the search, request the results
                        
                        //                        [self stopActivityFeedback];
                        //                        [self startActivityFeedbackWithMessage:NSLocalizedString(@"_DOWNLOADING_ACTV_MSG_", nil)];
                        
                        NSArray * requestParameters = [[NSArray alloc] initWithObjects:searchQuery, nil];
                        
                        [self performRestGet:GET_SEARCH_GROUPS_WITHIN_BRAND_PRODUCTS withParamaters:requestParameters];
                        
                        NSLog(@"Search succeed!");
                        
                        break;
                    }
                }
                
                self.searchResults = nil;
                
                [self actionAfterSuccessfulAnswerToRestConnection:FINISHED_BRANDPRODUCTSSEARCH_WITHOUT_RESULTS WithResult:mappingResult];
                
                break;
            }
            case GET_USER_LIKES:
            {
                [self actionAfterSuccessfulAnswerToRestConnection:GET_USER_LIKES WithResult:mappingResult];
                
                break;
            }
            case GET_USER_HISTORY:
            {
                [self actionAfterSuccessfulAnswerToRestConnection:GET_USER_HISTORY WithResult:mappingResult];
                break;
            }
            case GET_FASHIONISTAPOSTS:
            {
                self.searchResults = [[NSMutableArray alloc] init];
                
                // Get the number of total results that were provided
                // and the string of terms that didn't provide any results
                [mappingResult enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
                 {
                     if (([obj isKindOfClass:[SearchQuery class]]))
                     {
                         searchQuery = obj;
                         
                         [self.searchResults addObject:searchQuery];
                         
                         // Stop the enumeration
                         *stop = YES;
                     }
                 }];
                
                if (!(searchQuery == nil))
                {
                    if (searchQuery.numresults > 0)
                    {
                        NSArray * requestParameters = [[NSArray alloc] initWithObjects:searchQuery,[NSNumber numberWithInt:0], nil];
                        
                        [self performRestGet:GET_SEARCH_RESULTS_WITHIN_FASHIONISTAPOSTS withParamaters:requestParameters];
                        //[self performRestGet:GET_SEARCH_GROUPS_WITHIN_FASHIONISTAPOSTS withParamaters:requestParameters];
                        
                        NSLog(@"Search succeed!");
                        
                        break;
                    }
                }
                
                self.searchResults = nil;
                
                [self actionAfterSuccessfulAnswerToRestConnection:FINISHED_SEARCH_WITHOUT_RESULTS WithResult:mappingResult];
                
                break;
            }
            case GET_FASHIONISTAWARDROBES:
            {
                self.searchResults = [[NSMutableArray alloc] init];
                
                // Get the number of total results that were provided
                // and the string of terms that didn't provide any results
                [mappingResult enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
                 {
                     if (([obj isKindOfClass:[SearchQuery class]]))
                     {
                         searchQuery = obj;
                         
                         [self.searchResults addObject:searchQuery];
                         
                         // Stop the enumeration
                         *stop = YES;
                     }
                 }];
                
                if (!(searchQuery == nil))
                {
                    if (searchQuery.numresults > 0)
                    {
                        NSArray * requestParameters = [[NSArray alloc] initWithObjects:searchQuery,[NSNumber numberWithInt:0], nil];
                        
                        [self performRestGet:GET_SEARCH_RESULTS_WITHIN_FASHIONISTAWARDROBES withParamaters:requestParameters];
                        //[self performRestGet:GET_SEARCH_GROUPS_WITHIN_FASHIONISTAPOSTS withParamaters:requestParameters];
                        
                        NSLog(@"Search succeed!");
                        
                        break;
                    }
                }
                
                break;

            }
            case GET_FASHIONISTAMAGAZINES:
            {
                self.searchResults = [[NSMutableArray alloc] init];
                
                // Get the number of total results that were provided
                // and the string of terms that didn't provide any results
                //                [mappingResult enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
                //                 {
                //                     if (([obj isKindOfClass:[SearchQuery class]]))
                //                     {
                //                         searchQuery = obj;
                //
                //                         [self.searchResults addObject:searchQuery];
                //
                //                         // Stop the enumeration
                //                         *stop = YES;
                //                     }
                //                 }];
                //
                //                if (!(searchQuery == nil))
                //                {
                //                    if (searchQuery.numresults > 0)
                //                    {
                //                        NSArray * requestParameters = [[NSArray alloc] initWithObjects:searchQuery,[NSNumber numberWithInt:0], nil];
                //
                //                        [self performRestGet:GET_SEARCH_RESULTS_WITHIN_FASHIONISTAPOSTS withParamaters:requestParameters];
                //                        //[self performRestGet:GET_SEARCH_GROUPS_WITHIN_FASHIONISTAPOSTS withParamaters:requestParameters];
                //
                //                        NSLog(@"Search succeed!");
                //                        
                //                        break;
                //                    }
                //                }
                //                
                self.searchResults = nil;
                
                [self actionAfterSuccessfulAnswerToRestConnection:GET_FASHIONISTAMAGAZINES WithResult:mappingResult];
                
                break;
                
            }
            case GET_FASHIONISTAMAGAZINES_RELATED:
            {
                self.searchResults = [[NSMutableArray alloc] init];
                
                self.searchResults = nil;
                
                [self actionAfterSuccessfulAnswerToRestConnection:GET_FASHIONISTAMAGAZINES_RELATED WithResult:mappingResult];
                
                break;

            }
            case GET_USER_DISCOVER:
            {
                self.searchResults = [[NSMutableArray alloc] init];
                
                // Get the number of total results that were provided
                // and the string of terms that didn't provide any results
                [mappingResult enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
                 {
                     if (([obj isKindOfClass:[SearchQuery class]]))
                     {
                         searchQuery = obj;
                         
                         [self.searchResults addObject:searchQuery];
                         
                         // Stop the enumeration
                         *stop = YES;
                     }
                 }];
                
                if (!(searchQuery == nil))
                {
                    if (searchQuery.numresults > 0)
                    {
                        NSArray * requestParameters = [[NSArray alloc] initWithObjects:searchQuery, nil];
                        
                        [self performRestGet:GET_SEARCH_GROUPS_WITHIN_DISCOVER withParamaters:requestParameters];
                        
                        NSLog(@"Search succeed!");
                        
                        break;
                    }
                }
                
                self.searchResults = nil;
                
                [self actionAfterSuccessfulAnswerToRestConnection:FINISHED_SEARCH_WITHOUT_RESULTS WithResult:mappingResult];
                
                break;
            }
            case GET_USER_NEWSFEED:
            {
                self.searchResults = [[NSMutableArray alloc] init];
                
                // Get the number of total results that were provided
                // and the string of terms that didn't provide any results
                [mappingResult enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
                 {
                     if (([obj isKindOfClass:[SearchQuery class]]))
                     {
                         searchQuery = obj;
                         
                         [self.searchResults addObject:searchQuery];
                         
                         // Stop the enumeration
                         *stop = YES;
                     }
                 }];
                
                if (!(searchQuery == nil))
                {
                    if (searchQuery.numresults > 0)
                    {
                        NSArray * requestParameters = [[NSArray alloc] initWithObjects:searchQuery, [NSNumber numberWithInt:0], nil];
                        
                        [self performRestGet:GET_SEARCH_RESULTS_WITHIN_NEWSFEED withParamaters:requestParameters];
                        
                        //NSArray * requestParameters = [[NSArray alloc] initWithObjects:searchQuery, nil];
                        //[self performRestGet:GET_SEARCH_GROUPS_WITHIN_NEWSFEED withParamaters:requestParameters];
                        
                        NSLog(@"Search succeed!");
                        
                        break;
                    }
                }
                
                self.searchResults = nil;
                
                [self actionAfterSuccessfulAnswerToRestConnection:FINISHED_SEARCH_WITHOUT_RESULTS WithResult:mappingResult];
                
                break;
            }
            case PERFORM_SEARCH_WITHIN_TRENDING:
            {
                self.searchResults = [[NSMutableArray alloc] init];
                
                // Get the number of total results that were provided
                // and the string of terms that didn't provide any results
                [mappingResult enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
                 {
                     if (([obj isKindOfClass:[SearchQuery class]]))
                     {
                         searchQuery = obj;
                         
                         [self.searchResults addObject:searchQuery];
                         
                         // Stop the enumeration
                         *stop = YES;
                     }
                 }];
                
                if (!(searchQuery == nil))
                {
                    if (searchQuery.numresults > 0)
                    {
                        // Once performed the search, request the results
                        
                        //                        [self stopActivityFeedback];
                        //                        [self startActivityFeedbackWithMessage:NSLocalizedString(@"_DOWNLOADING_ACTV_MSG_", nil)];
                        
                        NSArray * requestParameters = [[NSArray alloc] initWithObjects:searchQuery, nil];
                        
                        [self performRestGet:GET_SEARCH_GROUPS_WITHIN_TRENDING withParamaters:requestParameters];
                        
                        NSLog(@"Search succeed!");
                        
                        break;
                    }
                }
                
                self.searchResults = nil;
                
                [self actionAfterSuccessfulAnswerToRestConnection:FINISHED_SEARCH_WITHOUT_RESULTS WithResult:mappingResult];
                
                break;
            }
            case PERFORM_SEARCH_WITHIN_HISTORY:
            {
                self.searchResults = [[NSMutableArray alloc] init];
                
                // Get the number of total results that were provided
                // and the string of terms that didn't provide any results
                [mappingResult enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
                 {
                     if (([obj isKindOfClass:[SearchQuery class]]))
                     {
                         searchQuery = obj;
                         
                         [self.searchResults addObject:searchQuery];
                         
                         // Stop the enumeration
                         *stop = YES;
                     }
                 }];
                
                if (!(searchQuery == nil))
                {
                    if (searchQuery.numresults > 0)
                    {
                        // Once performed the search, request the results
                        
                        //                        [self stopActivityFeedback];
                        //                        [self startActivityFeedbackWithMessage:NSLocalizedString(@"_DOWNLOADING_ACTV_MSG_", nil)];
                        
                        NSArray * requestParameters = [[NSArray alloc] initWithObjects:searchQuery, nil];
                        
                        [self performRestGet:GET_SEARCH_GROUPS_WITHIN_HISTORY withParamaters:requestParameters];
                        
                        NSLog(@"Search succeed!");
                        
                        break;
                    }
                }
                
                self.searchResults = nil;
                
                [self actionAfterSuccessfulAnswerToRestConnection:FINISHED_SEARCH_WITHOUT_RESULTS WithResult:mappingResult];
                
                break;
            }
            case PERFORM_SEARCH_WITHIN_FASHIONISTAPOSTS:
            {
                if (self.searchResults == nil)
                {
                    self.searchResults = [[NSMutableArray alloc] init];
                }
                
                // Get the number of total results that were provided
                // and the string of terms that didn't provide any results
                [mappingResult enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
                 {
                     if (([obj isKindOfClass:[SearchQuery class]]))
                     {
                         searchQuery = obj;
                         
                         [self.searchResults addObject:searchQuery];
                         
                         // Stop the enumeration
                         *stop = YES;
                     }
                 }];
                
                if (!(searchQuery == nil))
                {
                    if (searchQuery.numresults > 0)
                    {
                        // Once performed the search, request the results
                        
                        //                        [self stopActivityFeedback];
                        //                        [self startActivityFeedbackWithMessage:NSLocalizedString(@"_DOWNLOADING_ACTV_MSG_", nil)];
                        
                        NSArray * requestParameters = [[NSArray alloc] initWithObjects:searchQuery, nil];
                        
                        [self performRestGet:GET_SEARCH_GROUPS_WITHIN_FASHIONISTAPOSTS withParamaters:requestParameters];
                        
                        NSLog(@"Search succeed!");
                        
                        break;
                    }
                }
                
                self.searchResults = nil;
                
                [self actionAfterSuccessfulAnswerToRestConnection:FINISHED_SEARCH_WITHOUT_RESULTS WithResult:mappingResult];
                
                break;
            }
            case PERFORM_SEARCH_USER_LIKE_POST:
            {
                if (self.searchResults == nil)
                {
                    self.searchResults = [[NSMutableArray alloc] init];
                }
                
                // Get the number of total results that were provided
                // and the string of terms that didn't provide any results
                [mappingResult enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
                 {
                     if (([obj isKindOfClass:[SearchQuery class]]))
                     {
                         searchQuery = obj;
                         
                         [self.searchResults addObject:searchQuery];
                         
                         // Stop the enumeration
                         *stop = YES;
                     }
                 }];
                
                if (!(searchQuery == nil))
                {
                    if (searchQuery.numresults > 0)
                    {
                        // Once performed the search, request the results
                        
                        //                        [self stopActivityFeedback];
                        //                        [self startActivityFeedbackWithMessage:NSLocalizedString(@"_DOWNLOADING_ACTV_MSG_", nil)];
                        
                        NSArray * requestParameters = [[NSArray alloc] initWithObjects:searchQuery, nil];
                        
                        [self performRestGet:GET_SEARCH_GROUPS_WITHIN_FASHIONISTAS withParamaters:requestParameters];
                        
                        NSLog(@"Search succeed!");
                        
                        break;
                    }
                }
                
                self.searchResults = nil;
                
                [self actionAfterSuccessfulAnswerToRestConnection:PERFORM_SEARCH_USER_LIKE_POST WithResult:mappingResult];
                break;
            }
            case PERFORM_SEARCH_WITHIN_FASHIONISTAS:
            case PERFORM_SEARCH_WITHIN_FASHIONISTAS_LIKE_POST:
            {
                if (self.searchResults == nil)
                {
                    self.searchResults = [[NSMutableArray alloc] init];
                }
                
                // Get the number of total results that were provided
                // and the string of terms that didn't provide any results
                [mappingResult enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
                 {
                     if (([obj isKindOfClass:[SearchQuery class]]))
                     {
                         searchQuery = obj;
                         
                         [self.searchResults addObject:searchQuery];
                         
                         // Stop the enumeration
                         *stop = YES;
                     }
                 }];
                
                if (!(searchQuery == nil))
                {
                    if (searchQuery.numresults > 0)
                    {
                        // Once performed the search, request the results
                        
                        //                        [self stopActivityFeedback];
                        //                        [self startActivityFeedbackWithMessage:NSLocalizedString(@"_DOWNLOADING_ACTV_MSG_", nil)];
                        
                        NSArray * requestParameters = [[NSArray alloc] initWithObjects:searchQuery, nil];
                        NSLog(@"aaaaaaa  %@", requestParameters);
                        [self performRestGet:GET_SEARCH_GROUPS_WITHIN_FASHIONISTAS withParamaters:requestParameters];
                        
                        NSLog(@"Search succeed!");
                        
                        break;
                    }
                }
                
                self.searchResults = nil;
                
                [self actionAfterSuccessfulAnswerToRestConnection:FINISHED_SEARCH_WITHOUT_RESULTS WithResult:mappingResult];
                
                break;
            }
            case GET_THE_LOOK:
            {
                self.searchResults = [[NSMutableArray alloc] init];
                
                // Get the number of total results that were provided
                // and the string of terms that didn't provide any results
                [mappingResult enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
                 {
                     if (([obj isKindOfClass:[SearchQuery class]]))
                     {
                         searchQuery = obj;
                         
                         [self.searchResults addObject:searchQuery];
                         
                         // Stop the enumeration
                         *stop = YES;
                     }
                 }];
                
                if (!(searchQuery == nil))
                {
                    if (searchQuery.numresults > 0)
                    {
                        // Once performed the search, request the results
                        
                        //                        [self stopActivityFeedback];
                        //                        [self startActivityFeedbackWithMessage:NSLocalizedString(@"_DOWNLOADING_ACTV_MSG_", nil)];
                        
                        NSArray * requestParameters = [[NSArray alloc] initWithObjects:searchQuery, nil];
                        
                        [self performRestGet:GET_SEARCH_GROUPS_WITHIN_STYLES withParamaters:requestParameters];
                        
                        NSLog(@"Search succeed!");
                        
                        break;
                    }
                }
                
                self.searchResults = nil;
                
                [self actionAfterSuccessfulAnswerToRestConnection:FINISHED_GETTHELOOK_WITHOUT_RESULTS WithResult:mappingResult];
                
                break;
            }
            case PERFORM_SEARCH_WITHIN_STYLES:
            {
                self.searchResults = [[NSMutableArray alloc] init];
                
                // Get the number of total results that were provided
                // and the string of terms that didn't provide any results
                [mappingResult enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
                 {
                     if (([obj isKindOfClass:[SearchQuery class]]))
                     {
                         searchQuery = obj;
                         
                         [self.searchResults addObject:searchQuery];
                         
                         // Stop the enumeration
                         *stop = YES;
                     }
                 }];
                
                if (!(searchQuery == nil))
                {
                    if (searchQuery.numresults > 0)
                    {
                        // Once performed the search, request the results
                        
                        //                        [self stopActivityFeedback];
                        //                        [self startActivityFeedbackWithMessage:NSLocalizedString(@"_DOWNLOADING_ACTV_MSG_", nil)];
                        
                        NSArray * requestParameters = [[NSArray alloc] initWithObjects:searchQuery, nil];
                        
                        [self performRestGet:GET_SEARCH_GROUPS_WITHIN_STYLES withParamaters:requestParameters];
                        
                        NSLog(@"Search succeed!");
                        
                        break;
                    }
                }
                
                self.searchResults = nil;
                
                [self actionAfterSuccessfulAnswerToRestConnection:FINISHED_SEARCH_WITHOUT_RESULTS WithResult:mappingResult];
                
                break;
            }
            case PERFORM_SEARCHINITIAL_WITHIN_BRANDS:
            case PERFORM_SEARCH_WITHIN_BRANDS:
            {
                self.searchResults = [[NSMutableArray alloc] init];
                
                // Get the number of total results that were provided
                // and the string of terms that didn't provide any results
                [mappingResult enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
                 {
                     if (([obj isKindOfClass:[SearchQuery class]]))
                     {
                         searchQuery = obj;
                         
                         [self.searchResults addObject:searchQuery];
                         
                         // Stop the enumeration
                         *stop = YES;
                     }
                 }];
                
                if (!(searchQuery == nil))
                {
                    if (searchQuery.numresults > 0)
                    {
                        // Once performed the search, request the results
                        
                        //                        [self stopActivityFeedback];
                        //                        [self startActivityFeedbackWithMessage:NSLocalizedString(@"_DOWNLOADING_ACTV_MSG_", nil)];
                        
                        NSArray * requestParameters = [[NSArray alloc] initWithObjects:searchQuery, nil];
                        
                        [self performRestGet:GET_SEARCH_GROUPS_WITHIN_BRANDS withParamaters:requestParameters];
                        
                        NSLog(@"Search succeed!");
                        
                        break;
                    }
                }
                
                self.searchResults = nil;
                
                [self actionAfterSuccessfulAnswerToRestConnection:FINISHED_SEARCH_WITHOUT_RESULTS WithResult:mappingResult];
                
                break;
            }
            case GET_SEARCH_GROUPS_WITHIN_PRODUCTS:
            {
                if(self.searchResults == nil)
                {
                    self.searchResults = [[NSMutableArray alloc] init];
                }
                
                // Get the results groups that were provided
                [mappingResult enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
                 {
                     if (([obj isKindOfClass:[ResultsGroup class]]))
                     {
                         [self.searchResults addObject:obj];
                         
                         //                         if(!(obj == nil))
                         //                         {
                         //                             if(!([((ResultsGroup*) obj) idResultsGroup] == nil))
                         //                             {
                         //                                 if(!([[((ResultsGroup*) obj) idResultsGroup] isEqualToString:@""]))
                         //                                 {
                         //                                     [self performRestGet:GET_SEARCH_GROUP_KEYWORDS withParamaters:[[NSArray alloc] initWithObjects:[((ResultsGroup*) obj) idResultsGroup], nil]];
                         //                                 }
                         //
                         //                             }
                         //                         }
                     }
                 }];
                
                if( !(self.searchResults == nil))
                {
                    if([self.searchResults count] > 0)
                    {
                        if(!([self.searchResults objectAtIndex:0] == nil))
                        {
                            if([[self.searchResults objectAtIndex:0] isKindOfClass:[SearchQuery class]])
                            {
                                if([((SearchQuery *)[self.searchResults objectAtIndex:0]) numresults] > 0)
                                {
                                    // Once performed the search, request the results
                                    
                                    //                                    [self stopActivityFeedback];
                                    //                                    [self startActivityFeedbackWithMessage:NSLocalizedString(@"_DOWNLOADING_ACTV_MSG_", nil)];
                                    
                                    NSArray * requestParameters = [[NSArray alloc] initWithObjects:(SearchQuery *)[self.searchResults objectAtIndex:0], [NSNumber numberWithInt:0], nil];
                                    
                                    [self performRestGet:GET_SEARCH_RESULTS_WITHIN_PRODUCTS withParamaters:requestParameters];
                                    
                                    NSLog(@"Search succeed!");
                                    
                                    break;
                                }
                            }
                            
                        }
                    }
                }
                
                self.searchResults = nil;
                
                [self actionAfterSuccessfulAnswerToRestConnection:FINISHED_SEARCH_WITHOUT_RESULTS WithResult:mappingResult];
                
                break;
            }
            case GET_SEARCH_GROUPS_WITHIN_BRAND_PRODUCTS:
            {
                if(self.searchResults == nil)
                {
                    self.searchResults = [[NSMutableArray alloc] init];
                }
                
                // Get the results groups that were provided
                [mappingResult enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
                 {
                     if (([obj isKindOfClass:[ResultsGroup class]]))
                     {
                         [self.searchResults addObject:obj];
                         
                         //                         if(!(obj == nil))
                         //                         {
                         //                             if(!([((ResultsGroup*) obj) idResultsGroup] == nil))
                         //                             {
                         //                                 if(!([[((ResultsGroup*) obj) idResultsGroup] isEqualToString:@""]))
                         //                                 {
                         //                                     [self performRestGet:GET_SEARCH_GROUP_KEYWORDS withParamaters:[[NSArray alloc] initWithObjects:[((ResultsGroup*) obj) idResultsGroup], nil]];
                         //                                 }
                         //
                         //                             }
                         //                         }
                     }
                 }];
                
                if( !(self.searchResults == nil))
                {
                    if([self.searchResults count] > 0)
                    {
                        if(!([self.searchResults objectAtIndex:0] == nil))
                        {
                            if([[self.searchResults objectAtIndex:0] isKindOfClass:[SearchQuery class]])
                            {
                                if([((SearchQuery *)[self.searchResults objectAtIndex:0]) numresults] > 0)
                                {
                                    // Once performed the search, request the results
                                    
                                    //                                    [self stopActivityFeedback];
                                    //                                    [self startActivityFeedbackWithMessage:NSLocalizedString(@"_DOWNLOADING_ACTV_MSG_", nil)];
                                    
                                    NSArray * requestParameters = [[NSArray alloc] initWithObjects:(SearchQuery *)[self.searchResults objectAtIndex:0], [NSNumber numberWithInt:0], nil];
                                    
                                    [self performRestGet:GET_SEARCH_RESULTS_WITHIN_BRAND_PRODUCTS withParamaters:requestParameters];
                                    
                                    NSLog(@"Search succeed!");
                                    
                                    break;
                                }
                            }
                            
                        }
                    }
                }
                
                self.searchResults = nil;
                
                [self actionAfterSuccessfulAnswerToRestConnection:FINISHED_BRANDPRODUCTSSEARCH_WITHOUT_RESULTS WithResult:mappingResult];
                
                break;
            }
            case GET_SEARCH_GROUPS_WITHIN_TRENDING:
            {
                if(self.searchResults == nil)
                {
                    self.searchResults = [[NSMutableArray alloc] init];
                }
                
                // Get the results groups that were provided
                [mappingResult enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
                 {
                     if (([obj isKindOfClass:[ResultsGroup class]]))
                     {
                         [self.searchResults addObject:obj];
                         
                         //                         if(!(obj == nil))
                         //                         {
                         //                             if(!([((ResultsGroup*) obj) idResultsGroup] == nil))
                         //                             {
                         //                                 if(!([[((ResultsGroup*) obj) idResultsGroup] isEqualToString:@""]))
                         //                                 {
                         //                                     [self performRestGet:GET_SEARCH_GROUP_KEYWORDS withParamaters:[[NSArray alloc] initWithObjects:[((ResultsGroup*) obj) idResultsGroup], nil]];
                         //                                 }
                         //
                         //                             }
                         //                         }
                     }
                 }];
                
                if( !(self.searchResults == nil))
                {
                    if([self.searchResults count] > 0)
                    {
                        if(!([self.searchResults objectAtIndex:0] == nil))
                        {
                            if([[self.searchResults objectAtIndex:0] isKindOfClass:[SearchQuery class]])
                            {
                                if([((SearchQuery *)[self.searchResults objectAtIndex:0]) numresults] > 0)
                                {
                                    // Once performed the search, request the results
                                    
                                    //                                    [self stopActivityFeedback];
                                    //                                    [self startActivityFeedbackWithMessage:NSLocalizedString(@"_DOWNLOADING_ACTV_MSG_", nil)];
                                    
                                    NSArray * requestParameters = [[NSArray alloc] initWithObjects:(SearchQuery *)[self.searchResults objectAtIndex:0], [NSNumber numberWithInt:0], nil];
                                    
                                    [self performRestGet:GET_SEARCH_RESULTS_WITHIN_TRENDING withParamaters:requestParameters];
                                    
                                    NSLog(@"Search succeed!");
                                    
                                    break;
                                }
                            }
                            
                        }
                    }
                }
                
                self.searchResults = nil;
                
                [self actionAfterSuccessfulAnswerToRestConnection:FINISHED_SEARCH_WITHOUT_RESULTS WithResult:mappingResult];
                
                break;
            }
            case GET_SEARCH_GROUPS_WITHIN_DISCOVER:
            {
                if(self.searchResults == nil)
                {
                    self.searchResults = [[NSMutableArray alloc] init];
                }
                
                // Get the results groups that were provided
                [mappingResult enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
                 {
                     if (([obj isKindOfClass:[ResultsGroup class]]))
                     {
                         [self.searchResults addObject:obj];
                     }
                 }];
                
                if( !(self.searchResults == nil))
                {
                    if([self.searchResults count] > 0)
                    {
                        if(!([self.searchResults objectAtIndex:0] == nil))
                        {
                            if([[self.searchResults objectAtIndex:0] isKindOfClass:[SearchQuery class]])
                            {
                                if([((SearchQuery *)[self.searchResults objectAtIndex:0]) numresults] > 0)
                                {
                                    // Once performed the search, request the results
                                    
                                    NSArray * requestParameters = [[NSArray alloc] initWithObjects:(SearchQuery *)[self.searchResults objectAtIndex:0], [NSNumber numberWithInt:0], nil];
                                    
                                    [self performRestGet:GET_SEARCH_RESULTS_WITHIN_DISCOVER withParamaters:requestParameters];
                                    
                                    NSLog(@"Search succeed!");
                                    
                                    break;
                                }
                            }
                            
                        }
                    }
                }
                
                self.searchResults = nil;
                
                [self actionAfterSuccessfulAnswerToRestConnection:FINISHED_SEARCH_WITHOUT_RESULTS WithResult:mappingResult];
                
                break;
            }
            case GET_SEARCH_RESULTS_WITHIN_DISCOVER:
            {
                if (self.searchResults == nil)
                {
                    self.searchResults = [[NSMutableArray alloc] init];
                }
                [self.searchResults addObjectsFromArray:mappingResult];
                
                NSLog(@"Getting search discover succeed!");
                
                [self actionAfterSuccessfulAnswerToRestConnection:FINISHED_SEARCH_WITH_RESULTS WithResult:self.searchResults];
                
                self.searchResults = nil;
                
                break;
            }
            case GET_SEARCH_RESULTS_WITHIN_NEWSFEED:
            case GET_SEARCH_RESULTS_WITHIN_LIKES:
            {
                if (self.searchResults == nil)
                {
                    self.searchResults = [[NSMutableArray alloc] init];
                }
                [self.searchResults addObjectsFromArray:mappingResult];
                
                // Now, request the keywords that succeed
                
                if (!(self.searchResults == nil))
                {
                    if ([self.searchResults count] > 1)
                    {
                        [self actionAfterSuccessfulAnswerToRestConnection:FINISHED_SEARCH_WITH_RESULTS WithResult:self.searchResults];
                        /*
                         searchQuery = [self.searchResults objectAtIndex:0];
                         
                         NSArray * requestParameters = [[NSArray alloc] initWithObjects:searchQuery.idSearchQuery, nil];
                         
                         [self performRestGet:GET_SEARCH_KEYWORDS withParamaters:requestParameters];
                         
                         NSLog(@"Getting products succeed!");
                         */
                        
                        self.searchResults = nil;
                        break;
                    }
                }
                
                [self actionAfterSuccessfulAnswerToRestConnection:FINISHED_SEARCH_WITHOUT_RESULTS WithResult:mappingResult];
                break;
            }
            case GET_SEARCH_GROUPS_WITHIN_NEWSFEED:
            {
                if(self.searchResults == nil)
                {
                    self.searchResults = [[NSMutableArray alloc] init];
                }
                
                // Get the results groups that were provided
                [mappingResult enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
                 {
                     if (([obj isKindOfClass:[ResultsGroup class]]))
                     {
                         [self.searchResults addObject:obj];
                     }
                 }];
                
                if( !(self.searchResults == nil))
                {
                    if([self.searchResults count] > 0)
                    {
                        if(!([self.searchResults objectAtIndex:0] == nil))
                        {
                            if([[self.searchResults objectAtIndex:0] isKindOfClass:[SearchQuery class]])
                            {
                                if([((SearchQuery *)[self.searchResults objectAtIndex:0]) numresults] > 0)
                                {
                                    // Once performed the search, request the results
                                    
                                    NSArray * requestParameters = [[NSArray alloc] initWithObjects:(SearchQuery *)[self.searchResults objectAtIndex:0], [NSNumber numberWithInt:0], nil];
                                    
                                    [self performRestGet:GET_SEARCH_RESULTS_WITHIN_NEWSFEED withParamaters:requestParameters];
                                    
                                    NSLog(@"Search succeed!");
                                    
                                    break;
                                }
                            }
                            
                        }
                    }
                }
                
                self.searchResults = nil;
                
                [self actionAfterSuccessfulAnswerToRestConnection:FINISHED_SEARCH_WITHOUT_RESULTS WithResult:mappingResult];
                
                break;
            }
            case GET_SEARCH_GROUPS_WITHIN_HISTORY:
            {
                if(self.searchResults == nil)
                {
                    self.searchResults = [[NSMutableArray alloc] init];
                }
                
                // Get the results groups that were provided
                [mappingResult enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
                 {
                     if (([obj isKindOfClass:[ResultsGroup class]]))
                     {
                         [self.searchResults addObject:obj];
                         
                         //                         if(!(obj == nil))
                         //                         {
                         //                             if(!([((ResultsGroup*) obj) idResultsGroup] == nil))
                         //                             {
                         //                                 if(!([[((ResultsGroup*) obj) idResultsGroup] isEqualToString:@""]))
                         //                                 {
                         //                                     [self performRestGet:GET_SEARCH_GROUP_KEYWORDS withParamaters:[[NSArray alloc] initWithObjects:[((ResultsGroup*) obj) idResultsGroup], nil]];
                         //                                 }
                         //
                         //                             }
                         //                         }
                     }
                 }];
                
                if( !(self.searchResults == nil))
                {
                    if([self.searchResults count] > 0)
                    {
                        if(!([self.searchResults objectAtIndex:0] == nil))
                        {
                            if([[self.searchResults objectAtIndex:0] isKindOfClass:[SearchQuery class]])
                            {
                                if([((SearchQuery *)[self.searchResults objectAtIndex:0]) numresults] > 0)
                                {
                                    // Once performed the search, request the results
                                    
                                    //                                    [self stopActivityFeedback];
                                    //                                    [self startActivityFeedbackWithMessage:NSLocalizedString(@"_DOWNLOADING_ACTV_MSG_", nil)];
                                    
                                    NSArray * requestParameters = [[NSArray alloc] initWithObjects:(SearchQuery *)[self.searchResults objectAtIndex:0], [NSNumber numberWithInt:0], nil];
                                    
                                    [self performRestGet:GET_SEARCH_RESULTS_WITHIN_HISTORY withParamaters:requestParameters];
                                    
                                    NSLog(@"Search succeed!");
                                    
                                    break;
                                }
                            }
                            
                        }
                    }
                }
                
                self.searchResults = nil;
                
                [self actionAfterSuccessfulAnswerToRestConnection:FINISHED_SEARCH_WITHOUT_RESULTS WithResult:mappingResult];
                
                break;
            }
            case GET_SEARCH_GROUPS_WITHIN_FASHIONISTAPOSTS:
            {
                if(self.searchResults == nil)
                {
                    self.searchResults = [[NSMutableArray alloc] init];
                }
                
                // Get the results groups that were provided
                [mappingResult enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
                 {
                     if (([obj isKindOfClass:[ResultsGroup class]]))
                     {
                         [self.searchResults addObject:obj];
                         
                         //                         if(!(obj == nil))
                         //                         {
                         //                             if(!([((ResultsGroup*) obj) idResultsGroup] == nil))
                         //                             {
                         //                                 if(!([[((ResultsGroup*) obj) idResultsGroup] isEqualToString:@""]))
                         //                                 {
                         //                                     [self performRestGet:GET_SEARCH_GROUP_KEYWORDS withParamaters:[[NSArray alloc] initWithObjects:[((ResultsGroup*) obj) idResultsGroup], nil]];
                         //                                 }
                         //
                         //                             }
                         //                         }
                     }
                 }];
                
                if( !(self.searchResults == nil))
                {
                    if([self.searchResults count] > 0)
                    {
                        if(!([self.searchResults objectAtIndex:0] == nil))
                        {
                            if([[self.searchResults objectAtIndex:0] isKindOfClass:[SearchQuery class]])
                            {
                                if([((SearchQuery *)[self.searchResults objectAtIndex:0]) numresults] > 0)
                                {
                                    // Once performed the search, request the results
                                    
                                    //                                    [self stopActivityFeedback];
                                    //                                    [self startActivityFeedbackWithMessage:NSLocalizedString(@"_DOWNLOADING_ACTV_MSG_", nil)];
                                    
                                    NSArray * requestParameters = [[NSArray alloc] initWithObjects:(SearchQuery *)[self.searchResults objectAtIndex:0], [NSNumber numberWithInt:0], nil];
                                    
                                    [self performRestGet:GET_SEARCH_RESULTS_WITHIN_FASHIONISTAPOSTS withParamaters:requestParameters];
                                    
                                    NSLog(@"Search succeed!");
                                    
                                    break;
                                }
                            }
                            
                        }
                    }
                }
                
                self.searchResults = nil;
                
                [self actionAfterSuccessfulAnswerToRestConnection:FINISHED_SEARCH_WITHOUT_RESULTS WithResult:mappingResult];
                
                break;
            }
            case GET_SEARCH_GROUPS_WITHIN_FASHIONISTAS:
            {
                if(self.searchResults == nil)
                {
                    self.searchResults = [[NSMutableArray alloc] init];
                }
                
                // Get the results groups that were provided
                [mappingResult enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
                 {
                     if (([obj isKindOfClass:[ResultsGroup class]]))
                     {
                         [self.searchResults addObject:obj];
                         
                         //                         if(!(obj == nil))
                         //                         {
                         //                             if(!([((ResultsGroup*) obj) idResultsGroup] == nil))
                         //                             {
                         //                                 if(!([[((ResultsGroup*) obj) idResultsGroup] isEqualToString:@""]))
                         //                                 {
                         //                                     [self performRestGet:GET_SEARCH_GROUP_KEYWORDS withParamaters:[[NSArray alloc] initWithObjects:[((ResultsGroup*) obj) idResultsGroup], nil]];
                         //                                 }
                         //
                         //                             }
                         //                         }
                     }
                 }];
                
                if( !(self.searchResults == nil))
                {
                    if([self.searchResults count] > 0)
                    {
                        if(!([self.searchResults objectAtIndex:0] == nil))
                        {
                            if([[self.searchResults objectAtIndex:0] isKindOfClass:[SearchQuery class]])
                            {
                                if([((SearchQuery *)[self.searchResults objectAtIndex:0]) numresults] > 0)
                                {
                                    // Once performed the search, request the results
                                    
                                    //                                    [self stopActivityFeedback];
                                    //                                    [self startActivityFeedbackWithMessage:NSLocalizedString(@"_DOWNLOADING_ACTV_MSG_", nil)];
                                    
                                    NSArray * requestParameters = [[NSArray alloc] initWithObjects:(SearchQuery *)[self.searchResults objectAtIndex:0], [NSNumber numberWithInt:0], nil];
                                    
                                    [self performRestGet:GET_SEARCH_RESULTS_WITHIN_FASHIONISTAS withParamaters:requestParameters];
                                    
                                    NSLog(@"Search succeed!");
                                    
                                    break;
                                }
                            }
                            
                        }
                    }
                }
                
                self.searchResults = nil;
                
                [self actionAfterSuccessfulAnswerToRestConnection:FINISHED_SEARCH_WITHOUT_RESULTS WithResult:mappingResult];
                
                break;
            }
            case GET_SEARCH_GROUPS_WITHIN_STYLES:
            {
                if(self.searchResults == nil)
                {
                    self.searchResults = [[NSMutableArray alloc] init];
                }
                
                // Get the results groups that were provided
                [mappingResult enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
                 {
                     if (([obj isKindOfClass:[ResultsGroup class]]))
                     {
                         [self.searchResults addObject:obj];
                         
                         //                         if(!(obj == nil))
                         //                         {
                         //                             if(!([((ResultsGroup*) obj) idResultsGroup] == nil))
                         //                             {
                         //                                 if(!([[((ResultsGroup*) obj) idResultsGroup] isEqualToString:@""]))
                         //                                 {
                         //                                     [self performRestGet:GET_SEARCH_GROUP_KEYWORDS withParamaters:[[NSArray alloc] initWithObjects:[((ResultsGroup*) obj) idResultsGroup], nil]];
                         //                                 }
                         //
                         //                             }
                         //                         }
                     }
                 }];
                
                if( !(self.searchResults == nil))
                {
                    if([self.searchResults count] > 0)
                    {
                        if(!([self.searchResults objectAtIndex:0] == nil))
                        {
                            if([[self.searchResults objectAtIndex:0] isKindOfClass:[SearchQuery class]])
                            {
                                if([((SearchQuery *)[self.searchResults objectAtIndex:0]) numresults] > 0)
                                {
                                    // Once performed the search, request the results
                                    
                                    //                                    [self stopActivityFeedback];
                                    //                                    [self startActivityFeedbackWithMessage:NSLocalizedString(@"_DOWNLOADING_ACTV_MSG_", nil)];
                                    
                                    NSArray * requestParameters = [[NSArray alloc] initWithObjects:(SearchQuery *)[self.searchResults objectAtIndex:0], [NSNumber numberWithInt:0], nil];
                                    
                                    [self performRestGet:GET_SEARCH_RESULTS_WITHIN_STYLES withParamaters:requestParameters];
                                    
                                    NSLog(@"Search succeed!");
                                    
                                    break;
                                }
                            }
                            
                        }
                    }
                }
                
                self.searchResults = nil;
                
                [self actionAfterSuccessfulAnswerToRestConnection:FINISHED_GETTHELOOK_WITHOUT_RESULTS WithResult:mappingResult];
                
                break;
            }
            case GET_SEARCH_GROUPS_WITHIN_BRANDS:
            {
                if(self.searchResults == nil)
                {
                    self.searchResults = [[NSMutableArray alloc] init];
                }
                
                // Get the results groups that were provided
                [mappingResult enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
                 {
                     if (([obj isKindOfClass:[ResultsGroup class]]))
                     {
                         [self.searchResults addObject:obj];
                         
                         //                         if(!(obj == nil))
                         //                         {
                         //                             if(!([((ResultsGroup*) obj) idResultsGroup] == nil))
                         //                             {
                         //                                 if(!([[((ResultsGroup*) obj) idResultsGroup] isEqualToString:@""]))
                         //                                 {
                         //                                     [self performRestGet:GET_SEARCH_GROUP_KEYWORDS withParamaters:[[NSArray alloc] initWithObjects:[((ResultsGroup*) obj) idResultsGroup], nil]];
                         //                                 }
                         //
                         //                             }
                         //                         }
                     }
                 }];
                
                if( !(self.searchResults == nil))
                {
                    if([self.searchResults count] > 0)
                    {
                        if(!([self.searchResults objectAtIndex:0] == nil))
                        {
                            if([[self.searchResults objectAtIndex:0] isKindOfClass:[SearchQuery class]])
                            {
                                if([((SearchQuery *)[self.searchResults objectAtIndex:0]) numresults] > 0)
                                {
                                    // Once performed the search, request the results
                                    
                                    //                                    [self stopActivityFeedback];
                                    //                                    [self startActivityFeedbackWithMessage:NSLocalizedString(@"_DOWNLOADING_ACTV_MSG_", nil)];
                                    
                                    NSArray * requestParameters = [[NSArray alloc] initWithObjects:(SearchQuery *)[self.searchResults objectAtIndex:0], [NSNumber numberWithInt:0], nil];
                                    
                                    [self performRestGet:GET_SEARCH_RESULTS_WITHIN_BRANDS withParamaters:requestParameters];
                                    
                                    NSLog(@"Search succeed!");
                                    
                                    break;
                                }
                            }
                            
                        }
                    }
                }
                
                self.searchResults = nil;
                
                [self actionAfterSuccessfulAnswerToRestConnection:FINISHED_SEARCH_WITHOUT_RESULTS WithResult:mappingResult];
                
                break;
            }
            case PERFORM_VISUAL_SEARCH:
            case GET_DETECTION_STATUS:
            {
                NSNumber * state = [[mappingResult firstObject] valueForKey:@"state"];
                NSString * idDetection = [[mappingResult firstObject] valueForKey:@"id"];
                
                if(!(state == nil))
                {
                    if ([state intValue] < 0)
                    {
                        if(numRetries < MAX_RETRIES)
                        {
                            if(!(idDetection == nil))
                            {
                                if(!([idDetection isEqualToString:@""]))
                                {
                                    sleep(SLEEPTIME);
                                    
                                    [self performRestGet:GET_DETECTION_STATUS withParamaters:[NSArray arrayWithObject:idDetection]];
                                    
                                    break;
                                }
                            }
                        }
                    }
                    else
                    {
                        NSString * stringToSearch = [[mappingResult firstObject] valueForKey:@"ext_name"];
                        BOOL bComingFromFashionistaContext = NO;
                        
                        if(((VisualSearchViewController *)self).currentVisualSearchContext == FASHIONISTAPOSTS_VISUAL_SEARCH)
                        {
                            stringToSearch = [[mappingResult firstObject] valueForKey:@"cat_name"];
                        }
                        
                        if(!(stringToSearch == nil))
                        {
                            if (!([stringToSearch isEqualToString:@""]))
                            {
                                [self stopActivityFeedback];
                                [self startActivityFeedbackWithMessage:NSLocalizedString(@"_SEARCHING_ACTV_MSG_", nil)];
                                
                                stringToSearch = [self composeStringhWithTermsOfArray:[NSArray arrayWithObject:stringToSearch] encoding:YES];
                                
                                if(bComingFromFashionistaContext)
                                {
                                    NSArray * requestParameters = [[NSArray alloc] initWithObjects:stringToSearch, @"", @"all", nil];
                                    
                                    [self performRestGet:PERFORM_SEARCH_WITHIN_FASHIONISTAPOSTS withParamaters:requestParameters];
                                }
                                else
                                {
                                    NSArray * requestParameters = [[NSArray alloc] initWithObjects:stringToSearch, nil];
                                    
                                    [self performRestGet:PERFORM_SEARCH_WITHIN_PRODUCTS withParamaters:requestParameters];
                                }
                                
                                NSLog(@"Visual identification succeed!");
                                
                                break;
                            }
                        }
                    }
                }
                
                self.searchResults = nil;
                numRetries = 0;
                
                [self actionAfterSuccessfulAnswerToRestConnection:FINISHED_SEARCH_WITHOUT_RESULTS WithResult:mappingResult];
                
                break;
            }
            case GET_SEARCH_RESULTS_WITHIN_FASHIONISTAS:
            {
                if (self.searchResults == nil)
                {
                    self.searchResults = [[NSMutableArray alloc] init];
                }
                [self.searchResults addObjectsFromArray:mappingResult];
                
                NSLog(@"Getting search results within fashionistas succeed!");
                
                [self actionAfterSuccessfulAnswerToRestConnection:FINISHED_SEARCH_WITH_RESULTS WithResult:self.searchResults];
                
                self.searchResults = nil;
                
                break;
            }
            case GET_SEARCH_RESULTS_WITHIN_FASHIONISTAPOSTS:
            {
                if (self.searchResults == nil)
                {
                    self.searchResults = [[NSMutableArray alloc] init];
                }
                [self.searchResults addObjectsFromArray:mappingResult];
                
                NSLog(@"Getting search results within fashionista posts succeed!");
                
                [self actionAfterSuccessfulAnswerToRestConnection:FINISHED_SEARCH_WITH_RESULTS WithResult:self.searchResults];
                
                self.searchResults = nil;
                
                break;
            }
            case GET_SEARCH_RESULTS_WITHIN_FASHIONISTAWARDROBES:
            {
                if (self.searchResults == nil)
                {
                    self.searchResults = [[NSMutableArray alloc] init];
                }
                [self.searchResults addObjectsFromArray:mappingResult];
                
                NSLog(@"Getting search results within fashionista posts succeed!");
                
                [self actionAfterSuccessfulAnswerToRestConnection:FINISHED_SEARCH_WITH_WARDROBES WithResult:self.searchResults];
                
                self.searchResults = nil;
                
                break;
            }
            case GET_SEARCH_RESULTS_WITHIN_PRODUCTS:
            case GET_SEARCH_RESULTS_WITHIN_TRENDING:
            case GET_SEARCH_RESULTS_WITHIN_HISTORY:
            case GET_SEARCH_RESULTS_WITHIN_BRANDS:
            {
                if (self.searchResults == nil)
                {
                    self.searchResults = [[NSMutableArray alloc] init];
                }
                [self.searchResults addObjectsFromArray:mappingResult];
                
                // Now, request the keywords that succeed
                
                if (!(self.searchResults == nil))
                {
                    if ([self.searchResults count] > 1)
                    {
                        if([[self.searchResults objectAtIndex:0] isKindOfClass:[SearchQuery class]]){
                            if([((SearchQuery *)[self.searchResults objectAtIndex:0]) numresults] > 0)
                            {
                                searchQuery = [self.searchResults objectAtIndex:0];
                                
                                NSArray * requestParameters = [[NSArray alloc] initWithObjects:searchQuery.idSearchQuery, nil];
                                
                                [self performRestGet:GET_SEARCH_KEYWORDS withParamaters:requestParameters];
                                
                                NSLog(@"Getting products succeed!");
                                
                                break;
                            }
                        }
                    }
                }
                
                [self actionAfterSuccessfulAnswerToRestConnection:FINISHED_SEARCH_WITHOUT_RESULTS WithResult:mappingResult];
                
                break;
            }
            case GET_SEARCH_RESULTS_WITHIN_STYLES:
            {
                if (self.searchResults == nil)
                {
                    self.searchResults = [[NSMutableArray alloc] init];
                }
                [self.searchResults addObjectsFromArray:mappingResult];
                
                // Now, request the keywords that succeed
                
                if (!(self.searchResults == nil))
                {
                    if ([self.searchResults count] > 1)
                    {
                        if([[self.searchResults objectAtIndex:0] isKindOfClass:[SearchQuery class]]){
                            if([((SearchQuery *)[self.searchResults objectAtIndex:0]) numresults] > 0)
                            {
                                searchQuery = [self.searchResults objectAtIndex:0];
                                
                                NSArray * requestParameters = [[NSArray alloc] initWithObjects:searchQuery.idSearchQuery, nil];
                                
                                [self performRestGet:GET_STYLESSEARCH_KEYWORDS withParamaters:requestParameters];
                                
                                NSLog(@"Getting products succeed!");
                                
                                break;
                            }
                        }
                    }
                }
                
                [self actionAfterSuccessfulAnswerToRestConnection:FINISHED_GETTHELOOK_WITHOUT_RESULTS WithResult:mappingResult];
                
                break;
            }
            case GET_SEARCH_RESULTS_WITHIN_BRAND_PRODUCTS:
            {
                if (self.searchResults == nil)
                {
                    self.searchResults = [[NSMutableArray alloc] init];
                }
                [self.searchResults addObjectsFromArray:mappingResult];
                
                // Now, request the keywords that succeed
                
                if (!(self.searchResults == nil))
                {
                    if ([self.searchResults count] > 1)
                    {
                        if([[self.searchResults objectAtIndex:0] isKindOfClass:[SearchQuery class]]){
                            if([((SearchQuery *)[self.searchResults objectAtIndex:0]) numresults] > 0)
                            {
                                searchQuery = [self.searchResults objectAtIndex:0];
                                
                                NSArray * requestParameters = [[NSArray alloc] initWithObjects:searchQuery.idSearchQuery, nil];
                                
                                [self performRestGet:GET_BRANDPRODUCTSSEARCH_KEYWORDS withParamaters:requestParameters];
                                
                                NSLog(@"Getting products succeed!");
                                
                                break;
                            }
                        }
                    }
                }
                
                [self actionAfterSuccessfulAnswerToRestConnection:FINISHED_BRANDPRODUCTSSEARCH_WITHOUT_RESULTS WithResult:mappingResult];
                
                break;
            }
            case GET_SEARCH_KEYWORDS:
            {
                if (self.searchResults == nil)
                {
                    self.searchResults = [[NSMutableArray alloc] init];
                }
                [self.searchResults addObjectsFromArray:mappingResult];
                
                NSLog(@"Getting search keywords succeed!");
                
                [self actionAfterSuccessfulAnswerToRestConnection:FINISHED_SEARCH_WITH_RESULTS WithResult:self.searchResults];
                
                self.searchResults = nil;
                
                break;
            }
            case GET_STYLESSEARCH_KEYWORDS:
            {
                if (self.searchResults == nil)
                {
                    self.searchResults = [[NSMutableArray alloc] init];
                }
                [self.searchResults addObjectsFromArray:mappingResult];
                
                NSLog(@"Getting search keywords succeed!");
                
                [self actionAfterSuccessfulAnswerToRestConnection:FINISHED_STYLESSEARCH_WITH_RESULTS WithResult:self.searchResults];
                
                self.searchResults = nil;
                
                break;
            }
            case GET_BRANDPRODUCTSSEARCH_KEYWORDS:
            {
                if (self.searchResults == nil)
                {
                    self.searchResults = [[NSMutableArray alloc] init];
                }
                [self.searchResults addObjectsFromArray:mappingResult];
                
                NSLog(@"Getting search keywords succeed!");
                
                [self actionAfterSuccessfulAnswerToRestConnection:FINISHED_BRANDPRODUCTSSEARCH_WITH_RESULTS WithResult:self.searchResults];
                
                self.searchResults = nil;
                
                break;
            }
            case GET_PRODUCT:
            {
                [_productContents addObjectsFromArray:mappingResult];
                
                // Now, request the product reviews
                if (!(_productContents == nil))
                {
                    if ([_productContents count] > 0)
                    {
                        if([[_productContents objectAtIndex:0] isKindOfClass:[Product class]])
                        {
                            Product * p =((Product *)([_productContents objectAtIndex:0]));
                            product = p.idProduct; //(NSString *)[((Product *)([_productContents objectAtIndex:0])) idProduct];
                            
                            NSArray * requestParameters = [[NSArray alloc] initWithObjects:product, nil];
                            
                            [self performRestGet:GET_PRODUCT_CONTENT withParamaters:requestParameters];
                            
                            NSLog(@"Getting product succeed!");
                            
                            if (p.size_array == nil)
                            {
                                NSLog(@"Size_Array nil");
                            }
                            else
                            {
                                for (NSString * s in p.size_array)
                                {
                                    NSLog(@"Size %@", s);
                                }
                            }
                            
                            if (p.variantGroup == nil)
                            {
                                NSLog(@"Variant group is null");
                            }
                            else
                            {
                                NSLog(@"VariantGroup %@", p.variantGroup.idVariantGroup);
                                for(VariantGroupElement * vge in p.variantGroup.variants)
                                {
                                    NSLog(@"Colour %@, %@", vge.color_name , vge.color_image);
                                    NSLog(@"Material %@, %@", vge.material_name , vge.material_image);
                                    NSLog(@"ProductId %@", vge.product_id);
                                }
                            }
                            
                            break;
                        }
                    }
                }
                
                [self actionAfterSuccessfulAnswerToRestConnection:connection WithResult:mappingResult];
                
                break;
            }
            case GET_PRODUCT_CONTENT:
            {
                [_productContents addObjectsFromArray:mappingResult];
                
                // Now, request the product reviews
                if (!(_productContents == nil))
                {
                    if ([_productContents count] > 0)
                    {
                        if([[_productContents objectAtIndex:0] isKindOfClass:[Product class]])
                        {
                            product = (NSString *)[((Product *)([_productContents objectAtIndex:0])) idProduct];
                            
                            NSArray * requestParameters = [[NSArray alloc] initWithObjects:product, nil];
                            
                            [self performRestGet:GET_PRODUCT_REVIEWS withParamaters:requestParameters];
                            
                            NSLog(@"Getting product content succeed!");
                            
                            break;
                        }
                    }
                }
                
                [self actionAfterSuccessfulAnswerToRestConnection:GET_PRODUCT WithResult:mappingResult];
                
                break;
            }
            case GET_PRODUCT_AVAILABILITY:
            {
                
                [_productContents addObjectsFromArray:mappingResult];
                
                // Now, request the product reviews
//                if (!(_productAvailabilities == nil))
//                {
//                    if ([_productAvailabilities count] > 0)
//                    {
//                        for(NSObject * object in _productAvailabilities)
//                        {
//                            if([object isKindOfClass:[ProductAvailability class]])
//                            {
//                                
//                                
//                                ProductAvailability * p_availability =((ProductAvailability *)object);
//                                
//                                NSLog(@"Getting product availability succeed!");
//                                
//                                BOOL bOnline = NO;
//                                if ([p_availability.online boolValue])
//                                {
//                                    NSLog(@"Online: YES");
//                                    bOnline = YES;
//                                }
//                                else
//                                {
//                                    NSLog(@"Online: NO");
//                                    bOnline = NO;
//                                }
//                                
//                                if (bOnline)
//                                {
//                                    NSLog(@"Website %@", p_availability.website);
//                                }
//                                
//                                NSLog(@"storename %@", p_availability.storename);
//                                NSLog(@"address %@", p_availability.address);
//                                NSLog(@"zipcode %@", p_availability.zipcode);
//                                NSLog(@"state %@", p_availability.state);
//                                NSLog(@"city %@", p_availability.city);
//                                NSLog(@"country %@", p_availability.country);
//                                NSLog(@"telephone %@", p_availability.telephone);
//                                NSLog(@"latitude %f", [p_availability.latitude floatValue]);
//                                NSLog(@"longitude %f", [p_availability.longitude floatValue]);
//                                
//                            }
//                        }
//                        
//                        [self actionAfterSuccessfulAnswerToRestConnection:GET_PRODUCT WithResult:mappingResult];
//                        
//                        break;
//                    }
//                }
                
                [self actionAfterSuccessfulAnswerToRestConnection:GET_PRODUCT WithResult:_productContents];
                _productContents = nil;
                
                break;
            }
            case GET_USER:
            {
                [self actionAfterSuccessfulAnswerToRestConnection:GET_USER WithResult:mappingResult];
                break;
            }
            case GET_USERS_FOR_AUTOFILL:
            {
                [self actionAfterSuccessfulAnswerToRestConnection:GET_USERS_FOR_AUTOFILL WithResult:mappingResult];
                break;
            }
            case GET_PRODUCT_REVIEWS:
            {
                [_productContents addObjectsFromArray:mappingResult];
                
                if (!(_productContents == nil))
                {
                    if ([_productContents count] > 0)
                    {
                        if([[_productContents objectAtIndex:0] isKindOfClass:[Product class]])
                        {
                            product = (NSString *)[((Product *)([_productContents objectAtIndex:0])) idProduct];
                            
                            NSLog(@"Getting product reviews succeed!");
                            
                            NSString *countryCode = self.placeMark.ISOcountryCode;
                            NSString *postalCode = self.placeMark.postalCode;
                            NSString *radius = @"100";
                            NSString *lat = [NSString stringWithFormat:@"%.4F", self.placeMark.location.coordinate.latitude];
                            NSString *lon = [NSString stringWithFormat:@"%.4F", self.placeMark.location.coordinate.longitude];
                            NSArray *requestParameters = [[NSArray alloc] initWithObjects:product, countryCode, postalCode, radius, lon, lat,  nil];
                            
                            if (self.placeMark == nil) {
                                [self actionAfterSuccessfulAnswerToRestConnection:GET_PRODUCT WithResult:_productContents];
                                break;
                            }
                            [self performRestGet:GET_PRODUCT_AVAILABILITY withParamaters:requestParameters];
                            break;
                        }
                    }
                }
                
                [self actionAfterSuccessfulAnswerToRestConnection:GET_PRODUCT WithResult:_productContents];
                break;
            }
            case GET_PRODUCT_FEATURES:
            {
                [_productFeatures addObjectsFromArray:mappingResult];
                
                [self actionAfterSuccessfulAnswerToRestConnection:connection WithResult:_productFeatures];
                
                NSLog(@"Getting product features succeed!");
                
                break;
            }
                //            case GET_SIMILAR_PRODUCTS:
                //            {
                //                [_productFeatures addObjectsFromArray:mappingResult];
                //
                //                [self actionAfterSuccessfulAnswerToRestConnection:connection WithResult:_productFeatures];
                //
                //                NSLog(@"Getting product features succeed!");
                //
                //                break;
                //            }
            case GET_PRODUCT_GROUP:
            {
                [_productFeatures addObjectsFromArray:mappingResult];
                
                [self actionAfterSuccessfulAnswerToRestConnection:connection WithResult:_productFeatures];
                
                NSLog(@"Getting product group succeed!");
                
                break;
            }
            case GET_SIMILARPRODUCTS_GROUP:
            {
                [_productFeatures addObjectsFromArray:mappingResult];
                
                [self actionAfterSuccessfulAnswerToRestConnection:connection WithResult:_productFeatures];
                
                NSLog(@"Getting product group succeed!");
                
                break;
            }
            case GET_PRODUCTGROUP_FEATURES:
            {
                [_productFeatures addObjectsFromArray:mappingResult];
                
                [self actionAfterSuccessfulAnswerToRestConnection:connection WithResult:_productFeatures];
                
                NSLog(@"Getting products group features succeed!");
                
                break;
            }
            case GET_SIMILARPRODUCTS_BRAND:
            {
                NSLog(@"Getting products brands succeed!");
                
                [_productFeatures addObjectsFromArray:mappingResult];
                
                [self actionAfterSuccessfulAnswerToRestConnection:connection WithResult:_productFeatures];
                
                break;
            }
            case GET_PRODUCT_BRAND:
            case GET_SEARCHPRODUCTS_BRAND:
            {
                NSLog(@"Getting products brands succeed!");
                
                if (!(_productFeatures == nil))
                {
                    [_productFeatures addObjectsFromArray:mappingResult];
                    
                    [self actionAfterSuccessfulAnswerToRestConnection:connection WithResult:_productFeatures];
                }
                
                break;
            }
            case GET_PRODUCTGROUP_FEATURES_FOR_ADVANCED_SEARCH:
            {
                [_productGroupFeaturesGroup addObjectsFromArray:mappingResult];
                
                NSLog(@"Getting products group features for advanced search succeed!");
                
                [self actionAfterSuccessfulAnswerToRestConnection:GET_PRODUCTGROUP_FEATURES_FOR_ADVANCED_SEARCH WithResult:_productGroupFeaturesGroup];
                
                _productGroupFeaturesGroup = nil;
                
                break;
            }
            case GET_FULL_POST:
            {
                [self actionAfterSuccessfulAnswerToRestConnection:connection WithResult:mappingResult];
                break;
            }
            case GET_AD:
            {
                [self actionAfterSuccessfulAnswerToRestConnection:connection WithResult:mappingResult];
                break;
            }
            case GET_POST:
            {
                if(!_postContents){
                    _postContents = [[NSMutableArray alloc] init];
                }
                [_postContents addObjectsFromArray:mappingResult];
                
                // Now, request the post contents
                if (!(_postContents == nil))
                {
                    if ([_postContents count] > 0)
                    {
                        if([[_postContents objectAtIndex:0] isKindOfClass:[FashionistaPost class]])
                        {
                            post = (NSString *)[((FashionistaPost *)([_postContents objectAtIndex:0])) idFashionistaPost];
                            
                            NSArray * requestParameters = [[NSArray alloc] initWithObjects:post, nil];
                            
                            [self performRestGet:GET_POST_CONTENT withParamaters:requestParameters];
                            
                            //NSLog(@"Getting Fashionista post succeed!");
                            
                            break;
                        }
                        
                        NSLog(@"Getting post content succeed! But will not get post comments.");
                    }
                }
                
                [self actionAfterSuccessfulAnswerToRestConnection:connection WithResult:mappingResult];
                
                _postContents = nil;
                
                break;
            }
            case GET_POST_FOR_SHARE:
            {
                // Get the post that was provided
                for (FashionistaPost *post in mappingResult)
                {
                    if([post isKindOfClass:[FashionistaPost class]])
                    {
                        if(!(post.idFashionistaPost == nil))
                        {
                            if  (!([post.idFashionistaPost isEqualToString:@""]))
                            {
                                NSArray * parametersForNextVC = [NSArray arrayWithObjects: [NSNumber numberWithBool:YES], (FashionistaPost *)post, nil];
                                
                                if(!([parametersForNextVC count] < 2))
                                {
#ifdef OLD_POST
                                    [self transitionToViewController:CREATEPOST_VC withParameters:parametersForNextVC];
#else
                                    [self transitionToViewController:TAGGING_VC withParameters:parametersForNextVC];
#endif
                                }
                                
                                break;
                            }
                        }
                    }
                }
                
                _postContents = nil;
                
                [self stopActivityFeedback];
                
                break;
            }
            case GET_POST_CONTENT_KEYWORDS:
            {
                //                [_keywordsPostContent addObjectsFromArray:mappingResult];
                //
                //                // Check if the Fetched Results Controller is already initialized; if so, update it
                //                if (!(_keywordsPostContent == nil))
                //                {
                //                    // Check if the Fetched Results Controller is already initialized; if so, update it
                //                    if ([_keywordsPostContent count] > 0)
                //                    {
                //                        [_keywordsPostContent enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
                //                         {
                //                             if (([obj isKindOfClass:[FashionistaContent class]]))
                //                             {
                //                                 fashionistaContent = obj;
                //                                 // Stop the enumeration
                //                                 *stop = YES;
                //                             }
                //                         }];
                //
                //                        if (!(fashionistaContent == nil))
                //                        {
                //                            if(!(fashionistaContent.idFashionistaContent == nil))
                //                            {
                //                                if(!([fashionistaContent.idFashionistaContent isEqualToString:@""]))
                //                                {
                //                                    NSManagedObjectContext *currentContext = [RKObjectManager sharedManager].managedObjectStore.mainQueueManagedObjectContext;
                //
                //                                    for (Keyword *keyword in _keywordsPostContent)
                //                                    {
                //                                        if([keyword isKindOfClass:[Keyword class]])
                //                                        {
                //                                            if(!(keyword.idKeyword == nil))
                //                                            {
                //                                                if(!([keyword.idKeyword isEqualToString:@""]))
                //                                                {
                //                                                    if(!([fashionistaContent.keywords containsObject:keyword]))
                //                                                    {
                //                                                        [fashionistaContent.keywords addObject:keyword];
                //                                                    }
                //                                                }
                //                                            }
                //                                        }
                //                                    }
                //
                //                                    [currentContext refreshObject:fashionistaContent mergeChanges:YES];
                //
                //                                    [currentContext save:nil];
                //                                }
                //                            }
                //                        }
                //                    }
                //                }
                //
                //NSLog(@"Getting Fashionista post content succeed!");
                
                [self actionAfterSuccessfulAnswerToRestConnection:connection WithResult:_keywordsPostContent];
                
                //                _keywordsPostContent = nil;
                
                break;
            }
            case GET_POST_CONTENT_WARDROBE:
            {
                NSLog(@"Getting Fashionista post content wardrobe succeed!");
                
                [self actionAfterSuccessfulAnswerToRestConnection:connection WithResult:mappingResult];
                
                break;
            }
            case GET_POST_CONTENT:
            {
                [_postContents addObjectsFromArray:mappingResult];
                
                // Now, request the product reviews
                if (!(_postContents == nil))
                {
                    if ([_postContents count] > 0)
                    {
                        if([[_postContents objectAtIndex:0] isKindOfClass:[FashionistaPost class]])
                        {
                            post = (NSString *)[((FashionistaPost *)([_postContents objectAtIndex:0])) idFashionistaPost];
                            
                            NSArray * requestParameters = [[NSArray alloc] initWithObjects:post, nil];
                            
                            [self performRestGet:GET_POST_LIKES_NUMBER withParamaters:requestParameters];
                            
                            //NSLog(@"Getting post content succeed!");
                            
                            break;
                        }
                        
                        NSLog(@"Getting post content succeed! But will not get post comments.");
                    }
                }
                
                [self actionAfterSuccessfulAnswerToRestConnection:((_postContents == nil) ? (GET_POST_CONTENT) : (GET_POST)) WithResult:((_postContents == nil) ? (mappingResult) : (_postContents))];
                
                break;
            }
            case GET_ONLYPOST_LIKES_NUMBER:
            {
                //NSLog(@"Getting post likes number succeed!");
                
                [self actionAfterSuccessfulAnswerToRestConnection:connection WithResult:mappingResult];
                
                break;
            }
            case GET_POST_LIKES_NUMBER:
            {
                [_postContents addObjectsFromArray:mappingResult];
                
                // Now, request the product reviews
                if (!(_postContents == nil))
                {
                    if ([_postContents count] > 0)
                    {
                        if([[_postContents objectAtIndex:0] isKindOfClass:[FashionistaPost class]])
                        {
                            post = (NSString *)[((FashionistaPost *)([_postContents objectAtIndex:0])) idFashionistaPost];
                            
                            NSArray * requestParameters = [[NSArray alloc] initWithObjects:post, nil];
                            
                            [self performRestGet:GET_POST_COMMENTS withParamaters:requestParameters];
                            
                            //NSLog(@"Getting post likes succeed!");
                            
                            break;
                        }
                        
                        NSLog(@"Getting post content succeed! But will not get post comments.");
                    }
                }
                
                [self actionAfterSuccessfulAnswerToRestConnection:((_postContents == nil) ? (GET_POST_CONTENT) : (GET_POST)) WithResult:((_postContents == nil) ? (mappingResult) : (_postContents))];
                
                break;
            }
            case GET_FOLLOWERS_FOLLOWINGS_COUNT:
            {
                [self actionAfterSuccessfulAnswerToRestConnection:GET_FOLLOWERS_FOLLOWINGS_COUNT WithResult:mappingResult];
                break;
            }
            case GET_POST_COMMENTS:
            {
                [_postContents addObjectsFromArray:mappingResult];
                
                // Now, request the product reviews
                if (!(_postContents == nil))
                {
                    if ([_postContents count] > 0)
                    {
                        if([[_postContents objectAtIndex:0] isKindOfClass:[FashionistaPost class]])
                        {
                            author = (NSString *)[((FashionistaPost *)([_postContents objectAtIndex:0])) userId];
                            
                            NSArray * requestParameters = [[NSArray alloc] initWithObjects:author, nil];
                            
                            [self performRestGet:GET_POST_AUTHOR withParamaters:requestParameters];
                            
                            //NSLog(@"Getting post comments succeed!");
                            
                            break;
                        }
                        
                        NSLog(@"Getting post content succeed! But will not get post author.");
                    }
                }
                
                [self actionAfterSuccessfulAnswerToRestConnection:((_postContents == nil) ? (GET_POST_CONTENT) : (GET_POST)) WithResult:((_postContents == nil) ? (mappingResult) : (_postContents))];
                
                break;
            }
            case GET_POST_AUTHOR:
            {
                [_postContents addObjectsFromArray:mappingResult];
                
                //NSLog(@"Getting Fashionista post content succeed!");
                
                [self actionAfterSuccessfulAnswerToRestConnection:((_postContents == nil) ? (GET_POST_CONTENT) : (GET_POST)) WithResult:((_postContents == nil) ? (mappingResult) : (_postContents))];
                
                _postContents = nil;
                
                break;
            }
            case GET_POST_LIKES:
            case GET_USER_LIKES_POST:
            case LIKE_POST:
            case UNLIKE_POST:
            {
                //NSLog(@"Like Post  /  Unlike Post  /  Getting post likes succeed!");
                
                [self actionAfterSuccessfulAnswerToRestConnection:connection WithResult:mappingResult];
                
                break;
            }
            case GET_ALLPRODUCTCATEGORIES:
            {
                [_allProductCategory addObjectsFromArray:mappingResult];
                
                NSLog(@"Getting ALL products categories succeed!");
                
                [self actionAfterSuccessfulAnswerToRestConnection:GET_ALLPRODUCTCATEGORIES WithResult:_allProductCategory];
                
                _allProductCategory = nil;
                break;
            }
            case GET_ALLFEATURES:
            {
                [_allFeatures addObjectsFromArray:mappingResult];
                
                NSLog(@"Getting ALL features succeed!");
                
                [self actionAfterSuccessfulAnswerToRestConnection:GET_ALLFEATURES WithResult:_allFeatures];
                
                _allFeatures = nil;
                
                break;
            }
            case GET_ALLFEATUREGROUPS:
            {
                [_allFeatures addObjectsFromArray:mappingResult];
                
                NSLog(@"Getting ALL feature Groups succeed!");
                
                [self actionAfterSuccessfulAnswerToRestConnection:GET_ALLFEATUREGROUPS WithResult:_allFeatures];
                
                _allFeatures = nil;
                
                break;
            }
            case GET_PRODUCTCATEGORIES:
            {
                if (_productCategories == nil)
                {
                    _productCategories = [[NSMutableArray alloc] init];
                }
                
                [_productCategories addObjectsFromArray:mappingResult];
                
                NSLog(@"Getting products categories succeed!");
                
                [self actionAfterSuccessfulAnswerToRestConnection:GET_PRODUCTCATEGORIES WithResult:_productCategories];
                
                _productCategories = nil;
                
                break;
            }
            case GET_SUBPRODUCTSCATEGORIES:
            {
                [_subProductCategories addObjectsFromArray:mappingResult];
                
                NSLog(@"Getting sub-products categories succeed!");
                
                [self actionAfterSuccessfulAnswerToRestConnection:GET_SUBPRODUCTSCATEGORIES WithResult:_subProductCategories];
                
                _subProductCategories = nil;
                
                break;
            }
            case GET_PRIORITYBRANDS:
            {
                [_priorityBrands addObjectsFromArray:mappingResult];
                
                NSLog(@"Getting brands priority with product ctagories succeed!");
                
                [self actionAfterSuccessfulAnswerToRestConnection:GET_PRIORITYBRANDS WithResult:_priorityBrands];
                
                _priorityBrands = nil;
                
                break;
            }
            case GET_ALLBRANDS:
            {
                [_allBrands addObjectsFromArray:mappingResult];
                
                NSLog(@"Getting all brands succeed!");
                
                [self actionAfterSuccessfulAnswerToRestConnection:GET_ALLBRANDS WithResult:_priorityBrands];
                
                _allBrands = nil;
                
                break;
            }
            case GET_FEATUREGROUP_FEATURES:
            {
                [_featureGroupFeatures addObjectsFromArray:mappingResult];
                
                NSLog(@"Getting feature group features succeed!");
                
                [self actionAfterSuccessfulAnswerToRestConnection:GET_FEATUREGROUP_FEATURES WithResult:_featureGroupFeatures];
                
                _featureGroupFeatures = nil;
                
                break;
            }
            case GET_USER_WARDROBES:
            {
                if (!(mappingResult == nil))
                {
                    NSLog(@"Getting user wardrobes succeed!");
                    
                    // Get the list of wardrobes that were provided to request their products
                    for (Wardrobe *wardrobe in mappingResult)
                    {
                        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                        
                        if(!(appDelegate.addingProductsToWardrobeID == nil))
                        {
                            if([appDelegate.addingProductsToWardrobeID isEqualToString:((Wardrobe *)(wardrobe)).idWardrobe])
                            {
                                //NSLog(@"XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX\nOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOO");
                            }
                        }
                        
                        if([wardrobe isKindOfClass:[Wardrobe class]])
                        {
                            [self performRestGet:GET_USER_WARDROBES_CONTENT withParamaters:[NSArray arrayWithObject:wardrobe.idWardrobe]];
                        }
                    }
                }
                
                [self actionAfterSuccessfulAnswerToRestConnection:connection WithResult:mappingResult];
                
                break;
            }
            case GET_USER_WARDROBES_CONTENT:
            {
                if (!(mappingResult == nil))
                {
                    // Get the wardrobe that was provided to insert its products
                    [mappingResult enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
                     {
                         if (([obj isKindOfClass:[Wardrobe class]]))
                         {
                             AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                             
                             if(!(appDelegate.addingProductsToWardrobeID == nil))
                             {
                                 if([appDelegate.addingProductsToWardrobeID isEqualToString:((Wardrobe *)(obj)).idWardrobe])
                                 {
                                     // NSLog(@"CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC\nOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOO");
                                 }
                             }
                             
                             // Get the list of products that were provided to fill the Wardrobe.itemsId property
                             for (GSBaseElement *item in mappingResult)
                             {
                                 if([item isKindOfClass:[GSBaseElement class]])
                                 {
                                     if(!(item.idGSBaseElement == nil))
                                     {
                                         if(!([item.idGSBaseElement isEqualToString:@""]))
                                         {
                                             if([((Wardrobe *)(obj)) itemsId] == nil)
                                             {
                                                 ((Wardrobe *)(obj)).itemsId = [[NSMutableArray alloc] init];
                                             }
                                             
                                             if(!([((Wardrobe *)(obj)).itemsId containsObject:item.idGSBaseElement]))
                                             {
                                                 [((Wardrobe *)(obj)).itemsId addObject:item.idGSBaseElement];
                                             }
                                         }
                                     }
                                 }
                             }
                         }
                     }];
                }
                
                
                [self actionAfterSuccessfulAnswerToRestConnection:GET_USER_WARDROBES_CONTENT WithResult:mappingResult];
                
                break;
            }
            case UNFOLLOW_USER:
            {
                if (!(mappingResult == nil))
                {
                    // Get the list of wardrobes that were provided to request their products
                    for (Follow *follow in mappingResult)
                    {
                        if([follow isKindOfClass:[Follow class]])
                        {
                            currentContext = [RKObjectManager sharedManager].managedObjectStore.mainQueueManagedObjectContext;
                            
                            [currentContext deleteObject:follow];
                            NSError * error = nil;
                            if (![currentContext save:&error])
                            {
                                NSLog(@"Error saving context! %@", error);
                            }
                        }
                    }
                }
                
                NSLog(@"Unsetting user follow succeed!");
                
                [self actionAfterSuccessfulAnswerToRestConnection:connection WithResult:mappingResult];
                break;
            }
            case FOLLOW_USER:
            case GET_USER_FOLLOWS:
            case VERIFY_FOLLOWER:
            {
                NSLog(@"Setting user follow  /  Getting user follows succeed / Verify Follower!");
                
                [self actionAfterSuccessfulAnswerToRestConnection:connection WithResult:mappingResult];
                
                break;
            }
            case GET_USER_NOTIFICATIONS:
            {
                NSMutableArray * userIds= [[NSMutableArray alloc] init];
                
                int numberOfNewNotifications = 0;
                
                for(Notification * notification in mappingResult)
                {
                    if(!(notification == nil))
                    {
                        if([notification isKindOfClass:[Notification class]])
                        {
                            if(notification.actionUser == nil)
                            {
                                if(!(notification.actionUserId == nil))
                                {
                                    if(!([notification.actionUserId isEqualToString:@""]))
                                    {
                                        if(!([userIds containsObject:notification.actionUserId]))
                                        {
                                            NSArray * requestParameters = [[NSArray alloc] initWithObjects:notification.actionUserId, nil];
                                            [self performRestGet:GET_USER withParamaters:requestParameters];
                                            [userIds addObject:notification.actionUserId];
                                        }
                                    }
                                }
                            }
                            
                            if(notification.notificationIsNew && ([notification.notificationIsNew boolValue] == YES))
                            {
                                numberOfNewNotifications ++;
                            }
                        }
                    }
                }
                
                AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                
                [appDelegate setUserNewNotifications:[NSNumber numberWithInt:(([appDelegate.userNewNotifications intValue]) + (numberOfNewNotifications))]];
                [self initMainMenu];
                [[NSNotificationCenter defaultCenter] postNotificationName:kFinishedUpdatingNotifications object:nil];
                //[self setupNotificationsLabel];
                /*
                 if([appDelegate.userNewNotifications intValue] > 0)
                 {
                 
                 
                 //Prepare the notification image
                 UIImage * baseImage = [UIImage imageNamed:@"profile_ico.png"];
                 
                 UIImageView * notificationImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0,baseImage.size.width, baseImage.size.height)];
                 
                 [notificationImageView setContentMode:UIViewContentModeScaleAspectFit];
                 
                 [notificationImageView setImage:baseImage];
                 
                 UILabel * numberLabel = [UILabel createLabelWithOrigin:CGPointMake(baseImage.size.width-(baseImage.size.width*0.6),0)
                 andSize:CGSizeMake(baseImage.size.width*0.6, baseImage.size.height*0.55)
                 andBackgroundColor:[UIColor clearColor]
                 andAlpha:1.0
                 andText:[appDelegate.userNewNotifications stringValue]
                 andTextColor:[UIColor whiteColor]
                 andFont:[UIFont fontWithName:@"Avenir-Heavy" size:20]
                 andUppercasing:YES
                 andAligned:NSTextAlignmentCenter];
                 
                 UIView * notificationIcon = [[UIView alloc] initWithFrame:CGRectMake(0, 0,baseImage.size.width, baseImage.size.height)];
                 
                 // Add image and label to view
                 [notificationIcon addSubview:notificationImageView];
                 [notificationIcon addSubview:numberLabel];
                 
                 UIGraphicsBeginImageContextWithOptions(notificationIcon.bounds.size, NO, 0.0);
                 
                 [notificationIcon.layer renderInContext:UIGraphicsGetCurrentContext()];
                 
                 UIImage *notificationImage = UIGraphicsGetImageFromCurrentImageContext();
                 
                 UIGraphicsEndImageContext();
                 
                 // check
                 AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                 
                 if ([appDelegate.window.rootViewController.restorationIdentifier isEqualToString:[@(REQUIREDPROFILESTYLIST_VC) stringValue]] )
                 {
                 
                 }
                 else
                 {
                 if ([[appDelegate.config valueForKey:@"visual_search"] boolValue] == YES)
                 {
                 }
                 else
                 {
                 //[self setHomeTitle:NSLocalizedString(@"_MENUENTRY_5_", nil) andImage:notificationImage];
                 }
                 }
                 }
                 else
                 {
                 AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                 
                 if ([appDelegate.window.rootViewController.restorationIdentifier isEqualToString:[@(REQUIREDPROFILESTYLIST_VC) stringValue]] )
                 {
                 
                 }
                 else
                 {
                 if ([[appDelegate.config valueForKey:@"visual_search"] boolValue] == YES)
                 {
                 
                 }
                 else
                 {
                 
                 }
                 }
                 }
                 */
                NSLog(@"Getting user notifications succeed!");
                
                [self actionAfterSuccessfulAnswerToRestConnection:connection WithResult:mappingResult];
                
                break;
            }
            case GET_FULLSCREENBACKGROUNDAD:
            {
                if (!(mappingResult == nil))
                {
                    //Check if user is already loged in
                    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                    
                    // Get the BackgroundAd that was provided to store it
                    [mappingResult enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
                     {
                         if (([obj isKindOfClass:[BackgroundAd class]]))
                         {
                             if(!([((BackgroundAd*)obj) imageURL] == nil))
                             {
                                 if(!([[((BackgroundAd*)obj) imageURL] isEqualToString:@""]))
                                 {
                                     appDelegate.nextFullscreenBackgroundAd = obj;
                                     
                                     NSLog(@"***********************Getting background Ad succeed! Got: %@", appDelegate.nextFullscreenBackgroundAd.mainInformation);
                                     
                                     // Stop the enumeration
                                     *stop = YES;
                                 }
                             }
                         }
                     }];
                }
                
                [self actionAfterSuccessfulAnswerToRestConnection:connection WithResult:mappingResult];
                
                break;
            }
            case GET_SEARCHADAPTEDBACKGROUNDAD:
            {
                if (!(mappingResult == nil))
                {
                    //Check if user is already loged in
                    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                    
                    // Get the BackgroundAd that was provided to store it
                    [mappingResult enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
                     {
                         if (([obj isKindOfClass:[BackgroundAd class]]))
                         {
                             if(!([((BackgroundAd*)obj) imageURL] == nil))
                             {
                                 if(!([[((BackgroundAd*)obj) imageURL] isEqualToString:@""]))
                                 {
                                     appDelegate.nextSearchAdaptedBackgroundAd = obj;
                                     
                                     NSLog(@"***********************Getting background Ad succeed! Got: %@", appDelegate.nextSearchAdaptedBackgroundAd.mainInformation);
                                     
                                     // Stop the enumeration
                                     *stop = YES;
                                 }
                             }
                         }
                     }];
                }
                
                [self actionAfterSuccessfulAnswerToRestConnection:connection WithResult:mappingResult];
                
                break;
            }
            case GET_POSTADAPTEDBACKGROUNDAD:
            {
                if (!(mappingResult == nil))
                {
                    //Check if user is already loged in
                    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                    
                    // Get the BackgroundAd that was provided to store it
                    [mappingResult enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
                     {
                         if (([obj isKindOfClass:[BackgroundAd class]]))
                         {
                             if(!([((BackgroundAd*)obj) imageURL] == nil))
                             {
                                 if(!([[((BackgroundAd*)obj) imageURL] isEqualToString:@""]))
                                 {
                                     appDelegate.nextPostAdaptedBackgroundAd = obj;
                                     
                                     NSLog(@"***********************Getting background Ad succeed! Got: %@", appDelegate.nextPostAdaptedBackgroundAd.mainInformation);
                                     
                                     // Stop the enumeration
                                     *stop = YES;
                                 }
                             }
                         }
                     }];
                }
                
                [self actionAfterSuccessfulAnswerToRestConnection:connection WithResult:mappingResult];
                
                break;
            }
            case GET_SEARCH_SUGGESTEDFILTERKEYWORDS:
            case ADD_WARDROBE:
            case UPDATE_WARDROBE_NAME:
            {
                if (!(mappingResult == nil))
                {
                    // Get the list of wardrobes that were provided to request their products
                    for (Wardrobe *wardrobe in mappingResult)
                    {
                        if([wardrobe isKindOfClass:[Wardrobe class]])
                        {
                            currentContext = [RKObjectManager sharedManager].managedObjectStore.mainQueueManagedObjectContext;
                            
                            [currentContext insertObject:wardrobe];
                        }
                    }
                }
                
                NSLog(@"Getting search suggested filter keywords / Adding wardrobe / Updating wardrobe name succeed!");
                
                [self actionAfterSuccessfulAnswerToRestConnection:connection WithResult:mappingResult];
                
                break;
            }
            case ADD_ITEM_TO_WARDROBE:
            {
                /*                if (!(mappingResult == nil))
                 {
                 // Get the list of wardrobes that were provided to request their products
                 for (GSBaseElement *item in mappingResult)
                 {
                 if([item isKindOfClass:[GSBaseElement class]])
                 {
                 currentContext = [RKObjectManager sharedManager].managedObjectStore.mainQueueManagedObjectContext;
                 
                 //                            [currentContext insertObject:item];
                 
                 GSBaseElement *newItem = [NSEntityDescription
                 insertNewObjectForEntityForName:@"GSBaseElement"
                 inManagedObjectContext:currentContext];
                 
                 [newItem setIdGSBaseElement:item.idGSBaseElement];
                 [newItem setAdditionalInformation:item.additionalInformation];
                 [newItem setFashionistaPostId:item.fashionistaPostId];
                 [newItem setGroup:item.group];
                 [newItem setMainInformation:item.mainInformation];
                 [newItem setName:item.name];
                 [newItem setOrder:item.order];
                 [newItem setPreview_image:item.preview_image];
                 [newItem setPreview_image_height:item.preview_image_height];
                 [newItem setPreview_image_width:item.preview_image_width];
                 [newItem setProductId:item.productId];
                 [newItem setRecommendedPrice:item.recommendedPrice];
                 [newItem setStyleId:item.styleId];
                 [newItem setWardrobeId:item.wardrobeId];
                 
                 NSError *error = nil;
                 
                 if (![currentContext save:&error])
                 {
                 NSLog(@"Save did not complete successfully. Error: %@", error);
                 }
                 }
                 }
                 }
                 */
                NSLog(@"Adding products to wardrobe succeed!");
                
                [self actionAfterSuccessfulAnswerToRestConnection:connection WithResult:mappingResult];
                
                break;
            }
            case UPDATE_ITEM_TO_WARDROBE:
            {
                NSLog(@"Updating products to wardrobe succeed!");
                
                [self actionAfterSuccessfulAnswerToRestConnection:connection WithResult:mappingResult];
                
                break;
            }
            case ADD_POST_TO_WARDROBE:
            {
                NSLog(@"Adding post to wardrobe succeed!");
                
                [self actionAfterSuccessfulAnswerToRestConnection:connection WithResult:mappingResult];
                
                break;
            }
            case ADD_KEYWORD_TO_CONTENT:
            {
                NSLog(@"Adding keyword to content succeed!");
                
                [self actionAfterSuccessfulAnswerToRestConnection:connection WithResult:mappingResult];
                
                break;
            }
            case UPDATE_KEYWORD_TO_CONTENT:
            {
                NSLog(@"Updating keyword to content succeed!");
                
                [self actionAfterSuccessfulAnswerToRestConnection:connection WithResult:mappingResult];
                
                break;
            }
            case ADD_REVIEW_TO_PRODUCT:
            {
                if (!(mappingResult == nil))
                {
                    // Get the list of wardrobes that were provided to request their products
                    for (Review *review in mappingResult)
                    {
                        if([review isKindOfClass:[Review class]])
                        {
                            currentContext = [RKObjectManager sharedManager].managedObjectStore.mainQueueManagedObjectContext;
                            
                            [currentContext insertObject:review];
                        }
                    }
                }
                
                NSLog(@"Adding review to product succeed!");
                
                [self actionAfterSuccessfulAnswerToRestConnection:connection WithResult:mappingResult];
                
                break;
            }
            case GET_WARDROBE:
            {
                [_wardrobeContents addObjectsFromArray:mappingResult];
                
                // Now, request the product reviews
                if (!(_wardrobeContents == nil))
                {
                    if ([_wardrobeContents count] > 0)
                    {
                        if([[_wardrobeContents objectAtIndex:0] isKindOfClass:[Wardrobe class]])
                        {
                            wardrobe = (NSString *)[((Wardrobe *)([_wardrobeContents objectAtIndex:0])) idWardrobe];
                            
                            NSArray * requestParameters = [[NSArray alloc] initWithObjects:wardrobe, nil];
                            
                            [self performRestGet:GET_WARDROBE_CONTENT withParamaters:requestParameters];
                            
                            NSLog(@"Getting wardrobe succeed!");
                            
                            break;
                        }
                    }
                }
                
                [self actionAfterSuccessfulAnswerToRestConnection:connection WithResult:mappingResult];
                
                break;
            }
            case GET_WARDROBE_CONTENT:
            {
                [_wardrobeContents addObjectsFromArray:mappingResult];
                
                NSLog(@"Getting wardrobe content succeed!");
                
                [self actionAfterSuccessfulAnswerToRestConnection:GET_WARDROBE WithResult:_wardrobeContents];
                
                _wardrobeContents = nil;
                
                break;
            }
            case REMOVE_ITEM_FROM_WARDROBE:
            case DELETE_WARDROBE:
            {
                NSLog(@"Removing product from wardrobe / Deleting wardrobe succeed!");
                
                [self actionAfterSuccessfulAnswerToRestConnection:connection WithResult:mappingResult];
                
                break;
            }
            case GET_FASHIONISTAWITHMAIL:
            case GET_FASHIONISTAWITHNAME:
            case GET_FASHIONISTA:
            {
                NSLog(@"Getting fashionista info succeed!");
                [self actionAfterSuccessfulAnswerToRestConnection:connection WithResult:mappingResult];
                break;
            }
            case GET_PAGE:
            case GET_FASHIONISTAPAGES:
            {
                NSLog(@"Getting fashionista pages from a user!");
                [self actionAfterSuccessfulAnswerToRestConnection:connection WithResult:mappingResult];
                break;
            }
            case GET_FASHIONISTAPAGESFORSHARE:
            {
                //[self stopActivityFeedback];
                
                // Get the list of pages that were provided
                for (FashionistaPage *page in mappingResult)
                {
                    if([page isKindOfClass:[FashionistaPage class]])
                    {
                        if(!(page.idFashionistaPage == nil))
                        {
                            if  (!([page.idFashionistaPage  isEqualToString:@""]))
                            {
                                // Paramters for next VC
                                NSArray * parametersForNextVC = [NSArray arrayWithObjects: [NSNumber numberWithBool:YES], page, nil];
                                
                                if(!([parametersForNextVC count] < 2))
                                {
                                    [self transitionToViewController:FASHIONISTAPOST_VC withParameters:parametersForNextVC];
                                }
                                
                                return;
                                
                                break;
                            }
                        }
                    }
                }
                
                // Paramters for next VC
                NSArray * parametersForNextVC = [NSArray arrayWithObjects: [NSNumber numberWithBool:YES], nil];
                
                [self transitionToViewController:FASHIONISTAMAINPAGE_VC withParameters:parametersForNextVC];
                
                break;
            }
            case GET_FASHIONISTAPAGE_AUTHOR:
            {
                NSLog(@"Getting fashionista page author succeed!");
                
                [self actionAfterSuccessfulAnswerToRestConnection:connection WithResult:mappingResult];
                
                break;
            }
            case GET_FASHIONISTAPAGE_POSTS:
            {
                NSLog(@"Getting fashionista page posts succeed!");
                
                [self actionAfterSuccessfulAnswerToRestConnection:connection WithResult:mappingResult];
                
                break;
            }
            case UPLOAD_FASHIONISTAPAGE:
            {
                //                if (!(mappingResult == nil))
                //                {
                //                    // Get the list of fashionista pages that were provided to request their products
                //                    for (FashionistaPage *page in mappingResult)
                //                    {
                //                        if([page isKindOfClass:[FashionistaPage class]])
                //                        {
                //                            currentContext = [RKObjectManager sharedManager].managedObjectStore.mainQueueManagedObjectContext;
                //
                //                            [currentContext insertObject:page];
                //                        }
                //                    }
                //                }
                
                NSLog(@"Adding fashionista page / Updating fashionista page succeed!");
                
                [self actionAfterSuccessfulAnswerToRestConnection:connection WithResult:mappingResult];
                
                break;
            }
            case UPLOAD_FASHIONISTAPAGE_IMAGE:
            {
                NSLog(@"Uploading Fashionista Page Image succeed!");
                
                [self actionAfterSuccessfulAnswerToRestConnection:connection WithResult:mappingResult];
                
                break;
            }
            case UPLOAD_FASHIONISTAPOST:
            {
                //                if (!(mappingResult == nil))
                //                {
                //                    // Get the list of fashionista pages that were provided to request their products
                //                    for (FashionistaPage *page in mappingResult)
                //                    {
                //                        if([page isKindOfClass:[FashionistaPage class]])
                //                        {
                //                            currentContext = [RKObjectManager sharedManager].managedObjectStore.mainQueueManagedObjectContext;
                //
                //                            [currentContext insertObject:page];
                //                        }
                //                    }
                //                }
                
                NSLog(@"Adding fashionista post / Updating fashionista post succeed!");
                
                [self actionAfterSuccessfulAnswerToRestConnection:connection WithResult:mappingResult];
                
                break;
            }
            case UPLOAD_FASHIONISTAPOST_LOCATION:
            {
                NSLog(@"Adding fashionista post UPLOAD_FASHIONISTAPOST_FORSHARE");
                
                for (FashionistaPost *post in mappingResult)
                {
                    if([post isKindOfClass:[FashionistaPost class]])
                    {
                        if(!(post.idFashionistaPost == nil))
                        {
                            if  (!([post.idFashionistaPost isEqualToString:@""]))
                            {
                                [self actionAfterSuccessfulAnswerToRestConnection:connection WithResult:mappingResult];
                                
                                 break;
                            }
                        }
                    }
                }
                
                
                break;
            }
            case UPLOAD_FASHIONISTAPOST_FORSHARE:
            {
                NSLog(@"Adding fashionista post UPLOAD_FASHIONISTAPOST_FORSHARE");
                
                for (FashionistaPost *post in mappingResult)
                {
                    if([post isKindOfClass:[FashionistaPost class]])
                    {
                        if(!(post.idFashionistaPost == nil))
                        {
                            if  (!([post.idFashionistaPost isEqualToString:@""]))
                            {
                                 [self actionAfterSuccessfulAnswerToRestConnection:connection WithResult:mappingResult];
                                
                                NSArray * requestParameters = [[NSArray alloc] initWithObjects:post.idFashionistaPost, nil];
                                
                                [self performRestGet:GET_POST_FOR_SHARE withParamaters:requestParameters];
                                
                                currentContext = [RKObjectManager sharedManager].managedObjectStore.mainQueueManagedObjectContext;
                                
                                [currentContext deleteObject:post];
                                
                                [currentContext processPendingChanges];
                                
                                if (![currentContext save:nil])
                                {
                                    NSLog(@"Save did not complete successfully.");
                                }
                                
                                return;
                                
                                break;
                            }
                        }
                    }
                }
                
                [self stopActivityFeedback];
                
                break;
            }
            case UPLOAD_FASHIONISTAPOST_PREVIEWIMAGE:
            {
                NSLog(@"Uploading Fashionista Post Preview Image succeed!");
                
                [self actionAfterSuccessfulAnswerToRestConnection:connection WithResult:mappingResult];
                
                break;
            }
            case UPLOAD_FASHIONISTACONTENT:
            {
                //                if (!(mappingResult == nil))
                //                {
                //                    // Get the list of fashionista pages that were provided to request their products
                //                    for (FashionistaPage *page in mappingResult)
                //                    {
                //                        if([page isKindOfClass:[FashionistaPage class]])
                //                        {
                //                            currentContext = [RKObjectManager sharedManager].managedObjectStore.mainQueueManagedObjectContext;
                //
                //                            [currentContext insertObject:page];
                //                        }
                //                    }
                //                }
                
                NSLog(@"Adding fashionista content / Updating fashionista content succeed!");
                
                [self actionAfterSuccessfulAnswerToRestConnection:connection WithResult:mappingResult];
                
                break;
            }
            case ADD_COMMENT_TO_POST:
            {
                if (!(mappingResult == nil))
                {
                    // Get the list of wardrobes that were provided to request their products
                    for (Comment *comment in mappingResult)
                    {
                        if([comment isKindOfClass:[Comment class]])
                        {
                            currentContext = [RKObjectManager sharedManager].managedObjectStore.mainQueueManagedObjectContext;
                            
                            [currentContext insertObject:comment];
                        }
                    }
                }
                
                NSLog(@"Adding comment to post succeed!");
                
                [self actionAfterSuccessfulAnswerToRestConnection:connection WithResult:mappingResult];
                
                break;
            }
            case UPLOAD_REVIEW_VIDEO:
            {
                NSLog(@"Uploading Review Video succeed!");
                
                [self actionAfterSuccessfulAnswerToRestConnection:connection WithResult:mappingResult];
                
                break;
            }
            case UPLOAD_FASHIONISTACONTENT_VIDEO:
            {
                NSLog(@"Uploading Fashionista Content Video succeed!");
                
                [self actionAfterSuccessfulAnswerToRestConnection:connection WithResult:mappingResult];
                
                break;
            }
            case UPLOAD_FASHIONISTACONTENT_IMAGE:
            {
                NSLog(@"Uploading Fashionista Content Image succeed!");
                
                [self actionAfterSuccessfulAnswerToRestConnection:connection WithResult:mappingResult];
                
                break;
            }
            case UPLOAD_COMMENT_VIDEO:
            {
                NSLog(@"Uploading Comment Video succeed!");
                
                [self actionAfterSuccessfulAnswerToRestConnection:connection WithResult:mappingResult];
                
                break;
            }
            case ADD_WARDROBE_TO_CONTENT:
            {
                NSLog(@"Adding wardrobe to post content succeed!");
                
                [self actionAfterSuccessfulAnswerToRestConnection:connection WithResult:mappingResult];
                
                break;
            }
            case DELETE_FASHIONISTA_PAGE:
            {
                NSLog(@"Deleting fashionista page succeed!");
                
                [self actionAfterSuccessfulAnswerToRestConnection:connection WithResult:mappingResult];
                
                break;
            }
            case DELETE_POST:
            {
                NSLog(@"Deleting post succeed!");
                
                [self actionAfterSuccessfulAnswerToRestConnection:connection WithResult:mappingResult];
                
                break;
            }
            case DELETE_POST_CONTENT:
            {
                NSLog(@"Deleting fashionista content succeed!");
                
                [self actionAfterSuccessfulAnswerToRestConnection:connection WithResult:mappingResult];
                
                break;
            }
            case DELETE_COMMENT:
            {
                NSLog(@"Deleting comment succeed!");
                
                [self actionAfterSuccessfulAnswerToRestConnection:connection WithResult:mappingResult];
                
                break;
            }
            case REMOVE_KEYWORD_FROM_CONTENT:
            {
                NSLog(@"Removing keyword from fashionista post content!");
                
                [self actionAfterSuccessfulAnswerToRestConnection:connection WithResult:mappingResult];
                
                break;
            }
            case POST_FOLLOW_SOCIALNETWORK_USERS:
            {
                [self actionAfterSuccessfulAnswerToRestConnection:connection WithResult:mappingResult];
                break;
            }
            case ADD_USERREPORT:
            case ADD_POSTCONTENTREPORT:
            case ADD_POSTCOMMENTREPORT:
            case ADD_PRODUCTREPORT:
            {
                NSLog(@"Adding User/PostContent/PostComment/Product Report succeed!");
                
                [self stopActivityFeedback];
                
                break;
            }
            case UPLOAD_SHARE:
            {
                NSLog(@"Uploading Share object succeed!");
                
                [self actionAfterSuccessfulAnswerToRestConnection:connection WithResult:mappingResult];
                
                break;
            }
            case POST_YES_NOTICES:
            case POST_FOLLOW:
            case USER_ACCEPT_NOTICES:
            case POST_UNFOLLOW:
            case USER_IGNORE_NOTICES:
            case POST_NO_NOTICES:
            {
                [self actionAfterSuccessfulAnswerToRestConnection:connection WithResult:mappingResult];
                break;
            }
            case ADD_PRODUCTVIEW:
            {
                NSLog(@"Uploading Product View!");
                
                [self actionAfterSuccessfulAnswerToRestConnection:connection WithResult:mappingResult];
                
                break;
            }
            case UPLOAD_LIVESTREAMING:
            {
                NSLog(@"Uploading / Updating live streaming succeed!");
                
                [self actionAfterSuccessfulAnswerToRestConnection:connection WithResult:mappingResult];
                
                break;
            }
            case UPLOAD_LIVESTREAMINGETHINICITY:
            {
                NSLog(@"Uploading live streaming ethnicity succeed!");
                
                [self actionAfterSuccessfulAnswerToRestConnection:connection WithResult:mappingResult];
                
                break;
            }
            case ADD_LIVESTREAMINGCATEGORY_TO_LIVESTREAMING:
            {
                NSLog(@"Addomg category to live streaming succeed!");
                
                [self actionAfterSuccessfulAnswerToRestConnection:connection WithResult:mappingResult];
                
                break;
            }
            case ADD_COUNTRY_TO_LIVESTREAMING:
            {
                NSLog(@"Adding country to live streaming succeed!");
                
                [self actionAfterSuccessfulAnswerToRestConnection:connection WithResult:mappingResult];
                
                break;
            }
            case ADD_STATEREGION_TO_LIVESTREAMING:
            {
                NSLog(@"Adding state to live streaming succeed!");
                
                [self actionAfterSuccessfulAnswerToRestConnection:connection WithResult:mappingResult];
                
                break;
            }
            case ADD_CITY_TO_LIVESTREAMING:
            {
                NSLog(@"Adding cities to live streaming succeed!");
                
                [self actionAfterSuccessfulAnswerToRestConnection:connection WithResult:mappingResult];
                
                break;
            }
            case ADD_TYPELOOK_TO_LIVESTREAMING:
            {
                NSLog(@"Adding typelook to live streaming succeed!");
                
                [self actionAfterSuccessfulAnswerToRestConnection:connection WithResult:mappingResult];
                
                break;
            }
            case ADD_HASHTAG_TO_LIVESTREAMING:
            {
                NSLog(@"Adding typelook to live streaming succeed!");
                
                [self actionAfterSuccessfulAnswerToRestConnection:connection WithResult:mappingResult];
                
                break;
            }
            case ADD_PRODUCTCATEGORY_TO_LIVESTREAMING:
            {
                NSLog(@"Adding Product Category to live streaming succeed!");
                
                [self actionAfterSuccessfulAnswerToRestConnection:connection WithResult:mappingResult];
                
                break;
            }
            case ADD_BRAND_TO_LIVESTREAMING:
            {
                NSLog(@"Adding brand to live streaming succeed!");
                
                [self actionAfterSuccessfulAnswerToRestConnection:connection WithResult:mappingResult];
                
                break;
            }
            case GET_LIVESTREAMINGPRIVACY:
            {
                NSLog(@"Setting live streaming privacy succeed!");
                
                [self actionAfterSuccessfulAnswerToRestConnection:connection WithResult:mappingResult];
                
                break;
            }
            case GET_LIVESTREAMINGCATEGORIES:
            {
                NSLog(@"getting live streaming privacy succeed!");
                
                [self actionAfterSuccessfulAnswerToRestConnection:connection WithResult:mappingResult];
                
                break;
            }
            case GET_TYPELOOKS:
            {
                NSLog(@"getting looks succeed!");
                
                [self actionAfterSuccessfulAnswerToRestConnection:connection WithResult:mappingResult];
                
                break;
            }
            case GET_LIVESTREAMING:
            {
                NSLog(@"getting live streaming privacy succeed!");
                
                [self actionAfterSuccessfulAnswerToRestConnection:connection WithResult:mappingResult];
                
                break;
            }
            case GET_MOST_POPULAR_HASHTAG:
            {
                NSLog(@"getting tags succeed!");
                
                [self actionAfterSuccessfulAnswerToRestConnection:connection WithResult:mappingResult];
                
                break;
            }
            case GET_HASHTAG:
            {
                NSLog(@"getting tags succeed!");
                
                [self actionAfterSuccessfulAnswerToRestConnection:connection WithResult:mappingResult];
                
                break;
            }
            case ADD_PRODUCTSHARED:
            case ADD_PRODUCTPURCHASE:
            case ADD_FASHIONISTAVIEW:
            case ADD_FASHIONISTAVIEWTIME:
            case ADD_COMMENTVIEW:
            case ADD_REVIEWPRODUCTVIEW:
            case ADD_POSTVIEW:
            case ADD_POSTVIEWTIME:
            case ADD_POSTSHARED:
            case ADD_WARDROBEVIEW:
            case GET_ALL_KEYWORDS:
            case GET_SHARE:
                
            default:
                
                NSLog(@"Adding Product View / Getting user wardrobes content / Getting all keywords / Getting share object succeed!");
                
                break;
        }
    }
    else
    {
        // Something went wrong with the request process...
        
        NSLog(@"Ooops! Webservice fetching failed for operation: %u", connection);
        
        if (!(errorMessage == nil))
        {
            if ([errorMessage count] == 3)
            {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[errorMessage objectAtIndex:0] message:[errorMessage objectAtIndex:1] delegate:nil cancelButtonTitle:[errorMessage objectAtIndex:2] otherButtonTitles:nil];
                
                [self stopActivityFeedback];
                
                [alertView show];
            }
        }
    }
}

-(NSString *)getPatternForConnectionType:(connectionType)connection intendedForStringFormat:(BOOL)bForStringFormat
{
    switch (connection)
    {
        case PERFORM_SEARCH_WITHIN_PRODUCTS:
        {
            return ((bForStringFormat) ? (@"/search/%@") : (@"/search/:id"));
            break;
        }
        case PERFORM_SEARCH_WITHIN_PRODUCTS_NUMS:
        {
            return ((bForStringFormat) ? (@"/search/%@") : (@"/search/:id"));
            break;
        }
        case PERFORM_SEARCH_WITHIN_TRENDING:
        {
            return ((bForStringFormat) ? (@"/gettrending/%@") : (@"/gettrending/:id"));
            break;
        }
        case PERFORM_SEARCH_WITHIN_HISTORY:
        {
            return ((bForStringFormat) ? (@"/user/%@/history/%@/%@") : (@"/user/:IdUser/history/:Date/:searchString"));
            break;
        }
        case PERFORM_VISUAL_SEARCH:
        {
            return ((bForStringFormat) ? (@"/detect") : (@"/detect"));
            break;
        }
        case GET_DETECTION_STATUS:
        {
            return ((bForStringFormat) ? (@"/detection/%@") : (@"/detection/:idDetection"));
            break;
        }
        case GET_SEARCH_QUERY:
        {
            return ((bForStringFormat) ? (@"/statproductsquery/%@") : (@"/statproductsquery/:idSearchQuery"));
            break;
        }
        case GET_SEARCH_RESULTS_WITHIN_PRODUCTS:
        case GET_SEARCH_RESULTS_WITHIN_TRENDING:
        case GET_SEARCH_RESULTS_WITHIN_HISTORY:
        case GET_SEARCH_RESULTS_WITHIN_FASHIONISTAPOSTS:
        case GET_SEARCH_RESULTS_WITHIN_FASHIONISTAWARDROBES:
        case GET_SEARCH_RESULTS_WITHIN_FASHIONISTAS:
        case GET_SEARCH_RESULTS_WITHIN_BRAND_PRODUCTS:
        {
            return ((bForStringFormat) ? (@"/statproductsquery/%@/products") : (@"/statproductsquery/:idSearchQuery/products"));
            break;
        }
        case GET_ALL_KEYWORDS:
        {
            return ((bForStringFormat) ? (@"/keyword?limit=-1") : (@"/keyword?limit=-1"));
            break;
        }
        case GET_SEARCH_KEYWORDS:
        {
            return ((bForStringFormat) ? (@"/statproductsquery/%@/keywords") : (@"/statproductsquery/:idSearchQuery/keywords"));
            break;
        }
        case GET_PRODUCT_BRAND:
        case GET_SEARCHPRODUCTS_BRAND:
        {
            return ((bForStringFormat) ? (@"/product/%@/brand") : (@"/product/:idProduct/brand"));
            break;
        }
        case GET_SEARCH_SUGGESTEDFILTERKEYWORDS:
        {
            return ((bForStringFormat) ? (@"/statproductsquery/:idSearchQuery/suggestedKeywords") : (@"/statproductsquery/:idSearchQuery/suggestedKeywords"));
            break;
        }
        case GET_PRODUCT_CONTENT:
        {
            return ((bForStringFormat) ? (@"/product/%@/contents") : (@"/product/:idProduct/contents"));
            break;
        }
        case GET_PRODUCT_REVIEWS:
        case ADD_REVIEW_TO_PRODUCT:
        {
            return ((bForStringFormat) ? (@"/product/%@/reviews") : (@"/product/:idProduct/reviews"));
            break;
        }
        case GET_PRODUCT_FEATURES:
        {
            return ((bForStringFormat) ? (@"/product/%@/features") : (@"/product/:idProduct/features"));
            break;
        }
        case GET_PRODUCT_GROUP:
        {
            return ((bForStringFormat) ? (@"/product/%@/category") : (@"/product/:idProduct/category"));
            break;
        }
        case GET_PRODUCTGROUP_FEATURES:
        {
            return ((bForStringFormat) ? (@"/productCategory/%@/featuresGroup") : (@"/productCategory/:idProductGroup/featuresGroup"));
            break;
        }
        case GET_FEATUREGROUP_FEATURES:
        {
            return ((bForStringFormat) ? (@"/featureGroup/%@/features") : (@"/featureGroup/:idFeatureGroup/features"));
            break;
        }
        case GET_USER_WARDROBES:
        {
            return ((bForStringFormat) ? (@"/user/%@/wardrobes") : (@"/user/:idUser/wardrobes"));
            break;
        }
        case GET_WARDROBE_CONTENT:
        case GET_USER_WARDROBES_CONTENT:
        {
            return ((bForStringFormat) ? (@"/wardrobe/%@/products") : (@"/wardrobe/:idWardrobe/products"));
            break;
        }
        case ADD_PRODUCTVIEW:
        {
            return  ((bForStringFormat) ? (@"/statProductView") : (@"/statProductView"));
            break;
        }
        case ADD_WARDROBE:
        {
            return ((bForStringFormat) ? (@"/wardrobe") : (@"/wardrobe"));
            break;
        }
        case ADD_ITEM_TO_WARDROBE:
        {
            return ((bForStringFormat) ? (@"/wardrobe/%@/products") : (@"/wardrobe/:idWardrobe/products"));
            break;
        }
        case ADD_POST_TO_WARDROBE:
        {
            return ((bForStringFormat) ? (@"/wardrobe/%@/addFashionistaPost/%@") : (@"/wardrobe/:idWardrobe/addFashionistaPost/:idPost"));
            break;
        }
        case UPDATE_WARDROBE_NAME:
        case DELETE_WARDROBE:
        {
            return ((bForStringFormat) ? (@"/wardrobe/%@") : (@"/wardrobe/:idWardrobe"));
            break;
        }
        case REMOVE_ITEM_FROM_WARDROBE:
        {
            return ((bForStringFormat) ? (@"/wardrobe/%@/products/%@") : (@"/wardrobe/:idWardrobe/products/:idProduct"));
            break;
        }
            
        default:
            
            return @"";
            break;
    }
}

- (void)getProductForElement:(GSBaseElement *)element
{
    if (!(element == nil))
    {
        if(!(element.productId == nil))
        {
            if(!([element.productId isEqualToString:@""]))
            {
                // Perform request to get the result contents
                NSLog(@"Getting contents for product: %@", element.name);
                
                // Provide feedback to user
                [self stopActivityFeedback];
                [self startActivityFeedbackWithMessage:NSLocalizedString(@"_DOWNLOADINGCONTENT_ACTV_MSG_", nil)];
                
                NSArray * requestParameters = [[NSArray alloc] initWithObjects:element.productId, nil];
                
                [self performRestGet:GET_PRODUCT withParamaters:requestParameters];
            }
        }
    }
}
// Get content for selected result
- (void)getContentsForElement:(GSBaseElement *)element
{
    // Check that the element to search is valid
    
    if (!(element == nil))
    {
        if(!(element.productId == nil))
        {
            if(!([element.productId isEqualToString:@""]))
            {
                // Perform request to get the result contents
                NSLog(@"Getting contents for product: %@", element.name);
                
                // Provide feedback to user
                [self stopActivityFeedback];
                [self startActivityFeedbackWithMessage:NSLocalizedString(@"_DOWNLOADINGCONTENT_ACTV_MSG_", nil)];
                
                NSArray * requestParameters = [[NSArray alloc] initWithObjects:element.productId, nil];
                
                [self performRestGet:GET_PRODUCT withParamaters:requestParameters];
            }
        }
        //        else if(!(element.articleId == nil))
        //        {
        //            if(!([element.articleId isEqualToString:@""]))
        //            {
        //
        //            }
        //        }
        //        else if(!(element.tutorialId == nil))
        //        {
        //            if(!([element.tutorialId isEqualToString:@""]))
        //            {
        //
        //            }
        //        }
        //        else if(!(element.reviewId == nil))
        //        {
        //            if(!([element.reviewId isEqualToString:@""]))
        //            {
        //
        //            }
        //        }
        else if(!(element.fashionistaId == nil))
        {
            if(!([element.fashionistaId isEqualToString:@""]))
            {
                // Perform request to get the result contents
                NSLog(@"Getting contents for Fashionista: %@", element.name);
                
                // Provide feedback to user
                [self stopActivityFeedback];
                [self startActivityFeedbackWithMessage:NSLocalizedString(@"_DOWNLOADINGCONTENT_ACTV_MSG_", nil)];
                
                NSArray * requestParameters = [[NSArray alloc] initWithObjects:element.fashionistaId, nil];
                
                [self performRestGet:GET_FASHIONISTA withParamaters:requestParameters];
            }
        }
        else if(!(element.fashionistaPageId == nil))
        {
            if(!([element.fashionistaPageId isEqualToString:@""]))
            {
                // Perform request to get the result contents
                NSLog(@"Getting contents for Fashionista page: %@", element.name);
                
                // Provide feedback to user
                [self stopActivityFeedback];
                [self startActivityFeedbackWithMessage:NSLocalizedString(@"_DOWNLOADINGCONTENT_ACTV_MSG_", nil)];
                
                NSArray * requestParameters = [[NSArray alloc] initWithObjects:element.fashionistaPageId, nil];
                
                [self performRestGet:GET_FASHIONISTA withParamaters:requestParameters];
            }
        }
        else if(!(element.fashionistaPostId == nil))
        {
            if(!([element.fashionistaPostId isEqualToString:@""]))
            {
                // Perform request to get the result contents
                NSLog(@"Getting contents for Fashionista post: %@", element.name);
                
                // Provide feedback to user
                [self stopActivityFeedback];
                [self startActivityFeedbackWithMessage:NSLocalizedString(@"_DOWNLOADINGCONTENT_ACTV_MSG_", nil)];
                
                NSArray * requestParameters = [[NSArray alloc] initWithObjects:element.fashionistaPostId, nil];
                
                [self performRestGet:GET_FULL_POST withParamaters:requestParameters];
            }
        }
        else if(!(element.wardrobeId == nil))
        {
            if(!([element.wardrobeId isEqualToString:@""]))
            {
                // Perform request to get the result contents
                NSLog(@"Getting contents for wardrobe: %@", element.name);
                
                // Provide feedback to user
                [self stopActivityFeedback];
                [self startActivityFeedbackWithMessage:NSLocalizedString(@"_DOWNLOADINGCONTENT_ACTV_MSG_", nil)];
                
                NSArray * requestParameters = [[NSArray alloc] initWithObjects:element.wardrobeId, nil];
                
                [self performRestGet:GET_WARDROBE withParamaters:requestParameters];
            }
        }
        else if(!(element.wardrobeQueryId == nil))
        {
            if(!([element.wardrobeQueryId isEqualToString:@""]))
            {
                // Perform request to get the result contents
                NSLog(@"Getting contents for wardrobe: %@", element.name);
                
                // Provide feedback to user
                [self stopActivityFeedback];
                [self startActivityFeedbackWithMessage:NSLocalizedString(@"_DOWNLOADINGCONTENT_ACTV_MSG_", nil)];
                
                NSArray * requestParameters = [[NSArray alloc] initWithObjects:element.wardrobeQueryId, nil];
                
                [self performRestGet:GET_WARDROBE withParamaters:requestParameters];
            }
        }
        else if(!(element.brandId == nil))
        {
            if(!([element.brandId isEqualToString:@""]))
            {
                // Perform request to get the result contents
                NSLog(@"Getting contents for brand: %@", element.mainInformation);
                
                // Provide feedback to user
                [self stopActivityFeedback];
                [self startActivityFeedbackWithMessage:NSLocalizedString(@"_DOWNLOADINGCONTENT_ACTV_MSG_", nil)];
                
                NSArray * requestParameters = [[NSArray alloc] initWithObjects:[element.mainInformation urlEncodeUsingNSUTF8StringEncoding], nil];
                
                // TODO: make performsearch in order to get the products of the brand
                [self performRestGet:GET_BRAND_PRODUCTS withParamaters:requestParameters];
            }
        }
        else if(!(element.styleId == nil))
        {
            if(!([element.styleId isEqualToString:@""]))
            {
                
            }
        }
    }
}

// Action to perform once an answer is succesfully processed
- (void) actionAfterSuccessfulAnswerToRestConnection:(connectionType)connection WithResult:(NSArray *)mappingResult
{
    NSLog(@"XXXX This is an abstract method and should be overridden XXXX");
    
    switch (connection)
    {
        case GET_ALLPRODUCTCATEGORIES:
        {
            
            [self setupAllProductCategoriesWithMapping: mappingResult];
            
            [self loadBrandsPriority];
            
            break;
        }
        case GET_PRIORITYBRANDS:
        {
            [self setupPriorityBrandsWithMapping: mappingResult];
            
            //[self finishedLoadingFilterInfo];
            //[self getSearchKeywords];
            
            break;
        }
        case GET_ALLBRANDS:
        {
            [self setupAllBrandsWithMapping: mappingResult];
            
            break;
        }
        case GET_ALLFEATURES:
        {
            [self setupAllFeaturesWithMapping: mappingResult];
            
            [self loadAllProductCategory];
            
            break;
        }
        case GET_ALLFEATUREGROUPS:
        {
            [self setupAllFeatureGroupsWithMapping: mappingResult];
            
            // es neceasrio que estas llamadas se hagan en este orden para que el mapping se haga correctamente
            // primero la llamada para obtener los fetureGroups y despues la de las features.
            [self loadAllFeatures];
            
            
            break;
        }
        default:
        {
            [self stopActivityFeedback];
            break;
        }
            
    }
    
    return;
}

@end

