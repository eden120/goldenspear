//
//  GSEthnicityViewController.m
//  GoldenSpear
//
//  Created by Adria Vernetta Rubio on 9/5/16.
//  Copyright © 2016 GoldenSpear. All rights reserved.
//

#import "GSEthnicityViewController.h"
#import "BaseViewController+TopBarManagement.h"
#import "BaseViewController+ActivityFeedbackManagement.h"
#import "User+Manage.h"

#define kNameKey    @"name"
#define kOtherKey   @"other"
#define kEthnicityKey   @"ethnicity"

@interface GSEthnicityViewController (){
    NSMutableDictionary* ethnyObjectDictionary;
    User* current;
    
    CGFloat keyboardHeight;
}

@end

@implementation GSEthnicityViewController

- (void)dealloc{
    ethnyObjectDictionary = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.translatesAutoresizingMaskIntoConstraints = NO;
    [self hideTopBar];
    ethnyObjectDictionary = [NSMutableDictionary new];
    keyboardHeight = 0;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidChangeFrameWithNotification:) name:UIKeyboardWillChangeFrameNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShowNotification:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHideNotification:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)keyboardWillHideNotification:(NSNotification *)notification
{
    [self animateTextViewFrameForVerticalHeight:0];
}

- (void)keyboardWillShowNotification:(NSNotification *)notification
{
    [self animateTextViewFrameForVerticalHeight:keyboardHeight];
}

- (void)keyboardDidChangeFrameWithNotification:(NSNotification *)notification
{
    // Calculate vertical increase
    CGFloat keyboardVerticalIncrease = [self keyboardVerticalIncreaseForNotification:notification];
    keyboardHeight += keyboardVerticalIncrease;
    // Properly animate Add Terms text box
    [self animateTextViewFrameForVerticalOffset:keyboardVerticalIncrease];
}

// Calculate the vertical increase when keyboard appears
- (CGFloat)keyboardVerticalIncreaseForNotification:(NSNotification *)notification
{
    CGFloat keyboardBeginY = [notification.userInfo[UIKeyboardFrameBeginUserInfoKey] CGRectValue].origin.y;
    
    CGFloat keyboardEndY = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue].origin.y;
    
    CGFloat keyboardVerticalIncrease = keyboardBeginY - keyboardEndY;
    
    return keyboardVerticalIncrease;
}

- (void)animateTextViewFrameForVerticalHeight:(CGFloat)height{
    self.scrollBottomDistanceConstraint.constant = MAX(height,0);
    [self.view layoutIfNeeded];
}

// Animate the Add Terms text box when keyboard appears
- (void)animateTextViewFrameForVerticalOffset:(CGFloat)offset
{
    CGFloat constant = self.scrollBottomDistanceConstraint.constant;
    CGFloat newConstant = constant + offset;// + 50;
    [self animateTextViewFrameForVerticalHeight:newConstant];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    current = [(AppDelegate*)[UIApplication sharedApplication].delegate currentUser];
    [self startActivityFeedbackWithMessage:@""];
    
    [self layoutEthnicities];
    [self getCurrentUserEthnicities];
    
    [self stopActivityFeedback];
}

- (void)processSelectedEtnicities:(NSArray*)ethnicities{
    for (NSDictionary* ethny in ethnicities) {
        NSString* groupName = [current.ethnyGroupRefDictionary objectForKey:[ethny objectForKey:kEthnicityKey]];
        GSEthnyView* ethnyView = [ethnyObjectDictionary objectForKey:groupName];
        [ethnyView addSelectedEthny:ethny];
    }
}

- (void)fixLayout{
    for(NSString* key in [ethnyObjectDictionary allKeys]){
        GSEthnyView* eV = [ethnyObjectDictionary objectForKey:key];
        [eV fixLayout];
    }
}

- (void)addLayoutForView:(UIView*)theView withPreviousView:(UIView*)previousView{
    //Height
    NSLayoutConstraint* aConstraint = [NSLayoutConstraint constraintWithItem:theView
                                                                   attribute:NSLayoutAttributeHeight
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:nil
                                                                   attribute:NSLayoutAttributeNotAnAttribute
                                                                  multiplier:1
                                                                    constant:theView.frame.size.height];
    [theView addConstraint:aConstraint];
    
    //Width
    aConstraint = [NSLayoutConstraint constraintWithItem:theView
                                               attribute:NSLayoutAttributeWidth
                                               relatedBy:NSLayoutRelationEqual
                                                  toItem:theView.superview
                                               attribute:NSLayoutAttributeWidth
                                              multiplier:1
                                                constant:0];
    [theView.superview addConstraint:aConstraint];
    
    //Center Hori
    aConstraint = [NSLayoutConstraint constraintWithItem:theView
                                               attribute:NSLayoutAttributeCenterX
                                               relatedBy:NSLayoutRelationEqual
                                                  toItem:theView.superview
                                               attribute:NSLayoutAttributeCenterX
                                              multiplier:1
                                                constant:0];
    [theView.superview addConstraint:aConstraint];
    
    //Y
    if (previousView) {
        aConstraint = [NSLayoutConstraint constraintWithItem:theView
                                                   attribute:NSLayoutAttributeTop
                                                   relatedBy:NSLayoutRelationEqual
                                                      toItem:previousView
                                                   attribute:NSLayoutAttributeBottom
                                                  multiplier:1
                                                    constant:10];
        
        [theView.superview addConstraint:aConstraint];
    }else{
        aConstraint = [NSLayoutConstraint constraintWithItem:theView
                                                   attribute:NSLayoutAttributeTop
                                                   relatedBy:NSLayoutRelationEqual
                                                      toItem:theView.superview
                                                   attribute:NSLayoutAttributeTop
                                                  multiplier:1
                                                    constant:0];
        [theView.superview addConstraint:aConstraint];
    }
    
}

- (void)layoutEthnicities{
    CGRect theFrame = CGRectMake(10, 0, self.ethnicitiesContainer.frame.size.width, 125);
    GSEthnyView* previousView = nil;
    for (NSString* group in current.groupsArray) {
        NSArray* ethnies = [current.groupEthniesDict objectForKey:group];
        GSEthnyView* ethnyView = [GSEthnyView new];
        ethnyView.delegate = self;
        [ethnyView setEthnyGroupCollection:ethnies];
        [ethnyObjectDictionary setObject:ethnyView forKey:group];

        [self.ethnicitiesContainer addSubview:ethnyView];
        [self addLayoutForView:ethnyView withPreviousView:previousView];
        previousView = ethnyView;
        theFrame.size.height = ethnyView.frame.size.height;
        theFrame.origin.y += theFrame.size.height+10;
    }
    self.ethnicitiesContainerHeight.constant = theFrame.origin.y;
    [self.view layoutIfNeeded];
}

- (void)getCurrentUserEthnicities{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSString* userEthnicityUrl = [NSString stringWithFormat:@"%@/user_ethnicity?user=%@", RESTBASEURL, appDelegate.currentUser.idUser];
    NSMutableURLRequest *configRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:userEthnicityUrl] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:30];
    [configRequest setHTTPMethod:@"GET"];
    
    [configRequest setValue:@"application/json;charset=UTF-8" forHTTPHeaderField:@"content-type"];
    NSError *requestError;
    
    NSURLResponse *requestResponse;
    
    NSData *configResponseData = [NSURLConnection sendSynchronousRequest:configRequest returningResponse:&requestResponse error:&requestError];
    int statusCode = (int)[((NSHTTPURLResponse *)requestResponse) statusCode];
    
    if(!(configResponseData == nil) && statusCode != 404)
    {
        id json = [NSJSONSerialization JSONObjectWithData:configResponseData options: NSJSONReadingMutableContainers error: &requestError];
        [self processSelectedEtnicities:json];
    }
}

- (IBAction)savePushed:(id)sender{
    [self.relatedDelegate closeRelatedViewController:self];
}

#pragma mark - EthnyViewDelegate

- (void)commitEthny:(NSDictionary*)ethny forAdding:(BOOL)addOrNot{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    NSString* userEthnicityUrl;
    if (addOrNot) {
        userEthnicityUrl = [NSString stringWithFormat:@"%@/user_ethnicity", RESTBASEURL];
    }else{
        userEthnicityUrl = [NSString stringWithFormat:@"%@/user_ethnicity?user=%@&ethnicity=%@", RESTBASEURL, appDelegate.currentUser.idUser,[ethny objectForKey:kIdKey]];
    }
    
    NSMutableURLRequest *configRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:userEthnicityUrl] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:30];
    if(addOrNot){
        [configRequest setHTTPMethod:@"POST"];
        NSMutableDictionary* body = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                     appDelegate.currentUser.idUser,@"user",
                                     [ethny objectForKey:kIdKey],@"ethnicity",nil];
        id other = [ethny objectForKey:kOtherKey];
        if (other!=nil&&![other isEqualToString:@""]) {
            [body setObject:[ethny objectForKey:kOtherKey] forKey:kOtherKey];
        }
        NSError *error = nil;
        [configRequest setHTTPBody:[NSJSONSerialization dataWithJSONObject:body options:0 error:&error]];
    }else{
        [configRequest setHTTPMethod:@"DELETE"];
    }
    [configRequest setValue:@"application/json;charset=UTF-8" forHTTPHeaderField:@"content-type"];
    
    NSError *requestError;
    
    NSURLResponse *requestResponse;
    
    NSData *configResponseData = [NSURLConnection sendSynchronousRequest:configRequest returningResponse:&requestResponse error:&requestError];
    int statusCode = (int)[((NSHTTPURLResponse *)requestResponse) statusCode];
    
    if(!(configResponseData == nil) && statusCode != 404)
    {
        id json = [NSJSONSerialization JSONObjectWithData:configResponseData options: NSJSONReadingMutableContainers error: &requestError];
    }
    [self stopActivityFeedback];
}

- (void)deleteEthny:(NSDictionary *)ethny{
    [self startActivityFeedbackWithMessage:@"Deleting Ethny..."];
    [self commitEthny:ethny forAdding:NO];
}

- (void)addNewEthny:(NSDictionary *)ethny{
    [self startActivityFeedbackWithMessage:@"Adding Ethny..."];
    [self commitEthny:ethny forAdding:YES];
}

@end
