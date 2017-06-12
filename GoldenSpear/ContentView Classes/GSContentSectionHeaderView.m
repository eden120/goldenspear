//
//  GSContentSectionHeaderView.m
//  GoldenSpear
//
//  Created by Adria Vernetta Rubio on 5/5/16.
//  Copyright © 2016 GoldenSpear. All rights reserved.
//

#import "GSContentSectionHeaderView.h"

@implementation GSContentSectionHeaderView

- (void)dealloc{
    self.contentId = nil;
}

- (void)awakeFromNib{
    [super awakeFromNib];
    self.backgroundView.layer.shadowColor = [[UIColor blackColor] CGColor];
    self.backgroundView.layer.shadowOffset = CGSizeMake(0,3);
    self.backgroundView.layer.shadowRadius = 5.0;
    self.backgroundView.layer.shadowOpacity = 0.5;
}

- (IBAction)headerTouched:(id)sender {
    [self.delegate headerTouched:self];
}

@end
