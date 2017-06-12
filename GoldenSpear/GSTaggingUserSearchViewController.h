//
//  GSTaggingUserSearchViewController.h
//  GoldenSpear
//
//  Created by Crane on 8/3/16.
//  Copyright © 2016 GoldenSpear. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SearchBaseViewController.h"

@interface GSTaggingUserSearchViewController : SearchBaseViewController<UITableViewDataSource,UITableViewDelegate,UIScrollViewDelegate,UITextFieldDelegate, MFMailComposeViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UIButton *manualBtn;
@property (weak, nonatomic) IBOutlet UIScrollView *toolScrollView;

@property (weak, nonatomic) IBOutlet UITableView *userDisplayList;
@property (nonatomic) followingRelationships userListMode;
@property (nonatomic, weak) User* shownRelatedUser;
@property (weak, nonatomic) IBOutlet UITextField *searchTextField;
@property (weak, nonatomic) IBOutlet UIView *notFoundView;
@property (weak, nonatomic) IBOutlet UILabel *notFoundMsgLab;
@property (weak, nonatomic) IBOutlet UILabel *notFoundTitleLab;
@property (weak, nonatomic) IBOutlet UIButton *thnBtn;
@property (weak, nonatomic) IBOutlet UIButton *yesBtn;
- (IBAction)manualAction:(id)sender;

- (IBAction)followButtonPushed:(UIButton *)sender;

@property (nonatomic, strong) NSOperationQueue *imagesQueue;

- (void)operationAfterLoadingSearch:(BOOL)hasResults;
- (IBAction)doSearchPush:(id)sender;
- (IBAction)cancel:(id)sender;
- (IBAction)thnkAction:(id)sender;
- (IBAction)yesAction:(id)sender;


@end
