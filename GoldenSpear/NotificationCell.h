//
//  NotificationCell.h
//  GoldenSpear
//
//  Created by Jose Antonio Sanchez Martinez on 17/09/15.
//  Copyright (c) 2015 GoldenSpear. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface NotificationCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *notificationIcon;
@property (weak, nonatomic) IBOutlet UILabel *notificationType;
@property (weak, nonatomic) IBOutlet UILabel *notificationDate;
@property (weak, nonatomic) IBOutlet UITextView *notificationMessage;
@property (weak, nonatomic) IBOutlet UIButton *actionButton;
@property (weak, nonatomic) IBOutlet UIView *separatorView;

@property UIActivityIndicatorView *activityIndicator;

// Setter for cell properties
- (void)setAppearanceForCellOfType:(NSString *)cellType withBackgroundColor:(UIColor *)backgroundColor andBorderColor:(UIColor *)borderColor andBorderWith:(CGFloat)borderWidth andShadowColor:(UIColor *)shadowColor andImageContentMode:(UIViewContentMode)contentMode;
- (void)setupFollowButtonAtIndexPath:(NSIndexPath *)indexPath selected:(BOOL)bSelected;
-(void) setupNotificationIconWithImage: (UIImage *)image;

@end
