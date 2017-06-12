//
//  MagazineTappedViewController.h
//  GoldenSpear
//
//  Created by JCB on 9/7/16.
//  Copyright © 2016 GoldenSpear. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "GSContentViewPost.h"

@interface MagazineTappedViewController : BaseViewController <GSContentViewPostDelegate>

@property (weak, nonatomic) IBOutlet GSContentViewPost *contentView;
@property (strong, nonatomic) NSArray* postParameters;

@property (nonatomic, strong) NSOperationQueue *imagesQueue;

@property SearchQuery * searchQuery;
@end
