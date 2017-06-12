//
//  AddPostToPageViewController.h
//  GoldenSpear
//
//  Created by Jose Antonio Sanchez Martinez on 31/07/15.
//  Copyright (c) 2015 GoldenSpear. All rights reserved.
//

#import "BaseViewController.h"
#import <CoreLocation/CoreLocation.h>


@interface AddPostToPageViewController : BaseViewController <NSFetchedResultsControllerDelegate, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, CLLocationManagerDelegate>

@property FashionistaPost * postToAdd;
@property (weak, nonatomic) IBOutlet UIImageView *postPreviewImage;
@property (weak, nonatomic) IBOutlet UILabel *postTitle;
@property (weak, nonatomic) IBOutlet UITextField * stylistPostName;
@property (weak, nonatomic) IBOutlet UISwitch *saveDateSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *saveLocationSwitch;
@property NSString *currentUserLocation;
@property (weak, nonatomic) IBOutlet UILabel *controllerTitle;
@property (weak, nonatomic) IBOutlet UISegmentedControl *postTypeSegmentedControl;
@property (weak, nonatomic) IBOutlet UILabel *noCollectionsLabel;
@property (weak, nonatomic) IBOutlet UITextField * stylistPageName;
@property (weak, nonatomic) IBOutlet UITableView *pagesTable;
@property (weak, nonatomic) IBOutlet UIButton *addToPageButton;

@property NSFetchedResultsController * pagesFetchedResultsController;
@property NSFetchRequest * pagesFetchRequest;
@property (nonatomic, strong) NSOperationQueue *imagesQueue;

@property UIButton * buttonToHighlight;

@end
