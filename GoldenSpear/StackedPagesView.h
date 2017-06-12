//
//  StackedPagesView.h
//  GoldenSpear
//
//  Created by Jose Antonio Sanchez Martinez on 24/11/15.
//  Copyright © 2015 GoldenSpear. All rights reserved.
//
//  Based on: https://github.com/PlenipotentSS/SSStackedPageView
//

#import <UIKit/UIKit.h>

@protocol StackedPagesViewDelegate;

@interface StackedPagesView : UIView <UIScrollViewDelegate>

// Delegate
@property (nonatomic) id<StackedPagesViewDelegate> delegate;

// User settings for pages to have shadows
@property (nonatomic) BOOL pagesHaveShadows;

// Dequeue the last page in the reusable queue
- (UIView*)dequeueReusablePage;

// Method to get the curently visible page
- (NSInteger) getSelectedPageIndex;

// Method to set a specific page visible
- (void)selectPageAtIndex:(NSInteger)index;

@end


@protocol StackedPagesViewDelegate

// Method for setting the current page at the index
- (UIView*)stackView:(StackedPagesView *)stackView pageForIndex:(NSInteger)index;

// Total number of pages to present in the stack
- (NSInteger)numberOfPagesForStackView:(StackedPagesView *)stackView;

// Handler for when a page is selected
- (void)stackView:(StackedPagesView *)stackView selectedPageAtIndex:(NSInteger) index;

@end
