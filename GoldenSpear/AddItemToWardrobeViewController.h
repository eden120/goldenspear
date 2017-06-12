//
//  AddItemToWardrobeViewController.h
//  GoldenSpear
//
//  Created by Jose Antonio Sanchez Martinez on 25/06/15.
//  Copyright (c) 2015 GoldenSpear. All rights reserved.
//

#import "BaseViewController.h"

@interface AddItemToWardrobeViewController : BaseViewController <NSFetchedResultsControllerDelegate, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>

@property GSBaseElement * itemToAdd;
@property FashionistaPost * postToAdd;
@property (weak, nonatomic) IBOutlet UIImageView *itemImage;
@property (weak, nonatomic) IBOutlet UILabel *itemName;
@property (weak, nonatomic) IBOutlet UILabel *controllerTitle;
@property (weak, nonatomic) IBOutlet UILabel *noCollectionsLabel;
@property (weak, nonatomic) IBOutlet UITextField * wardrobeCollectionName;
@property (weak, nonatomic) IBOutlet UITableView *wardrobesTable;
@property (weak, nonatomic) IBOutlet UIButton *addToWardrobeButton;

@property NSFetchedResultsController * wardrobesFetchedResultsController;
@property NSFetchRequest * wardrobesFetchRequest;
@property (nonatomic, strong) NSOperationQueue *imagesQueue;

@property UIButton * buttonToHighlight;

@property BOOL isAddButton;

@end
