//
//  GSTaggedHistoryViewController.m
//  GoldenSpear
//
//  Created by Adria Vernetta Rubio on 16/5/16.
//  Copyright © 2016 GoldenSpear. All rights reserved.
//

#import "GSTaggedHistoryViewController.h"
#import "BaseViewController+ActivityFeedbackManagement.h"
#import "BaseViewController+RestServicesManagement.h"
#import "TagHistory.h"
#import "BaseViewController+StoryboardManagement.h"
#import "NotificationsPostTableViewCell.h"
#import "GSDateFilterSectionHeaderView.h"

#define kFontInTagLineText "Avenir-Light"
#define kBoldFontInTagLineText "Avenir-Heavy"
#define kFontSizeInTagLineText 14

#define kLowestYearForFilter 2014

@interface GSTaggedHistoryViewController (){
    NSString* searchString;
    
    NSMutableArray* monthFilterArray;
    NSMutableDictionary* monthComponents;
    
    NSInteger yearFiltered;
    NSInteger monthFiltered;
    
    NSTimer* monthTimer;
}

@end

@implementation GSTaggedHistoryViewController

- (void)dealloc{
    self.postsArray = nil;
    self.postsIdsArray = nil;
    self.imagesQueue = nil;
    searchString = nil;
    [monthTimer invalidate];
    monthTimer = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.imagesQueue = [[NSOperationQueue alloc] init];
    
    // Set max number of concurrent operations it can perform at 3, which will make things load even faster
    self.imagesQueue.maxConcurrentOperationCount = 3;
    // Initialize results array
    if (_postsArray == nil)
    {
        _postsArray = [[NSMutableArray alloc] init];
        _postsIdsArray = [[NSMutableArray alloc] init];
    }
    [self setupMonthsForFiltering];
    [self dismissMonthSelector];
    [self.monthSelectorTable registerNib:[UINib nibWithNibName:@"GSDateFilterSectionHeaderView" bundle:[NSBundle mainBundle]] forHeaderFooterViewReuseIdentifier:@"sectionHeaderCell"];
    searchString = @"";
}

- (void)setupMonthsForFiltering{
    monthFilterArray = [NSMutableArray new];
    monthComponents = [NSMutableDictionary new];
    NSDate * today = [NSDate date];
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    NSDateComponents *dateComponents = [calendar components: (NSCalendarUnitMonth | NSCalendarUnitYear) fromDate:today];
    NSInteger currentYear = dateComponents.year;
    NSInteger currentMonth = dateComponents.month;
    
    [monthComponents setObject:[[NSMutableArray alloc] initWithObjects:@"ALL", nil] forKey:[NSNumber numberWithInteger:0]];
    [monthFilterArray addObject:[NSNumber numberWithInteger:0]];
    
    for (NSInteger i = currentYear; i>=kLowestYearForFilter; i--) {
        NSMutableArray* newYear = [NSMutableArray new];
        NSInteger limitMonth = 12;
        if (i==currentYear) {
            limitMonth = currentMonth;
        }
        for (NSInteger j=1; j<=limitMonth; j++) {
            [newYear addObject:[NSNumber numberWithInteger:j]];
        }
        [monthComponents setObject:newYear forKey:[NSNumber numberWithInteger:i]];
        [monthFilterArray addObject:[NSNumber numberWithInteger:i]];
    }
}

- (BOOL)shouldCenterTitle{
    return YES;
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.postsArray removeAllObjects];
    [self.postsIdsArray removeAllObjects];
    [self getUserPosts];
    
    NSIndexPath *path = [NSIndexPath indexPathForRow:0 inSection:0];
    [_monthSelectorTable selectRowAtIndexPath:path animated:NO scrollPosition:UITableViewScrollPositionTop];
}

#pragma mark - Connection functions

- (void)getUserPosts
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    User* theUser = appDelegate.currentUser;
    if (!(theUser.idUser == nil))
    {
        if (!([theUser.idUser isEqualToString:@""]))
        {
            NSLog(@"Retrieving User NewsFeed");
            
            // Perform request to get the search results
            
            // Provide feedback to user
            [self stopActivityFeedback];
            [self startActivityFeedbackWithMessage:NSLocalizedString(@"_DOWNLOADING_ACTV_MSG_", nil)];

            NSMutableArray * requestParameters = [[NSMutableArray alloc] initWithObjects:theUser.idUser,[NSNumber numberWithInteger:[self.postsArray count]],searchString, nil];
            NSArray* filterDateArray = [self calculateDateStringForSelection];
            if(filterDateArray&&[filterDateArray count]==2){
                [requestParameters addObjectsFromArray:filterDateArray];
            }
            [self performRestGet:GET_USER_HISTORY withParamaters:requestParameters];
        }
    }
}

- (void)updateSearch
{
    [self getUserPosts];
}

- (void)actionAfterSuccessfulAnswerToRestConnection:(connectionType)connection WithResult:(NSArray *)mappingResult{
    NSArray * parametersForNextVC = nil;
    __block FashionistaPost * selectedSpecificPost;
    
    NSMutableArray * postContent = [[NSMutableArray alloc] init];
    __block NSNumber * postLikesNumber = [NSNumber numberWithInt:0];
    NSMutableArray * resultComments = [[NSMutableArray alloc] init];
    
    switch (connection) {
        case GET_USER_HISTORY:
        {
            if([mappingResult count] > 0)
            {
                // Get the list of results that were provided
                for (TagHistory *tagH in mappingResult)
                {
                    if([tagH isKindOfClass:[TagHistory class]])
                    {
                        if(!(tagH.idTagHistory == nil))
                        {
                            if  (!([tagH.idTagHistory isEqualToString:@""]))
                            {
                                if(!([self.postsArray containsObject:tagH.idTagHistory]))
                                {
                                    [self.postsIdsArray addObject:tagH.idTagHistory];
                                    [self.postsArray addObject:tagH];
                                }
                            }
                        }
                    }
                }
            }
            
            [self stopActivityFeedback];
            [self.dataTable reloadData];
            break;
        }
        case GET_POST:
        {
            User* postUser = nil;
            // Get the post that was provided
            for (FashionistaPost *post in mappingResult)
            {
                if([post isKindOfClass:[FashionistaPost class]])
                {
                    if(!(post.idFashionistaPost == nil))
                    {
                        if  (!([post.idFashionistaPost isEqualToString:@""]))
                        {
                            selectedSpecificPost = (FashionistaPost *)post;
                            break;
                        }
                    }
                }
            }
            
            // Get the number of likes of that post
            for (NSMutableDictionary *postLikesNumberDict in mappingResult)
            {
                if([postLikesNumberDict isKindOfClass:[NSMutableDictionary class]])
                {
                    postLikesNumber = [postLikesNumberDict objectForKey:@"likes"];
                }
            }
            
            // Get the list of comments that were provided
            for (Comment *comment in mappingResult)
            {
                if([comment isKindOfClass:[Comment class]])
                {
                    if(!(comment.idComment == nil))
                    {
                        if  (!([comment.idComment isEqualToString:@""]))
                        {
                            if(!([resultComments containsObject:comment.idComment]))
                            {
                                //[resultComments addObject:comment.idComment];
                                [resultComments addObject:comment];
                            }
                        }
                    }
                }
            }
            
            // Get the list of contents that were provided
            for (FashionistaContent *content in mappingResult)
            {
                if([content isKindOfClass:[FashionistaContent class]])
                {
                    if(!(content.idFashionistaContent == nil))
                    {
                        if  (!([content.idFashionistaContent isEqualToString:@""]))
                        {
                            if(!([postContent containsObject:content]))
                            {
                                [postContent addObject:content];
                                [UIImage cachedImageWithURL:content.image];
                            }
                        }
                    }
                }
            }
            
            // Get the list of contents that were provided
            for (User *content in mappingResult)
            {
                if([content isKindOfClass:[User class]])
                {
                    if(!(content.idUser == nil))
                    {
                        if  (!([content.idUser isEqualToString:@""]))
                        {
                            postUser = content;
                        }
                    }
                }
            }
            
            // Paramters for next VC (ResultsViewController)
            parametersForNextVC = [NSArray arrayWithObjects: [NSNumber numberWithBool:YES], selectedSpecificPost, postContent, resultComments, [NSNumber numberWithBool:NO], postLikesNumber, postUser, nil];
            
            
            if((!([parametersForNextVC count] < 2)) && ([postContent count] > 0))
            {
                [self transitionToViewController:FASHIONISTAPOST_VC withParameters:parametersForNextVC];
            }
            
            [self stopActivityFeedback];
            break;
        }
        default:
            [super actionAfterSuccessfulAnswerToRestConnection:connection WithResult:mappingResult];
            break;
    }
}

#pragma mark - TableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if(tableView==self.monthSelectorTable){
        return [monthFilterArray count];
    }
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(tableView==self.monthSelectorTable){
        NSNumber* yearName = [monthFilterArray objectAtIndex:section];
        return [[monthComponents objectForKey:yearName]count];
    }
    return [self.postsArray count];
}

- (NSAttributedString *)attributedMessageWithName:(NSString *)name andText:(NSString*)text andDate:(NSString*)dateString
{
    UIFont* normalFont = [UIFont fontWithName:@kFontInTagLineText size:kFontSizeInTagLineText];
    UIFont* boldFont = [UIFont fontWithName:@kBoldFontInTagLineText size:kFontSizeInTagLineText];
    
    NSMutableAttributedString *attributedMessage = [[NSMutableAttributedString alloc] initWithString:@""];
    
    NSDictionary * attributes = @{NSForegroundColorAttributeName:[UIColor blackColor],
                                  NSFontAttributeName:boldFont};
    
    NSAttributedString * subString = [[NSAttributedString alloc]
                                      initWithString:[NSString stringWithFormat:@"%@ ",name]
                                      attributes:attributes];
    [attributedMessage appendAttributedString:subString];
    
    attributes = @{NSForegroundColorAttributeName:[UIColor blackColor],
                   NSFontAttributeName:normalFont};
    
    subString = [[NSAttributedString alloc]
                 initWithString:[NSString stringWithFormat:@"%@ ",text]
                 attributes:attributes];
    [attributedMessage appendAttributedString:subString];
    
    attributes = @{NSForegroundColorAttributeName:GOLDENSPEAR_COLOR,
                   NSFontAttributeName:boldFont};
    
    subString = [[NSAttributedString alloc]
                 initWithString:dateString
                 attributes:attributes];
    [attributedMessage appendAttributedString:subString];
    return attributedMessage;
}

- (NSString*)processDate:(NSDate*)theDate
{
    if(!theDate){
        return @"";
    }
    return [NSDateFormatter localizedStringFromDate:theDate dateStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterNoStyle];
    
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"dd/MM/yy"];
    [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en"]];
    return [dateFormatter stringFromDate:theDate];
}

-(NSAttributedString *) tagTextForTagHistory:(TagHistory *)tagLine
{
    NSString* notificationText = NSLocalizedString(@"_USER_TAGGED_PICTURE_", nil);
    if (!(tagLine.commentId == nil)) {
        if(!([tagLine.commentId isEqualToString:@""])){
            notificationText = NSLocalizedString(@"_USER_TAGGED_COMMENT_", nil);
        }
    }
    
    NSString* userName = tagLine.taggerName;
    NSString* noticeDate = [self processDate:tagLine.date];
    
    return [self attributedMessageWithName:userName andText:notificationText andDate:noticeDate];
}

- (UITableViewCell *)tableView:(UITableView *)tableView tagCellForRowAtIndexPath:(NSIndexPath *)indexPath{
    TagHistory * tagLine = [self.postsArray objectAtIndex:indexPath.row];
    
    NSAttributedString* text = [self tagTextForTagHistory:tagLine];
    NSString* identifier = @"postNotifCell";
    
    NotificationsPostTableViewCell* theCell = [tableView dequeueReusableCellWithIdentifier:identifier];
    theCell.userName.attributedText = text;
    NSString* previewImage = tagLine.taggerPicture;
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
        [theCell.theImage setImageWithURL:[NSURL URLWithString:previewImage] placeholderImage:[UIImage imageNamed:@"no_image.png"]];
        /*
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
         */
    }
    
    previewImage = tagLine.postPreview;
    theCell.imageURL = previewImage;
    if ([UIImage isCached:previewImage])
    {
        UIImage * image = [UIImage cachedImageWithURL:previewImage];
        
        if(image == nil)
        {
            image = [UIImage imageNamed:@"no_image.png"];
        }
        theCell.postImage.image = image;
    }
    else
    {
        [theCell.postImage setImageWithURL:[NSURL URLWithString:previewImage] placeholderImage:[UIImage imageNamed:@"no_image.png"]];
        /*
        NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
            
            UIImage * image = [UIImage cachedImageWithURL:previewImage];
            
            if(image == nil)
            {
                image = [UIImage imageNamed:@"no_image.png"];
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                // Then set them via the main queue if the cell is still visible.
                if ([tableView.indexPathsForVisibleRows containsObject:indexPath]&&[theCell.postImageURL isEqualToString:previewImage])
                {
                    theCell.postImage.image = image;
                }
            });
        }];
        
        operation.queuePriority = NSOperationQueuePriorityHigh;
        
        [self.imagesQueue addOperation:operation];
         */
    }
    
    return theCell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView==self.monthSelectorTable) {
        return [self tableView:tableView dateCellForRowAtIndexPath:indexPath];
    }else{
        return [self tableView:tableView tagCellForRowAtIndexPath:indexPath];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView==self.monthSelectorTable) {
        [self tableView:tableView didSelectMonthRowAtIndexPath:indexPath];
    }else{
        [self tableView:tableView didSelectTagRowAtIndexPath:indexPath];
    }
}

- (void)tableView:(UITableView *)tableView didSelectTagRowAtIndexPath:(NSIndexPath *)indexPath{
    TagHistory * tagLine = [self.postsArray objectAtIndex:indexPath.row];
    
    if(!(tagLine.postId == nil))
    {
        if(!([tagLine.postId isEqualToString:@""]))
        {
            // Provide feedback to user
            [self stopActivityFeedback];
            [self startActivityFeedbackWithMessage:NSLocalizedString(@"_DOWNLOADINGCONTENT_ACTV_MSG_", nil)];
            
            NSArray * requestParameters = [[NSArray alloc] initWithObjects:tagLine.postId, nil];
            
            [self performRestGet:GET_POST withParamaters:requestParameters];
        }
    }
}

#pragma mark - ScrollView

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    if (scrollView==self.dataTable) {
        [self moveMonthFilter:YES];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    if (scrollView==self.dataTable) {
        float scrollViewHeight = scrollView.frame.size.height;
        float scrollContentSizeHeight = scrollView.contentSize.height;
        float scrollOffset = scrollView.contentOffset.y;
        
        if (scrollOffset == 0)
        {
            // then we are at the top
        }
        else if (scrollOffset + scrollViewHeight >= scrollContentSizeHeight)
        {
            [self updateSearch];
        }
        monthTimer = [NSTimer scheduledTimerWithTimeInterval:3
                                                      target:self
                                                    selector:@selector(dismissMonthSelector)
                                                    userInfo:nil
                                                     repeats:NO];
    }
}

- (void)dismissMonthSelector{
    [self moveMonthFilter:NO];
}

#pragma mark - Search

- (void)searchBarResultsListButtonClicked:(UISearchBar *)searchBar{
    [searchBar resignFirstResponder];
    [self performSearch];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    [searchBar resignFirstResponder];
    [self performSearch];
}

- (void)performSearch
{
    [self resetSearch];
    [self performSearchWithString:_searchBar.text];
}

- (void)resetSearch{
    [self.postsArray removeAllObjects];
    [self.postsIdsArray removeAllObjects];
}

- (void)performSearchWithString:(NSString*)stringToSearch
{
    searchString = stringToSearch;
    [self getUserPosts];
}

#pragma mark - DateFilter

- (void)moveMonthFilter:(BOOL)showOrNot{
    CGFloat alpha = 0.0;
    if (showOrNot) {
        alpha = 1.0;
        [self.monthSelectorTable.superview bringSubviewToFront:self.monthSelectorTable];
    }
    
    [UIView animateWithDuration:0.3
                     animations:^{
                         self.monthSelectorTable.alpha = alpha;
                     }
                     completion:^(BOOL finished) {
                         if (!showOrNot) {
                             [self.monthSelectorTable.superview sendSubviewToBack:self.monthSelectorTable];
                         }
                     }];
}

- (NSString*)getMonthLabelForIndex:(NSInteger)monthIndex{
    switch (monthIndex) {
        case 0:
            return @"ALL";
            break;
        case 1:
            return @"JAN";
            break;
        case 2:
            return @"FEB";
            break;
        case 3:
            return @"MAR";
            break;
        case 4:
            return @"APR";
            break;
        case 5:
            return @"MAY";
            break;
        case 6:
            return @"JUN";
            break;
        case 7:
            return @"JUL";
            break;
        case 8:
            return @"AUG";
            break;
        case 9:
            return @"SEP";
            break;
        case 10:
            return @"OCT";
            break;
        case 11:
            return @"NOV";
            break;
        case 12:
            return @"DEC";
            break;
        default:
            return @"";
            break;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView dateCellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"monthCell"];
    UIView* goldenBack = [UIView new];
    goldenBack.backgroundColor = GOLDENSPEAR_COLOR;
    cell.selectedBackgroundView = goldenBack;
    UILabel* theLabel = (UILabel*)[cell viewWithTag:100];
    NSNumber* yearName = [monthFilterArray objectAtIndex:indexPath.section];
    NSArray* monthArray = [monthComponents objectForKey:yearName];
    NSString* monthLabel = [self getMonthLabelForIndex:[[monthArray objectAtIndex:indexPath.row] integerValue]];
    theLabel.text = monthLabel;
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if(tableView==self.monthSelectorTable)
        return [NSString stringWithFormat:@"%i",[[monthFilterArray objectAtIndex:section] integerValue]];
    return @"";
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if(tableView==self.monthSelectorTable) {
        if (section == 0) {
            return 0;
        }
        return 35;
    }
    return 0;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    return [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"sectionHeaderCell"];
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section{
    GSDateFilterSectionHeaderView* header = (GSDateFilterSectionHeaderView*)view;
    header.nameLabel.text = [self tableView:tableView titleForHeaderInSection:section];
    if(header.headerButton.tag==0){
        [header.headerButton addTarget:self action:@selector(changeYear:) forControlEvents:UIControlEventTouchUpInside];
    }
    header.headerButton.tag = [header.nameLabel.text integerValue];
}

- (void)tableView:(UITableView *)tableView didSelectMonthRowAtIndexPath:(NSIndexPath *)indexPath{
    NSNumber* newYearFiltered = [monthFilterArray objectAtIndex:indexPath.section];
    NSInteger newMonthFiltered = [[[monthComponents objectForKey:newYearFiltered] objectAtIndex:indexPath.row] integerValue];
    if (indexPath.section == 0) {
        yearFiltered = 0;
        monthFiltered = 0;
    }
    else if(yearFiltered==[newYearFiltered integerValue]&&newMonthFiltered==monthFiltered){
        //Same row, disable filtering
        yearFiltered = 0;
        monthFiltered = 0;
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
        
        NSIndexPath *path = [NSIndexPath indexPathForRow:0 inSection:0];
        [tableView selectRowAtIndexPath:path animated:NO scrollPosition:UITableViewScrollPositionTop];
    }
    else{
        yearFiltered = [newYearFiltered integerValue];
        monthFiltered = newMonthFiltered;
    }
    [self moveMonthFilter:NO];
    //Reload search with new filter
    [self performSearch];
}

- (void)changeYear:(UIButton*)sender{
    NSNumber* newYearFiltered = [NSNumber numberWithInteger:sender.tag];
    NSInteger newMonthFiltered = 0;
    if(yearFiltered==[newYearFiltered integerValue]&&newMonthFiltered==monthFiltered){
        //Same row, disable filtering
        yearFiltered = 0;
        monthFiltered = 0;
    }
    else{
        NSInteger currentSection = [monthFilterArray indexOfObject:[NSNumber numberWithInteger:yearFiltered]];
        NSIndexPath* indexPath = [NSIndexPath indexPathForRow:monthFiltered inSection:currentSection];
        [self.monthSelectorTable deselectRowAtIndexPath:indexPath animated:NO];
        yearFiltered = [newYearFiltered integerValue];
        monthFiltered = newMonthFiltered;
    }
    [self moveMonthFilter:NO];
    //Reload search with new filter
    [self performSearch];
}

#pragma mark - MonthFilterHelpers
- (NSArray*) calculateDateStringForSelection
{
    if (yearFiltered==0) {
        return nil;
    }
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    NSLocale *enUSPOSIXLocale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
    
    [dateFormatter setLocale:enUSPOSIXLocale];
    
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"];
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    NSDateComponents *dateComponents = [calendar components: ( NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond )  fromDate:[NSDate date]];
    dateComponents.day = 1;
    dateComponents.hour=0;
    dateComponents.minute=0;
    dateComponents.second=5;
    
    NSInteger nextMonth;
    NSInteger nextYear;
    NSInteger currentMonth;
    NSInteger currentYear;
    if(monthFiltered==0){
        //Filter all year
        nextYear = yearFiltered+1;
        nextMonth = 1;
        currentMonth = 1;
        currentYear = yearFiltered;
    }else{
        nextMonth = monthFiltered+1;
        nextYear = yearFiltered;
        if (nextMonth>12) {
            nextMonth = 1;
            nextYear++;
        }
        currentMonth = monthFiltered;
        currentYear = yearFiltered;
    }
    
    dateComponents.month = currentMonth;
    dateComponents.year = currentYear;
    NSDate* fromDate = [calendar dateFromComponents:dateComponents];
    
    dateComponents.month = nextMonth;
    dateComponents.year = nextYear;
    NSDate* toDate = [calendar dateFromComponents:dateComponents];
    
    NSString* fromDateString = [dateFormatter stringFromDate:fromDate];
    NSString* toDateString = [dateFormatter stringFromDate:toDate];
    return [NSArray arrayWithObjects:fromDateString,toDateString,nil];
}

@end
