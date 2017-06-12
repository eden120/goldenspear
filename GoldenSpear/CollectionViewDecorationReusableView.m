//
//  CollectionViewDecorationReusableView.m
//  GoldenSpear
//
//  Created by Jose Antonio Sanchez Martinez on 02/11/15.
//  Copyright © 2015 GoldenSpear. All rights reserved.
//

#import "CollectionViewDecorationReusableView.h"
#import "UILabel+CustomCreation.h"

NSString *const CollectionViewCustomLayoutElementKindTopDecorationViewImage = @"reset";

@implementation CollectionViewDecorationReusableView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self)
    {
//        UIImage *image = [UIImage imageNamed:CollectionViewCustomLayoutElementKindTopDecorationViewImage];
//        
//        UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
//        
//        imageView.frame = self.bounds;
//        
//        [self addSubview:imageView];

        UILabel *refreshLabel = [UILabel createLabelWithOrigin:self.bounds.origin
                                                andSize:CGSizeMake(320, 20)
                                     andBackgroundColor:[UIColor clearColor]
                                               andAlpha:0.7
                                                andText:NSLocalizedString(@"_PULL_TO_REFRESH", nil)
                                           andTextColor:[UIColor darkGrayColor]
                                                andFont:[UIFont fontWithName:@"Avenir-Light" size:12]
                                         andUppercasing:YES
                                             andAligned:NSTextAlignmentCenter];
        
        [self addSubview:refreshLabel];
    }
    
    return self;
}

+ (CGSize)defaultSize
{
//    return [UIImage imageNamed:CollectionViewCustomLayoutElementKindTopDecorationViewImage].size;
    return CGSizeMake(320, 20);
}

@end
