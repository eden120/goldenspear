//
//  CommentCell.h
//  GoldenSpear
//
//  Created by Jose Antonio Sanchez Martinez on 04/09/15.
//  Copyright (c) 2015 GoldenSpear. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>


@interface CommentCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *userPic;
@property (weak, nonatomic) IBOutlet UILabel *userName;
@property (weak, nonatomic) IBOutlet UILabel *userLocation;
@property (weak, nonatomic) IBOutlet UITextView *commentStr;
@property (weak, nonatomic) IBOutlet UIButton *videoButton;
@property (weak, nonatomic) IBOutlet UIView *separatorView;

@property UIActivityIndicatorView *activityIndicator;
@property (strong, nonatomic) NSString * videoURL;

// Setter for cell properties
- (void)setAppearanceForCellOfType:(NSString *)cellType withBackgroundColor:(UIColor *)backgroundColor andBorderColor:(UIColor *)borderColor andBorderWith:(CGFloat)borderWidth andShadowColor:(UIColor *)shadowColor andImageContentMode:(UIViewContentMode)contentMode;
- (void)setVideoURL:(NSString*) videoURL andIndex:(NSInteger)index;
@end
