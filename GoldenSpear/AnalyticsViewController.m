//
//  AnalyticsViewController.m
//  GoldenSpear
//
//  Created by Jose Antonio Sanchez Martinez on 24/11/15.
//  Copyright © 2015 GoldenSpear. All rights reserved.
//


#import "AnalyticsViewController.h"
#import "StackedPagesView.h"
#import "FollowersAnalyticsView.h"
#import "ViewsAnalyticsView.h"
#import "EstimatedSalesAnalyticsView.h"
#import "RankingAnalyticsView.h"


@interface AnalyticsViewController () <StackedPagesViewDelegate>

@property (nonatomic) IBOutlet StackedPagesView *stackedPagesView;
@property (nonatomic) NSMutableArray *views;

@end

@implementation AnalyticsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    self.stackedPagesView.delegate = self;
    
    self.stackedPagesView.pagesHaveShadows = YES;
    
    self.views = [[NSMutableArray alloc] init];
    
    // FOLLOWERS CARD:
    FollowersAnalyticsView *followersView = [[FollowersAnalyticsView alloc] initWithFrame:CGRectMake(0.f, 0.f, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame))];
    
    [self.views addObject:followersView];
    
    // VIEWS CARD:
    ViewsAnalyticsView *viewsView = [[ViewsAnalyticsView alloc] initWithFrame:CGRectMake(0.f, 0.f, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame))];
    
    [self.views addObject:viewsView];
    
    // ESTIMATED SALES CARD:
    EstimatedSalesAnalyticsView *estimatedSalesView = [[EstimatedSalesAnalyticsView alloc] initWithFrame:CGRectMake(0.f, 0.f, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame))];
    
    [self.views addObject:estimatedSalesView];
    
    // RANKING CARD:
    RankingAnalyticsView *rankingView = [[RankingAnalyticsView alloc] initWithFrame:CGRectMake(0.f, 0.f, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame))];
    
    [self.views addObject:rankingView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)viewDidLayoutSubviews
{
    if([self.stackedPagesView getSelectedPageIndex] == -1)
    {
        [self.stackedPagesView selectPageAtIndex:0];
    }
}

#pragma mark - StackedPagesView delegate methods


- (UIView *)stackView:(StackedPagesView *)stackView pageForIndex:(NSInteger)index
{
    UIView *thisView = [stackView dequeueReusablePage];
    
    if (!thisView)
    {
        thisView = [self.views objectAtIndex:index];
        thisView.backgroundColor = [UIColor whiteColor];
        thisView.layer.cornerRadius = 5;
        thisView.layer.masksToBounds = YES;
    }
    
    return thisView;
}

- (NSInteger)numberOfPagesForStackView:(StackedPagesView *)stackView
{
    return [self.views count];
}

- (void)stackView:(StackedPagesView *)stackView selectedPageAtIndex:(NSInteger) index
{
    NSLog(@"selected page: %i",(int)index);
}

@end
