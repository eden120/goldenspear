//
//  GSShowInfoViewController.h
//  GoldenSpear
//
//  Created by Adria Vernetta Rubio on 8/5/16.
//  Copyright © 2016 GoldenSpear. All rights reserved.
//

#import "BaseViewController.h"
#import "User.h"

@interface GSShowInfoViewController : BaseViewController
@property (weak, nonatomic) IBOutlet UIScrollView *contentScroll;
@property (weak, nonatomic) IBOutlet UILabel *noInformationLabel;

@property (weak, nonatomic) User* shownStylist;
@end
