//
//  ShareView.h
//  GoldenSpear
//
//  Created by jcb on 7/28/16.
//  Copyright © 2016 GoldenSpear. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol Delegate <NSObject>

-(void)onTapShare:(NSInteger)index;

@end

@interface ShareView : UIViewController

@property(nonatomic, retain) id<Delegate> delegate;
@property(nonatomic) BOOL isEnd;

-(void)swipeUp:(NSInteger)height;
-(void)swipeDown;

@end