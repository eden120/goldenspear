//
//  GSContentSectionHeaderView.h
//  GoldenSpear
//
//  Created by Adria Vernetta Rubio on 5/5/16.
//  Copyright © 2016 GoldenSpear. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GSContentSectionHeaderView;

@protocol GSContentSectionHeaderDelegate <NSObject>

- (void)headerTouched:(GSContentSectionHeaderView*)header;

@end

@interface GSContentSectionHeaderView : UITableViewHeaderFooterView

@property (weak, nonatomic) IBOutlet UIImageView *headerImage;
@property (weak, nonatomic) IBOutlet UILabel *headerTitle;
@property (weak, nonatomic) IBOutlet UILabel *headerSubtitle;
@property (weak, nonatomic) IBOutlet UIView *backgroundView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleImageWidthConstraint;

@property (weak, nonatomic) id<GSContentSectionHeaderDelegate> delegate;

@property (strong, nonatomic) NSString* contentId;

- (IBAction)headerTouched:(id)sender;
@end
