//
//  MainMenuView.m
//  GoldenSpear
//
//  Created by Jose Antonio Sanchez Martinez on 08/04/15.
//  Copyright (c) 2015 GoldenSpear. All rights reserved.
//

#import "MainMenuView.h"
#import "MenuSection.h"
#import "MenuEntry.h"
#import "MenuEntryView.h"
#import "AppDelegate.h"
#import "GSUnderlinedLabel.h"

#define kMenuSectionsHeaderHeight 25

@interface MainMenuView (){
    UIScrollView* menuContainer;
    UIButton* leftCloseButton;
    UIView* blackSeparator;
}

@end

@implementation MainMenuView

// Initialize variables to default values
- (void)initMainMenuView
{
    _menuEntryViews = [[NSMutableArray alloc] init];
    _menuSectionLabels = [[NSMutableArray alloc] init];
    _maxEntries = 1;
    _selectedEntry = -1;
    _midMargin = 10;
    _outerMargin = 10;
    _minEntrySize = CGSizeMake(35, 35);
    _menuEntriesStructure = nil;
    _delegate = nil;
    
    [self setUserInteractionEnabled:YES];
    
    [self setupBasicUI];
    
}

- (void)setupBasicUI{
    menuContainer = [UIScrollView new];
    menuContainer.backgroundColor = [UIColor whiteColor];
    menuContainer.userInteractionEnabled = YES;
    [self addSubview:menuContainer];
    [self setupCloseButton];
    [self setupLeftCloseButton];
    [self setupBlackSeparatorAndBackground];
}

// View controller can add the view programatically
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self)
    {
        [self initMainMenuView];
    }
    
    return self;
}

// View controller can add the view via XIB
- (id)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super initWithCoder:aDecoder]))
    {
        [self initMainMenuView];
    }
    return self;
}

// Initialize the Main Menu View entries
- (void) initMainMenuWithEntries:(NSArray *) menuEntries andMidMargin:(float) midMargin andOuterMargin:(float) outerMargin andMinEntrySize:(CGSize) minEntrySize andDelegate: (id <MainMenuViewDelegate>)delegate
{
    [self setDelegate:delegate];
     
    [self setMidMargin:midMargin];
    [self setOuterMargin:outerMargin];
    [self setMinEntrySize:minEntrySize];
    
    /*
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSNumber* lastEntryNumber = [defaults objectForKey:GSLastMenuEntry];
    int lastEntry = -1;
    if (lastEntryNumber!=nil) {
        lastEntry = [lastEntryNumber intValue];
    }
    [self setSelectedEntry:lastEntry];
    */
    [self setupMenuEntryViews: menuEntries];
}

//Adds Close Button on top right corner
- (void)setupCloseButton{
    UIButton* closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage* theImage = [UIImage imageNamed:@"close_x.png"];
    [closeButton setImage:theImage forState:UIControlStateNormal];
    [closeButton addTarget:self action:@selector(closeMenu:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:closeButton];
    CGRect screenSize = [[UIScreen mainScreen] bounds];
    int iFrameWidth = screenSize.size.width;
    closeButton.frame = CGRectMake(iFrameWidth - theImage.size.width - 10, 10, theImage.size.width, theImage.size.height);
}

//Adds Close Button on top left corner
- (void)setupLeftCloseButton{
    leftCloseButton = [UIButton buttonWithType:UIButtonTypeCustom];
    leftCloseButton.backgroundColor = GOLDENSPEAR_COLOR;
    UIImage* theImage = [UIImage imageNamed:@"menubutton_on.png"];
    [leftCloseButton setImage:theImage forState:UIControlStateNormal];
    [leftCloseButton addTarget:self action:@selector(closeMenu:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:leftCloseButton];
    leftCloseButton.frame = CGRectMake(0, 0, theImage.size.width, theImage.size.height);
}

- (void)setupBlackSeparatorAndBackground{
    CGRect screenSize = [[UIScreen mainScreen] bounds];
    int iFrameHeight = screenSize.size.height;
    UIView* backgroundView = [UIView new];
    backgroundView.backgroundColor = [UIColor whiteColor];
    [self addSubview:backgroundView];
    backgroundView.frame = CGRectMake(leftCloseButton.frame.size.width, 0, screenSize.size.width, iFrameHeight);
    [self sendSubviewToBack:backgroundView];
    
    blackSeparator = [UIView new];
    blackSeparator.backgroundColor = [UIColor blackColor];
    blackSeparator.frame = CGRectMake(leftCloseButton.frame.size.width, 0, 2, iFrameHeight);
    [self addSubview:blackSeparator];
    self.leftOverflow = blackSeparator.frame.origin.x;
}

// Refresh view based on the current entry selection
- (void)updateMainMenuView
{
    // Loop through the list of entries
    for(int i=0; i<self.menuEntryViews.count; ++i)
    {
        MenuEntryView *menuEntry = [self.menuEntryViews objectAtIndex:i];
        
        // Set the appropriate border based on the selection
        if (self.selectedEntry == i)
        {
            //[menuEntry.layer setBorderWidth:3];
            //[menuEntry.layer setBorderColor:[UIColor blackColor].CGColor];
            [menuEntry setBackgroundColor:GOLDENSPEAR_COLOR];
            [menuEntry.menuEntryLabel setTextColor:[UIColor whiteColor]];
            //[menuEntry.layer setCornerRadius:10];
        }
        else
        {
            //[menuEntry.layer setBorderWidth:0];
            //[menuEntry.layer setBorderColor:[UIColor lightGrayColor].CGColor];
            [menuEntry setBackgroundColor:[UIColor whiteColor]];
            [menuEntry.menuEntryLabel setTextColor:[UIColor darkGrayColor]];
        }
    }
}


// Set up the frames of all subviews whenever the frame of the view changes
- (void)layoutSubviews
{
    CGFloat viewY = 20;
    int numMenuEntry = 0;

    [super layoutSubviews];
    
    // Check if the view is already setup
    if (self.delegate == nil)
    {
        return;
    }
    
    self.vertMargin = 0;
    
    CGFloat sectionMargin = 15;
    
    // Calculate the frames for each entry
    CGRect screenSize = [[UIScreen mainScreen] bounds];
    CGFloat blackSeparatorEnd = blackSeparator.frame.origin.x+blackSeparator.frame.size.width;
    int iFrameWidth = screenSize.size.width-blackSeparatorEnd;
    int iFrameHeight = screenSize.size.height;
    CGFloat entryBorder = 40;
    CGFloat iconsWidth = 30;
    _minEntrySize = CGSizeMake(iFrameWidth-2*entryBorder, 30);
    float desiredEntryHeight = 35;
    
    float entryHeight = MAX(self.minEntrySize.height, desiredEntryHeight);
    
    float entryWidth = self.minEntrySize.width;
    
    menuContainer.frame = CGRectMake(blackSeparatorEnd, 0, iFrameWidth-entryBorder, iFrameHeight);
    // Loop through the menu sections
    for(int iSection = 0; iSection < [self.menuEntriesStructure count]; iSection++)
    {
        if(iSection>0){
            viewY += sectionMargin;
        }
        // Set the appropriate frame size
        UILabel *menuSectionLabel = [self.menuSectionLabels objectAtIndex:iSection];
        
        menuSectionLabel.frame = CGRectMake(entryBorder+iconsWidth+5, viewY, entryWidth-iconsWidth-5, kMenuSectionsHeaderHeight);
        NSString* sectionTitle = [((MenuSection *)[self.menuEntriesStructure objectAtIndex:iSection]) sectionTitle];
        CGFloat labelWidth = menuSectionLabel.frame.size.width;
        menuSectionLabel.text = sectionTitle;
        [menuSectionLabel sizeToFit];
        CGRect theFrame = menuSectionLabel.frame;
        theFrame.size.width = labelWidth;
        if(theFrame.size.height==0){
            viewY -= sectionMargin;
            theFrame.origin.y -= sectionMargin;
            theFrame.size.height = 2;
        }
        menuSectionLabel.frame = theFrame;
        
        [menuSectionLabel setTextColor:[UIColor blackColor]];
        [menuSectionLabel setTextAlignment:NSTextAlignmentLeft];
        [menuSectionLabel setFont:[UIFont fontWithName:@"Avenir-Black" size:16]];

        [menuContainer addSubview:menuSectionLabel];
        [menuContainer bringSubviewToFront:menuSectionLabel];
        
        viewY += menuSectionLabel.frame.size.height;
        
        // Loop through the list of entries
        int iNumEntries = (int)[[((MenuSection *)[self.menuEntriesStructure objectAtIndex:iSection]) sectionEntries] count];
        
        for(int iEntry = 0; iEntry < iNumEntries; ++iEntry)
        {
            
            // Set the appropriate frame size
            MenuEntryView *menuEntryView = [self.menuEntryViews objectAtIndex:numMenuEntry];
            menuEntryView.layer.borderWidth = 0.0;
            
            CGRect entryFrame = CGRectMake(entryBorder, viewY, entryWidth, entryHeight);
            menuEntryView.frame = entryFrame;
            
            menuEntryView.menuEntryIcon.frame = CGRectMake(0,0,iconsWidth, entryHeight);
            menuEntryView.menuEntryLabel.frame = CGRectMake(iconsWidth+5,0,entryWidth-iconsWidth-10, entryHeight);
            menuEntryView.menuEntryButton.frame = menuEntryView.bounds;
            numMenuEntry++;
            
            viewY += menuEntryView.frame.size.height +self.vertMargin;
        }
    }
    
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, screenSize.size.width, screenSize.size.height);
    
    [self setBackgroundColor:[UIColor colorWithWhite:1 alpha:0.8]];
    menuContainer.contentSize = CGSizeMake(1, viewY);
}

// Set menu entries (therefore, how many UIViews we have)
- (void)setupMenuEntryViews:(NSArray *)menuEntries
{
    self.menuEntriesStructure = menuEntries;

    // Remove old sections
    for(int i = 0; i < self.menuSectionLabels.count; ++i)
    {
        UILabel *menuSection = (UILabel *) [self.menuSectionLabels objectAtIndex:i];
        
        [menuSection removeFromSuperview];
    }

    [self.menuSectionLabels removeAllObjects];

    // Remove old entries
    for(int i = 0; i < self.menuEntryViews.count; ++i)
    {
        MenuEntryView *menuEntry = (MenuEntryView *) [self.menuEntryViews objectAtIndex:i];
        
        [menuEntry removeFromSuperview];
    }
    
    [self.menuEntryViews removeAllObjects];
    
    int nEntry = 0;
    
    // Loop through the menu sections
    for(int iSection = 0; iSection < [self.menuEntriesStructure count]; iSection++)
    {
        GSUnderlinedLabel *sectionEntry = [[GSUnderlinedLabel alloc] initWithFrame:CGRectMake(0,0,40,30)];
        
        [self.menuSectionLabels addObject:sectionEntry];
        
        [menuContainer addSubview:sectionEntry];

        // Loop through the list of entries
        for(int iEntry = 0; iEntry < [[((MenuSection *)[self.menuEntriesStructure objectAtIndex:iSection]) sectionEntries] count]; ++iEntry)
        {
            MenuEntryView *menuEntry = [[MenuEntryView alloc] initWithFrame:CGRectMake(0,0,40,30)];
            [menuEntry.menuEntryButton addTarget:self action:@selector(menuEntryPushed:) forControlEvents:UIControlEventTouchUpInside];
            menuEntry.menuEntryButton.tag = nEntry;
            nEntry++;
            menuEntry.menuEntryIcon.image = [((MenuEntry*)[[((MenuSection *)[self.menuEntriesStructure objectAtIndex:iSection]) sectionEntries] objectAtIndex:iEntry]) entryIcon];
            
            [menuEntry.menuEntryIcon setAlpha:0.4];
            
            menuEntry.menuEntryLabel.text = [((MenuEntry*)[[((MenuSection *)[self.menuEntriesStructure objectAtIndex:iSection]) sectionEntries] objectAtIndex:iEntry]) entryText];
            
            [self.menuEntryViews addObject:menuEntry];
            
            [menuContainer addSubview:menuEntry];
        }
    }
    
    _maxEntries = (int)[self.menuEntryViews count];
    
    // Relayout and refresh
    //[self setNeedsLayout];
    [self layoutSubviews];
    
    [self updateMainMenuView];
}

- (void)menuEntryPushed:(UIButton*)sender{
    [(AppDelegate *)[[UIApplication sharedApplication] delegate] resetTabIndex];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[NSNumber numberWithInt:(int)sender.tag] forKey:GSLastMenuEntry];
    [defaults synchronize];
    //self.selectedEntry = (int)sender.tag;
    [self.delegate mainMenuView:self selectionDidChange:(int)sender.tag];
}

// Set entry selection
- (void)setSelectedEntry:(int)selectedEntry
{
    _selectedEntry = selectedEntry;

    

    [self updateMainMenuView];
}

// Handle user interaction
- (void)handleTouchAtLocation:(CGPoint)touchLocation
{
    int newEntrySelection = -1;
    
    // Loop through the entry labels
    for(int i = 0; i < self.menuEntryViews.count; i++)
    {
        UIView *menuEntry = [self.menuEntryViews objectAtIndex:i];
        
        // Check if the coordinates is within the entry label
        if(CGRectContainsPoint(menuEntry.frame, touchLocation))
        {
            newEntrySelection = i;
            break;
        }
    }
    
    self.selectedEntry = newEntrySelection;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    
    CGPoint touchLocation = [touch locationInView:self];
    
    [self handleTouchAtLocation:touchLocation];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    
    CGPoint touchLocation = [touch locationInView:self];
    
    [self handleTouchAtLocation:touchLocation];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.delegate mainMenuView:self selectionDidChange:self.selectedEntry];
}

- (void) closeMenu:(id)sender{
    [self hideMainMenuViewAnimated:YES];
}

// Show view animated
- (void) showMainMenuViewAnimated: (BOOL) bAnimated
{
    if ([self isHidden])
    {
        [self setTransparent:NO];
        [self setHidden:NO];
        [self.delegate moveMainMenu:YES animated:bAnimated];
    }
}

// Hide view animated
- (void) hideMainMenuViewAnimated: (BOOL) bAnimated
{
    if (![self isHidden])
    {
        leftCloseButton.hidden = YES;
        [self.delegate moveMainMenu:NO animated:bAnimated];
    }
}

- (void)setTransparent:(BOOL)isVisible{
    if(isVisible){
        leftCloseButton.hidden = NO;
        self.backgroundColor = [UIColor colorWithWhite:1 alpha:0.8];
    }else{
        self.backgroundColor = [UIColor colorWithWhite:1 alpha:0];
    }
}

/*
 Old Menu layout
 // Set up the frames of all subviews whenever the frame of the view changes
 - (void)layoutSubviews
 {
 CGFloat viewY = self.outerMargin;
 int numMenuEntry = 0;
 
 [super layoutSubviews];
 
 // Check if the view is already setup
 if (self.delegate == nil)
 {
 return;
 }
 
 self.vertMargin = 5;
 
 // Calculate the frames for each entry
 CGRect screenSize      = [[UIScreen mainScreen] bounds];
 int iFrameWidth = screenSize.size.width;//_minEntrySize.width;
 int iFrameHeight = screenSize.size.height;
 _minEntrySize = ((IS_IPHONE_4_OR_LESS) ? (CGSizeMake(100, 55)) : ((IS_IPHONE_5) ? (CGSizeMake(100, 70)) : (CGSizeMake(120, 70))));
 float desiredEntryHeight = 30;//(self.frame.size.height - (self.outerMargin*2) - ([self.menuEntriesStructure count]*kMenuSectionsHeaderHeight) - (((2*self.outerMargin)*[self.menuEntriesStructure count]) - 1) - (self.midMargin*self.menuEntryViews.count)) / self.menuEntryViews.count;
 
 float entryHeight = MAX(self.minEntrySize.height, desiredEntryHeight);
 
 float entryWidth = self.minEntrySize.width;
 
 // Loop through the menu sections
 for(int iSection = 0; iSection < [self.menuEntriesStructure count]; iSection++)
 {
 // Set the appropriate frame size
 UILabel *menuSectionLabel = [self.menuSectionLabels objectAtIndex:iSection];
 
 menuSectionLabel.frame = CGRectMake(self.frame.origin.x+4, viewY, iFrameWidth-8, kMenuSectionsHeaderHeight);
 menuSectionLabel.text = [((MenuSection *)[self.menuEntriesStructure objectAtIndex:iSection]) sectionTitle];
 [menuSectionLabel setBackgroundColor:[UIColor colorWithRed:0.65 green:0.65 blue:0.65 alpha:0.75]];//[UIColor colorWithRed:0.95 green:0.80 blue:0.46 alpha:0.95]];
 
 [menuSectionLabel setTextColor:[UIColor whiteColor]];
 [menuSectionLabel setTextAlignment:NSTextAlignmentCenter];
 [menuSectionLabel setFont:[UIFont fontWithName:@"Avenir-Black" size:15]];
 
 [self addSubview:menuSectionLabel];
 [self bringSubviewToFront:menuSectionLabel];
 
 viewY += (menuSectionLabel.frame.size.height + self.midMargin);
 
 int iNumEntriesPerRow = 3;
 int iCurrentRowEntry = 0;
 
 // Loop through the list of entries
 int iNumEntries = (int)[[((MenuSection *)[self.menuEntriesStructure objectAtIndex:iSection]) sectionEntries] count];
 
 float initialMargin = 0.0;
 
 for(int iEntry = 0; iEntry < iNumEntries; ++iEntry)
 {
 if(iCurrentRowEntry == 0)
 {
 int iEntriesLeft = iNumEntries - iEntry;
 //if(iEntriesLeft > iNumEntriesPerRow)
 iEntriesLeft = 3;
 
 
 
 initialMargin = (iFrameWidth - ((iEntriesLeft*_minEntrySize.width) + (iEntriesLeft-1.0)*self.midMargin)) / 2.0;
 }
 
 // Set the appropriate frame size
 MenuEntryView *menuEntryView = [self.menuEntryViews objectAtIndex:numMenuEntry];
 menuEntryView.layer.borderWidth = 0.0;
 
 float x = initialMargin + _minEntrySize.width * iCurrentRowEntry + (_midMargin * iCurrentRowEntry);
 
 CGRect entryFrame = CGRectMake(x, viewY, entryWidth, entryHeight);
 
 menuEntryView.frame = entryFrame;
 
 menuEntryView.menuEntryLabel.frame = CGRectMake(0,entryHeight*0.6 + 5,_minEntrySize.width, entryHeight*0.35);
 menuEntryView.menuEntryIcon.frame = CGRectMake(0,0,_minEntrySize.width, entryHeight*0.6);
 
// @Javi: si en la función ‘layoutSubviews’, donde se hace el “menuEntryView.menuEntryLabel.frame = …” le pones que en lugar de toda la view ocupe, por ejemplo, el 20% inferior, esa label quedará abajo; si ademas ajustas el “ menuEntryView.menuEntryIcon.frame” para que ocupe el 80% superior, ahi se mostrará una UIImageView.
numMenuEntry++;

iCurrentRowEntry++;

if(iCurrentRowEntry == iNumEntriesPerRow)
{
    viewY += (menuEntryView.frame.size.height + self.vertMargin);
    iCurrentRowEntry = 0;
}
else if(iEntry == (iNumEntries-1))
{
    viewY += (menuEntryView.frame.size.height + self.vertMargin);
}
}
}

self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, iFrameWidth, iFrameHeight);//self.outerMargin + viewY);
[self setBackgroundColor:[UIColor whiteColor]];
}
 */

/* Old Menu animations
// Show view animated
- (void) showMainMenuViewAnimated: (BOOL) bAnimated
{
    if ([self isHidden])
    {
        [self setHidden:NO];

        [self.delegate bringTopBarViewToFront];
 
        if (bAnimated)
        {
            [UIView animateWithDuration:0.5
                                  delay:0
                                options:UIViewAnimationOptionCurveEaseOut
                             animations:^ {
 
                                 [self setAlpha:1.0];
 
                                 [self setTransform:CGAffineTransformMakeTranslation(0, [self.delegate getYOriginForMenuView])];
                             }
                             completion:^(BOOL finished) {
                                 
                             }];
        }
        else
        {
            [self.delegate bringTopBarViewToFront];
            [self setAlpha:1.0];
            [self setTransform:CGAffineTransformMakeTranslation(0, [self.delegate getYOriginForMenuView])];
        }
        
    }
}

// Hide view animated
- (void) hideMainMenuViewAnimated: (BOOL) bAnimated
{
    if (![self isHidden])
    {
        [self.delegate bringTopBarViewToFront];

        if (bAnimated)
        {
            [UIView animateWithDuration:0.5
                                  delay:0
                                options:UIViewAnimationOptionCurveEaseOut
                             animations:^ {
                                 
                                 [self setAlpha:0.0];
                                 [self setTransform:CGAffineTransformMakeTranslation(0, -290)];
                                 
                             }
                             completion:^(BOOL finished) {
                                 
                                 [self setHidden:YES];
                                 
                             }];
        }
        else
        {
            [self.delegate bringTopBarViewToFront];
            [self setHidden:YES];
            [self setAlpha:0.0];
            [self setTransform:CGAffineTransformMakeTranslation(0, -290)];
        }
    }
}
*/

@end
