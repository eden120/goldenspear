//
//  CellBackgroundView.m
//  GoldenSpear
//
//  Created by Jose Antonio Sanchez Martinez on 22/04/15.
//  Copyright (c) 2015 GoldenSpear. All rights reserved.
//

#import "CellBackgroundView.h"


@implementation CellBackgroundView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self)
    {
        // Initialization code
    }
    
    return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    CGColorRef cgColorWhite = [UIColor whiteColor].CGColor;
    
    UIColor* color235Gray = [UIColor colorWithRed:235.0/255.0
                                            green:235.0/255.0
                                             blue:235.0/255.0
                                            alpha:1.0];
    CGColorRef cgColor235Gray = color235Gray.CGColor;
    
    UIColor* color214Gray = [UIColor colorWithRed:214.0/255.0
                                            green:214.0/255.0
                                             blue:214.0/255.0
                                            alpha:1.0];
    CGColorRef cgColor214Gray = color214Gray.CGColor;
    
    UIColor* color210Gray = [UIColor colorWithRed:210.0/255.0
                                            green:210.0/255.0
                                             blue:210.0/255.0
                                            alpha:1.0];
    CGColorRef cgColor210Gray = color210Gray.CGColor;
    
    UIColor* color190Gray = [UIColor colorWithRed:190.0/255.0
                                            green:190.0/255.0
                                             blue:190.0/255.0
                                            alpha:1.0];
    CGColorRef cgColor190Gray = color190Gray.CGColor;
    
    //Get the CGContext from this view
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // fill all with white
    CGContextSetFillColorWithColor(context,cgColorWhite);
    CGContextFillRect(context,self.bounds);
    
    CGContextSetLineWidth(context,1.0);
    
    // top
    CGContextSetStrokeColorWithColor(context,cgColor235Gray);
    CGContextMoveToPoint(context,0.0,0.0);
    CGContextAddLineToPoint(context,self.bounds.size.width,0.0);
    CGContextStrokePath(context);
    
    // left
    CGContextSetStrokeColorWithColor(context,cgColor214Gray);
    CGContextMoveToPoint(context,0.0,0.0);
    CGContextAddLineToPoint(context,0.0,self.bounds.size.height);
    CGContextStrokePath(context);
    
    CGContextSetStrokeColorWithColor(context,cgColor235Gray);
    CGContextMoveToPoint(context,1.0,0.0);
    CGContextAddLineToPoint(context,1.0,self.bounds.size.height);
    CGContextStrokePath(context);
    
    // right
    CGContextSetStrokeColorWithColor(context,cgColor235Gray);
    CGContextMoveToPoint(context,self.bounds.size.width - 1.0,0.0);
    CGContextAddLineToPoint(context,self.bounds.size.width - 1.0,self.bounds.size.height);
    CGContextStrokePath(context);
    
    CGContextSetStrokeColorWithColor(context,cgColor214Gray);
    CGContextMoveToPoint(context,self.bounds.size.width - 0.0,0.0);
    CGContextAddLineToPoint(context,self.bounds.size.width - 0.0,self.bounds.size.height);
    CGContextStrokePath(context);
    
    // bottom
    CGContextSetStrokeColorWithColor(context,cgColor190Gray);
    CGContextMoveToPoint(context,0.0,self.bounds.size.height - 1.0);
    CGContextAddLineToPoint(context,self.bounds.size.width,self.bounds.size.height - 1.0);
    CGContextStrokePath(context);
    
    CGContextSetStrokeColorWithColor(context,cgColor210Gray);
    CGContextMoveToPoint(context,0.0,self.bounds.size.height - 0.0);
    CGContextAddLineToPoint(context,self.bounds.size.width,self.bounds.size.height - 0.0);
    CGContextStrokePath(context);
    
}

@end
