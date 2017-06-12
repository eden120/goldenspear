//
//  GSPostCollectionViewCell.h
//  GoldenSpear
//
//  Created by Adria Vernetta Rubio on 23/4/16.
//  Copyright © 2016 GoldenSpear. All rights reserved.
//

#import "GSContentCollectionViewCell.h"
#import "FashionistaPost.h"

@interface GSPostCollectionViewCell : GSContentCollectionViewCell

@property (nonatomic,weak) FashionistaPost* thePost;

- (void)setContentData:(NSArray*)contentObject;

@end
