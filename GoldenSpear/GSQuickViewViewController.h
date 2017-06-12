//
//  GSQuickViewViewController.h
//  GoldenSpear
//
//  Created by Adria Vernetta Rubio on 6/5/16.
//  Copyright © 2016 GoldenSpear. All rights reserved.
//

#import "BaseViewController.h"
#import "FashionistaPost.h"
#import "GSImageCollectionViewCell.h"
@class GSQuickViewViewController;

@protocol GSQuickViewDelegate <NSObject>

- (void)detailTappedForQuickView:(GSQuickViewViewController*)vC;
- (void)commentContentForQuickView:(GSQuickViewViewController*)vC;
- (void)quickView:(GSQuickViewViewController*)vC viewProfilePushed:(User*)theUser;
- (void)showMessageWithImageNamed:(NSString*)imageNamed andSharedObject:(Share*)sharedObject;
- (void)quickViewLikeUpdatingFinished;

@end

@interface GSQuickViewViewController : BaseViewController <GSImageCollectionCellDelegate>

@property (strong, nonatomic) IBOutletCollection(UIView) NSArray *framedViews;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *headerTopDistanceConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *footerTopDistanceConstraint;

@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UIImageView *headerImage;
@property (weak, nonatomic) IBOutlet UILabel *headerTitle;
@property (weak, nonatomic) IBOutlet UILabel *headerDate;

@property (weak, nonatomic) IBOutlet UIButton *likesButton;
@property (weak, nonatomic) IBOutlet UIButton *profileButton;
@property (weak, nonatomic) IBOutlet UIView *footerView;

@property (weak, nonatomic) IBOutlet UIImageView *postImage;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *postImageHeight;

@property (weak, nonatomic) id<GSQuickViewDelegate> delegate;
@property (weak, nonatomic) NSIndexPath* itemIndexPath;

@property (nonatomic, strong) NSOperationQueue *imagesQueue;

- (void)setPost:(NSArray*)aPost;
- (void)setPostWithPost:(GSBaseElement*)post;

- (IBAction)likePushed:(id)sender;
- (IBAction)viewProfilePushed:(id)sender;
- (IBAction)commentPushed:(id)sender;
- (IBAction)sharePushed:(id)sender;
- (IBAction)imageTapped:(id)sender;
- (void)closeVC;

@end
