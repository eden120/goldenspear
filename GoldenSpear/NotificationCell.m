//
//  NotificationCell.m
//  GoldenSpear
//
//  Created by Jose Antonio Sanchez Martinez on 17/09/15.
//  Copyright (c) 2015 GoldenSpear. All rights reserved.
//

#import "NotificationCell.h"
#import "UIView+Shadow.h"

@implementation NotificationCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self)
    {
        // Initialization code
        
        // Initialize view cell properties

        self.backgroundColor = [UIColor colorWithWhite:0.85f alpha:1.0f];
        
        self.layer.borderColor = [UIColor whiteColor].CGColor;
        self.layer.borderWidth = 1.0f;
        self.layer.shadowColor = [UIColor grayColor].CGColor;
        self.layer.shadowRadius = 2.0f;
        self.layer.shadowOffset = CGSizeMake(0.0f, 2.0f);
        self.layer.shadowOpacity = 0.5f;
        
        // Make sure to rasterize nicely for retina
        self.layer.rasterizationScale = [UIScreen mainScreen].scale;
        self.layer.shouldRasterize = YES;
        
        _notificationMessage.layer.borderColor = [UIColor lightGrayColor].CGColor;
        _notificationMessage.layer.borderWidth = 0.5f;
        
        _actionButton.hidden = YES;
    }
    
    return self;
}

// Setter for cell properties
- (void)setAppearanceForCellOfType:(NSString *)cellType withBackgroundColor:(UIColor *)backgroundColor andBorderColor:(UIColor *)borderColor andBorderWith:(CGFloat)borderWidth andShadowColor:(UIColor *)shadowColor andImageContentMode:(UIViewContentMode)contentMode
{
    self.backgroundColor = backgroundColor;
    
    self.layer.borderColor = borderColor.CGColor;
    self.layer.borderWidth = borderWidth;
    
    self.layer.shadowColor = shadowColor.CGColor;
    
    self.notificationIcon.contentMode = contentMode;
    _notificationIcon.contentMode = UIViewContentModeScaleAspectFill;
    
    // Initialize image view properties
    _notificationIcon.clipsToBounds = YES;
    
    _notificationIcon.layer.cornerRadius = _notificationIcon.frame.size.height /2;
    _notificationIcon.layer.masksToBounds = YES;
    _notificationIcon.layer.borderWidth = 0;
    
    _actionButton.hidden = YES;
    
    // Init, position and show the activity indicator
    self.activityIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [self.activityIndicator setCenter:self.notificationIcon.center];
    [self.activityIndicator setHidesWhenStopped:YES];
    [self.activityIndicator startAnimating];
    [self.contentView addSubview: self.activityIndicator];
}

-(void) setupNotificationIconWithImage: (UIImage *)image
{
    self.notificationIcon.image = image;
    
    // Hide the activity indicator
    [self.activityIndicator stopAnimating];
}

- (void)setVideoURL:(NSString*) videoURL andIndex:(NSInteger)index
{
    _actionButton.tag = index;
    _actionButton.hidden = YES;
}

// Setup Follow Button
- (void)setupFollowButtonAtIndexPath:(NSIndexPath *)indexPath selected:(BOOL)bSelected
{
    // Setup the follow button

    self.notificationType.frame = CGRectMake(self.notificationType.frame.origin.x, self.notificationType.frame.origin.y, self.frame.size.width-self.actionButton.frame.size.width, self.notificationType.frame.size.height);

    self.notificationDate.frame = CGRectMake(self.notificationDate.frame.origin.x, self.notificationDate.frame.origin.y, self.frame.size.width-self.actionButton.frame.size.width, self.notificationDate.frame.size.height);
    
//    [self.actionButton setHidden:NO];

    UIImage * buttonImage = [UIImage imageNamed:(bSelected ? (@"heart_checked.png") : (@"heart_unchecked.png"))];
    
    if (buttonImage == nil)
    {
        [self.actionButton setTitle:NSLocalizedString(@"_FOLLOW_BTN_", nil) forState:UIControlStateNormal];
    }
    else
    {
        [self.actionButton setImage:buttonImage forState:UIControlStateNormal];
        [self.actionButton setImage:buttonImage forState:UIControlStateHighlighted];
        [[self.actionButton imageView] setContentMode:UIViewContentModeScaleAspectFit];
    }
    
    [self.actionButton setTag:(int)([indexPath item])];
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    
    // Hide the activity indicator
    [self.activityIndicator stopAnimating];
    self.activityIndicator = nil;
    self.notificationIcon.image = nil;
    
    [self setNeedsLayout];
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */

@end
