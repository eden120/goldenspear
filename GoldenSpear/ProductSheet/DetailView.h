//
//  DetailView.h
//  AnimationSample
//
//  Created by jcb on 7/17/16.
//  Copyright © 2016 dikwessels. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol Delegate <NSObject>

-(void)onTapDetailButton:(NSString*)color material:(NSString*)material;

@end

@interface DetailView : UIViewController

@property(nonatomic, retain) id<Delegate> delegate;

@property (nonatomic) NSMutableDictionary *color_images;
@property (nonatomic) NSMutableDictionary *material_images;
@property (nonatomic) NSInteger height;
@property (nonatomic) BOOL isColor;
@property (nonatomic) NSString *color_curated;
@property (nonatomic) NSString *material_curated;

-(void)animationAppear;
-(void)animationDisappear;

-(void)swipeDown;
-(void)swipeUp;

@end