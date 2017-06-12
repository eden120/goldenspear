//
//  SeeMoreView.m
//  GoldenSpear
//
//  Created by jcb on 7/25/16.
//  Copyright © 2016 GoldenSpear. All rights reserved.
//

#import "SeeMoreView.h"

@interface SeeMoreView()

@property (weak, nonatomic) IBOutlet UILabel *seeMoreLabel;

@end

@implementation SeeMoreView

-(void)viewDidLoad {
	[super viewDidLoad];
	
}

-(void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
}

-(void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:YES];
	
	CGSize maximumLabelSize = CGSizeMake(296, FLT_MAX);
	
	CGSize expectedLabelSize = [_infoStr sizeWithFont:_seeMoreLabel.font constrainedToSize:maximumLabelSize lineBreakMode:_seeMoreLabel.lineBreakMode];
	
	CGRect frame = _seeMoreLabel.frame;
	frame.size.height = expectedLabelSize.height;
	frame.origin.y = (self.view.frame.size.height - expectedLabelSize.height) / 2;
	_seeMoreLabel.frame = frame;
	_seeMoreLabel.text = _infoStr;
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapClose:)];
    singleTap.numberOfTapsRequired = 1;
    [self.view addGestureRecognizer:singleTap];
}

- (IBAction)onTapCloseSeeMore:(id)sender {
	[self dismissViewControllerAnimated:YES completion:nil];
}

-(void)onTapClose:(UITapGestureRecognizer*)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end