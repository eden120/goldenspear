//
//  SimilarView.h
//  GoldenSpear
//
//  Created by JCB on 7/30/16.
//  Copyright © 2016 GoldenSpear. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol Delegate <NSObject>

-(void)onTapSimilarSeeMore;
-(void)onTapAddtoWardrobeButton:(UIButton *)sender isSimilar:(BOOL)isSimilar;
-(void)onTapSimilarProductItem:(NSInteger)index;

@end

@interface SimilarView : UIViewController

@property(nonatomic, retain) id<Delegate> delegate;

@property (nonatomic) NSMutableArray *products;
@property (nonatomic) NSMutableArray *userWardrobesElements;

-(void)initView;
-(void)animationAppear;

@end