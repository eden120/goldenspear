//
//  GSCommentTableViewCell.m
//  GoldenSpear
//
//  Created by Adria Vernetta Rubio on 2/5/16.
//  Copyright © 2016 GoldenSpear. All rights reserved.
//

#import "GSCommentTableViewCell.h"
#import "AppDelegate.h"

#define kFontInLabelText @"Avenir-Light"
#define kFontInLabelBoldText @"Avenir-Heavy"
#define kFontSizeInLabelText 16

@implementation GSCommentTableViewCell

- (void)prepareForReuse{
    [super prepareForReuse];
    self.theLabel.text = @"";
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    // Initialization code
    self.theLabel.tintColor = GOLDENSPEAR_COLOR;
    self.theLabel.numberOfLines = 0;
    self.theLabel.font = [UIFont fontWithName:kFontInLabelText size:kFontSizeInLabelText];
    
    [self.theLabel setAttributes:[self getOwnerLinkAttributes:self.theLabel] forLinkType:KILinkTypeOwner];
    
    KILinkTapHandler tapHandler = ^(KILabel *label, NSString *string, NSRange range) {
        [self tappedLinkWithType:KILinkTypeURL andString:string];
    };
    self.theLabel.urlLinkTapHandler = tapHandler;
    tapHandler = ^(KILabel *label, NSString *string, NSRange range) {
        [self tappedLinkWithType:KILinkTypeUserHandle andString:string];
    };
    self.theLabel.userHandleLinkTapHandler = tapHandler;
    tapHandler = ^(KILabel *label, NSString *string, NSRange range) {
        [self tappedLinkWithType:KILinkTypeHashtag andString:string];
    };
    self.theLabel.hashtagLinkTapHandler = tapHandler;
    tapHandler = ^(KILabel *label, NSString *string, NSRange range) {
        [self tappedLinkWithType:KILinkTypeOwner andString:string];
    };
    self.theLabel.ownerLinkTapHandler = tapHandler;
    
    self.selectedBackgroundView = [[UIView alloc] init];
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

@end
