//
//  GSCommentViewController.h
//  GoldenSpear
//
//  Created by Adria Vernetta Rubio on 11/5/16.
//  Copyright © 2016 GoldenSpear. All rights reserved.
//

#import "BaseViewController.h"
#import "KILabel.h"
#import "Comment.h"

@class GSCommentViewController;
@class GSCommentViewCell;

@protocol GSCommentViewDelegate <NSObject>

- (void)commentController:(GSCommentViewController*)controller prepareForUpdateComment:(Comment*)oldComment atIndex:(NSInteger)index;
- (void)commentController:(GSCommentViewController*)controller deleteComment:(Comment*)oldComment atIndex:(NSInteger)index dismiss:(BOOL)dismiss;
- (void)commentController:(GSCommentViewController*)controller openFashionistaWithName:(NSString*)userName;

@end

@protocol GSCommentCellDelegate <NSObject>

- (void)commentCell:(GSCommentViewCell*)cell hashtagTapped:(NSString*)hashTag;
- (void)commentCell:(GSCommentViewCell*)cell urlTapped:(NSString*)url;
- (void)commentCell:(GSCommentViewCell*)cell userTapped:(NSString*)username;

@end

@interface GSCommentViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *userName;
@property (weak, nonatomic) IBOutlet KILabel *commentLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UIButton *deleteButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *deleteButtonWidthConstraint;
@property (weak, nonatomic) IBOutlet UIButton *editButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *editButtonWidthConstraint;
@property (strong, nonatomic) User* commentOwner;
@property (weak, nonatomic) NSString* imageURL;

@property (weak, nonatomic) id<GSCommentCellDelegate> delegate;

- (void)setItem:(Comment*)theComment;
- (IBAction)userLabelPushed:(id)sender;

@end

@interface GSCommentViewController : BaseViewController<UITableViewDelegate,UITableViewDataSource,GSCommentCellDelegate>

@property (weak, nonatomic) IBOutlet UITableView *commentTable;
@property (weak, nonatomic) id<GSCommentViewDelegate> commentDelegate;
@property (strong, nonatomic) NSArray* commentArray;
@property (nonatomic) BOOL shouldEdit;

@property (nonatomic, strong) NSOperationQueue *imagesQueue;

@end
