//
//  ProductImageView.m
//  GoldenSpear
//
//  Created by jcb on 7/21/16.
//  Copyright © 2016 GoldenSpear. All rights reserved.
//

#import "ProductImageView.h"

#import <AFNetworking.h>

@interface ProductImageView()

@end

@implementation ProductImageView {
	BOOL isZoom;
}

@synthesize currentIndex, productPreviews;

-(void)viewDidLoad {
	[super viewDidLoad];
	
	isZoom = NO;
	productPreviews = [[NSMutableArray alloc] init];
}

-(void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:YES];
	for (int i = 0; i < [_images count]; i ++) {
		UIImageView *product_Image = [[UIImageView alloc] init];
		[product_Image setFrame:CGRectMake(0, 0, self.productImgPreview.frame.size.width, self.productImgPreview.frame.size.height)];
		NSURL *url = [NSURL URLWithString:(NSString*)[_images objectAtIndex:i]];
		[product_Image setContentMode:UIViewContentModeScaleAspectFit];
		[product_Image setImageWithURL:url];
		
		[productPreviews addObject:product_Image];
	}
	
	[self.productImgPreview addSubview:(UIImageView*)[productPreviews objectAtIndex:0]];
	currentIndex = 0;
}

-(void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
}

-(void)swipePreview:(BOOL)isLeft {
	if (isLeft) {
		NSLog(@" *** SWIPE LEFT ***");
		if (currentIndex < [productPreviews count] - 1) {
			[self slideProduct:currentIndex + 1];
		}
		else if (currentIndex == [productPreviews count] - 1) {
			[self slideProduct:0];
		}
	}
	else {
		NSLog(@" *** SWIPE RIGHT ***");
		if (currentIndex > 0) {
			[self slideProduct:currentIndex - 1];
		}
		else if (currentIndex == 0) {
			NSInteger index = [productPreviews count]- 1;
			[self slideProduct:index];
		}
	}
}

#pragma mark - Swipe Left/Right
-(void)slideProduct:(NSInteger)index {
	UIImageView *fromView = (UIImageView*)[productPreviews objectAtIndex:currentIndex];
	UIImageView *toView = (UIImageView*)[productPreviews objectAtIndex:index];
	
	if (currentIndex == [productPreviews count] - 1 && index == 0) {
		[self animationTransitionProduct:fromView toView:toView isLeft:YES];
	}
	else if (currentIndex == 0 && index == [productPreviews count] - 1) {
		[self animationTransitionProduct:fromView toView:toView isLeft:NO];
	}
	else if (currentIndex > index) {
		[self animationTransitionProduct:fromView toView:toView isLeft:NO];
	}
	else {
		[self animationTransitionProduct:fromView toView:toView isLeft:YES];
	}
	
	currentIndex = index;
}

-(void)animationTransitionProduct:(UIImageView*)fromView toView:(UIImageView*)toView isLeft:(BOOL)isLeft {
	
	if (isLeft) {
		CGRect fromFrame = fromView.frame;
		CGRect toFrame = toView.frame;
		
		fromFrame.origin.x = -fromFrame.size.width;
		toFrame.origin.x = toFrame.size.width;
		[toView setFrame:toFrame];
		toFrame.origin.x = 0;
		
		[UIView animateWithDuration:0.5
							  delay:0
							options: UIViewAnimationCurveEaseIn
						 animations:^{
							 [fromView setFrame:fromFrame];
							 [toView setFrame:toFrame];
						 }
						 completion:^(BOOL finished){
						 }];
		[self.productImgPreview addSubview:toView];
	}
	else {
		CGRect fromFrame = fromView.frame;
		CGRect toFrame = toView.frame;
		
		fromFrame.origin.x = fromFrame.size.width;
		toFrame.origin.x = -toFrame.size.width;
		[toView setFrame:toFrame];
		toFrame.origin.x = 0;
		
		[UIView animateWithDuration:0.5
							  delay:0
							options: UIViewAnimationCurveEaseIn
						 animations:^{
							 [fromView setFrame:fromFrame];
							 [toView setFrame:toFrame];
						 }
						 completion:^(BOOL finished){
						 }];
		[self.productImgPreview addSubview:toView];
	}
}

@end