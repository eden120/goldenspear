//
//  GSCollapsableLabelContainer.m
//  GoldenSpear
//
//  Created by Adria Vernetta Rubio on 20/4/16.
//  Copyright © 2016 GoldenSpear. All rights reserved.
//

#import "GSCollapsableLabelContainer.h"
#import "Comment.h"
#import "AppDelegate.h"

#define kFontInLabelText @"Avenir-Light"
#define kFontInLabelBoldText @"Avenir-Heavy"
#define kFontSizeInLabelText 16

@interface GSCollapsableLabelContainer (){
    NSMutableArray* labelArray;
    BOOL collapsedLabels;
    UIButton* expandButton;
    CGFloat previousWidth;
    NSMutableArray* objectsArray;
}

@end

@implementation GSCollapsableLabelContainer

- (instancetype)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    self.translatesAutoresizingMaskIntoConstraints = NO;
    return self;
}

- (void)collapseWithMoreThan:(NSInteger)maxLabels{
    maxLabelNum = maxLabels;
    [self setNeedsDisplay];
}

- (void)redrawView{
    for(UIView* v in labelArray){
        v.hidden = YES;
    }
    [self updateHeightCalculations];
}

- (void)setLabelsWithArray:(NSArray*)objectArray{
    for(UIView* v in self.subviews){
        [v removeFromSuperview];
    }
    [labelArray removeAllObjects];
    labelArray = [NSMutableArray new];
    [objectsArray removeAllObjects];
    objectArray = [NSMutableArray new];
    
    collapsedLabels = YES;
    
    for(id object in objectArray){
        [self addLabelWithObject:object];
    }
    if([objectArray count]>0){
        expandButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [expandButton setTitle:@"..." forState:UIControlStateNormal];
        expandButton.backgroundColor = [UIColor lightGrayColor];
        expandButton.layer.cornerRadius = 5;
        [expandButton sizeToFit];
        CGRect theFrame = expandButton.frame;
        theFrame.size.height = 25;
        expandButton.frame = theFrame;
        [expandButton addTarget:self action:@selector(expandLabels:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:expandButton];
    }
    [self updateHeightCalculations];
}

- (void)expandLabels:(UIButton*)sender{
    collapsedLabels = NO;
    [self updateHeightCalculations];
    [self setNeedsDisplay];
}

- (NSDictionary*)getOwnerLinkAttributes:(KILabel*)label{
    NSShadow *shadow = shadow = [[NSShadow alloc] init];
    if (label.shadowColor)
    {
        shadow.shadowColor = label.shadowColor;
        shadow.shadowOffset = label.shadowOffset;
    }
    else
    {
        shadow.shadowOffset = CGSizeMake(0, -1);
        shadow.shadowColor = nil;
    }
    
    // Setup paragraph attributes
    NSMutableParagraphStyle *paragraph = [[NSMutableParagraphStyle alloc] init];
    paragraph.alignment = label.textAlignment;
    
    NSDictionary *attributes = @{NSFontAttributeName : [UIFont fontWithName:kFontInLabelBoldText size:kFontSizeInLabelText],
                                 NSForegroundColorAttributeName : [UIColor blackColor],
                                 NSShadowAttributeName : shadow,
                                 NSParagraphStyleAttributeName : paragraph,
                                 };
    return attributes;
}

- (KILabel*)getBaseLabel{
    KILabel* newLabel = [KILabel new];
    newLabel.tintColor = GOLDENSPEAR_COLOR;
    newLabel.numberOfLines = 0;
    newLabel.hidden = YES;
    newLabel.font = [UIFont fontWithName:kFontInLabelText size:kFontSizeInLabelText];

    [newLabel setAttributes:[self getOwnerLinkAttributes:newLabel] forLinkType:KILinkTypeOwner];
    
    [self addSubview:newLabel];
    [self sendSubviewToBack:newLabel];
    newLabel.tag = [labelArray count];
    
    KILinkTapHandler tapHandler = ^(KILabel *label, NSString *string, NSRange range) {
        [self tappedLinkWithType:KILinkTypeURL andString:string];
    };
    newLabel.urlLinkTapHandler = tapHandler;
    tapHandler = ^(KILabel *label, NSString *string, NSRange range) {
        [self tappedLinkWithType:KILinkTypeUserHandle andString:string];
    };
    newLabel.userHandleLinkTapHandler = tapHandler;
    tapHandler = ^(KILabel *label, NSString *string, NSRange range) {
        [self tappedLinkWithType:KILinkTypeHashtag andString:string];
    };
    newLabel.hashtagLinkTapHandler = tapHandler;
    tapHandler = ^(KILabel *label, NSString *string, NSRange range) {
        [self tappedLinkWithType:KILinkTypeOwner andString:string];
    };
    newLabel.ownerLinkTapHandler = tapHandler;
    return newLabel;
}

- (void)tappedLinkWithType:(KILinkType)linkType andString:(NSString*)string{
    switch (linkType) {
        case KILinkTypeHashtag:
            [self.viewDelegate collapsableLabelContainer:self hashtagTapped:string];
            break;
        case KILinkTypeOwner:
            [self.viewDelegate collapsableLabelContainer:self ownerTapped:string];
            break;
        case KILinkTypeURL:
            [self.viewDelegate collapsableLabelContainer:self urlTapped:string];
            break;
        case KILinkTypeUserHandle:
            [self.viewDelegate collapsableLabelContainer:self userTapped:string];
            break;
        default:
            break;
    }
}

- (void)addLabelWithObject:(id)object{
    if([object isKindOfClass:[NSString class]]){
        KILabel* newLabel = [self getBaseLabel];
        newLabel.linkDetectionTypes = KILinkTypeOptionNone;
        newLabel.text = (NSString*)object;
        [newLabel sizeToFit];
        [objectsArray addObject:object];
    }else if([object isKindOfClass:[Comment class]]){
        Comment* aComment = (Comment*)object;
        KILabel* newLabel = [self getBaseLabel];
        newLabel.text = [NSString stringWithFormat:@"%@ %@",aComment.fashionistaPostName,aComment.text];
        [newLabel sizeToFit];
        [objectsArray addObject:object];
    }
}

- (void)layoutSubviews{
    [super layoutSubviews];
    BOOL updateHeight = (previousWidth!=self.frame.size.width);
    previousWidth = self.frame.size.width;
    if (updateHeight) {
        [self updateHeightCalculations];
    }
    
}

- (void)setFrame:(CGRect)frame{
    previousWidth = self.frame.size.width;
    [super setFrame:frame];
    if (previousWidth!=frame.size.width) {
        [self updateHeightCalculations];
    }
}

- (void)updateHeightCalculations{
    CGRect theFrame = self.bounds;
    CGFloat originalHeight = theFrame.size.height;
    
    CGFloat yMargin = 10;
    CGFloat xMargin = 20;
    theFrame.origin.x = xMargin;
    theFrame.size.width -= xMargin*2;
    theFrame.size.height = 0;
    CGSize constrainedSize = CGSizeMake(theFrame.size.width, CGFLOAT_MAX);
    if (maxLabelNum!=0&&maxLabelNum<[labelArray count]&&collapsedLabels) {
        //Draw collapsed
        [self bringSubviewToFront:expandButton];
        expandButton.hidden = NO;
        //Draw first
        KILabel* label = [labelArray firstObject];
        label.hidden = NO;
        CGRect requiredHeight = [label.text boundingRectWithSize:constrainedSize
                                                         options:NSStringDrawingUsesLineFragmentOrigin
                                                      attributes:@{NSFontAttributeName:label.font}
                                                         context:nil];
        theFrame.size.height = requiredHeight.size.height;
        label.frame = theFrame;
        theFrame.origin.y +=theFrame.size.height+yMargin;
        
        //Draw Button
        CGPoint buttonCenter = self.center;
        buttonCenter.y = theFrame.origin.y+expandButton.frame.size.height/2;
        expandButton.center = buttonCenter;
        theFrame.origin.y += expandButton.frame.size.height+yMargin;
        
        //Draw maxLabelNum-1 last
        for(NSUInteger i = ([labelArray count]-maxLabelNum+1);i<[labelArray count];i++){
            label = [labelArray objectAtIndex:i];
            label.hidden = NO;
            CGRect requiredHeight = [label.text boundingRectWithSize:constrainedSize
                                                             options:NSStringDrawingUsesLineFragmentOrigin
                                                          attributes:@{NSFontAttributeName:label.font}
                                                             context:nil];
            theFrame.size.height = requiredHeight.size.height;
            label.frame = theFrame;
            theFrame.origin.y +=theFrame.size.height+yMargin;
        }
    }else{
        //Draw all
        [self sendSubviewToBack:expandButton];
        expandButton.hidden = YES;
        
        for(KILabel* label in labelArray){
            label.hidden = NO;
            CGRect requiredHeight = [label.text boundingRectWithSize:constrainedSize
                                                             options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading
                                                          attributes:@{NSFontAttributeName:label.font}
                                                             context:nil];
            theFrame.size.height = ceilf(requiredHeight.size.height);
            label.frame = theFrame;
            theFrame.origin.y +=theFrame.size.height+yMargin;
        }
    }
    CGFloat totalHeight = MAX(theFrame.origin.y,yMargin);
    if (originalHeight!=totalHeight) {
        [self.viewDelegate collapsableLabelContainer:self heightChanged:totalHeight];
    }
}

@end
