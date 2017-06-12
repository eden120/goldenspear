//
//  ShareView.m
//  GoldenSpear
//
//  Created by jcb on 7/28/16.
//  Copyright © 2016 GoldenSpear. All rights reserved.
//

#import "ShareView.h"
#import "AppDelegate.h"

#define COLS        4
#define ROWS        6

@interface ShareView()

@property (weak, nonatomic) IBOutlet UIView *bgView;

@end

@implementation ShareView {
    UIView *shareView;
}

-(void)viewDidLoad {
	[super viewDidLoad];
    
    _isEnd = NO;
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:YES];
    
    _isEnd = NO;
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:YES];
}


-(void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
}

-(void)onTapButton:(UIButton*)sender {
    [_delegate onTapShare:sender.tag];
}

- (IBAction)onTapMESSAGE:(id)sender {
    [_delegate onTapShare:MESSAGE];
}
- (IBAction)onTapMMS:(id)sender {
    [_delegate onTapShare:MMS];
}
- (IBAction)onTapEmail:(id)sender {
    [_delegate onTapShare:EMAIL];
}
- (IBAction)onTapPINTEREST:(id)sender {
    [_delegate onTapShare:PINTEREST];
}
- (IBAction)onTapLINKEDIN:(id)sender {
    [_delegate onTapShare:LINKEDIN];
}
- (IBAction)onTapINSTAGRAM:(id)sender {
    [_delegate onTapShare:INSTAGRAM];
}
- (IBAction)onTapSNAPCHAT:(id)sender {
    [_delegate onTapShare:SNAPCHAT];
}
- (IBAction)onTapFACEBOOK:(id)sender {
    [_delegate onTapShare:FACEBOOK];
}
- (IBAction)onTapTUMBLR:(id)sender {
    [_delegate onTapShare:TUMBLR];
}
- (IBAction)onTapFLICKER:(id)sender {
    [_delegate onTapShare:FLIKER];
}
- (IBAction)onTapTWITTER:(id)sender {
    [_delegate onTapShare:TWITTER];
}

-(void)swipeUp:(NSInteger)height {
    CGRect frame = self.bgView.frame;
    frame.origin.y = height - 6 * self.bgView.frame.size.width / 4;
    
    [UIView animateWithDuration:0.8
                          delay:0
                        options: UIViewAnimationCurveEaseIn
                     animations:^{
                         [self.bgView setFrame:frame];
                     }
                     completion:^(BOOL finished){
                         [self.view setUserInteractionEnabled:YES];
                     }];
    
    _isEnd = YES;
}

-(void)swipeDown {
    CGRect frame = self.bgView.frame;
    frame.origin.y = 0;
    
    [UIView animateWithDuration:0.8
                          delay:0
                        options: UIViewAnimationCurveEaseIn
                     animations:^{
                         [self.bgView setFrame:frame];
                     }
                     completion:^(BOOL finished){
                         [self.view setUserInteractionEnabled:YES];
                     }];
    
    _isEnd = NO;
}

@end