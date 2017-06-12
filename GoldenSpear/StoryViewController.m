//
//  StoryViewController.m
//  GoldenSpear
//
//  Created by JCB on 9/1/16.
//  Copyright © 2016 GoldenSpear. All rights reserved.
//

#include "StoryViewController.h"
#include "SlideViewController.h"
#include "ShareViewController.h"
#include "UIImageView+WebCache.h"
#include "BaseViewController+StoryboardManagement.h"
#include "BaseViewController+TopBarManagement.h"
#include "BaseViewController+BottomControlsManagement.h"

#define TextContentCell @"textContentCell"
#define ImageContentCell @"imageContentCell"
#define SlideContentCell @"slideContentCell"
#define VideoContentCell @"videoContentCell"

#define STORYVIEW   0
#define SHAREVIEW   1
#define RELATEDVIEW 2
#define MOREVIEW    3

@implementation imageContentCell

@end

@implementation textContentCell

@end

@implementation videoContentCell

-(void)dealloc {
    [player.player removeObserver:self forKeyPath:@"rate"];
    [player removeObserver:self forKeyPath:@"readyForDisplay"];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    player = nil;
}

-(void)awakeFromNib {
    [super awakeFromNib];
}

-(void)manageVideoPlay:(BOOL)playOrNot {
    if(playOrNot){
        if(player){
            [self.imageView.superview sendSubviewToBack:self.imageView];
            [player.player play];
        }
    }else{
        if(playing&&player){
            [self.imageView.superview bringSubviewToFront:self.imageView];
            [player.player pause];
        }
    }
}

- (void)playerItemDidReachEnd:(NSNotification *)notification {
    AVPlayerItem *p = [notification object];
    [p seekToTime:kCMTimeZero];
}

- (void)stopVideo{
    if(player){
        [self manageVideoPlay:NO];
        player.player.volume = 0;
        self.audioButton.selected = NO;
    }
}

- (void)startVideo{
    if(player){
        [self manageVideoPlay:YES];
    }
}

- (void)setVideoWithURL:(NSString*)videourl currentTime:(CMTime)currentTime hasSound:(BOOL)sound {
    if (videourl==nil) {
        [player.view removeFromSuperview];
        [player.player removeObserver:self forKeyPath:@"rate"];
        [player removeObserver:self forKeyPath:@"readyForDisplay"];
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        player = nil;
        self.audioButton.hidden = YES;
        [self.audioButton.superview sendSubviewToBack:self.audioButton];
    }else{
        videoURL = videourl;
        NSLog(@"Video URL : %@", videourl);
        playing = NO;
        player = [[AVPlayerViewController alloc] init];
        
        NSError *_error = nil;
        [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryAmbient error: &_error];
        [[AVAudioSession sharedInstance] setActive:NO error:nil];
        
        player.player = [AVPlayer playerWithURL:[NSURL URLWithString:videoURL]];
        player.showsPlaybackControls = YES;
        player.player.actionAtItemEnd = AVPlayerActionAtItemEndNone;
        [player.player seekToTime:currentTime];
        
        player.view.frame = self.videoContainer.bounds;
        
        int h = player.view.frame.size.height;
        
        UIView * pView = player.view;
        // Insert View into Post View
        [self.videoContainer addSubview:pView];
        [pView.superview bringSubviewToFront:pView];
        [player.player addObserver:self forKeyPath:@"rate" options:0 context:nil];
        [player addObserver:self forKeyPath:@"readyForDisplay" options:0 context:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(playerItemDidReachEnd:)
                                                     name:AVPlayerItemDidPlayToEndTimeNotification
                                                   object:[player.player currentItem]];
        
        self.audioButton.hidden = NO;
        [self.audioButton.superview bringSubviewToFront:self.audioButton];
        if (sound) {
            player.player.volume = 1;
        }
        else {
            player.player.volume = 0;
        }
        self.audioButton.selected = sound;
    }
}

- (IBAction)audioPushed:(UIButton *)sender {
    sender.selected = !sender.selected;
    if(sender.selected){
        player.player.volume = 1;
        NSError *_error = nil;
        [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryPlayback error: &_error];
    }else{
        player.player.volume = 0;
        NSError *_error = nil;
        [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryAmbient error: &_error];
        [[AVAudioSession sharedInstance] setActive:NO error:nil];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"rate"]) {
        if ([player.player rate]) {
            playing = YES;
        }else{
            playing = NO;
            [self manageVideoPlay:NO];
        }
    }else if ([keyPath isEqualToString:@"readyForDisplay"]) {
        if (player.readyForDisplay&&!playing)
        {
            [self manageVideoPlay:YES];
        }
    }
}

-(NSString*)getVideoURL {
    
    return videoURL;
}

-(CMTime)getVideoPlayer {
    CMTime currentTime = player.player.currentItem.currentTime;
    [player.player pause];
    return currentTime;
}

-(BOOL)hasSoundNow {
    if (player.player.volume == 0) {
        return false;
    }
    return true;
}

-(void)setPlayer:(CMTime)videoPlayer hasSound:(BOOL)sound {
    [player.player seekToTime:videoPlayer];
    hasSound = sound;
}


@end

@implementation slideContentCell

@end

@interface StoryViewController()

@end

@implementation StoryViewController {
    BOOL isHideFullCaption;
    NSInteger storyType;
    NSMutableArray *cellData;
    NSMutableArray *slideContents;
    NSMutableArray* visibleCells;
    NSInteger currentIndex;
    NSInteger currentView;
}

-(void)viewDidLoad {
    [super viewDidLoad];
    
    visibleCells = [NSMutableArray new];
    [self getCellData];
    //[_contentList reloadData];
    [_contentList setSeparatorColor:[UIColor whiteColor]];
    
    shareVC = [self.storyboard instantiateViewControllerWithIdentifier:@"ShareViewVC"];
    [self initMoreViews];
    [self initRelatedViews];
    currentIndex = 0;
    currentView = STORYVIEW;
}

-(BOOL) shouldCreateTopBar {
    return NO;
}

-(BOOL)shouldCreateMenuButton {
    return NO;
}

-(void)panGesture:(UIPanGestureRecognizer *)sender {
    
    CGPoint velocity = [sender velocityInView:self.view];
    
    CGPoint translation = [sender translationInView:self.view];
    
    CGFloat widthPercentage  = fabs(translation.x / CGRectGetWidth(sender.view.bounds));
    
    CGFloat heightPercentage  = fabs(translation.y / CGRectGetHeight(sender.view.bounds));
    
    if(sender.state == UIGestureRecognizerStateEnded)
    {
        // Perform the transition when swipe right
        if (velocity.x > 0)
        {
            if(widthPercentage > 0.3)
            {
                //[self swipeRightAction];
            }
        }
        
        // Perform the transition when swipe left
        if (velocity.x < 0)
        {
            if(widthPercentage > 0.3)
            {
                //[self swipeLeftAction];
            }
        }
        
        // Show the advanced search when swipe up
        if (velocity.y < 0)
        {
            if(heightPercentage > 0.3)
            {
                switch (currentView) {
                    case STORYVIEW:
                    {
                        if (currentIndex == [cellData count] - 1) {
                            [self showShareView];
                            return;
                        }
                        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:currentIndex + 1 inSection:0];
                        [_contentList scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
                        currentIndex = currentIndex + 1;
                        break;
                    }
                    case SHAREVIEW:
                    {
                        [self showRelatedMagazineView];
                        break;
                    }
                    case RELATEDVIEW:
                    {
                        [self showMoreMagazineView];
                        break;
                    }
                    case MOREVIEW:
                    {
                        break;
                    }
                    default:
                        break;
                }

            }
        }
        
        // Hide the advanced search when swipe up
        if (velocity.y > 0)
        {
            if(heightPercentage > 0.3)
            {
                switch (currentView) {
                    case STORYVIEW:
                    {
                        if (currentIndex == 0) {
                            [self dismissViewControllerAnimated:YES completion:nil];
                            return;
                        }
                        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:currentIndex - 1 inSection:0];
                        [_contentList scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
                        currentIndex = currentIndex - 1;
                        break;
                    }
                    case SHAREVIEW:
                    {
                        [self hideShareView];
                        break;
                    }
                    case RELATEDVIEW:
                    {
                        [self hideRelatedMagazineView];
                        break;
                    }
                    case MOREVIEW:
                    {
                        [self hideMoreMagazineView];
                        break;
                    }
                    default:
                        break;
                }
            }
        }
    }
}

-(void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    for (videoContentCell *cell in visibleCells) {
        if ([cell isKindOfClass:[videoContentCell class]]) {
            [cell startVideo];
        }
    }
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
}

- (void)stopVisibleCells{
    for (videoContentCell* cell in visibleCells) {
        if ([cell isKindOfClass:[videoContentCell class]]) {
            [cell stopVideo];
        }
    }
}

-(void)initView {
}

-(NSInteger)getViewHeight {
    return 0;
}

-(void)showShareView {
    
    UIView *toView = shareVC.view;
    CGRect toframe = self.swipeView.frame;

    toframe.origin.y = toframe.size.height;
    toView.frame = toframe;
    toframe.origin.y = 0;
    
    [UIView animateWithDuration:0.8
                          delay:0
                        options: UIViewAnimationCurveEaseIn
                     animations:^{
                         [toView setFrame:toframe];
                     }
                     completion:^(BOOL finished){
                         
                     }];
    [self.view addSubview:toView];
    currentView = SHAREVIEW;
}

-(void)hideShareView {
    UIView *fromView = shareVC.view;
    CGRect fromframe = self.swipeView.frame;
    
    fromframe.origin.y = fromframe.size.height;
    
    [UIView animateWithDuration:0.8
                          delay:0
                        options: UIViewAnimationCurveEaseIn
                     animations:^{
                         [fromView setFrame:fromframe];
                     }
                     completion:^(BOOL finished){
                         
                     }];
    currentView = STORYVIEW;
}

-(void)showMoreMagazineView {
    
    UIView *moreView = magazineMoreVC.view;
    CGRect frame = self.swipeView.frame;
    
    frame.origin.y = frame.size.height;
    moreView.frame = frame;
    frame.origin.y = 0;
    
    [UIView animateWithDuration:0.8
                          delay:0
                        options: UIViewAnimationCurveEaseIn
                     animations:^{
                         [moreView setFrame:frame];
                     }
                     completion:^(BOOL finished){
                         [self.view setUserInteractionEnabled:YES];
                     }];
    [self.view addSubview:moreView];
    currentView = MOREVIEW;
}

-(void)hideMoreMagazineView {
    UIView *fromView = magazineMoreVC.view;
    CGRect fromframe = self.swipeView.frame;
    
    fromframe.origin.y = fromframe.size.height;
    
    [UIView animateWithDuration:0.8
                          delay:0
                        options: UIViewAnimationCurveEaseIn
                     animations:^{
                         [fromView setFrame:fromframe];
                     }
                     completion:^(BOOL finished){
                         
                     }];
    currentView = RELATEDVIEW;
}

-(void)showRelatedMagazineView {
    
    UIView *relatedView = magazineRelatedVC.view;
    CGRect frame = self.swipeView.frame;
    
    frame.origin.y = frame.size.height;
    relatedView.frame = frame;
    frame.origin.y = 0;
    
    [UIView animateWithDuration:0.8
                          delay:0
                        options: UIViewAnimationCurveEaseIn
                     animations:^{
                         [relatedView setFrame:frame];
                     }
                     completion:^(BOOL finished){
                         [self.view setUserInteractionEnabled:YES];
                     }];
    [self.view addSubview:relatedView];
    currentView = RELATEDVIEW;
}

-(void)hideRelatedMagazineView {
    UIView *fromView = magazineRelatedVC.view;
    CGRect fromframe = self.swipeView.frame;
    
    fromframe.origin.y = fromframe.size.height;
    
    [UIView animateWithDuration:0.8
                          delay:0
                        options: UIViewAnimationCurveEaseIn
                     animations:^{
                         [fromView setFrame:fromframe];
                     }
                     completion:^(BOOL finished){
                         
                     }];
    currentView = SHAREVIEW;
}

-(void)initMoreViews {
    magazineMoreVC = [self.storyboard instantiateViewControllerWithIdentifier:@"MagazineMoreVC"];
    magazineMoreVC.posts = _moreMagazines;
}

-(void)initRelatedViews {
    magazineRelatedVC = [self.storyboard instantiateViewControllerWithIdentifier:@"MagazineRelationVC"];
    magazineRelatedVC.posts = _relatedMagazines;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger n = [cellData count];
    return [cellData count];
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGSize maximumLabelSize = CGSizeMake(self.view.bounds.size.width, FLT_MAX);
    
    if ([[cellData objectAtIndex:indexPath.row] isKindOfClass:[FashionistaContent class]]) {
        FashionistaContent *content = [cellData objectAtIndex:indexPath.row];
        NSLog(@"Content Image : %@", content.image);
        
        /////////////   Image Content    ///////////////////////
        if (![content.image isEqualToString:@""] && content.image != nil) {
            imageContentCell *cell = [tableView dequeueReusableCellWithIdentifier:ImageContentCell];
            
            [cell.preview_image sd_setImageWithURL:[NSURL URLWithString:content.image]];
            NSLog(@"ImageText : %@", content.imageText);
            cell.imageLabel.hidden = NO;
            cell.showFullViewButton.hidden = NO;
            if ([content.imageText isEqualToString:@""] || content.imageText == nil) {
                cell.imageLabel.hidden = YES;
                cell.showFullViewButton.hidden = YES;
            }
            cell.showFullViewButton.tag = indexPath.row;
            [cell.showFullViewButton addTarget:self action:@selector(onTapShowFullCaption:) forControlEvents:UIControlEventTouchUpInside];
            cell.closeFullViewButton.tag = indexPath.row;
            [cell.closeFullViewButton addTarget:self action:@selector(onTapHideFullCaption:) forControlEvents:UIControlEventTouchUpInside];
            cell.imageLabel.text = content.imageText;
            CGSize aheadLabelExpectedSize = [content.imageText sizeWithFont:[UIFont fontWithName:@"Avenir-Heavy" size:16] constrainedToSize:maximumLabelSize lineBreakMode:UILineBreakModeWordWrap];
            cell.aheadLabelHeightConstraint.constant = aheadLabelExpectedSize.height;
            cell.aheadLabel.text = content.imageText;
            cell.fullCaptionView.hidden = YES;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            if (![visibleCells containsObject:cell]) {
                [visibleCells addObject:cell];
            }
            return cell;
        }
        /////////////   Video Content    ///////////////////////
        else if (![content.video isEqualToString:@""] && content.video != nil) {
            videoContentCell *cell = [tableView dequeueReusableCellWithIdentifier:VideoContentCell];
            [cell setVideoWithURL:content.video currentTime:kCMTimeZero hasSound:NO];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            if (![visibleCells containsObject:cell]) {
                [visibleCells addObject:cell];
            }
            return cell;
        }
        /////////////   Text Content    ///////////////////////
        else {
            textContentCell *cell = [tableView dequeueReusableCellWithIdentifier:TextContentCell];
            cell.storyLabel.text = content.text;
            CGSize storyLabelExpectedSize = [content.text sizeWithFont:[UIFont fontWithName:@"Avenir-Heavy" size:30] constrainedToSize:maximumLabelSize lineBreakMode:UILineBreakModeWordWrap];
            CGRect frame = cell.frame;
            cell.storyLabelHeightConstraint.constant = storyLabelExpectedSize.height + 10;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            if (![visibleCells containsObject:cell]) {
                [visibleCells addObject:cell];
            }
            return cell;
        }
    }
    else if ([[cellData objectAtIndex:indexPath.row] isKindOfClass:[NSMutableArray class]]) {
        NSMutableArray *contents = [NSMutableArray new];
        contents = [cellData objectAtIndex:indexPath.row];
        FashionistaContent *content = [contents firstObject];
        
        /////////////   Image Content    ///////////////////////
        if ([contents count] == 1) {
            imageContentCell *cell = [tableView dequeueReusableCellWithIdentifier:ImageContentCell];
            
            [cell.preview_image sd_setImageWithURL:[NSURL URLWithString:content.image]];
            NSLog(@"ImageText : %@", content.imageText);
            cell.imageLabel.hidden = NO;
            cell.showFullViewButton.hidden = NO;
            if ([content.imageText isEqualToString:@""] || content.imageText == nil) {
                cell.imageLabel.hidden = YES;
                cell.showFullViewButton.hidden = YES;
            }
            cell.showFullViewButton.tag = indexPath.row;
            [cell.showFullViewButton addTarget:self action:@selector(onTapShowFullCaption:) forControlEvents:UIControlEventTouchUpInside];
            cell.closeFullViewButton.tag = indexPath.row;
            [cell.closeFullViewButton addTarget:self action:@selector(onTapHideFullCaption:) forControlEvents:UIControlEventTouchUpInside];
            cell.imageLabel.text = content.imageText;
            CGSize aheadLabelExpectedSize = [content.imageText sizeWithFont:[UIFont fontWithName:@"Avenir-Heavy" size:16] constrainedToSize:maximumLabelSize lineBreakMode:UILineBreakModeWordWrap];
            cell.aheadLabelHeightConstraint.constant = aheadLabelExpectedSize.height;
            cell.aheadLabel.text = content.imageText;
            cell.fullCaptionView.hidden = YES;
            cell.fullCaptionView.clipsToBounds = YES;
            cell.fullCaptionView.layer.cornerRadius = 10;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            if (![visibleCells containsObject:cell]) {
                [visibleCells addObject:cell];
            }
            return cell;
        }
        
        /////////////   Slide Content    ///////////////////////
        slideContentCell *cell = [tableView dequeueReusableCellWithIdentifier:SlideContentCell];
        [cell.preview_image sd_setImageWithURL:[NSURL URLWithString:content.image]];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.showSlideButton.tag = indexPath.row;
        [cell.showSlideButton addTarget:self action:@selector(onTapSlideShow:) forControlEvents:UIControlEventTouchUpInside];
        if (![visibleCells containsObject:cell]) {
            [visibleCells addObject:cell];
        }
        return cell;
    }
    return nil;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([[cellData objectAtIndex:indexPath.row] isKindOfClass:[FashionistaContent class]]) {
        FashionistaContent *content = [cellData objectAtIndex:indexPath.row];
        NSLog(@"Content Image : %@", content.image);
        return [self getEstimatedHeight:content];
    }
    else if ([[cellData objectAtIndex:indexPath.row] isKindOfClass:[NSMutableArray class]]) {
        NSMutableArray *contents = [NSMutableArray new];
        contents = [cellData objectAtIndex:indexPath.row];
        FashionistaContent *content = [contents firstObject];
        return [self getEstimatedHeight:content];
    }

    return 0;
}

-(void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([[cellData objectAtIndex:indexPath.row] isKindOfClass:[FashionistaContent class]]) {
        FashionistaContent *content = [cellData objectAtIndex:indexPath.row];
        if (content.video != nil && ![content.video isEqualToString:@""]) {
            [(videoContentCell*)cell stopVideo];
        }
    }
    [visibleCells removeObject:cell];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"select cell");
}

-(void)onTapSlideShow:(UIButton*)sender {
    NSMutableArray *images = [NSMutableArray new];
    NSMutableArray *contents = [cellData objectAtIndex:sender.tag];
    for (int i = 0; i < [contents count]; i ++) {
        FashionistaContent *content = [contents objectAtIndex:i];
        [images addObject:content.image];
    }
    
    SlideViewController *slideVC = [self.storyboard instantiateViewControllerWithIdentifier:@"SlideViewVC"];
    
    slideVC.isHideFullCaption = isHideFullCaption;
    slideVC.images = images;
    
    [self presentViewController:slideVC animated:YES completion:nil];
}
-(void)onTapShowFullCaption:(UIButton*)sender {
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:sender.tag inSection:0];
    imageContentCell *cell = (imageContentCell*)[_contentList cellForRowAtIndexPath:indexPath];
    CGRect frame = cell.fullCaptionView.frame;
    frame.origin.x = self.view.bounds.size.width;
    cell.fullCaptionView.frame = frame;
    cell.fullCaptionView.hidden = NO;
    
    frame.origin.x = 20;
    
    [UIView animateWithDuration:0.6
                               delay:0.1
                             options: UIViewAnimationCurveEaseIn
                          animations:^{
                              cell.fullCaptionView.frame = frame;
                          }
                          completion:^(BOOL finished){
     
                          }];
}

-(void)onTapHideFullCaption:(UIButton*)sender {
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:sender.tag inSection:0];
    imageContentCell *cell = (imageContentCell*)[_contentList cellForRowAtIndexPath:indexPath];
    CGRect frame = cell.fullCaptionView.frame;
    frame.origin.x = self.view.bounds.size.width;
    
    [UIView animateWithDuration:0.6
                          delay:0.1
                        options: UIViewAnimationCurveEaseIn
                     animations:^{
                         cell.fullCaptionView.frame = frame;
                     }
                     completion:^(BOOL finished){
                         cell.fullCaptionView.hidden = YES;
                     }];
}

-(CGFloat)getEstimatedHeight:(FashionistaContent*)content {
    CGSize maximumLabelSize = CGSizeMake(self.view.frame.size.width, FLT_MAX);
    
    if (![content.image isEqualToString:@""] && content.image != nil) {
        if ([content.image_height integerValue] == 0) {
            return 400;
        }
        CGFloat height = [content.image_height integerValue] * self.view.bounds.size.width / [content.image_width integerValue];
        CGSize aheadLabelExpectedSize = [content.imageText sizeWithFont:[UIFont fontWithName:@"Avenir-Heavy" size:16] constrainedToSize:maximumLabelSize lineBreakMode:UILineBreakModeWordWrap];
        if (height > aheadLabelExpectedSize.height + 43) {
            return height;
        }
        else {
            return aheadLabelExpectedSize.height + 43;
        }
    }
    else if (![content.video isEqualToString:@""] && content.video != nil) {
        if ([content.image_height integerValue] == 0) {
            return 400;
        }
        CGFloat height = [content.image_height integerValue] * self.view.bounds.size.width / [content.image_width integerValue];
        return height;
    }
    else {
        CGSize storyLabelExpectedSize = [content.text sizeWithFont:[UIFont fontWithName:@"Avenir-Heavy" size:30] constrainedToSize:maximumLabelSize lineBreakMode:UILineBreakModeWordWrap];
        
        NSLog(@"StoryLabel text : %@", content.text);
        
        return storyLabelExpectedSize.height + 5;
    }
    return 0;
}

-(void)getCellData {
    NSMutableArray *temp;
    temp = [NSMutableArray new];
    [cellData removeAllObjects];
    cellData = [NSMutableArray new];
    [slideContents removeAllObjects];
    slideContents = [NSMutableArray new];
    for (FashionistaContent *content in [self.postParameters objectAtIndex:2]) {
        NSLog(@"*******@@@@@@@@@ order : %li", [content.order integerValue]);
        for (int i = 0; i < [temp count]; i ++) {
            FashionistaContent *tempContent = [temp objectAtIndex:i];
            NSLog(@"@@@@@@@@@@@ Temp Order : %li", [tempContent.order integerValue]);
            if ([content.order integerValue] < [tempContent.order integerValue]) {
                [temp insertObject:content atIndex:i];
                break;
            }
        }
        if ([temp containsObject:content]) {
            continue;
        }
        else {
            [temp addObject:content];
        }
    }
    
    for (int i = 0; i < [temp count]; i++) {
        FashionistaContent *content = [temp objectAtIndex:i];
        if (content) {
            if ([slideContents containsObject:content]) {
                continue;
            }
            if (![content.video isEqualToString:@""] && content.video != nil) {
                [cellData addObject:content];
            }
            else if (![content.image isEqualToString:@""] && content.image != nil) {
                if (i == [temp count] - 1) {
                    [cellData addObject:content];
                }
                else {
                    [cellData addObject:[self getSlideContent:temp index:i]];
                }
            }
            else {
                [cellData addObject:content];
            }
        }
    }
}

-(NSMutableArray*)getSlideContent:(NSMutableArray*)contents index:(NSInteger)index {
    NSMutableArray *slideContent = [NSMutableArray new];
    FashionistaContent *currentContent = [contents objectAtIndex:index];
    
    [slideContent addObject:currentContent];
    for (NSInteger i = index + 1; i < [contents count]; i ++) {
        FashionistaContent *content = [contents objectAtIndex:i];
        if (![content.image isEqualToString:@""] && content.image != nil) {
            [slideContents addObject:content];
            [slideContent addObject:content];
        }
        else {
            return slideContent;
        }
    }
    return slideContent;
}

@end
