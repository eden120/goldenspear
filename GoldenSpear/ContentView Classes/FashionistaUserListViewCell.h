//
//  GSUserTableViewCell.h
//  GoldenSpear
//
//  Created by Adria Vernetta Rubio on 12/5/16.
//  Copyright © 2016 GoldenSpear. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FashionistaUserListViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *theImage;
@property (weak, nonatomic) IBOutlet UILabel *userName;
@property (weak, nonatomic) IBOutlet UIButton *followingButton;
@property (weak, nonatomic) IBOutlet UILabel *userTitle;

@property (strong, nonatomic) NSString* fashionistaId;
@property (strong, nonatomic) NSString* imageURL;

@end
