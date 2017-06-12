//
//  GSTaggableView.h
//  GoldenSpear
//
//  Created by Adria Vernetta Rubio on 20/4/16.
//  Copyright © 2016 GoldenSpear. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SlideButtonView.h"
#import "Keyword+CoreDataProperties.h"

@class GSTaggableView;

@protocol GSTaggableViewDelegate <NSObject>

-(void)taggableView:(GSTaggableView*)taggableView heightChanged:(CGFloat)newHeight;
-(void)taggableView:(GSTaggableView*)taggableView didSelectFashionista:(NSString*)fashionistaId;
-(void)taggableView:(GSTaggableView*)taggableView didSelectKeywords:(NSArray*)keywordArray categoryTerms:(NSMutableArray*)categoryTerms;
-(void)taggableView:(GSTaggableView*)taggableView keyWords:(NSMutableDictionary*)searchStringDictionary;
-(void)pinchImage:(UIImage*)image;
@end

@interface GSTaggableView : UIView<SlideButtonViewDelegate,UIGestureRecognizerDelegate>{
    NSMutableDictionary* keywordsDictionary;
    NSMutableDictionary* multiTagDictionary;
    NSMutableDictionary* multiTagViewDictionary;
    NSMutableDictionary* multiTagSearchDictionary;
    SlideButtonView* tagList;
}

@property (weak, nonatomic) IBOutlet UIView *backgroundContainer;
@property (weak, nonatomic) IBOutlet UIView *tagContainer;
@property (weak, nonatomic) IBOutlet UIView *tagListContainer;
@property (nonatomic) BOOL tapAbleView;

@property (weak, nonatomic) IBOutlet id<GSTaggableViewDelegate> viewDelegate;

- (IBAction)tagContainerTapped:(UITapGestureRecognizer *)sender;
- (void)addTags:(NSArray*)keywords;
- (void)setNumOfMatches:(NSMutableDictionary*)numsOfMatchs;

- (void)setupBackgroundView;
- (void)extraSetupView;

@end
