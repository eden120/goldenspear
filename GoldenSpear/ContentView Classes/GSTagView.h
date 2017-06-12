//
//  GSTagView.h
//  GoldenSpear
//
//  Created by JCB on 8/26/16.
//  Copyright © 2016 GoldenSpear. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GSTagView;

@protocol GSTagViewDelegate <NSObject>

-(void)tagView:(GSTagView*)tagView heightChanged:(CGFloat)newHeight;

@end

@interface GSTagView : UIView

@property (weak, nonatomic) IBOutlet UIView *optionsContainer;

@property (weak, nonatomic) id<GSTagViewDelegate> viewDelegate;

- (id)initWithWidth:(CGFloat)viewWidth andOptions:(NSArray*)optionsArray;

- (void)setOptions:(NSArray*)optionsArray;
- (void)showUpToDown:(BOOL)upToDownOrNot;

@end
