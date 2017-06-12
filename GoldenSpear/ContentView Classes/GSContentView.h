//
//  GSContentView.h
//  GoldenSpear
//
//  Created by Adria Vernetta Rubio on 20/4/16.
//  Copyright © 2016 GoldenSpear. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GSTaggableView.h"
#import "GSCollapsableLabelContainer.h"
#import "GSOptionsView.h"
#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>

typedef enum{
    GSPostContentHeightChangeReasonImage,
    GSPostContentHeightChangeReasonComments
}GSPostContentHeightChangeReason;

@class GSContentView;

@protocol GSContentViewDelegate <NSObject>

-(void)contentView:(GSContentView*)contentView heightChanged:(CGFloat)newHeight reason:(GSPostContentHeightChangeReason)aReason forceResize:(BOOL)forceResize;

@optional
-(void)contentView:(GSContentView*)contentView downloadProfileImage:(NSString*)imageURL;
-(void)contentView:(GSContentView*)contentView downloadContentImage:(NSString*)imageURL;

@end

@interface GSContentView : UIView<GSOptionsViewDelegate,GSTaggableViewDelegate,UIGestureRecognizerDelegate>{
    BOOL showingOptions;
}

@property (weak, nonatomic) IBOutlet UIScrollView *contentScroll;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *headerHeightConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *contentImage;
@property (weak, nonatomic) IBOutlet UILabel *contentTitle;
@property (weak, nonatomic) IBOutlet UILabel *contentSubtitle;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UIButton *likesButton;
@property (weak, nonatomic) IBOutlet UILabel *likesLabel;
@property (weak, nonatomic) IBOutlet UIButton *likeButton;
//@property (weak, nonatomic) IBOutlet GSCollapsableLabelContainer *commentsView;
@property (weak, nonatomic) IBOutlet GSOptionsView *optionsView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *optionsViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *optionsViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *taggableViewHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *commentsViewHeightConstraint;
@property (weak, nonatomic) IBOutlet GSTaggableView *taggableView;
@property (weak, nonatomic) IBOutlet UIView *contentHeader;
@property (weak, nonatomic) IBOutlet UITableView *commentsTableView;

@property (weak,nonatomic) IBOutlet id<GSContentViewDelegate> viewDelegate;

@property (strong, nonatomic) id contentObject;

- (IBAction)optionsPushed:(UIButton *)sender;
- (IBAction)likePushed:(UIButton *)sender;
- (IBAction)commentPushed:(id)sender;
- (IBAction)getLikePushed:(id)sender;
- (IBAction)closeOptionsGR:(id)sender;
- (void)showOptions:(BOOL)showOrNot fromPoint:(CGPoint)anchor;
- (void)hideHeaderView:(BOOL)hideOrNot;

- (void)extraSetupView;
- (void)addLostConstraints;

- (void)setProfileImage;

- (void)setLikeState:(BOOL)likedOrNot;
- (void)getLikeUsers;
- (void)setLikesNumber:(NSInteger)numberOfLikes;
- (void)addCommentObject:(id)comment;

/* Protected methods to be implemented on subclasses */
- (void)commentContent;
- (void)likeContent:(BOOL)likeOrNot;
- (void)setContentData:(id)contentObject currentTime:(CMTime)currentTime hasSound:(BOOL)sound;
- (void)initOptionsView;
- (void)initComments;

@end
