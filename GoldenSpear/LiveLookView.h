//
//  LiveLookView.h
//  GoldenSpear
//
//  Created by Crane on 9/22/16.
//  Copyright © 2016 GoldenSpear. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LiveLookView : UIView
@property (weak, nonatomic) IBOutlet UITextField *searchBar;
@property (weak, nonatomic) IBOutlet UITableView *searchResultTableView;
@property (weak, nonatomic) IBOutlet UIView *collectionViewLayer;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableviewHeightContrast;
@property (weak, nonatomic) IBOutlet UIView *searchView;

@end
