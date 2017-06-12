//
//  RateView.m
//  GoldenSpear
//
//  Created by Jose Antonio Sanchez Martinez on 08/04/15.
//  Copyright (c) 2015 GoldenSpear. All rights reserved.
//

#import "RateView.h"

@implementation RateView

// Initialize variables to default values
- (void)initRateView
{
    _notSelectedImage = nil;
    _halfSelectedImage = nil;
    _fullSelectedImage = nil;
    _rating = 0;
    _editable = NO;
    _imageViews = [[NSMutableArray alloc] init];
    _maxRating = 5;
    _midMargin = 5;
    _outerMargin = 0;
    _minImageSize = CGSizeMake(5, 5);
    _delegate = nil;
}

// View controller can add the view programatically
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self)
    {
        [self initRateView];
    }
    
    return self;
}

// View controller can add the view via XIB
- (id)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super initWithCoder:aDecoder]))
    {
        [self initRateView];
    }
    return self;
}

// Refresh view based on the current rating
- (void)updateRateView
{
    // Loop through the list of images
    for(int i=0; i<self.imageViews.count; ++i)
    {
        UIImageView *imageView = [self.imageViews objectAtIndex:i];
        
        // Set the appropriate image based on the rating
        if (self.rating >= i+1)
        {
            imageView.image = self.fullSelectedImage;
        }
        else if (self.rating > i)
        {
            imageView.image = self.halfSelectedImage;
        }
        else
        {
            imageView.image = self.notSelectedImage;
        }
    }
}

// Set up the frames of all subviews whenever the frame of the view changes
- (void)layoutSubviews
{
    [super layoutSubviews];
    
    // Check if the view is already setup
    if (self.notSelectedImage == nil)
    {
        return;
    }
    
    // Calculate the frames for each image
    
    float desiredImageWidth = (self.frame.size.width - (self.outerMargin*2) - (self.midMargin*self.imageViews.count)) / self.imageViews.count;
    
    float imageWidth = MAX(self.minImageSize.width, desiredImageWidth);
    
    float imageHeight = MAX(self.minImageSize.height, self.frame.size.height);
    
    // Loop through the list of images
    for (int i = 0; i < self.imageViews.count; ++i)
    {
        // Set the appropriate frame size
        UIImageView *imageView = [self.imageViews objectAtIndex:i];
        
        CGRect imageFrame = CGRectMake(self.outerMargin + i*(self.midMargin+imageWidth), 0, imageWidth, imageHeight);
        
        imageView.frame = imageFrame;
    }
}

// Set max rating (therefore, how many UIImageViews we have)
- (void)setMaxRating:(int)maxRating
{
    _maxRating = maxRating;
    
    // Remove old image views
    for(int i = 0; i < self.imageViews.count; ++i)
    {
        UIImageView *imageView = (UIImageView *) [self.imageViews objectAtIndex:i];
        
        [imageView removeFromSuperview];
    }
    
    [self.imageViews removeAllObjects];
    
    // Add new image views
    for(int i = 0; i < maxRating; ++i)
    {
        UIImageView *imageView = [[UIImageView alloc] init];
        
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        
        [self.imageViews addObject:imageView];
        
        [self addSubview:imageView];
    }
    
    // Relayout and refresh
    [self setNeedsLayout];
    
    [self updateRateView];
}

// Set image for 'not selected'
- (void)setNotSelectedImage:(UIImage *)image
{
    _notSelectedImage = image;
    
    [self updateRateView];
}

// Set image for 'half selected'
- (void)setHalfSelectedImage:(UIImage *)image
{
    _halfSelectedImage = image;
    
    [self updateRateView];
}

// Set image for 'full selected'
- (void)setFullSelectedImage:(UIImage *)image
{
    _fullSelectedImage = image;
    
    [self updateRateView];
}

// Set rating value
- (void)setRating:(float)rating
{
    _rating = rating;
    
    [self updateRateView];
}

// Handle user interaction
- (void)handleTouchAtLocation:(CGPoint)touchLocation
{
    // Check if that's editable
    if (!self.editable)
    {
        return;
    }
    
    int newRating = 0;
    
    // Loop through the subviews (backwards)
    for(int i = (int)self.imageViews.count - 1; i >= 0; i--)
    {
        UIImageView *imageView = [self.imageViews objectAtIndex:i];
        
        // Compare the x coordinate to that of the subview
        if (touchLocation.x > imageView.frame.origin.x)
        {
            newRating = i+1;
            break;
        }
    }
    
    self.rating = newRating;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    
    CGPoint touchLocation = [touch locationInView:self];
    
    [self handleTouchAtLocation:touchLocation];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    
    CGPoint touchLocation = [touch locationInView:self];
    
    [self handleTouchAtLocation:touchLocation];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.delegate rateView:self ratingDidChange:self.rating];
}

@end
