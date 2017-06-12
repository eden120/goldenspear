//
//  BaseViewController+MainMenuManagement.h
//  GoldenSpear
//
//  Created by Jose Antonio Sanchez Martinez on 16/04/15.
//  Copyright (c) 2015 GoldenSpear. All rights reserved.
//

#import "BaseViewController.h"


@interface BaseViewController (MainMenuManagement) <MainMenuViewDelegate>

// Main menu management
@property MainMenuView *mainMenuView;
@property NSArray *menuEntries;
- (void)showMainMenu:(UIButton *)sender;
- (void)initMainMenu;
- (void)hideMainMenu;
@end
