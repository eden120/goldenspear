//
//  StackedPagesView.m
//  GoldenSpear
//
//  Created by Jose Antonio Sanchez Martinez on 24/11/15.
//  Copyright © 2015 GoldenSpear. All rights reserved.
//
//  Based on: https://github.com/PlenipotentSS/SSStackedPageView
//

#import "StackedPagesView.h"


#define OFFSET_TOP 5.0f
#define COLLAPSED_OFFSET_TOP 5.0f
#define PAGE_PEAK 50.0f
#define COLLAPSED_PAGE_PEAK 50.0f
#define BOTTOM_OFFSET_HIDE 200.0f

#define MINIMUM_ALPHA 0.5f
#define MINIMUM_SCALE 0.98f
#define SHADOW_VECTOR CGSizeMake(0.0f,-0.5f)
#define SHADOW_ALPHA 0.3f


@interface StackedPagesView()

// ScrollView attached to this view
@property (nonatomic) UIScrollView *scrollView;

// Array containing reusable pages
@property (nonatomic) NSMutableArray *reusablePages;

// Index of the current page selected
@property (nonatomic) NSInteger selectedPageIndex;

// Tracked translation for the current view being dragged
@property (nonatomic) CGFloat trackedTranslation;

// Count of the total number of pages
@property (nonatomic) NSInteger pageCount;

// Array of the posts contained
@property (nonatomic) NSMutableArray *pages;

// Current posts visible
@property (nonatomic) NSRange visiblePages;

@end


@implementation StackedPagesView


#pragma mark - setup methods


- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [self setup];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self)
    {
        [self setup];
    }
    
    return self;
}

- (void)setup
{
    self.pageCount = 0;
    self.selectedPageIndex = -1;
    
    self.pages = [[NSMutableArray alloc] init];
    self.reusablePages = [[NSMutableArray alloc] init];
    self.visiblePages = NSMakeRange(0, 0);
    
    self.scrollView= [[UIScrollView alloc] initWithFrame:self.bounds];
    self.scrollView.delegate = self;
    self.scrollView.backgroundColor = [UIColor clearColor];
    self.scrollView.showsVerticalScrollIndicator = NO;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (self.delegate)
    {
        self.pageCount = [self.delegate numberOfPagesForStackView:self];
    }
    
    [self.reusablePages removeAllObjects];
    
    self.visiblePages = NSMakeRange(0, 0);
    
    for (NSInteger i=0; i < [self.pages count]; i++)
    {
        [self removePageAtIndex:i];
    }
    
    [self.pages  removeAllObjects];
    
    for (NSInteger i=0; i<self.pageCount; i++)
    {
        [self.pages addObject:[NSNull null]];
    }
    
    self.scrollView.frame = CGRectMake(0.f, 0.f, CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds));
    
    self.scrollView.contentSize = CGSizeMake(CGRectGetWidth(self.bounds), MAX(CGRectGetHeight(self.bounds), OFFSET_TOP + (self.pageCount * PAGE_PEAK)));
    
    [self addSubview:self.scrollView];
    
    [self setPageAtOffset:self.scrollView.contentOffset];
    
    [self reloadVisiblePages];
}


#pragma mark - Page Selection

// Method to get the curently visible page
- (NSInteger) getSelectedPageIndex
{
    return self.selectedPageIndex;
}

// Method to set a specific page visible
- (void)selectPageAtIndex:(NSInteger)index
{
    if (index != self.selectedPageIndex)
    {
        if(index < [self.pages count])
        {
            self.selectedPageIndex = index;
            
            NSInteger visibleEnd = self.visiblePages.location + self.visiblePages.length;
            
            [self hidePagesBehind:NSMakeRange(self.visiblePages.location, index-self.visiblePages.location)];
            
            if (index+1 < visibleEnd)
            {
                NSInteger start = index+1;
                NSInteger stop = visibleEnd-start;
                [self hidePagesInFront:NSMakeRange(start,stop)];
            }
            
            self.scrollView.scrollEnabled = NO;
        }
    }
//    else
//    {
//        self.selectedPageIndex = -1;
//        
//        [self resetPages];
//    }
}

- (void)resetPages
{
    NSInteger start = self.visiblePages.location;
    
    NSInteger stop = self.visiblePages.location + self.visiblePages.length;
    
    [UIView beginAnimations:@"stackReset" context:nil];
    
    [UIView setAnimationDuration:.4f];
    
    for (NSInteger i=start;i < stop;i++)
    {
        UIView *page = [self.pages objectAtIndex:i];
        
        page.layer.transform = CATransform3DMakeScale(MINIMUM_SCALE, MINIMUM_SCALE, 1.f);
        
        CGRect thisFrame = page.frame;
        
        thisFrame.origin.y = OFFSET_TOP + i * PAGE_PEAK;
        
        page.frame = thisFrame;
    }
    
    [UIView commitAnimations];
    
    self.scrollView.scrollEnabled = YES;
}

- (void)hidePagesBehind:(NSRange)backPages
{
    NSInteger start = backPages.location;
    
    NSInteger stop = backPages.location + backPages.length;
    
    [UIView beginAnimations:@"stackHideBack" context:nil];
    
    [UIView setAnimationDuration:.4f];
    
    for (NSInteger i=start;i <= stop;i++)
    {
        UIView *page = (UIView*)[self.pages objectAtIndex:i];
        
        CGRect thisFrame = page.frame;
        
        NSInteger visibleIndex = i-self.visiblePages.location;
        
        thisFrame.origin.y = self.scrollView.contentOffset.y+COLLAPSED_OFFSET_TOP + visibleIndex * COLLAPSED_PAGE_PEAK;
        
        page.frame = thisFrame;
    }
    
    [UIView commitAnimations];
}

- (void)hidePagesInFront:(NSRange)frontPages
{
    NSInteger start = frontPages.location;
    
    NSInteger stop = frontPages.location + frontPages.length;
    
    [UIView beginAnimations:@"stackHideFront" context:nil];
    
    [UIView setAnimationDuration:.4f];
    
    for (NSInteger i=start;i < stop;i++)
    {
        UIView *page = (UIView*)[self.pages objectAtIndex:i];
        
        CGRect thisFrame = page.frame;

        thisFrame.origin.y = self.scrollView.contentOffset.y+CGRectGetHeight(self.frame)-BOTTOM_OFFSET_HIDE + i * COLLAPSED_PAGE_PEAK;
        
        page.frame = thisFrame;
    }
    
    [UIView commitAnimations];
}


#pragma mark - displaying pages

- (void)reloadVisiblePages
{
    NSInteger start = self.visiblePages.location;
    
    NSInteger stop = self.visiblePages.location + self.visiblePages.length;
    
    for (NSInteger i = start; i < stop; i++)
    {
        UIView *page = [self.pages objectAtIndex:i];
        
        if (i == 0 || [self.pages objectAtIndex:i-1] == [NSNull null])
        {
            page.layer.transform = CATransform3DMakeScale(MINIMUM_SCALE, MINIMUM_SCALE, 1.f);
        }
        else
        {
            [UIView beginAnimations:@"stackScrolling" context:nil];
            
            [UIView setAnimationDuration:.4f];
            
            page.layer.transform = CATransform3DMakeScale(MINIMUM_SCALE, MINIMUM_SCALE, 1.f);
            
            [UIView commitAnimations];
        }
    }
}

- (void)setPageAtOffset:(CGPoint)offset
{
    if ([self.pages count] > 0 )
    {
        CGPoint start = CGPointMake(offset.x - CGRectGetMinX(self.scrollView.frame), offset.y -(CGRectGetMinY(self.scrollView.frame)));
        
        CGPoint end = CGPointMake(MAX(0, start.x) + CGRectGetWidth(self.bounds), MAX(OFFSET_TOP, start.y) + CGRectGetHeight(self.bounds));
        
        NSInteger startIndex = 0;
        
        for (NSInteger i=0; i < [self.pages count]; i++)
        {
            if (PAGE_PEAK * (i+1) > start.y)
            {
                startIndex = i;
                break;
            }
        }
        
        NSInteger endIndex = 0;
        
        for (NSInteger i=0; i < [self.pages count]; i++)
        {
            if ((PAGE_PEAK * i < end.y && PAGE_PEAK * (i + 1) >= end.y ) || i == [self.pages count]-1)
            {
                endIndex = i + 1;
                break;
            }
        }
        
        startIndex = MAX(startIndex - 1, 0);
        
        endIndex = MIN(endIndex, [self.pages count] - 1);
        
        CGFloat pagedLength = endIndex - startIndex + 1;
        
        if (self.visiblePages.location != startIndex || self.visiblePages.length != pagedLength)
        {
            _visiblePages.location = startIndex;
            
            _visiblePages.length = pagedLength;
            
            for (NSInteger i = startIndex; i <= endIndex; i++)
            {
                [self setPageAtIndex:i];
            }
            
            for (NSInteger i = 0; i < startIndex; i ++)
            {
                [self removePageAtIndex:i];
            }
            
            for (NSInteger i = endIndex + 1; i < [self.pages count]; i ++)
            {
                [self removePageAtIndex:i];
            }
        }
    }
}

- (void)setPageAtIndex:(NSInteger)index
{
    if (index >= 0 && index < [self.pages count])
    {
        UIView *page = [self.pages objectAtIndex:index];
        
        if ((!page || (NSObject*)page == [NSNull null]) && self.delegate)
        {
            page = [self.delegate stackView:self pageForIndex:index];
            
            [self.pages replaceObjectAtIndex:index withObject:page];
            
            page.frame = CGRectMake(0.f, index * PAGE_PEAK, CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds));
            
            if (self.pagesHaveShadows)
            {
                [page.layer setShadowOpacity:SHADOW_ALPHA];
            
                [page.layer setShadowOffset:SHADOW_VECTOR];
                
                page.layer.shadowPath = [UIBezierPath bezierPathWithRect:page.bounds].CGPath;
                
                page.clipsToBounds = NO;
            }
            
            page.layer.zPosition = index;
        }
        
        if (![page superview])
        {
            if ((index == 0 || [self.pages objectAtIndex:index-1] == [NSNull null]) && index+1 < [self.pages count])
            {
                UIView *topPage = [self.pages objectAtIndex:index+1];
            
                [self.scrollView insertSubview:page belowSubview:topPage];
            }
            else
            {
                [self.scrollView addSubview:page];
            }
            
            page.tag = index;
        }
        
        if ([page.gestureRecognizers count] < 2)
        {
//            We don't want to drag and reorganize views in this implementation
//
//            UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panned:)];
//         
//            [page addGestureRecognizer:pan];
            
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)];
            
            [page addGestureRecognizer:tap];
        }
    }
}


#pragma mark - reuse methods

- (void)enqueueReusablePage:(UIView*)page
{
    [self.reusablePages addObject:page];
}

- (UIView*)dequeueReusablePage
{
    UIView *page = [self.reusablePages lastObject];
    
    if (page && (NSObject*)page != [NSNull null])
    {
        [self.reusablePages removeLastObject];
    
        return page;
    }
    
    return nil;
}

- (void)removePageAtIndex:(NSInteger)index
{
    UIView *page = [self.pages objectAtIndex:index];
    
    if (page && (NSObject*)page != [NSNull null])
    {
        page.layer.transform = CATransform3DIdentity;
    
        [page removeFromSuperview];
        
        [self enqueueReusablePage:page];
        
        [self.pages replaceObjectAtIndex:index withObject:[NSNull null]];
    }
}


#pragma mark - gesture recognizer

- (void)tapped:(UIGestureRecognizer*)sender
{
    UIView *page = [sender view];
 
    NSInteger index = [self.pages indexOfObject:page];
    
    CGRect pageTouchFrame = page.frame;
    
    if (self.selectedPageIndex == index)
    {
        pageTouchFrame.size.height = CGRectGetHeight(pageTouchFrame)-COLLAPSED_PAGE_PEAK;
    }
    else if (self.selectedPageIndex != -1)
    {
        pageTouchFrame.size.height = COLLAPSED_PAGE_PEAK;
    }
    else if ( index+1 < [self.pages count] )
    {
        pageTouchFrame.size.height = PAGE_PEAK;
    }

    [self selectPageAtIndex:index];
    
    [self.delegate stackView:self selectedPageAtIndex:index];
}

- (void)panned:(UIPanGestureRecognizer*)recognizer
{
    UIView *page = [recognizer view];
    
    CGPoint translation = [recognizer translationInView:page];
    
    if (recognizer.state == UIGestureRecognizerStateBegan)
    {
        self.trackedTranslation = 0;
    }
    else if (recognizer.state ==UIGestureRecognizerStateChanged)
    {
        CGRect pageFrame = page.frame;

        pageFrame.origin.y += translation.y;
        
        page.frame = pageFrame;
        
        self.trackedTranslation += translation.y;
        
        [recognizer setTranslation:CGPointMake(0, 0) inView:page];
    }
    else if (recognizer.state == UIGestureRecognizerStateEnded)
    {
        if (self.trackedTranslation < -PAGE_PEAK)
        {
            NSInteger pageIndex = [self.pages indexOfObject:page];
        
            [self selectPageAtIndex:pageIndex];
            
            [self.delegate stackView:self selectedPageAtIndex:pageIndex];
        }
        else
        {
            self.selectedPageIndex = -1;
            
            [self resetPages];
        }
    }
}


#pragma mark - ScrollView Delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self setPageAtOffset:scrollView.contentOffset];
    
    [self reloadVisiblePages];
}

@end
