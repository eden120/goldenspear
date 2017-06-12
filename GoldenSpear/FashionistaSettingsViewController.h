//
//  FashionistaSettingsViewController.h
//  GoldenSpear
//
//  Created by Jose Antonio Sanchez Martinez on 28/07/15.
//  Copyright (c) 2015 GoldenSpear. All rights reserved.
//

#import "BaseViewController.h"

@interface FashionistaSettingsViewController : BaseViewController <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *fashionistaName;
@property (weak, nonatomic) IBOutlet UITextField *fashionistaBlogURL;
@property (weak, nonatomic) IBOutlet UITextField *fashionistaMessage;

@property BOOL bEditionMode;
@property FashionistaPage * creatingFashionistaPage;

@property FashionistaPost * selectedPost;
@property FashionistaPost * selectedPostToDelete;
@property NSMutableArray * postsGroups;
@property NSMutableArray * postsArray;

// Fetch current user wardrobes
@property NSFetchedResultsController * wardrobesFetchedResultsController;
@property NSFetchRequest * wardrobesFetchRequest;

// Views to manage adding an item to a wardrobe
@property (weak, nonatomic) IBOutlet UIView *addToWardrobeBackgroundView;
@property (weak, nonatomic) IBOutlet UIView *addToWardrobeVCContainerView;
- (void)closeAddingItemToWardrobeHighlightingButton:(UIButton *)button withSuccess:(BOOL) bSuccess;

@end
