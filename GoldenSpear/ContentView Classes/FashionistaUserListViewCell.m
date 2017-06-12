//
//  GSUserTableViewCell.m
//  GoldenSpear
//
//  Created by Adria Vernetta Rubio on 12/5/16.
//  Copyright © 2016 GoldenSpear. All rights reserved.
//

#import "FashionistaUserListViewCell.h"

@implementation FashionistaUserListViewCell

- (void)dealloc{
    self.fashionistaId = nil;
    self.imageURL = nil;
}
- (void)prepareForReuse{
    [super prepareForReuse];
    self.userTitle.text = @"";
    self.userName.text = @"";
    self.theImage.image = [UIImage imageNamed:@"no_image.png"];
    self.followingButton.selected = NO;
    self.imageURL = @"";
}

@end