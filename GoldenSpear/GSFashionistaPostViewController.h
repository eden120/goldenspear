//
//  GSFashionistaPostViewController.h
//  GoldenSpear
//
//  Created by Adria Vernetta Rubio on 10/5/16.
//  Copyright © 2016 GoldenSpear. All rights reserved.
//

#import "BaseViewController.h"
#import "GSContentViewPost.h"
#import "GSImageTaggableView.h"
#import "FashionistaAddCommentViewController.h"
#import "CustomAlertView.h"
#import "GSCommentViewController.h"
#import "FullVideoViewController.h"
#import "HTHorizentalSelection/HTHorizontalSelectionList.h"
#import "MagazineMoreViewController.h"
#import "MagazineRelationViewController.h"

@class MagazineMoreViewController, MagazineRelationViewController;

@interface GSFashionistaPostViewController : BaseViewController<GSContentViewPostDelegate,GSContentViewDelegate,GSOptionsViewDelegate,FashionistaAddCommentDelegate,CustomAlertViewDelegate,GSTaggableViewDelegate,GSCommentViewDelegate,FullVideoViewDelegate, HTHorizontalSelectionListDelegate, HTHorizontalSelectionListDataSource, UITextFieldDelegate> {
    
    MagazineMoreViewController *magazineMoreVC;
    MagazineRelationViewController *magazineRelatedVC;
}

@property (strong, nonatomic) NSArray* postParameters;
@property (weak, nonatomic) IBOutlet UIScrollView *contentScroll;
@property (weak, nonatomic) IBOutlet GSContentViewPost *contentView;
@property (weak, nonatomic) IBOutlet UIView *optionsBackground;
@property (weak, nonatomic) IBOutlet GSOptionsView *optionsView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *optionsViewTop;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *optionsViewHeight;
@property (weak, nonatomic) IBOutlet UIView *containerVC;
@property (weak, nonatomic) IBOutlet HTHorizontalSelectionList *topNaviList;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topNaviHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *wardrobeBackground;
@property (weak, nonatomic) IBOutlet UIView *wardrobeVC;

@property (weak, nonatomic) IBOutlet UIView *wardrobeNameView;
@property (weak, nonatomic) IBOutlet UITextField *wardrobeName;

@property (nonatomic, strong) NSOperationQueue *imagesQueue;

@property NSFetchedResultsController * keywordsFetchedResultsController;
@property NSFetchRequest * keywordssFetchRequest;
@property User* shownStylist;

- (IBAction)closeOptions:(id)sender;
-(void)showFullVideo:(NSInteger)orientation;
// Search query (if any) that lead the user to this post  (for statistics)
@property SearchQuery * searchQuery;

// Manage adding an item to a wardrobe
@property NSString * addingProductsToWardrobeID;
@property Wardrobe * addingProductsToWardrobe;
// Fetch current user wardrobes
@property NSFetchedResultsController * wardrobesFetchedResultsController;
@property NSFetchRequest * wardrobesFetchRequest;

- (void)closeAddingItemToWardrobeHighlightingButton:(UIButton *)button withSuccess:(BOOL)bSuccess;

@end
