//
//  UIView+Shadow.m
//  GoldenSpear
//
//  Created by Jose Antonio Sanchez Martinez on 01/05/15.
//  Copyright (c) 2015 GoldenSpear. All rights reserved.
//

#import "UIView+Shadow.h"

#define kShadowViewtag 2132
#define kValidDirections [NSArray arrayWithObjects: @"top", @"bottom", @"left", @"right",nil]


@implementation UIView (Shadow)

UIView *shadowView;

- (UIView *) makeInsetShadow
{
    NSArray *shadowDirections = [NSArray arrayWithObjects:@"top", @"bottom", @"left" , @"right" , nil];
    UIColor *color = [UIColor colorWithRed:(0.0) green:(0.0) blue:(0.0) alpha:0.5];
    
//    UIView *shadowView = [self createShadowViewWithRadius:3 Color:color Directions:shadowDirections];
    shadowView = [self createShadowViewWithRadius:3 Color:color Directions:shadowDirections Insets:0];
    shadowView.tag = kShadowViewtag;
    
    [self addSubview:shadowView];
    return shadowView;
}

- (UIView *) makeInsetShadowWithRadius:(float)radius Alpha:(float)alpha
{
    NSArray *shadowDirections = [NSArray arrayWithObjects:@"top", @"bottom", @"left" , @"right" , nil];
    UIColor *color = [UIColor colorWithRed:(0.0) green:(0.0) blue:(0.0) alpha:alpha];
    
//    UIView *shadowView = [self createShadowViewWithRadius:radius Color:color Directions:shadowDirections];
    shadowView = [self createShadowViewWithRadius:radius Color:color Directions:shadowDirections Insets:0];
    shadowView.tag = kShadowViewtag;
    
    [self addSubview:shadowView];
    return shadowView;
}

- (UIView *) makeInsetShadowWithRadius:(float)radius Color:(UIColor *)color Directions:(NSArray *)directions
{
    UIView *shadowView = [self createShadowViewWithRadius:radius Color:color Directions:directions Insets:0];
    shadowView.tag = kShadowViewtag;
    
    [self addSubview:shadowView];
    
    return shadowView;
}

- (UIView *) makeInsetShadowWithRadius:(float)radius Color:(UIColor *)color Directions:(NSArray *)directions Insets:(float)inset
{
    UIView *shadowView = [self createShadowViewWithRadius:radius Color:color Directions:directions Insets:inset];
    shadowView.tag = kShadowViewtag;
    
    [self addSubview:shadowView];
    
    return shadowView;
}

- (UIView *) createShadowViewWithRadius:(float)radius Color:(UIColor *)color Directions:(NSArray *)directions Insets:(float)inset
{
    UIView *shadowView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height)];
    shadowView.backgroundColor = [UIColor clearColor];
    shadowView.userInteractionEnabled = NO;
    
    // Ignore duplicate direction
    NSMutableDictionary *directionDict = [[NSMutableDictionary alloc] init];
    for (NSString *direction in directions) [directionDict setObject:@"1" forKey:direction];
    
    for (NSString *direction in directionDict) {
        // Ignore invalid direction
        if ([kValidDirections containsObject:direction])
        {
            CAGradientLayer *shadow = [CAGradientLayer layer];
            
            if ([direction isEqualToString:@"top"]) {
                [shadow setStartPoint:CGPointMake(0.5, 0.0)];
                [shadow setEndPoint:CGPointMake(0.5, 1.0)];
                shadow.frame = CGRectMake(0+inset, 0, self.bounds.size.width-(2*inset), radius);
            }
            else if ([direction isEqualToString:@"bottom"])
            {
                [shadow setStartPoint:CGPointMake(0.5, 1.0)];
                [shadow setEndPoint:CGPointMake(0.5, 0.0)];
                shadow.frame = CGRectMake(0+inset, self.bounds.size.height - radius, self.bounds.size.width-(2*inset), radius);
            } else if ([direction isEqualToString:@"left"])
            {
                shadow.frame = CGRectMake(0, 0+inset, radius, self.bounds.size.height-(2*inset));
                [shadow setStartPoint:CGPointMake(0.0, 0.5)];
                [shadow setEndPoint:CGPointMake(1.0, 0.5)];
            } else if ([direction isEqualToString:@"right"])
            {
                shadow.frame = CGRectMake(self.bounds.size.width - radius, 0+inset, radius, self.bounds.size.height-(2*inset));
                [shadow setStartPoint:CGPointMake(1.0, 0.5)];
                [shadow setEndPoint:CGPointMake(0.0, 0.5)];
            }
            
//            shadow.colors = [NSArray arrayWithObjects:(id)[color CGColor], (id)[[UIColor clearColor] CGColor], nil];
            shadow.colors = [NSArray arrayWithObjects:(id)[color CGColor], (id)[[UIColor colorWithWhite:1.0 alpha:0.0] CGColor], nil];
            [shadowView.layer insertSublayer:shadow atIndex:0];
        }
    }
    
    return shadowView;
}

@end
