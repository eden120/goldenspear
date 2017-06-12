//
//  GetTheLookView.m
//  GoldenSpear
//
//  Created by jcb on 7/28/16.
//  Copyright © 2016 GoldenSpear. All rights reserved.
//

#import "GetTheLookView.h"
#import "GSBaseElement.h"
#import <AFNetworking.h>
#import <RestKit/Network.h>
#import <CoreData.h>

@interface GetTheLookView()

@property (weak, nonatomic) IBOutlet UIView *bgView;
@property (weak, nonatomic) IBOutlet UIView *firstProductView;
@property (weak, nonatomic) IBOutlet UIImageView *firstProductImage;
@property (weak, nonatomic) IBOutlet UILabel *firstProductFeatureTitle;
@property (weak, nonatomic) IBOutlet UILabel *firstProductFeatureLabel;
@property (weak, nonatomic) IBOutlet UIButton *firstHangerButton;
@property (weak, nonatomic) IBOutlet UIView *secondProductView;
@property (weak, nonatomic) IBOutlet UIImageView *secondProductImage;
@property (weak, nonatomic) IBOutlet UILabel *secondProductTitle;
@property (weak, nonatomic) IBOutlet UILabel *secondProductFeatureLabel;
@property (weak, nonatomic) IBOutlet UIButton *secondHangerButton;
@property (weak, nonatomic) IBOutlet UIView *thirdProductView;
@property (weak, nonatomic) IBOutlet UIImageView *thirdProductImage;
@property (weak, nonatomic) IBOutlet UILabel *thirdProductTitile;
@property (weak, nonatomic) IBOutlet UILabel *thirdProductLabel;
@property (weak, nonatomic) IBOutlet UIButton *thirdHangerButton;

@property NSFetchedResultsController * wardrobesFetchedResultsController;
@property NSFetchRequest * wardrobesFetchRequest;

@end

@implementation GetTheLookView {
    BOOL firstSelected;
    BOOL secondSelected;
    BOOL thirdSelected;
}

-(void)viewDidLoad {
	[super viewDidLoad];
    firstSelected = NO;
    secondSelected = NO;
    thirdSelected = NO;
}

-(void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
}

-(void)initView {
    
	GSBaseElement *first_product = (GSBaseElement*)[_products objectAtIndex:0];
	
	if (first_product != nil) {
		
		[_firstProductImage setImageWithURL:[NSURL URLWithString:first_product.preview_image]];
        _firstProductFeatureTitle.text = [first_product.additionalInformation uppercaseString];
        _firstProductFeatureLabel.text = first_product.mainInformation;
        firstSelected = [self doesCurrentUserWardrobesContainItemWithId:first_product];
        UIImage * buttonImage = [UIImage imageNamed:(firstSelected ? (@"hanger_checked.png") : (@"hanger_unchecked.png"))];
        
        [_firstHangerButton setBackgroundImage:buttonImage forState:UIControlStateNormal];
	}
    
    GSBaseElement *second_product = (GSBaseElement*)[_products objectAtIndex:1];
    
    if (second_product != nil) {
        
        [_secondProductImage setImageWithURL:[NSURL URLWithString:second_product.preview_image]];
        _secondProductTitle.text = [second_product.additionalInformation uppercaseString];
        _secondProductFeatureLabel.text = second_product.mainInformation;
        
        secondSelected = [self doesCurrentUserWardrobesContainItemWithId:second_product];
        UIImage * buttonImage = [UIImage imageNamed:(secondSelected ? (@"hanger_checked.png") : (@"hanger_unchecked.png"))];
        
        [_secondHangerButton setBackgroundImage:buttonImage forState:UIControlStateNormal];
    }
    
    GSBaseElement *third_product = (GSBaseElement*)[_products objectAtIndex:2];
    
    if (first_product != nil) {
        
        [_thirdProductImage setImageWithURL:[NSURL URLWithString:third_product.preview_image]];
        _thirdProductTitile.text = [third_product.additionalInformation uppercaseString];
        _thirdProductLabel.text = third_product.mainInformation;
        
        thirdSelected = [self doesCurrentUserWardrobesContainItemWithId:third_product];
        UIImage * buttonImage = [UIImage imageNamed:(thirdSelected ? (@"hanger_checked.png") : (@"hanger_unchecked.png"))];
        
        [_thirdHangerButton setBackgroundImage:buttonImage forState:UIControlStateNormal];
    }
}

-(void)animationAppear {
    CGRect firstFrame = self.firstProductView.frame;
    CGRect secondFrame = self.secondProductView.frame;
    CGRect thirdFrame = self.thirdProductView.frame;
    
    firstFrame.origin.x = -self.firstProductView.frame.size.width - 10;
    thirdFrame.origin.x = -self.thirdProductView.frame.size.width - 10;
    secondFrame.origin.x = self.view.frame.size.width;
    
    self.firstProductView.frame = firstFrame;
    self.secondProductView.frame = secondFrame;
    self.thirdProductView.frame = thirdFrame;
    
    firstFrame.origin.x = 8;
    secondFrame.origin.x = self.bgView.frame.size.width - self.secondProductView.frame.size.width - 8;
    thirdFrame.origin.x= 8;
    
    [UIView animateWithDuration:0.8
                          delay:0.8
                        options: UIViewAnimationCurveEaseIn
                     animations:^{
                         [self.firstProductView setFrame:firstFrame];
                     }
                     completion:^(BOOL finished){
                         [self.view setUserInteractionEnabled:YES];
                     }];
    
    [UIView animateWithDuration:0.8
                          delay:1
                        options: UIViewAnimationCurveEaseIn
                     animations:^{

                         [self.secondProductView setFrame:secondFrame];
                     }
                     completion:^(BOOL finished){
                         [self.view setUserInteractionEnabled:YES];
                     }];
    [UIView animateWithDuration:0.8
                          delay:1.2
                        options: UIViewAnimationCurveEaseIn
                     animations:^{
                         [self.thirdProductView setFrame:thirdFrame];
                     }
                     completion:^(BOOL finished){
                         [self.view setUserInteractionEnabled:YES];
                     }];
}

- (BOOL) doesCurrentUserWardrobesContainItemWithId:(GSBaseElement *)item
{
    NSString * itemId = @"";
    
    _wardrobesFetchedResultsController = nil;
    _wardrobesFetchRequest = nil;
    
    [self initFetchedResultsControllerWithEntity:@"GSBaseElement" andPredicate:@"idGSBaseElement IN %@" inArray:_userWardrobesElements sortingWithKey:@"idGSBaseElement" ascending:YES];
    
    if (!(item == nil))
    {
        if(!(item.productId == nil))
        {
            if(!([item.productId isEqualToString:@""]))
            {
                itemId = item.productId;
            }
        }
        else if(!(item.fashionistaPostId == nil))
        {
            if(!([item.fashionistaPostId isEqualToString:@""]))
            {
                itemId = item.fashionistaPostId;
            }
        }
        else if(!(item.fashionistaPageId == nil))
        {
            if(!([item.fashionistaPageId isEqualToString:@""]))
            {
                itemId = item.fashionistaPageId;
            }
        }
        else if(!(item.wardrobeId == nil))
        {
            if(!([item.wardrobeId isEqualToString:@""]))
            {
                itemId = item.wardrobeId;
            }
        }
        else if(!(item.wardrobeQueryId == nil))
        {
            if(!([item.wardrobeQueryId isEqualToString:@""]))
            {
                itemId = item.wardrobeQueryId;
            }
        }
        else if(!(item.styleId == nil))
        {
            if(!([item.styleId isEqualToString:@""]))
            {
                itemId = item.styleId;
            }
        }
    }
    
    if (!([itemId isEqualToString:@""]))
    {
        if (!(_wardrobesFetchedResultsController == nil))
        {
            if (!((int)[[_wardrobesFetchedResultsController fetchedObjects] count] < 1))
            {
                for (GSBaseElement *tmpGSBaseElement in [_wardrobesFetchedResultsController fetchedObjects])
                {
                    if([tmpGSBaseElement isKindOfClass:[GSBaseElement class]])
                    {
                        // Check that the element to search is valid
                        if (!(tmpGSBaseElement == nil))
                        {
                            if(!(tmpGSBaseElement.productId == nil))
                            {
                                if(!([tmpGSBaseElement.productId isEqualToString:@""]))
                                {
                                    if ([tmpGSBaseElement.productId isEqualToString:itemId])
                                    {
                                        return YES;
                                    }
                                }
                            }
                            else if(!(tmpGSBaseElement.fashionistaPostId == nil))
                            {
                                if(!([tmpGSBaseElement.fashionistaPostId isEqualToString:@""]))
                                {
                                    if ([tmpGSBaseElement.fashionistaPostId isEqualToString:itemId])
                                    {
                                        return YES;
                                    }
                                }
                            }
                            else if(!(tmpGSBaseElement.fashionistaPageId == nil))
                            {
                                if(!([tmpGSBaseElement.fashionistaPageId isEqualToString:@""]))
                                {
                                    if ([tmpGSBaseElement.fashionistaPageId isEqualToString:itemId])
                                    {
                                        return YES;
                                    }
                                }
                            }
                            else if(!(tmpGSBaseElement.wardrobeId == nil))
                            {
                                if(!([tmpGSBaseElement.wardrobeId isEqualToString:@""]))
                                {
                                    if ([tmpGSBaseElement.wardrobeId isEqualToString:itemId])
                                    {
                                        return YES;
                                    }
                                }
                            }
                            else if(!(tmpGSBaseElement.wardrobeQueryId == nil))
                            {
                                if(!([tmpGSBaseElement.wardrobeQueryId isEqualToString:@""]))
                                {
                                    if ([tmpGSBaseElement.wardrobeQueryId isEqualToString:itemId])
                                    {
                                        return YES;
                                    }
                                }
                            }
                            else if(!(tmpGSBaseElement.styleId == nil))
                            {
                                if(!([tmpGSBaseElement.styleId isEqualToString:@""]))
                                {
                                    if ([tmpGSBaseElement.styleId isEqualToString:itemId])
                                    {
                                        return YES;
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    return NO;
}

- (BOOL)initFetchedResultsControllerWithEntity:(NSString *)entityName andPredicate:(NSString *)predicate inArray:(NSArray *)arrayForPredicate sortingWithKey:(NSString *)sortKey ascending:(BOOL)ascending
{
    BOOL bReturn = FALSE;
    
    if(_wardrobesFetchedResultsController == nil)
    {
        NSManagedObjectContext *currentContext = [RKObjectManager sharedManager].managedObjectStore.mainQueueManagedObjectContext;
        
        if (_wardrobesFetchRequest == nil)
        {
            if([arrayForPredicate count] > 0)
            {
                _wardrobesFetchRequest = [[NSFetchRequest alloc] init];
                
                // Entity to look for
                
                NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:currentContext];
                
                [_wardrobesFetchRequest setEntity:entity];
                
                // Filter results
                
                [_wardrobesFetchRequest setPredicate:[NSPredicate predicateWithFormat:predicate, arrayForPredicate]];
                
                // Sort results
                
                NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:sortKey ascending:ascending];
                
                [_wardrobesFetchRequest setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
                
                [_wardrobesFetchRequest setFetchBatchSize:20];
            }
        }
        
        if(_wardrobesFetchRequest)
        {
            // Initialize Fetched Results Controller
            
            //NSSortDescriptor *tmpSortDescriptor = (NSSortDescriptor *)[_wardrobesFetchRequest sortDescriptors].firstObject;
            
            NSFetchedResultsController *fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:_wardrobesFetchRequest managedObjectContext:currentContext sectionNameKeyPath:nil cacheName:nil];
            
            _wardrobesFetchedResultsController = fetchedResultsController;
            
            _wardrobesFetchedResultsController.delegate = self;
        }
        
        if(_wardrobesFetchedResultsController)
        {
            // Perform fetch
            
            NSError *error = nil;
            
            if (![_wardrobesFetchedResultsController performFetch:&error])
            {
                // TODO: Update to handle the error appropriately. Now, we just assume that there were not results
                
                NSLog(@"Couldn't fetched wardrobes. Unresolved error: %@, %@", error, [error userInfo]);
                
                return FALSE;
            }
            
            bReturn = ([_wardrobesFetchedResultsController fetchedObjects].count > 0);
        }
    }
    
    return bReturn;
}
- (IBAction)onTapFirstHangerButton:(id)sender {
    if (firstSelected) {
        NSLog(@"Already added");
    }
    else {
        _firstHangerButton.tag = 0;
        [_delegate onTapAddtoWardrobeButton:_firstHangerButton isSimilar:NO];
    }
}

- (IBAction)onTapSecondHangerButton:(id)sender {
    if (secondSelected) {
        NSLog(@"Already added");
    }
    else {
        _secondHangerButton.tag = 1;
        [_delegate onTapAddtoWardrobeButton:_secondHangerButton isSimilar:NO];
    }
}

- (IBAction)onTapThirdHangerButton:(id)sender {
    if (thirdSelected) {
        NSLog(@"Already added");
    }
    else {
        _thirdHangerButton.tag = 2;
        [_delegate onTapAddtoWardrobeButton:_thirdHangerButton isSimilar:NO];
    }
}

- (IBAction)onTapSeeMore:(id)sender {
    [_delegate onTapGetLookSeeMore];
}
- (IBAction)onTapFirstItem:(id)sender {
    [_delegate onTapProductItem:0];
}
- (IBAction)onTapSecondItem:(id)sender {
    [_delegate onTapProductItem:1];
}
- (IBAction)onTapThirdItem:(id)sender {
    [_delegate onTapProductItem:2];
}

@end