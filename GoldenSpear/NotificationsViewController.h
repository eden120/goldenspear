//
//  NotificationsViewController.h
//  GoldenSpear
//
//  Created by Jose Antonio Sanchez Martinez on 17/09/15.
//  Copyright (c) 2015 GoldenSpear. All rights reserved.
//

#import "BaseViewController.h"
#import "NotificationCell.h"

@interface NotificationsViewController : BaseViewController<UITableViewDelegate,UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UIView *notificationsView;

@property (nonatomic, strong) NSOperationQueue *imagesQueue;

// Fetch notifications users
@property NSFetchedResultsController * usersFetchedResultsController;
@property NSFetchRequest * usersFetchRequest;
@property int numberOfNewNotifications;

// Fetch current user follows
@property NSFetchedResultsController * followsFetchedResultsController;
@property NSFetchRequest * followsFetchRequest;

@property (weak, nonatomic) IBOutlet UITableView *noticesTable;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topDistanceConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomDistanceConstraint;

- (IBAction)followButtonPushed:(UIButton *)sender;

@end
