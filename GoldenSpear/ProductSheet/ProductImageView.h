//
//  ProductImageView.h
//  GoldenSpear
//
//  Created by jcb on 7/21/16.
//  Copyright © 2016 GoldenSpear. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProductImageView : UIViewController

@property (weak, nonatomic) IBOutlet UIView *productImgPreview;
@property (nonatomic) NSMutableArray *images;
@property NSMutableArray *productPreviews;
@property NSInteger currentIndex;

-(void)swipePreview:(BOOL)isLeft;

@end
