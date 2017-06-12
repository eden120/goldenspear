//
//  ReviewCell.m
//  GoldenSpear
//
//  Created by Jose Antonio Sanchez Martinez on 13/04/15.
//  Copyright (c) 2015 GoldenSpear. All rights reserved.
//

#import "ReviewCell.h"
#import "UIView+Shadow.h"

@implementation ReviewCell


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self)
    {
        // Initialization code
        
        // Initialize view cell properties
        _videoURL = @"";
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
        
        // Initialize image view properties
        
        
        //_userPic.clipsToBounds = YES;
        
        
        //[[_userPic layer] setBorderColor:[[UIColor blackColor] CGColor]];
        //[[_userPic layer] setBorderWidth:1.0];
        
        _reviewStr.layer.borderColor = [UIColor lightGrayColor].CGColor;
        _reviewStr.layer.borderWidth = 0.5f;
        
        //[self.contentView addSubview:_reviewerProfilePic];
        
        
        _overallRateView.notSelectedImage = [UIImage imageNamed:@"notSelectedImage.png"];
        _overallRateView.halfSelectedImage = [UIImage imageNamed:@"halfSelectedImage.png"];
        _overallRateView.fullSelectedImage = [UIImage imageNamed:@"fullSelectedImage.png"];
        _overallRateView.rating = 0;
        _overallRateView.editable = NO;
        _overallRateView.maxRating = 5;
        _overallRateView.delegate = self;
    
        _comfortRateView.notSelectedImage = [UIImage imageNamed:@"notSelectedImage.png"];
        _comfortRateView.halfSelectedImage = [UIImage imageNamed:@"halfSelectedImage.png"];
        _comfortRateView.fullSelectedImage = [UIImage imageNamed:@"fullSelectedImage.png"];
        _comfortRateView.rating = 0;
        _comfortRateView.editable = NO;
        _comfortRateView.maxRating = 5;
        _comfortRateView.delegate = self;
        
        _qualityRateView.notSelectedImage = [UIImage imageNamed:@"notSelectedImage.png"];
        _qualityRateView.halfSelectedImage = [UIImage imageNamed:@"halfSelectedImage.png"];
        _qualityRateView.fullSelectedImage = [UIImage imageNamed:@"fullSelectedImage.png"];
        _qualityRateView.rating = 0;
        _qualityRateView.editable = NO;
        _qualityRateView.maxRating = 5;
        _qualityRateView.delegate = self;
        
        // Init, position and show the activity indicator
        self.activityIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [self.activityIndicator setCenter:CGPointMake(self.frame.size.width / 2.0, self.frame.size.height / 2.0)];
        [self.activityIndicator setHidesWhenStopped:YES];
        [self.activityIndicator startAnimating];
        [self.contentView addSubview: self.activityIndicator];
        
        _videoButton.hidden = YES;
        if(_videoURL && ![_videoURL isEqualToString:@""])
            _videoButton.hidden = NO;
        
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
    
    self.userPic.contentMode = contentMode;
    _userPic.contentMode = UIViewContentModeScaleAspectFill;
    
    // Initialize image view properties
    _userPic.clipsToBounds = YES;
    
//    [[_userPic layer] setBorderColor:[[UIColor blackColor] CGColor]];
//    [[_userPic layer] setBorderWidth:0.0];
    
    _userPic.layer.cornerRadius = _userPic.frame.size.height /2;
    _userPic.layer.masksToBounds = YES;
    _userPic.layer.borderWidth = 0;
    
    _overallRateView.notSelectedImage = [UIImage imageNamed:@"notSelectedImage.png"];
    _overallRateView.halfSelectedImage = [UIImage imageNamed:@"halfSelectedImage.png"];
    _overallRateView.fullSelectedImage = [UIImage imageNamed:@"fullSelectedImage.png"];
    _overallRateView.rating = 0;
    _overallRateView.editable = NO;
    _overallRateView.maxRating = 5;
    _overallRateView.midMargin = 0;
    _overallRateView.delegate = self;
    
    _comfortRateView.notSelectedImage = [UIImage imageNamed:@"notSelectedImage.png"];
    _comfortRateView.halfSelectedImage = [UIImage imageNamed:@"halfSelectedImage.png"];
    _comfortRateView.fullSelectedImage = [UIImage imageNamed:@"fullSelectedImage.png"];
    _comfortRateView.rating = 0;
    _comfortRateView.editable = NO;
    _comfortRateView.maxRating = 5;
    _comfortRateView.midMargin = 0;
    _comfortRateView.delegate = self;
    
    _qualityRateView.notSelectedImage = [UIImage imageNamed:@"notSelectedImage.png"];
    _qualityRateView.halfSelectedImage = [UIImage imageNamed:@"halfSelectedImage.png"];
    _qualityRateView.fullSelectedImage = [UIImage imageNamed:@"fullSelectedImage.png"];
    _qualityRateView.rating = 0;
    _qualityRateView.editable = NO;
    _qualityRateView.maxRating = 5;
    _qualityRateView.midMargin = 0;
    _qualityRateView.delegate = self;

 
    //[self.separatorView makeInsetShadowWithRadius:4 Color:[UIColor colorWithRed:(0.5) green:(0.5) blue:(0.5) alpha:0.05] Directions:[NSArray arrayWithObject:@"bottom"]];
    
    _videoButton.hidden = YES;
    if(_videoURL && ![_videoURL isEqualToString:@""])
        _videoButton.hidden = NO;
    
    // Hide the activity indicator
    [self.activityIndicator stopAnimating];
}

// Rate view delegate
- (void)rateView:(RateView *)rateView ratingDidChange:(float)rating
{
    
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    
    self.userPic.image = nil;
    _videoURL = @"";
}

- (void)setVideoURL:(NSString*) videoURL andIndex:(NSInteger)index
{
    _videoButton.tag = index;
    _videoButton.hidden = YES;
    if(videoURL && ![videoURL isEqualToString:@""])
        _videoButton.hidden = NO;
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
