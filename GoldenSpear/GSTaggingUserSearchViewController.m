//
//  GSTaggingUserSearchViewController.m
//  GoldenSpear
//
//  Created by Crane on 8/3/16.
//  Copyright © 2016 GoldenSpear. All rights reserved.
//

#import "GSTaggingUserSearchViewController.h"
#import "FashionistaUserListViewController.h"
#import "BaseViewController+RestServicesManagement.h"
#import "BaseViewController+ActivityFeedbackManagement.h"
#import "BaseViewController+StoryboardManagement.h"
#import "BaseViewController+TopBarManagement.h"
#import "BaseViewController+FetchedResultsManagement.h"
#import "AppDelegate.h"
#import "FashionistaUserListViewCell.h"
#import "InviteView.h"
#import "NSString+ValidateEMail.h"

@interface SearchBaseViewController (Protected)

- (NSInteger)numberOfItemsInSection:(NSInteger)section forCollectionViewWithCellType:(NSString *)cellType;
- (NSInteger)numberOfSectionsForCollectionViewWithCellType:(NSString *)cellType;
- (NSArray *)getContentForCellWithType:(NSString *)cellType AtIndexPath:(NSIndexPath *)indexPath;
- (void)actionForSelectionOfCellWithType:(NSString *)cellType AtIndexPath:(NSIndexPath *)indexPath;
- (void)updateSearch;
- (void)performSearchWithString:(NSString*)stringToSearch;
-(NSString *) stringForStylistRelationship:(followingRelationships)stylistRelationShip;
- (void)initFetchedResultsController;
- (void)updateCollectionViewWithCellType:(NSString *)cellType fromItem:(int)startItem toItem:(int)endItem deleting:(BOOL)deleting;
- (void)scrollViewDidScroll:(UIScrollView*)scrollView;

@end

@implementation UIView (testing)



@end

@interface GSTaggingUserSearchViewController ()

@end

@implementation GSTaggingUserSearchViewController {
    InviteView *inviteView;
}

- (void)dealloc{
    self.imagesQueue = nil;
}
- (void)viewDidLoad{
    [super viewDidLoad];
    self.view.translatesAutoresizingMaskIntoConstraints = NO;
    self.imagesQueue = [[NSOperationQueue alloc] init];
    
    // Set max number of concurrent operations it can perform at 3, which will make things load even faster
    self.imagesQueue.maxConcurrentOperationCount = 3;
    self.searchContext = FASHIONISTAS_SEARCH;
    self.thnBtn.layer.borderColor = [UIColor blackColor].CGColor;
    self.thnBtn.layer.borderWidth = 1.0f;
    self.thnBtn.layer.cornerRadius = 3.0f;
    self.yesBtn.layer.borderColor = [UIColor blackColor].CGColor;
    self.yesBtn.layer.borderWidth = 1.0f;
    self.yesBtn.layer.cornerRadius = 3.0f;
    
    [self hideTopBar];
    self.userListMode = ALLSTYLISTS;


}

- (void)operationAfterLoadingSearch:(BOOL)hasResults{
    if(!hasResults){
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_INFO_", nil) message:NSLocalizedString(@"_NO_RESULTS_ERROR_MSG_", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"_OK_", nil) otherButtonTitles:nil];
        
        [alertView show];
    }else{
        [self stopActivityFeedback];
    }
}

- (IBAction)doSearchPush:(id)sender {
    _manualBtn.enabled = YES;
    [_manualBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self performSearch];
}

- (IBAction)cancel:(id)sender {
}

- (IBAction)thnkAction:(id)sender {
    [self.currentPresenterViewController dismissControllerModal];
}

- (IBAction)yesAction:(id)sender {
    InviteView *iView =
    [[[NSBundle mainBundle] loadNibNamed:@"InviteView" owner:self options:nil] objectAtIndex:0];
    
    iView.frame = self.notFoundView.bounds;
    iView.searchBtn.layer.borderWidth = 1.0f;
    iView.searchBtn.layer.borderColor = [UIColor blackColor].CGColor;
    iView.sendBtn.enabled = NO;
    
    [iView.femaleBtn setBackgroundColor:[UIColor blackColor]];
    [iView.femaleBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    iView.userNameTxt.delegate = self;
    iView.emailTxt.delegate = self;

    
    [iView.maleBtn addTarget:self action:@selector(maleAction:) forControlEvents:UIControlEventTouchUpInside];
    [iView.femaleBtn addTarget:self action:@selector(femaleAction:) forControlEvents:UIControlEventTouchUpInside];
    [iView.sendBtn addTarget:self action:@selector(sendAction:) forControlEvents:UIControlEventTouchUpInside];
    [iView.searchBtn addTarget:self action:@selector(searchAction:) forControlEvents:UIControlEventTouchUpInside];
    [iView.tagBtn addTarget:self action:@selector(tagAction:) forControlEvents:UIControlEventTouchUpInside];

    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapDetected)];
        singleTap.numberOfTapsRequired = 1;
        [iView setUserInteractionEnabled:YES];
        [iView addGestureRecognizer:singleTap];

    [self.notFoundView addSubview:iView];
    inviteView = iView;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
//    if ([string isEqualToString:@" "]) {
//        return NO;
//    }
    
    if (textField == inviteView.emailTxt) {
        NSUInteger newLength = [textField.text length] + [string length] - range.length;
        if (newLength > 1) inviteView.sendBtn.enabled = YES;
        else inviteView.sendBtn.enabled = NO;
    }
    
    return YES;
}

- (void)maleAction:(UIButton*)sender {
    [sender setBackgroundColor:[UIColor blackColor]];
    [sender setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    [inviteView.femaleBtn setBackgroundColor:[UIColor colorWithRed:(220/255.0) green:(215/255.0) blue:(215/255.0) alpha:1]];
    [inviteView.femaleBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
}

- (void)femaleAction:(UIButton*)sender {
    [sender setBackgroundColor:[UIColor blackColor]];
    [sender setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    [inviteView.maleBtn setBackgroundColor:[UIColor colorWithRed:(220/255.0) green:(215/255.0) blue:(215/255.0) alpha:1]];
    [inviteView.maleBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
}

- (void)sendAction:(UIButton*)sender {
    
    [self showEmail];
}

#pragma mark - Mail Methods

- (void)showEmail
{
    // Get the Global Mail Composer
    AppDelegate * appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    
    if ([MFMailComposeViewController canSendMail])
    {
        [appDelegate cycleGlobalMailComposer];
        
       
        if(![NSString validateEmail:inviteView.emailTxt.text])
        {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_ERROR_", nil) message:NSLocalizedString(@"_ENTER_VALID_EMAIL_", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"_OK_", nil) otherButtonTitles: nil];
            
            [alertView show];
            
            return;
        }
        // Compose Email

        [appDelegate.globalMailComposer setSubject:NSLocalizedString(@"_INVITE_EMAIL_TITLE_", nil)];
        [appDelegate.globalMailComposer setMessageBody:NSLocalizedString(@"_INVITE_EMAIL_BODY_", nil) isHTML:NO];
        [appDelegate.globalMailComposer setToRecipients:[NSArray arrayWithObject:inviteView.emailTxt.text]];

        // Present mail view controller on screen
        appDelegate.globalMailComposer.mailComposeDelegate = self;
    
        [self presentViewController:appDelegate.globalMailComposer animated:YES completion:nil];
    }
    else
    {
        [appDelegate cycleGlobalMailComposer];
    }
}
- (void)mailComposeController:(MFMailComposeViewController *)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError *)error
{
    switch (result)
    {
        case MFMailComposeResultCancelled:
            //NSLog(@"Result: canceled");
            break;
        case MFMailComposeResultSaved:
            //NSLog(@"Result: saved");
            break;
        case MFMailComposeResultSent:
        {
            inviteView.tagBtn.enabled = YES;
            [inviteView endEditing:YES];
            inviteView.resultLab.text = [NSLocalizedString(@"_INVITE_RESULT_", nil) stringByAppendingString:inviteView.emailTxt.text];
        }
            break;
        case MFMailComposeResultFailed:
            //NSLog(@"Result: failed");
            break;
        default:
            //NSLog(@"Result: not sent");
            break;
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];

}


- (void)searchAction:(UIButton*)sender {
    [inviteView removeFromSuperview];
    self.notFoundView.hidden = YES;
    self.searchTextField.text = @"";
    [self performSearch];
}

- (void)tagAction:(UIButton*)sender {
    NSString *str = inviteView.userNameTxt.text;
    
    NSString *result = [str stringByReplacingOccurrencesOfString:@" " withString:@""];
    inviteView.userNameTxt.text = result;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:inviteView.userNameTxt.text forKey:@"UsernameKey"];
    [defaults setObject:@"" forKey:@"UserIDKey"];
    
    [inviteView removeFromSuperview];
    self.notFoundView.hidden = YES;

    [defaults synchronize];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"AddUserTagNotification" object:self];
    
    [self.currentPresenterViewController dismissControllerModal];

}


- (void)tapDetected {
    [inviteView endEditing:YES];
}

#pragma mark - Touch Methods
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{

}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    // make sure a point is recorded
    [self touchesMoved:touches withEvent:event];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    // make sure a point is recorded
    [self touchesEnded:touches withEvent:event];
}

- (void) actionAfterSuccessfulAnswerToRestConnection:(connectionType)connection WithResult:(NSArray *)mappingResult
{
    NSArray * parametersForNextVC = nil;
    __block id selectedSpecificResult;
    
    switch (connection)
    {
        case FINISHED_SEARCH_WITHOUT_RESULTS:
        {
            [self stopActivityFeedback];
            
            [self operationAfterLoadingSearch:NO];
            break;
        }
        case FINISHED_SEARCH_WITH_RESULTS:
        {
            [super actionAfterSuccessfulAnswerToRestConnection:connection WithResult:mappingResult];
            [self.userDisplayList reloadData];
            [self operationAfterLoadingSearch:YES];
            break;
        }
        case UNFOLLOW_USER:
        case FOLLOW_USER:
        {
            [self stopActivityFeedback];
            
            break;
        }
        case GET_FASHIONISTA:
        {
            // Get the product that was provided
            [mappingResult enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
             {
                 if (([obj isKindOfClass:[User class]]))
                 {
                     selectedSpecificResult = (User *)obj;
                     
                     // Stop the enumeration
                     *stop = YES;
                 }
             }];
            
            // Paramters for next VC (ResultsViewController)
            parametersForNextVC = [NSArray arrayWithObjects: selectedSpecificResult, [NSNumber numberWithBool:NO], [self currentSearchQuery], nil];
            
            [self stopActivityFeedback];
            
            if(!self.currentPresenterViewController){
                [self transitionToViewController:USERPROFILE_VC withParameters:parametersForNextVC];
            }else{
                [self.currentPresenterViewController transitionToViewController:USERPROFILE_VC withParameters:parametersForNextVC];
                [self.currentPresenterViewController dismissControllerModal];
            }
            break;
        }
        default:
            [super actionAfterSuccessfulAnswerToRestConnection:connection WithResult:mappingResult];
            break;
    }
}

- (IBAction)manualAction:(id)sender {
    self.notFoundView.hidden = NO;
}

- (IBAction)followButtonPushed:(UIButton *)sender {
//    sender.selected = !sender.selected;
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if ((appDelegate.currentUser == nil))
    {
        // Must be logged!
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_INFO_", nil) message:NSLocalizedString(@"_MUSTBELOGGED_MSG_", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"_OK_", nil) otherButtonTitles:nil];
        
        [alertView show];
        
        return;
    }
    
    NSArray* rowInfo = [super getContentForCellWithType:@"ResultCell" AtIndexPath:[NSIndexPath indexPathForRow:sender.tag inSection:0]];
    
    if (!(appDelegate.currentUser.idUser == nil))
    {
        if(!([appDelegate.currentUser.idUser isEqualToString:@""]))
        {
            // Perform request to follow user
            
            // Provide feedback to user
            [self stopActivityFeedback];
            
            NSString* fashionistaName = [rowInfo objectAtIndex:3];
            NSString* fashionistaId = [rowInfo objectAtIndex:6];
//            theCell.userName.text = fashionistaName;
//            if([rowInfo count]>7){
//                NSString *realName = [rowInfo objectAtIndex:7];
//            }
            
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setObject:fashionistaName forKey:@"UsernameKey"];
            [defaults setObject:fashionistaId forKey:@"UserIDKey"];
            
           
            [defaults synchronize];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"AddUserTagNotification" object:self];
           
            [self.currentPresenterViewController dismissControllerModal];
        }
    }
}

#pragma mark - UITableViewDelegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    FashionistaUserListViewCell* theCell = [tableView dequeueReusableCellWithIdentifier:@"userCell"];
    NSArray* rowInfo = [super getContentForCellWithType:@"ResultCell" AtIndexPath:indexPath];
    if([rowInfo count]>6){
        NSString* previewImage = [rowInfo objectAtIndex:0];
        BOOL isFollowing = [[rowInfo objectAtIndex:2] boolValue];
        NSString* fashionistaName = [rowInfo objectAtIndex:3];
        theCell.userName.text = fashionistaName;
        if([rowInfo count]>7){
            theCell.userTitle.text = [rowInfo objectAtIndex:7];
        }
        theCell.fashionistaId = [rowInfo objectAtIndex:6];
//        AppDelegate* appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
//        if([appDelegate.currentUser.idUser isEqualToString:theCell.fashionistaId]){
//            theCell.followingButton.hidden = YES;
//        }else{
            theCell.followingButton.hidden = NO;
            theCell.followingButton.tag = indexPath.row;
            theCell.followingButton.selected = NO;
//        }
        theCell.imageURL = previewImage;
        if ([UIImage isCached:previewImage])
        {
            UIImage * image = [UIImage cachedImageWithURL:previewImage];
            
            if(image == nil)
            {
                image = [UIImage imageNamed:@"no_image.png"];
            }
            
            theCell.theImage.image = image;
        }
        else
        {
            NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
                
                UIImage * image = [UIImage cachedImageWithURL:previewImage];
                
                if(image == nil)
                {
                    image = [UIImage imageNamed:@"no_image.png"];
                }
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    // Then set them via the main queue if the cell is still visible.
                    if ([tableView.indexPathsForVisibleRows containsObject:indexPath]&&[theCell.imageURL isEqualToString:previewImage])
                    {
                        theCell.theImage.image = image;
                    }
                });
            }];
            
            operation.queuePriority = NSOperationQueuePriorityHigh;
            
            [self.imagesQueue addOperation:operation];
        }
    }
    return theCell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return [super numberOfSectionsForCollectionViewWithCellType:@"ResultCell"];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if ([super numberOfItemsInSection:section forCollectionViewWithCellType:@"ResultCell"] == 0) {
        self.notFoundView.hidden = NO;
    } else {
        self.notFoundView.hidden = YES;
    }
    return [super numberOfItemsInSection:section forCollectionViewWithCellType:@"ResultCell"];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    // Tweak for reusing superclass function
    // Hide Add Terms text field
//    UITextField* phantomTextField = [UITextField new];
//    [self setAddTermTextField:phantomTextField];
//    phantomTextField.hidden = YES;
//    
    [super actionForSelectionOfCellWithType:@"ResultCell" AtIndexPath:indexPath];
}


- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    float scrollViewHeight = scrollView.frame.size.height;
    float scrollContentSizeHeight = scrollView.contentSize.height;
    float scrollOffset = scrollView.contentOffset.y;
    
    if (scrollOffset == 0)
    {
        // then we are at the top
    }
    else if (scrollOffset + scrollViewHeight == scrollContentSizeHeight)
    {
        NSInteger currentItems = [super numberOfItemsInSection:0 forCollectionViewWithCellType:@"ResultCell"];
        NSInteger searchResults = [self.currentSearchQuery.numresults integerValue];
        if(currentItems<searchResults){
            [super updateSearch];
        }
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    if (self.notFoundView.hidden == NO) {
        [self.view endEditing:YES];
        return YES;
    }
    _manualBtn.enabled = YES;
    [_manualBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    
    [self performSearch];
    return YES;
}

- (void)performSearch
{
//    if (_searchTextField.text != nil && _searchTextField.text != @"") {
//        self.userListMode = ALLSTYLISTS;
//    } else {
//        self.userListMode = SUGGESTED;
//    }

    [self.view endEditing:YES];
    [self resetSearch];
    
    [self performSearchWithString:self.searchTextField.text];
}

- (void)resetSearch{
    // Empty successful terms array
    [self.successfulTerms removeAllObjects];
    [self.searchTermsListView removeAllButtons];
    
    [self.suggestedFilters removeAllObjects];
    [self.suggestedFiltersObject removeAllObjects];
    
    // Empty not successful terms string
    self.notSuccessfulTerms = @"";
    [self setNotSuccessfulTermsText:@""];
    
    // Hide Filter Terms Label
    [self.noFilterTermsLabel setHidden:YES];
    
    int resultsBeforeUpdate = (int) [self.resultsArray count];
    
    // Empty old results array
    [self.resultsArray removeAllObjects];
    
    // Empty old results array
    [self.resultsGroups removeAllObjects];
    
    self.currentSearchQuery = nil;
    
    // Check if the Fetched Results Controller is already initialized; otherwise, initialize it
    if ([self getFetchedResultsControllerForCellType:@"ResultCell" ] == nil)
    {
        [self initFetchedResultsController];
    }
    
    // Update Fetched Results Controller
    [self performFetchForCollectionViewWithCellType:@"ResultCell"];
    
    // Update collection view
    [super updateCollectionViewWithCellType:@"ResultCell" fromItem:0 toItem:resultsBeforeUpdate deleting:TRUE];
    
    // Set ALL as the default relationships filter for stylists search
    self.searchStylistRelationships = self.userListMode;
    
    if (self.foundSuggestions != nil)
    {
        [self.foundSuggestions removeAllObjects];
    }
    if(self.foundSuggestionsPC != nil)
    {
        [self.foundSuggestionsPC removeAllObjects];
    }
}

- (void)performSearchWithString:(NSString*)stringToSearch
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    NSArray * requestParameters = nil;
    
    
    NSLog(@"Performing search within fashionistas with terms: %@", stringToSearch);
    
    // Perform request to get the search results
    
    // Provide feedback to user
    [self stopActivityFeedback];
    [self startActivityFeedbackWithMessage:NSLocalizedString(@"_DOWNLOADING_ACTV_MSG_", nil)];
    
    // TODO: Add post type filtering!
    
    NSString * currentUserId = @"";
    
    if(self.shownRelatedUser){
        currentUserId = self.shownRelatedUser.idUser;
    }else if(appDelegate.currentUser)
    {
        if(!([appDelegate.currentUser.idUser isEqualToString:@""]))
        {
            currentUserId = appDelegate.currentUser.idUser;
        }
    }
    
    requestParameters = [[NSArray alloc] initWithObjects:[self composeStringhWithTermsOfArray:[NSArray arrayWithObject:stringToSearch] encoding:YES], [super stringForStylistRelationship:self.userListMode], currentUserId, @"sort=tagged", nil];
    
    [self performRestGet:PERFORM_SEARCH_WITHIN_FASHIONISTAS withParamaters:requestParameters];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [super scrollViewDidScroll:scrollView];
    [self.view endEditing:YES];
}
@end
