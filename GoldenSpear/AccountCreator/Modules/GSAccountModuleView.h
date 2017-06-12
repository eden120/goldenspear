//
//  GSAccountModuleView.h
//  GoldenSpear
//
//  Created by Adria Vernetta Rubio on 18/5/16.
//  Copyright © 2016 GoldenSpear. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GSAccountModule.h"
#import "User.h"

@class GSAccountModuleView;

@protocol GSAccountModuleViewDelegate <NSObject>

- (void)module:(GSAccountModuleView*)module increasedItsSize:(CGFloat)variation;

@end

@interface GSAccountModuleView : UIView{
    User* moduleUser;
}

@property (nonatomic,strong) GSAccountModule* theModule;
@property (nonatomic,weak) id<GSAccountModuleViewDelegate> delegate;

- (void)fillModule:(User*)theUser withAccountModule:(GSAccountModule*)module;

@end
