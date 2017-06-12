//
//  GSCollapsableLabelContainer.h
//  GoldenSpear
//
//  Created by Adria Vernetta Rubio on 20/4/16.
//  Copyright © 2016 GoldenSpear. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KILabel.h"

@class GSCollapsableLabelContainer;

@protocol GSCollapsableLabelContainerDelegate <NSObject>

-(void)collapsableLabelContainer:(GSCollapsableLabelContainer*)collapsableView heightChanged:(CGFloat)newHeight;
-(void)collapsableLabelContainer:(GSCollapsableLabelContainer*)collapsableView urlTapped:(NSString*)url;
-(void)collapsableLabelContainer:(GSCollapsableLabelContainer*)collapsableView userTapped:(NSString*)username;
-(void)collapsableLabelContainer:(GSCollapsableLabelContainer*)collapsableView hashtagTapped:(NSString*)hashtag;
-(void)collapsableLabelContainer:(GSCollapsableLabelContainer*)collapsableView ownerTapped:(NSString*)owner;

@end

@interface GSCollapsableLabelContainer : UIView{
    NSInteger maxLabelNum;
}

@property (weak, nonatomic) id<GSCollapsableLabelContainerDelegate> viewDelegate;

- (void)setLabelsWithArray:(NSArray*)objectArray;
- (void)collapseWithMoreThan:(NSInteger)maxLabels;

- (void)addLabelWithObject:(id)object;

- (void)redrawView;

@end
