//
//  FashionistaAddCommentViewController.h
//  GoldenSpear
//
//  Created by Adria Vernetta Rubio on 2/5/16.
//  Copyright © 2016 GoldenSpear. All rights reserved.
//

#import "BaseViewController.h"
#import "Comment.h"

@protocol FashionistaAddCommentDelegate <NSObject>

- (void)updateNewComment:(Comment*)theComment;
- (void)updateOldComment:(Comment*)theComment atIndex:(NSInteger)index;

@end

@interface FashionistaAddCommentViewController : BaseViewController <UITextViewDelegate, UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *commentButtonBottom;
@property (weak, nonatomic) IBOutlet UITextView *commentTextEdit;
@property (weak, nonatomic) IBOutlet UITableView *autoTableView;
@property (weak, nonatomic) id<FashionistaAddCommentDelegate> commentDelegate;
@property (weak, nonatomic) Comment* oldComment;
@property (nonatomic) NSInteger commentIndex;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *autoTableHeight;

@property (nonatomic, strong) NSOperationQueue *imagesQueue;

- (IBAction)addCommentTap:(id)sender;

@end
