//
//  GSOptionsView.h
//  GoldenSpear
//
//  Created by Adria Vernetta Rubio on 20/4/16.
//  Copyright © 2016 GoldenSpear. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GSOptionsView;

@protocol GSOptionsViewDelegate <NSObject>

-(void)optionsView:(GSOptionsView*)optionView selectOptionAtIndex:(NSInteger)option;
-(void)optionsView:(GSOptionsView*)optionView heightChanged:(CGFloat)newHeight;

@end

@interface GSOptionsView : UIView

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *angleLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomAngleLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *containerBgTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *containerBgBottomConstraint;
@property (weak, nonatomic) IBOutlet UIView *optionsContainer;
@property (weak, nonatomic) IBOutlet UIImageView *angleImage;
@property (weak, nonatomic) IBOutlet UIImageView *bottomAngleImage;

@property (weak, nonatomic) id<GSOptionsViewDelegate> viewDelegate;

- (id)initWithWidth:(CGFloat)viewWidth andOptions:(NSArray*)optionsArray;

- (void)moveAngleToPosition:(CGFloat)x;
- (void)setOptions:(NSArray*)optionsArray;
- (void)showUpToDown:(BOOL)upToDownOrNot;

@end
