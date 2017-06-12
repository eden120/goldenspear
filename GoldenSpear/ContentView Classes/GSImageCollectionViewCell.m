//
//  GSImageCollectionViewCell.m
//  GoldenSpear
//
//  Created by Adria Vernetta Rubio on 23/4/16.
//  Copyright © 2016 GoldenSpear. All rights reserved.
//

#import "GSImageCollectionViewCell.h"

@implementation GSImageCollectionViewCell

- (void)prepareForReuse{
    self.theImage.image = [UIImage imageNamed:@"no-image.png"];
}

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    self.clipsToBounds = YES;
    self.backgroundColor = [UIColor clearColor];
    self.theImage = [UIImageView new];
    self.theImage.contentMode = UIViewContentModeScaleAspectFill;
    [self addSubview:self.theImage];
    self.hangerButton = [UIButton new];
    [self.hangerButton setImage:[UIImage imageNamed:@"hanger_unchecked.png"] forState:UIControlStateNormal];
    [self addSubview:self.hangerButton];
    self.titleLabel = [UILabel new];
    [self.titleLabel setTextAlignment:UITextAlignmentCenter];
    [self.titleLabel setFont:[UIFont fontWithName:@"Avenir-Light" size:16]];
    [self addSubview:self.titleLabel];
    self.magazineIcon = [UIImageView new];
    self.magazineIcon.contentMode = UIViewContentModeScaleAspectFill;
    self.magazineIcon.image = [UIImage imageNamed:@"magazineicon.png"];
    [self addSubview:_magazineIcon];
    self.wardrobeIcon = [UIImageView new];
    self.wardrobeIcon.contentMode = UIViewContentModeScaleAspectFill;
    self.wardrobeIcon.image = [UIImage imageNamed:@"hanger_unchecked.png"];
    [self addSubview:_wardrobeIcon];
    self.postIcon = [UIImageView new];
    self.postIcon.contentMode = UIViewContentModeScaleAspectFill;
    self.postIcon.image = [UIImage imageNamed:@"postImagesNum.png"];
    [self addSubview:_postIcon];
    UILongPressGestureRecognizer* longRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
    [self addGestureRecognizer:longRecognizer];
    return self;
}

- (void)longPress:(UILongPressGestureRecognizer*)gesture{
    if (gesture.state == UIGestureRecognizerStateBegan) {
        [self.cellDelegate longPressedCell:self];
    }
    if (gesture.state == UIGestureRecognizerStateEnded) {
        [self.cellDelegate closeQV];
    }
}

- (void)dealloc{
    self.theImage = nil;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    self.theImage.frame = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.width);
    self.hangerButton.frame = CGRectMake(self.bounds.size.width - 28, 8, 20, 20);
    self.titleLabel.frame = CGRectMake(0, self.bounds.size.height - 20, self.bounds.size.width, 20);
    self.magazineIcon.frame = CGRectMake(self.bounds.size.width - 28, 8, 20, 20);
    self.wardrobeIcon.frame = CGRectMake(self.bounds.size.width - 28, 8, 20, 20);
    self.postIcon.frame = CGRectMake(self.bounds.size.width - 28, 8, 20, 20);
}

@end
