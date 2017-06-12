//
//  GSContentCollectionViewCell.m
//  GoldenSpear
//
//  Created by Adria Vernetta Rubio on 23/4/16.
//  Copyright © 2016 GoldenSpear. All rights reserved.
//

#import "GSContentCollectionViewCell.h"


@implementation GSContentCollectionViewCell{
    NSLayoutConstraint* contentHeightConstraint;
}

- (void)extraSetup{
    self.translatesAutoresizingMaskIntoConstraints = NO;
    [self setupContentView];
    [self setupContentViewLayout];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    [self extraSetup];
    return self;
}

- (instancetype)init{
    self = [super init];
    [self extraSetup];
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    [self extraSetup];
    return self;
}

- (void)setupContentView{
    self.theContent = [GSContentView new];
    self.theContent.viewDelegate = self;
    [self addSubview:self.theContent];
}

- (void)setupContentViewLayout{
    //Height
    contentHeightConstraint = [NSLayoutConstraint constraintWithItem:self.theContent
                                                                    attribute:NSLayoutAttributeHeight
                                                                    relatedBy:NSLayoutRelationEqual
                                                                       toItem:nil
                                                                    attribute:NSLayoutAttributeNotAnAttribute
                                                                   multiplier:1
                                                                     constant:400];
    [self.theContent addConstraint:contentHeightConstraint];
    //Width
    NSLayoutConstraint* aConstraint = [NSLayoutConstraint constraintWithItem:self.theContent
                                               attribute:NSLayoutAttributeWidth
                                               relatedBy:NSLayoutRelationEqual
                                                  toItem:self
                                               attribute:NSLayoutAttributeWidth
                                              multiplier:1
                                                constant:0];
    [self addConstraint:aConstraint];
    //Center Hori
    aConstraint = [NSLayoutConstraint constraintWithItem:self.theContent
                                               attribute:NSLayoutAttributeCenterX
                                               relatedBy:NSLayoutRelationEqual
                                                  toItem:self
                                               attribute:NSLayoutAttributeCenterX
                                              multiplier:1
                                                constant:0];
    [self addConstraint:aConstraint];
    //Center Vert
    aConstraint = [NSLayoutConstraint constraintWithItem:self.theContent
                                               attribute:NSLayoutAttributeCenterY
                                               relatedBy:NSLayoutRelationEqual
                                                  toItem:self
                                               attribute:NSLayoutAttributeCenterY
                                              multiplier:1
                                                constant:0];
    [self addConstraint:aConstraint];
}

- (void)dealloc{
    self.theContent = nil;
}

- (void)setCellHidesHeader:(BOOL)hideHeader{
    [self.theContent hideHeaderView:hideHeader];
}

- (void)contentView:(GSContentView *)contentView heightChanged:(CGFloat)newHeight{
    contentHeightConstraint.constant = newHeight;
    [self.theContent layoutIfNeeded];
    [self.cellDelegate contentCollectionView:self heightChanged:newHeight];
}

- (void)contentView:(GSContentView *)contentView downloadProfileImage:(NSString *)imageURL{
    [self.cellDelegate contentCollectionView:self downloadProfileImage:imageURL];
}

- (void)contentView:(GSContentView *)contentView downloadContentImage:(NSString *)imageURL{
    [self.cellDelegate contentCollectionView:self downloadProfileImage:imageURL];
}

@end
