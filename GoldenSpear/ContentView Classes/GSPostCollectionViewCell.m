//
//  GSPostCollectionViewCell.m
//  GoldenSpear
//
//  Created by Adria Vernetta Rubio on 23/4/16.
//  Copyright © 2016 GoldenSpear. All rights reserved.
//

#import "GSPostCollectionViewCell.h"
#import "GSContentViewPost.h"

@implementation GSPostCollectionViewCell

- (void)setupContentView{
    
    self.backgroundColor = [UIColor grayColor];
    /*
    self.theContent = [GSContentViewPost new];
    [self addSubview:self.theContent];
    self.theContent.viewDelegate = self;
     */
}

- (void)setupContentViewLayout{
    
}

- (void)setContentData:(NSArray*)contentObject{
    if([contentObject count]<7){
        return;
    }
    FashionistaPost* aPost = [contentObject firstObject];
    self.thePost = aPost;
    self.theContent.tag = self.tag;
    [self.theContent setContentData:contentObject];
}

@end
