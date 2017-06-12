//
//  GSTagView.m
//  GoldenSpear
//
//  Created by JCB on 8/26/16.
//  Copyright © 2016 GoldenSpear. All rights reserved.
//

#import "GSTagView.h"

@interface GSTagView (){
    NSMutableArray* optionButtons;
    BOOL isUpToDown;
}

@end

@implementation GSTagView

- (id)init{
    NSArray *arrayOfViews = [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class])
                                                          owner:nil
                                                        options:nil];
    if ([arrayOfViews count] < 1){
        return nil;
    }
    self = [arrayOfViews objectAtIndex:0];
    self.translatesAutoresizingMaskIntoConstraints = NO;
    _optionsContainer.superview.layer.cornerRadius = 5;
    return self;
}

- (id) awakeAfterUsingCoder:(NSCoder*)aDecoder {
    if ([[self subviews] count] == 0) {
        return [self init];
    }
    
    return self;
}

- (id)initWithWidth:(CGFloat)viewWidth andOptions:(NSArray*)optionsArray{
    self = [super init];
    /*
     CGRect myFrame = self.frame;
     myFrame.size.width = viewWidth;
     self.frame = myFrame;
     
     [self setOptions:optionsArray];
     [self layoutOptionButtons];
     */
    return self;
}

- (void)dealloc{
    [optionButtons removeAllObjects];
    optionButtons = nil;
}

- (void)setOptions:(NSArray*)optionsArray{
    for (UIButton* b in optionButtons) {
        [b removeFromSuperview];
    }
    [optionButtons removeAllObjects];
    optionButtons = [NSMutableArray new];
    
    for (NSString* optionTitle in optionsArray) {
        UIButton* optionButton = [UIButton buttonWithType:UIButtonTypeCustom];
        optionButton.titleLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightMedium];
        [optionButton addTarget:self action:@selector(pushOptionAtIndex:) forControlEvents:UIControlEventTouchUpInside];
        
        [optionButton setTitle:optionTitle forState:UIControlStateNormal];
        
        optionButton.tag = [optionButtons count];
        [optionButton sizeToFit];
        [optionButtons addObject:optionButton];
    }
    [self layoutOptionButtons];
}

- (void)layoutSubviews{
    [super layoutSubviews];
    [self layoutOptionButtons];
}

- (void)layoutOptionButtons{
    for(UIView* v in _optionsContainer.subviews){
        [v removeFromSuperview];
    }
    
    CGFloat oldHeight = _optionsContainer.frame.size.height;
    
    CGFloat maxWidth = _optionsContainer.frame.size.width;
    CGFloat separatorWidth = 2;
    CGFloat buttonHeight = 30;
    CGFloat verticalMargin = 3;
    CGFloat separatorHeight = buttonHeight - 10;
    
    CGFloat separatorMargin = 5;
    CGFloat distanceBetweenOptions = 2*separatorMargin+separatorWidth;
    
    CGFloat currentRowWidth = 0;
    CGFloat currentY = 0;
    UIView* currentRow = nil;
    BOOL addSeparator;
    
    for(UIButton* b in optionButtons){
        CGFloat thisButtonWidth = b.frame.size.width;
        if (currentRowWidth>0) {
            //Check if we can add another button in the row
            if((currentRowWidth+distanceBetweenOptions+thisButtonWidth)>maxWidth){
                currentRow.frame = CGRectMake(floorf((maxWidth-currentRowWidth)/2), currentY, currentRowWidth, buttonHeight);
                [_optionsContainer addSubview:currentRow];
                currentY += currentRow.frame.size.height + verticalMargin;
                currentRow = nil;
            }
        }
        
        addSeparator = YES;
        if (!currentRow) {
            currentRow = [UIView new];
            currentRowWidth = 0;
            addSeparator = NO;
        }
        
        if(addSeparator){
            UIView* separatorView = [UIView new];
            separatorView.backgroundColor = [UIColor whiteColor];
            separatorView.frame = CGRectMake(currentRowWidth+separatorMargin, floorf((buttonHeight-separatorHeight)/2), separatorWidth, separatorHeight);
            [currentRow addSubview:separatorView];
            currentRowWidth += distanceBetweenOptions;
        }
        
        CGRect buttonFrame = b.frame;
        buttonFrame.origin.x = currentRowWidth;
        b.frame = buttonFrame;
        currentRowWidth += thisButtonWidth;
        [currentRow addSubview:b];
    }
    
    //Add last row
    currentRow.frame = CGRectMake(floorf((maxWidth-currentRowWidth)/2), currentY, currentRowWidth, buttonHeight);
    [_optionsContainer addSubview:currentRow];
    CGFloat newHeight = currentY+buttonHeight;
    if (oldHeight!=newHeight) {
        [self setNewHeight:newHeight];
    }
}

- (void)setNewHeight:(CGFloat)newHeight{
    [_viewDelegate tagView:self heightChanged:newHeight+46];
}

- (void)showUpToDown:(BOOL)upToDownOrNot{
    isUpToDown = upToDownOrNot;
    
    [self layoutIfNeeded];
}

@end

