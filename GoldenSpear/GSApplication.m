//
//  GSApplication.m
//  GoldenSpear
//
//  Created by Alberto Seco on 7/9/15.
//  Copyright (c) 2015 GoldenSpear. All rights reserved.
//

#import "GSApplication.h"
#import <Foundation/Foundation.h>

@implementation GSApplication


- (void)sendEvent:(UIEvent*)event {
    //handle the event (you will probably just reset a timer)
    /*
    switch(event.type)
    {
        case UIEventTypeTouches:
        {
            NSSet *set = event.allTouches;
            NSArray *array = [set allObjects];
            UITouch *touchEvent= [array lastObject];
            UIView *view=[touchEvent view];
            
            UIViewController * topMostController = view.window.rootViewController;
            while (topMostController.presentedViewController != nil)
            {
                topMostController = topMostController.presentedViewController;
            }
            NSString * controllerName = NSStringFromClass([topMostController class]);
            
            UIView * topMostView = topMostController.view;
            
            if (touchEvent.phase == UITouchPhaseBegan)
            {
                CGPoint point = [touchEvent locationInView: view];
                CGPoint topMostPoint = [touchEvent locationInView: topMostView];
                NSLog(@"Event Touches Began Pos: (%f,%f) in view %@. Began Pos: (%f,%f) in topMostView %@. Controller: %@", point.x, point.y, NSStringFromClass([view class]) ,topMostPoint.x, topMostPoint.y, NSStringFromClass([topMostView class]), controllerName);
            }
            if (touchEvent.phase == UITouchPhaseMoved)
            {
                CGPoint point = [touchEvent locationInView: view];
                CGPoint topMostPoint = [touchEvent locationInView: topMostView];
                NSLog(@"Event Touches Moved Pos: (%f,%f) in view %@. Began Pos: (%f,%f) in topMostView %@. Controller: %@", point.x, point.y, NSStringFromClass([view class]), topMostPoint.x, topMostPoint.y, NSStringFromClass([topMostView class]),controllerName);
            }
            if (touchEvent.phase == UITouchPhaseEnded)
            {
                CGPoint point = [touchEvent locationInView: view];
                CGPoint topMostPoint = [touchEvent locationInView: topMostView];
                NSLog(@"Event Touches Ended Pos: (%f,%f) in view %@. Began Pos: (%f,%f) in topMostView %@. Controller: %@", point.x, point.y, NSStringFromClass([view class]), topMostPoint.x, topMostPoint.y, NSStringFromClass([topMostView class]),controllerName);
            }
            break;
        }
        case UIEventTypeMotion:
        {
            NSLog(@"Event Motion %ld", (long)event.type);
            break;
        }
        case UIEventTypeRemoteControl:
        {
            NSLog(@"Event RemoteControl %ld", (long)event.type);
            break;
        }
    }
    */
    
    [super sendEvent:event];
}
@end
