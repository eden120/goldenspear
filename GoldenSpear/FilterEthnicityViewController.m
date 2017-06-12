//
//  FilterEthnicityViewController.m
//  GoldenSpear
//
//  Created by Crane on 9/21/16.
//  Copyright © 2016 GoldenSpear. All rights reserved.
//

#import "FilterEthnicityViewController.h"
#import "BaseViewController+TopBarManagement.h"
#import "BaseViewController+ActivityFeedbackManagement.h"
#import "User+Manage.h"
#import "LiveAddItemView.h"

#define kNameKey    @"name"
#define kOtherKey   @"other"
#define kEthnicityKey   @"ethnicity"
#define kIdKey   @"id"
@interface FilterEthnicityViewController () {
    NSMutableDictionary* ethnyObjectDictionary;
    User* current;
    UITextView *text_view;
    CGFloat keyboardHeight;
    NSMutableArray *ethnicities;
    NSMutableDictionary* selectedEthnies;
    BOOL addORNo;
    BOOL delBtnClicked;
}

@end

@implementation FilterEthnicityViewController

- (void)dealloc{
    ethnyObjectDictionary = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.translatesAutoresizingMaskIntoConstraints = NO;
    ethnicities = [[NSMutableArray alloc]init];
    [self hideTopBar];
    ethnyObjectDictionary = [NSMutableDictionary new];
    keyboardHeight = 0;
    
    LiveAddItemView *addView =
    [[[NSBundle mainBundle] loadNibNamed:@"LiveAddItemView" owner:self options:nil] objectAtIndex:0];
    addView.titleLab.text = NSLocalizedString(@"_LIVE_ETHNICITY_", nil);
    addView.addBtn.hidden = YES;

    [addView.addBtn addTarget:self action:@selector(addAction:) forControlEvents:UIControlEventTouchUpInside];
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(textViewTapped:)];
    [addView.contentText addGestureRecognizer:gestureRecognizer];
    text_view = addView.contentText;
    
    
    addView.frame = _ethnicityView.bounds;
    [_ethnicityView addSubview:addView];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidChangeFrameWithNotification:) name:UIKeyboardWillChangeFrameNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShowNotification:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHideNotification:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)textViewTapped:(UITapGestureRecognizer *)recognizer
{
    NSLog(@"Single Tap");
    UITextView *textView_New = (UITextView *)recognizer.view;
    CGPoint pos = [recognizer locationInView:textView_New];
    NSLog(@"Tap Gesture Coordinates: %.2f %.2f", pos.x, pos.y);
    UITextPosition *tapPos = [textView_New closestPositionToPoint:pos];
    UITextRange * wr = [textView_New.tokenizer rangeEnclosingPosition:tapPos withGranularity:UITextGranularityWord inDirection:UITextLayoutDirectionRight];
    
    NSString *selectedText = [textView_New textInRange:wr];
    NSLog(@"selectedText: %@", selectedText);
    if (selectedText == nil || [selectedText isEqualToString:@""])
        return;
    
    NSRange range = [self selectedRangeInTextView:textView_New cornvertRange:wr];
    NSLog(@"WORD: %d", range.location);
    
    
    NSString *sting = textView_New.text;
    int startPosition = 0, endPosotion = 0;
    for (int i = (int)range.location; i >= 0; i--) {
        char character = [sting characterAtIndex:i];
        
        if (character == '|') {
            startPosition = i + 2;
            break;
        }
        if (i == 0) {
            startPosition = i;
            break;
        }
    }
    
    for (int i = (int)range.location; i < [sting length]; i++) {
        char character = [sting characterAtIndex:i];
        if (character == '|') {
            endPosotion = i - 1;
            break;
        }
        if (i == [sting length] - 1) {
            endPosotion = [sting length];
            break;
        }
    }
    

    
    UITextRange *newRange = [self frameOfTextRange:NSMakeRange(startPosition, endPosotion - startPosition) inTextView:textView_New];
    
    NSString *allSelectedText = [textView_New textInRange:newRange];
    NSLog(@"selectedText: %@", allSelectedText);
 
    for (NSDictionary *dic in _selectedEthy) {
        NSString *str = nil;
        id other = [dic objectForKey:kOtherKey];
        if(other){
            if(![other isEqualToString:@""]){
                str = other;
            }
        }else{
            str = [dic objectForKey:kNameKey];
        }
        if (str != nil && [str isEqualToString:allSelectedText]) {
            delBtnClicked = NO;
            [self removeOnEthnicityBox:dic];
            return;
        }
    }
}
- (void)addAction:(UIButton*)button {
    
}

- (UITextRange *)frameOfTextRange:(NSRange)range inTextView:(UITextView *)textView
{
    UITextPosition *beginning = textView.beginningOfDocument;
    UITextPosition *start = [textView positionFromPosition:beginning offset:range.location];
    UITextPosition *end = [textView positionFromPosition:start offset:range.length];
    UITextRange *textRange = [textView textRangeFromPosition:start toPosition:end];
    
    return textRange;
}

- (NSRange) selectedRangeInTextView:(UITextView*)textView cornvertRange:(UITextRange*)selectedRange
{
    UITextPosition* beginning = textView.beginningOfDocument;
    
    //    UITextRange* selectedRange = textView.selectedTextRange;
    UITextPosition* selectionStart = selectedRange.start;
    UITextPosition* selectionEnd = selectedRange.end;
    
    const NSInteger location = [textView offsetFromPosition:beginning toPosition:selectionStart];
    const NSInteger length = [textView offsetFromPosition:selectionStart toPosition:selectionEnd];
    
    return NSMakeRange(location, length);
}
- (void)keyboardWillHideNotification:(NSNotification *)notification
{
    [self animateTextViewFrameForVerticalHeight:0];
}

- (void)keyboardWillShowNotification:(NSNotification *)notification
{
    [self animateTextViewFrameForVerticalHeight:keyboardHeight];
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
    self.scrollBottomDistanceConstraint.constant = MAX(height,0);
    [self.view layoutIfNeeded];
}

// Animate the Add Terms text box when keyboard appears
- (void)animateTextViewFrameForVerticalOffset:(CGFloat)offset
{
    CGFloat constant = self.scrollBottomDistanceConstraint.constant;
    CGFloat newConstant = constant + offset;// + 50;
    [self animateTextViewFrameForVerticalHeight:newConstant];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    current = [(AppDelegate*)[UIApplication sharedApplication].delegate currentUser];
    [self startActivityFeedbackWithMessage:@""];
    
    [self layoutEthnicities];
    [self processSelectedEtnicities:_selectedEthy];
  //  [self getCurrentUserEthnicities];
    [self showEthnicityBox];
    [self stopActivityFeedback];
}

- (void)processSelectedEtnicities:(NSArray*)ethns{
    for (NSDictionary* ethny in ethns) {
        GSEthnyView* ethnyView = [ethnyObjectDictionary objectForKey:[ethny objectForKey:kGroupKey]];
        [ethnyView selectEthny:ethny];
    }
}

- (void)removeSelectedEtnicities:(NSDictionary*)ethny{
    GSEthnyView* ethnyView = [ethnyObjectDictionary objectForKey:[ethny objectForKey:kGroupKey]];
    [ethnyView resetSelectedEthny:ethny];
}
- (void)fixLayout{
    for(NSString* key in [ethnyObjectDictionary allKeys]){
        GSEthnyView* eV = [ethnyObjectDictionary objectForKey:key];
        [eV fixLayout];
    }
}

- (void)addLayoutForView:(UIView*)theView withPreviousView:(UIView*)previousView{
    //Height
    NSLayoutConstraint* aConstraint = [NSLayoutConstraint constraintWithItem:theView
                                                                   attribute:NSLayoutAttributeHeight
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:nil
                                                                   attribute:NSLayoutAttributeNotAnAttribute
                                                                  multiplier:1
                                                                    constant:theView.frame.size.height];
    [theView addConstraint:aConstraint];
    
    //Width
    aConstraint = [NSLayoutConstraint constraintWithItem:theView
                                               attribute:NSLayoutAttributeWidth
                                               relatedBy:NSLayoutRelationEqual
                                                  toItem:theView.superview
                                               attribute:NSLayoutAttributeWidth
                                              multiplier:1
                                                constant:0];
    [theView.superview addConstraint:aConstraint];
    
    //Center Hori
    aConstraint = [NSLayoutConstraint constraintWithItem:theView
                                               attribute:NSLayoutAttributeCenterX
                                               relatedBy:NSLayoutRelationEqual
                                                  toItem:theView.superview
                                               attribute:NSLayoutAttributeCenterX
                                              multiplier:1
                                                constant:0];
    [theView.superview addConstraint:aConstraint];
    
    //Y
    if (previousView) {
        aConstraint = [NSLayoutConstraint constraintWithItem:theView
                                                   attribute:NSLayoutAttributeTop
                                                   relatedBy:NSLayoutRelationEqual
                                                      toItem:previousView
                                                   attribute:NSLayoutAttributeBottom
                                                  multiplier:1
                                                    constant:10];
        
        [theView.superview addConstraint:aConstraint];
    }else{
        aConstraint = [NSLayoutConstraint constraintWithItem:theView
                                                   attribute:NSLayoutAttributeTop
                                                   relatedBy:NSLayoutRelationEqual
                                                      toItem:theView.superview
                                                   attribute:NSLayoutAttributeTop
                                                  multiplier:1
                                                    constant:0];
        [theView.superview addConstraint:aConstraint];
    }
    
}

- (void)layoutEthnicities{
    CGRect theFrame = CGRectMake(10, 0, self.ethnicitiesContainer.frame.size.width, 125);
    GSEthnyView* previousView = nil;
    for (NSString* group in current.groupsArray) {
        NSArray* ethnies = [current.groupEthniesDict objectForKey:group];
        [ethnicities addObjectsFromArray:ethnies];
        GSEthnyView* ethnyView = [GSEthnyView new];
        ethnyView.delegate = self;
        [ethnyView setEthnyGroupCollection:ethnies];
        [ethnyObjectDictionary setObject:ethnyView forKey:group];
        
        [self.ethnicitiesContainer addSubview:ethnyView];
        [self addLayoutForView:ethnyView withPreviousView:previousView];
        previousView = ethnyView;
        theFrame.size.height = ethnyView.frame.size.height;
        theFrame.origin.y += theFrame.size.height+10;
    }
    self.ethnicitiesContainerHeight.constant = theFrame.origin.y;
    [self.view layoutIfNeeded];
}

- (void)getCurrentUserEthnicities{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSString* userEthnicityUrl = [NSString stringWithFormat:@"%@/user_ethnicity?user=%@", RESTBASEURL, appDelegate.currentUser.idUser];
    NSMutableURLRequest *configRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:userEthnicityUrl] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:30];
    [configRequest setHTTPMethod:@"GET"];
    
    [configRequest setValue:@"application/json;charset=UTF-8" forHTTPHeaderField:@"content-type"];
    NSError *requestError;
    
    NSURLResponse *requestResponse;
    
    NSData *configResponseData = [NSURLConnection sendSynchronousRequest:configRequest returningResponse:&requestResponse error:&requestError];
    int statusCode = (int)[((NSHTTPURLResponse *)requestResponse) statusCode];
    
    if(!(configResponseData == nil) && statusCode != 404)
    {
        id json = [NSJSONSerialization JSONObjectWithData:configResponseData options: NSJSONReadingMutableContainers error: &requestError];
        [self processSelectedEtnicities:json];
    }
}

- (IBAction)savePushed:(id)sender{
    [self.relatedDelegate closeRelatedViewController:self];
}

#pragma mark - EthnyViewDelegate

- (void)commitEthny:(NSDictionary*)ethny forAdding:(BOOL)addOrNot{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    NSString* userEthnicityUrl;
    if (addOrNot) {
        userEthnicityUrl = [NSString stringWithFormat:@"%@/user_ethnicity", RESTBASEURL];
    }else{
        userEthnicityUrl = [NSString stringWithFormat:@"%@/user_ethnicity?user=%@&ethnicity=%@", RESTBASEURL, appDelegate.currentUser.idUser,[ethny objectForKey:kIdKey]];
    }
    
    NSMutableURLRequest *configRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:userEthnicityUrl] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:30];
    if(addOrNot){
        [configRequest setHTTPMethod:@"POST"];
        NSMutableDictionary* body = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                     appDelegate.currentUser.idUser,@"user",
                                     [ethny objectForKey:kIdKey],@"ethnicity",nil];
        id other = [ethny objectForKey:kOtherKey];
        if (other!=nil&&![other isEqualToString:@""]) {
            [body setObject:[ethny objectForKey:kOtherKey] forKey:kOtherKey];
        }
        NSError *error = nil;
        [configRequest setHTTPBody:[NSJSONSerialization dataWithJSONObject:body options:0 error:&error]];
    }else{
        [configRequest setHTTPMethod:@"DELETE"];
    }
    [configRequest setValue:@"application/json;charset=UTF-8" forHTTPHeaderField:@"content-type"];
    
    NSError *requestError;
    
    NSURLResponse *requestResponse;
    
    NSData *configResponseData = [NSURLConnection sendSynchronousRequest:configRequest returningResponse:&requestResponse error:&requestError];
    int statusCode = (int)[((NSHTTPURLResponse *)requestResponse) statusCode];
    
    if(!(configResponseData == nil) && statusCode != 404)
    {
        id json = [NSJSONSerialization JSONObjectWithData:configResponseData options: NSJSONReadingMutableContainers error: &requestError];
        [self addOnEthnicityBox:json];
    }
    [self stopActivityFeedback];
}


- (void)deleteEthny:(NSDictionary *)ethny{
    delBtnClicked = YES;
    [self removeOnEthnicityBox:ethny];
}

- (void)addNewEthny:(NSDictionary *)ethny{
    [self addOnEthnicityBox:ethny];
}

- (void)addOnEthnicityBox:(NSDictionary*)ethny
{
    if (_selectedEthy == nil) {
        _selectedEthy = [[NSMutableArray new] init];
    }
    
    id other = [ethny objectForKey:kOtherKey];
    if(other){
        if(![other isEqualToString:@""]){
            
            int replaceIndex = -1;
            for (int i = 0; i < _selectedEthy.count; i++) {
                NSDictionary *dic = [_selectedEthy objectAtIndex:i];
                NSString *dicStr = [dic objectForKey:kIdKey];
                if ([[ethny objectForKey:kIdKey] isEqualToString:dicStr]) {
                    replaceIndex = i;
                    break;
                    
                }
            }
            if (replaceIndex > -1) {
                [_selectedEthy replaceObjectAtIndex:replaceIndex withObject:ethny];
                [self showEthnicityBox];
                return;
            }
        }
    }
    
    NSString *title = text_view.text;
    
    [_selectedEthy addObject:ethny];
    NSString *str;
    
    if(other){
        if(![other isEqualToString:@""]){
            str = other;
        }
    }else{
        str = [ethny objectForKey:kNameKey];
    }
    
    if (str != nil && ![str isEqualToString:@""]) {
        if ([title isEqualToString:@""] || [title isEqualToString:@"All"] || title == nil) {
            title = str;
        } else {
            title = [NSString stringWithFormat:@"%@ | %@", title, str];
        }
        text_view.text = title;
        
        if ([self.filterEthnicityDelegate respondsToSelector:@selector(setEthnicity:type:)]) {
            [self.filterEthnicityDelegate setEthnicity:_selectedEthy type:_type];
        }
    }
}

- (void)removeOnEthnicityBox:(NSDictionary*)ethny
{
    id other = [ethny objectForKey:kOtherKey];
    if(other){
            NSDictionary *delDic = nil;
            for (NSDictionary *dic in _selectedEthy) {
                NSString *dicStr = [dic objectForKey:kIdKey];
                if ([[ethny objectForKey:kIdKey] isEqualToString:dicStr]) {
                    delDic = dic;
                    break;
                    
                }
            }
            if (delDic != nil) {
                [_selectedEthy removeObject:delDic];
                if (!delBtnClicked)
                    [self removeSelectedEtnicities:delDic];
                [self showEthnicityBox];
            }
    }
    else {
        if ([_selectedEthy containsObject:ethny]) {
            [_selectedEthy removeObject:ethny];
            if (!delBtnClicked)
                [self removeSelectedEtnicities:ethny];
            [self showEthnicityBox];
        }
    }
}

- (void)showEthnicityBox
{
    if (_selectedEthy == nil) return;
    
    NSString *title = @"All";
    for (NSDictionary *selDic in _selectedEthy) {
        NSString *str;
        id other = [selDic objectForKey:kOtherKey];
        if(other){
            if(![other isEqualToString:@""]){
                str = other;
            }
        }else{
            str = [selDic objectForKey:kNameKey];
        }
        
        if (str != nil && ![str isEqualToString:@""]) {
            if ([title isEqualToString:@""] || [title isEqualToString:@"All"]) {
                title = str;
            } else {
                title = [NSString stringWithFormat:@"%@ | %@", title, str];
            }
        }
    }
    text_view.text = title;
    
    if ([self.filterEthnicityDelegate respondsToSelector:@selector(setEthnicity:type:)]) {
        [self.filterEthnicityDelegate setEthnicity:_selectedEthy type:_type];
    }
}
@end
