//
//  GSQuickViewViewController.m
//  GoldenSpear
//
//  Created by Adria Vernetta Rubio on 6/5/16.
//  Copyright © 2016 GoldenSpear. All rights reserved.
//

#import "GSQuickViewViewController.h"
#import "BaseViewController+StoryboardManagement.h"
#import "BaseViewController+RestServicesManagement.h"
#import "UIImage+ImageCache.h"
#import "User+Manage.h"
#import "BaseViewController+ActivityFeedbackManagement.h"
#import "BaseViewController+BottomControlsManagement.h"
#import "BaseViewController+TopBarManagement.h"

#define kSensitivity 20

@interface BaseViewController (protected)

- (void)showMessageWithImageNamed:(NSString*)imageNamed;

@end

@implementation GSQuickViewViewController{
    //FashionistaPost* thePost;
    //User* postOwner;
    BOOL showingDetails;
    
    CGPoint initialTouch;
    BOOL touchBegan;
    
    NSString* thePostId;
    NSString* previewImage;
    NSString* postOwner_name;
    NSString* postOwner_picture;
    
    NSNumber* preview_image_height;
    NSNumber* preview_image_width;
    
    NSDate* postDate;
    
    BOOL completePost;
}

- (void)dealloc{
    self.imagesQueue = nil;
}

- (void)viewDidLoad {
    [self hideTopBar];
    [super viewDidLoad];
    self.view.translatesAutoresizingMaskIntoConstraints = NO;
    for (UIView* v in self.framedViews) {
        v.layer.masksToBounds = YES;
        v.layer.borderWidth = 2;
        v.layer.borderColor = [[UIColor blackColor] CGColor];
    }
    
    self.imagesQueue = [[NSOperationQueue alloc] init];
    
    // Set max number of concurrent operations it can perform at 3, which will make things load even faster
    self.imagesQueue.maxConcurrentOperationCount = 3;
    
 //   self.headerTopDistanceConstraint.constant = -self.headerView.frame.size.height;
}

- (void)actionAfterSuccessfulAnswerToRestConnection:(connectionType)connection WithResult:(NSArray *)mappingResult{
    switch (connection)
    {
        case GET_FASHIONISTAWITHNAME:
        {
            __block User* postOwner = nil;
            [mappingResult enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
             {
                 if (([obj isKindOfClass:[User class]]))
                 {
                     postOwner = (User *)obj;
                     
                     // Stop the enumeration
                     *stop = YES;
                 }
             }];
            if(postOwner){
                if(!self.delegate){
                    NSArray* parametersForNextVC = [NSArray arrayWithObjects: postOwner, [NSNumber numberWithBool:NO], nil, nil];
                    [self transitionToViewController:USERPROFILE_VC withParameters:parametersForNextVC];
                }else{
                    [self.delegate quickView:self viewProfilePushed:postOwner];
                }
            }
            [self stopActivityFeedback];
        }
        case GET_POST_AUTHOR:
        {
            User* postOwner = [mappingResult firstObject];
            //[self setUserData];
            if(!self.delegate){
                NSArray* parametersForNextVC = [NSArray arrayWithObjects: postOwner, [NSNumber numberWithBool:NO], nil, nil];
                [self transitionToViewController:USERPROFILE_VC withParameters:parametersForNextVC];
            }else{
                [self.delegate quickView:self viewProfilePushed:postOwner];
            }
            break;
        }
        case GET_USER_LIKES_POST:
        {
            // Get the list of comments that were provided
            for (NSMutableDictionary *userLikesPostDict in mappingResult)
            {
                if([userLikesPostDict isKindOfClass:[NSMutableDictionary class]])
                {
                    NSNumber * like = [userLikesPostDict objectForKey:@"like"];
                    NSString * postId = [userLikesPostDict objectForKey:@"post"];
                    if([postId isEqualToString:thePostId]){
                        self.likesButton.selected = [like boolValue];
                    }
                }
            }
            break;
        }
        case LIKE_POST:
        case UNLIKE_POST:
        {
            [self.delegate quickViewLikeUpdatingFinished];
            break;
        }
        case UPLOAD_SHARE:
        {
            // Get the list of comments that were provided
            for (Share *newShare in mappingResult)
            {
                if([newShare isKindOfClass:[Share class]])
                {
                    [self socialShareActionWithShareObject:((Share*) newShare) andPreviewImage:[UIImage cachedImageWithURL:previewImage]];
                    
                    break;
                }
            }
            break;
        }
        default:
            [super actionAfterSuccessfulAnswerToRestConnection:connection WithResult:mappingResult];
            break;
    }
}

- (IBAction)dismissView:(id)sender {
    [self.currentPresenterViewController dismissControllerModal];
}

- (IBAction)likePushed:(UIButton*)sender {
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if ((appDelegate.currentUser == nil))
    {
        // Must be logged!
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_INFO_", nil) message:NSLocalizedString(@"_MUSTBELOGGED_MSG_", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"_OK_", nil) otherButtonTitles:nil];
        
        [alertView show];
        
        return;
    }
    
    if (sender.selected) {
        NSArray * requestParameters = [[NSArray alloc] initWithObjects:appDelegate.currentUser.idUser, thePostId, nil];
        
        [self performRestGet:UNLIKE_POST withParamaters:requestParameters];
    }else{
        // Post the PostLike object
        
        NSManagedObjectContext *currentContext = [RKObjectManager sharedManager].managedObjectStore.mainQueueManagedObjectContext;
        
        PostLike *newPostLike = [[PostLike alloc] initWithEntity:[NSEntityDescription entityForName:@"PostLike" inManagedObjectContext:currentContext] insertIntoManagedObjectContext:currentContext];
        
        [newPostLike setUserId:appDelegate.currentUser.idUser];
        
        [newPostLike setPostId:thePostId];
        
        NSArray * requestParameters = [[NSArray alloc] initWithObjects:newPostLike, nil];
        
        [self performRestPost:LIKE_POST withParamaters:requestParameters];
    }
    sender.selected = !sender.selected;
}

-(void) showMessageWithImageNamed:(NSString *)imageName{    
    [self.delegate showMessageWithImageNamed:imageName andSharedObject:self.currentSharedObject];
}

- (IBAction)viewProfilePushed:(id)sender {
    //Cambiar a get Fashionista
    [self stopActivityFeedback];
    [self startActivityFeedbackWithMessage:NSLocalizedString(@"_DOWNLOADING_ACTV_MSG_", nil)];
    
    NSArray * requestParameters = [[NSArray alloc] initWithObjects:postOwner_name, nil];
    
    [self performRestGet:GET_FASHIONISTAWITHNAME withParamaters:requestParameters];
}

- (IBAction)commentPushed:(id)sender {
    [self.delegate commentContentForQuickView:self];
}

- (IBAction)sharePushed:(id)sender {
    NSManagedObjectContext *currentContext = [RKObjectManager sharedManager].managedObjectStore.mainQueueManagedObjectContext;
    
    Share * newShare = [[Share alloc] initWithEntity:[NSEntityDescription entityForName:@"Share" inManagedObjectContext:currentContext] insertIntoManagedObjectContext:currentContext];
    
    [newShare setSharedPostId:thePostId];
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if (!(appDelegate.currentUser == nil))
    {
        if (!([appDelegate.currentUser.idUser isEqualToString:@""]))
        {
            [newShare setSharingUserId:appDelegate.currentUser.idUser];
        }
    }
    
    [currentContext processPendingChanges];
    
    [currentContext save:nil];
    
    NSArray * requestParameters = [[NSArray alloc] initWithObjects:newShare, nil];
    
    [self performRestPost:UPLOAD_SHARE withParamaters:requestParameters];
}

- (IBAction)imageTapped:(id)sender {
    [self.delegate detailTappedForQuickView:self];
}

- (IBAction)swipeUp:(id)sender {
    if (showingDetails) {
        [self imageTapped:nil];
    }else{
        showingDetails = YES;
        [self moveDetails:showingDetails];
    }
}

- (IBAction)swipeDown:(id)sender {
    if (showingDetails) {
        showingDetails = NO;
        [self moveDetails:showingDetails];
    }
}

- (void)layoutImage{
    CGFloat imageHeight = [preview_image_height floatValue];
    CGFloat imageWidth = [preview_image_width floatValue];
    if (imageHeight==0||imageWidth==0) {
        UIImage* theImage = self.postImage.image;
        if(theImage.size.height==0||theImage.size.width==0){
            return;
        }
        imageWidth = theImage.size.width;
        imageHeight = theImage.size.height;
    }
    CGFloat aspectRatio = imageWidth/imageHeight;
    CGFloat newHeight = floorf(self.postImage.frame.size.width/aspectRatio);
    
    self.postImageHeight.constant = newHeight;
    [self.postImage.superview layoutIfNeeded];
}

- (void)setUserData{
    self.headerTitle.text = postOwner_name;
    if ([UIImage isCached:postOwner_picture])
    {
        UIImage * image = [UIImage cachedImageWithURL:postOwner_picture];
        
        if(image == nil)
        {
            image = [UIImage imageNamed:@"no_image.png"];
        }
        
        self.headerImage.image = image;
    }
    else
    {
        NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
            
            UIImage * image = [UIImage cachedImageWithURL:postOwner_picture];
            
            if(image == nil)
            {
                image = [UIImage imageNamed:@"no_image.png"];
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                // Then set them via the main queue if the cell is still visible.
                self.headerImage.image = image;
            });
        }];
        
        operation.queuePriority = NSOperationQueuePriorityHigh;
        
        [self.imagesQueue addOperation:operation];
    }
}

- (NSString*)processDate:(NSDate*)theDate
{
    return [NSDateFormatter localizedStringFromDate:theDate dateStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterNoStyle];
    
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"dd / MM / yy"];
    [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en"]];
    return [dateFormatter stringFromDate:theDate];
}

- (void)setPost:(NSArray*)aPost{
    completePost = [[aPost firstObject] boolValue];
    if(completePost){
        FashionistaPost* thePost = [aPost objectAtIndex:1];
        thePostId = thePost.idFashionistaPost;
        User* postOwner = [aPost objectAtIndex:6];
        postOwner_picture = postOwner.picture;
        postOwner_name = postOwner.fashionistaName;
        previewImage = thePost.preview_image;
        postDate = thePost.date;
    }else{
        thePostId = [aPost objectAtIndex:1];
        postOwner_picture = [aPost objectAtIndex:6];
        postOwner_name = [aPost objectAtIndex:7];
        previewImage = [aPost objectAtIndex:2];
        postDate = [aPost objectAtIndex:12];
    }
    
    self.postImage.image = [UIImage cachedImageWithURL:previewImage];
    [self layoutImage];
    self.headerDate.text = [self processDate:postDate];
    [self setUserData];
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSArray * requestParameters = [[NSArray alloc] initWithObjects:appDelegate.currentUser.idUser, thePostId, nil];
    [self performRestGet:GET_USER_LIKES_POST withParamaters:requestParameters];
}

- (void)setPostWithPost:(GSBaseElement*)post {
    thePostId = post.fashionistaPostId;
    //postOwner_name = post.
    previewImage = post.preview_image;
    self.postImage.image = [UIImage cachedImageWithURL:previewImage];
    preview_image_width = post.preview_image_width;
    preview_image_height = post.preview_image_height;
    [self layoutImage];
}


- (void)moveDetails:(BOOL)showOrNot{
    CGFloat topPosition = 0;
    CGFloat bottomPosition = 0;
    if (showOrNot) {
        topPosition = -1*self.headerView.frame.size.height;
        bottomPosition = 20 + self.footerView.frame.size.height;
    }
    self.headerTopDistanceConstraint.constant = topPosition;
    self.footerTopDistanceConstraint.constant = bottomPosition;
    [UIView animateWithDuration:0.5
                     animations:^{
                         [self.view layoutIfNeeded];
                     }];
}

#pragma mark - Swipe and Touch

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if(!touchBegan){
        initialTouch = [[touches anyObject] locationInView:self.view];
        touchBegan = YES;
    }
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    touchBegan = NO;
}

- (void)processSwipeWithYDistance:(CGFloat)yDistance{
    if (yDistance>0) {
        [self swipeDown:nil];
    }else{
        [self swipeUp:nil];
    }
}

- (void)processTouchInPoint:(CGPoint)touch{
    CGPoint convertedPoint = [self.view convertPoint:touch toView:self.headerView];
    if([self.headerView pointInside:convertedPoint withEvent:nil]&&showingDetails){
        return;
    }
    convertedPoint = [self.view convertPoint:touch toView:self.footerView];
    if([self.footerView pointInside:convertedPoint withEvent:nil]&&showingDetails){
        return;
    }
    convertedPoint = [self.view convertPoint:touch toView:self.postImage.superview];
    if([self.postImage.superview pointInside:convertedPoint withEvent:nil]){
        [self imageTapped:nil];
        return;
    }
    [self dismissView:nil];
    
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint lastTouch = [[touches anyObject] locationInView:self.view];
    CGPoint distanceVector = CGPointMake(lastTouch.x-initialTouch.x, lastTouch.y-initialTouch.y);
    CGFloat distanceValue = sqrt(pow(distanceVector.x, 2)+pow(distanceVector.y,2));
    if (distanceValue>kSensitivity) {
        //Swipe
        [self processSwipeWithYDistance:distanceVector.y];
    }else{
        [self processTouchInPoint:lastTouch];
    }
    initialTouch = CGPointZero;
    touchBegan = NO;
}

- (void)closeVC {
    [self dismissView:nil];
}

@end
