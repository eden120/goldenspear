//
//  ProductSheetViewController.m
//  GoldenSpear
//
//  Created by JAVIER CASTAN SANCHEZ on 27/4/15.
//  Copyright (c) 2015 GoldenSpear. All rights reserved.
//

#import "ProductSheetViewController.h"
#import "BaseViewController+TopBarManagement.h"
#import "BaseViewController+CustomCollectionViewManagement.h"
#import "BaseViewController+ActivityFeedbackManagement.h"
#import "BaseViewController+RestServicesManagement.h"
#import "BaseViewController+BottomControlsManagement.h"
#import "BaseViewController+StoryboardManagement.h"
#import "BaseViewController+FetchedResultsManagement.h"
#import "BaseViewController+UserManagement.h"
#import "AddItemToWardrobeViewController.h"
#import "WardrobeViewController.h"
#import "ProductFeatureSearchViewController.h"
#import "SearchBaseViewController.h"
#import "BaseViewController+MainMenuManagement.h"
#import "ShopsCell.h"
#import "UILabel+CustomCreation.h"
#import "NYTPhotosViewController.h"
#import <MobileCoreServices/UTCoreTypes.h>
#import "WardrobeContentViewController.h"
#import "GSFashionistaPostViewController.h"
#import "SeeMoreView.h"
#import "AvailabilityTableView.h"
#import "ReviewTableView.h"
#import "NSDate+Localtime.h"
#import "CoreDataQuery.h"

@import MapKit;

@import ImageIO;

@import AVKit;

@import AVFoundation;


@implementation NYTExamplePhotoProd

@end


@interface ProductSheetViewController () <HTHorizontalSelectionListDelegate, HTHorizontalSelectionListDataSource>

@end

@implementation ProductSheetViewController
{
    ProductView * productView;
    BOOL isGettingTheLook;
    BOOL issimilar;
	
	BOOL isRefresh;
	
	BOOL hasSize;
	BOOL hasReview;
	BOOL hasVariant;
	BOOL hasColor;
	BOOL hasMaterial;
    BOOL hasAvailability;
	
	// Top Navigation
	NSArray *topNavs;
	NSMutableArray *navs;
	//Size Array
	NSMutableArray *size_array;
	// Color Image Array
	NSMutableDictionary *color_images;
	NSMutableDictionary *material_images;
    
    NSMutableArray *instorelist;
    NSMutableArray *onlinelist;
    
    BOOL isSelectDetail;
	// Swipe Up/Down Page Views
	NSInteger currentPageIndex;
    
    NSMutableArray *review_array;
    NSArray *getLookParams;
    NSMutableArray *userWardrobesElements;
    
    NSArray *similarParams;
    
	UISwipeGestureRecognizer *rightSwipe;
	UISwipeGestureRecognizer *leftSwipe;
	UISwipeGestureRecognizer *topSwipe;
	UISwipeGestureRecognizer *bottomSwipe;
    
    UITapGestureRecognizer *singleTap;
}

// Object to get location data
CLLocationManager *locationManager;
// Class providing services for converting between a GPS coordinate and a user-readable address
CLGeocoder *geocoder;
// Object containing the result returned by CLGeocoder
CLPlacemark *placemark;

UIActivityIndicatorView *imgViewActivityIndicator;

// When adding products to a known wardrobe (directly within this ViewController, when coming from StylistPost edition), we need to keep track of the button to highlight
UIButton * buttonForHighlight = nil;

- (void)addExtraButtons{
    [self addExtraButton:@"share_ico" withHandler:@selector(shareContent)];
    [self addExtraButton:@"GetTheLookBottom" withHandler:@selector(getTheLook)];
}

- (void)getTheLook{
    
    if(!([_addToWardrobeVCContainerView isHidden]))
    {
        return;
    }

    if(!([_availabilityVCContainerView isHidden]))
    {
        return;
    }
    
    if (!self.writeReviewView.hidden)
    {
        [self closeWriteReview];
        [self actionForMainFourthCircleMenuEntry];
    }
    else if(!(_addingProductsToWardrobeID == nil))
    {
        [self dismissViewController];
    }
    else
    {
        //[super leftAction:sender];
        [self actionForMainFourthCircleMenuEntry];
    }
}

- (void)shareContent{
    if (!(self.shownProduct.idProduct == nil))
    {
        if(!([self.shownProduct.idProduct isEqualToString:@""]))
        {
            // Post the Share object
            
            NSManagedObjectContext *currentContext = [RKObjectManager sharedManager].managedObjectStore.mainQueueManagedObjectContext;
            
            Share * newShare = [[Share alloc] initWithEntity:[NSEntityDescription entityForName:@"Share" inManagedObjectContext:currentContext] insertIntoManagedObjectContext:currentContext];
            
            [newShare setSharedProductId:self.shownProduct.idProduct];
            
            AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            
            if (!(appDelegate.currentUser == nil))
            {
                if (!([appDelegate.currentUser.idUser isEqualToString:@""]))
                {
                    [newShare setSharingUserId:appDelegate.currentUser.idUser];
                }
            }
            
            [currentContext processPendingChanges];
            
            [currentContext save:nil];
            
            NSArray * requestParameters = [[NSArray alloc] initWithObjects:newShare, nil];
            
            [self performRestPost:UPLOAD_SHARE withParamaters:requestParameters];
        }
    }
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self performSelector:@selector(moveScrollBar) withObject:nil afterDelay:0.5];
	
	
	
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    _tempImagePath = @"";
    self.shownContent = nil;
    self.iSelectedContent = 0;
    
    self.bShowWebShops = true;
    self.bShowInStoreShops = true;

    _shownProductFeatureTerms = [[NSMutableArray alloc] init];
    //[self getFeaturesForProductId:_shownProduct];

    [self uploadProductView];
    [self setupViews];
    [self setupCollections];
	
	
	//////////////////////jcb
	isRefresh = NO;
	hasSize = NO;
	hasVariant = NO;
	hasColor = NO;
	hasMaterial = NO;
	hasReview = NO;
    hasAvailability = NO;
    isSelectDetail = NO;
    
	size_array = [[NSMutableArray alloc] init];
	if (_shownProduct.size_array == nil)
	{
		NSLog(@"Size_Array nil");
		hasSize = NO;
	}
	else
	{
		hasSize = YES;
		for (NSString * s in _shownProduct.size_array)
		{
			NSLog(@"Size %@", s);
			[size_array addObject:s];
		}
	}
	
	color_images = [[NSMutableDictionary alloc] init];
	material_images = [[NSMutableDictionary alloc] init];
	if (_shownProduct.variantGroup == nil)
	{
		NSLog(@"Variant group is null");
		hasVariant = NO;
	}
	else
	{
		
		NSLog(@"VariantGroup %@", _shownProduct.variantGroup.idVariantGroup);
		
		for(VariantGroupElement * vge in _shownProduct.variantGroup.variants)
		{
			hasVariant = YES;
			NSLog(@"Colour %@, %@", vge.color_name , vge.color_image);
			NSLog(@"Material %@, %@", vge.material_name , vge.material_image);
			NSLog(@"ProductId %@", vge.product_id);
			
			if ([color_images objectForKey:vge.color_name] == nil) {
				[color_images setObject:vge.color_image forKey:vge.color_name];
			}
			if ([material_images objectForKey:vge.material_name] == nil) {
				[material_images setObject:vge.material_image forKey:vge.material_name];
			}
		}
	}

	if ([color_images count] > 0) {
		hasColor = YES;
	}
	if ([material_images count] > 0) {
		hasMaterial = YES;
	}
    
    onlinelist = [[NSMutableArray alloc] init];
    instorelist = [[NSMutableArray alloc] init];
    for (int i = 0; i < [_productAvailabilies count]; i ++) {
        ProductAvailability *availability = (ProductAvailability*) [_productAvailabilies objectAtIndex:i];
        if ([availability.online boolValue]) {
            [onlinelist addObject:availability];
        }
        else {
            [instorelist addObject:availability];
        }
    }

    
	[self setupTopNavi];
    
    review_array = [[NSMutableArray alloc] init];
    
    if ([_productReviews count] > 0) {
        hasReview = YES;
    }
    getLookParams = [[NSArray alloc] init];
    similarParams = [[NSArray alloc] init];
    ////////////////////////////
	
    //Setup a fetched results controller to fetch the current user wardrobes
	
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
	
    if(!(appDelegate.addingProductsToWardrobeID == nil))
    {
        if(!([appDelegate.addingProductsToWardrobeID isEqualToString:@""]))
        {
            _addingProductsToWardrobeID = appDelegate.addingProductsToWardrobeID;
        }
    }
    
    if(appDelegate.currentUser)
    {
        [self initFetchedResultsControllerWithEntity:@"Wardrobe" andPredicate:@"userId IN %@" inArray:[NSArray arrayWithObject:appDelegate.currentUser.idUser] sortingWithKey:@"idWardrobe" ascending:YES];
        
        if (!(_wardrobesFetchedResultsController == nil))
        {
            userWardrobesElements = [[NSMutableArray alloc] init];
            
            for (int i = 0; i < [[_wardrobesFetchedResultsController fetchedObjects] count]; i++)
            {
                Wardrobe * tmpWardrobe = [[_wardrobesFetchedResultsController fetchedObjects] objectAtIndex:i];
                
                if([tmpWardrobe.idWardrobe isEqualToString:_addingProductsToWardrobeID])
                {
                    _addingProductsToWardrobe = tmpWardrobe;
                }

                [userWardrobesElements addObjectsFromArray:tmpWardrobe.itemsId];
            }
            
            _wardrobesFetchedResultsController = nil;
            _wardrobesFetchRequest = nil;
            
            [self initFetchedResultsControllerWithEntity:@"GSBaseElement" andPredicate:@"idGSBaseElement IN %@" inArray:userWardrobesElements sortingWithKey:@"idGSBaseElement" ascending:YES];
        }
    }
}

- (IBAction)reportBadProduct:(UIButton *)sender
{
    // Here we need to pass a full frame
    CustomAlertView *alertView = [[CustomAlertView alloc] init];
    
    UIView *errorTypesView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 300, 180)];
    
    for (int i = 0; i < maxProductReportTypes; i++)
    {
        // "_PRODUCT_REPORT_TYPE_0_" = "Imágenes incorrectas (pequeñas, borrosas, etc.)";
        // "_PRODUCT_REPORT_TYPE_1_" = "Precio incorrecto (o no tiene)";
        // "_PRODUCT_REPORT_TYPE_2_" = "Descripción incorrecta";
        // "_PRODUCT_REPORT_TYPE_3_" = "URL incorrecta";
        
        NSString *productReportType = [NSString stringWithFormat:@"_PRODUCT_REPORT_TYPE_%i_", i];
        
        UILabel *reportTypeLabel = [UILabel createLabelWithOrigin:CGPointMake(10, (10 * (i+1)) + (30 * i))
                                                          andSize:CGSizeMake(errorTypesView.frame.size.width - 80, 30)
                                               andBackgroundColor:[UIColor clearColor]
                                                         andAlpha:1.0
                                                          andText:NSLocalizedString(productReportType, nil)
                                                     andTextColor:[UIColor blackColor]
                                                          andFont:[UIFont fontWithName:@"Avenir-Light" size:15]
                                                   andUppercasing:NO
                                                       andAligned:NSTextAlignmentLeft];
        
        UISwitch *switchErrorType = [[UISwitch alloc] initWithFrame:CGRectMake(reportTypeLabel.frame.origin.x + reportTypeLabel.frame.size.width + 10, reportTypeLabel.frame.origin.y, 80, 10)];
        [switchErrorType setTag:i];
        [switchErrorType setOn:NO animated:NO];

        [errorTypesView addSubview:reportTypeLabel];
        [errorTypesView addSubview:switchErrorType];
    }
    
    // Add some custom content to the alert view
    [alertView setContainerView:errorTypesView];
    
    // Modify the parameters
    [alertView setButtonTitles:[NSMutableArray arrayWithObjects:NSLocalizedString(@"_CANCEL_", nil), NSLocalizedString(@"_SEND_", nil), nil]];

    [alertView setDelegate:self];
    
    [alertView setUseMotionEffects:true];
    
    // You may use a Block, rather than a delegate.
    [alertView setOnButtonTouchUpInside:^(CustomAlertView *alertView, int buttonIndex) {
        
        NSLog(@"Block: Button at position %d is clicked on alertView %d.", buttonIndex, (int)[alertView tag]);
        
        if(buttonIndex == 1)
        {
            // Check that the name is valid
            
            if (!(_shownProduct.idProduct == nil))
            {
                if(!([_shownProduct.idProduct isEqualToString:@""]))
                {
                    // Post the ProductReport object
                    
                    ProductReport * newProductReport = [[ProductReport alloc] init];
                    
                    [newProductReport setProductId:_shownProduct.idProduct];

                    int reportType = 0;
                    
                    for (UIView * view in alertView.containerView.subviews)
                    {
                        if ([view isKindOfClass:[UISwitch class]])
                        {
                            reportType += ((pow(2,(view.tag))) * ([((UISwitch*) view) isOn]));
                        }
                    }

                    [newProductReport setReportType:[NSNumber numberWithInt:reportType]];

                    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                    
                    if (!(appDelegate.currentUser == nil))
                    {
                        if (!([appDelegate.currentUser.idUser isEqualToString:@""]))
                        {
                            [newProductReport setUserId:appDelegate.currentUser.idUser];
                        }
                    }
                    
                    NSArray * requestParameters = [[NSArray alloc] initWithObjects:newProductReport, nil];
                    
                    [self stopActivityFeedback];
                    [self startActivityFeedbackWithMessage:NSLocalizedString(@"_UPLOADINGPRODUCTREPORT_ACTV_MSG_", nil)];
                    
                    [self performRestPost:ADD_PRODUCTREPORT withParamaters:requestParameters];
                }
            }
        }
        
        [alertView close];

    }];
    
    // And launch the dialog
    [alertView show];
    
}

- (void)customAlertViewButtonTouchUpInside:(id)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSLog(@"Delegate: Button at position %d is clicked on alertView %d.", (int)buttonIndex, (int)[alertView tag]);
}


// Given an array of terms, compose the string to be shown
- (NSString *)composeStringhWithTermsOfArray:(NSArray *)termsArray
{
    //Setup string
    
    NSString *resultString = @"";
    
    if (!((termsArray == nil) || ([termsArray count] < 1)))
    {
        for(int i = 0; i < [termsArray count]; i++)
        {
            NSString * term = [termsArray objectAtIndex:i];

            if(i == ([termsArray count]-1))
            {
                resultString = [resultString stringByAppendingString:[[[NSString stringWithFormat:@"%@.", term] lowercaseString] capitalizedString]];
            }
            else
            {
                resultString = [resultString stringByAppendingString:[[[NSString stringWithFormat:@"%@, ", term] lowercaseString] capitalizedString]];
            }
        }
    }
    
    // Check that the string is valid
    if (!((resultString == nil) || ([resultString isEqualToString:@""])))
    {
        // 'Clean' the string
        
        resultString = [resultString stringByReplacingOccurrencesOfString:@"\\s+"
                                                               withString:@" "
                                                                  options:NSRegularExpressionSearch
                                                                    range:NSMakeRange(0, resultString.length)];
        
        resultString = [resultString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    }
    
    return resultString;
}

- (void)setupViews
{
    // Separator
    CGFloat isRetina = ([UIScreen mainScreen].scale == 2.0f) ? YES : NO;
    
    if (isRetina)
    {
        self.separatorLineHeightConstraint.constant /= 2.0;
    }
    
    self.menuView.hidden = NO;
    self.reviewsView.hidden = YES;
    self.productInfoView.hidden = YES;
    self.availabilityView.hidden = YES;
    
    
    // Rate view
    _rateView.notSelectedImage = [UIImage imageNamed:@"notSelectedImage.png"];
    _rateView.halfSelectedImage = [UIImage imageNamed:@"halfSelectedImage.png"];
    _rateView.fullSelectedImage = [UIImage imageNamed:@"fullSelectedImage.png"];
    _rateView.rating = 3;
    _rateView.midMargin= 0;
    _rateView.editable = NO;
    _rateView.maxRating = 5;
    _rateView.delegate = nil;
    _reviewShadowView.layer.shadowOpacity = 0.3;
    _reviewShadowView.layer.shadowRadius = 2;
    _reviewShadowView.layer.shadowColor = [UIColor grayColor].CGColor;
    _reviewShadowView.layer.shadowOffset = CGSizeMake(0, 2.5);
    // New rating
    _reviewTextView.layer.borderWidth = 0.5;
    _reviewTextView.layer.borderColor = [UIColor grayColor].CGColor;
    _overallRateView.notSelectedImage = [UIImage imageNamed:@"notSelectedImage.png"];
    _overallRateView.halfSelectedImage = [UIImage imageNamed:@"halfSelectedImage.png"];
    _overallRateView.fullSelectedImage = [UIImage imageNamed:@"fullSelectedImage.png"];
    _overallRateView.rating = 3;
    _overallRateView.midMargin= 0;
    _overallRateView.editable = YES;
    _overallRateView.maxRating = 5;
    _overallRateView.delegate = nil;
    
    _comfortRateView.notSelectedImage = [UIImage imageNamed:@"notSelectedImage.png"];
    _comfortRateView.halfSelectedImage = [UIImage imageNamed:@"halfSelectedImage.png"];
    _comfortRateView.fullSelectedImage = [UIImage imageNamed:@"fullSelectedImage.png"];
    _comfortRateView.rating = 3;
    _comfortRateView.midMargin= 0;
    _comfortRateView.editable = YES;
    _comfortRateView.maxRating = 5;
    _comfortRateView.delegate = nil;
    
    _qualityRateView.notSelectedImage = [UIImage imageNamed:@"notSelectedImage.png"];
    _qualityRateView.halfSelectedImage = [UIImage imageNamed:@"halfSelectedImage.png"];
    _qualityRateView.fullSelectedImage = [UIImage imageNamed:@"fullSelectedImage.png"];
    _qualityRateView.rating = 3;
    _qualityRateView.midMargin= 0;
    _qualityRateView.editable = YES;
    _qualityRateView.maxRating = 5;
    _qualityRateView.delegate = nil;
    _addVideoToReviewButton.titleLabel.text = NSLocalizedString(@"_ADD_REVIEW_VIDEO_", nil);
    [_addVideoToReviewButton.titleLabel setAdjustsFontSizeToFitWidth:YES];
    [_addVideoToReviewButton.titleLabel setMinimumScaleFactor:0.5];
    
    [self setProductScreenTopBottom];
    
    
    if([_shownProductFeatureTerms count] > 0)
    {
        _productInfoTextView.text = [NSString stringWithFormat:@"%@: %@\n\n%@", NSLocalizedString(@"_PRODUCTTAGS_", nil), [self composeStringhWithTermsOfArray:_shownProductFeatureTerms], _shownProduct.information];
    }
    else
    {
        _productInfoTextView.text = _shownProduct.information;
    }

    if((_shownProduct.url == nil) || ([_shownProduct.url isEqualToString:@""]))
    {
        _PriceLabel.text = NSLocalizedString(@"_PASTCOLLECTIONPRODUCT_", nil);
        
        if((_shownProduct.brand.url == nil) || ([_shownProduct.brand.url isEqualToString:@""]))
        {
            [_purchaseButton setHidden:YES];
        }
        else
        {
            [_purchaseButton setTitle:NSLocalizedString(@"_GOTO_BRAND_PAGE_", nil) forState:UIControlStateNormal];
        }
    }
    else
    {
        if([_shownProduct.recommendedPrice floatValue] > 0)
        {
            _PriceLabel.text = [NSString stringWithFormat:@"$%.2f", [_shownProduct.recommendedPrice floatValue]];
        }
        else
        {
            _PriceLabel.text = NSLocalizedString(@"_PRICE_NOT_AVAILABLE_", nil);

            [_PriceLabel setTextColor:[UIColor lightGrayColor]];
        }
    }
    
    // Do any additional setup after loading the view.
    _missingImage = [UIImage imageNamed:@"no_image.png"];
    _portraitImage = [UIImage imageNamed:@"portrait.png"];

    _ProductImageView.contentMode = UIViewContentModeScaleAspectFit;
    // Init the activity indicator
    imgViewActivityIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    // Position and show the activity indicator
    [imgViewActivityIndicator setCenter:CGPointMake((_ProductImageView.frame.origin.x + (_ProductImageView.frame.size.width * 0.25)), (_ProductImageView.frame.origin.y + (_ProductImageView.frame.size.height * 0.6)))];
    [imgViewActivityIndicator setHidesWhenStopped:YES];
    [imgViewActivityIndicator startAnimating];
    [self.view addSubview: imgViewActivityIndicator];

}

- (void)setupWebViewArray
{
    /*
    // Seteamos las webviews
    _webViewArray = [[NSMutableArray alloc]init];
    _webView.hidden = YES;
    
    NSInteger iCount = self.productImageTempImageArray.count;
    for(int i = 0; i < iCount; i++)
    {
        UIWebView * pView = [[UIWebView alloc]initWithFrame:self.view.frame];
        pView.scalesPageToFit = YES;
        pView.allowsInlineMediaPlayback = YES;
        pView.contentMode = UIViewContentModeScaleAspectFill;
        pView.hidden = YES;
        pView.scrollView.delegate = self;
        pView.delegate = self;
        pView.backgroundColor = [UIColor whiteColor];
        [pView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[self.productImageTempImageArray objectAtIndex:i]]]];
        
        [_webView.superview addSubview:pView];
        [_webViewArray addObject:pView];
    }
     */
}



- (void)setupCollections
{
    // Setup Collection View
    [self setupCollectionViewsWithCellTypes:[[NSMutableArray alloc] initWithObjects:@"ContentCell", @"ReviewCell", nil]];
    
    // Check if there are contents
    bool bHasContent = false;
	
	////////////////////////////////////////////////JCB
	
//	NSLog([NSString stringWithFormat:<#(nonnull NSString *), ...#>]_productContent);
	/////////////////////////////////////////////////////
	
    if([self initFetchedResultsControllerForCollectionViewWithCellType:@"ContentCell" WithEntity:@"Content" andPredicate:@"idContent IN %@" inArray:_productContent sortingWithKeys:[NSArray arrayWithObject:@"idContent"] ascending:YES andSectionWithKeyPath:nil])
    {
        if([self getFetchedResultsControllerForCellType:@"ContentCell"].fetchedObjects.count > 0)
        {
            bHasContent = true;
            
            self.shownContent = [[self getFetchedResultsControllerForCellType:@"ContentCell"] objectAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
            
            if([self.shownContent.type isEqualToString: @"image"])
            {
                [self setMainImageWithURLString:self.shownContent.url];
            }
            else if([self.shownContent.type isEqualToString: @"video"])
            {
                [_ProductImageView setImage:[self generateThumbImage:self.shownContent.url]];
            }
        }
    }
    
    if(!bHasContent)
    {
        [self setMainImageWithURLString:_shownProduct.preview_image];

    }
    
    //[self setupWebViewArray];
    
    // Check if there are reviews
    if([self initFetchedResultsControllerForCollectionViewWithCellType:@"ReviewCell" WithEntity:@"Review" andPredicate:@"idReview IN %@" inArray:_productReviews sortingWithKeys:[NSArray arrayWithObject:@"date"] ascending:NO andSectionWithKeyPath:nil])
    {
        for(Review * review in [self getFetchedResultsControllerForCellType:@"ReviewCell"].fetchedObjects)
        {
            if(review.userId && ![review.userId isEqualToString:@""])
            {
                NSArray * requestParameters = [[NSArray alloc] initWithObjects:review.userId, nil];
                [self performRestGet:GET_USER withParamaters:requestParameters];
            }
        }
 
    }
    
    [self initCollectionViewsLayout];
}

- (void)setProductScreenTopBottom
{
    [self setTopBarTitle:(((_shownProduct.brand.name == nil) || ([_shownProduct.brand.name isEqualToString:@""])) ? (NSLocalizedString(@"_VCTITLE_23_", nil)) : (_shownProduct.brand.name)) andSubtitle:_shownProduct.name];
    
    if(!(_addingProductsToWardrobeID == nil))
    {
        
        return;
    }
}

- (void)setReviewScreenTopBottom
{
    NSString * sBrandProduct = [NSString stringWithFormat:@"%@", _shownProduct.name];

    if(!((_shownProduct.brand.name == nil) || ([_shownProduct.brand.name isEqualToString:@""])))
    {
        sBrandProduct = [NSString stringWithFormat:@"%@ - %@", _shownProduct.brand.name,_shownProduct.name];
    }
    
    [self setTopBarTitle:NSLocalizedString(@"_WRITE_REVIEW_", nil) andSubtitle:sBrandProduct];
}

- (void)setWebsiteScreenTopBottom:(NSString*)sTitle
{
    [self setTopBarTitle:sTitle andSubtitle:@""];
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if([self doesCurrentUserWardrobesContainProductWithId:_shownProduct.idProduct])
    {
        //_wardrobeButton.alpha = 0.5;
        UIImage * image = [UIImage imageNamed:@"wardrobeselected.png"];
        [self.wardrobeButton setBackgroundImage:image forState:UIControlStateNormal];
    }
    else
    {
        _wardrobeButton.alpha = 1;
        UIImage * image =  [UIImage imageNamed:@"wardrobe.png"];
        [self.wardrobeButton setBackgroundImage:image forState:UIControlStateNormal];
    }
	
	NSLog([NSString stringWithFormat:@"Profile Brand : %@", _shownProduct.idProduct]);
	if (_shownProduct.profile_brand == nil) {
		NSLog(@"Profile Brand NULL");
		[self.followButton setHidden:YES];
	}
	else {
		NSLog([NSString stringWithFormat:@"Profile Brand : %@", _shownProduct.profile_brand]);
		_isFollowing = [self doesCurrentUserFollowsStylistWithId:_shownProduct.profile_brand];
		UIImage *image;
		if (_isFollowing) {
			image = [UIImage imageNamed: @"unfollow.png"];
		}
		else {
			image = [UIImage imageNamed: @"follow.png"];
		}
		
		[self.followButton setImage:image forState:UIControlStateNormal];
		[self.followButton setHidden:NO];
	}

}



-(void) viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];

    [_productInfoTextView scrollRangeToVisible:NSMakeRange(0, 1)];
    
    if(IS_IPHONE_4_OR_LESS)
    {
        _ProductInfoToReviewsSpaceConstraint.constant = 0;
        _ReviewsToPurchaseSpaceConstraint.constant = 0;
        _PurchaseToFindSimilarSpaceConstraint.constant = 0;
    }

	if (!isRefresh) {
		isRefresh = YES;
		[self initBackgroundView];
	}
    /*
    for(NSInteger i = 0; i < _webViewArray.count; i++)
    {
        UIWebView * webView = [_webViewArray objectAtIndex:i];
        webView.frame = _webView.frame;
    }
     */
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];

    // Dispose of any resources that can be recreated.
}

BOOL bAnimating = false;

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    /*
    if(bAnimating)
        return;
    
    float fOffsetMargin = 30.0;
    NSInteger contentCount = self.productImageTempImageArray.count;
    
    if(scrollView.contentOffset.x >= ((scrollView.contentSize.width - scrollView.frame.size.width)+fOffsetMargin))
    {
        // Current webview
        UIWebView * pCurrentWebView = [self.webViewArray objectAtIndex:self.iSelectedContent];
        
        // Right
        if(self.iSelectedContent < (contentCount-1))
        {
            bAnimating = true;
            self.iSelectedContent = self.iSelectedContent+1;
            UIWebView * pNextWebView = [self.webViewArray objectAtIndex:(self.iSelectedContent)];
            
            CGRect visibleRect = pCurrentWebView.frame;
            CGRect hideRightRect = pCurrentWebView.frame;
            hideRightRect.origin.x = hideRightRect.size.width;
            CGRect hideLefttRect = pCurrentWebView.frame;
            hideLefttRect.origin.x = -hideLefttRect.size.width;
            
            pNextWebView.frame = hideRightRect;
            
            CGPoint bottomOffset = CGPointMake(0, pNextWebView.scrollView.contentSize.height - pNextWebView.scrollView.bounds.size.height);
            [pNextWebView.scrollView setContentOffset:bottomOffset animated:NO];

            pNextWebView.hidden = NO;
            
            [UIView animateWithDuration:0.5
                                  delay:0
                                options:UIViewAnimationOptionCurveLinear
                             animations:^ {
                                 
                                 pNextWebView.frame = visibleRect;
                                 pCurrentWebView.frame = hideLefttRect;
                                 [self.view layoutIfNeeded];

                                 
                             }
                             completion:^(BOOL finished) {
                                 pCurrentWebView.hidden = YES;
                                 pCurrentWebView.frame = visibleRect;
                                 bAnimating = false;
                             }];
        }
        
    }
    else if(scrollView.contentOffset.x <= -fOffsetMargin)
    {
        // Current webview
        UIWebView * pCurrentWebView = [self.webViewArray objectAtIndex:self.iSelectedContent];
        
        // left
        if(self.iSelectedContent > 0)
        {
            bAnimating = true;
            self.iSelectedContent = self.iSelectedContent-1;
            UIWebView * pNextWebView = [self.webViewArray objectAtIndex:(self.iSelectedContent)];
            
            CGRect visibleRect = pCurrentWebView.frame;
            CGRect hideRightRect = pCurrentWebView.frame;
            hideRightRect.origin.x = hideRightRect.size.width;
            CGRect hideLefttRect = pCurrentWebView.frame;
            hideLefttRect.origin.x = -hideLefttRect.size.width;
            
            pNextWebView.frame = hideLefttRect;
            
            CGPoint bottomOffset = CGPointMake(0, pNextWebView.scrollView.contentSize.height - pNextWebView.scrollView.bounds.size.height);
            [pNextWebView.scrollView setContentOffset:bottomOffset animated:NO];

            pNextWebView.hidden = NO;
            
            [UIView animateWithDuration:0.5
                                  delay:0
                                options:UIViewAnimationOptionCurveLinear
                             animations:^ {
                                 
                                 pNextWebView.frame = visibleRect;
                                 pCurrentWebView.frame = hideRightRect;
                                 [self.view layoutIfNeeded];

                                 
                             }
                             completion:^(BOOL finished) {
                                 pCurrentWebView.hidden = YES;
                                 pCurrentWebView.frame = visibleRect;
                                 bAnimating = false;
                             }];
        }
        
    }
     */
}

- (void)closeAvailiabilityDetailView
{
    [UIView transitionWithView:self.availabilityDetailView
                      duration:0.5
                       options:UIViewAnimationOptionTransitionCrossDissolve//UIViewAnimationOptionTransitionNone
                    animations:^{
                        self.infoView.hidden = NO;
                        [self.view bringSubviewToFront:self.infoView];
                        [self bringBottomControlsToFront];
                        [self bringTopBarToFront];
                        self.availabilityDetailView.hidden = YES;
                    }
                    completion:^(BOOL finished){
                        [_availabilityWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"about:blank"]]];
                    }];

}

- (void)closeWriteReview
{
    [self setProductScreenTopBottom];
    
    [UIView transitionWithView:self.writeReviewView
                      duration:0.5
                       options:UIViewAnimationOptionTransitionCrossDissolve//UIViewAnimationOptionTransitionNone
                    animations:^{
                        self.infoView.hidden = NO;
                        [self.view bringSubviewToFront:self.infoView];
                        [self bringBottomControlsToFront];
                        [self bringTopBarToFront];
                        self.writeReviewView.hidden = YES;
                        _reviewTextSpaceConstraint.constant = 125;
                        if(self.player)
                        {
                            self.player.view.alpha = 0.0;
                        }
                    }
                    completion:^(BOOL finished){
                        if(self.player)
                        {
                            [self.player.view removeFromSuperview];
                            self.player = nil;
                        }
                    }];
    
}

// Custom animation to dismiss view controller
- (void)dismissViewController
{
    [self setProductScreenTopBottom];
    
    if(!self.availabilityDetailView.hidden)
    {
        [self closeAvailiabilityDetailView];
    }
    else if(!self.writeReviewView.hidden)
    {
        [self closeWriteReview];
    }
    else
    {
        if(self.menuView.hidden == NO)
        {
            [super dismissViewController];
        }
        else
        {
            self.menuView.hidden = NO;
            [self.ProductBottomView bringSubviewToFront:self.menuView];
            [self bringBottomControlsToFront];
            [self bringTopBarToFront];
            
            [UIView transitionWithView:self.menuView
                              duration:0.5
                               options:UIViewAnimationOptionTransitionCrossDissolve//UIViewAnimationOptionTransitionNone
                            animations:nil
                            completion:^(BOOL finished){
                                self.productInfoView.hidden = YES;
                                self.availabilityView.hidden = YES;
                                self.reviewsView.hidden = YES;
                            }];
        }
    }

}

-(BOOL)saveImage:(CGImageRef)image savePath:(NSString*)savePath
{
    @autoreleasepool {
        
        CFURLRef url = (__bridge CFURLRef)[NSURL fileURLWithPath:savePath];
        
        CGImageDestinationRef destination = CGImageDestinationCreateWithURL(url, kUTTypePNG, 1, NULL);
        
        CGImageDestinationAddImage(destination, image, nil);
        
        if (!CGImageDestinationFinalize(destination))
        {
            CFRelease(destination);
            
            CGImageRelease(image);
            
            NSLog(@"ERROR saving: %@", url);
            
            return NO;
        }
        
        CFRelease(destination);
        
        CGImageRelease(image);
        
        return YES;
    }
}

- (void)setMainImageWithURLString:(NSString*)urlString
{
    if ([UIImage isCached:urlString])
    {
        UIImage * image = [UIImage cachedImageWithURL:urlString];
        
        if(image == nil)
        {
            image = [UIImage imageNamed:@"no_image.png"];
        }
        
        [self.ProductImageView setImage:image];
        
        [imgViewActivityIndicator stopAnimating];
    }
    else
    {
        // Load image in the background
        
        __weak ProductSheetViewController *weakSelf = self;
        
        NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
            
            UIImage * image = [UIImage cachedImageWithURL:urlString];
            
            if(image == nil)
            {
                image = [UIImage imageNamed:@"no_image.png"];
                
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                // Then set image via the main queue
                [weakSelf.ProductImageView setImage:image];
                
                [imgViewActivityIndicator stopAnimating];
            });
        }];
        
        operation.queuePriority = NSOperationQueuePriorityHigh;
        
        [self.imagesQueue addOperation:operation];
    }
    
//    UIImage * pImage = [UIImage cachedImageWithURL:urlString];
//
//    if(pImage)
//        [_ProductImageView setImage:pImage];
//    else
//        [_ProductImageView setImage:_missingImage];
    
}

-(UIImage *)generateThumbImage : (NSString *)filepath
{
    //NSURL *url = [NSURL fileURLWithPath:filepath];
    NSURL *url = [NSURL URLWithString:filepath];
    
    AVURLAsset *asset = [AVURLAsset assetWithURL:url];
    AVAssetImageGenerator *imageGenerator = [[AVAssetImageGenerator alloc]initWithAsset:asset];
    //CMTime time = [asset duration];
    CMTime time = CMTimeMake(0, 60);
//    time.value = 0;
    CGImageRef imageRef = [imageGenerator copyCGImageAtTime:time actualTime:NULL error:NULL];
    UIImage *thumbnail = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);  // CGImageRef won't be released by ARC
    
    return thumbnail;
}



// Get product features
- (void)getFeaturesForProductId:(Product *)product
{
    // Check that there's actually a product to search its features
    if (!(product == nil))
    {
        if (!(product.idProduct == nil))
        {
            if (!([product.idProduct isEqualToString:@""]))
            {
                [_shownProductFeatureTerms removeAllObjects];
                
                NSLog(@"Getting features for product: %@", product.idProduct);
                
                // Provide feedback to user
                [self stopActivityFeedback];
                [self startActivityFeedbackWithMessage:NSLocalizedString(@"_DOWNLOADINGFEATURES_ACTV_MSG_", nil)];
                
                NSArray * requestParameters = [[NSArray alloc] initWithObjects:product, nil];
                
                [self performRestGet:GET_PRODUCT_FEATURES withParamaters:requestParameters];
            }
        }
    }
}


#pragma mark - Collection View

// OVERRIDE: Number of sections for the given collection view (to be overridden by each sub- view controller)
- (NSInteger)numberOfSectionsForCollectionViewWithCellType:(NSString *)cellType
{
    return 1;
}

// OVERRIDE: Return if the first section is empty and it should, therefore, be notified to the user
- (BOOL)shouldShowDecorationViewForCollectionView:(UICollectionView *)collectionView
{
    return NO;
}

// OVERRIDE: Return if the first section is empty and it should, therefore, be notified to the user
- (BOOL)shouldReportResultsforSection:(int)section
{
    return NO;
}

// OVERRIDE: Return the title to be shown in section header for a collection view
- (NSString *)getHeaderTitleForCellWithType:(NSString *)cellType AtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

// OVERRIDE: Number of items in each section for the main collection view (to be overridden by each sub- view controller)
- (NSInteger)numberOfItemsInSection:(NSInteger)section forCollectionViewWithCellType:(NSString *)cellType
{
    if ([cellType isEqualToString:@"ContentCell"])
    {
        NSInteger iCount =  [self getFetchedResultsControllerForCellType:@"ContentCell"].fetchedObjects.count;
        
        if(iCount <= 1)
            return 0;
        else
            return iCount;

    }
    else if([cellType isEqualToString:@"ReviewCell"])
    {
        NSInteger count = [self getFetchedResultsControllerForCellType:@"ReviewCell"].fetchedObjects.count;
        return [self getFetchedResultsControllerForCellType:@"ReviewCell"].fetchedObjects.count;
    }
    
    return 0;
}

// OVERRIDE: Return the content to be shown in a cell for a collection view
- (NSArray *)getContentForCellWithType:(NSString *)cellType AtIndexPath:(NSIndexPath *)indexPath
{
    if ([cellType isEqualToString:@"ContentCell"])
    {
        self.shownContent = [[self getFetchedResultsControllerForCellType:@"ContentCell"] objectAtIndexPath:indexPath];
        
        return [NSArray arrayWithObjects: self.shownContent.url, nil];
    }
    else if([cellType isEqualToString:@"ReviewCell"])
    {
        Review * review = [[self getFetchedResultsControllerForCellType:@"ReviewCell"] objectAtIndexPath:indexPath];
        
        if(!review.user)
        {
            _wardrobesFetchedResultsController = nil;
            _wardrobesFetchRequest = nil;
            
            [self initFetchedResultsControllerWithEntity:@"User" andPredicate:@"idUser IN %@" inArray:[NSArray arrayWithObject:review.userId] sortingWithKey:@"idUser" ascending:YES];
            
            if (!(_wardrobesFetchedResultsController == nil))
            {
                //NSMutableArray * userWardrobesElements = [[NSMutableArray alloc] init];
                
                for (int i = 0; i < [[_wardrobesFetchedResultsController fetchedObjects] count]; i++)
                {
                    User * tmpUser = [[_wardrobesFetchedResultsController fetchedObjects] objectAtIndex:i];
                    review.user = tmpUser;
                }
                
                _wardrobesFetchedResultsController = nil;
                _wardrobesFetchRequest = nil;
            }
        }
        
        [review_array addObject:review];
        
//        reviewVC.reviews = review_array;
//        reviewVC.reviewCount = [_productReviews count];
//        [reviewVC initView];
        
        return [NSArray arrayWithObjects: review.user.picture, review.user.name, review.location, review.text, review.overall_rating, review.comfort_rating, review.quality_rating, review.video, nil];
    }
    
    return nil;
}

// OVERRIDE: Action to perform if an item in a collection view is selected
- (void)actionForSelectionOfCellWithType:(NSString *)cellType AtIndexPath:(NSIndexPath *)indexPath
{
    if ([cellType isEqualToString:@"ContentCell"])
    {
        self.shownContent = [[self getFetchedResultsControllerForCellType:@"ContentCell"] objectAtIndexPath:indexPath];

        self.iSelectedContent = [indexPath indexAtPosition:1];
        [self setMainImageWithURLString:self.shownContent.url];
    }
    else if([cellType isEqualToString:@"ReviewCell"])
    {
    }
}

- (void)showAvailabilityDetailViewWithURLString:(NSString*)sURL
{
    [self.availabilityWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:sURL]]];
    
    self.availabilityDetailView.hidden = NO;
    [self.view bringSubviewToFront:self.availabilityDetailView];
    [self bringBottomControlsToFront];
    [self bringTopBarToFront];
    
    [UIView transitionWithView:self.availabilityDetailView
                      duration:0.5
                       options:UIViewAnimationOptionTransitionCrossDissolve//UIViewAnimationOptionTransitionNone
                    animations:nil
                    completion:^(BOOL finished){
                        self.infoView.hidden = YES;
                    }];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{

    CGSize contentSize = webView.scrollView.contentSize;
    contentSize.width += 1.0f;
    [webView.scrollView setContentSize:contentSize];
    //[webView.scrollView setContentOffset:CGPointMake(-10,0) animated:NO];
}

/*
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    if([webView.request.URL isEqual:[NSURL URLWithString:@"about:blank"]])
        return;
    //Check here if still webview is loding the content
    if (webView.isLoading)
        return;
    else //finished
    {
        //Fit to window
        //[_webView setScalesPageToFit:YES];
        //self.webView.contentMode = UIViewContentModeScaleAspectFill;
        
        CGSize contentSize = webView.scrollView.contentSize;
        //CGSize viewSize = self.view.bounds.size;
 
        //float rw = viewSize.width / contentSize.width;
        
        //_webView.scrollView.minimumZoomScale = rw*0.8;
        //_webView.scrollView.maximumZoomScale = rw*2.0;
        //_webView.scrollView.zoomScale = rw*1.1;
 

        contentSize.width += 10.0f;
        [webView.scrollView setContentSize:contentSize];
        webView.scrollView.scrollEnabled = TRUE;
        webView.scalesPageToFit = TRUE;

        webView.hidden = NO;
        self.zoomView.hidden = NO;
        [self.view bringSubviewToFront:self.zoomView];
        [self bringBottomControlsToFront];
        [self bringTopBarToFront];
        
        [UIView transitionWithView:self.view
                          duration:0.5
                           options:UIViewAnimationOptionTransitionCrossDissolve//UIViewAnimationOptionTransitionNone
                        animations:nil
                        completion:^(BOOL finished){
                            self.infoView.hidden = YES;
                        }];
    }
}
*/
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 1)
    {
        [self transitionToViewController:SIGNIN_VC withParameters:nil];
    }
}


// Initialize fetched Results Controller to fetch the current user wardrobes in order to properly show the hanger button
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


- (BOOL) doesCurrentUserWardrobesContainProductWithId:(NSString *)productId
{
    if (!([productId isEqualToString:@""]))
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
                                    if ([tmpGSBaseElement.productId isEqualToString:productId])
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

- (void)uploadReview
{
    NSLog(@"Uploading review...");
    
    // Check that the name is valid
    
    // Perform request to upload the review
    
    // Provide feedback to user
    [self stopActivityFeedback];
    [self startActivityFeedbackWithMessage:NSLocalizedString(@"_UPLOADINGREVIEW_ACTV_MSG_", nil)];
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    NSManagedObjectContext *currentContext = [RKObjectManager sharedManager].managedObjectStore.mainQueueManagedObjectContext;
    
    Review *newReview = [[Review alloc] initWithEntity:[NSEntityDescription entityForName:@"Review" inManagedObjectContext:currentContext] insertIntoManagedObjectContext:currentContext];
    
    // TO DO: Upload date??
    
    [newReview setProductId:_shownProduct.idProduct];

    [newReview setUserId:appDelegate.currentUser.idUser];

    // TO DO: Get real location
    [newReview setLocation:(((_currentUserLocation == nil) || ([_currentUserLocation isEqualToString:@""])) ? (NSLocalizedString(@"_COULDNT_RETRIEVE_USERLOCATION_", nil)) : (_currentUserLocation))];
    
    [newReview setOverall_rating:[NSNumber numberWithFloat:self.overallRateView.rating]];
    
    [newReview setComfort_rating:[NSNumber numberWithFloat:self.comfortRateView.rating]];
    
    [newReview setQuality_rating:[NSNumber numberWithFloat:self.qualityRateView.rating]];
    
    [newReview setText:self.reviewTextView.text];
    newReview.video = _temporalReviewURL;
    
    NSArray * requestParameters = [[NSArray alloc] initWithObjects: _shownProduct.idProduct, newReview, nil];
    
    [self performRestPost:ADD_REVIEW_TO_PRODUCT withParamaters:requestParameters];
    
    
}

// Action to perform if the connection succeed
- (void) actionAfterSuccessfulAnswerToRestConnection:(connectionType)connection WithResult:(NSArray *)mappingResult
{
    __block SearchQuery *searchQuery;
    
    __block NSNumber * postLikesNumber = [NSNumber numberWithInt:0];
    __block User * postAuthor = nil;
    
    NSArray * parametersForNextVC = nil;
    NSMutableArray * resultComments = [[NSMutableArray alloc] init];
    
    NSMutableArray *foundResultsGroups = [[NSMutableArray alloc] init];
    NSMutableArray *foundResults = [[NSMutableArray alloc] init];
    __block NSString * notSuccessfulTerms = @"";
    NSMutableArray *successfulTerms = nil;

    NSMutableArray *getLookResults = [[NSMutableArray alloc] init];
    NSMutableArray *similarResults = [[NSMutableArray alloc] init];
    
    __block id selectedSpecificResult;
    NSMutableArray * resultContent = [[NSMutableArray alloc] init];
    NSMutableArray * resultReviews = [[NSMutableArray alloc] init];
    
    switch (connection)
    {
        case ADD_PRODUCTVIEW:
        {
            // Now, request the product group
            if (!(mappingResult == nil))
            {
                if ([mappingResult count] > 0)
                {
                    productView = ((ProductView *)([mappingResult objectAtIndex:0]));
                    
                    return;
                }
            }
            break;
        }
        case GET_PRODUCT_FEATURES:
        {
            // Get the list of features that were provided, as well as the brand and the product group
            // Then, check if the mapping contains the expected information
            [mappingResult enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
             {
                 if (([obj isKindOfClass:[Feature class]]))
                 {
                     if(!([(Feature*)(obj) name] == nil))
                     {
                         if (!([[(Feature*)(obj) name] isEqualToString:@""]))
                         {
                             if (!([_shownProductFeatureTerms containsObject:[(Feature*)(obj) name]]))
                             {
                                 [_shownProductFeatureTerms addObject:[(Feature*)(obj) name]];
                             }
                         }
                     }
                 }
             }];
            
            // Now, request the product group
            if (!(mappingResult == nil))
            {
                if ([mappingResult count] > 0)
                {
                    Product * product = ((Product *)([mappingResult objectAtIndex:0]));
                    
                    NSArray * requestParameters = [[NSArray alloc] initWithObjects:product, nil];
                    
                    [self performRestGet:GET_PRODUCT_GROUP withParamaters:requestParameters];
                    
                    return;
                }
            }
            
            // Update the Product Info view
            
            if([_shownProductFeatureTerms count] > 0)
            {
                // There were results!
                _productInfoTextView.text = [NSString stringWithFormat:@"%@: %@\n\n%@", NSLocalizedString(@"_PRODUCTTAGS_", nil), [self composeStringhWithTermsOfArray:_shownProductFeatureTerms], _shownProduct.information];
            }

            [self stopActivityFeedback];
            
            break;
        }
        case GET_PRODUCT_GROUP:
        {
            // Get the list of features that were provided, as well as the brand and the product group
            // Then, check if the mapping contains the expected information
            [mappingResult enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
             {
                 if (([obj isKindOfClass:[ProductGroup class]]))
                 {
                     if(!([(ProductGroup*)(obj) name] == nil))
                     {
                         if (!([[(ProductGroup*)(obj) name] isEqualToString:@""]))
                         {
                             if (!([_shownProductFeatureTerms containsObject:[(ProductGroup*)(obj) name]]))
                             {
                                 [_shownProductFeatureTerms addObject:[(ProductGroup*)(obj) name]];
                             }
                             
                             // Now, request the product brand
                             
                             if(!(mappingResult == nil))
                             {
                                 if([mappingResult count] > 0)
                                 {
                                     NSString * product = (NSString *)([(Product*)([mappingResult objectAtIndex:0]) idProduct]);
                                     
                                     [self performRestGet:GET_PRODUCT_BRAND withParamaters:[NSArray arrayWithObject:product]];
                                     
                                     return;
                                 }
                             }
                         }
                     }
                 }
             }];

            // Update the Product Info view
            
            if([_shownProductFeatureTerms count] > 0)
            {
                // There were results!
                _productInfoTextView.text = [NSString stringWithFormat:@"%@: %@\n\n%@", NSLocalizedString(@"_PRODUCTTAGS_", nil), [self composeStringhWithTermsOfArray:_shownProductFeatureTerms], _shownProduct.information];
            }
            
            [self stopActivityFeedback];
            
            break;
        }
        case GET_PRODUCT:
        {
            // Get the product that was provided
            [mappingResult enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
             {
                 if (([obj isKindOfClass:[Product class]]))
                 {
                     selectedSpecificResult = (Product *)obj;
                     
                     // Stop the enumeration
                     *stop = YES;
                 }
             }];
            
            // Get the list of reviews that were provided
            for (Review *review in mappingResult)
            {
                if([review isKindOfClass:[Review class]])
                {
                    if(!(review.idReview == nil))
                    {
                        if  (!([review.idReview isEqualToString:@""]))
                        {
                            if(!([resultReviews containsObject:review.idReview]))
                            {
                                [resultReviews addObject:review.idReview];
                            }
                        }
                    }
                }
            }
            
            // Get the list of contents that were provided
            for (Content *content in mappingResult)
            {
                if([content isKindOfClass:[Content class]])
                {
                    if(!(content.idContent == nil))
                    {
                        if  (!([content.idContent isEqualToString:@""]))
                        {
                            if(!([resultContent containsObject:content.idContent]))
                            {
                                [resultContent addObject:content.idContent];
                                [self preLoadImage:content.url];
                            }
                        }
                    }
                }
            }
            
            // Paramters for next VC (ResultsViewController)
            parametersForNextVC = [NSArray arrayWithObjects: _selectedResult, selectedSpecificResult, resultContent, resultReviews, nil, nil];
            
            [self stopActivityFeedback];
            
            if (!isSelectDetail) {
                [self transitionToViewController:PRODUCTSHEET_VC withParameters:parametersForNextVC];
            }
            else {
                isSelectDetail = NO;
                [self setUpProductImageView];
                [self onTapProductImage:nil];
            }
            
            break;
            
        }

        case GET_PRODUCT_BRAND:
        {
            // Get the list of features that were provided, as well as the brand and the product group
            // Then, check if the mapping contains the expected information
            [mappingResult enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
             {
                 if (([obj isKindOfClass:[Brand class]]))
                 {
                     if(!([(Brand*)(obj) name] == nil))
                     {
                         if (!([[(Brand*)(obj) name] isEqualToString:@""]))
                         {
                             if (!([_shownProductFeatureTerms containsObject:[(Brand*)(obj) name]]))
                             {
                                 [_shownProductFeatureTerms addObject:[(Brand*)(obj) name]];
                             }
                         }
                     }
                 }
             }];
            
            // Update the Product Info view
            
            if([_shownProductFeatureTerms count] > 0)
            {
                // There were results!
                _productInfoTextView.text = [NSString stringWithFormat:@"%@: %@\n\n%@", NSLocalizedString(@"_PRODUCTTAGS_", nil), [self composeStringhWithTermsOfArray:_shownProductFeatureTerms], _shownProduct.information];
            }
            
            [self stopActivityFeedback];
            
            break;
        }
        case FINISHED_BRANDPRODUCTSSEARCH_WITH_RESULTS:
        {
            // Get the number of total results that were provided
            // and the string of terms that didn't provide any results
            [mappingResult enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
             {
                 if (([obj isKindOfClass:[SearchQuery class]]))
                 {
                     searchQuery = obj;
                     
                     // Stop the enumeration
                     *stop = YES;
                 }
             }];
            
            if (searchQuery.numresults > 0)
            {
                // Get the list of results groups that were provided
                for (ResultsGroup *group in mappingResult)
                {
                    if([group isKindOfClass:[ResultsGroup class]])
                    {
                        if(!(group.idResultsGroup == nil))
                        {
                            if (!([group.idResultsGroup isEqualToString:@""]))
                            {
                                if(!([foundResultsGroups containsObject:group]))
                                {
                                    [foundResultsGroups addObject:group];
                                }
                            }
                        }
                    }
                }
                
                // Get the list of results that were provided
                for (GSBaseElement *result in mappingResult)
                {
                    if([result isKindOfClass:[GSBaseElement class]])
                    {
                        if(!(result.idGSBaseElement == nil))
                        {
                            if (!([result.idGSBaseElement isEqualToString:@""]))
                            {
                                if(!([foundResults containsObject:result.idGSBaseElement]))
                                {
                                    [foundResults addObject:result.idGSBaseElement];
                                }
                            }
                        }
                    }
                }
                
                // Get the keywords that provided results
                for (Keyword *keyword in mappingResult)
                {
                    if([keyword isKindOfClass:[Keyword class]])
                    {
                        if (successfulTerms == nil)
                        {
                            successfulTerms = [[NSMutableArray alloc] init];
                        }
                        
                        if(!(keyword.name == nil))
                        {
                            if (!([keyword.name isEqualToString:@""]))
                            {
                                NSString * pene = [[keyword.name lowercaseString] capitalizedString];
                                pene = [pene stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                                
                                if (!([successfulTerms containsObject:pene]))
                                {
                                    // Add the term to the set of terms
                                    [successfulTerms addObject:pene];
                                }
                            }
                        }
                        
                    }
                }
                
                // Paramters for next VC (ResultsViewController)
                NSArray * parametersForNextVC = [NSArray arrayWithObjects: searchQuery, foundResults, foundResultsGroups, successfulTerms, notSuccessfulTerms, nil];
                
                [self stopActivityFeedback];
                
                if ([foundResults count] > 0)
                {
					[self transitionToViewController:SEARCH_VC withParameters:parametersForNextVC];
                }
                else
                {
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_INFO_", nil) message:NSLocalizedString(@"_NO_BRANDPRODUCTS_ERROR_MSG_", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"_OK_", nil) otherButtonTitles:nil];
                    
                    [alertView show];
                }
            }
            else
            {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_INFO_", nil) message:NSLocalizedString(@"_NO_BRANDPRODUCTS_ERROR_MSG_", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"_OK_", nil) otherButtonTitles:nil];
                
                [alertView show];
            }

            break;
        }
        case FINISHED_BRANDPRODUCTSSEARCH_WITHOUT_RESULTS:
        {
            [self stopActivityFeedback];
            
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_INFO_", nil) message:NSLocalizedString(@"_NO_BRANDPRODUCTS_ERROR_MSG_", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"_OK_", nil) otherButtonTitles:nil];
            
            [alertView show];
            
            break;
        }
        case UPLOAD_SHARE:
        {
            // Get the list of comments that were provided
            for (Share *newShare in mappingResult)
            {
                if([newShare isKindOfClass:[Share class]])
                {
                    [self socialShareActionWithShareObject:((Share*) newShare) andPreviewImage:[UIImage cachedImageWithURL:_shownProduct.preview_image]];
                    
                    break;
                }
            }
            
            break;
        }
        case GET_USER:
        {
            
            //[self.secondCollectionView reloadData];
			for (User *user in mappingResult) {
				if ([user isKindOfClass:[User class]]) {
					

				}
			}
            break;
        }
		case UNFOLLOW_USER:
		case FOLLOW_USER:
		{
			UIImage *image;
			if (_isFollowing) {
				image = [UIImage imageNamed: @"unfollow.png"];
			}
			else {
				image = [UIImage imageNamed: @"follow.png"];
			}
			
			[self.followButton setImage:image forState:UIControlStateNormal];
			
			[self stopActivityFeedback];
			
			break;
		}
        case UPLOAD_REVIEW_VIDEO:
        {
            if(![self performFetchForCollectionViewWithCellType:@"ReviewCell"])
            {
                if([self initFetchedResultsControllerForCollectionViewWithCellType:@"ReviewCell" WithEntity:@"Review" andPredicate:@"idReview IN %@" inArray:_productReviews sortingWithKeys:[NSArray arrayWithObject:@"date"] ascending:NO andSectionWithKeyPath:nil])
                {
                    for(Review * review in [self getFetchedResultsControllerForCellType:@"ReviewCell"].fetchedObjects)
                    {
                        if(review.userId && ![review.userId isEqualToString:@""])
                        {
                            NSArray * requestParameters = [[NSArray alloc] initWithObjects:review.userId, nil];
                            [self performRestGet:GET_USER withParamaters:requestParameters];
                        }
                    }
                }
            }
            
            // Update collection view
            [self.secondCollectionView reloadData];

            [self stopActivityFeedback];
            
            [self closeWriteReview];
            
            break;
        }
            
        case ADD_REVIEW_TO_PRODUCT:
        {
            Review * uploadedReview = nil;
            
            // Get the Added review
            for (Review * content in mappingResult)
            {
                if([content isKindOfClass:[Review class]])
                {
                    if(!(content.idReview == nil))
                    {
                        if  (!([content.idReview isEqualToString:@""]))
                        {
                            [_productReviews addObject:content.idReview];
                            [_reviews insertObject:content atIndex:0];
                            uploadedReview = content;
                            break;
                        }
                    }
                }
            }
            
            
            
            if(!(uploadedReview == nil))
            {
                //                _uploadedContent = uploadedContent;
                if(!(uploadedReview.video == nil))
                {
                    if(!([uploadedReview.video isEqualToString:@""]))
                    {
                        NSData * data = [NSData dataWithContentsOfURL:[NSURL URLWithString:uploadedReview.video]];
                        if(!(data == nil))
                        {
                            // Post header image
                            NSArray * requestParameters = [NSArray arrayWithObjects:data, uploadedReview.idReview, nil];
                            
                            if([requestParameters count] == 2)
                            {
                                // Give feedback to user
                                [self stopActivityFeedback];
                                [self startActivityFeedbackWithMessage:NSLocalizedString(@"_PREPARINGFASHIONISTACONTENT_MSG_", nil)];
                                
                                [self performRestPost:UPLOAD_REVIEW_VIDEO withParamaters:requestParameters];
                                
                                
                                return;
                            }
                            else
                            {
                                NSLog(@"Uploading review video: %@", uploadedReview.text);
                                
                                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_ERROR_", nil) message:NSLocalizedString(@"_NO_REVIEWVIDEO_ERROR_MSG_", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"_OK_", nil) otherButtonTitles:nil];
                                
                                [alertView show];
                            }
                        }
                    }
                }
            }
            
            if(![self performFetchForCollectionViewWithCellType:@"ReviewCell"])
            {
                if([self initFetchedResultsControllerForCollectionViewWithCellType:@"ReviewCell" WithEntity:@"Review" andPredicate:@"idReview IN %@" inArray:_productReviews sortingWithKeys:[NSArray arrayWithObject:@"date"] ascending:NO andSectionWithKeyPath:nil])
                {
                    for(Review * review in [self getFetchedResultsControllerForCellType:@"ReviewCell"].fetchedObjects)
                    {
                        if(review.userId && ![review.userId isEqualToString:@""])
                        {
                            NSArray * requestParameters = [[NSArray alloc] initWithObjects:review.userId, nil];
                            [self performRestGet:GET_USER withParamaters:requestParameters];
                        }
                    }
                }
            }
            
            // Update collection view
            [self.secondCollectionView reloadData];
            [reviewVC initView];
            
            [self stopActivityFeedback];

            [self closeWriteReview];
            
            break;
        }
        case FINISHED_GETTHELOOK_WITHOUT_RESULTS:
        {
            [self stopActivityFeedback];
            
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_INFO_", nil) message:NSLocalizedString(@"_NO_GETTHELOOK_ERROR_MSG_", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"_OK_", nil) otherButtonTitles:nil];
            
            [alertView show];
            
            break;
        }
        case FINISHED_SEARCH_WITHOUT_RESULTS:
        {
            [self stopActivityFeedback];
            
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_INFO_", nil) message:NSLocalizedString(@"_NO_RESULTS_ERROR_MSG_", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"_OK_", nil) otherButtonTitles:nil];
            
            [alertView show];
            
            break;
        }
        case FINISHED_SEARCH_WITH_RESULTS:
        {
            // Get the number of total results that were provided
            // and the string of terms that didn't provide any results
            [mappingResult enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
             {
                 if (([obj isKindOfClass:[SearchQuery class]]))
                 {
                     searchQuery = obj;
                     
                     // Stop the enumeration
                     *stop = YES;
                 }
             }];
            
            if (searchQuery.numresults > 0)
            {
                // Get the list of results groups that were provided
                for (ResultsGroup *group in mappingResult)
                {
                    if([group isKindOfClass:[ResultsGroup class]])
                    {
                        if(!(group.idResultsGroup == nil))
                        {
                            if (!([group.idResultsGroup isEqualToString:@""]))
                            {
                                if(!([foundResultsGroups containsObject:group]))
                                {
                                    [foundResultsGroups addObject:group];
                                }
                            }
                        }
                    }
                }
                
                // Get the list of products that were provided
                for (GSBaseElement *result in mappingResult)
                {
                    if([result isKindOfClass:[GSBaseElement class]])
                    {
                        if(!(result.idGSBaseElement == nil))
                        {
                            if (!([result.idGSBaseElement isEqualToString:@""]))
                            {
                                if(!([foundResults containsObject:result.idGSBaseElement]))
                                {
                                    [foundResults addObject:result.idGSBaseElement];
                                    [similarResults addObject:result];
                                }
                            }
                        }
                    }
                }
                
                NSMutableArray *categoryTerms = [NSMutableArray new];
                // Get the keywords that provided results
                for (Keyword *keyword in mappingResult)
                {
                    if([keyword isKindOfClass:[Keyword class]])
                    {
                        if (successfulTerms == nil)
                        {
                            successfulTerms = [[NSMutableArray alloc] init];
                        }
                        
                        if(!(keyword.name == nil))
                        {
                            if (!([keyword.name isEqualToString:@""]))
                            {
                                NSString * pene = [[keyword.name lowercaseString] capitalizedString];
                                pene = [pene stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                                
                                
                                if (!([successfulTerms containsObject:pene]))
                                {
                                    if (keyword.productCategoryId != nil && ![keyword.productCategoryId isEqualToString:@""]) {
                                        CoreDataQuery * objCoreDataQuery = [CoreDataQuery sharedCoreDataQuery];
                                        ProductGroup *group = [objCoreDataQuery getProductGroupFromId:keyword.productCategoryId];
                                        [categoryTerms addObject:group.idProductGroup];
                                    }
                                    // Add the term to the set of terms
                                    [successfulTerms addObject:pene];
                                }
                            }
                        }
                        
                    }
                }
                
                // Paramters for next VC (ResultsViewController)
                Content *shownContent = [[self getFetchedResultsControllerForCellType:@"ContentCell"] objectAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
                NSArray *inspireParams = [[NSArray alloc] initWithObjects:shownContent.url, _shownProduct.preview_image_width, _shownProduct.preview_image_heigth, nil];
                NSArray * parametersForNextVC = [NSArray arrayWithObjects: searchQuery, foundResults, foundResultsGroups, successfulTerms, notSuccessfulTerms, [NSNumber numberWithBool:YES], categoryTerms, inspireParams, nil];
                
                [self stopActivityFeedback];
                
                if ([foundResults count] > 0)
                {
                    [self loadSimilarView:parametersForNextVC products:similarResults];
                    //[self transitionToViewController:SEARCH_VC withParameters:parametersForNextVC];
                }
                else
                {
                    
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_INFO_", nil) message:NSLocalizedString(@"_NO_RESULTS_ERROR_MSG_", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"_OK_", nil) otherButtonTitles:nil];
                    
                    [alertView show];
                    
                }
            }
            else
            {
                
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_INFO_", nil) message:NSLocalizedString(@"_NO_RESULTS_ERROR_MSG_", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"_OK_", nil) otherButtonTitles:nil];
                
                [alertView show];
                 
            }
            
            break;
        }
        case GET_SIMILAR_PRODUCTS:
        {
            // Get the list of features that were provided, as well as the brand and the product group
            // Then, check if the mapping contains the expected information
            [mappingResult enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
             {
                 if (([obj isKindOfClass:[Feature class]]))
                 {
                     if(!([(Feature*)(obj) name] == nil))
                     {
                         if (!([[(Feature*)(obj) name] isEqualToString:@""]))
                         {
                             if (!([_similarProductsSearchTerms containsObject:[(Feature*)(obj) name]]))
                             {
                                 [_similarProductsSearchTerms addObject:[(Feature*)(obj) name]];
                             }
                         }
                     }
                 }
             }];
            
            // Now, request the product group
            if (!(mappingResult == nil))
            {
                if ([mappingResult count] > 0)
                {
                    Product * product = ((Product *)([mappingResult objectAtIndex:0]));
                    
                    NSArray * requestParameters = [[NSArray alloc] initWithObjects:product, nil];
                    
                    [self performRestGet:GET_SIMILARPRODUCTS_GROUP withParamaters:requestParameters];
                    
                    return;
                }
            }
            
            [self stopActivityFeedback];
            
            break;
        }
        case GET_SIMILARPRODUCTS_GROUP:
        {
            // Get the list of features that were provided, as well as the brand and the product group
            // Then, check if the mapping contains the expected information
            [mappingResult enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
             {
                 if (([obj isKindOfClass:[ProductGroup class]]))
                 {
                     if(!([(ProductGroup*)(obj) name] == nil))
                     {
                         if (!([[(ProductGroup*)(obj) name] isEqualToString:@""]))
                         {
                             if (!([_similarProductsSearchTerms containsObject:[(ProductGroup*)(obj) name]]))
                             {
                                 [_similarProductsSearchTerms addObject:[(ProductGroup*)(obj) name]];
                             }
                         }
                     }
                 }
             }];

            
            // Now, request the product brand
            
            if(!(mappingResult == nil))
            {
                if([mappingResult count] > 0)
                {
                    NSString * product = (NSString *)([(Product*)([mappingResult objectAtIndex:0]) idProduct]);
                    
                    [self performRestGet:GET_SIMILARPRODUCTS_BRAND withParamaters:[NSArray arrayWithObject:product]];
                    
                    break;
                }
            }

            break;
        }
        case GET_SIMILARPRODUCTS_BRAND:
        {
            // Get the list of features that were provided, as well as the brand and the product group
            // Then, check if the mapping contains the expected information
            
            // To allow results from other brands, we discard this...
//            [mappingResult enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
//             {
//                 if (([obj isKindOfClass:[Brand class]]))
//                 {
//                     if(!([(Brand*)(obj) name] == nil))
//                     {
//                         if (!([[(Brand*)(obj) name] isEqualToString:@""]))
//                         {
//                             if (!([_similarProductsSearchTerms containsObject:[(Brand*)(obj) name]]))
//                             {
//                                 [_similarProductsSearchTerms addObject:[(Brand*)(obj) name]];
//                             }
//                         }
//                     }
//                 }
//             }];

            if(!(_similarProductsSearchTerms == nil))
            {
                if ([_similarProductsSearchTerms count] > 0)
                {
                    NSString * stringToSearch = [self composeStringhWithTermsOfArray:_similarProductsSearchTerms encoding:YES];
                    
                    NSLog(@"Performing search with terms: %@", stringToSearch);
                    
                    // Update feedback to user
                    [self stopActivityFeedback];
                    [self startActivityFeedbackWithMessage:NSLocalizedString(@"_SEARCHING_ACTV_MSG_", nil)];
                    
                    NSArray * requestParameters = [NSArray arrayWithObject:stringToSearch];
                    
                    [self performRestGet:PERFORM_SEARCH_WITHIN_PRODUCTS withParamaters:requestParameters];
                    
                    _similarProductsSearchTerms = nil;
                }
            }
            
            break;
        }
        case FINISHED_STYLESSEARCH_WITH_RESULTS:
        {
            isGettingTheLook = NO;
            // Get the number of total results that were provided
            // and the string of terms that didn't provide any results
            [mappingResult enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
             {
                 if (([obj isKindOfClass:[SearchQuery class]]))
                 {
                     searchQuery = obj;
                     
                     // Stop the enumeration
                     *stop = YES;
                 }
             }];
            
            if (searchQuery.numresults > 0)
            {
                // Get the list of results groups that were provided
                for (ResultsGroup *group in mappingResult)
                {
                    if([group isKindOfClass:[ResultsGroup class]])
                    {
                        if(!(group.idResultsGroup == nil))
                        {
                            if (!([group.idResultsGroup isEqualToString:@""]))
                            {
                                if(!([foundResultsGroups containsObject:group]))
                                {
                                    [foundResultsGroups addObject:group];
                                }
                            }
                        }
                    }
                }
                
                // Get the list of products that were provided
                for (GSBaseElement *result in mappingResult)
                {
                    if([result isKindOfClass:[GSBaseElement class]])
                    {
                        if(!(result.idGSBaseElement == nil))
                        {
                            if (!([result.idGSBaseElement isEqualToString:@""]))
                            {
                                if(!([foundResults containsObject:result.idGSBaseElement]))
                                {
                                    NSLog(@"Product Preview Image : %@", result.preview_image);
                                    [foundResults addObject:result.idGSBaseElement];
                                    [getLookResults addObject:result];
                                }
                            }
                        }
                    }
                }
                
                NSMutableArray *categoryTerms = [NSMutableArray new];
                // Get the keywords that provided results
                for (Keyword *keyword in mappingResult)
                {
                    if([keyword isKindOfClass:[Keyword class]])
                    {
                        if (successfulTerms == nil)
                        {
                            successfulTerms = [[NSMutableArray alloc] init];
                        }
                        
                        if(!(keyword.name == nil))
                        {
                            if (!([keyword.name isEqualToString:@""]))
                            {
                                NSString * pene = [[keyword.name lowercaseString] capitalizedString];
                                pene = [pene stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                                
                                
                                if (!([successfulTerms containsObject:pene]))
                                {
                                    if (keyword.productCategoryId != nil && ![keyword.productCategoryId isEqualToString:@""]) {
                                        CoreDataQuery * objCoreDataQuery = [CoreDataQuery sharedCoreDataQuery];
                                        ProductGroup *group = [objCoreDataQuery getProductGroupFromId:keyword.productCategoryId];
                                        [categoryTerms addObject:group.idProductGroup];
                                    }
                                    // Add the term to the set of terms
                                    [successfulTerms addObject:pene];
                                }
                            }
                        }
                        
                    }
                }
                
                // Paramters for next VC (ResultsViewController)
                Content *shownContent = [[self getFetchedResultsControllerForCellType:@"ContentCell"] objectAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
                NSArray *inspireParams = [[NSArray alloc] initWithObjects:shownContent.url, _shownProduct.preview_image_width, _shownProduct.preview_image_heigth, nil];
                NSArray * parametersForNextVC = [NSArray arrayWithObjects: searchQuery, foundResults, foundResultsGroups, _shownGSBaseElement, [GSBaseElement new], [NSNumber numberWithBool:YES], categoryTerms, inspireParams, nil];
                
                [self stopActivityFeedback];
                
                if ([foundResults count] > 0)
                {
					[self loadGetLookView:parametersForNextVC products:getLookResults];
                    //[self transitionToViewController:STYLES_VC withParameters:parametersForNextVC];
                }
                else
                {                 
                    [self stopActivityFeedback];
                    
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_INFO_", nil) message:NSLocalizedString(@"_NO_GETTHELOOK_ERROR_MSG_", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"_OK_", nil) otherButtonTitles:nil];
                    
                    [alertView show];
                    
                }
            }
            else
            {
                [self stopActivityFeedback];
                
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_INFO_", nil) message:NSLocalizedString(@"_NO_GETTHELOOK_ERROR_MSG_", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"_OK_", nil) otherButtonTitles:nil];
                
                [alertView show];
                
            }
            
            break;
        }
        case ADD_ITEM_TO_WARDROBE:
        {
            if ((!(buttonForHighlight == nil)))
            {
                // Change the hanger button imageç
                UIImage * buttonImage = [UIImage imageNamed:@"hanger_checked.png"];
                
                if (!(buttonImage == nil))
                {
                    [buttonForHighlight setImage:buttonImage forState:UIControlStateNormal];
                    [buttonForHighlight setImage:buttonImage forState:UIControlStateHighlighted];
                    [[buttonForHighlight imageView] setContentMode:UIViewContentModeScaleAspectFit];
                }
                
                // Reload User Wardrobes
                
                AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                
                if (!(appDelegate.currentUser == nil))
                {
                    if(!(appDelegate.currentUser.idUser == nil))
                    {
                        if(!([appDelegate.currentUser.idUser isEqualToString:@""]))
                        {
                            NSArray * requestParameters = [[NSArray alloc] initWithObjects:appDelegate.currentUser.idUser, nil];
                            
                            [self performRestGet:GET_USER_WARDROBES withParamaters:requestParameters];
                        }
                    }
                }
                
                buttonForHighlight = nil;
            }
            
            [self stopActivityFeedback];
            
            break;
        }
        case GET_FULL_POST:
        {
            User* postUser = nil;
            FashionistaPost* selectedSpecificPost = nil;
            
            // Get the post that was provided
            for (FashionistaPost *post in mappingResult)
            {
                if([post isKindOfClass:[FashionistaPost class]])
                {
                    if(!(post.idFashionistaPost == nil))
                    {
                        if  (!([post.idFashionistaPost isEqualToString:@""]))
                        {
                            selectedSpecificPost = (FashionistaPost *)post;
                            break;
                        }
                    }
                }
            }
            
            postLikesNumber = selectedSpecificPost.likesNum;
            
            resultComments = [NSMutableArray arrayWithArray:[selectedSpecificPost.comments allObjects]];
            
            NSMutableArray* postContent = [NSMutableArray arrayWithArray:[selectedSpecificPost.contents allObjects]];
            // Get the list of contents that were provided
            for (FashionistaContent *content in postContent)
            {
                [self preLoadImage:content.image];
                //[UIImage cachedImageWithURL:content.image];
            }
            
            postUser = selectedSpecificPost.author;
            
            // Paramters for next VC (ResultsViewController)
            parametersForNextVC = [NSArray arrayWithObjects: [NSNumber numberWithBool:YES], selectedSpecificPost, postContent, resultComments, [NSNumber numberWithBool:NO], postLikesNumber, postUser, nil];
            
            if((!([parametersForNextVC count] < 2)) && ([postContent count] > 0))
            {
                [self transitionToViewController:FASHIONISTAPOST_VC withParameters:parametersForNextVC];
            }
            [self stopActivityFeedback];
            break;
        }


        default:
            break;
    }
}

// OVERRIDE: Rest answer not reached, to control if the answer fails when getting similar products
- (void)processRestConnection: (connectionType)connection WithErrorMessage:(NSArray*)errorMessage forOperation:(RKObjectRequestOperation *)operation
{
    switch (connection)
    {
        case GET_PRODUCT_FEATURES:
        {
            // Check that there's actually a product to search its features
            if (!(_shownProduct == nil))
            {
                if (!(_shownProduct.idProduct == nil))
                {
                    if (!([_shownProduct.idProduct isEqualToString:@""]))
                    {
                        NSArray * requestParameters = [[NSArray alloc] initWithObjects:_shownProduct, nil];
                        
                        [self performRestGet:GET_PRODUCT_GROUP withParamaters:requestParameters];
                        
                        return;
                    }
                }
            }

            // Update the Product Info view
            
            if([_shownProductFeatureTerms count] > 0)
            {
                // There were results!
                _productInfoTextView.text = [NSString stringWithFormat:@"%@: %@\n\n%@", NSLocalizedString(@"_PRODUCTTAGS_", nil), [self composeStringhWithTermsOfArray:_shownProductFeatureTerms], _shownProduct.information];
            }
            
            [self stopActivityFeedback];
            
            break;
        }
        case GET_PRODUCT_GROUP:
        {
            // Check that there's actually a product to search its features
            if (!(_shownProduct == nil))
            {
                if (!(_shownProduct.idProduct == nil))
                {
                    if (!([_shownProduct.idProduct isEqualToString:@""]))
                    {
                        NSArray * requestParameters = [[NSArray alloc] initWithObjects:_shownProduct, nil];
                        
                        [self performRestGet:GET_PRODUCT_BRAND withParamaters:requestParameters];
                        
                        return;
                    }
                }
            }

            // Update the Product Info view
            
            if([_shownProductFeatureTerms count] > 0)
            {
                // There were results!
                _productInfoTextView.text = [NSString stringWithFormat:@"%@: %@\n\n%@", NSLocalizedString(@"_PRODUCTTAGS_", nil), [self composeStringhWithTermsOfArray:_shownProductFeatureTerms], _shownProduct.information];
            }

            [self stopActivityFeedback];
            
            break;
        }
        case GET_PRODUCT_BRAND:
        {
            // Update the Product Info view
            
            if([_shownProductFeatureTerms count] > 0)
            {
                // There were results!
                _productInfoTextView.text = [NSString stringWithFormat:@"%@: %@\n\n%@", NSLocalizedString(@"_PRODUCTTAGS_", nil), [self composeStringhWithTermsOfArray:_shownProductFeatureTerms], _shownProduct.information];
            }

            [self stopActivityFeedback];
            
            break;
        }
        case GET_SIMILAR_PRODUCTS:
        {
            // Check that there's actually a product to search its features
            if(!(_shownProduct == nil))
            {
                if (!(_shownProduct.idProduct == nil))
                {
                    if (!([_shownProduct.idProduct isEqualToString:@""]))
                    {
                        if(_similarProductsSearchTerms == nil)
                        {
                            _similarProductsSearchTerms = [[NSMutableArray alloc] init];
                        }
                       
                        // Try getting the product group
                        NSArray * requestParameters = [[NSArray alloc] initWithObjects:_shownProduct, nil];
                        
                        [self performRestGet:GET_SIMILARPRODUCTS_GROUP withParamaters:requestParameters];
                        
                        return;
                    }
                }
            }
            
            [self stopActivityFeedback];
            
            break;
        }
        case GET_SIMILARPRODUCTS_GROUP:
        {
            // Check that there's actually a product to search its features
            if(!(_shownProduct == nil))
            {
                if (!(_shownProduct.idProduct == nil))
                {
                    if (!([_shownProduct.idProduct isEqualToString:@""]))
                    {
                        if(_similarProductsSearchTerms == nil)
                        {
                            _similarProductsSearchTerms = [[NSMutableArray alloc] init];
                        }
                        
                        NSArray * requestParameters = [[NSArray alloc] initWithObjects:_shownProduct, nil];
                        
                        [self performRestGet:GET_SIMILARPRODUCTS_BRAND withParamaters:requestParameters];
                    }
                }
            }
            
            break;
        }
        case GET_SIMILARPRODUCTS_BRAND:
        {
            if(!(_similarProductsSearchTerms == nil))
            {
                if ([_similarProductsSearchTerms count] > 0)
                {
                    NSString * stringToSearch = [self composeStringhWithTermsOfArray:_similarProductsSearchTerms encoding:YES];
                    
                    // Update feedback to user
                    [self stopActivityFeedback];
                    [self startActivityFeedbackWithMessage:NSLocalizedString(@"_SEARCHING_ACTV_MSG_", nil)];
                    
                    NSArray * requestParameters = [NSArray arrayWithObject:stringToSearch];
                    
                    [self performRestGet:PERFORM_SEARCH_WITHIN_PRODUCTS withParamaters:requestParameters];
                    
                    _similarProductsSearchTerms = nil;
                }
            }
            
            break;
        }
        default:
            
            [super processRestConnection:connection WithErrorMessage:errorMessage forOperation:operation];
            
            break;
    }
}

- (IBAction)onTapProductInfo:(UIButton *)sender
{
    self.productInfoView.hidden = NO;
    [self.ProductBottomView bringSubviewToFront:self.productInfoView];
    [self bringBottomControlsToFront];
    [self bringTopBarToFront];
    
    [UIView transitionWithView:self.productInfoView
                      duration:0.5
                       options:UIViewAnimationOptionTransitionCrossDissolve//UIViewAnimationOptionTransitionNone
                    animations:nil
                    completion:^(BOOL finished){
                        self.menuView.hidden = YES;
                    }];
}

- (IBAction)onTapCloseProductInfo:(UIButton *)sender
{
    [self dismissViewController];
}

- (IBAction)onTapAvailability:(UIButton *)sender
{
    self.availabilityView.hidden = NO;
    [self.ProductBottomView bringSubviewToFront:self.availabilityView];
    [self bringBottomControlsToFront];
    [self bringTopBarToFront];
    
    [UIView transitionWithView:self.availabilityView
                      duration:0.5
                       options:UIViewAnimationOptionTransitionCrossDissolve//UIViewAnimationOptionTransitionNone
                    animations:nil
                    completion:^(BOOL finished){
                        self.menuView.hidden = YES;
                    }];
}

-(void)onTapSeeMoreInfo:(NSString *)str {
	SeeMoreView *seemoreView = [self.storyboard instantiateViewControllerWithIdentifier:@"SeeMoreVC"];
	seemoreView.infoStr = str;
	seemoreView.modalPresentationStyle = UIModalPresentationOverCurrentContext;
	[self presentViewController:seemoreView animated:YES completion:nil];
}

- (IBAction)onTapCloseSeeMore:(id)sender {
	_seeMoreView.hidden = YES;
}


- (IBAction)onTapCloseAvailability:(UIButton *)sender
{
    [self dismissViewController];
}

- (IBAction)onTapReviews:(UIButton *)sender
{
    self.reviewsView.hidden = NO;
    [self.ProductBottomView bringSubviewToFront:self.reviewsView];
    [self bringBottomControlsToFront];
    [self bringTopBarToFront];
    
    [UIView transitionWithView:self.reviewsView
                      duration:0.5
                       options:UIViewAnimationOptionTransitionCrossDissolve//UIViewAnimationOptionTransitionNone
                    animations:nil
                    completion:^(BOOL finished){
                        self.menuView.hidden = YES;
                    }];
}
- (IBAction)onTapCloseReviews:(UIButton *)sender
{
    [self dismissViewController];
}

- (IBAction)onTapFollow:(id)sender {
	AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
	
	if (!_isFollowing) {
		setFollow * newFollow = [[setFollow alloc] init];
		
		[newFollow setFollow:_shownProduct.profile_brand];
		
		NSArray * requestParameters = [[NSArray alloc] initWithObjects:appDelegate.currentUser.idUser, newFollow, nil];
		
		[self performRestPost:FOLLOW_USER withParamaters:requestParameters];
	}
	else {
		unsetFollow * newUnsetFollow = [[unsetFollow alloc] init];
		
		[newUnsetFollow setUnfollow:_shownProduct.profile_brand];
		
		NSArray * requestParameters = [[NSArray alloc] initWithObjects:appDelegate.currentUser.idUser, newUnsetFollow, nil];
		
		[self performRestPost:UNFOLLOW_USER withParamaters:requestParameters];
	}
	
	_isFollowing = !_isFollowing;
}


- (IBAction)onTapPurchase:(UIButton *)sender
{
    
    NSString *urlStr = (((self.shownProduct.url != nil) && (!([self.shownProduct.url isEqualToString:@""]))) ? (self.shownProduct.url) : (((self.shownProduct.brand.url != nil) && (!([self.shownProduct.brand.url isEqualToString:@""]))) ? (self.shownProduct.brand.url) : (nil)));
    
    if(!(urlStr == nil))
    {
        if(!([urlStr isEqualToString:@""]))
        {
            urlStr = [urlStr stringByReplacingOccurrencesOfString:@"\\n" withString:@""];
            urlStr = [urlStr stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];
            
//            NSInteger colon = [urlStr rangeOfString:@":"].location;
//            
//            if (colon != NSNotFound)
//            {
//                urlStr = [urlStr substringFromIndex:colon]; // strip off existing scheme
//
//                urlStr = [@"https" stringByAppendingString:urlStr];
//            }

            NSURL * url = [NSURL URLWithString:urlStr];
            
            [self setWebsiteScreenTopBottom:url.host];
            [self showAvailabilityDetailViewWithURLString:urlStr];

            // purchase statistics
            [self uploadProductPurchase];
            
            return;
        }
        
    }
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_PRODUCT_WEBSITE_", nil) message:NSLocalizedString(@"_WEBSITENOAVAILABLE_MSG_", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"_OK_", nil) otherButtonTitles:nil];
    
    [alertView show];
    // Not yet implemented!
    //UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_INFO_", nil) message:NSLocalizedString(@"_NOTYETIMPLMENETED_MSG_", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"_OK_", nil) otherButtonTitles:nil];
    
    //[alertView show];
}

-(void)onTapWebSite {
    [self onTapPurchase:nil];
}

- (IBAction)onTapFindSimilar:(UIButton *)sender
{
    if(!(_addingProductsToWardrobeID == nil))
    {
        return;
    }
    
    if(!([_addToWardrobeVCContainerView isHidden]))
    {
        return;
    }
    
    if(!([_availabilityVCContainerView isHidden]))
    {
        return;
    }
    
    if (!self.writeReviewView.hidden)
    {
        [self closeWriteReview];
        [self actionForMainFirstCircleMenuEntry];

//        // Check that the review has some text
//        if ([self.reviewTextView.text length] == 0)
//        {
//            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Product review", nil) message:NSLocalizedString(@"Please fill your review with some text!", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
//            
//            [alertView show];
//        }
//        else
//        {
//            [self.writeReviewView endEditing:YES];
//            
//            [self uploadReview];
//        }
    }
    else
    {
        //[super rightAction:sender];
        [self actionForMainFirstCircleMenuEntry];
    }
}

- (IBAction)onTapProductImage:(UITapGestureRecognizer *)sender
{
    int iIdx = productImageVC.currentIndex;
    NYTExamplePhotoProd *selectedPhoto = nil;
    
    NSMutableArray * photos = [[NSMutableArray alloc]init];
    
    for (int i = 0; i < [self getFetchedResultsControllerForCellType:@"ContentCell"].fetchedObjects.count; i++)
    {
        
        Content * content = [[self getFetchedResultsControllerForCellType:@"ContentCell"].fetchedObjects objectAtIndex:i];
        
        if (!(content == nil))
        {
            if(content.url != nil)
            {
                NYTExamplePhotoProd *photo = [[NYTExamplePhotoProd alloc] init];
                photo.image =[UIImage cachedImageWithURL:content.url];
                
                if(iIdx == i)
                    selectedPhoto = photo;
                
                [photos addObject:photo];
            }
        }
    }
    
    if(selectedPhoto)
    {
        NYTPhotosViewController *photosViewController = [[NYTPhotosViewController alloc] initWithPhotos:photos initialPhoto:selectedPhoto];
        [self presentViewController:photosViewController animated:YES completion:nil];
    }
    else
    {
        NYTPhotosViewController *photosViewController = [[NYTPhotosViewController alloc] initWithPhotos:photos];
        [self presentViewController:photosViewController animated:YES completion:nil];
    }
    
    
    
    return;
    
    /*
    //Load the request in the UIWebView.
    //[[_webViewArray objectAtIndex:self.iSelectedContent] loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:_tempImagePath]]];
    
    // Ocultamos todos los webviews
    for(NSInteger i = 0; i < _webViewArray.count; i++)
    {
        UIWebView * webView = [_webViewArray objectAtIndex:i];
        webView.hidden = YES;
    }
    
    if (!(_webViewArray == nil))
    {
        if (!(self.iSelectedContent >= [_webViewArray count]))
        {
            UIWebView * webView = [_webViewArray objectAtIndex:self.iSelectedContent] ;
            
            CGSize contentSize = webView.scrollView.contentSize;
            //CGSize viewSize = self.view.bounds.size;

            
            contentSize.width += 10.0f;
            [webView.scrollView setContentSize:contentSize];
            webView.scrollView.scrollEnabled = TRUE;
            webView.scalesPageToFit = TRUE;
            
//            CGPoint bottomOffset = CGPointMake(0, webView.scrollView.contentSize.height - webView.scrollView.bounds.size.height);
//            [webView.scrollView setContentOffset:bottomOffset animated:NO];
            
            webView.hidden = NO;

//            UIScrollView * scrollView = [_webViewArray objectAtIndex:self.iSelectedContent] ;
//            
//            scrollView.scrollEnabled = TRUE;
//            
//            scrollView.hidden = NO;
            
            self.zoomView.hidden = NO;
            [self.view bringSubviewToFront:self.zoomView];
            [self bringBottomControlsToFront];
            [self bringTopBarToFront];
            
            [UIView transitionWithView:self.view
                              duration:0.5
                               options:UIViewAnimationOptionTransitionCrossDissolve//UIViewAnimationOptionTransitionNone
                            animations:nil
                            completion:^(BOOL finished){
                                self.infoView.hidden = YES;
                            }];
        }
    }
*/
}

- (IBAction)onTapAddToWardrobe:(UIButton *)sender
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if ((appDelegate.currentUser == nil))
    {
        // Must be logged!
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_INFO_", nil) message:NSLocalizedString(@"_MUSTBELOGGED_MSG_", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"_OK_", nil) otherButtonTitles:nil];
        
        [alertView show];
        
        return;
    }
    
    if (!appDelegate.completeUser) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_PROFILE_COMPLETE_ERROR_",nil)
                                                        message:NSLocalizedString(@"_PROFILE_COMPLETE_MSG",nil)
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"_OK_",nil)
                                              otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    if (!(_addingProductsToWardrobe == nil))
    {
        for (NSString *itemId in _addingProductsToWardrobe.itemsId)
        {
            if([itemId isEqualToString:_shownGSBaseElement.idGSBaseElement])
            {
                /*
                // Item already in wardrobe!
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_INFO_", nil) message:NSLocalizedString(@"_ITEMALREADYINWARDROBE_MSG_", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"_OK_", nil) otherButtonTitles:nil];
                
                [alertView show];
                */
                return;
            }
        }
        
        buttonForHighlight = sender;
        
        [self addItem:_shownGSBaseElement toWardrobeWithID:_addingProductsToWardrobe.idWardrobe];
    }
    else if (!([self doesCurrentUserWardrobesContainProductWithId:_shownProduct.idProduct]))
    {
        // Instantiate the 'AddProductToWardrobe' view controller within the container view
        
        if ([UIStoryboard storyboardWithName:@"Wardrobe" bundle:nil] != nil)
        {
            AddItemToWardrobeViewController *addItemToWardrobeVC = nil;
            
            @try {
                
                addItemToWardrobeVC = [[UIStoryboard storyboardWithName:@"Wardrobe" bundle:nil] instantiateViewControllerWithIdentifier:[@(ADDITEMTOWARDROBE_VC) stringValue]];
                
            }
            @catch (NSException *exception) {
                
                return;
                
            }
            
            if (addItemToWardrobeVC != nil)
            {
                [addItemToWardrobeVC setItemToAdd:_shownGSBaseElement];
                
                [addItemToWardrobeVC setButtonToHighlight:sender];
                
                [self addChildViewController:addItemToWardrobeVC];
                
                //[addProductToWardrobeVC willMoveToParentViewController:self];
                
                addItemToWardrobeVC.view.frame = CGRectMake(0,0,_addToWardrobeVCContainerView.frame.size.width, _addToWardrobeVCContainerView.frame.size.height);
                
                [_addToWardrobeVCContainerView addSubview:addItemToWardrobeVC.view];
                
                [addItemToWardrobeVC didMoveToParentViewController:self];
                
                [_addToWardrobeVCContainerView setHidden:NO];
                
                [_addToWardrobeBackgroundView setHidden:NO];
                
                [self.view bringSubviewToFront:_addToWardrobeBackgroundView];
                
                [self.view bringSubviewToFront:_addToWardrobeVCContainerView];
            }
        }
    }
}

- (void)closeAddingItemToWardrobeHighlightingButton:(UIButton *)button withSuccess:(BOOL)bSuccess
{
    if((bSuccess) && (!(button == nil)))
    {
        // Change the hanger button imageç
        UIImage * buttonImage = [UIImage imageNamed:@"wardrobeselected.png"];
        
        if (!(buttonImage == nil))
        {
//            [button setImage:buttonImage forState:UIControlStateNormal];
//           // [button setImage:buttonImage forState:UIControlStateHighlighted];
//            [[button imageView] setContentMode:UIViewContentModeScaleAspectFit];
            [self.wardrobeButton setBackgroundImage:buttonImage forState:UIControlStateNormal];
//            //[self.wardrobeButton setImage:buttonImage forState:UIControlStateHighlighted];
           // [[self.wardrobeButton imageView] setContentMode:UIViewContentModeScaleAspectFit];
//            _wardrobeButton.alpha = 0.5;

        }
    }
    
    [[self.childViewControllers lastObject] willMoveToParentViewController:nil];
    
    [[_addToWardrobeVCContainerView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    [[self.childViewControllers lastObject] removeFromParentViewController];
    
    //[[self.childViewControllers lastObject] didMoveToParentViewController:nil];
    
    [_addToWardrobeVCContainerView setHidden:YES];
    
    [_addToWardrobeBackgroundView setHidden:YES];
}


// OVERRIDE: Just to prevent from being at the 'Add to Wardrobe' view
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if(!([_addToWardrobeVCContainerView isHidden]))
        return;

    if(!([_availabilityVCContainerView isHidden]))
        return;
    
    [super touchesEnded:touches withEvent:event];
    
}

// Add items to wardrobe
- (void)addItem:(GSBaseElement *)itemToAdd toWardrobeWithID:(NSString *)wardrobeID
{
    if (!(itemToAdd == nil))
    {
        NSLog(@"Adding item to wardrobe: %@", wardrobeID);
        
        // Perform request to save the item into the wardrobe
        
        // Provide feedback to user
        [self stopActivityFeedback];
        [self startActivityFeedbackWithMessage:NSLocalizedString(@"_ADDINGITEMTOWARDROBE_MSG_", nil)];
        
        NSArray * requestParameters = [[NSArray alloc] initWithObjects:wardrobeID, itemToAdd, nil];
        
        [self performRestPost:ADD_ITEM_TO_WARDROBE withParamaters:requestParameters];
    }
}

- (IBAction)onTapWriteReview
{
    
    if(!(_addingProductsToWardrobeID == nil))
    {
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_ADDING_PRODUCTS_TO_CONTENT_WARDROBE_", nil) message:NSLocalizedString(@"_ADDING_PRODUCTS_TO_CONTENT_WARDROBE_MSG_", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"_OK_", nil) otherButtonTitles:nil];
        
        [alertView show];
        
        return;
    }

    
    // Limipiamos el dialogo
    _temporalReviewURL = @"";
    //RateView *rateView;
    [_overallRateView setRating:3.0];
    [_qualityRateView setRating:3.0];
    [_comfortRateView setRating:3.0];
    _reviewTextView.text = @"";
    _addVideoToReviewButton.titleLabel.text = NSLocalizedString(@"_ADD_REVIEW_VIDEO_", nil);
    
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if (appDelegate.currentUser == nil)
    {
        // if it is, then sign out. Because of the menu, is sign out
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Log in", nil) message:NSLocalizedString(@"You have to log in to write a review", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Not now", nil) otherButtonTitles:NSLocalizedString(@"Log in", nil), nil];
        
        [alertView show];
        
        
        return;
        // show white view
        
    }
    
    // Initialize objects to get location data
    locationManager = [[CLLocationManager alloc] init];
    geocoder = [[CLGeocoder alloc] init];
   
    self.writeReviewView.hidden = NO;
    [self.view bringSubviewToFront:self.writeReviewView];
    [self bringBottomControlsToFront];
    [self bringTopBarToFront];
    
    [UIView transitionWithView:self.writeReviewView
                      duration:0.5
                       options:UIViewAnimationOptionTransitionCrossDissolve//UIViewAnimationOptionTransitionNone
                    animations:^ {

                    }
                    completion:^(BOOL finished){
                        self.infoView.hidden = YES;
                        [self setReviewScreenTopBottom];
                        
                        [self getCurrentLocation];
                    }];

}

- (IBAction)onTapShowVideoReviews:(UIButton*)sender
{
    Review * review = [[self getFetchedResultsControllerForCellType:@"ReviewCell"] objectAtIndexPath:[NSIndexPath indexPathForItem:sender.tag inSection:0]];

    if(review)
    {
        NSString * moviePath = review.video;
        if (moviePath)
        {
            [self uploadReviewProductsView:review];
            
            AVPlayer * player = [AVPlayer playerWithURL:[NSURL URLWithString:moviePath]];
            AVPlayerViewController *playerViewController = [AVPlayerViewController new];
            playerViewController.player = player;
            [playerViewController.player play];
            [self presentViewController:playerViewController animated:YES completion:nil];
        }
    }
}

- (IBAction)onTapAddVideoToReview:(UIButton *)sender
{
    if(_temporalReviewURL && ![_temporalReviewURL isEqualToString:@""])
    {
        _reviewTextSpaceConstraint.constant = 125;
        
        
        [UIView animateWithDuration:0.30
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^ {
                             self.player.view.alpha = 0.0;
                             self.reviewTextSpaceConstraint.constant = 125;
                             [self.view layoutIfNeeded];
                         }
                         completion:^(BOOL finished) {
                             UIView * pView = self.player.view;
                             [pView removeFromSuperview];
                             self.player = nil;
                         }];
        
        _temporalReviewURL = @"";
        _addVideoToReviewButton.titleLabel.text = NSLocalizedString(@"_ADD_REVIEW_VIDEO_", nil);
    }
    else
    {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"_SELECT_SOURCE_PHOTO_",nil) delegate:self cancelButtonTitle:NSLocalizedString(@"_CANCEL_", nil) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"_TAKE_VIDEO_", nil), NSLocalizedString(@"_CHOOSE_VIDEO_", nil), nil];
    
        [actionSheet showInView:[UIApplication sharedApplication].keyWindow];
    }
}
- (IBAction)onTapCancelReview:(id)sender {
    [self dismissViewController];
}
- (IBAction)onTapUploadReview:(id)sender {
    if (!self.writeReviewView.hidden)
    {
        // Check that the review has some text
        if ([self.reviewTextView.text length] == 0)
        {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Product review", nil) message:NSLocalizedString(@"Please fill your review with some text!", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
            
            [alertView show];
        }
        else
        {
            [self.writeReviewView endEditing:YES];
            
            [self uploadReview];
            
            NSString * key = [NSString stringWithFormat:@"HIGHLIGHTSUBMIT_%d", [self.restorationIdentifier intValue]];
            
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            
            // Save into defaults if doesn't already exists
            if (!([defaults objectForKey:key]))
            {
                [defaults setInteger:1 forKey:key];
                
                [defaults synchronize];
            }
            else
            {
                int iNumHighlights = (int)[defaults integerForKey:key];
                
                [defaults setInteger:(iNumHighlights+1) forKey:key];
                
                [defaults synchronize];
            }
        }
    }

}

- (IBAction)onTapOpenWebsite:(UIButton *)sender
{
    NSString *urlStr = ((self.shownProduct.url!=nil) ? (self.shownProduct.url) : (self.shownProduct.brand.url));
    
    if(!(urlStr == nil))
    {
        if(!([urlStr isEqualToString:@""]))
        {
            urlStr = [urlStr stringByReplacingOccurrencesOfString:@"\\n" withString:@""];
            urlStr = [urlStr stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];
            
            NSURL * url = [NSURL URLWithString:urlStr];
            
            [self setWebsiteScreenTopBottom:url.host];
            [self showAvailabilityDetailViewWithURLString:urlStr];
            
            return;
        }
        
    }
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_PRODUCT_WEBSITE_", nil) message:NSLocalizedString(@"_WEBSITENOAVAILABLE_MSG_", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"_OK_", nil) otherButtonTitles:nil];
    
    [alertView show];
}

- (IBAction)onTapShowMap:(UIButton *)sender
{
    if(!(_addingProductsToWardrobeID == nil))
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_ADDING_PRODUCTS_TO_CONTENT_WARDROBE_", nil) message:NSLocalizedString(@"_ADDING_PRODUCTS_TO_CONTENT_WARDROBE_MSG_", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"_OK_", nil) otherButtonTitles:nil];
        
        [alertView show];
        
        return;
    }

    [self setWebsiteScreenTopBottom:@"Nearest store"];

    NSString *urlStr = [NSString stringWithFormat:@"https://www.google.com/maps/search/%@/",self.shownProduct.brand.name];
    
    if (!(urlStr == nil))
    {
        if (!([urlStr isEqualToString:@""]))
        {
            if(!NSEqualRanges( [urlStr rangeOfString:@" "], NSMakeRange(NSNotFound, 0) ) )
            {
                urlStr = [urlStr stringByReplacingOccurrencesOfString:@" " withString:@"+"];
            }
            
            [self showAvailabilityDetailViewWithURLString:urlStr];

            return;
        }
    }
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_NEAREST_STORE_", nil) message:NSLocalizedString(@"_STORENOAVAILABLE_MSG_", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"_OK_", nil) otherButtonTitles:nil];
    
    [alertView show];
}

#pragma - markup TableView Delegate Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section

{
    if(self.bShowWebShops)
        return 1;
    else
        return 0;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath

{
    
    static NSString *simpleTableIdentifier = @"ShopCell";
    
    ShopsCell *cell = (ShopsCell*)[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil) {
        
        cell = (ShopsCell*)[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
        
    }
    
    //cell.shopNameLabel.text = (([_shownProduct.url isEqualToString:@""]) ? (([_shownProduct.brand.url isEqualToString:@""]) ? (NSLocalizedString(@"_STORENOAVAILABLE_MSG_", nil)) : (_shownProduct.brand.url)) : (_shownProduct.url));
    if(_shownProduct.brand && [_shownProduct.brand.url isEqualToString:@""])
    {
        // No tenemos brand url, que es nuestra prioridad
        if([_shownProduct.url isEqualToString:@""])
        {
            // Tampoco tenemos url de producto!
            cell.shopNameLabel.text = (NSLocalizedString(@"_STORENOAVAILABLE_MSG_", nil));
        }
        else
        {
            cell.shopNameLabel.text = _shownProduct.url;
        }
    }
    else
    {
        cell.shopNameLabel.text = _shownProduct.brand.url;
    }
    
    cell.priceLabel.text = NSLocalizedString(@"_PRICE_NOT_AVAILABLE_", nil);
    
    if (!(_shownProduct.recommendedPrice == nil))
    {
        cell.priceLabel.text = [NSString stringWithFormat:@"$%.2f", [_shownProduct.recommendedPrice floatValue]];
    }
    
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath

{
    if(!(_addingProductsToWardrobeID == nil))
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_ADDING_PRODUCTS_TO_CONTENT_WARDROBE_", nil) message:NSLocalizedString(@"_ADDING_PRODUCTS_TO_CONTENT_WARDROBE_MSG_", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"_OK_", nil) otherButtonTitles:nil];
        
        [alertView show];
        
        return;
    }

    NSString *urlStr = ((self.shownProduct.url!=nil)? (self.shownProduct.url) : (self.shownProduct.brand.url));
    
    if(!(urlStr == nil))
    {
        if(!([urlStr isEqualToString:@""]))
        {
            urlStr = [urlStr stringByReplacingOccurrencesOfString:@"\\n" withString:@""];
            urlStr = [urlStr stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];
            
            NSURL * url = [NSURL URLWithString:urlStr];
            
            [self setWebsiteScreenTopBottom:url.host];
            [self showAvailabilityDetailViewWithURLString:urlStr];
            
            return;
        }
        
    }
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_PRODUCT_WEBSITE_", nil) message:NSLocalizedString(@"_WEBSITENOAVAILABLE_MSG_", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"_OK_", nil) otherButtonTitles:nil];
    
    [alertView show];
}


- (IBAction)onTapAvailabilityAll:(UIButton *)sender
{
    self.bShowWebShops = true;
    self.bShowInStoreShops = true;
    [self.availabilityTableView reloadData];
}

- (IBAction)onTapAvailabilityWeb:(UIButton *)sender
{
    self.bShowWebShops = true;
    self.bShowInStoreShops = false;
    [self.availabilityTableView reloadData];
}

- (IBAction)onTapAvailabilityInStore:(UIButton *)sender
{
    self.bShowWebShops = false;
    self.bShowInStoreShops = true;
    [self.availabilityTableView reloadData];
}

- (IBAction)onTapLeftImage:(id)sender {
    if (currentPageIndex == (7 - (!(hasVariant)) - (!(hasSize)) - (!(hasAvailability)))) {
        NSLog(@"Can't Slide Product Image");
    }
    else {
        NSLog(@"On Tap Left image Button");
        [productImageVC swipePreview:NO];
    }
}

- (IBAction)onTapRightImage:(id)sender {
    if (currentPageIndex == (7 - (!(hasVariant)) - (!(hasSize)) - (!(hasAvailability)))) {
        NSLog(@"Can't Slide Product Image");
    }
    else {
        NSLog(@"On Tap Right Image Button");
        [productImageVC swipePreview:YES];
    }
}

-(void)onTapShare:(NSInteger)index {
	UIImage *imageToShare = [UIImage imageNamed:@"Logo.png"];
	
	NSString *messageToShare = NSLocalizedString(@"_SHARE_GENERIC_MSG_", nil);
	
	NSURL * urlToShare = [NSURL URLWithString:NSLocalizedString(@"_SHARE_GENERIC_URL_", nil)];
	
	switch (index) {
		case FACEBOOK:
			if([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook])
			{
				SLComposeViewController *facebookController=[SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
				
				SLComposeViewControllerCompletionHandler __block completionHandler=^(SLComposeViewControllerResult result){
					
					[facebookController dismissViewControllerAnimated:YES completion:nil];
					
					switch(result)
					{
						case SLComposeViewControllerResultDone:
						{
							NSLog(@"Shared...");
							[self afterSharedIn:@"facebook"];
							break;
						}
						case SLComposeViewControllerResultCancelled:
						default:
						{
							NSLog(@"Cancelled...");
							
							break;
						}
					}};
				
				UIPasteboard *pasteBoard = [UIPasteboard generalPasteboard];
				pasteBoard.string = messageToShare;
				
				[facebookController setInitialText:messageToShare];
				[facebookController addImage:imageToShare];
				[facebookController addURL:urlToShare];
				[facebookController setCompletionHandler:completionHandler];
				[self presentViewController:facebookController animated:YES completion:nil];
			}
			else
			{
				UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_FACEBOOK_",nil)
																message:NSLocalizedString(@"_SOCIALNETWORKNOTAVAILABLE_",nil)
															   delegate:self
													  cancelButtonTitle:NSLocalizedString(@"_OK_",nil)
													  otherButtonTitles:nil];
				[alert show];
			}
			
			self.currentSharedObject = nil;
			self.currentPreviewImage = nil;
			break;
		case TWITTER:
			if([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter])
			{
				SLComposeViewController *twitterController=[SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
				
				SLComposeViewControllerCompletionHandler __block completionHandler=^(SLComposeViewControllerResult result){
					
					[twitterController dismissViewControllerAnimated:YES completion:nil];
					
					switch(result)
					{
						case SLComposeViewControllerResultDone:
						{
							NSLog(@"Shared...");
							[self afterSharedIn:@"twitter"];
							break;
						}
						case SLComposeViewControllerResultCancelled:
						default:
						{
							NSLog(@"Cancelled...");
							
							break;
						}
					}};
				
				UIPasteboard *pasteBoard = [UIPasteboard generalPasteboard];
				pasteBoard.string = messageToShare;
				
				[twitterController setInitialText:messageToShare];
				[twitterController addURL:urlToShare];
				[twitterController setCompletionHandler:completionHandler];
				[self presentViewController:twitterController animated:YES completion:nil];
			}
			else
			{
				UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_TWITTER_",nil)
																message:NSLocalizedString(@"_SOCIALNETWORKNOTAVAILABLE_",nil)
															   delegate:self
													  cancelButtonTitle:NSLocalizedString(@"_OK_",nil)
													  otherButtonTitles:nil];
				[alert show];
			}
			
			self.currentSharedObject = nil;
			self.currentPreviewImage = nil;
			break;
		case INSTAGRAM:
			if([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"instagram://"]])
			{
				NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
				
				NSString *documentsPath = [paths objectAtIndex:0];
				
				NSString* savePath = [documentsPath stringByAppendingPathComponent:@"imageToShare.igo"];
				
				BOOL result = NO;
				
				@autoreleasepool {
					
					NSData *imageData = UIImageJPEGRepresentation(imageToShare, 0.5);
					result = [imageData writeToFile:savePath atomically:YES];
					imageData = nil;
				}
				
				if(result)
				{
					self.docController = [UIDocumentInteractionController interactionControllerWithURL:[NSURL fileURLWithPath:savePath]];
					
					[self.docController setDelegate:self];
					
					[self.docController setUTI:@"com.instagram.exclusivegram"];
					
					[self.docController setAnnotation:@{@"InstagramCaption" : [NSString stringWithFormat:@"%@ %@", messageToShare, urlToShare]}];
					
					UIPasteboard *pasteBoard = [UIPasteboard generalPasteboard];
					pasteBoard.string = [NSString stringWithFormat:@"%@ %@", messageToShare, urlToShare];
					
					[self.docController presentOpenInMenuFromRect:CGRectZero inView:self.view animated:YES];
				}
				else
				{
					NSError *error = nil;
					
					NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
					
					NSString *documentsPath = [paths objectAtIndex:0];
					
					NSString* deletePath = [documentsPath stringByAppendingPathComponent:@"imageToShare.igo"];
					
					if (![[NSFileManager defaultManager] removeItemAtPath:deletePath error:&error])
					{
						NSLog(@"Error cleaning up temporary image file: %@", error);
					}
					
					self.currentSharedObject = nil;
					self.currentPreviewImage = nil;
					
					UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_INSTAGRAM_",nil)
																	message:NSLocalizedString(@"_CANTSHAREIMAGE_",nil)
																   delegate:self
														  cancelButtonTitle:NSLocalizedString(@"_OK_",nil)
														  otherButtonTitles:nil];
					[alert show];
				}
			}
			else
			{
				UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_INSTAGRAM_",nil)
																message:NSLocalizedString(@"_SOCIALNETWORKNOTAVAILABLE_",nil)
															   delegate:self
													  cancelButtonTitle:NSLocalizedString(@"_OK_",nil)
													  otherButtonTitles:nil];
				[alert show];
			}
			
			self.currentSharedObject = nil;
			self.currentPreviewImage = nil;
			break;
        case MESSAGE:
        case MMS:
        case EMAIL:
        case PINTEREST:
        case LINKEDIN:
        case SNAPCHAT:
        case TUMBLR:
        case FLIKER:
            {
                // items to share
                NSArray *sharingItems =  @[messageToShare, imageToShare, urlToShare];
            
                // create the controller
                UIActivityViewController *activityVC = [[UIActivityViewController alloc]initWithActivityItems:sharingItems applicationActivities:nil];
            
                NSArray *excludeActivities = @[UIActivityTypeAirDrop,
                                           UIActivityTypePrint,
                                           UIActivityTypeCopyToPasteboard,
                                           UIActivityTypeAssignToContact,
                                           UIActivityTypeSaveToCameraRoll,
                                           UIActivityTypeAddToReadingList,
                                           UIActivityTypePostToFacebook,
                                           UIActivityTypePostToTwitter,
                                           ];
            
            
                activityVC.excludedActivityTypes = excludeActivities;
            
                activityVC.completionWithItemsHandler = ^(NSString *act, BOOL done, NSArray *returnedItems, NSError *activityError)
                {
                    if ( done )
                    {
                        NSLog(@"Shared in %@", act);
                    
                        [self afterSharedIn:act];
                    }
                };
            
                [self presentViewController:activityVC animated:YES completion:nil];
            }
            
            self.currentSharedObject = nil;
            self.currentPreviewImage = nil;
            break;
		default:
			break;
	}
}

-(void)onTapAddtoWardrobeButton:(UIButton *)sender isSimilar:(BOOL)isSimilar {
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if ((appDelegate.currentUser == nil))
    {
        // Must be logged!
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_INFO_", nil) message:NSLocalizedString(@"_MUSTBELOGGED_MSG_", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"_OK_", nil) otherButtonTitles:nil];
        
        [alertView show];
        
        return;
    }
    
    GSBaseElement *selectedResult = nil;
    
    if (!isSimilar) {
        selectedResult = [getLookVC.products objectAtIndex:sender.tag];
    }
    else {
        selectedResult = [similarVC.products objectAtIndex:sender.tag];
    }
    
    if (!(selectedResult == nil)) {
        if (!(_addingProductsToWardrobe == nil))
        {
            for (NSString *itemId in _addingProductsToWardrobe.itemsId)
            {
                if([itemId isEqualToString:_shownGSBaseElement.idGSBaseElement])
                {
                    /*
                     // Item already in wardrobe!
                     UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_INFO_", nil) message:NSLocalizedString(@"_ITEMALREADYINWARDROBE_MSG_", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"_OK_", nil) otherButtonTitles:nil];
                 
                     [alertView show];
                     */
                    return;
                }
            }
        
            //buttonForHighlight = sender;
        
            [self addItem:_shownGSBaseElement toWardrobeWithID:_addingProductsToWardrobe.idWardrobe];
        }
        else
        {
            // Instantiate the 'AddProductToWardrobe' view controller within the container view
        
            if ([UIStoryboard storyboardWithName:@"Wardrobe" bundle:nil] != nil)
            {
                AddItemToWardrobeViewController *addItemToWardrobeVC = nil;
            
                @try {
                
                    addItemToWardrobeVC = [[UIStoryboard storyboardWithName:@"Wardrobe" bundle:nil] instantiateViewControllerWithIdentifier:[@(ADDITEMTOWARDROBE_VC) stringValue]];
                
                }
                @catch (NSException *exception) {
                
                    return;
                
                }
            
                if (addItemToWardrobeVC != nil)
                {
                    [addItemToWardrobeVC setItemToAdd:selectedResult];
                
                    [addItemToWardrobeVC setButtonToHighlight:sender];
                
                    [self addChildViewController:addItemToWardrobeVC];
                
                    //[addProductToWardrobeVC willMoveToParentViewController:self];
                
                    addItemToWardrobeVC.view.frame = CGRectMake(0,0,_addToWardrobeVCContainerView.frame.size.width, _addToWardrobeVCContainerView.frame.size.height);
                
                    [_addToWardrobeVCContainerView addSubview:addItemToWardrobeVC.view];
                
                    [addItemToWardrobeVC didMoveToParentViewController:self];
                
                    [_addToWardrobeVCContainerView setHidden:NO];
                
                    [_addToWardrobeBackgroundView setHidden:NO];
                
                    [self.view bringSubviewToFront:_addToWardrobeBackgroundView];
                
                    [self.view bringSubviewToFront:_addToWardrobeVCContainerView];
                }
            }
        }
    }
}

-(void)onTapGetLookSeeMore {
    [self transitionToViewController:STYLES_VC withParameters:getLookParams];
}

-(void)onTapProductItem:(NSInteger)index {
    GSBaseElement *selectedResult = nil;
    
    selectedResult = [getLookVC.products objectAtIndex:index];
    
    if(!(selectedResult == nil))
    {
        if (!(_addingProductsToWardrobe == nil))
        {
            for (NSString *itemId in _addingProductsToWardrobe.itemsId)
            {
                if([itemId isEqualToString:selectedResult.idGSBaseElement])
                {
                    return;
                }
            }
        
            //buttonToHighlight = currentCell.hangerButton;
            
            [self addItem:selectedResult toWardrobeWithID:_addingProductsToWardrobe.idWardrobe];
            
            selectedResult = nil;
        }
        else
        {
            //bGettingDataOfElement = YES;
            if(!(selectedResult.fashionistaPostId == nil))
            {
                if(!([selectedResult.fashionistaPostId isEqualToString:@""]))
                {
                    // Perform request to get the result contents
                    NSLog(@"Getting contents for Fashionista post: %@", selectedResult.name);
                    
                    // Provide feedback to user
                    [self stopActivityFeedback];
                    [self startActivityFeedbackWithMessage:NSLocalizedString(@"_DOWNLOADINGCONTENT_ACTV_MSG_", nil)];
                    
                    BOOL isMagazine = NO;
                    if (selectedResult.post_magazinecategory != nil && ![selectedResult.post_magazinecategory isEqualToString:@""]) {
                        isMagazine = YES;
                    }
                    NSArray * requestParameters = [[NSArray alloc] initWithObjects:selectedResult.fashionistaPostId, [NSNumber numberWithBool:isMagazine], nil];
                    
                    [self performRestGet:GET_FULL_POST withParamaters:requestParameters];
                }
            }
        }
    }

}

-(void)onTapSimilarSeeMore {
    [self transitionToViewController:SEARCH_VC withParameters:similarParams];
}

-(void)onTapSimilarProductItem:(NSInteger)index {
    _selectedResult = [similarVC.products objectAtIndex:index];
    [self getContentsForElement:_selectedResult];
}

-(void)onTapDetailButton:(NSString*)color material:(NSString*)material {
    for(VariantGroupElement * vge in _shownProduct.variantGroup.variants)
    {
        if ([vge.color_name isEqualToString:color] && [vge.material_name isEqualToString:material]) {
            NSString *productID = vge.product_id;
            NSArray * requestParameters = [[NSArray alloc] initWithObjects:productID, nil];
            
            isSelectDetail = YES;
            [self performRestGet:GET_PRODUCT withParamaters:requestParameters];
        }
    }
}

-(void)onTapSeeMoreReviews {
    ReviewTableView *view = [self.storyboard instantiateViewControllerWithIdentifier:@"ReviewTableView"];
    view.delegate = self;
    view.reviews = _reviews;
    view.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    [self presentViewController:view animated:YES completion:nil];
//    self.reviewsView.hidden = NO;
//    [self.reviewsView addGestureRecognizer:topSwipe];
//    [self.reviewsView addGestureRecognizer:bottomSwipe];
}

-(void)onTapSeeMoreAvailability {
    AvailabilityTableView *seemoreView = [self.storyboard instantiateViewControllerWithIdentifier:@"AvailabilityTableView"];
    
    seemoreView.availabilities = _productAvailabilies;
    
    [self addChildViewController:seemoreView];
    
    seemoreView.view.frame = CGRectMake(0,0,_availabilityVCContainerView.frame.size.width, _availabilityVCContainerView.frame.size.height);
    
    [_availabilityVCContainerView addSubview:seemoreView.view];
    
    [seemoreView didMoveToParentViewController:self];
    
    [_availabilityVCContainerView setHidden:NO];
    
    [_availabilityVCContainerView setHidden:NO];
    
    [self.view bringSubviewToFront:_availabilityVCContainerView];
    
    self.buttonView.backgroundColor = [UIColor whiteColor];
}


- (void)closeSeeMoreAvailability
{
    [[self.childViewControllers lastObject] willMoveToParentViewController:nil];
    
    [[_availabilityVCContainerView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    [[self.childViewControllers lastObject] removeFromParentViewController];
    
    //[[self.childViewControllers lastObject] didMoveToParentViewController:nil];
    
    [_availabilityVCContainerView setHidden:YES];
    
    self.buttonView.backgroundColor = [UIColor clearColor];
}

-(void)showWebsite {
    [self closeSeeMoreAvailability];
    
    [self onTapPurchase:nil];
}

-(void)showFullViewAvailability:(ProductAvailability *)availability {
    [self closeSeeMoreAvailability];
    
    availabilityVC.instoreStore = availability;
    [availabilityVC initView];
}

#pragma mark - Transitions between View Controllers

// OVERRIDE: Title button action
- (void)titleButtonAction:(UIButton *)sender
{
    if(![[self activityIndicator] isHidden])
    {
        return;
    }

    if(!([self.hintBackgroundView isHidden]))
    {
        return;
    }
	
    if(!([_addToWardrobeVCContainerView isHidden]))
    {
        return;
    }
	
    if(!([_availabilityVCContainerView isHidden]))
    {
        return;
    }
    
    if(!(_addingProductsToWardrobeID == nil))
    {
        return;
    }

    if (!self.writeReviewView.hidden)
    {
        return;
    }
	
    if(!(_shownProduct == nil))
    {
        if(!(_shownProduct.brand == nil))
        {
            if(!(_shownProduct.brand.name == nil))
            {
                if(!([_shownProduct.brand.name isEqualToString:@""]))
                {
                    if(!(_shownProduct.brand.idBrand == nil))
                    {
                        if(!([_shownProduct.brand.idBrand isEqualToString:@""]))
                        {
                            // Perform request to get the result contents
                            NSLog(@"Getting contents for brand: %@", _shownProduct.brand.name);
                            
                            // Provide feedback to user
                            [self stopActivityFeedback];
                            [self startActivityFeedbackWithMessage:NSLocalizedString(@"_DOWNLOADINGCONTENT_ACTV_MSG_", nil)];
                            
                            NSArray * requestParameters = [[NSArray alloc] initWithObjects:[_shownProduct.brand.name urlEncodeUsingNSUTF8StringEncoding], nil];
                            
                            // TODO: make performsearch in order to get the products of the brand
                            [self performRestGet:GET_BRAND_PRODUCTS withParamaters:requestParameters];
                        }
                    }
                }
            }
        }
    }
}

// OVERRIDE: (Just to prevent from being at 'AddToWardrobe' dialog) Action to perform when user swipes to right: go to previous screen
- (void)swipeRightAction
{
    if(!([self.hintBackgroundView isHidden]))
    {
        [self hintPrevAction:nil];
        
        return;
    }

    if(!([_addToWardrobeVCContainerView isHidden]))
    {
        [self closeAddingItemToWardrobeHighlightingButton:nil withSuccess:NO];
    }

    if(!([_availabilityVCContainerView isHidden]))
    {
        [self closeSeeMoreAvailability];
    }
    
    else
    {
        [super swipeRightAction];
    }
}

// OVERRIDE: (Just to prevent from being at 'AddToWardrobe' dialog) Home action
//- (void)homeAction:(UIButton *)sender
//{
//    if(!([_addToWardrobeVCContainerView isHidden]))
//    {
//        return;
//    }
//
//    UIWebView * currentWebView = [_webViewArray objectAtIndex:self.iSelectedContent] ;
//    
//    [self transitionToViewController:PRODUCTFEATURESEARCH_VC withParameters:[NSArray arrayWithObjects:_shownProduct, currentWebView.request.URL.absoluteString, nil]];
//}

/*
// OVERRIDE: (Just to prevent from being at 'AddToWardrobe' dialog) Long press gesture reconizer
- (void)homeLongPressGestureRecognized:(UITapGestureRecognizer *)recognizer
{
    if(!(_addingProductsToWardrobeID == nil))
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_ADDING_PRODUCTS_TO_CONTENT_WARDROBE_", nil) message:NSLocalizedString(@"_ADDING_PRODUCTS_TO_CONTENT_WARDROBE_MSG_", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"_OK_", nil) otherButtonTitles:nil];
        
        [alertView show];
        
        return;
    }

    if(!([_addToWardrobeVCContainerView isHidden]))
    {
        return;
    }
    
    [super homeLongPressGestureRecognized:recognizer];
}


// Left action
- (void)leftAction:(UIButton *)sender
{
    if(!([_addToWardrobeVCContainerView isHidden]))
    {
        return;
    }
    
    if (!self.writeReviewView.hidden)
    {
        [self closeWriteReview];
    }
    else if(!(_addingProductsToWardrobeID == nil))
    {
        [self dismissViewController];
    }
    else
    {
        //[super leftAction:sender];
        [self actionForMainFourthCircleMenuEntry];
        
    }
}


// Right action
- (void)rightAction:(UIButton *)sender
{
    if(!(_addingProductsToWardrobeID == nil))
    {
        return;
    }

    if(!([_addToWardrobeVCContainerView isHidden]))
    {
        return;
    }
    
    if (!self.writeReviewView.hidden)
    {
        // Check that the review has some text
        if ([self.reviewTextView.text length] == 0)
        {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Product review", nil) message:NSLocalizedString(@"Please fill your review with some text!", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
            
            [alertView show];
        }
        else
        {
            [self.writeReviewView endEditing:YES];
            
            [self uploadReview];
            
            NSString * key = [NSString stringWithFormat:@"HIGHLIGHTSUBMIT_%d", [self.restorationIdentifier intValue]];
            
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            
            // Save into defaults if doesn't already exists
            if (!([defaults objectForKey:key]))
            {
                [defaults setInteger:1 forKey:key];
                
                [defaults synchronize];
            }
            else
            {
                int iNumHighlights = (int)[defaults integerForKey:key];
                
                [defaults setInteger:(iNumHighlights+1) forKey:key];
                
                [defaults synchronize];
            }
        }
    }
    else
    {
        // Action to perform is 'Share'
        if (!(self.shownProduct.idProduct == nil))
        {
            if(!([self.shownProduct.idProduct isEqualToString:@""]))
            {
                // Post the Share object
                
                NSManagedObjectContext *currentContext = [RKObjectManager sharedManager].managedObjectStore.mainQueueManagedObjectContext;
                
                Share * newShare = [[Share alloc] initWithEntity:[NSEntityDescription entityForName:@"Share" inManagedObjectContext:currentContext] insertIntoManagedObjectContext:currentContext];
                
                [newShare setSharedProductId:self.shownProduct.idProduct];
                
                AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                
                if (!(appDelegate.currentUser == nil))
                {
                    if (!([appDelegate.currentUser.idUser isEqualToString:@""]))
                    {
                        [newShare setSharingUserId:appDelegate.currentUser.idUser];
                    }
                }
                
                [currentContext processPendingChanges];
                
                [currentContext save:nil];
                
                NSArray * requestParameters = [[NSArray alloc] initWithObjects:newShare, nil];
                
                [self performRestPost:UPLOAD_SHARE withParamaters:requestParameters];
            }
        }
    }
}
*/
// OVERRIDE: First circle menu action
-(void) actionForMainFirstCircleMenuEntry
{
    if(!([_addToWardrobeVCContainerView isHidden]))
    {
        return;
    }
    
    if(!([_availabilityVCContainerView isHidden]))
    {
        return;
    }
    
    // Get product features
    
    // Check that there's actually a product to search its features
    if (issimilar) {
        return;
    }
    if(!(_shownProduct == nil))
    {
        if (!(_shownProduct.idProduct == nil))
        {
            if (!([_shownProduct.idProduct isEqualToString:@""]))
            {
                NSLog(@"Searching products similar to product: %@", _shownProduct.idProduct);
                
                if(_similarProductsSearchTerms == nil)
                {
                    _similarProductsSearchTerms = [[NSMutableArray alloc] init];
                }

                // Provide feedback to user
                [self stopActivityFeedback];
                [self startActivityFeedbackWithMessage:NSLocalizedString(@"_DOWNLOADINGFEATURES_ACTV_MSG_", nil)];
                
                NSArray * requestParameters = [[NSArray alloc] initWithObjects:_shownProduct, nil];
                issimilar = YES;
                [self performRestGet:GET_SIMILAR_PRODUCTS withParamaters:requestParameters];
            }
        }
    }
    
    return;
}

// OVERRIDE: Third circle menu action
-(void) actionForMainThirdCircleMenuEntry
{
    if(!([_addToWardrobeVCContainerView isHidden]))
    {
        return;
    }
    
    if(!([_availabilityVCContainerView isHidden]))
    {
        return;
    }
    
    [self transitionToViewController:PRODUCTFEATURESEARCH_VC withParameters:[NSArray arrayWithObjects:_shownProduct, self.ProductImageView.image, nil]];
    //UIWebView * currentWebView = [_webViewArray objectAtIndex:self.iSelectedContent] ;
    
    //[self transitionToViewController:PRODUCTFEATURESEARCH_VC withParameters:[NSArray arrayWithObjects:_shownProduct, currentWebView.request.URL.absoluteString, nil]];
}

// OVERRIDE: Fourth circle menu action
-(void) actionForMainFourthCircleMenuEntry
{
    if(!isGettingTheLook){
        if(!([_addToWardrobeVCContainerView isHidden]))
        {
            return;
        }

        if(!([_availabilityVCContainerView isHidden]))
        {
            return;
        }
        
        // Get product features
        
        // Check that there's actually a product to search its features
        if(!(_shownGSBaseElement == nil))
        {
            if (!(_shownGSBaseElement.productId == nil))
            {
                if (!([_shownGSBaseElement.productId isEqualToString:@""]))
                {
                    NSLog(@"Searching outfits for product: %@", _shownGSBaseElement.name);
                    
                    // Provide feedback to user
                    [self stopActivityFeedback];
                    [self startActivityFeedbackWithMessage:NSLocalizedString(@"_DOWNLOADINGFEATURES_ACTV_MSG_", nil)];
                    
                    NSArray * requestParameters = [[NSArray alloc] initWithObjects:_shownGSBaseElement, @"", nil];
                    isGettingTheLook = YES;
                    [self performRestGet:GET_THE_LOOK withParamaters:requestParameters];
                }
            }
        }
    }
    return;
}

// OVERRIDE: To control the case when the user is adding products to a post content wardrobe
- (void)showMainMenu:(UIButton *)sender
{
    if((!(sender == nil)) && (!(_addingProductsToWardrobeID == nil)))
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_ADDING_PRODUCTS_TO_CONTENT_WARDROBE_", nil) message:NSLocalizedString(@"_ADDING_PRODUCTS_TO_CONTENT_WARDROBE_MSG_", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"_OK_", nil) otherButtonTitles:nil];
        
        [alertView show];
    }
    else
    {
        [super showMainMenu:sender];
    }
}

#pragma mark - CLLocationManagerDelegate

- (void)getCurrentLocation
{
    [locationManager requestWhenInUseAuthorization];
    
    locationManager.delegate = self;

    locationManager.pausesLocationUpdatesAutomatically = NO;
    
    locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
    
    if ([CLLocationManager locationServicesEnabled])
    {
        [locationManager startUpdatingLocation];
    }
    else
    {
        NSLog(@"Location services is not enabled");
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"Location failed with error: %@", error);
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    NSLog(@"Location updated to location: %@", newLocation);
    
    CLLocation *currentLocation = newLocation;
    
    if (currentLocation != nil)
    {
        // Stop Location Manager
        [locationManager stopUpdatingLocation];
        
        // Reverse Geocoding
        NSLog(@"Resolving the address...");
        
        [geocoder reverseGeocodeLocation:currentLocation completionHandler:^(NSArray *placemarks, NSError *error){
            
            NSLog(@"Found placemarks: %@, error: %@", placemarks, error);
            
            if (error == nil && [placemarks count] > 0)
            {
                placemark = [placemarks lastObject];
                
                // For full address
                /*_detailedReviewUserLocation.text = [NSString stringWithFormat:@"%@ %@\n%@ %@\n%@\n%@",
                 placemark.subThoroughfare, placemark.thoroughfare,
                 placemark.postalCode, placemark.locality,
                 placemark.administrativeArea,
                 placemark.country];*/
                
                _currentUserLocation = [NSString stringWithFormat:@"%@ (%@)", placemark.locality, placemark.country];
                
                NSString *countryCode = placemark.ISOcountryCode;
                
                NSString *radius = @"100";
                NSString *lat = [NSString stringWithFormat:@"%.4F", placemark.location.coordinate.latitude];
                NSString *lon = [NSString stringWithFormat:@"%.4F", placemark.location.coordinate.longitude];
                
                //MKPlacemark *mark = [[MKPlacemark alloc] initWithCoordinate:placemark.location.coordinate addressDictionary:nil];
                NSString *zipCode = placemark.postalCode;
                
                
                NSLog(@"Place Mark Info : %@ %@ %@ %@ %@", countryCode, zipCode, radius, lat, lon);
            }
            else
            {
                NSLog(@"%@", error.debugDescription);
            }
        } ];
    }
}

#pragma mark - logout
// Peform an action once the user logs out
- (void)actionAfterLogOut
{
    [super actionAfterLogOut];
    
    [self closeAddingItemToWardrobeHighlightingButton:nil withSuccess:NO];
}

#pragma mark - action sheet video review
// Perform action to change user profile picture
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(!(self.currentSharedObject == nil))
    {
        [super actionSheet:actionSheet clickedButtonAtIndex:buttonIndex];
        return;
    }
    
    // Prepare Image Picker
    _temporalReviewURL = @"";
    
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    
    imagePicker.delegate = self;
    
    imagePicker.allowsEditing = YES;
    imagePicker.mediaTypes = [[NSArray alloc] initWithObjects: (NSString *) kUTTypeMovie, nil];
    
    switch (buttonIndex)
    {
        case 0: //Take photo
            
            // Ensure that device has camera
            if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
            {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_ERROR_", nil) message:NSLocalizedString(@"Device has no camera", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"_OK_", nil) otherButtonTitles: nil];
                
                [alertView show];
                
                return;
            }
            else
            {
                imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
            }
            
            break;
            
        case 1: // Select from camera roll
            
            imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            
            break;
            
        default:
            
            return;
    }
    
    
    
    [self presentViewController:imagePicker animated:YES completion:nil];
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
}

// Image selected, now edit it
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSURL * URL = info[UIImagePickerControllerMediaURL];
    _temporalReviewURL = [URL absoluteString];
    
    // Save it to camera roll
    UISaveVideoAtPathToSavedPhotosAlbum([[info objectForKey:@"UIImagePickerControllerMediaURL"]relativePath], self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
    
    // Save the image to the filesystem
    //NSData *imageData = UIImagePNGRepresentation(croppedImage);
    //NSData *data = [[NSFileManager defaultManager] contentsAtPath:URL];
    _addVideoToReviewButton.titleLabel.text = NSLocalizedString(@"_REMOVE_REVIEW_VIDEO_", nil);

    [self dismissViewControllerAnimated:YES completion:nil];
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
    
    _reviewTextSpaceConstraint.constant = 125;
    
    self.player = [[AVPlayerViewController alloc] init];
    self.player.player = [AVPlayer playerWithURL:[NSURL URLWithString:_temporalReviewURL]];
    float fFinalConstraint = _reviewTextSpaceConstraint.constant + _reviewTextView.frame.size.height * 0.7;
    
    float fW = _reviewTextView.frame.size.width;
    float fFinalH = _reviewTextView.frame.size.height * 0.7 - 1; //130;
    float fX = _reviewTextView.frame.origin.x + (IS_IPHONE_6P ? 4 : 0);
    float fY = _reviewTextView.frame.origin.y + _reviewTextView.frame.size.height;
    float fYFinal = _writeReviewView.frame.origin.y +  _writeReviewView.frame.size.height -fFinalConstraint + 37;
    
    self.player.view.frame = CGRectMake(fX,fY,fW,0);
    UIView * pView = self.player.view;
    [self.view addSubview:pView];
    [self.view bringSubviewToFront:pView];
    
    
    [UIView animateWithDuration:0.30
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^ {
                         self.player.view.frame = CGRectMake(fX,fYFinal,fW,fFinalH);
                         self.reviewTextSpaceConstraint.constant = fFinalConstraint;//240;
                         [self.view layoutIfNeeded];
                     }
                     completion:^(BOOL finished) {
                         
                         
                     }];
}

// Check if saving an image to camera roll succeed
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];

}

// In case user cancels changing image
- (void) imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
}

-(void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
}

-(BOOL)prefersStatusBarHidden   // iOS8 definitely needs this one. checked.
{
    return YES;
}

-(UIViewController *)childViewControllerForStatusBarHidden
{
    return nil;
}


#pragma mark - Statistics

-(NSString *) getPostComeFrom
{
    if (self.fromViewController != nil)
    {
        if ([self.fromViewController isKindOfClass:[WardrobeContentViewController class]])
        {
            WardrobeContentViewController * wardrobePost = (WardrobeContentViewController *)self.fromViewController;
            
            if (wardrobePost.fromViewController != nil)
            {
                if ([wardrobePost.fromViewController isKindOfClass:[GSFashionistaPostViewController class]])
                {
                    GSFashionistaPostViewController * postController = (GSFashionistaPostViewController *)wardrobePost.fromViewController;
                    
                    return postController.contentView.thePostId;
                }
            }
        }
    }
    return @"";
}


-(void)uploadProductView
{
    // Check that the name is valid
    
    if (!(_shownProduct.idProduct == nil))
    {
        if(!([_shownProduct.idProduct isEqualToString:@""]))
        {
            // Post the ProductView object
            
            ProductView * newProductView = [[ProductView alloc] init];
            
            newProductView.localtime = [NSDate date];
            
            [newProductView setProductId:_shownProduct.idProduct];
            
            [newProductView setPostId:[self getPostComeFrom]];
            
            AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            
            if (!(appDelegate.currentUser == nil))
            {
                if (!([appDelegate.currentUser.idUser isEqualToString:@""]))
                {
                    [newProductView setUserId:appDelegate.currentUser.idUser];
                }
            }
            
            if(!(_searchQuery == nil))
            {
                if(!(_searchQuery.idSearchQuery == nil))
                {
                    if(!([_searchQuery.idSearchQuery isEqualToString:@""]))
                    {
                        [newProductView setStatProductQueryId:_searchQuery.idSearchQuery];
                    }
                }
            }
            
            [newProductView setFingerprint:appDelegate.finger.fingerprint];
            
            NSArray * requestParameters = [[NSArray alloc] initWithObjects:newProductView, nil];
            
            [self performRestPost:ADD_PRODUCTVIEW withParamaters:requestParameters];
        }
    }
}

-(void)uploadProductSharedIn:(NSString *) sSocialNetwork
{
    // Check that the name is valid
    
    if (!(_shownProduct.idProduct == nil))
    {
        if(!([_shownProduct.idProduct isEqualToString:@""]))
        {
            // Post the ProductView object
            
            ProductShared * newProductShared = [[ProductShared alloc] init];
            
            newProductShared.localtime = [NSDate date];
            
            newProductShared.socialNetwork = sSocialNetwork;
            
            [newProductShared setProductId:_shownProduct.idProduct];
            
            [newProductShared setPostId:[self getPostComeFrom]];
            
            AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            
            if (!(appDelegate.currentUser == nil))
            {
                if (!([appDelegate.currentUser.idUser isEqualToString:@""]))
                {
                    [newProductShared setUserId:appDelegate.currentUser.idUser];
                }
            }
            
            if(!(_searchQuery == nil))
            {
                if(!(_searchQuery.idSearchQuery == nil))
                {
                    if(!([_searchQuery.idSearchQuery isEqualToString:@""]))
                    {
                        [newProductShared setStatProductQueryId:_searchQuery.idSearchQuery];
                    }
                }
            }
            
            [newProductShared setFingerprint:appDelegate.finger.fingerprint];
            
            [newProductShared setOrigin: NSStringFromClass([self.fromViewController class])];
            
            if ([self.fromViewController isKindOfClass:[SearchBaseViewController class]])
            {
                SearchBaseViewController * searchVC = (SearchBaseViewController *)self.fromViewController;
                
                [newProductShared setOrigindetail:[searchVC getSearchContextString]];
            }
            else if ([self.fromViewController isKindOfClass:[WardrobeContentViewController class]])
            {
                WardrobeContentViewController * wardrobeVC = (WardrobeContentViewController *)self.fromViewController;
                
                if (wardrobeVC.shownWardrobe != nil)
                {
                    [newProductShared setOrigindetail:wardrobeVC.shownWardrobe.userId];
                }
            }
            
            NSArray * requestParameters = [[NSArray alloc] initWithObjects:newProductShared, nil];
            
            [self performRestPost:ADD_PRODUCTSHARED withParamaters:requestParameters];
        }
    }
}


-(void)uploadReviewProductsView:(Review *) review
{
    // Check that the name is valid
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    // Post the ProductView object
    
    ReviewProductView * newCommentView = [[ReviewProductView alloc] init];
    newCommentView.localtime = [NSDate date];
    [newCommentView setReviewId:review.idReview];
    
    if (!(appDelegate.currentUser == nil))
    {
        if (!([appDelegate.currentUser.idUser isEqualToString:@""]))
        {
            [newCommentView setUserId:appDelegate.currentUser.idUser];
        }
    }
    
    [newCommentView setFingerprint:appDelegate.finger.fingerprint];
    
    if(!(newCommentView == nil))
    {
        NSArray * requestParameters = [[NSArray alloc] initWithObjects:newCommentView, nil];
        
        [self performRestPost:ADD_REVIEWPRODUCTVIEW withParamaters:requestParameters];
    }
}

-(void)uploadProductPurchase
{
    // Check that the name is valid
    
    if (!(_shownProduct.idProduct == nil))
    {
        if(!([_shownProduct.idProduct isEqualToString:@""]))
        {
            // Post the ProductView object
            
            ProductPurchase * newProductPurchase = [[ProductPurchase alloc] init];
            
            newProductPurchase.localtime = [NSDate date];
            
            [newProductPurchase setProductId:_shownProduct.idProduct];
            
            [newProductPurchase setPostId:[self getPostComeFrom]];
            
            AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            
            if (!(appDelegate.currentUser == nil))
            {
                if (!([appDelegate.currentUser.idUser isEqualToString:@""]))
                {
                    [newProductPurchase setUserId:appDelegate.currentUser.idUser];
                }
            }
            
            if(!(_searchQuery == nil))
            {
                if(!(_searchQuery.idSearchQuery == nil))
                {
                    if(!([_searchQuery.idSearchQuery isEqualToString:@""]))
                    {
                        [newProductPurchase setStatProductQueryId:_searchQuery.idSearchQuery];
                    }
                }
            }
            
            [newProductPurchase setFingerprint:appDelegate.finger.fingerprint];
            
            if (productView != nil)
            {
                [newProductPurchase setStatProductViewId:productView.idProductView];
            }
            
            
            NSArray * requestParameters = [[NSArray alloc] initWithObjects:newProductPurchase, nil];
            
            [self performRestPost:ADD_PRODUCTPURCHASE withParamaters:requestParameters];
        }
    }
}

-(void) afterSharedIn:(NSString *) sSocialNetwork
{
    [self uploadProductSharedIn:sSocialNetwork];
}
//////////////////////////////jcb

#pragma mark - BackgroundView
-(void) initBackgroundView {
    [self setUpProductImageView];
	[self setupVCArray];
}

#pragma mark - setUp Pages
-(void)setupVCArray {
	// Setup Swipe Up/Down Page Views
	defaultVC = [[UIViewController alloc] init];
	defaultVC.view.backgroundColor = [UIColor clearColor];
	defaultVC.view.frame = CGRectMake(defaultVC.view.frame.origin.x, defaultVC.view.frame.origin.y, self.productView.frame.size.width, self.productView.frame.size.height);
	[self.productView addSubview:defaultVC.view];
	currentPageIndex = -1;
	
	[self setUpPriceView];
	[self setUpInfoView];
	[self setUpDetailView];
	[self setUpReviewView];
	[self setUpSizeView];
    [self setUpAvailabilityView];
	[self setUpShippingView];
	[self setUpGetLookView];
    [self setUpSimiarView];
	[self setUpShareView];
}

-(void)setUpProductImageView {
    //Product Image View
    NSMutableArray *images = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < [self.productContent count]; i ++) {
        self.shownContent = [[self getFetchedResultsControllerForCellType:@"ContentCell"] objectAtIndexPath:[NSIndexPath indexPathForItem:i inSection:0]];
        NSLog(_shownProduct.url);
        [images addObject:_shownContent.url];
    }
    
    productImageVC = [self.storyboard instantiateViewControllerWithIdentifier:@"ProductImageVC"];
    productImageVC.images = images;
    productImageVC.view.frame = CGRectMake(0, 0, _productimgView.frame.size.width, _productimgView.frame.size.height);
    [self.productimgView addSubview:productImageVC.view];
}
-(void)setUpPriceView {
	priceVC = [self.storyboard instantiateViewControllerWithIdentifier:@"PriceVC"];
	
	if((_shownProduct.url == nil) || ([_shownProduct.url isEqualToString:@""]))
	{
		priceVC.price = NSLocalizedString(@"_PASTCOLLECTIONPRODUCT_", nil);
	}
	else
	{
		if([_shownProduct.recommendedPrice floatValue] > 0)
		{
			priceVC.price = [NSString stringWithFormat:@"$%.2f", [_shownProduct.recommendedPrice floatValue]];
		}
		else
		{
			priceVC.price = NSLocalizedString(@"_PRICE_NOT_AVAILABLE_", nil);
			
			[priceVC.priceLabel setTextColor:[UIColor lightGrayColor]];
		}
	}
}

-(void)setUpInfoView {
	infoVC = [self.storyboard instantiateViewControllerWithIdentifier:@"InfoVC"];
	infoVC.delegate = self;
	if([_shownProductFeatureTerms count] > 0)
	{
		NSString *info = [NSString stringWithFormat:@"%@: %@\n\n%@", NSLocalizedString(@"_PRODUCTTAGS_", nil), [self composeStringhWithTermsOfArray:_shownProductFeatureTerms], _shownProduct.information];
		[infoVC setText:info];
	}
	else
	{
		NSString *info = _shownProduct.information;
		[infoVC setText:info];
	}
}

-(void)setUpDetailView {
	if (hasColor) {
		detailVC = [self.storyboard instantiateViewControllerWithIdentifier:@"DetailVC"];
//		NSArray *colors = [color_images allValues];
//		NSArray *materials = [material_images allValues];
		detailVC.color_images = color_images;
        detailVC.material_images = material_images;
        NSLog(@"Color_Curated : %@", _shownProduct.color);
        detailVC.color_curated = _shownProduct.color;
        detailVC.material_curated = _shownProduct.material;
		detailVC.height = self.productView.frame.size.height;
        detailVC.delegate = self;
	}
}

-(void)setUpReviewView {
	reviewVC = [self.storyboard instantiateViewControllerWithIdentifier:@"ReviewVC"];
	reviewVC.delegate = self;
	if(!(_addingProductsToWardrobeID == nil))
	{
		reviewVC.availableWriteReview = NO;
	}
    reviewVC.reviews = _reviews;
    reviewVC.reviewCount = [_reviews count];
    [reviewVC initView];
}

-(void)setUpSizeView {
	sizeVC = [self.storyboard instantiateViewControllerWithIdentifier:@"SizeVC"];
	sizeVC.size_array = size_array;
	sizeVC.height = self.productView.frame.size.height;
}

-(void)setUpAvailabilityView {
    availabilityVC = [self.storyboard instantiateViewControllerWithIdentifier:@"AvailabilityVC"];
    if ([_productAvailabilies count] > 0) {
        if (self.placeMark != nil) {
            availabilityVC.coordinate = self.placeMark.location.coordinate;
        }
        else {
            NSLog(@"@@@@@    PLACE MARK IS NULL     @@@@@");
        }
        
        if ([onlinelist count] > 0 && [instorelist count] > 0) {
            availabilityVC.onlinestate = ONLINE_INSTORE;
            availabilityVC.onlineStore = (ProductAvailability*)[onlinelist objectAtIndex:0];
            availabilityVC.instoreStore = (ProductAvailability*)[instorelist objectAtIndex:0];
        }
        else if ([onlinelist count] > 0) {
            availabilityVC.onlinestate = ONLINE_ONLY;
            availabilityVC.onlineStore = (ProductAvailability*)[onlinelist objectAtIndex:0];
        }
        else if ([instorelist count] > 0) {
            availabilityVC.onlinestate = INSTORE_ONLY;
            availabilityVC.instoreStore = (ProductAvailability*)[instorelist objectAtIndex:0];
        }
        if ([_productAvailabilies count] > 1) {
            availabilityVC.isShowSeeMore = YES;
        }
        else {
            availabilityVC.isShowSeeMore = NO;
        }
        
        [availabilityVC initView];
        
        availabilityVC.delegate = self;
    }
}

-(void)setUpShippingView {
	shippingVC = [self.storyboard instantiateViewControllerWithIdentifier:@"ShippingVC"];
}

-(void)setUpGetLookView {
	getLookVC = [self.storyboard instantiateViewControllerWithIdentifier:@"GetLookVC"];
    getLookVC.delegate = self;
}

-(void)loadGetLookView:(NSArray*)params products:(NSArray*)products {
    getLookParams = params;
    getLookVC.products = products;
    getLookVC.userWardrobesElements = userWardrobesElements;
    [getLookVC initView];
}

-(void)setUpSimiarView {
    similarVC = [self.storyboard instantiateViewControllerWithIdentifier:@"SimilarVC"];
    similarVC.delegate = self;
}

-(void)loadSimilarView:(NSArray*)params products:(NSMutableArray*)products {
    similarParams = params;
    similarVC.products = products;
    similarVC.userWardrobesElements = userWardrobesElements;
    [similarVC initView];
}
-(void)setUpShareView {
	shareVC = [self.storyboard instantiateViewControllerWithIdentifier:@"ShareVC"];
	shareVC.delegate = self;
}

#pragma mark - setup Top Navi
-(void)setupTopNavi {
	// Setup Top Navigation
	self.edgesForExtendedLayout = UIRectEdgeNone;
	self.topNaviListView.delegate = self;
	self.topNaviListView.dataSource = self;
	
	self.topNaviListView.selectionIndicatorAnimationMode = HTHorizontalSelectionIndicatorAnimationModeLightBounce;
    self.topNaviListView.selectionIndicatorStyle = HTHorizontalSelectionIndicatorStyleNone;
	self.topNaviListView.showsEdgeFadeEffect = YES;
	
	self.topNaviListView.selectionIndicatorColor = [UIColor whiteColor];
	[self.topNaviListView setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
	[self.topNaviListView setTitleFont:[UIFont systemFontOfSize:16] forState:UIControlStateNormal];
	[self.topNaviListView setTitleFont:[UIFont boldSystemFontOfSize:16] forState:UIControlStateSelected];
	[self.topNaviListView setTitleFont:[UIFont boldSystemFontOfSize:16] forState:UIControlStateHighlighted];
	
	navs = [[NSMutableArray alloc] init];
	[navs addObject:@"PRICE"];
	[navs addObject:@"INFO"];
	if (hasColor) {
		[navs addObject:@"DETAILS"];
	}
	if (hasSize) {
		[navs addObject:@"SIZES"];
	}
    if ([_productAvailabilies count] > 0) {
        hasAvailability = YES;
        [navs addObject:@"AVAILABLE"];
    }
    else {
        hasAvailability = NO;
    }
	
	//[navs addObject:@"SHIPPING"];
	[navs addObject:@"REVIEWS"];
	[navs addObject:@"GET THE LOOK"];
	[navs addObject:@"SIMILAR"];
	[navs addObject:@"SHARE"];

	topNavs = [NSArray arrayWithArray:navs];
	
	// Swipe Recognizer
}

// Initialize gesture recognizer in productFeatureTermsView

- (void)initGestureRecognizer
{
	rightSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(panGesture:)];
	rightSwipe.direction = UISwipeGestureRecognizerDirectionRight;
	[self.productView addGestureRecognizer:rightSwipe];
	
	topSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(panGesture:)];
	topSwipe.direction = UISwipeGestureRecognizerDirectionUp;
	[self.productView addGestureRecognizer:topSwipe];
	
	bottomSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(panGesture:)];
	bottomSwipe.direction = UISwipeGestureRecognizerDirectionDown;
	[self.productView addGestureRecognizer:bottomSwipe];

	singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapProductImage:)];
	singleTap.numberOfTapsRequired = 1;
	[self.productView addGestureRecognizer:singleTap];
}

#pragma mark - Gesture Recognizer
- (void)panGesture:(UIPanGestureRecognizer *)sender {
    
	UISwipeGestureRecognizer *swipeGesture = (UISwipeGestureRecognizer*)sender;
    
	if ( swipeGesture.direction == UISwipeGestureRecognizerDirectionRight ) {
		NSLog(@" *** SWIPE RIGHT ***");
		[self swipeRightAction];
	}
	if ( swipeGesture.direction == UISwipeGestureRecognizerDirectionDown ) {
		NSLog(@" *** SWIPE DOWN ***");
		if (currentPageIndex == 2 && hasColor && hasMaterial && !detailVC.isColor) {
			[detailVC swipeDown];
		}
		else if ((currentPageIndex == -1) || (currentPageIndex == 0)) {
			NSInteger index = [topNavs count] - 1;
			[self SlidePage:index];
		}
        else if (currentPageIndex == 5 - (!(hasVariant)) - (!(hasSize)) - (!(hasAvailability))) {
            if (reviewVC.isShownReview && reviewVC.hasReview) {
                [reviewVC hiddenUserReview];
            }
            else {
                [self SlidePage:currentPageIndex - 1];
            }
        }
        else if (shareVC.isEnd && currentPageIndex == (8 - (!(hasVariant)) - (!(hasSize)) - (!(hasAvailability)))) {
            [shareVC swipeDown];
        }
        else if (hasAvailability && availabilityVC.isEnd && availabilityVC.isFill && currentPageIndex == (4 - (!(hasVariant)) - (!(hasSize)) - (!(hasAvailability)))) {
            [availabilityVC swipeDown];
        }
		else if (currentPageIndex > 0) {
			NSInteger index = currentPageIndex - 1;
			[self SlidePage:index];
		}
	}
	if ( swipeGesture.direction == UISwipeGestureRecognizerDirectionUp ) {
		NSLog(@" *** SWIPE UP ***");
		if (currentPageIndex == 2 && hasColor && hasMaterial && detailVC.isColor) {
			[detailVC swipeUp];
		}
        else if (currentPageIndex == 5 - (!(hasVariant)) - (!(hasSize)) - (!(hasAvailability))) {
            if ((!reviewVC.isShownReview) && reviewVC.hasReview) {
                [reviewVC shownUserReviews:self.productView.frame.size.height];
            }
            else {
                NSInteger index = currentPageIndex + 1;
                [self SlidePage:index];
            }
        }
        else if (currentPageIndex == (8 - (!(hasVariant)) - (!(hasSize)) - (!(hasAvailability)))) {
            if (shareVC.isEnd) {
                [self SlidePage:0];
                shareVC.isEnd = NO;
            }
            else {
                [shareVC swipeUp:self.productView.frame.size.height - 50];
            }
        }
        else if (hasAvailability && currentPageIndex == (4 - (!(hasVariant)) - (!(hasSize)) - (!(hasAvailability)))) {
            if (availabilityVC.isEnd || !availabilityVC.isFill) {
                [self SlidePage:currentPageIndex + 1];
                availabilityVC.isEnd = NO;
            }
            else {
                [availabilityVC swipeUp:self.productView.frame.size.height - 50];
            }
            
        }
		else if (currentPageIndex == -1 || currentPageIndex < [topNavs count] - 1) {
			NSInteger index = currentPageIndex + 1;
			[self SlidePage:index];
		}
	}
}

#pragma mark - HTHorizontalSelectionListDataSource Protocol Methods

- (NSInteger)numberOfItemsInSelectionList:(HTHorizontalSelectionList *)selectionList {
	return topNavs.count;
}

- (NSString *)selectionList:(HTHorizontalSelectionList *)selectionList titleForItemWithIndex:(NSInteger)index {
	
    self.reviewsView.hidden = YES;
	return topNavs[index];
}

#pragma mark - HTHorizontalSelectionListDelegate Protocol Methods

- (void)selectionList:(HTHorizontalSelectionList *)selectionList didSelectButtonWithIndex:(NSInteger)index {
	// update the view for the corresponding index
	[self SlidePage:index];
}

#pragma mark - Swipe Up/Down
-(void)SlidePage:(NSInteger)index {
	
    if (currentPageIndex == (5 - (!(hasVariant)) - (!(hasSize)) - (!(hasAvailability)))) {
        [self.reviewsView removeGestureRecognizer:topSwipe];
        [self.reviewsView removeGestureRecognizer:bottomSwipe];
        reviewVC.isShownReview = NO;
        reviewVC.userReviewView.hidden = YES;
    }
    
	UIView *fromView = [self getView:currentPageIndex];
	UIView *toView = [self getView:index];
	
    if (index == - 1 ||
        index == 0 ||
        index == 1) {
        [self.productView addGestureRecognizer:singleTap];
        _leftImagebutton.hidden = NO;
        _rightImagebutton.hidden = NO;
    }
    else {
        [self.productView removeGestureRecognizer:singleTap];
        _leftImagebutton.hidden = YES;
        _rightImagebutton.hidden = YES;
    }
    
	NSString *fromTab;
	if (currentPageIndex == -1) {
		fromTab = nil;
	}
	else {
		fromTab = (NSString *)[navs objectAtIndex:currentPageIndex];
	}
	NSString *toTab = (NSString *)[navs objectAtIndex:index];
	
	if (currentPageIndex == index) {

	}
	else if (currentPageIndex < index) { // Swipe up
		if ((currentPageIndex == 0 || currentPageIndex == -1) && index == [topNavs count] - 1) {
			[self animationTransitionTopBottom:fromView toView:toView];
		}
		else if ([fromTab isEqualToString:@"SIZES"]){
			[self animationTransitionSBLeft:fromView toView:toView];
		}
		else if ([toTab isEqualToString:@"DETAILS"]) {
			[self animationTransitionBottomRight:fromView toView:toView];
		}
		else if ([fromTab isEqualToString:@"DETAILS"] && [toTab isEqualToString:@"SIZES"]) {
			[self animationTransitionRight:fromView toView:toView];
		}
		else if ([fromTab isEqualToString:@"DETAILS"]) {
			[self animationTransitionRightTop:fromView toView:toView];
		}
		else if ([toTab isEqualToString:@"SIZES"]) {
			[self animationTransitionSBRight:fromView toView:toView];
		}
		else {
			[self animationTransitionBottomTop:fromView toView:toView];
		}
	}
	else { // Swipe Down
		if (index == 0 && currentPageIndex == [topNavs count] - 1) {
			[self animationTransitionBottomTop:fromView toView:toView];
		}
		else if ([fromTab isEqualToString:@"SIZES"] && [toTab isEqualToString:@"DETAILS"]) {
			[self animationTransitionLeft:fromView toView:toView];
		}
		else if ([toTab isEqualToString:@"SIZES"]) {
			[self animationTransitionSTRight:fromView toView:toView];
		}
		else if ([toTab isEqualToString:@"DETAILS"]) {
			[self animationTransitionTopRight:fromView toView:toView];
		}
		else if ([fromTab isEqualToString:@"DETAILS"]) {
			[self animationTransitionRightBottom:fromView toView:toView];
		}
		else if ([fromTab isEqualToString:@"SIZES"]) {
			[self animationTransitionSTLeft:fromView toView:toView];
		}
		else {
			[self animationTransitionTopBottom:fromView toView:toView];
		}
	}
	
	currentPageIndex = index;
	[_topNaviListView setSelectedButtonIndex:index animated:YES];

    
    if (currentPageIndex == (6 - (!(hasColor)) - (!(hasSize)) - (!(hasAvailability))))
    {
        [self getTheLook];
        [getLookVC animationAppear];
    }
    else if (currentPageIndex == (7 - (!(hasColor)) - (!(hasSize)) - (!(hasAvailability))))
    {
        [self onTapFindSimilar:nil];
        [similarVC animationAppear];
    }
}

-(UIView*)getView:(NSInteger)index {
	
	if (index == -1) {
		return defaultVC.view;
	}
	else if (index == 0) {
		return priceVC.view;
	}
	else if (index == 1) {
		return infoVC.view;
	}
	else if (index == (2 - (!(hasVariant)))) {
		return detailVC.view;
	}
	else if (index == (3 - (!(hasVariant)) - (!(hasSize)))) {
		return sizeVC.view;
	}
	else if (index == (4 - (!(hasVariant)) - (!(hasSize)) - (!(hasAvailability)))) {
		return availabilityVC.view;
	}
//	else if (index == (5 - (!(hasVariant)) - (!(hasSize)) - (!(hasAvailability)))) {
//		return shippingVC.view;
//	}
	else if (index == (5 - (!(hasVariant)) - (!(hasSize)) - (!(hasAvailability)))) {
		return reviewVC.view;
	}
	else if (index == (6 - (!(hasVariant)) - (!(hasSize)) - (!(hasAvailability)))) {
		return getLookVC.view;
	}
	else if (index == (7 - (!(hasVariant)) - (!(hasSize)) - (!(hasAvailability)))) {
		return similarVC.view;
	}
	else if (index == (8 - (!(hasVariant)) - (!(hasSize)) - (!(hasAvailability)))) {
		return shareVC.view;
	}
	return defaultVC.view;
}

#pragma mark - Bottom - Top Animation (First - Price - Info)
-(void)animationTransitionBottomTop:(UIView*)fromView toView:(UIView*)toView {
	[self.view setUserInteractionEnabled:NO];
	
	CGRect fromFrame = CGRectMake(fromView.frame.origin.x, fromView.frame.origin.y, self.productView.frame.size.width, self.productView.frame.size.height);
	CGRect toFrame = CGRectMake(toView.frame.origin.x, toView.frame.origin.y, self.productView.frame.size.width, self.productView.frame.size.height);
	
	fromFrame.origin.y = -fromFrame.size.height;
	toFrame.origin.y = toFrame.size.height;
	[toView setFrame:toFrame];
	toFrame.origin.y = 0;
	
	[UIView animateWithDuration:0.8
						  delay:0
						options: UIViewAnimationCurveEaseIn
					 animations:^{
						 [fromView setFrame:fromFrame];
						 [fromView setAlpha:0];
						 [toView setFrame:toFrame];
						 [toView setAlpha:0.9];
					 }
					 completion:^(BOOL finished){
						 [self.view setUserInteractionEnabled:YES];
					 }];

	[self.productView addSubview:toView];
}

#pragma mark - Top - Bottom Animation (First - Price - Info)
-(void)animationTransitionTopBottom:(UIView*)fromView toView:(UIView*)toView {
	[self.view setUserInteractionEnabled:NO];
	
	CGRect fromFrame = CGRectMake(fromView.frame.origin.x, fromView.frame.origin.y, self.productView.frame.size.width, self.productView.frame.size.height);
	CGRect toFrame = CGRectMake(toView.frame.origin.x, toView.frame.origin.y, self.productView.frame.size.width, self.productView.frame.size.height);
	
	fromFrame.origin.y = fromFrame.size.height;
	toFrame.origin.y = -toFrame.size.height;
	[toView setFrame:toFrame];
	toFrame.origin.y = 0;
	
	[UIView animateWithDuration:0.8
						  delay:0
						options: UIViewAnimationCurveEaseIn
					 animations:^{
						 [fromView setFrame:fromFrame];
						 [fromView setAlpha:0];
						 [toView setFrame:toFrame];
						 [toView setAlpha:0.9];
					 }
					 completion:^(BOOL finished){
						 [self.view setUserInteractionEnabled:YES];
					 }];
	
	[self.productView addSubview:toView];
}

#pragma mark - Bottom - Top Left - Right Animation (Info - Detail)
-(void)animationTransitionBottomRight:(UIView*)fromView toView:(UIView*)toView {
	[self.view setUserInteractionEnabled:NO];
	
	CGRect fromFrame = CGRectMake(fromView.frame.origin.x, fromView.frame.origin.y, self.productView.frame.size.width, self.productView.frame.size.height);
	CGRect toFrame = CGRectMake(toView.frame.origin.x, toView.frame.origin.y, self.productView.frame.size.width, self.productView.frame.size.height);
	
	fromFrame.origin.y = -fromFrame.size.height;
	toFrame.origin.x = -toFrame.size.width;
	[toView setFrame:toFrame];
	toFrame.origin.x = 0;
	
	[UIView animateWithDuration:0.6
						  delay:0
						options: UIViewAnimationCurveEaseIn
					 animations:^{
						 [fromView setFrame:fromFrame];
						 [fromView setAlpha:0];
					 }
					 completion:^(BOOL finished){
						 [detailVC animationAppear];
						 [UIView animateWithDuration:0.6
											   delay:0.1
											 options: UIViewAnimationCurveEaseIn
										  animations:^{
											  [toView setFrame:toFrame];
										  }
										  completion:^(BOOL finished){
											  [self.view setUserInteractionEnabled:YES];
										  }];
					 }];
	
	[self.productView addSubview:toView];
}

#pragma mark - Right - Left Top - Bottom Animation (Detail - Info)
-(void)animationTransitionRightBottom:(UIView*)fromView toView:(UIView*)toView {
	[self.view setUserInteractionEnabled:NO];
	
	CGRect fromFrame = CGRectMake(fromView.frame.origin.x, fromView.frame.origin.y, self.productView.frame.size.width, self.productView.frame.size.height);
	CGRect toFrame = CGRectMake(toView.frame.origin.x, toView.frame.origin.y, self.productView.frame.size.width, self.productView.frame.size.height);
	
	
	fromFrame.origin.x = -fromFrame.size.width;
	
	toFrame.origin.y = -toFrame.size.height;
	[toView setFrame:toFrame];
	toFrame.origin.y = 0;
	
	[detailVC animationDisappear];
	[UIView animateWithDuration:0.6
						  delay:0.5
						options: UIViewAnimationCurveEaseIn
					 animations:^{
						 [fromView setFrame:fromFrame];
						 [toView setFrame:toFrame];
						 [toView setAlpha:0.9];
					 }
					 completion:^(BOOL finished){
						 [self.view setUserInteractionEnabled:YES];
					 }];
	
	[self.productView addSubview:toView];
}

#pragma mark - Bottom - Top Left - Right Animation (Info - Detail)
-(void)animationTransitionTopRight:(UIView*)fromView toView:(UIView*)toView {
	[self.view setUserInteractionEnabled:NO];
	
	CGRect fromFrame = CGRectMake(fromView.frame.origin.x, fromView.frame.origin.y, self.productView.frame.size.width, self.productView.frame.size.height);
	CGRect toFrame = CGRectMake(toView.frame.origin.x, toView.frame.origin.y, self.productView.frame.size.width, self.productView.frame.size.height);
	
	fromFrame.origin.y = fromFrame.size.height;
	toFrame.origin.x = -toFrame.size.width;
	[toView setFrame:toFrame];
	toFrame.origin.x = 0;
	
	[UIView animateWithDuration:0.6
						  delay:0
						options: UIViewAnimationCurveEaseIn
					 animations:^{
						 [fromView setFrame:fromFrame];
						 [fromView setAlpha:0];
					 }
					 completion:^(BOOL finished){
						 [detailVC animationAppear];
						 [UIView animateWithDuration:0.6
											   delay:0.1
											 options: UIViewAnimationCurveEaseIn
										  animations:^{
											  [toView setFrame:toFrame];
										  }
										  completion:^(BOOL finished){
											  [self.view setUserInteractionEnabled:YES];
										  }];
					 }];
	
	[self.productView addSubview:toView];
}

#pragma mark - Right - Left Bottom - Top Animation (Detail - Info)
-(void)animationTransitionRightTop:(UIView*)fromView toView:(UIView*)toView {
	[self.view setUserInteractionEnabled:NO];
	
	CGRect fromFrame = CGRectMake(fromView.frame.origin.x, fromView.frame.origin.y, self.productView.frame.size.width, self.productView.frame.size.height);
	CGRect toFrame = CGRectMake(toView.frame.origin.x, toView.frame.origin.y, self.productView.frame.size.width, self.productView.frame.size.height);
	
	
	fromFrame.origin.x = -fromFrame.size.width;
	
	
	toFrame.origin.y = toFrame.size.height;
	[toView setFrame:toFrame];
	toFrame.origin.y = 0;
	
	[detailVC animationDisappear];
	[UIView animateWithDuration:0.6
						  delay:0.5
						options: UIViewAnimationCurveEaseIn
					 animations:^{
						 [fromView setFrame:fromFrame];
						 [toView setFrame:toFrame];
						 [toView setAlpha:0.9];
					 }
					 completion:^(BOOL finished){
						 [self.view setUserInteractionEnabled:YES];
					 }];
	
	[self.productView addSubview:toView];
}

#pragma mark - Detail - SizeView
-(void) animationTransitionRight:(UIView*)fromView toView:(UIView*)toView {
	[self.view setUserInteractionEnabled:NO];
	
	CGRect fromFrame = CGRectMake(fromView.frame.origin.x, fromView.frame.origin.y, self.productView.frame.size.width, self.productView.frame.size.height);
	CGRect toFrame = CGRectMake(toView.frame.origin.x, toView.frame.origin.y, self.productView.frame.size.width, self.productView.frame.size.height);
	
	
	fromFrame.origin.x = -fromFrame.size.width;
	
	toFrame.origin.x = -toFrame.size.width;
	[toView setFrame:toFrame];
	[toView setAlpha:0];
	toFrame.origin.x = 0;
	
	[detailVC animationDisappear];
	[UIView animateWithDuration:0.6
						  delay:1
						options: UIViewAnimationCurveEaseIn
					 animations:^{
						 //[sizeVC animationAppear];
						 [toView setFrame:toFrame];
						 [toView setAlpha:0.9];
						 [fromView setFrame:fromFrame];
					 }
					 completion:^(BOOL finished){
						 [self.view setUserInteractionEnabled:YES];
					 }];
	
	[self.productView addSubview:toView];
}

#pragma mark - SizeView - DetailsView
-(void) animationTransitionLeft:(UIView*)fromView toView:(UIView*)toView {
	[self.view setUserInteractionEnabled:NO];
	
	CGRect fromFrame = CGRectMake(fromView.frame.origin.x, fromView.frame.origin.y, self.productView.frame.size.width, self.productView.frame.size.height);
	CGRect toFrame = CGRectMake(toView.frame.origin.x, toView.frame.origin.y, self.productView.frame.size.width, self.productView.frame.size.height);
	
	
	fromFrame.origin.x = -fromFrame.size.width;
	
	toFrame.origin.x = -toFrame.size.width;
	[toView setFrame:toFrame];
	[toView setAlpha:0];
	toFrame.origin.x = 0;

	
	//[sizeVC animationDisappear];
	[UIView animateWithDuration:0.6
						  delay:0.1
						options: UIViewAnimationCurveEaseIn
					 animations:^{
						 [fromView setFrame:fromFrame];
					 }
					 completion:^(BOOL finished){
						 [detailVC animationAppear];
						 [UIView animateWithDuration:0.6
											   delay:0.1
											 options: UIViewAnimationCurveEaseIn
										  animations:^{
											  [toView setFrame:toFrame];
											  [toView setAlpha:0.9];
										  }
										  completion:^(BOOL finished){
											  [self.view setUserInteractionEnabled:YES];
										  }];
					 }];
	
	[self.productView addSubview:toView];
}

#pragma mark - Bottom - Top - SizeView ( Info - Size )
-(void) animationTransitionSBRight:(UIView*)fromView toView:(UIView*)toView {
	[self.view setUserInteractionEnabled:NO];
	
	CGRect fromFrame = CGRectMake(fromView.frame.origin.x, fromView.frame.origin.y, self.productView.frame.size.width, self.productView.frame.size.height);
	CGRect toFrame = CGRectMake(toView.frame.origin.x, toView.frame.origin.y, self.productView.frame.size.width, self.productView.frame.size.height);
	
	
	fromFrame.origin.y = -fromFrame.size.height;
	
	toFrame.origin.x = -toFrame.size.width;
	[toView setFrame:toFrame];
	[toView setAlpha:0];
	toFrame.origin.x = 0;
	
	[UIView animateWithDuration:0.6
						  delay:0.1
						options: UIViewAnimationCurveEaseIn
					 animations:^{
						 [fromView setFrame:fromFrame];
						 [fromView setAlpha:0];
					 }
					 completion:^(BOOL finished){
						 [UIView animateWithDuration:0.6
											   delay:0.1
											 options: UIViewAnimationCurveEaseIn
										  animations:^{
											  [toView setFrame:toFrame];
											  [toView setAlpha:0.9];
										  }
										  completion:^(BOOL finished){
											  [self.view setUserInteractionEnabled:YES];
										  }];
					 }];
	
	[self.productView addSubview:toView];
}

#pragma mark - Top - Bottom - SizeView ( Review - Size )
-(void) animationTransitionSTRight:(UIView*)fromView toView:(UIView*)toView {
	[self.view setUserInteractionEnabled:NO];
	
	CGRect fromFrame = CGRectMake(fromView.frame.origin.x, fromView.frame.origin.y, self.productView.frame.size.width, self.productView.frame.size.height);
	CGRect toFrame = CGRectMake(toView.frame.origin.x, toView.frame.origin.y, self.productView.frame.size.width, self.productView.frame.size.height);
	
	
	fromFrame.origin.y = fromFrame.size.height;
	
	toFrame.origin.x = -toFrame.size.width;
	[toView setFrame:toFrame];
	[toView setAlpha:0];
	toFrame.origin.x = 0;
	
	[UIView animateWithDuration:0.6
						  delay:0.1
						options: UIViewAnimationCurveEaseIn
					 animations:^{
						 [fromView setFrame:fromFrame];
						 [fromView setAlpha:0];
					 }
					 completion:^(BOOL finished){
						 [UIView animateWithDuration:0.6
											   delay:0.1
											 options: UIViewAnimationCurveEaseIn
										  animations:^{
											  [toView setFrame:toFrame];
											  [toView setAlpha:0.9];
										  }
										  completion:^(BOOL finished){
											  [self.view setUserInteractionEnabled:YES];
										  }];
					 }];
	
	[self.productView addSubview:toView];
}

#pragma mark - SizeView - Top - Bottom ( Review - Size )
-(void) animationTransitionSTLeft:(UIView*)fromView toView:(UIView*)toView {
	[self.view setUserInteractionEnabled:NO];
	
	CGRect fromFrame = CGRectMake(fromView.frame.origin.x, fromView.frame.origin.y, self.productView.frame.size.width, self.productView.frame.size.height);
	CGRect toFrame = CGRectMake(toView.frame.origin.x, toView.frame.origin.y, self.productView.frame.size.width, self.productView.frame.size.height);
	
	
	fromFrame.origin.x = -fromFrame.size.width;
	
	toFrame.origin.y = -toFrame.size.height;
	[toView setFrame:toFrame];
	[toView setAlpha:0];
	toFrame.origin.y = 0;
	
	[UIView animateWithDuration:0.6
						  delay:0.1
						options: UIViewAnimationCurveEaseIn
					 animations:^{
						 [fromView setFrame:fromFrame];
						 [fromView setAlpha:0];
					 }
					 completion:^(BOOL finished){
						 [UIView animateWithDuration:0.6
											   delay:0.1
											 options: UIViewAnimationCurveEaseIn
										  animations:^{
											  [toView setFrame:toFrame];
											  [toView setAlpha:0.9];
										  }
										  completion:^(BOOL finished){
											  [self.view setUserInteractionEnabled:YES];
										  }];
					 }];
	
	[self.productView addSubview:toView];
}

#pragma mark - SizeView - Bottom - Top ( Size - Review )
-(void) animationTransitionSBLeft:(UIView*)fromView toView:(UIView*)toView {
	[self.view setUserInteractionEnabled:NO];
	
	CGRect fromFrame = CGRectMake(fromView.frame.origin.x, fromView.frame.origin.y, self.productView.frame.size.width, self.productView.frame.size.height);
	CGRect toFrame = CGRectMake(toView.frame.origin.x, toView.frame.origin.y, self.productView.frame.size.width, self.productView.frame.size.height);
	
	
	fromFrame.origin.x = -fromFrame.size.width;
	
	toFrame.origin.y = toFrame.size.height;
	[toView setFrame:toFrame];
	[toView setAlpha:0];
	toFrame.origin.y = 0;
	
	[UIView animateWithDuration:0.6
						  delay:0.1
						options: UIViewAnimationCurveEaseIn
					 animations:^{
						 [fromView setFrame:fromFrame];
						 [fromView setAlpha:0];
					 }
					 completion:^(BOOL finished){
						 [UIView animateWithDuration:0.6
											   delay:0.1
											 options: UIViewAnimationCurveEaseIn
										  animations:^{
											  [toView setFrame:toFrame];
											  [toView setAlpha:0.9];
										  }
										  completion:^(BOOL finished){
											  [self.view setUserInteractionEnabled:YES];
										  }];
					 }];
	
	[self.productView addSubview:toView];
}

- (BOOL) doesCurrentUserFollowsStylistWithId:(NSString *)stylistId
{
	_followsFetchedResultsController = nil;
	_followsFetchRequest = nil;
	
	AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
	
	if (!(appDelegate.currentUser == nil))
	{
		if(!(appDelegate.currentUser.idUser == nil))
		{
			if(!([appDelegate.currentUser.idUser isEqualToString:@""]))
			{
				if(!(stylistId == nil))
				{
					if (!([stylistId isEqualToString:@""]))
					{
						[self initFollowsFetchedResultsControllerWithEntity:@"Follow" andPredicate:@"followingId IN %@" inArray:[NSArray arrayWithObject:appDelegate.currentUser.idUser] sortingWithKey:@"idFollow" ascending:YES];
						
						if (!(_followsFetchedResultsController == nil))
						{
							if (!((int)[[_followsFetchedResultsController fetchedObjects] count] < 1))
							{
								for (Follow *tmpFollow in [_followsFetchedResultsController fetchedObjects])
								{
									if([tmpFollow isKindOfClass:[Follow class]])
									{
										// Check that the follow is valid
										if (!(tmpFollow == nil))
										{
											if(!(tmpFollow.followedId == nil))
											{
												if(!([tmpFollow.followedId isEqualToString:@""]))
												{
													if ([tmpFollow.followedId isEqualToString:stylistId])
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
				}
			}
		}
	}
	
	return NO;
}

// Initialize a specific Fetched Results Controller to fetch the current user follows in order to properly show the heart button
- (BOOL)initFollowsFetchedResultsControllerWithEntity:(NSString *)entityName andPredicate:(NSString *)predicate inArray:(NSArray *)arrayForPredicate sortingWithKey:(NSString *)sortKey ascending:(BOOL)ascending
{
	BOOL bReturn = FALSE;
	
	if(_followsFetchedResultsController == nil)
	{
		NSManagedObjectContext *currentContext = [RKObjectManager sharedManager].managedObjectStore.mainQueueManagedObjectContext;
		
		if (_followsFetchRequest == nil)
		{
			if([arrayForPredicate count] > 0)
			{
				_followsFetchRequest = [[NSFetchRequest alloc] init];
				
				// Entity to look for
				
				NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:currentContext];
				
				[_followsFetchRequest setEntity:entity];
				
				// Filter results
				
				[_followsFetchRequest setPredicate:[NSPredicate predicateWithFormat:predicate, arrayForPredicate]];
				
				// Sort results
				
				NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:sortKey ascending:ascending];
				
				[_followsFetchRequest setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
				
				[_followsFetchRequest setFetchBatchSize:20];
			}
		}
		
		if(_followsFetchRequest)
		{
			// Initialize Fetched Results Controller
			
			//NSSortDescriptor *tmpSortDescriptor = (NSSortDescriptor *)[_followsFetchRequest sortDescriptors].firstObject;
			
			NSFetchedResultsController *fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:_followsFetchRequest managedObjectContext:currentContext sectionNameKeyPath:nil cacheName:nil];
			
			_followsFetchedResultsController = fetchedResultsController;
			
			_followsFetchedResultsController.delegate = self;
		}
		
		if(_followsFetchedResultsController)
		{
			// Perform fetch
			
			NSError *error = nil;
			
			if (![_followsFetchedResultsController performFetch:&error])
			{
				// TODO: Update to handle the error appropriately. Now, we just assume that there were not results
				
				NSLog(@"Couldn't fetched wardrobes. Unresolved error: %@, %@", error, [error userInfo]);
				
				return FALSE;
			}
			
			bReturn = ([_followsFetchedResultsController fetchedObjects].count > 0);
		}
	}
	
	return bReturn;
}

@end

