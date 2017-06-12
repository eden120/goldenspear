//
//  GSSocialAccountModuleView.h
//  GoldenSpear
//
//  Created by Adria Vernetta Rubio on 19/5/16.
//  Copyright © 2016 GoldenSpear. All rights reserved.
//

#import "GSTextAccountModuleView.h"

@class GSAgencyAccountModuleView;

@protocol GSAgencyAccountModuleViewDelegate <NSObject>

- (void)agencyViewPushed:(GSAgencyAccountModuleView*)module withData:(NSArray*)agencyData andPosition:(CGPoint)position;

@end

@interface GSAgencyAccountModuleView : GSTextAccountModuleView

@property (nonatomic,weak) id<GSAgencyAccountModuleViewDelegate> agencyDelegate;

- (void)setAgencyDataForEditingField:(NSArray*)theData;

@end
