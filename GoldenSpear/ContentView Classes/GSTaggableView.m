//
//  GSTaggableView.m
//  GoldenSpear
//
//  Created by Adria Vernetta Rubio on 20/4/16.
//  Copyright © 2016 GoldenSpear. All rights reserved.
//

#import "GSTaggableView.h"
#import "KeywordFashionistaContent+CoreDataProperties.h"
#import "CoreDataQuery.h"

#define kMaxTagSize 0.6
#define kTagFontName @"Avenir-light"
#define kTagFontSize 16

@implementation GSTaggableView

- (id)init{
    NSArray *arrayOfViews = [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class])
                                                          owner:nil
                                                        options:nil];
    int i = 0;
    while(i<[arrayOfViews count]){
        if([[arrayOfViews objectAtIndex:i] isKindOfClass:[self class]]){
            self = [arrayOfViews objectAtIndex:i];
            [self extraSetupView];
            return self;
        }
        i++;
    }
    return nil;
}

- (void)extraSetupView{
    self.translatesAutoresizingMaskIntoConstraints = NO;
    [self setupBackgroundView];
    [self setupTagListView];
}

// Setup and init the search terms list
-(void)setupTagListView
{
    tagList = [SlideButtonView new];
    
    [self.tagListContainer addSubview:tagList];
    self.tagListContainer.alpha = 0;
    self.tagListContainer.layer.cornerRadius = 5;
    
    [tagList setMinWidthButton:5];
    
    [tagList setSpaceBetweenButtons:0];
    [tagList setBShowShadowsSides:YES];
    [tagList setBShowPointRight:YES];
    [tagList setBButtonsCentered:NO];
    
    [tagList setSNameButtonImageHighlighted:@"termListButtonBackground.png"];
    
    // array of the string with the names of the buttons
    NSMutableArray * arButtons = [[NSMutableArray alloc] init];
    
    // add any option
    [tagList initSlideButtonWithButtons:arButtons andDelegate:self];
    
    [tagList setBackgroundColor:[UIColor clearColor]];
    [tagList setColorBackgroundButtons:[UIColor clearColor]];
}

- (id) awakeAfterUsingCoder:(NSCoder*)aDecoder {
    if ([[self subviews] count] == 0) {
        return [self init];
    }
    
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    tagList.frame = self.tagListContainer.bounds;
}

- (void)showTags:(BOOL)showOrNot{
    _tagContainer.hidden = !showOrNot;
}

- (IBAction)tagContainerTapped:(UITapGestureRecognizer *)sender {
    if (self.tagListContainer.alpha==1.0) {
        [self showTagList:NO];
    }else{
        [self showTags:(self.tagContainer.alpha==0.0)];
    }
}
- (IBAction)imagePinched:(UIPinchGestureRecognizer *)sender {
    NSLog(@"Image Pinched");
}

- (void)addTags:(NSArray*)keywords{
    for(UIView* v in _tagContainer.subviews){
        if(v!=self.tagListContainer){
            [v removeFromSuperview];
        }
    }
    [keywordsDictionary removeAllObjects];
    keywordsDictionary = [NSMutableDictionary new];
    [multiTagDictionary removeAllObjects];
    multiTagDictionary = [NSMutableDictionary new];
    [multiTagViewDictionary removeAllObjects];
    multiTagViewDictionary = [NSMutableDictionary new];
    [multiTagSearchDictionary removeAllObjects];
    multiTagSearchDictionary = [NSMutableDictionary new];
    
    CGFloat lastFloatingTagY = 0;
    for (KeywordFashionistaContent* kFC in keywords) {
        NSMutableArray* groupArray = [keywordsDictionary objectForKey:kFC.group];
        if(!groupArray){
            
            groupArray = [NSMutableArray new];
            [keywordsDictionary setObject:groupArray forKey:kFC.group];
            
            //Create tag
            UIButton* tag = [UIButton buttonWithType:UIButtonTypeCustom];
            UIButton *tagView = [UIButton buttonWithType:UIButtonTypeCustom];
            tagView.clipsToBounds = YES;
            tagView.layer.cornerRadius = 5;
            //tag.titleEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 10);
            tagView.titleEdgeInsets = UIEdgeInsetsMake(0, 5, 0, 5);
            
            NSString *title = [NSString stringWithFormat:@"%@\n%@", [kFC.keyword.name uppercaseString], @"XXXXX Matches"];
            NSMutableArray *stringTagSearch = [[NSMutableArray alloc] init];
            [stringTagSearch addObject:kFC.keyword.name];
            
            tag.accessibilityLabel = title;
            [tag addTarget:self action:@selector(tagPushed:) forControlEvents:UIControlEventTouchUpInside];
            tag.tag = [kFC.group integerValue];
            tag.titleLabel.font = [UIFont fontWithName:kTagFontName size:kTagFontSize];
            
            tagView.titleLabel.font = [UIFont fontWithName:kTagFontName size:kTagFontSize];
            [tagView setTitle:title forState:UIControlStateNormal];
            tagView.titleLabel.textColor = [UIColor whiteColor];
            tagView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.7];
            tagView.titleLabel.numberOfLines = 0;
            tagView.titleLabel.lineBreakMode = UILineBreakModeWordWrap;
            tagView.hidden = YES;
            
            if (kFC.keyword.userId&&![kFC.keyword.userId isEqualToString:@""]) {
                //User tag
                [tag setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                //[tag setBackgroundImage:[UIImage imageNamed:@"userTagBackground.png"] forState:UIControlStateNormal];
                [tag setImage:[UIImage imageNamed:@"tag-unselected.png"] forState:UIControlStateNormal];
                [tag setImage:[UIImage imageNamed:@"tag-selected.png"] forState:UIControlStateSelected];
                //tag.imageView.contentMode = UIViewContentModeScaleAspectFit;
            }else{
                [tag setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                [tag setImage:[UIImage imageNamed:@"tag-unselected.png"] forState:UIControlStateNormal];
                [tag setImage:[UIImage imageNamed:@"tag-selected.png"] forState:UIControlStateSelected];
                //tag.imageView.contentMode = UIViewContentModeScaleAspectFit;
            }
            [tag sizeToFit];
            [tagView sizeToFit];
            
            CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
            CGRect frame = tag.frame;
            frame.size.width = 25;
            frame.size.height = 25;
            CGFloat y = [kFC.yPos floatValue];
            CGFloat x = [kFC.xPos floatValue];
            if(y==-1&&x==-1){
                x = 0;
                y = lastFloatingTagY;
                lastFloatingTagY += frame.size.height+10;
            }else{
                x *= self.frame.size.width;
                y *= self.frame.size.height;
            }
            
            if(x+frame.size.width>screenWidth){
                x = screenWidth - frame.size.width;
            }
            frame.origin = CGPointMake(x,y);
            tag.frame = frame;
            
            CGRect viewFrame = tagView.frame;
            viewFrame.size.width += 10;
            viewFrame.origin.x = frame.origin.x;
            viewFrame.origin.y = frame.origin.y + frame.size.height - 2;
            CGFloat h = _tagListContainer.frame.origin.y;
            
            if (viewFrame.origin.x + viewFrame.size.width > screenWidth) {
                viewFrame.origin.x = frame.origin.x + frame.size.width - viewFrame.size.width;
            }
            if (viewFrame.origin.y + viewFrame.size.height > h) {
                viewFrame.origin.y = frame.origin.y - viewFrame.size.height + 7;
            }
            
            tagView.frame = viewFrame;
            
            [_tagContainer addSubview:tag];
            [_tagContainer addSubview:tagView];
            
            [multiTagDictionary setObject:tag forKey:kFC.group];
            [multiTagViewDictionary setObject:tagView forKey:kFC.group];
            [multiTagSearchDictionary setObject:stringTagSearch forKey:kFC.group];
        }else{
            
            UIButton* tag = [multiTagDictionary objectForKey:kFC.group];
            UIButton *tagView = [multiTagViewDictionary objectForKey:kFC.group];
            NSMutableArray* stringTagSearch = [multiTagSearchDictionary objectForKey:kFC.group];
            
            if(kFC.keyword.productCategoryId&&![kFC.keyword.productCategoryId isEqualToString:@""]){
                NSString *title = [NSString stringWithFormat:@"%@ %@", [kFC.keyword.name uppercaseString], tag.accessibilityLabel];
                tag.accessibilityLabel = title;
                [tagView setTitle:title forState:UIControlStateNormal];
            }
            
            [stringTagSearch insertObject:kFC.keyword.name atIndex:0];
            
            [tag setImage:[UIImage imageNamed:@"tag-unselected.png"] forState:UIControlStateNormal];
            [tag setImage:[UIImage imageNamed:@"tag-selected.png"] forState:UIControlStateSelected];
            //tag.imageView.contentMode = UIViewContentModeScaleAspectFit;
            
            [tag sizeToFit];
            [tagView sizeToFit];
            CGRect frame = tag.frame;
            frame.size.width = 25;
            frame.size.height = 25;
            CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
            if(frame.origin.x+frame.size.width>screenWidth){
                frame.origin.x = screenWidth - frame.size.width;
            }
            tag.frame = frame;
            
            CGRect viewFrame = tagView.frame;
            viewFrame.size.width += 20;
            if (viewFrame.origin.x + viewFrame.size.width > screenWidth) {
                viewFrame.origin.x = frame.origin.x + frame.size.width - viewFrame.size.width;
            }
            
            tagView.frame = viewFrame;
            
        }
        
        if(kFC.keyword.productCategoryId&&![kFC.keyword.productCategoryId isEqualToString:@""]){
            [groupArray insertObject:kFC atIndex:0];
            CoreDataQuery * objCoreDataQuery = [CoreDataQuery sharedCoreDataQuery];
            ProductGroup *group = [objCoreDataQuery getProductGroupFromId:kFC.keyword.productCategoryId];
            NSLog(@"Product Gategory : %@  @@@@  %@", group.name, kFC.keyword.name);
        }else{
            [groupArray addObject:kFC];
        }
        
    }
    [self layoutSubviews];
    [self showTags:NO];
    [self getNumbersofMatches];
}

- (void)setNumOfMatches:(NSMutableDictionary*)numsOfMatchs {
    NSArray *keys = [multiTagViewDictionary allKeys];
    for (NSNumber *key in keys) {
        UIButton *button = (UIButton*)[multiTagViewDictionary objectForKey:key];
        NSString *title = button.currentTitle;
        NSString *nums;
        if ([numsOfMatchs objectForKey:key]) {
            if (((NSNumber*)[numsOfMatchs objectForKey:key]).intValue > 1000) {
                nums = @"+1000";
            }
            else {
                nums = [NSString stringWithFormat:@"%i", ((NSNumber*)[numsOfMatchs objectForKey:key]).intValue];
            }
        }
        else {
            nums = @"0";
        }
        NSLog(@"Num : %@", nums);
        NSString *subString = [title stringByReplacingOccurrencesOfString:@"XXXXX" withString:nums];
        
        [button setTitle:subString forState:UIControlStateNormal];
    }
}

-(void)getNumbersofMatches {
    [self.viewDelegate taggableView:self keyWords:multiTagSearchDictionary];
}

- (void)tagPushed:(UIButton*)tag{
    NSArray *tags = [multiTagDictionary allValues];
    for (UIButton *button in tags) {
        if ([button isKindOfClass:[UIButton class]]) {
            button.selected = NO;
        }
    }
    
    NSArray *tagViews = [multiTagViewDictionary allValues];
    for (UIButton *label in tagViews) {
        if ([label isKindOfClass:[UIButton class]]) {
            label.hidden = YES;
        }
    }
    
    UIButton *tagView = (UIButton*)[multiTagViewDictionary objectForKey:[NSNumber numberWithInteger:tag.tag]];
    tagView.hidden = NO;
    tag.selected = YES;
    NSMutableArray* groupArray = [keywordsDictionary objectForKey:[NSNumber numberWithInteger:tag.tag]];
    if ([groupArray count]==1) {
        KeywordFashionistaContent* kFC = [groupArray firstObject];
        if (kFC.keyword.userId&&![kFC.keyword.userId isEqualToString:@""]) {
            //Do action directly
            [self commitKeywordAction:[(KeywordFashionistaContent*)[groupArray firstObject] keyword]];
            return;
        }
    }
    
    //Show Label scroller
    [tagList removeAllButtons];
    for (KeywordFashionistaContent* kFC in groupArray) {
        [tagList addButtonWithObject:kFC.keyword];
    }
    
    [self showTagList:YES];
    tagList.frame = self.tagListContainer.bounds;
}

- (void)showTagList:(BOOL)showOrNot{
    if (showOrNot) {
        [self.tagListContainer.superview bringSubviewToFront:self.tagListContainer];
    }
    [UIView animateWithDuration:0.5
                     animations:^{
                         self.tagListContainer.alpha = (showOrNot ? 1.0 : 0.0);
                     } completion:^(BOOL finished) {
                         if(!showOrNot){
                             [self.tagListContainer.superview sendSubviewToBack:self.tagListContainer];
                         }
                     }];
}

- (void)commitKeywordAction:(Keyword*)keyword{
    if (keyword.userId&&![keyword.userId isEqualToString:@""]) {
        [self.viewDelegate taggableView:self didSelectFashionista:keyword.userId];
    }else{
        if (keyword.productCategoryId != nil && ![keyword.productCategoryId isEqualToString:@""]) {
            [self.viewDelegate taggableView:self didSelectKeywords:@[[keyword toStringButtonSlideView]] categoryTerms:[[NSMutableArray alloc] initWithObjects:keyword.name, nil]];
        }
        [self.viewDelegate taggableView:self didSelectKeywords:@[[keyword toStringButtonSlideView]] categoryTerms:nil];
    }
}

#pragma mark - Protected for subclassing

- (void)setupBackgroundView{
    
}

#pragma mark - SliderButton Delegate
- (void)slideButtonView:(SlideButtonView *)slideButtonView btnClick:(int)buttonEntry
{
    NSMutableArray *categoryTerms = [NSMutableArray new];
    if(!(slideButtonView.arrayButtons == nil))
    {
        if([slideButtonView.arrayButtons count] > 0)
        {
            NSMutableArray * searchTerms = [[NSMutableArray alloc] init];
            
            for (NSObject * keyword in slideButtonView.arrayButtons)
            {
                if ([keyword isKindOfClass:[Keyword class]]) {
//                    CoreDataQuery * objCoreDataQuery = [CoreDataQuery sharedCoreDataQuery];
//                    ProductGroup *group = [objCoreDataQuery getProductGroupFromId:((Keyword*)keyword).productCategoryId];
                    if (((Keyword*)keyword).productCategoryId != nil && ![((Keyword*)keyword).productCategoryId isEqualToString:@""]) {
                        CoreDataQuery * objCoreDataQuery = [CoreDataQuery sharedCoreDataQuery];
                        ProductGroup *group = [objCoreDataQuery getProductGroupFromId:((Keyword*)keyword).productCategoryId];
                        [categoryTerms addObject:group.idProductGroup];
                    }
                }
                if(!(keyword == nil))
                {
                    if([keyword isKindOfClass:[NSObject class]])
                    {
                        [searchTerms addObject:[keyword toStringButtonSlideView]];
                        
                    }
                }
            }
            [self.viewDelegate taggableView:self didSelectKeywords:searchTerms categoryTerms:categoryTerms];
        }
    }
    
}

@end
