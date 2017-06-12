//
//  LiveFilterViewController.h
//  GoldenSpear
//
//  Created by Crane on 9/19/16.
//  Copyright © 2016 GoldenSpear. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "FilterLocationViewController.h"
#import "FilterAgeRangeViewController.h"
#import "FilterEthnicityViewController.h"
@protocol FilterSearchtDelegate;

@interface LiveFilterViewController : BaseViewController <FilterLocationSearchtDelegate, FilterAgeRangeDelegate, FilterEthnicityDelegate, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>

- (IBAction)saveAction:(id)sender;
- (IBAction)backAction:(id)sender;
-(void) hideFilterSearch;
@property (weak, nonatomic) IBOutlet UIScrollView *bodyScrollView;
@property (weak, nonatomic) IBOutlet UIScrollView *toolScrollView;
@property NSMutableArray * keywordsSelected;
@property LiveStreaming *liveStringObject;
@property NSMutableArray *selCatArry;
@property NSMutableArray *filterCatArry;
@property (nonatomic, assign) id <FilterSearchtDelegate> filterDelegate;
@property NSMutableArray *filtercountries;
@property NSMutableArray *filterstates;
@property NSMutableArray *filtercities;
@property BOOL isSelectedMale;
@property BOOL isSelectedFemale;
@property BOOL setSelectedMale;
@property BOOL setSelectedFemale;
@property NSMutableArray *filterageArray;
@property NSMutableArray *filterselectedEthnicities;
@property NSMutableArray *filterselectedLooks;
@property NSMutableArray *filterselectedTags;
@property NSMutableArray *filterproducts;
@property NSMutableArray *filterbrands;

@end
@protocol FilterSearchtDelegate <NSObject>
@optional
- (void)setCategories:(LiveFilterViewController*)vc Arry: (NSMutableArray *)aryy;
- (void)setGender:(LiveFilterViewController*)vc  Male:(BOOL)isMale Female:(BOOL)isFemale;
- (void)setProducts:(LiveFilterViewController*)vc Arry:(NSMutableArray*)products;
- (void)setBrands:(LiveFilterViewController*)vc Arry:(NSMutableArray*)brands;
@end