//
//  GSContentView.m
//  GoldenSpear
//
//  Created by Adria Vernetta Rubio on 20/4/16.
//  Copyright © 2016 GoldenSpear. All rights reserved.
//

#import "GSContentView.h"
#import "AppDelegate.h"
@interface GSContentView (){
    
}

@end

@implementation GSContentView

- (void)dealloc{
    self.contentObject = nil;
}

- (id)init{
    NSArray *arrayOfViews = [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class])
                                                          owner:nil
                                                        options:nil];
    int i = 0;
    while(i<[arrayOfViews count]){
        if([[arrayOfViews objectAtIndex:i] isKindOfClass:[self class]]){
            self = [arrayOfViews objectAtIndex:i];
            [self extraSetupView];
            return self;
        }
        i++;
    }
    return nil;
}

- (void)extraSetupView{
    self.translatesAutoresizingMaskIntoConstraints = NO;
    [self initOptionsView];
    [self initComments];
    [self addLostConstraints];
}

- (id) awakeAfterUsingCoder:(NSCoder*)aDecoder {
    if ([[self subviews] count] == 0) {
        return [self init];
    }
    
    return self;
}

- (void)addLostConstraints{
    self.optionsViewHeightConstraint = [NSLayoutConstraint constraintWithItem:self.optionsView
                                                                    attribute:NSLayoutAttributeHeight
                                                                    relatedBy:NSLayoutRelationEqual
                                                                       toItem:nil
                                                                    attribute: NSLayoutAttributeNotAnAttribute
                                                                   multiplier:1
                                                                     constant:46];
    [self.optionsView addConstraint:self.optionsViewHeightConstraint];
}

- (IBAction)likePushed:(UIButton *)sender {
    [self likeContent:!sender.selected];
    AppDelegate *appDelegate = (AppDelegate*) [[UIApplication sharedApplication] delegate];
    if (appDelegate.completeUser) {
        sender.selected = !sender.selected;
    }
}
- (IBAction)getLikePushed:(id)sender {
    [self getLikeUsers];
}

- (IBAction)commentPushed:(id)sender {
    //Show comment Input
    [self commentContent];
}

- (IBAction)closeOptionsGR:(id)sender {
    if (showingOptions) {
        [self showOptions:NO];
    }
}

- (IBAction)optionsPushed:(UIButton *)sender {
    CGPoint anchor = CGPointMake(sender.center.x, sender.superview.frame.origin.y + sender.center.y);
    if(!showingOptions){
        [self.optionsView showUpToDown:YES];
        //Check if it fits screen or show it downToUp
        CGPoint windowPoint = [sender.superview.superview convertPoint:anchor toView:nil];
        CGFloat optionsHeight = self.optionsView.frame.size.height;
        CGFloat selfHeight = self.frame.size.height;
        CGFloat superHeight = [UIScreen mainScreen].bounds.size.height-88;
        if((windowPoint.y+optionsHeight>superHeight)||
           (anchor.y+10+optionsHeight>selfHeight)){
            [self.optionsView showUpToDown:NO];
            optionsHeight = self.optionsView.frame.size.height;
            anchor.y -= 10 + optionsHeight;
        }else{
            anchor.y += 10;
            [self.optionsView showUpToDown:YES];
        }
    }
    [self showOptions:!showingOptions fromPoint:anchor];
}

- (void)showOptions:(BOOL)showOrNot fromPoint:(CGPoint)anchor{
    showingOptions = showOrNot;
    
    if (showOrNot) {
        self.optionsView.alpha = 1;
        self.optionsViewTopConstraint.constant = anchor.y;
        [self.optionsView moveAngleToPosition:anchor.x];
        [self.optionsView layoutIfNeeded];
        
        [self.optionsView.superview bringSubviewToFront:self.optionsView];
    }else{
        [self.optionsView.superview sendSubviewToBack:self.optionsView];
        self.optionsView.alpha = 0;
    }
}

- (void)showOptions:(BOOL)showOrNot{
    [self showOptions:showOrNot fromPoint:CGPointZero];
}

- (void)hideHeaderView:(BOOL)hideOrNot{
    if (hideOrNot) {
        self.headerHeightConstraint.constant = 0;
    }else{
        self.headerHeightConstraint.constant = 44;
    }
    self.contentHeader.hidden = hideOrNot;
    [self layoutIfNeeded];
}

#pragma mark - Protected for subclassing use

- (void)commentContent{
    
}

- (void)likeContent:(BOOL)likeOrNot{
    
}

- (void)getLikeUsers {
    
}

- (void)setContentData:(id)contentObject currentTime:(CMTime)currentTime hasSound:(BOOL)sound{
    
}

- (void)optionsView:(GSOptionsView *)optionView selectOptionAtIndex:(NSInteger)option{
    
}

- (void)initComments{
    
}

- (void)setProfileImage{
    
}

- (void)setLikeState:(BOOL)likedOrNot{
    self.likeButton.selected = likedOrNot;
}

- (void)setLikesNumber:(NSInteger)numberOfLikes{
    self.likesLabel.text = [NSString stringWithFormat:@"%ld LIKES",(long)numberOfLikes];
}

- (void)addCommentObject:(id)comment{
    
}
#pragma mark - GSOptionsViewDelegate

- (void)initOptionsView{
    self.optionsView.viewDelegate = self;
    [self sendSubviewToBack:self.optionsView];
    self.optionsView.alpha = 0;    
}

- (void)optionsView:(GSOptionsView *)optionView heightChanged:(CGFloat)newHeight{
    self.optionsViewHeightConstraint.constant = newHeight;
    [self.optionsView layoutIfNeeded];
}

- (void)taggableView:(GSTaggableView *)taggableView didSelectFashionista:(NSString *)fashionistaId{
    
}

- (void)taggableView:(GSTaggableView *)taggableView didSelectKeywords:(NSArray *)keywordArray categoryTerms:(NSMutableArray*)categoryTerms{
    
}

-(void)taggableView:(GSTaggableView *)taggableView keyWords:(NSMutableDictionary *)searchStringDictionary {
    
}

- (void)taggableView:(GSTaggableView *)taggableView heightChanged:(CGFloat)newHeight{
    self.taggableViewHeight.constant = newHeight;
    [self.taggableView layoutIfNeeded];
    [self.contentScroll layoutIfNeeded];
    [self.viewDelegate contentView:self heightChanged:self.contentScroll.contentSize.height reason:GSPostContentHeightChangeReasonImage forceResize:NO];
}

- (void)collapsableLabelContainer:(GSCollapsableLabelContainer *)collapsableView heightChanged:(CGFloat)newHeight{
    self.commentsViewHeightConstraint.constant = newHeight;
    [self.commentsTableView layoutIfNeeded];
    [self layoutIfNeeded];
    [self.viewDelegate contentView:self heightChanged:self.contentScroll.contentSize.height reason:GSPostContentHeightChangeReasonComments forceResize:NO];
}

- (void)collapsableLabelContainer:(GSCollapsableLabelContainer *)collapsableView userTapped:(NSString *)username{
    
}

- (void)collapsableLabelContainer:(GSCollapsableLabelContainer *)collapsableView hashtagTapped:(NSString *)hashtag{
    
}

- (void)collapsableLabelContainer:(GSCollapsableLabelContainer *)collapsableView urlTapped:(NSString *)url{
    
}

- (void)collapsableLabelContainer:(GSCollapsableLabelContainer *)collapsableView ownerTapped:(NSString *)owner{
    
}

@end
