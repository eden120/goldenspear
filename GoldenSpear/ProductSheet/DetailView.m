//
//  DetailView.m
//  AnimationSample
//
//  Created by jcb on 7/17/16.
//  Copyright © 2016 dikwessels. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DetailView.h"
#import "AppDelegate.h"
#import <AFNetworking.h>


#define MAX_ROW 5
#define MAX_COL 4

@interface DetailView()

@end

@implementation DetailView {
	//Color View
	UIView *colorView;
	NSMutableArray *color_titles;
	NSMutableArray *color_rowViews;
	NSInteger color_rows;
	//Material View
	UIView *materialView;
	NSMutableArray *material_titles;
	NSMutableArray *material_rowViews;
	NSInteger material_rows;
	
	UISwipeGestureRecognizer *topSwipe;
}

@synthesize height;

-(void)viewDidLoad {
	[super viewDidLoad];
}

-(void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
}

-(void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:YES];
	
	topSwipe.direction = UISwipeGestureRecognizerDirectionUp;
	
	[self initView];
}

-(void)initView{
    NSMutableArray *color_keys = [[_color_images allKeys] mutableCopy];
    
	colorView = [[UIView alloc] init];
	colorView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
	colorView.backgroundColor = [UIColor clearColor];
	
	if ([color_keys count] > 0) {
		_isColor = YES;
	}
	
	color_rowViews = [[NSMutableArray alloc] init];
	if ([color_keys count] > MAX_ROW) {
		
		color_rows = [color_keys count] / MAX_COL;
		
		for (int i = 0; i < color_rows; i ++) {
			UIView *view = [[UIView alloc] init];
			view.frame = CGRectMake(0, i * height / MAX_ROW, self.view.frame.size.width, height / MAX_ROW);
			for (int j = 0; j < MAX_COL; j ++) {
				UIButton *imageButton = [[UIButton alloc] init];
				imageButton.frame = CGRectMake(j * view.frame.size.width/MAX_COL, 0, view.frame.size.width/MAX_COL, view.frame.size.height);
				NSString *url = [NSString stringWithFormat:@"%@%@", IMAGESBASEURL, (NSString*)[_color_images objectForKey:[color_keys objectAtIndex:(i * MAX_COL + j)]]];
                UIImage *image = [UIImage cachedImageWithURL:url];
                [imageButton setBackgroundImage:image forState:UIControlStateNormal];
                [imageButton setAccessibilityLabel:[color_keys objectAtIndex:(i * MAX_COL + j)]];
                [imageButton addTarget:self action:@selector(onTapColorbutton:) forControlEvents:UIControlEventTouchUpInside];
				
				[view addSubview:imageButton];
				[view setAlpha:0.9];
			}
			[colorView addSubview:view];
			[color_rowViews addObject:view];
		}
		
		UIView *view = [[UIView alloc] init];
		view.frame = CGRectMake(0, color_rows * height / MAX_ROW, self.view.frame.size.width, height / MAX_ROW);
		for (int j = 0; j < [_color_images count] % MAX_COL; j ++) {
			UIButton *imageButton = [[UIButton alloc] init];
			imageButton.frame = CGRectMake(j * view.frame.size.width/MAX_COL, 0, view.frame.size.width/MAX_COL, view.frame.size.height);
			NSString *url = [NSString stringWithFormat:@"%@%@", IMAGESBASEURL, (NSString*)[_color_images objectForKey:[color_keys objectAtIndex:(color_rows * MAX_COL + j)]]];
            UIImage *image = [UIImage cachedImageWithURL:url];
            [imageButton setBackgroundImage:image forState:UIControlStateNormal];
            [imageButton setAccessibilityLabel:[color_keys objectAtIndex:(color_rows * MAX_COL + j)]];
            [imageButton addTarget:self action:@selector(onTapColorbutton:) forControlEvents:UIControlEventTouchUpInside];
            
			[view addSubview:imageButton];
			[view setAlpha:0.9];
		}
		
		[colorView addSubview:view];
		[color_rowViews addObject:view];
		
	}
	else {
		color_rows = [self.color_images count];
		
		for (int i = 0; i < color_rows; i++) {
			UIView *view = [[UIView alloc] init];
			view.frame = CGRectMake(0, i * height / color_rows, self.view.frame.size.width, height / color_rows);
			UIButton *imageButton = [[UIButton alloc] init];
			imageButton.frame = CGRectMake(0, 0, view.frame.size.width, view.frame.size.height);
			NSString *url = [NSString stringWithFormat:@"%@%@", IMAGESBASEURL, (NSString*)[_color_images objectForKey:[color_keys objectAtIndex:i]]];
            UIImage *image = [UIImage cachedImageWithURL:url];
            [imageButton setBackgroundImage:image forState:UIControlStateNormal];
            [imageButton setAccessibilityLabel:[color_keys objectAtIndex:i]];
            [imageButton addTarget:self action:@selector(onTapColorbutton:) forControlEvents:UIControlEventTouchUpInside];
            
			[view addSubview:imageButton];
			[view setAlpha:0.9];
			[colorView addSubview:view];
			
			[color_rowViews addObject:view];
		}
	}
	
	
	NSMutableArray *material_keys = [[_material_images allKeys] mutableCopy];
	materialView = [[UIView alloc] init];
	materialView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
	materialView.backgroundColor = [UIColor clearColor];
	
	material_rowViews = [[NSMutableArray alloc] init];
	if ([material_keys count] > MAX_ROW) {
		material_rows = [material_keys count] / MAX_COL;
		
		for (int i = 0; i < material_rows; i ++) {
			UIView *view = [[UIView alloc] init];
			view.frame = CGRectMake(0, i * height / MAX_ROW, self.view.frame.size.width, height / MAX_ROW);
			for (int j = 0; j < MAX_COL; j ++) {
				UIButton *imageButton = [[UIButton alloc] init];
				imageButton.frame = CGRectMake(j * view.frame.size.width/MAX_COL, 0, view.frame.size.width/MAX_COL, view.frame.size.height);
				NSString *url = [NSString stringWithFormat:@"%@%@", IMAGESBASEURL, (NSString*)[_material_images objectForKey:[material_keys objectAtIndex:(i * MAX_COL + j)]]];
                UIImage *image = [UIImage cachedImageWithURL:url];
                [imageButton setBackgroundImage:image forState:UIControlStateNormal];
                [imageButton setAccessibilityLabel:[material_keys objectAtIndex:(i * MAX_COL + j)]];
                [imageButton addTarget:self action:@selector(onTapMaterialbutton:) forControlEvents:UIControlEventTouchUpInside];
				
				[view addSubview:imageButton];
				[view setAlpha:0.9];
			}
			[materialView addSubview:view];
			[material_rowViews addObject:view];
		}
		
		UIView *view = [[UIView alloc] init];
		view.frame = CGRectMake(0, material_rows * height / MAX_ROW, self.view.frame.size.width, height / MAX_ROW);
		for (int j = 0; j < [_material_images count] % MAX_COL; j ++) {
			UIButton *imageButton = [[UIButton alloc] init];
			imageButton.frame = CGRectMake(j * view.frame.size.width/MAX_COL, 0, view.frame.size.width/MAX_COL, view.frame.size.height);
			NSString *url = [NSString stringWithFormat:@"%@%@", IMAGESBASEURL, (NSString*)[_material_images objectForKey:[material_keys objectAtIndex:(material_rows * MAX_COL + j)]]];
            UIImage *image = [UIImage cachedImageWithURL:url];
            [imageButton setBackgroundImage:image forState:UIControlStateNormal];
            [imageButton setAccessibilityLabel:[material_keys objectAtIndex:(material_rows * MAX_COL + j)]];
            [imageButton addTarget:self action:@selector(onTapMaterialbutton:) forControlEvents:UIControlEventTouchUpInside];
            
			[view addSubview:imageButton];
			[view setAlpha:0.9];
		}
		
		[materialView addSubview:view];
		[material_rowViews addObject:view];
	}
	else {
		material_rows = [self.material_images count];
		
		for (int i = 0; i < material_rows; i++) {
			UIView *view = [[UIView alloc] init];
			view.frame = CGRectMake(0, i * height / material_rows, self.view.frame.size.width, height / material_rows);
			UIButton *imageButton = [[UIButton alloc] init];
			imageButton.frame = CGRectMake(0, 0, view.frame.size.width, view.frame.size.height);
			NSString *url = [NSString stringWithFormat:@"%@%@", IMAGESBASEURL, (NSString*)[_material_images objectForKey:[material_keys objectAtIndex:i]]];
            UIImage *image = [UIImage cachedImageWithURL:url];
            [imageButton setBackgroundImage:image forState:UIControlStateNormal];
            [imageButton setAccessibilityLabel:[material_keys objectAtIndex:i]];
            [imageButton addTarget:self action:@selector(onTapMaterialbutton:) forControlEvents:UIControlEventTouchUpInside];
            
			[view addSubview:imageButton];
			[view setAlpha:0.9];
			[materialView addSubview:view];
			
			[material_rowViews addObject:view];
		}
	}
	
	if (_isColor) {
		[self.view addSubview:colorView];
	}
	else if ([self.material_images count] > 0) {
		[self.view addSubview:materialView];
	}
}

-(void)onTapColorbutton:(UIButton*)sender {
    NSLog(@"On Tap Color : %@", sender.accessibilityLabel);
    _color_curated = sender.accessibilityLabel;
    [_delegate onTapDetailButton:_color_curated material:_material_curated];
}

-(void)onTapMaterialbutton:(UIButton*)sender {
    NSLog(@"On Tap Material : %@", sender.accessibilityLabel);
    _material_curated = sender.accessibilityLabel;
    [_delegate onTapDetailButton:_color_curated material:_material_curated];
}

-(void)swipeUp {
	CGRect fromFrame = colorView.frame;
	CGRect toFrame = materialView.frame;
	
	fromFrame.origin.x = 0;
	fromFrame.origin.y = 0;
	[colorView setFrame:fromFrame];
	fromFrame.origin.y = -fromFrame.size.height;
	toFrame.origin.x = 0;
	toFrame.origin.y = toFrame.size.height;
	[materialView setFrame:toFrame];
	toFrame.origin.y = 0;
	
	[self.view setUserInteractionEnabled:NO];
	
	[UIView animateWithDuration:0.8
						  delay:0
						options: UIViewAnimationCurveEaseIn
					 animations:^{
						 [colorView setFrame:fromFrame];
						 [colorView setAlpha:0];
						 [materialView setFrame:toFrame];
						 [materialView setAlpha:0.9];
					 }
					 completion:^(BOOL finished){
						 [self.view setUserInteractionEnabled:YES];
					 }];
	
	[self.view addSubview:materialView];
	_isColor = NO;
}

-(void)swipeDown {
	CGRect fromFrame = materialView.frame;
	CGRect toFrame = colorView.frame;
	
	fromFrame.origin.x = 0;
	fromFrame.origin.y = 0;
	[materialView setFrame:fromFrame];
	fromFrame.origin.y = fromFrame.size.height;
	toFrame.origin.x = 0;
	toFrame.origin.y = -toFrame.size.height;
	[colorView setFrame:toFrame];
	toFrame.origin.y = 0;
	
	[self.view setUserInteractionEnabled:NO];
	
	[UIView animateWithDuration:0.8
						  delay:0
						options: UIViewAnimationCurveEaseIn
					 animations:^{
						 [materialView setFrame:fromFrame];
						 [materialView setAlpha:0];
						 [colorView setFrame:toFrame];
						 [colorView setAlpha:0.9];
					 }
					 completion:^(BOOL finished){
						 [self.view setUserInteractionEnabled:YES];
					 }];
	
	[self.view addSubview: colorView];
	_isColor = YES;
}

-(void)animationAppear {
	if (_isColor) {
		for (int i = 0; i < color_rows; i ++) {
			UIView *view = (UIView *)[color_rowViews objectAtIndex:i];
			CGRect frame = view.frame;
			frame.origin.x = -view.frame.size.width;
			view.frame = frame;
			frame.origin.x = 0;
			
			[UIView animateWithDuration:0.6
								  delay:0.1 * i
								options: UIViewAnimationCurveEaseIn
							 animations:^{
								 [view setFrame:frame];
							 }
							 completion:^(BOOL finished){
							 }];
			[colorView addSubview:view];
			[self.view addSubview:colorView];
		}
	}
	else {
		for (int i = 0; i < material_rows; i ++) {
			UIView *view = (UIView *)[material_rowViews objectAtIndex:i];
			CGRect frame = view.frame;
			frame.origin.x = -view.frame.size.width;
			view.frame = frame;
			frame.origin.x = 0;
			
			[UIView animateWithDuration:0.6
								  delay:0.1 * i
								options: UIViewAnimationCurveEaseIn
							 animations:^{
								 [view setFrame:frame];
							 }
							 completion:^(BOOL finished){
							 }];
			[materialView addSubview:view];
			[self.view addSubview:materialView];
		}
	}
}

-(void)animationDisappear {
	
	if (_isColor) {
		for (int i = 0; i < color_rows; i ++) {
			UIView *view = (UIView *)[color_rowViews objectAtIndex:i];
			CGRect frame = view.frame;
			frame.origin.x = 0;
			view.frame = frame;
			frame.origin.x = -view.frame.size.width;
			
			[UIView animateWithDuration:0.6
								  delay:0.1 * i
								options: UIViewAnimationCurveEaseIn
							 animations:^{
								 [view setFrame:frame];
							 }
							 completion:^(BOOL finished){
							 }];
			[colorView addSubview:view];
			[self.view addSubview:colorView];
		}
	}
	else {
		for (int i = 0; i < material_rows; i ++) {
			UIView *view = (UIView *)[material_rowViews objectAtIndex:i];
			CGRect frame = view.frame;
			frame.origin.x = 0;
			view.frame = frame;
			frame.origin.x = -view.frame.size.width;
			
			[UIView animateWithDuration:0.6
								  delay:0.1 * i
								options: UIViewAnimationCurveEaseIn
							 animations:^{
								 [view setFrame:frame];
							 }
							 completion:^(BOOL finished){
							 }];
			[materialView addSubview:view];
			[self.view addSubview:materialView];
		}
	}
}

@end