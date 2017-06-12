//
//  FashionistaUserListViewController.h
//  GoldenSpear
//
//  Created by Adria Vernetta Rubio on 3/5/16.
//  Copyright © 2016 GoldenSpear. All rights reserved.
//

#import "SearchBaseViewController.h"

@interface FashionistaUserListViewController : SearchBaseViewController<UITableViewDataSource,UITableViewDelegate,UIScrollViewDelegate,UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITableView *userDisplayList;
@property (nonatomic) followingRelationships userListMode;
@property (nonatomic, weak) User* shownRelatedUser;
@property (weak, nonatomic) IBOutlet UITextField *searchTextField;
@property (nonatomic) NSString *postId;
- (IBAction)followButtonPushed:(UIButton *)sender;

@property (nonatomic, strong) NSOperationQueue *imagesQueue;

- (void)operationAfterLoadingSearch:(BOOL)hasResults;
- (IBAction)doSearchPush:(id)sender;

@end
