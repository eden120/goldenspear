//
//  GetTheLookView.h
//  GoldenSpear
//
//  Created by jcb on 7/28/16.
//  Copyright © 2016 GoldenSpear. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol Delegate <NSObject>

-(void)onTapGetLookSeeMore;
-(void)onTapAddtoWardrobeButton:(UIButton *)sender isSimilar:(BOOL)isSimilar;
-(void)onTapProductItem:(NSInteger)index;

@end

@interface GetTheLookView : UIViewController

@property(nonatomic, retain) id<Delegate> delegate;

@property (nonatomic) NSMutableArray *products;
@property (nonatomic) NSMutableArray *userWardrobesElements;

-(void)initView;
-(void)animationAppear;

@end