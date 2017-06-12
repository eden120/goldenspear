//
//  FashionistaAddCommentViewController.m
//  GoldenSpear
//
//  Created by Adria Vernetta Rubio on 2/5/16.
//  Copyright © 2016 GoldenSpear. All rights reserved.
//

#import "FashionistaAddCommentViewController.h"
#import "BaseViewController+RestServicesManagement.h"
#import "FashionistaUserListViewCell.h"
#define kCommentTranslation ((IS_IPHONE_4_OR_LESS) ? (160) : (240))
#define kAutoTableHeight  ((IS_IPHONE_5_OR_LESS) ? (130) : (300))
@interface FashionistaAddCommentViewController (){
    CGFloat keyboardHeight;
}

@end

@implementation FashionistaAddCommentViewController {
    BOOL isSearchUser;
    NSMutableArray *userList;
    NSRange replaceRange;
    NSString *searchString;
}

- (void)viewDidLoad{
    [super viewDidLoad];
    self.view.translatesAutoresizingMaskIntoConstraints = NO;
    isSearchUser = NO;
    keyboardHeight = 0;
    
    userList = [[NSMutableArray alloc] init];

    self.commentTextEdit.delegate = self;
    
    self.imagesQueue = [[NSOperationQueue alloc] init];
    
    // Set max number of concurrent operations it can perform at 3, which will make things load even faster
    self.imagesQueue.maxConcurrentOperationCount = 3;
    
    _autoTableHeight.constant = 0;
    _autoTableView.hidden = YES;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if (self.oldComment) {
        self.commentTextEdit.text = self.oldComment.text;
    }
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidChangeFrameWithNotification:) name:UIKeyboardWillChangeFrameNotification object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShowNotification:) name:UIKeyboardDidShowNotification object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHideNotification:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)keyboardWillHideNotification:(NSNotification *)notification
{
    [self animateTextViewFrameForVerticalHeight:20];
}

- (void)keyboardWillShowNotification:(NSNotification *)notification
{
    [self animateTextViewFrameForVerticalHeight:kCommentTranslation];
}

- (void)keyboardDidChangeFrameWithNotification:(NSNotification *)notification
{
    // Calculate vertical increase
    CGFloat keyboardVerticalIncrease = [self keyboardVerticalIncreaseForNotification:notification];
    keyboardHeight += keyboardVerticalIncrease;
    // Properly animate Add Terms text box
    [self animateTextViewFrameForVerticalOffset:keyboardVerticalIncrease];
}

// Calculate the vertical increase when keyboard appears
- (CGFloat)keyboardVerticalIncreaseForNotification:(NSNotification *)notification
{
    CGFloat keyboardBeginY = [notification.userInfo[UIKeyboardFrameBeginUserInfoKey] CGRectValue].origin.y;
    
    CGFloat keyboardEndY = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue].origin.y;
    
    CGFloat keyboardVerticalIncrease = keyboardBeginY - keyboardEndY;
    
    return keyboardVerticalIncrease;
}

- (void)animateTextViewFrameForVerticalHeight:(CGFloat)height{
    self.commentButtonBottom.constant = MAX(height,20);
    [self.view layoutIfNeeded];
}

// Animate the Add Terms text box when keyboard appears
- (void)animateTextViewFrameForVerticalOffset:(CGFloat)offset
{
    CGFloat constant = self.commentButtonBottom.constant;
    if(constant==20){
        constant = 0;
    }
    CGFloat newConstant = constant + offset;// + 50;
    [self animateTextViewFrameForVerticalHeight:newConstant];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self.commentTextEdit becomeFirstResponder];
}

- (IBAction)addCommentTap:(id)sender {
    // Check that the review has some text
    if ([self.commentTextEdit.text length] == 0)
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_POST_COMMENT_", nil) message:NSLocalizedString(@"_POST_COMMENT_ADDSOMETEXT_MSG_", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"_OK_", nil) otherButtonTitles:nil];
        
        [alertView show];
    }
    else
    {
        [self.view endEditing:YES];
        
        if (!self.oldComment) {
            
            AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            
            NSManagedObjectContext *currentContext = [RKObjectManager sharedManager].managedObjectStore.mainQueueManagedObjectContext;
            
            Comment *newComment = [[Comment alloc] initWithEntity:[NSEntityDescription entityForName:@"Comment" inManagedObjectContext:currentContext] insertIntoManagedObjectContext:currentContext];
            
            [newComment setUserId:appDelegate.currentUser.idUser];
            [newComment setLocation:NSLocalizedString(@"_COULDNT_RETRIEVE_USERLOCATION_", nil)];
            [newComment setText:self.commentTextEdit.text];
            [newComment setFashionistaPostName:appDelegate.currentUser.fashionistaName];
            
            [self.commentDelegate updateNewComment:newComment];
        }else{
            [self.oldComment setText:self.commentTextEdit.text];
            
            [self.commentDelegate updateOldComment:self.oldComment atIndex:self.commentIndex];
        }
    }
}

-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    NSLog(@"Edit Text View : %@" ,text);
    
    if ([text isEqualToString:@" "]) {
        isSearchUser = NO;
        _autoTableHeight.constant = 0;
        _autoTableView.hidden = YES;
        return YES;
    }
    
    NSString *subString = textView.text;
    subString = [subString stringByReplacingCharactersInRange:range withString:text];
    NSLog(@"SubString  :  %@", subString);

    NSArray *components = [subString componentsSeparatedByString: @" "];
    NSString *temp = [components objectAtIndex:[components count] - 1];
    
    if (temp == nil || [temp isEqualToString:@""]) {
        isSearchUser = NO;
        _autoTableHeight.constant = 0;
        _autoTableView.hidden = YES;
        return YES;
    }
    
    NSString *firstletter = [temp substringToIndex:1];
    if ([firstletter isEqualToString:@"@"]) {
        searchString = [temp substringFromIndex:1];
        
        NSLog(@"Search STring : %@", searchString);
        if ([searchString isEqualToString:@""]) {
            if (!isSearchUser) {
                replaceRange = range;
            }
            isSearchUser = NO;
            _autoTableHeight.constant = 0;
            _autoTableView.hidden = YES;
            return YES;
        }
        if (!isSearchUser) {
            replaceRange.location = range.location - [searchString length] - range.length;
        }
        isSearchUser = YES;
        [self autoCompleteSearch:searchString];
        return YES;
    }
    
    isSearchUser = NO;
    _autoTableHeight.constant = 0;
    _autoTableView.hidden = YES;
    return YES;
}

-(void)autoCompleteSearch:(NSString*)searchString {
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];

    NSArray *requestParam = [[NSArray alloc] initWithObjects:appDelegate.currentUser.idUser, searchString, @"0", @"30", nil];
    [self performRestGet:GET_USERS_FOR_AUTOFILL withParamaters:requestParam];
}

-(void)actionAfterSuccessfulAnswerToRestConnection:(connectionType)connection WithResult:(NSArray *)mappingResult {
    
    NSMutableArray *results = [[NSMutableArray alloc] init];
    
    switch (connection)
    {
        case GET_USERS_FOR_AUTOFILL:
        {
            for (User *user in mappingResult) {
                [results addObject:user];
            }
            
            userList = results;
            if ([userList count] != 0 && isSearchUser) {
                _autoTableHeight.constant = kAutoTableHeight;
                _autoTableView.hidden = NO;
            }
            else {
                _autoTableHeight.constant = 0;
                _autoTableView.hidden = YES;
            }
            [_autoTableView reloadData];
        }
        default:
            break;
    }
}

-(void)textViewDidBeginEditing:(UITextView *)textView {
    [self keyboardWillShowNotification:nil];
}

-(void)textViewDidEndEditing:(UITextView *)textView {
    [self keyboardWillHideNotification:nil];
    
    isSearchUser = NO;
    _autoTableHeight.constant = 0;
    _autoTableView.hidden = YES;
}

#pragma mark - UITableViewDelegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    FashionistaUserListViewCell* theCell = [tableView dequeueReusableCellWithIdentifier:@"autoCell"];
    
    User* user = [userList objectAtIndex:indexPath.row];
    
    theCell.userName.text = user.fashionistaName;
    theCell.userTitle.text = user.fashionistaTitle;
    theCell.imageURL = user.picture;
    
    if ([UIImage isCached:user.picture])
    {
        UIImage * image = [UIImage cachedImageWithURL:user.picture];
        
        if(image == nil)
        {
            image = [UIImage imageNamed:@"no_image.png"];
        }
        
        theCell.theImage.image = image;
    }
    else
    {
        NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
            
            UIImage * image = [UIImage cachedImageWithURL:user.picture];
            
            if(image == nil)
            {
                image = [UIImage imageNamed:@"no_image.png"];
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                // Then set them via the main queue if the cell is still visible.
                if ([tableView.indexPathsForVisibleRows containsObject:indexPath]&&[theCell.imageURL isEqualToString:user.picture])
                {
                    theCell.theImage.image = image;
                }
            });
        }];
        
        operation.queuePriority = NSOperationQueuePriorityHigh;
        
        [self.imagesQueue addOperation:operation];
    }

    
    return theCell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [userList count];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (!isSearchUser) {
        return;
    }
    
    User *user = [userList objectAtIndex:indexPath.row];
    
    NSString *str = _commentTextEdit.text;

    NSRange range = replaceRange;
    range.location = replaceRange.location + 1;
    range.length = [searchString length];
    NSString *replaceString = [NSString stringWithFormat:@"%@ ", user.fashionistaName];
    str = [str stringByReplacingCharactersInRange:range withString:replaceString];
    
    _commentTextEdit.text = str;
    
    isSearchUser = NO;
    _autoTableHeight.constant = 0;
    _autoTableView.hidden = YES;
}


@end
