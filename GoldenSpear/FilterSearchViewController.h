//
//  FilterSearchViewController.h
//  GoldenSpear
//
//  Created by Alberto Seco on 9/6/15.
//  Copyright (c) 2015 GoldenSpear. All rights reserved.
//

#import "BaseViewController.h"
#import "SlideButtonView.h"

@interface FilterSearchViewController : BaseViewController<SlideButtonViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *lblNoFilters;
@property (nonatomic) NSMutableArray * searchTerms;
@property (weak, nonatomic) IBOutlet UIView *viewSubProductAndFeatures;
@property (weak, nonatomic) IBOutlet UIView *viewGenderAndProductCategory;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topConstraintCollectionView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *kBottomSubProductFeaturesCollectionView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *kLeftSubProductFeaturesCollectionView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *kTopSubProductFeaturesCollectionView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *kRightSubProductFeaturesCollectionView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *kBottomGenderProductCollectionView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *kLeftGenderProductCollectionView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *kRightGenderProductCollectionView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *kTopGenderProductCollectionView;

@property UIImageView * zoomView;
@property UIView * zoomBackgroundView;
@property UILabel * zoomLabel;
@property UIButton * btnZoomView;
@property int type;
@property BOOL bAutoSwap;
@property NSMutableArray *selectedProducts;

-(void) hideZoomView;
-(BOOL) zoomViewVisible;
-(NSMutableArray*)getSelectedProductGroup;
-(void) addSearchTerm: (NSString * ) sNewTerm;
-(void) addSearchTermObject: (NSObject * ) sNewTerm;

-(void) removeSearchTerm:(NSString *) sTermToRemove;
-(void) removeSearchTermObject:(NSObject *) objTermToRemove;

@end
