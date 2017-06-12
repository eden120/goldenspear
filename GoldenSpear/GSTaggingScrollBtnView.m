//
//  GSTaggingScrollBtnView.m
//  GoldenSpear
//
//  Created by Crane on 8/2/16.
//  Copyright © 2016 GoldenSpear. All rights reserved.
//

#import "GSTaggingScrollBtnView.h"

@interface GSTaggingScrollBtnView ()

//@property (weak, nonatomic) IBOutlet UIButton *swatchbtn;
//@property (weak, nonatomic) IBOutlet UIButton *editImgbtn;
//@property (weak, nonatomic) IBOutlet UIButton *tagbtn;
//@property (weak, nonatomic) IBOutlet UIButton *commentbtn;
//@property (weak, nonatomic) IBOutlet UIButton *locationbtn;

@end

@implementation GSTaggingScrollBtnView

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if (self)
    {
        [self commonInit];
    }
    
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self)
    {
        [self commonInit];
    }
    
    return self;
}

- (void)commonInit
{
//    UIView *view = nil;
//    
//    NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"GSTaggingScrollBtnView"
//                                                     owner:self
//                                                   options:nil];
//    
//    for (id object in objects)
//    {
//        if ([object isKindOfClass:[UIView class]])
//        {
//            view = object;
//            break;
//        }
//    }
    
//    if (view != nil)
//    {
//        _containerView = view;
//        
//        view.translatesAutoresizingMaskIntoConstraints = NO;
//        
//        [self addSubview:view];
//        
//        [[self class] addEdgeConstraint:NSLayoutAttributeLeft constant:0 superview:self subview:_containerView];
//        [[self class] addEdgeConstraint:NSLayoutAttributeRight constant:6 superview:self subview:_containerView];
//        [[self class] addEdgeConstraint:NSLayoutAttributeTop constant:5 superview:self subview:_containerView];
//        [[self class] addEdgeConstraint:NSLayoutAttributeBottom constant:5 superview:self subview:_containerView];
//        
//        [self setNeedsUpdateConstraints];
//    }
}

+(void)addEdgeConstraint:(NSLayoutAttribute)edge constant:(CGFloat)constant superview:(UIView *)superview subview:(UIView *)subview
{
    [superview addConstraint:[NSLayoutConstraint constraintWithItem:subview
                                                          attribute:edge
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:superview
                                                          attribute:edge
                                                         multiplier:1
                                                           constant:constant]];
}

@end
