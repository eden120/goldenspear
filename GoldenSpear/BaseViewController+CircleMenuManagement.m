//
//  BaseViewController+CircleMenuManagement.m
//  GoldenSpear
//
//  Created by Jose Antonio Sanchez Martinez on 15/05/15.
//  Copyright (c) 2015 GoldenSpear. All rights reserved.
//

#import "BaseViewController+CircleMenuManagement.h"
#import "BaseViewController+StoryboardManagement.h"
#import "BaseViewController+BottomControlsManagement.h"
#import "BaseViewController+MainMenuManagement.h"
#import "BaseViewController+ActivityFeedbackManagement.h"
#import "BaseViewController+RestServicesManagement.h"
#import "BaseViewController+BottomControlsManagement.h"
#import "SearchBaseViewController.h"
#import <objc/runtime.h>


static char PRESSEDLEFTBUTTON_KEY;
static char PRESSEDRIGHTBUTTON_KEY;
static char PRESSEDMAINBUTTON_KEY;


@implementation BaseViewController (CircleMenuManagement)


#pragma mark - Main menu management

// Getter and setter for bPressedLeftButton
- (NSNumber *)bPressedLeftButton
{
    return objc_getAssociatedObject(self, &PRESSEDLEFTBUTTON_KEY);
}

- (void)setBPressedLeftButton:(NSNumber *)bPressedLeftButton
{
    objc_setAssociatedObject(self, &PRESSEDLEFTBUTTON_KEY, bPressedLeftButton, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

// Getter and setter for bPressedRightButton
- (NSNumber *)bPressedRightButton
{
    return objc_getAssociatedObject(self, &PRESSEDRIGHTBUTTON_KEY);
}

- (void)setBPressedRightButton:(NSNumber *)bPressedRightButton
{
    objc_setAssociatedObject(self, &PRESSEDRIGHTBUTTON_KEY, bPressedRightButton, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

// Getter and setter for bPressedMainButton
- (NSNumber *)bPressedMainButton
{
    return objc_getAssociatedObject(self, &PRESSEDMAINBUTTON_KEY);
}

- (void)setBPressedMainButton:(NSNumber *)bPressedMainButton
{
    objc_setAssociatedObject(self, &PRESSEDMAINBUTTON_KEY, bPressedMainButton, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


NSArray* leftImageArray;
NSArray* leftLabelArray;
CGFloat leftAngle;
CGFloat leftFixedInterItemAngle;
CGFloat leftDelay;
int leftEntryShadow;
CGFloat leftRadius;
int leftDirection;

NSArray* rightImageArray;
NSArray* rightLabelArray;
CGFloat rightAngle;
CGFloat rightFixedInterItemAngle;
CGFloat rightDelay;
int rightEntryShadow;
CGFloat rightRadius;
int rightDirection;

NSArray* mainImageArray;
NSArray* mainLabelArray;
CGFloat mainAngle;
CGFloat mainFixedInterItemAngle;
CGFloat mainDelay;
int mainEntryShadow;
CGFloat mainRadius;
int mainDirection;

// Check if the current view controller must reacto to the long pressure in the home button
- (BOOL)shouldRecognizeLeftLongPressure
{
    return NO;
}

// Check if the current view controller must reacto to the long pressure in the home button
- (BOOL)shouldRecognizeRightLongPressure
{
    return NO;
}

// Check if the current view controller must reacto to the long pressure in the home button
- (BOOL)shouldRecognizeMainLongPressure
{
    // Show the circle menu for some specific ViewControllers: Product Sheet
    if (([self.restorationIdentifier isEqualToString:[@(PRODUCTSHEET_VC) stringValue]]) ||
        ([self.restorationIdentifier isEqualToString:[@(SEARCH_VC) stringValue]])/* ||
        ([self.restorationIdentifier isEqualToString:[@(FASHIONISTAMAINPAGE_VC) stringValue]]) ||
        ([self.restorationIdentifier isEqualToString:[@(FASHIONISTAPOST_VC) stringValue]])*/
        )
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

- (void)setupLeftCircleMenuDefaults
{
    leftDirection = CircleMenuDirectionRight;
    leftDelay = 0.0;
    leftEntryShadow = 0;
    leftRadius = 110.0;
    leftAngle = 180.0;
    leftFixedInterItemAngle = 65.0;

    leftImageArray = [NSArray arrayWithObjects:[UIImage imageNamed:@"SocialShareButtonBottom.png"], [UIImage imageNamed:@"StylistPostButtonBottom.png"], nil];
    
    leftLabelArray = [NSArray arrayWithObjects:@"SocialShareButtonBottomLbl", @"StylistPostButtonBottomLbl", nil];
}

- (void)setupRightCircleMenuDefaults
{
    self.bPressedRightButton = [NSNumber numberWithBool:NO];

    return;
}

- (void)setupMainCircleMenuDefaults
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    mainDirection = CircleMenuDirectionUp;
    mainDelay = 0.0;
    mainEntryShadow = 0;
    mainRadius = 110.0;
    mainAngle = 180.0;
    mainFixedInterItemAngle = 45.0;
    
    // Show the circle menu for some specific ViewControllers: Product Sheet
    if (([self.restorationIdentifier isEqualToString:[@(PRODUCTSHEET_VC) stringValue]])/* ||
                                                                                        ([self.restorationIdentifier isEqualToString:[@(FASHIONISTAMAINPAGE_VC) stringValue]]) ||
                                                                                        ([self.restorationIdentifier isEqualToString:[@(FASHIONISTAPOST_VC) stringValue]])*/
        )
    {
        if ([[appDelegate.config valueForKey:@"visual_search"] boolValue] == YES)
        {
            mainImageArray = [NSArray arrayWithObjects:[UIImage imageNamed:@"Similar.png"], [UIImage imageNamed:@"VisualSearch.png"], [UIImage imageNamed:@"FeaturesBottom.png"], [UIImage imageNamed:@"GetTheLookBottom.png"], nil];

            mainLabelArray = [NSArray arrayWithObjects:@"SimilarLbl", @"VisualSearchLbl", @"FeaturesBottomLbl", @"GetTheLookBottomLbl", nil];

            mainFixedInterItemAngle = 35.0;
        }
        else
        {
            mainImageArray = [NSArray arrayWithObjects:[UIImage imageNamed:@"Similar.png"], /*[UIImage imageNamed:@"VisualSearch.png"], */[UIImage imageNamed:@"FeaturesBottom.png"], [UIImage imageNamed:@"GetTheLookBottom.png"], nil];

            mainLabelArray = [NSArray arrayWithObjects:@"SimilarLbl", /*@"VisualSearchLbl", */@"FeaturesBottomLbl", @"GetTheLookBottomLbl", nil];
        }
    }
    else if ([self.restorationIdentifier isEqualToString:[@(SEARCH_VC) stringValue]])
    {
        if ([[appDelegate.config valueForKey:@"visual_search"] boolValue] == YES)
        {
            mainImageArray = [NSArray arrayWithObjects:[UIImage imageNamed:@"AddTermButton.png"], [UIImage imageNamed:@"VisualSearch.png"], [UIImage imageNamed:@"FeaturesBottom.png"], nil];

            mainLabelArray = [NSArray arrayWithObjects:@"AddTermButtonBottomLbl", @"VisualSearchLbl", @"FiltersBottomLbl", nil];
        }
        else
        {
           mainImageArray = [NSArray arrayWithObjects:[UIImage imageNamed:@"    Bottom.png"], /*[UIImage imageNamed:@"VisualSearch.png"], */[UIImage imageNamed:@"FeaturesBottom.png"], nil];
            
            mainLabelArray = [NSArray arrayWithObjects:@"AddTermButtonBottomLbl", /*@"VisualSearchLbl", */@"FiltersBottomLbl", nil];
        }
    }
}

- (void)leftLongPressGestureRecognized:(UITapGestureRecognizer *)sender
{
    if([self shouldRecognizeLeftLongPressure])
    {
        if (sender.state == UIGestureRecognizerStateEnded)
        {
//            CGPoint tPoint = [sender locationInView:self.view];
            CGPoint tPoint = CGPointMake(self.bottomControlsView.frame.origin.x + self.leftButton.frame.origin.x + (self.leftButton.frame.size.width/2), self.bottomControlsView.frame.origin.y + self.leftButton.frame.origin.y + (self.leftButton.frame.size.height/2));
            
            NSMutableDictionary* tOptions = [NSMutableDictionary new];
            [tOptions setValue:[NSDecimalNumber numberWithFloat:leftDelay] forKey:CIRCLE_MENU_OPENING_DELAY];
            [tOptions setValue:[NSDecimalNumber numberWithFloat:leftAngle] forKey:CIRCLE_MENU_MAX_ANGLE];
            [tOptions setValue:[NSDecimalNumber numberWithFloat:leftRadius] forKey:CIRCLE_MENU_RADIUS];
            [tOptions setValue:[NSNumber numberWithInt:leftDirection] forKey:CIRCLE_MENU_DIRECTION];
            [tOptions setValue:[NSDecimalNumber numberWithFloat:leftFixedInterItemAngle] forKey:CIRCLE_FIXED_INTERITEM_ANGLE];
            [tOptions setValue:[UIColor colorWithRed:1.0 green:1.00 blue:1.00 alpha:0.95] forKey:CIRCLE_MENU_BUTTON_BACKGROUND_NORMAL];
            [tOptions setValue:[UIColor colorWithRed:0.95 green:0.80 blue:0.46 alpha:0.95] forKey:CIRCLE_MENU_BUTTON_BACKGROUND_ACTIVE];
            [tOptions setValue:[UIColor lightGrayColor] forKey:CIRCLE_MENU_BUTTON_BORDER];
            [tOptions setValue:[NSNumber numberWithInt:leftEntryShadow] forKey:CIRCLE_MENU_DEPTH];
            [tOptions setValue:[NSDecimalNumber decimalNumberWithString:@"35.0"] forKey:CIRCLE_MENU_BUTTON_RADIUS];
            [tOptions setValue:[NSDecimalNumber decimalNumberWithString:@"2.5"] forKey:CIRCLE_MENU_BUTTON_BORDER_WIDTH];
            
            CircleMenuView* tMenu = [[CircleMenuView alloc] initAtOrigin:tPoint usingOptions:tOptions withImageArray:leftImageArray andLabelArray:leftLabelArray];
            [self.view addSubview:tMenu];
            
            self.bPressedLeftButton = [NSNumber numberWithBool:YES];
            
            [tMenu openMenuWithRecognizer:sender];
            tMenu.delegate = self;
        }
    }
    else
    {
        [self swipeLeftAction];
    }
}

- (void)rightLongPressGestureRecognized:(UITapGestureRecognizer *)sender
{
    if([self shouldRecognizeLeftLongPressure])
    {
    }
    else
    {
        [self swipeRightAction];
    }
}

- (void)homeLongPressGestureRecognized:(UITapGestureRecognizer *)sender
{
    if([self shouldRecognizeMainLongPressure])
    {
        if (sender.state == UIGestureRecognizerStateEnded)
        {
            NSString * key = [NSString stringWithFormat:@"HIGHLIGHTHOME_%d", [self.restorationIdentifier intValue]];
            
            if([self isKindOfClass:[SearchBaseViewController class]])
            {
                SearchBaseViewController * s = (SearchBaseViewController*)self;
                int iContext = s.searchContext;
                key = [NSString stringWithFormat:@"HIGHLIGHTHOME_%d_%d", [self.restorationIdentifier intValue], iContext];
            }

            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            
            // Save into defaults if doesn't already exists
            if ([defaults objectForKey:key] == nil)
            {
                NSString *dateString = [NSDateFormatter localizedStringFromDate:[NSDate date]
                                                                      dateStyle:NSDateFormatterShortStyle
                                                                      timeStyle:NSDateFormatterFullStyle];
                
                [defaults setObject:dateString forKey:key];
                [defaults synchronize];
            }
            
//            CGPoint tPoint = [sender locationInView:self.view];
            CGPoint tPoint = CGPointMake(self.bottomControlsView.frame.origin.x + self.homeButton.frame.origin.x + (self.homeButton.frame.size.width/2), self.bottomControlsView.frame.origin.y + self.homeButton.frame.origin.y + (self.homeButton.frame.size.height/2));
            
            NSMutableDictionary* tOptions = [NSMutableDictionary new];
            [tOptions setValue:[NSDecimalNumber numberWithFloat:mainDelay] forKey:CIRCLE_MENU_OPENING_DELAY];
            [tOptions setValue:[NSDecimalNumber numberWithFloat:mainAngle] forKey:CIRCLE_MENU_MAX_ANGLE];
            [tOptions setValue:[NSDecimalNumber numberWithFloat:mainRadius] forKey:CIRCLE_MENU_RADIUS];
            [tOptions setValue:[NSNumber numberWithInt:mainDirection] forKey:CIRCLE_MENU_DIRECTION];
            [tOptions setValue:[NSDecimalNumber numberWithFloat:mainFixedInterItemAngle] forKey:CIRCLE_FIXED_INTERITEM_ANGLE];
            [tOptions setValue:[UIColor colorWithRed:1.0 green:1.00 blue:1.00 alpha:0.95] forKey:CIRCLE_MENU_BUTTON_BACKGROUND_NORMAL];
            [tOptions setValue:[UIColor colorWithRed:0.95 green:0.80 blue:0.46 alpha:0.95] forKey:CIRCLE_MENU_BUTTON_BACKGROUND_ACTIVE];
            [tOptions setValue:[UIColor lightGrayColor] forKey:CIRCLE_MENU_BUTTON_BORDER];
            [tOptions setValue:[NSNumber numberWithInt:mainEntryShadow] forKey:CIRCLE_MENU_DEPTH];
            [tOptions setValue:[NSDecimalNumber decimalNumberWithString:@"35.0"] forKey:CIRCLE_MENU_BUTTON_RADIUS];
            [tOptions setValue:[NSDecimalNumber decimalNumberWithString:@"2.5"] forKey:CIRCLE_MENU_BUTTON_BORDER_WIDTH];
            
            CircleMenuView* tMenu = [[CircleMenuView alloc] initAtOrigin:tPoint usingOptions:tOptions withImageArray:mainImageArray andLabelArray:mainLabelArray];
            
            [self.view addSubview:tMenu];
            
            self.bPressedMainButton = [NSNumber numberWithBool:YES];

            [tMenu openMenuWithRecognizer:sender];
            tMenu.delegate = self;
        }
    }
}

- (void)circleMenuActivatedButtonWithIndex:(int)buttonIndex
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if([self.bPressedLeftButton boolValue] == YES)
    {
        switch (buttonIndex)
        {
            case 0:
                
                [self actionForLeftFirstCircleMenuEntry];

                self.bPressedLeftButton = [NSNumber numberWithBool:NO];

                break;
                
            case 1:
                
                [self actionForLeftSecondCircleMenuEntry];
                
                self.bPressedLeftButton = [NSNumber numberWithBool:NO];

                break;
                
            default:
                break;
        }
    }
    else if([self.bPressedRightButton boolValue] == YES)
    {
        switch (buttonIndex)
        {
            case 0:
                
                [self actionForRightFirstCircleMenuEntry];
                
                self.bPressedRightButton = [NSNumber numberWithBool:NO];

                break;
                
            case 1:
                
                [self actionForRightSecondCircleMenuEntry];
                
                self.bPressedRightButton = [NSNumber numberWithBool:NO];
                
                break;
                
            default:
                break;
        }
    }
    else if([self.bPressedMainButton boolValue] == YES)
    {
        switch (buttonIndex)
        {
            case 0:
                
                [self actionForMainFirstCircleMenuEntry];
                
                self.bPressedMainButton = [NSNumber numberWithBool:NO];
                
                break;
                
            case 1:
                
                if ([[appDelegate.config valueForKey:@"visual_search"] boolValue] == YES)
                {
                    [self actionForMainSecondCircleMenuEntry];
                    
                    self.bPressedMainButton = [NSNumber numberWithBool:NO];
                }
                else
                {
                    [self actionForMainThirdCircleMenuEntry];
                    
                    self.bPressedMainButton = [NSNumber numberWithBool:NO];
                }
                
                break;
                
            case 2:
                
                if ([[appDelegate.config valueForKey:@"visual_search"] boolValue] == YES)
                {
                    [self actionForMainThirdCircleMenuEntry];
                    
                    self.bPressedMainButton = [NSNumber numberWithBool:NO];
                }
                else
                {
                    [self actionForMainFourthCircleMenuEntry];
                    
                    self.bPressedMainButton = [NSNumber numberWithBool:NO];
                }
                
                break;
                
            case 3:
                
                [self actionForMainFourthCircleMenuEntry];
                
                self.bPressedMainButton = [NSNumber numberWithBool:NO];

                break;
                
            default:
                break;
        }
    }
}

- (void)circleMenuClosed
{
    self.bPressedLeftButton = [NSNumber numberWithBool:NO];
    self.bPressedRightButton = [NSNumber numberWithBool:NO];
    self.bPressedMainButton = [NSNumber numberWithBool:NO];
}


// Circle menu action: might be overriden to have a particular action within each ViewController
-(void) actionForLeftFirstCircleMenuEntry
{
    // Shared Items
    UIImage *imageToShare = [self getScreenCapture];
    
    NSString *messageToShare = NSLocalizedString(@"_SHARE_GENERIC_MSG_", nil);
    
    NSArray *sharedActivityItems = @[imageToShare, messageToShare];
    
    // Initialize Activity View Controller
    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:sharedActivityItems applicationActivities:nil];
    
    // Exclude non-desired sharing options
    activityVC.excludedActivityTypes = @[UIActivityTypeAirDrop,
                                         
                                         /*UIActivityTypeMessage,
                                          UIActivityTypeMail,*/
                                         
                                         UIActivityTypeSaveToCameraRoll,
                                         UIActivityTypeAssignToContact,
                                         UIActivityTypeCopyToPasteboard,
                                         UIActivityTypePrint,
                                         
                                         UIActivityTypeAddToReadingList
                                         ];
    
    // Present Activity View Controller
    [self presentViewController:activityVC animated:YES completion:nil];
}

// Circle menu action: might be overriden to have a particular action within each ViewController
-(void) actionForLeftSecondCircleMenuEntry
{
    [self showMainMenu:nil];
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if (!(appDelegate.currentUser == nil))
    {
        if(([appDelegate.currentUser.isFashionista boolValue]) == YES)
        {
            if(!(appDelegate.currentUser.idUser == nil))
            {
                if(!([appDelegate.currentUser.idUser isEqualToString: @""]))
                {
                    NSManagedObjectContext *currentContext = [RKObjectManager sharedManager].managedObjectStore.mainQueueManagedObjectContext;
                    
                    FashionistaPost * newPost = [[FashionistaPost alloc] initWithEntity:[NSEntityDescription entityForName:@"FashionistaPost" inManagedObjectContext:currentContext] insertIntoManagedObjectContext:currentContext];
                    
                    [newPost setUserId:appDelegate.currentUser.idUser];
                    
                    [newPost setType:@"article"];
                    
                    [currentContext processPendingChanges];
                    
                    [currentContext save:nil];
                    
                    if(!(newPost == nil))
                    {
                        if((!(newPost.userId == nil)) && (!([newPost.userId isEqualToString:@""])))
                        {
                            NSLog(@"Uploading fashionista post...");
                            
                            // Provide feedback to user
                            [self stopActivityFeedback];
                            [self startActivityFeedbackWithMessage:NSLocalizedString(@"_PREPARINGFASHIONISTAPOST_MSG_", nil)];
                            
                            NSArray * requestParameters = [[NSArray alloc] initWithObjects:newPost, [NSNumber numberWithBool:NO], nil];
                            
                            [self performRestPost:UPLOAD_FASHIONISTAPOST_FORSHARE withParamaters:requestParameters];
                            
                        }
                    }
                }
            }
            
            return;
        }
    }
}


// Circle menu action: might be overriden to have a particular action within each ViewController
-(void) actionForRightFirstCircleMenuEntry
{
    return;
}

// Circle menu action: might be overriden to have a particular action within each ViewController
-(void) actionForRightSecondCircleMenuEntry
{
    return;
}


// Circle menu action: might be overriden to have a particular action within each ViewController
-(void) actionForMainFirstCircleMenuEntry
{
    return;
}

// Circle menu action: might be overriden to have a particular action within each ViewController
-(void) actionForMainSecondCircleMenuEntry
{
    [self transitionToViewController:VISUALSEARCH_VC withParameters:nil];
}

// Circle menu action: might be overriden to have a particular action within each ViewController
-(void) actionForMainThirdCircleMenuEntry
{
    return;
}

// Circle menu action: might be overriden to have a particular action within each ViewController
-(void) actionForMainFourthCircleMenuEntry
{
    return;
}

@end

