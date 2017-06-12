//
//  SizeView.m
//  GoldenSpear
//
//  Created by jcb on 7/25/16.
//  Copyright © 2016 GoldenSpear. All rights reserved.
//

#import "SizeView.h"
#import "MLKMenuPopover.h"

@interface SizeView()

@property (weak, nonatomic) IBOutlet UIView *sizeView;
@property(nonatomic,strong) MLKMenuPopover *menuPopover;
@property (weak, nonatomic) IBOutlet UIButton *sizesettingBTN;

@end

@implementation SizeView {
	NSMutableArray *size_views;
	
}

-(void)viewDidLoad {
	[super viewDidLoad];
	_selectedSize = @"";
	size_views = [[NSMutableArray alloc] init];
	
	[self.view setUserInteractionEnabled:YES];
}

-(void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
}

-(void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:YES];
	
	[self initView];
}

-(void)initView {
	int size_count = [_size_array count];
	
	NSInteger start_x;
	NSInteger start_y;
	NSInteger start_width;
	NSInteger start_height;
	NSInteger delta_x;
	NSInteger start_font;
	NSInteger delta_font;
	NSInteger start_index;
	
	float a = 1.05f;
	start_height = [self getHeight:a num:(size_count - 1) height:self.sizeView.frame.size.height - 65];
    //start_width = [self getWidth:a num:(size_count - 1) width:self.sizeView.frame.size.width / 2];
	if (self.sizeView.frame.size.width < 400) {
		if (size_count < 8) {
			start_x = 20;
			start_y = 15;
			start_width = 25;
			delta_x = 7;
			start_font = 15;
			delta_font = 10;
			start_index = 4 - (size_count / 2) - (size_count % 2);
		}
		else {
			start_x = 20;
			start_y = 15;
			start_width = 25;
			delta_x = 6;
			start_font = 15;
			delta_font = 2;
			start_index = 0;
		}
	}
	else {
		if (size_count < 8) {
			start_x = 20;
			start_y = 30;
			start_width = 25;
			delta_x = 20;
			start_font = 20;
			delta_font = 20;
			start_index = 4 - (size_count / 2) - (size_count % 2);
		}
		else {
			start_x = 20;
			start_y = 30;
			start_width = 25;
			delta_x = 5;
			start_font = 20;
			delta_font = 4;
			start_index = 0;
		}
	}
	
	UIView *view = [[UIView alloc] init];
	CGRect frame = CGRectMake(start_x, start_y, start_width, start_height);
	view.frame = frame;
	[size_views addObject:view];
		
	UILabel *label = [[UILabel alloc] init];
	CGRect label_frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
	label.frame = label_frame;
	if (start_index == 0) {
		label.text = (NSString *)[_size_array objectAtIndex:0];
	}
	else {
		label.text = @"";
	}
	label.numberOfLines = 1;
	label.font = [UIFont fontWithName:@"Avenir-Black" size:start_font];
	if ([_selectedSize isEqualToString:label.text]) {
		label.textColor = [UIColor blackColor];
	}
	else {
		label.textColor = [UIColor grayColor];
	}
	[view addSubview:label];
	[self.sizeView addSubview:view];
	
	for (int i = 1; i < [_size_array count]; i++) {
		NSInteger w = start_width + delta_x * i;
		NSInteger h = start_height * powf(a, i);
		
		UIView *view = [[UIView alloc] init];
		UIView *pre_view = (UIView *)[size_views objectAtIndex:(i - 1)];
		CGRect frame = CGRectMake(pre_view.frame.origin.x + pre_view.frame.size.width - w/2, pre_view.frame.size.height + pre_view.frame.origin.y, w, h);
			
		UILabel *label = [[UILabel alloc] init];
		CGRect label_frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
		label.frame = label_frame;
			
		if (i < start_index) {
			label.text = @"";
		}
		else {
			label.text = (NSString *)[_size_array objectAtIndex:i];
		}
		label.numberOfLines = 1;
		label.font = [UIFont fontWithName:@"Avenir-Black" size:(start_font + delta_font * i)];
		label.adjustsFontSizeToFitWidth = YES;
		if ([_selectedSize isEqualToString:label.text]) {
			label.textColor = [UIColor blackColor];
		}
		else {
			label.textColor = [UIColor grayColor];
		}
		[view addSubview:label];
        view.frame = frame;
		[size_views addObject:view];
		[self.sizeView addSubview:view];
	}
}

- (IBAction)onTapSizeSettings:(id)sender {
	[self.menuPopover dismissMenuPopover];
    
	CGRect frame = CGRectMake(self.sizesettingBTN.frame.origin.x, _sizesettingBTN.frame.origin.y + _sizesettingBTN.frame.size.height, _sizesettingBTN.frame.size.width, 30 * [_size_array count]);
    if (self.view.frame.size.width < 400) {
        frame.size.height = 25 * [_size_array count];
    }
	NSArray *menuItems = [NSArray arrayWithArray:_size_array];
	self.menuPopover = [[MLKMenuPopover alloc] initWithFrame:frame menuItems:menuItems];
	
	self.menuPopover.menuPopoverDelegate = self;
	[self.menuPopover showInView:self.view];
}

#pragma mark -
#pragma mark MLKMenuPopoverDelegate

- (void)menuPopover:(MLKMenuPopover *)menuPopover didSelectMenuItemAtIndex:(NSInteger)selectedIndex
{
	[self.menuPopover dismissMenuPopover];
	
    _selectedSize = [self.size_array objectAtIndex:selectedIndex];
    [self initView];
}


#pragma mark - get first height
-(NSInteger)getHeight:(float)f num:(NSInteger)num height:(CGFloat)height {
	NSInteger h;
	
	float S = (powf(f, num) - 1) * f / (f - 1);
	h = height / S;
	return h;
}

-(NSInteger)getWidth:(float)f num:(NSInteger)num width:(CGFloat)width {
    NSInteger w;
    
    float s = 0.5 * (1 + (powf(f, num) - 1) * f / (f - 1));
    w = width / s;
    
    return w;
}

@end