//
//  BaseViewController+MainMenuManagement.m
//  GoldenSpear
//
//  Created by Jose Antonio Sanchez Martinez on 16/04/15.
//  Copyright (c) 2015 GoldenSpear. All rights reserved.
//

#import "BaseViewController+MainMenuManagement.h"
#import "BaseViewController+StoryboardManagement.h"
#import "BaseViewController+TopBarManagement.h"
#import "BaseViewController+UserManagement.h"
#import "FashionistaPostViewController.h"
#import "UILabel+CustomCreation.h"
#import <objc/runtime.h>

#define kMinEntryHeight ((IS_IPHONE_4_OR_LESS) ? (39) : ((IS_IPHONE_5) ? (39) : (49)))

static char MAINMENUVIEW_KEY;
static char MENUENTRIES_KEY;


@implementation BaseViewController (MainMenuManagement)


#pragma mark - Main menu management

// Getter and setter for mainMenuView
- (MainMenuView *)mainMenuView
{
    return objc_getAssociatedObject(self, &MAINMENUVIEW_KEY);
}

- (void)setMainMenuView:(MainMenuView *)mainMenuView
{
    objc_setAssociatedObject(self, &MAINMENUVIEW_KEY, mainMenuView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

// Getter and setter for menuEntries
- (NSArray *)menuEntries
{
    return objc_getAssociatedObject(self, &MENUENTRIES_KEY);
}

- (void)setMenuEntries:(NSArray *)menuEntries
{
    objc_setAssociatedObject(self, &MENUENTRIES_KEY, menuEntries, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

// Init Main Menu entries structures
- (void) initMainMenuEntries
{
    NSMutableArray * tmpMenuEntries = [[NSMutableArray alloc] init];
    int numEntry = 0;
    
    // Loop through the menu sections
    for(int iSection = 0; iSection < NUM_MENU_SECTIONS; iSection++)
    {
        MenuSection * tmpMenuSection = [[MenuSection alloc] init];
        
        [tmpMenuSection setSectionTitle:[NSLocalizedString(([NSString stringWithFormat:@"_MENUSECTION_%i_",iSection]), nil) uppercaseString]];
        tmpMenuSection.sectionEntries = [[NSMutableArray alloc] init];
        
        int numSectionEntries = 0;
        
        switch (iSection)
        {
            case 0:
            {
                numSectionEntries = NUM_MENU_ENTRIES_IN_SECTION_0;
                break;
            }
            case 1:
            {
                numSectionEntries = NUM_MENU_ENTRIES_IN_SECTION_1;
                break;
            }
            case 2:
            {
                numSectionEntries = NUM_MENU_ENTRIES_IN_SECTION_2 - 1;
                break;
            }
            default:
            {
                numSectionEntries = 0;
                break;
            }
        }
        
        // Loop through the menu entries
        for(int iEntry = 0; iEntry < numSectionEntries; iEntry++)
        {
            MenuEntry * tmpMenuEntry = [[MenuEntry alloc] init];
            
            [tmpMenuEntry setEntryText:NSLocalizedString(([NSString stringWithFormat:@"_MENUENTRY_%i_",numEntry]), nil)];
            
            [tmpMenuEntry setEntryIcon:[UIImage imageNamed:[NSString stringWithFormat:@"_MENUENTRY_%i_.png",numEntry]]];
            
            [tmpMenuEntry setDestinationVC:[NSNumber numberWithInt:numEntry]];
            
            [tmpMenuSection.sectionEntries addObject:tmpMenuEntry];
            
            numEntry++;
        }
        
        if(iSection == NUM_MENU_SECTIONS-1)
        {
            //Last entry, Log In or Log Out depending on the current user status
            
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            
            MenuEntry * tmpMenuEntry = [[MenuEntry alloc] init];
            
            [tmpMenuEntry setEntryText:(([defaults boolForKey:@"UserSignedIn"]) ? NSLocalizedString(([NSString stringWithFormat:@"_MENUENTRY_%iA_",SIGNIN_VC]), nil) : NSLocalizedString(([NSString stringWithFormat:@"_MENUENTRY_%iB_",SIGNIN_VC]), nil))];
            
            [tmpMenuEntry setEntryIcon:(([defaults boolForKey:@"UserSignedIn"]) ? [UIImage imageNamed:[NSString stringWithFormat:@"_MENUENTRY_%iA_",SIGNIN_VC]] : [UIImage imageNamed:[NSString stringWithFormat:@"_MENUENTRY_%iB_",SIGNIN_VC]])];
            
            [tmpMenuEntry setDestinationVC:[NSNumber numberWithInt:SIGNIN_VC]];
            
            [tmpMenuSection.sectionEntries addObject:tmpMenuEntry];
        }
        
        [tmpMenuEntries addObject:tmpMenuSection];
    }
    
    self.menuEntries = [tmpMenuEntries copy];
}
- (BOOL)shouldTopbarTransparent
{
    return NO;
}
// Main Menu initialization
- (void) initMainMenu
{
    if(!self.hidesTopBar){
        if (self.mainMenuView == nil)
        {
            self.mainMenuView = [[MainMenuView alloc] init];
        }
#if _ADD_OSAMA_
        BOOL bShouldTopbarTransparent = [self shouldTopbarTransparent];
        [self.menuButton setImage:bShouldTopbarTransparent? [UIImage imageNamed:@"live_direction.png"]:[UIImage imageNamed:@"Menu.png"] forState:UIControlStateNormal];
#else
        [self.menuButton setImage:[UIImage imageNamed:@"Menu.png"] forState:UIControlStateNormal];
#endif   
        [self initMainMenuEntries];
        
        [self.mainMenuView initMainMenuWithEntries:self.menuEntries andMidMargin:((IS_IPHONE_4_OR_LESS) ? (10) : ((IS_IPHONE_5) ? (10) : (20))) andOuterMargin:((IS_IPHONE_4_OR_LESS) ? (10) : ((IS_IPHONE_5) ? (10) : (20))) andMinEntrySize:CGSizeMake(self.view.frame.size.width,kMinEntryHeight) andDelegate:self];
        
        [self.view addSubview:self.mainMenuView];
        
        //New menu layout
        CGRect theFrame = self.mainMenuView.frame;
        theFrame.origin.x = self.view.frame.size.width - self.mainMenuView.leftOverflow;
        self.mainMenuView.frame = theFrame;
        [self showMainMenu:nil];
    }
}

// Main menu view delegate: an entry was selected
- (void)mainMenuView:(MainMenuView *)mainMenuView selectionDidChange:(int)menuEntry
{
    if(menuEntry == -1)
    {
        [self showMainMenu:nil];
        return;
    }
    
    int numEntry = 0;
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if (!appDelegate.completeUser) {
        if (menuEntry == 2 || menuEntry == 4 || menuEntry == 6) {
            [self showMainMenu:nil];
            [self showProfileErrorMessage];
            return;
        }
    }
    
    // Loop through the menu sections
    for(int iSection = 0; iSection < [self.menuEntries count]; iSection++)
    {
        // Loop through the list of entries
        for(int iEntry = 0; iEntry < [[((MenuSection *)[self.menuEntries objectAtIndex:iSection]) sectionEntries] count]; ++iEntry)
        {
            if (numEntry == menuEntry)
            {
                MenuEntry * tmpMenuEntry = ((MenuEntry*)[[((MenuSection *)[self.menuEntries objectAtIndex:iSection]) sectionEntries] objectAtIndex:iEntry]);
                
                //[self.mainMenuView setSelectedEntry:-1];
                
                if ([[tmpMenuEntry.entryText uppercaseString] isEqualToString:[NSLocalizedString(([NSString stringWithFormat:@"_MENUENTRY_%iA_",SIGNIN_VC]), nil) uppercaseString]])
                {
                    appDelegate.currentUser.delegate = self;
                    
                    BOOL bPerformTransition = YES;
                    if([self isKindOfClass:[FashionistaPostViewController class]])
                    {
                        bPerformTransition = [((FashionistaPostViewController *) self) checkPostEditionBeforeTransition];
                    }
                    
                    if (bPerformTransition)
                    {
                        [appDelegate.currentUser logOut];
                    }
                    [self showMainMenu:nil];
                    [self.mainMenuView setSelectedEntry:-1];
                }
                else if ([[tmpMenuEntry.entryText uppercaseString] isEqualToString:[NSLocalizedString(([NSString stringWithFormat:@"_MENUENTRY_%i_",STYLIST_VC]), nil) uppercaseString]])
                {
                    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                    
                    // Paramters for next VC
                    NSArray * parametersForNextVC = [NSArray arrayWithObjects: appDelegate.currentUser, [NSNumber numberWithBool:YES], nil];
                    
                    [self transitionToViewController:[tmpMenuEntry.destinationVC intValue] withParameters:parametersForNextVC];
                    [self.mainMenuView setSelectedEntry:-1];
                }
                else
                {
                    [self transitionToViewController:[tmpMenuEntry.destinationVC intValue] withParameters:nil];
                }
                
                return;
            }
            else
            {
                numEntry++;
            }
        }
    }
}

-(void)showProfileErrorMessage {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_PROFILE_COMPLETE_ERROR_",nil)
                                                    message:NSLocalizedString(@"_PROFILE_COMPLETE_MSG",nil)
                                                   delegate:self
                                          cancelButtonTitle:NSLocalizedString(@"_OK_",nil)
                                          otherButtonTitles:nil];
    [alert show];
}

// Main menu view delegate: provide the Y origin for the shown menu
- (float)getYOriginForMenuView
{
    return [self topBarHeight];
}

// Main menu view delegate: bring top view to front
- (void)bringTopBarViewToFront
{
    return [self bringTopBarToFront];
}

// Main Menu button action
- (void)showMainMenu:(UIButton *)sender
{
    [self showArrows];
    [self.view bringSubviewToFront:self.mainMenuView];
    
    if (sender == nil && [self.mainMenuView isHidden])
    {
        self.mainMenuView.hidden = YES;
        //[self showSuggestedFiltersRibbonAnimated:NO];
        self.mainMenuView.hidden = NO;
        
        [self.mainMenuView hideMainMenuViewAnimated: NO];
        
        return;
    }
    
    if ([self.mainMenuView isHidden])
    {
        [self.view endEditing:YES];
        
        //[self hideSuggestedFiltersRibbonAnimated:YES];
        
        [self.mainMenuView showMainMenuViewAnimated: YES];
    }
    else
    {
        self.mainMenuView.hidden = YES;
        //[self showSuggestedFiltersRibbonAnimated:YES];
        self.mainMenuView.hidden = NO;
        [self.mainMenuView hideMainMenuViewAnimated: YES];
    }
}

- (void)hideMainMenu
{
    self.mainMenuView.hidden = YES;
}
/*
 - (void)moveMainMenu:(BOOL)mustShow animated:(BOOL)animated{
 CGRect theFrame = self.view.frame;
 self.view.autoresizesSubviews = NO;
 CGRect screenSize = [[UIScreen mainScreen] bounds];
 if (mustShow) {
 theFrame.origin.x = self.mainMenuView.leftOverflow - theFrame.size.width;
 theFrame.size.width = screenSize.size.width + self.mainMenuView.frame.size.width;
 [self.mainMenuView.superview bringSubviewToFront:self.mainMenuView];
 }else{
 theFrame.origin.x = 0;
 theFrame.size.width = screenSize.size.width;
 [self.mainMenuView setTransparent:NO];
 }
 if (animated) {
 [UIView animateWithDuration:0.5
 delay:0
 options:UIViewAnimationOptionCurveEaseOut
 animations:^ {
 self.view.frame = theFrame;
 }
 completion:^(BOOL finished) {
 if(!mustShow){
 [self doAfterMenuHide];
 }else{
 [self.mainMenuView setTransparent:YES];
 }
 }];
 }else{
 self.view.frame = theFrame;
 if(!mustShow){
 [self doAfterMenuHide];
 }else{
 [self.mainMenuView setTransparent:YES];
 }
 }
 }
 */

- (void)moveMainMenu:(BOOL)mustShow animated:(BOOL)animated{
    CGRect theFrame = self.mainMenuView.frame;
    CGRect screenSize = [[UIScreen mainScreen] bounds];
    if (mustShow) {
        theFrame.origin.x = 0;
        [self.mainMenuView.superview bringSubviewToFront:self.mainMenuView];
    }else{
        theFrame.origin.x = screenSize.size.width;
        [self.mainMenuView setTransparent:NO];
    }
    if (animated) {
        [UIView animateWithDuration:0.5
                              delay:0
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^ {
                             self.mainMenuView.frame = theFrame;
                         }
                         completion:^(BOOL finished) {
                             if(!mustShow){
                                 [self doAfterMenuHide];
                             }else{
                                 [self.mainMenuView setTransparent:YES];
                             }
                         }];
    }else{
        self.mainMenuView.frame = theFrame;
        if(!mustShow){
            [self doAfterMenuHide];
        }else{
            [self.mainMenuView setTransparent:YES];
        }
    }
}

- (void)doAfterMenuHide{
    [self.mainMenuView setHidden:YES];
    [self.mainMenuView.superview sendSubviewToBack:self.mainMenuView];
    self.view.autoresizesSubviews = YES;
}

@end
