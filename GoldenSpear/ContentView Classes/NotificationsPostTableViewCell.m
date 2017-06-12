//
//  NotificationsPostTableViewCell.m
//  GoldenSpear
//
//  Created by Adria Vernetta Rubio on 13/5/16.
//  Copyright © 2016 GoldenSpear. All rights reserved.
//

#import "NotificationsPostTableViewCell.h"

@implementation NotificationsPostTableViewCell

- (void)dealloc{
    self.postImageURL = nil;
}

- (void)prepareForReuse{
    [super prepareForReuse];
    self.postImage.image = [UIImage imageNamed:@"no_image.png"];
}

@end
