//
//  NotificationsPostTableViewCell.h
//  GoldenSpear
//
//  Created by Adria Vernetta Rubio on 13/5/16.
//  Copyright © 2016 GoldenSpear. All rights reserved.
//

#import "FashionistaUserListViewCell.h"

@interface NotificationsPostTableViewCell : FashionistaUserListViewCell

@property (weak, nonatomic) IBOutlet UIImageView *postImage;

@property (strong, nonatomic) NSString* postImageURL;

@end
