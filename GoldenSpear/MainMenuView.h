//
//  MainMenuView.h
//  GoldenSpear
//
//  Created by Jose Antonio Sanchez Martinez on 08/04/15.
//  Copyright (c) 2015 GoldenSpear. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MainMenuView;

// Set up a delegate to notify the view controller when the rating changes
@protocol MainMenuViewDelegate

- (void)mainMenuView:(MainMenuView *)mainMenuView selectionDidChange:(int)menuEntry;
- (float)getYOriginForMenuView;
- (void)bringTopBarViewToFront;

//New layout functions
- (void)moveMainMenu:(BOOL)mustShow animated:(BOOL)animated;

@end

@interface MainMenuView : UIView

// Menu entries spacing and size
@property (assign) int midMargin;
@property (assign) int vertMargin;
@property (assign) int outerMargin;
@property (assign) CGSize minEntrySize;

// Set of children menu entries
@property (strong) NSMutableArray * menuSectionLabels;
@property (strong) NSMutableArray * menuEntryViews;
@property (strong) NSArray * menuEntriesStructure;

// Max menu entries (minimum is assumed 0)
@property (assign, nonatomic) int maxEntries;

// Selected menu entry
@property (assign, nonatomic) int selectedEntry;

// Track delegate
@property (assign) id <MainMenuViewDelegate> delegate;

@property (assign) int leftOverflow;

// Show and hide the menu view
- (void)showMainMenuViewAnimated: (BOOL) bAnimated;
- (void)hideMainMenuViewAnimated: (BOOL) bAnimated;

// Initialize the Main Menu View entries
- (void) initMainMenuWithEntries:(NSArray *) menuEntries andMidMargin:(float) midMargin andOuterMargin:(float) outerMargin andMinEntrySize:(CGSize) minEntrySize andDelegate: (id <MainMenuViewDelegate>)delegate;

- (void)setTransparent:(BOOL)isVisible;

@end
