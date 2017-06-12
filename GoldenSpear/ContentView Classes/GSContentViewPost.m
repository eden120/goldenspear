//
//  GSContentViewPost.m
//  GoldenSpear
//
//  Created by Adria Vernetta Rubio on 20/4/16.
//  Copyright © 2016 GoldenSpear. All rights reserved.
//

#import "GSContentViewPost.h"
#import "GSImageTaggableView.h"
#import "FashionistaPost.h"
#import "UIImage+ImageCache.h"
#import "UIView+Shadow.h"

#import "AppDelegate.h"

#define kFontInLabelText @"Avenir-Light"
#define kFontInLabelBoldText @"Avenir-Heavy"
#define kFontSizeInLabelText 16

#define kCommentCellIdentifier  @"commentCell"
#define kExpandCellIdentifier   @"expandCell"

#define kMaxComments 3
#define kMoreCommentsHeight 30
#define kCommentsYMargin 6
#define kCommentsXMargin 15
#define kCommentsMinimumBottom 20

@interface GSContentViewPost (){
    NSArray* optionHandlers;
    
    NSMutableArray* ownComments;
    
    BOOL isEditing;
    
    NSMutableArray* commentArray;
    NSMutableArray* commentCellHeight;
    NSInteger maxLabelNum;
    BOOL collapsedLabels;
    
    /*
    FashionistaPost* thePost;
    User* postOwner;
    */
    
    FashionistaContent* thePostContent;
    
    NSNumber* image_height;
    NSNumber* image_width;
    
    NSString* postOwner_image;
    
    NSString* postLocation_name;
    
    NSString* postContent_url;
    NSNumber* postContent_type;
    
    NSDate* postDate;
    
    NSString* wardrobeId;
    
    BOOL hasCompletePost;
    
    id content;
}

@end

@implementation GSContentViewPost

- (void)dealloc{
    //thePostContent = nil;
    
    optionHandlers = nil;
    ownComments = nil;
    commentArray = nil;
    commentCellHeight = nil;
}

- (void)extraSetupView{
    [super extraSetupView];
    [self makeInsetShadowWithRadius:8 Color:[UIColor colorWithRed:(0.0) green:(0.0) blue:(0.0) alpha:0.2] Directions:[NSArray arrayWithObjects:@"top", nil]];
}

- (void)addLostConstraints{
    [super addLostConstraints];
    self.taggableViewHeight = [NSLayoutConstraint constraintWithItem:self.taggableView
                                                           attribute:NSLayoutAttributeHeight
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:nil
                                                           attribute: NSLayoutAttributeNotAnAttribute
                                                          multiplier:1
                                                            constant:250];
    [self.taggableView addConstraint:self.taggableViewHeight];
}

- (void)prepareForReuse{
    collapsedLabels = YES;
    [self resetImage];
    self.contentImage.image = [UIImage imageNamed:@"no_image.png"];
    //thePost = nil;
    self.thePostId = nil;
    //postOwner = nil;
    self.contentTitle.text = @"";
    self.contentSubtitle.text = @"";
    
    thePostContent = nil;
    [self setLikesNumber:0];
    
    self.dateLabel.text = @"";
    
    [(GSImageTaggableView*)self.taggableView setVideoWithURL:nil currentTime:kCMTimeZero hasSound:NO];
    
    self.preview_image = nil;
    image_height = nil;
    image_width = nil;
}

#pragma mark - Options

- (void)optionsPushed:(UIButton *)sender{
    CGPoint anchor = CGPointMake(sender.center.x, sender.superview.frame.origin.y + sender.center.y);
    CGPoint windowPoint = [sender.superview.superview convertPoint:anchor toView:nil];
    
    [self.postDelegate openOptionsForContent:self atWindowPoint:windowPoint];
}

#pragma mark - Comments

- (BOOL)hasOwnComments{
    return [ownComments count]>0;
}

- (IBAction)hangerPush:(id)sender {
    if (!(thePostContent.wardrobeId == nil))
    {
        if(![thePostContent.wardrobeId isEqualToString:@""])
        {
            [self.postDelegate openWardrobeWithId:content];
        }
    }
    if (wardrobeId != nil && ![wardrobeId isEqualToString:@""]) {
        [self.postDelegate openWardrobeWithId:content];
    }
}

- (IBAction)wardrobePush:(id)sender {
    if (!(thePostContent.wardrobeId == nil))
    {
        if(![thePostContent.wardrobeId isEqualToString:@""])
        {
            [self.postDelegate wardrobePush:content button:(UIButton*)sender];
        }
    }
    if (wardrobeId != nil && ![wardrobeId isEqualToString:@""]) {
        [self.postDelegate wardrobePush:content button:(UIButton*)sender];
    }
}

- (IBAction)editPush:(UIButton*)sender {
    CGPoint anchor = CGPointMake(sender.center.x, sender.superview.frame.origin.y + sender.center.y);
    CGPoint windowPoint = [sender.superview.superview convertPoint:anchor toView:nil];
    
    [self.postDelegate openEditOptionsForContent:self atWindowPoint:windowPoint];
}

- (void)initComments{
    [super initComments];
    maxLabelNum = kMaxComments;
    [self.commentsTableView registerNib:[UINib nibWithNibName:@"GSCommentTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:kCommentCellIdentifier];
    [self.commentsTableView registerNib:[UINib nibWithNibName:@"GSExpandTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:kExpandCellIdentifier];
    self.commentsTableView.delegate = self;
    collapsedLabels = YES;
}

- (void)commentContent{
    self.editingComment = nil;
    [self.postDelegate commentContentPost:self atIndex:-1];
}

- (void)addCommentToContent:(NSString*)comment{
    
}

- (void)addCommentObject:(id)comment{
    [commentArray addObject:comment];
    [commentCellHeight addObject:comment];
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if ([((Comment*)comment).fashionistaPostName isEqualToString:appDelegate.currentUser.fashionistaName]) {
        [ownComments addObject:comment];
    }
   
    [self updateHeightCalculationsWithForceResize:YES];
}

#pragma mark - likes

- (void)likeContent:(BOOL)likeOrNot{
    [self.postDelegate contentPost:self doLike:likeOrNot];
}

- (void)getLikeUsers {
    [self.postDelegate getLikeUsers:self];
}

-(void)pinchImage:(UIImage*)image {
    [self.postDelegate imagePinch:image];
}
#pragma mark - Image management

- (void)showLoadingIndicator:(BOOL)showOrNot{
    if (showOrNot) {
        [self.contentLoadingIndicator startAnimating];
        //[self.contentLoadingIndicator.superview bringSubviewToFront:self.contentLoadingIndicator];
    }else{
        [self.contentLoadingIndicator stopAnimating];
        //[self.contentLoadingIndicator.superview sendSubviewToBack:self.contentLoadingIndicator];
    }
    self.contentLoadingIndicator.hidden = !showOrNot;
}

- (void)updateImageAndLayout{
    if(!self.preview_image || [self.preview_image isEqualToString:@""]){
        [self setBlankContent];
        return;
    }
    UIImage* anImage = [GSContentViewPost getTheImage:self.preview_image];
    if(anImage){
        [(GSImageTaggableView*)self.taggableView imageView].image = anImage;
        [self showLoadingIndicator:NO];
    }else{
        [(GSImageTaggableView*)self.taggableView imageView].image = nil;
        [[(GSImageTaggableView*)self.taggableView imageView] setNeedsDisplay];
        [self showLoadingIndicator:YES];
        [[(GSImageTaggableView*)self.taggableView imageView] setImageWithURL:[NSURL URLWithString:self.preview_image]];
    }
    CGFloat width = MIN([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    CGFloat imageHeight = [GSContentViewPost estimatedSizeForContentImage:self.preview_image
                                                                withWidth:image_width
                                                               withHeight:image_height
                                                       andControllerWidth:width];
    
    if(imageHeight!=self.taggableView.frame.size.height){
        self.taggableViewHeight.constant = imageHeight;
        [self.taggableView layoutIfNeeded];
        [self.contentScroll layoutIfNeeded];
    }
}

- (void)setBlankContent{
    [(GSImageTaggableView*)self.taggableView imageView].image = nil;
    [self showLoadingIndicator:NO];
    self.taggableViewHeight.constant = 0;
    [self.taggableView layoutIfNeeded];
    [self.contentScroll layoutIfNeeded];
}

- (void)resetImage{
    [self showLoadingIndicator:YES];
    [(GSImageTaggableView*)self.taggableView imageView].image = nil;
}

- (void)updateImages{
    [self setProfileImage];
    [self setPostImage];
}

- (void)setProfileImage{
    UIImage* anImage = [GSContentViewPost getTheImage:postOwner_image];
    self.contentImage.image = anImage;
}

- (void)setPostImage{
    [self updateImageAndLayout];
}

- (void)updateVideoView:(CMTime)currentTime hasSound:(BOOL)sound{
    [self showLoadingIndicator:NO];
    [(GSImageTaggableView*)self.taggableView setVideoWithURL:postContent_url currentTime:currentTime hasSound:sound];
    
    CGFloat width = MIN([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    CGFloat imageHeight = [GSContentViewPost estimatedSizeForContentVideoWithHeight:image_height andWidth:image_width andControllerWidth:width];
    
    if(imageHeight!=self.taggableView.frame.size.height){
        self.taggableViewHeight.constant = imageHeight;
        [self.taggableView layoutIfNeeded];
        [self.contentScroll layoutIfNeeded];
    }
}

#pragma mark - Content data setter

- (void)setContentData:(id)contentObject currentTime:(CMTime)currentTime hasSound:(BOOL)sound {
    if([contentObject count]<7){
        return;
    }
    content = contentObject;
    
    hasCompletePost = [[contentObject objectAtIndex:0] boolValue];
    NSString* thePostId;
    FashionistaPost* aPost = nil;
    if(hasCompletePost){
        aPost = [contentObject objectAtIndex:1];
        thePostId = aPost.idFashionistaPost;
    }else{
        thePostId = [contentObject objectAtIndex:1];
    }
    
    //Only update if the posts are different
    if(![self.thePostId isEqualToString:thePostId]){
        self.hangerButton.hidden = YES;
        self.wardrobeButton.hidden = YES;
        self.editButton.hidden = YES;
        self.thePostId = thePostId;
        postLocation_name = [contentObject objectAtIndex:4];
        
        if(hasCompletePost){
            User* postOwner = [contentObject objectAtIndex:6];
            postOwner_image = postOwner.picture;
            self.postOwner_name = postOwner.fashionistaName;
            
            thePostContent = [[contentObject objectAtIndex:2] firstObject];
            
            self.preview_image = aPost.preview_image;
            image_height = aPost.preview_image_height;
            image_width = aPost.preview_image_width;
            
            postDate = aPost.createdAt;
            
            if(!(thePostContent.video==nil)){
                postContent_type = [NSNumber numberWithInt:PostContentTypeVideo];
                postContent_url = thePostContent.video;
                [self updateVideoView:currentTime hasSound:sound];
                [self updateImageAndLayout];
            }else{
                [self updateImageAndLayout];
            }
            
            if(thePostContent.wardrobeId&&![thePostContent.wardrobeId isEqualToString:@""]){
                self.hangerButton.hidden = NO;
                self.wardrobeButton.hidden = NO;
                AppDelegate *delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
                if ([postOwner.idUser isEqualToString:delegate.currentUser.idUser]) {
                    self.wardrobeButton.hidden = YES;
                }
            }
            
            if ([aPost.type isEqualToString:@"wardrobe"]) {
                AppDelegate *delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
                if ([postOwner.idUser isEqualToString:delegate.currentUser.idUser]) {
                    self.editButton.hidden = NO;
                }
            }

            self.isFollowingOwner = [aPost.isFollowingAuthor boolValue];
            NSString *posttype = aPost.type;
        }else{
            postOwner_image = [contentObject objectAtIndex:6];
            self.postOwner_name = [contentObject objectAtIndex:7];
            
            thePostContent = nil;
            
            image_width = [contentObject objectAtIndex:10];
            image_height = [contentObject objectAtIndex:11];
            
            postContent_type = [contentObject objectAtIndex:9];
            postContent_url = [contentObject objectAtIndex:8];
            if([postContent_type integerValue]==PostContentTypeVideo){
                self.preview_image = [contentObject objectAtIndex:2];
                [self updateImageAndLayout];
                [self updateVideoView:currentTime hasSound:sound];
            }else{
                self.preview_image = [contentObject objectAtIndex:8];
                NSLog(@"URL : %@", self.preview_image);
                [self updateImageAndLayout];
            }
            
            postDate = [contentObject objectAtIndex:12];
            self.isFollowingOwner = [[contentObject objectAtIndex:13] boolValue];
            NSString *posttype = [contentObject objectAtIndex:15];
        }
        
        UIImage* anImage = [GSContentViewPost getTheImage:postOwner_image];
        if(anImage){
            self.contentImage.image = anImage;
        }else{
            [self.viewDelegate contentView:self downloadProfileImage:postOwner_image];
        }
        self.contentTitle.text = self.postOwner_name;
        self.contentSubtitle.text = postLocation_name;
                
        NSInteger likes = [[contentObject objectAtIndex:5] integerValue];
        [self setLikesNumber:likes];
        
        NSArray* comments = [contentObject objectAtIndex:3];
        [self setCommentsWithArray:comments];
        [self setupDate];
        self.taggableView.tapAbleView = hasCompletePost;
    }else{
        [self updateImages];
    }
}

#pragma mark - Date management

- (void)setupDate
{
    NSString *locationAndDate = nil;
    [self.dateLabel setText:NSLocalizedString(@"_UNKNOWN_LOCATION_AND_DATE_", nil)];
    
        if(!(postDate == nil))
        {
            NSString *date = [self processDate:postDate];
            
            if(!(date == nil))
            {
                if(!([date isEqualToString:@""]))
                {
                    locationAndDate = [date capitalizedString];
                }
            }
        }
        
        if(!(locationAndDate == nil))
        {
            if(!([locationAndDate isEqualToString:@""]))
            {
                [self.dateLabel setText:locationAndDate];
            }
        }
}

- (NSString*)processDate:(NSDate*)theDate
{
    if(!theDate){
        return nil;
    }
    return [NSDateFormatter localizedStringFromDate:theDate dateStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterNoStyle];
    
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"dd / MM / yy"];
    [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en"]];
    return [dateFormatter stringFromDate:theDate];
}

- (NSString*) calculatePeriodForDate:(NSDate *)date
{
    NSDate * today = [NSDate date];
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    NSDateComponents *dateComponents = [calendar components: (NSCalendarUnitSecond | NSCalendarUnitMinute | NSCalendarUnitHour | NSCalendarUnitDay | NSCalendarUnitWeekOfYear | NSCalendarUnitMonth | NSCalendarUnitYear) fromDate:date toDate:today options:0];
    
    if (dateComponents.year > 0)
    {
        if (dateComponents.year > 1)
        {
            return [NSString stringWithFormat:NSLocalizedString(@"_POSTED_YEARS_AGO_", nil), (long)dateComponents.year];
        }
        else
        {
            return NSLocalizedString(@"_POSTED_YEAR_AGO_", nil);
        }
    }
    else if (dateComponents.month > 0)
    {
        if (dateComponents.month > 1)
        {
            return [NSString stringWithFormat:NSLocalizedString(@"_POSTED_MONTHS_AGO_", nil), (long)dateComponents.month];
        }
        else
        {
            return NSLocalizedString(@"_POSTED_MONTH_AGO_", nil);
        }
    }
    else if (dateComponents.weekOfYear > 0)
    {
        if (dateComponents.weekOfYear > 1)
        {
            return [NSString stringWithFormat:NSLocalizedString(@"_POSTED_WEEKS_AGO_", nil), (long)dateComponents.weekOfYear];
        }
        else
        {
            return NSLocalizedString(@"_POSTED_WEEK_AGO_", nil);
        }
    }
    else if (dateComponents.day > 0)
    {
        if (dateComponents.day > 1)
        {
            return [NSString stringWithFormat:NSLocalizedString(@"_POSTED_DAYS_AGO_", nil), (long)dateComponents.day];
        }
        else
        {
            return NSLocalizedString(@"_POSTED_YESTERDAY_", nil);
        }
    }
    else if (dateComponents.hour > 0)
    {
        if (dateComponents.hour > 1)
        {
            return [NSString stringWithFormat:NSLocalizedString(@"_POSTED_HOURS_AGO_", nil), (long)dateComponents.hour];
        }
        else
        {
            return NSLocalizedString(@"_POSTED_HOUR_AGO_", nil);
        }
    }
    else if (dateComponents.minute > 0)
    {
        if (dateComponents.minute > 1)
        {
            return [NSString stringWithFormat:NSLocalizedString(@"_POSTED_MINUTES_AGO_", nil), (long)dateComponents.minute];
        }
        else
        {
            return NSLocalizedString(@"_POSTED_MINUTE_AGO_", nil);
        }
    }
    else if (dateComponents.second > 0)
    {
        {
            return NSLocalizedString(@"_POSTED_RIGHTNOW_", nil);
        }
    }
    
    return nil;
}

#pragma mark - Comments Layout

- (void)setExpandedComments{
    collapsedLabels = NO;
}

- (void)setCommentsWithArray:(NSArray*)comments{
    [commentArray removeAllObjects];
    commentArray = [[NSMutableArray alloc] initWithArray:comments];
    [commentCellHeight removeAllObjects];
    commentCellHeight = [[NSMutableArray alloc] initWithArray:comments];
    ownComments = [NSMutableArray new];
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    for (id c in comments) {
        if([c isKindOfClass:[Comment class]]){
            if ([((Comment*)c).fashionistaPostName isEqualToString:appDelegate.currentUser.fashionistaName]) {
                [ownComments addObject:c];
            }
        }else{
            if ([[c objectForKey:@"username"] isEqualToString:appDelegate.currentUser.fashionistaName]) {
                [ownComments addObject:c];
            }
        }
    }
    
    [self updateHeightCalculations];
    [self.commentsTableView reloadData];
}

//Updates cellHeightCalculations
- (void)updateHeightCalculations{
    [self updateHeightCalculationsWithForceResize:NO];
}

- (void)updateHeightCalculationsWithForceResize:(BOOL)forceResize{
    CGRect theFrame = self.commentsTableView.bounds;
    CGFloat originalHeight = theFrame.size.height;
    
    CGFloat xMargin = kCommentsXMargin;
    CGFloat yMargin = kCommentsYMargin;
    //Label final max width
    theFrame.size.width -= xMargin*2;
    CGSize constrainedSize = CGSizeMake(theFrame.size.width, CGFLOAT_MAX);
    
    UIFont* theFont = [UIFont fontWithName:kFontInLabelText size:kFontSizeInLabelText];
    int i = 0;
    BOOL cantFillAll = [commentArray count]>kMaxComments;
    CGFloat totalHeight = 0;
    if (cantFillAll) {
        totalHeight = kMoreCommentsHeight;
    }
    for (id c in commentArray) {
        NSString* theText = [GSContentViewPost textForComment:c];
        CGRect requiredHeight = [theText boundingRectWithSize:constrainedSize
                                                     options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading
                                                  attributes:@{NSFontAttributeName:theFont}
                                                     context:nil];
        theFrame.size.height = ceilf(requiredHeight.size.height)+yMargin*2;
        [commentCellHeight replaceObjectAtIndex:i withObject:[NSNumber numberWithFloat:theFrame.size.height]];
        if (cantFillAll) {
            if (i<=1||i>=[commentArray count]-1) {
                totalHeight += theFrame.size.height;
            }
        }else{
            totalHeight += theFrame.size.height;
        }
        i++;
    }
    totalHeight = MAX(kCommentsMinimumBottom,totalHeight);
    
    if (originalHeight!=totalHeight) {
        self.commentsViewHeightConstraint.constant = totalHeight;
        [self.commentsTableView layoutIfNeeded];
        [self layoutIfNeeded];
        if(forceResize){
            [self.viewDelegate contentView:self heightChanged:self.contentScroll.contentSize.height reason:GSPostContentHeightChangeReasonComments forceResize:forceResize];
        }
    }
}

#pragma mark - TableViewDelegate For Comments

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (collapsedLabels&&[commentArray count]>maxLabelNum) {
        return maxLabelNum+1;
    }
    return [commentArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSInteger index = indexPath.row;
    if (collapsedLabels&&[commentArray count]>maxLabelNum) {
        //Expand cell
        if(indexPath.row==kMaxComments){
            return [tableView dequeueReusableCellWithIdentifier:kExpandCellIdentifier];
        }
//        if (indexPath.row >0) {
//            index = indexPath.row + ([commentArray count] - maxLabelNum);
//        }
        if (indexPath.row == 0)
        {
            index = [commentArray count] - 1; //indexPath.row + ([commentArray count] - maxLabelNum);
        }
        else
        {
            index = index - 1;
        }
    }
    if(index>=[commentArray count]){
        return nil;
    }
    id aComment = [commentArray objectAtIndex:index];
    GSCommentTableViewCell* theCell = (GSCommentTableViewCell*)[tableView dequeueReusableCellWithIdentifier:kCommentCellIdentifier];
    theCell.viewDelegate = self;
    
    NSString* commentText = [GSContentViewPost textForComment:aComment];
    theCell.theLabel.text = commentText;

    return theCell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSInteger index = indexPath.row;
    if (collapsedLabels&&[commentArray count]>maxLabelNum) {
        //Expand cell
        if(indexPath.row==kMaxComments){
            return 30;
        }
//        if (indexPath.row >0) {
//            index = indexPath.row + ([commentArray count] - maxLabelNum);
//        }
        if (indexPath.row == 0) {
            index = indexPath.row + ([commentArray count] - 1);
        }
        else
        {
            index = index -1;
        }
    }
    return [[commentCellHeight objectAtIndex:index] floatValue];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (collapsedLabels&&[commentArray count]>maxLabelNum) {
        if(indexPath.row==kMaxComments){
            [self.postDelegate contentPost:self showComments:commentArray withEditMode:NO];
        }
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)setEditMode:(BOOL)editMode{
    if (editMode) {
        NSMutableDictionary* commentIndexes = [NSMutableDictionary new];
        for (Comment* c in ownComments) {
            BOOL commentFound = NO;
            for(int i =0;i<[commentArray count]&&!commentFound;i++){
                Comment* aComment = [commentArray objectAtIndex:i];
                if([aComment.idComment isEqualToString:c.idComment]){
                    [commentIndexes setObject:[NSNumber numberWithInt:i] forKey:c.idComment];
                    commentFound = YES;
                }
            }
        }
        [self.postDelegate contentPost:self showComments:ownComments withEditMode:YES andCommentIndexes:commentIndexes];
    }
}

- (void)endDisplayingCell{
    [(GSImageTaggableView*)self.taggableView stopVideo];
}

- (void)resumeDisplayingCell{
    [(GSImageTaggableView*)self.taggableView startVideo];
}

#pragma mark - KILabel
- (void)collapsableLabelContainer:(GSCommentTableViewCell *)collapsableView urlTapped:(NSString *)url{
    
}

- (void)collapsableLabelContainer:(GSCommentTableViewCell *)collapsableView userTapped:(NSString *)username{
    username = [username substringFromIndex:1];
    [self.postDelegate openFashionistaWithUsername:username];
}

- (void)collapsableLabelContainer:(GSCommentTableViewCell *)collapsableView ownerTapped:(NSString *)owner{
    [self.postDelegate openFashionistaWithUsername:owner];
}

- (void)collapsableLabelContainer:(GSCommentTableViewCell *)collapsableView hashtagTapped:(NSString *)hashtag{
    
}

- (void)taggableView:(GSTaggableView *)taggableView didSelectFashionista:(NSString *)fashionistaId{
    [self.postDelegate openFashionistaWithId:fashionistaId];
}

- (void)taggableView:(GSTaggableView *)taggableView didSelectKeywords:(NSArray *)keywordArray categoryTerms:(NSMutableArray*)categoryTerms{
    [self.postDelegate searchForKeywords:keywordArray categoryTerms:categoryTerms];
}

-(void)taggableView:(GSTaggableView *)taggableView keyWords:(NSMutableDictionary *)searchStringDictionary {
    [self.postDelegate getNumberOfMatchs:searchStringDictionary];
}

-(NSString*)getVideoURL {
    if ([postContent_type intValue] == 2) {
        return postContent_url;
    }
    else {
        return nil;
    }
}

-(CMTime)getPlayer {
    return [((GSImageTaggableView*)self.taggableView) getVideoPlayer];
}

-(BOOL)hasSoundNow {
    return [((GSImageTaggableView*)self.taggableView) hasSoundNow];
}

-(void)setPlayer:(CMTime)videoPlayer hasSound:(BOOL)sound{
    [((GSImageTaggableView*)self.taggableView) setPlayer:videoPlayer hasSound:sound];
}

#pragma mark - Height Functions

+ (UIImage*)getTheImage:(NSString*)imageURL{
    if ([UIImage isCached:imageURL])
    {
        UIImage * image = [UIImage cachedImageWithURL:imageURL];
        
        if(image == nil)
        {
            image = nil;
        }
        
        return image;
    }
    return nil;
}

+ (CGFloat)estimatedSizeForFullPostWithData:(NSArray*)postData andControllerWidth:(CGFloat)controllerWidth{
    if([postData count]<7){
        return 0.;
    }
    CGFloat totalHeight = 0.;
    BOOL isComplete = [[postData objectAtIndex:0] boolValue];

    if(isComplete){
        FashionistaContent* theContent = [[postData objectAtIndex:2] firstObject];
        totalHeight += [GSContentViewPost estimatedSizeForContent:theContent andControllerWidth:controllerWidth];
    }else{
        NSString* preview_image = [postData objectAtIndex:2];

        NSNumber* image_width = 0;
        NSNumber* image_height = 0;

        if(postData.count > 10)
        {
            image_width = [postData objectAtIndex:10];
        }

        if(postData.count > 11)
        {
            image_height = [postData objectAtIndex:11];
        }

        NSNumber* postContent_type = [NSNumber numberWithInt:0];

        if(postData.count > 9)
        {
            postContent_type = [postData objectAtIndex:9];
        }

        if([postContent_type integerValue]==PostContentTypeVideo){
            totalHeight += [GSContentViewPost estimatedSizeForContentVideoWithHeight:image_height
                                                                            andWidth:image_width
                                                                  andControllerWidth:controllerWidth];
        }else{
            totalHeight += [GSContentViewPost estimatedSizeForContentImage:preview_image
                                                                        withWidth:image_width
                                                                       withHeight:image_height
                                                               andControllerWidth:controllerWidth];
        }
    }
    
    NSArray* comments = [postData objectAtIndex:3];
    
    totalHeight += [GSContentViewPost estimatedSizeForSocialControlsWithControllerWidth:controllerWidth];
    totalHeight += [GSContentViewPost estimatedSizeForComments:comments andControllerWidth:controllerWidth];
    
    //Bottom Margin
    totalHeight += kCommentsMinimumBottom;
    return totalHeight;
}

+ (CGFloat)estimatedSizeForContentVideoWithHeight:(NSNumber*)image_height andWidth:(NSNumber*)image_width andControllerWidth:(CGFloat)controllerWidth{
    CGFloat imageHeight = [image_height floatValue];
    CGFloat imageWidth = [image_width floatValue];
    if (imageHeight==0||imageWidth==0) {

            return 0.0;
    }
    CGFloat aspectRatio = imageWidth/imageHeight;
    return ceilf(controllerWidth/aspectRatio);
}

+ (CGFloat)estimatedSizeForContentImage:(NSString*)imageUrl withWidth:(NSNumber*)image_width withHeight:(NSNumber*)image_height andControllerWidth:(CGFloat)controllerWidth{
    
    CGFloat imageHeight = [image_height floatValue];
    CGFloat imageWidth = [image_width floatValue];
    if (imageHeight==0||imageWidth==0) {
        UIImage* theImage = [self getTheImage:imageUrl];
        if(theImage.size.height==0||theImage.size.width==0){
            return 0.0;
        }
        imageWidth = theImage.size.width;
        imageHeight = theImage.size.height;
    }
    CGFloat aspectRatio = imageWidth/imageHeight;
    return ceilf(controllerWidth/aspectRatio);
}

+ (CGFloat)estimatedSizeForContent:(FashionistaContent*)thePostContent andControllerWidth:(CGFloat)controllerWidth{
    if (!(thePostContent.video==nil)) {
        return MAX([thePostContent.image_height floatValue],254);
    }
    CGFloat imageHeight = [thePostContent.image_height floatValue];
    CGFloat imageWidth = [thePostContent.image_width floatValue];
    if (imageHeight==0||imageWidth==0) {
        UIImage* theImage = [self getTheImage:thePostContent.image];
        if(theImage.size.height==0||theImage.size.width==0){
            return 0.0;
        }
        imageWidth = theImage.size.width;
        imageHeight = theImage.size.height;
    }
    CGFloat aspectRatio = imageWidth/imageHeight;
    return ceilf(controllerWidth/aspectRatio);
}

+ (CGFloat)estimatedSizeForComments:(NSArray*)commentArray andControllerWidth:(CGFloat)controllerWidth{
    CGRect theFrame = CGRectMake(0, 0, controllerWidth, 0);
    CGFloat xMargin = kCommentsXMargin;
    CGFloat yMargin = kCommentsYMargin;
    //Label final max width
    theFrame.size.width -= xMargin*2;
    CGSize constrainedSize = CGSizeMake(theFrame.size.width, CGFLOAT_MAX);
    
    UIFont* theFont = [UIFont fontWithName:kFontInLabelText size:kFontSizeInLabelText];
    int i = 0;
    BOOL cantFillAll = [commentArray count]>kMaxComments;
    
    CGFloat totalHeight = 0;
    if (cantFillAll) {
        totalHeight = kMoreCommentsHeight;
    }
    for (id c in commentArray) {
        NSString* theText = [GSContentViewPost textForComment:c];
        
        CGRect requiredHeight = [theText boundingRectWithSize:constrainedSize
                                                     options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading
                                                  attributes:@{NSFontAttributeName:theFont}
                                                     context:nil];
        theFrame.size.height = ceilf(requiredHeight.size.height)+yMargin*2;
        
        if (cantFillAll) {
            if (i==0||i>[commentArray count]-kMaxComments) {
                totalHeight += theFrame.size.height;
            }
        }else{
            totalHeight += theFrame.size.height;
        }
        i++;
    }
    return totalHeight;//MAX(totalHeight,kCommentsMinimumBottom);
}

+ (CGFloat)estimatedSizeForSocialControlsWithControllerWidth:(CGFloat)controllerWidth{
    return 44.;
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event{
    UIView* theView = [super hitTest:point withEvent:event];
    //Ignore event to pass it to the cell unless we are in single view mode
    if(theView == self.contentScroll&&!self.contentScroll.scrollEnabled)
        return nil;
    return theView;
}

+ (NSString*)textForComment:(id)aComment{
    NSString* commentText;
    if([aComment isKindOfClass:[Comment class]]){
        commentText = [[NSString stringWithFormat:@"%@ %@",(((Comment*)aComment).fashionistaPostName == nil || [((Comment*)aComment).fashionistaPostName isEqualToString:@"null"] || [((Comment*)aComment).fashionistaPostName isEqualToString:@"nil"] || [((Comment*)aComment).fashionistaPostName length] == 0) ? (NSLocalizedString(@"_ANONYMOUS_USER_", nil)) : (((Comment*)aComment).fashionistaPostName),((Comment*)aComment).text]stringByTrimmingCharactersInSet:
                       [NSCharacterSet whitespaceAndNewlineCharacterSet]];
    }else{
        NSString* username = [aComment objectForKey:@"username"];
        NSString* text = [aComment objectForKey:@"text"];
        commentText = [[NSString stringWithFormat:@"%@ %@",username,text]stringByTrimmingCharactersInSet:
                       [NSCharacterSet whitespaceAndNewlineCharacterSet]];
    }
    return commentText;
}

@end
