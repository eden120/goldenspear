//
//  GSTaggingProductSearchViewController.m
//  GoldenSpear
//
//  Created by Crane on 8/4/16.
//  Copyright © 2016 GoldenSpear. All rights reserved.
//

#import "GSTaggingProductSearchViewController.h"
#import "ProductSearchBottomView.h"
@interface GSTaggingProductSearchViewController ()

@end

@implementation GSTaggingProductSearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    ProductSearchBottomView *btnView =
    [[[NSBundle mainBundle] loadNibNamed:@"ProductSearchBottomView" owner:self options:nil] objectAtIndex:0];
    
    btnView.searchBtn.layer.borderColor = [UIColor blackColor].CGColor;
    btnView.searchBtn.layer.borderWidth = 1.0f;
    btnView.addNewBtn.layer.borderColor = [UIColor blackColor].CGColor;
    btnView.addNewBtn.layer.borderWidth = 1.0f;
    
    btnView.tagBtn.enabled = NO;
    [btnView.searchBtn addTarget:self action:@selector(searchAction:) forControlEvents:UIControlEventTouchUpInside];
    [btnView.addNewBtn addTarget:self action:@selector(addNewAction:) forControlEvents:UIControlEventTouchUpInside];
    [btnView.tagBtn addTarget:self action:@selector(tagAction:) forControlEvents:UIControlEventTouchUpInside];

    
     btnView.frame = CGRectMake(0, self.view.bounds.size.height - 60, self.view.bounds.size.width, 60);
    [self.view addSubview:btnView];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)searchAction:(UIButton*)sender
{
    NSLog(@"search Action Clicked");
}

- (void)addNewAction:(UIButton*)sender
{
    NSLog(@"addNew Action Clicked");

}

- (void)tagAction:(UIButton*)sender
{
    NSLog(@"tag Action Clicked");

}

- (BOOL)shouldCreateBottomButtons
{
    return NO;
}

@end
