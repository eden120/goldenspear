//
//  GSTaggedHistoryViewController.h
//  GoldenSpear
//
//  Created by Adria Vernetta Rubio on 16/5/16.
//  Copyright © 2016 GoldenSpear. All rights reserved.
//

#import "BaseViewController.h"

@interface GSTaggedHistoryViewController : BaseViewController<UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate>

@property (strong, nonatomic) NSMutableArray* postsIdsArray;
@property (strong, nonatomic) NSMutableArray* postsArray;
@property (nonatomic, strong) NSOperationQueue *imagesQueue;

@property (weak, nonatomic) IBOutlet UITableView *dataTable;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UITableView *monthSelectorTable;
@end
