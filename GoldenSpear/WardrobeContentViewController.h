//
//  WardrobeContentViewController.h
//  GoldenSpear
//
//  Created by Jose Antonio Sanchez Martinez on 04/05/15.
//  Copyright (c) 2015 GoldenSpear. All rights reserved.
//

#import "BaseViewController.h"

@interface WardrobeContentViewController : BaseViewController

@property GSBaseElement * selectedItem;
@property Wardrobe * shownWardrobe;
@property GSBaseElement *shownElement;

// Views to manage moving a item from/to a wardrobe
@property (weak, nonatomic) IBOutlet UIView *moveItemBackgroundView;
@property (weak, nonatomic) IBOutlet UIView *moveItemVCContainerView;

// Views to manage adding an item to a wardrobe
@property (weak, nonatomic) IBOutlet UIView *addToWardrobeBackgroundView;
@property (weak, nonatomic) IBOutlet UIView *addToWardrobeVCContainerView;

// Fetch current user wardrobes
@property NSFetchedResultsController * wardrobesFetchedResultsController;
@property NSFetchRequest * wardrobesFetchRequest;

@property NSString * addingProductsToWardrobeID;
@property Wardrobe * addingProductsToWardrobe;

- (void)closeMovingItemHighlightingButton:(UIButton *)button withSuccess:(BOOL) bSuccess;
- (void)closeAddingItemToWardrobeHighlightingButton:(UIButton *)button withSuccess:(BOOL) bSuccess;

@property BOOL bEditionMode;

// Search query (if any) that lead the user to this post  (for statistics)
@property SearchQuery * searchQuery;

@end
