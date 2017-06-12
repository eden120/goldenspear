//
//  InfoView.h
//  AnimationSample
//
//  Created by jcb on 7/16/16.
//  Copyright © 2016 dikwessels. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol Delegate <NSObject>

-(void)onTapSeeMoreInfo:(NSString *)str;

@end

@interface InfoView : UIViewController

@property(nonatomic, retain) id<Delegate> delegate;
-(void)setText:(NSString*)info;

@end