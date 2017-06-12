//
//  TabSlide.h
//  ControlsGoldenSpear
//
//  Created by Alberto Seco on 28/4/15.
//  Copyright (c) 2015 com example. All rights reserved.
//

#import "SlideButtonView.h"

@interface TabSlideView : SlideButtonView

+(void) drawLine:(UIView *)view topleft:(CGPoint) pTopLeft bottomright:(CGPoint) pBottomRight withColor:(UIColor*) color andLineWidth:(float)width;

@end
