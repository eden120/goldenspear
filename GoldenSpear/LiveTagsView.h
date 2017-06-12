//
//  LiveTagsView.h
//  GoldenSpear
//
//  Created by Crane on 9/23/16.
//  Copyright © 2016 GoldenSpear. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LiveTagsView : UIView
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *searchView;
@property (weak, nonatomic) IBOutlet UITextField *searchBar;
@property (weak, nonatomic) IBOutlet UIView *selectedTagView;
@property (weak, nonatomic) IBOutlet UIView *tagsView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *selectedTagViewHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tagsViewHeight;

@end
