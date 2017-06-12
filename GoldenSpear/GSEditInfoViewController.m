//
//  GSEditInfoViewController.m
//  GoldenSpear
//
//  Created by Adria Vernetta Rubio on 8/5/16.
//  Copyright © 2016 GoldenSpear. All rights reserved.
//

#import "GSEditInfoViewController.h"
#import "BaseViewController+StoryboardManagement.h"
#import "GSEthnicityViewController.h"
#import "BaseViewController+ActivityFeedbackManagement.h"

@implementation UITextField (Insets)

// placeholder position
- (CGRect)textRectForBounds:(CGRect)bounds {
    return CGRectInset(bounds, 10, 0);
}

// text position
- (CGRect)editingRectForBounds:(CGRect)bounds {
    return CGRectInset(bounds, 10, 0);
}

@end

@implementation GSEditInfoViewController{
    NSDate* birthDate;
    UITextField* textFieldEditing;
    NSMutableArray * arElementsPickerView;
    NSInteger iIdxElementSelectedInPickerView;
    NSInteger iIdxOldElementSelectedInPickerView;
    NSString * sOldElementsSelectedInMultiSelectView;
    
    User * theUser;
    GSEthnicityViewController* ethnyController;
    
    CGFloat keyboardHeight;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.translatesAutoresizingMaskIntoConstraints = NO;
    // Do any additional setup after loading the view.
    for (UIView* v in self.framedViews) {
        v.layer.masksToBounds = YES;
        v.layer.borderWidth = 2;
        v.layer.borderColor = [[UIColor grayColor] CGColor];
    }
    keyboardHeight = 0;
}

- (void)dealloc{
    [self cancelEditUser];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self loadData];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidChangeFrameWithNotification:) name:UIKeyboardWillChangeFrameNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShowNotification:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHideNotification:) name:UIKeyboardWillHideNotification object:nil];
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

- (void)updateCountLabel{
    NSInteger bioLength = [self.bioView.text length];
    self.charCountLabel.text = [NSString stringWithFormat:@"%ld / 140",(long)bioLength];
}

- (NSString*)processDate:(NSDate*)theDate
{
    if(!theDate){
        return @"-- / -- / --";
    }
    birthDate = theDate;
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"dd / MM / yy"];
    [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en"]];
    return [NSDateFormatter localizedStringFromDate:theDate dateStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterNoStyle];
    //return [dateFormatter stringFromDate:theDate];
}

- (void)loadData{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext * currentContext = [RKObjectManager sharedManager].managedObjectStore.mainQueueManagedObjectContext;
    theUser = [[User alloc] initWithEntity:[NSEntityDescription entityForName:@"User" inManagedObjectContext: currentContext] insertIntoManagedObjectContext:currentContext];
    
    [appDelegate.currentUser copyAllFields:theUser];
    self.bioView.text = theUser.tellusmore;
    [self updateCountLabel];
    self.birthDateField.text = [self processDate:theUser.birthdate];
    self.birthdayVisible.on = [theUser.birthdateVisible boolValue];
    if(theUser.gender){
        self.genderField.text = ([theUser.gender integerValue]?NSLocalizedString(@"_MALE_", nil):NSLocalizedString(@"_FEMALE_", nil));
        self.genderField.tag = [theUser.gender integerValue];
    }
    self.genderVisible.on = [theUser.genderVisible boolValue];
    self.hometownField.text = theUser.addressCity;
    self.hometownVisible.on = [theUser.addressCityVisible boolValue];
    if(theUser.relationship){
        NSArray * objs = [appDelegate.config valueForKey:@"relationship_types"];
        if([objs count]> [theUser.relationship integerValue]){
            self.relationshipField.text = [objs objectAtIndex:[theUser.relationship integerValue]];
        }
        self.relationshipField.tag = [theUser.relationship integerValue];
    }
    self.relationshipVisible.on = [theUser.relationshipVisible boolValue];
    self.interestsField.text = [User sGetTextGenreFromString:theUser.genre];
    self.interestsVisible.on = [theUser.genreVisible boolValue];
    self.politicalViewField.text = theUser.politicalView;
    self.politicalViewVisible.on = [theUser.politicalViewVisible boolValue];
    self.politicalPartyField.text = theUser.politicalParty;
    self.politicalPartyVisible.on = [theUser.politicalPartyVisible boolValue];
    self.religionField.text = theUser.religion;
    self.religionVisible.on = [theUser.religionVisible boolValue];

    self.ethnicityVisible.on = [theUser.ethnicityVisible boolValue];
    [self getCurrentUserEthnicities];
}

- (void)getCurrentUserEthnicities{
    NSString* userEthnicityUrl = [NSString stringWithFormat:@"%@/user_ethnicity?user=%@", RESTBASEURL, theUser.idUser];
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

- (void)processSelectedEtnicities:(NSArray*)ethnicities{
    User* current = [(AppDelegate*)[UIApplication sharedApplication].delegate currentUser];
    NSMutableString* ethnicitiesString = [NSMutableString new];
    for (NSDictionary* d in ethnicities) {
        NSString* groupName = [current.ethnyGroupRefDictionary objectForKey:[d objectForKey:kEthnicityKey]];
        NSString* ethnyName = [d objectForKey:kOtherKey];
        if(!ethnyName){
            NSArray* ethniesList = [current.groupEthniesDict objectForKey:groupName];
            for(int i=0;i<[ethniesList count]&&!ethnyName;i++){
                NSDictionary* ethny = [ethniesList objectAtIndex:i];
                if ([[d objectForKey:kIdKey] isEqualToString:[ethny objectForKey:kIdKey]]) {
                    ethnyName = [ethny objectForKey:kNameKey];
                }
            }
        }
        if(ethnyName&&groupName){
            if ([ethnicitiesString length]>0) {
                [ethnicitiesString appendString:@", "];
            }
            [ethnicitiesString appendFormat:@"%@ (%@)",ethnyName,groupName];
        }
    }
    self.ethnicityField.text = ethnicitiesString;
}

- (void)setData{
    theUser.tellusmore = self.bioView.text;
    [theUser setBirthdate:birthDate];
    [theUser setBirthdateVisible:[NSNumber numberWithBool:self.birthdayVisible.on]];
    theUser.gender = [NSNumber numberWithInteger:self.genderField.tag];
    theUser.genderVisible = [NSNumber numberWithBool:self.genderVisible.on];
    theUser.addressCity = self.hometownField.text;
    theUser.addressCityVisible = [NSNumber numberWithBool:self.hometownVisible.on];
    theUser.relationship = [NSNumber numberWithInteger:self.relationshipField.tag];
    theUser.relationshipVisible = [NSNumber numberWithBool:self.relationshipVisible.on];
    theUser.genreVisible = [NSNumber numberWithBool:self.interestsVisible.on];
    theUser.politicalView = self.politicalViewField.text;
    theUser.politicalViewVisible = [NSNumber numberWithBool:self.politicalViewVisible.on];
    theUser.politicalParty = self.politicalPartyField.text;
        theUser.politicalPartyVisible = [NSNumber numberWithBool:self.politicalPartyVisible.on];
    theUser.religion = self.religionField.text;
    theUser.religionVisible = [NSNumber numberWithBool:self.religionVisible.on];
    theUser.ethnicityVisible = [NSNumber numberWithBool:self.ethnicityVisible.on];
    
    AppDelegate* appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    [self getDataUserForUser:appDelegate.currentUser originalUser:theUser];
    [appDelegate.currentUser setDelegate:self];
    
    [self stopActivityFeedback];
    [self startActivityFeedbackWithMessage:NSLocalizedString(@"_UPDATING_USER_ACTV_MSG_", nil)];
    [appDelegate.currentUser updateUserToServerDBVerbose:YES];
}

-(void) getDataUserForUser:(User*) user originalUser:(User*)originalUser{
    user.tellusmore = originalUser.tellusmore;
    [user setBirthdate:originalUser.birthdate];
    [user setBirthdateVisible:originalUser.birthdateVisible];
    user.gender = originalUser.gender;
    user.genderVisible = originalUser.genderVisible;
    user.addressCityVisible = originalUser.addressCityVisible;
    user.relationship = originalUser.relationship;
    user.relationshipVisible = originalUser.relationshipVisible;
    user.genre = originalUser.genre;
    user.genreVisible = originalUser.genreVisible;
    user.politicalView = originalUser.politicalView;
    user.politicalViewVisible = originalUser.politicalViewVisible;
    user.politicalParty = originalUser.politicalParty;
    user.politicalPartyVisible = originalUser.politicalPartyVisible;
    user.religion = originalUser.religion;
    user.religionVisible = originalUser.religionVisible;
    user.ethnicityVisible = originalUser.ethnicityVisible;
}

- (void)cancelEditUser{
    NSManagedObjectContext * currentContext = [RKObjectManager sharedManager].managedObjectStore.mainQueueManagedObjectContext;
    [currentContext deleteObject:theUser];
}

- (void)userAccount:(User *)user didSignUpSuccessfully:(BOOL)bSignUpSuccess{
    [self.currentPresenterViewController dismissControllerModal];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if([segue.identifier isEqualToString:@"ethnicityLoad"]){
        ethnyController = (GSEthnicityViewController*)segue.destinationViewController;
        ethnyController.relatedDelegate = self;
    }
}

- (void)closeRelatedViewController:(UIViewController *)theViewController{
    [self showEthnies:NO];
}

- (IBAction)genderPushed:(id)sender {
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSArray * objs = [appDelegate.config valueForKey:@"gender_types"];
    
    [self initPickerViewWithElements:objs forTextField:self.genderField withElementSelected:theUser.gender.intValue];
}

- (IBAction)relationshipPushed:(id)sender {
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSArray * objs = [appDelegate.config valueForKey:@"relationship_types"];
    [self initPickerViewWithElements:objs forTextField:self.relationshipField withElementSelected:theUser.relationship.intValue];
}

- (IBAction)interestsPushed:(id)sender {
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSArray * objs = [appDelegate.config valueForKey:@"gender_types"];
    NSMutableArray* finalObjs = [NSMutableArray new];
    for(NSString* s in objs){
        if (![s isEqualToString:@""]) {
            [finalObjs addObject:s];
        }
    }
    NSString* userGenre = theUser.genre;
    if([userGenre isEqualToString:@""]){
        userGenre = nil;
    }
    [self initTableMultiselectViewWithElements:finalObjs forTextField:self.interestsField withElementsSelected:userGenre];
}

- (IBAction)ethinicityPushed:(id)sender {
    [self showEthnies:YES];
}

- (void)showEthnies:(BOOL)showOrNot{
    if (showOrNot) {
        [ethnyController fixLayout];
        self.ethnicityCenterConstraint.constant = 0;
    }else{
        self.ethnicityCenterConstraint.constant = self.ethnicityContainer.frame.size.height;
    }
    [UIView animateWithDuration:0.3
                     animations:^{
                         [self.view layoutIfNeeded];
                     }
                     completion:^(BOOL finished) {
                         
                     }];
}

- (IBAction)savePushed:(id)sender {
    [self setData];
    //[self.currentPresenterViewController dismissControllerModal];
}

- (IBAction)birthDatePushed:(id)sender {
    CGRect frame = [UIScreen mainScreen].bounds;
    DatePickerViewButtons *datePicker = [[DatePickerViewButtons alloc] initWithFrame:frame ];
    
    [datePicker updateFrame:frame];
    [datePicker setDate:birthDate];
    datePicker.delegate = self;
    
    self.birthDateField.inputView = datePicker;
}

// Update Birthdate text field
-(void)updateBirthdate:(id)sender
{
    DatePickerViewButtons *datePicker = (DatePickerViewButtons*) self.birthDateField.inputView;
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    
    
    self.birthDateField.text = [dateFormatter stringFromDate:datePicker.pickerView.date];
    
    birthDate = datePicker.pickerView.date;
}

-(void) datePickerButtonView:(DatePickerViewButtons *)datePickerView changeDate:(NSDate *)date
{
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    
    self.birthDateField.text = [dateFormatter stringFromDate:date];
    
    birthDate = datePickerView.pickerView.date;
}

-(void) datePickerButtonView:(DatePickerViewButtons *)datePickerView didButtonClick:(BOOL)bOk withDate:(NSDate *)date
{
    if (bOk == YES)
    {
        birthDate = datePickerView.pickerView.date;
    }
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    
    self.birthDateField.text = [dateFormatter stringFromDate:birthDate];
    
    [self.view endEditing:YES];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if (range.location>140) {
        return NO;
    }
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView{
    [self updateCountLabel];
}
#pragma mark - PickerFunctions

-(void) initPickerViewWithElements:(NSArray *) arElements forTextField:(UITextField *)uitextfield withElementSelected:(NSInteger) iIdxSelected
{
    textFieldEditing = uitextfield;
    if (arElementsPickerView == nil)
    {
        arElementsPickerView = [[NSMutableArray alloc] init];
    }
    [arElementsPickerView removeAllObjects];
    iIdxElementSelectedInPickerView = -1;
    
    iIdxOldElementSelectedInPickerView = iIdxSelected;
    
    for (int i = 0; i < arElements.count; i++)
    {
        [arElementsPickerView addObject:NSLocalizedString([arElements objectAtIndex:i],nil)];
    }
    
    
    CGRect frame = [UIScreen mainScreen].bounds;
    
    PickerViewButtons *myPickerView = [[PickerViewButtons alloc] initWithFrame:frame];
    myPickerView.delegate = self;
    [myPickerView setElements:arElementsPickerView];
    if (iIdxSelected != -1)
    {
        [myPickerView.pickerView selectRow:iIdxOldElementSelectedInPickerView inComponent:0 animated:YES];
    }
    
    textFieldEditing.inputView = myPickerView;
}

-(void) pickerButtonView:(PickerViewButtons *)pickerView changeSelected:(NSInteger) iRow
{
    textFieldEditing.text = [arElementsPickerView objectAtIndex:iRow];
    textFieldEditing.tag = iRow;
}

- (void) pickerButtonView:(PickerViewButtons *)pickerView didButtonClick:(BOOL)bOk withindex:(NSInteger) iRow
{
    if (bOk)
    {

    }
    else
    {
        if (iIdxOldElementSelectedInPickerView != -1)
        {
            textFieldEditing.text = [arElementsPickerView objectAtIndex:iIdxOldElementSelectedInPickerView];
            textFieldEditing.tag = iIdxOldElementSelectedInPickerView;
        }
    }
    // hide the picker view
    [textFieldEditing resignFirstResponder];
}

#pragma mark - MultiviewSelector management
-(void) multiSelectButtonView:(MultiSelectViewButtons *)pickerView didButtonClick:(BOOL)bOk withSelected:(NSArray *)arSelected
{
    if (bOk)
    {
        
            NSString * genre = @"";
            int i= 0;
            for (NSIndexPath * index in arSelected)
            {
                if (i== 0)
                {
                    genre = [NSString stringWithFormat:@"%ld", (long)index.row];
                }
                else
                {
                    genre = [NSString stringWithFormat:@"%@, %ld", genre, (long)index.row];
                }
                i++;
            }
            theUser.genre = genre;
        
    }
    else
    {
        textFieldEditing.text = [theUser sGetTextGenre];
    }
    // hide the picker view
    [textFieldEditing resignFirstResponder];
}

-(void) multiSelectButtonView:(MultiSelectViewButtons *)pickerView changeSelection:(NSArray *)arSelected
{
    NSString * genre = @"";
    int i= 0;
    for (NSIndexPath * index in arSelected)
    {
        if (i== 0)
        {
            genre = [NSString stringWithFormat:@"%ld", (long)index.row];
        }
        else
        {
            genre = [NSString stringWithFormat:@"%@, %ld", genre, (long)index.row];
        }
        i++;
    }
    textFieldEditing.text = [User sGetTextGenreFromString:genre];
}

-(void) initTableMultiselectViewWithElements:(NSArray *) arElements forTextField:(UITextField *)uitextfield withElementsSelected:(NSString *)sElementsSelected
{
    // split the string by coma
    NSArray * arElementsSelected = [sElementsSelected componentsSeparatedByString:@","];
    NSMutableArray * arSelected = [[NSMutableArray alloc] init];
    for(NSString * sElement in arElementsSelected)
    {
        [arSelected addObject:[NSIndexPath indexPathForRow:sElement.intValue inSection:0]];
    }
    
    textFieldEditing = uitextfield;
    if (arElementsPickerView == nil)
    {
        arElementsPickerView = [[NSMutableArray alloc] init];
    }
    [arElementsPickerView removeAllObjects];
    
    for (int i = 0; i < arElements.count; i++)
    {
        [arElementsPickerView addObject:NSLocalizedString([arElements objectAtIndex:i],nil)];
    }
    sOldElementsSelectedInMultiSelectView = sElementsSelected;
    
    
    CGRect frame = [UIScreen mainScreen].bounds;
    
    MultiSelectViewButtons *myMultiselectView = [[MultiSelectViewButtons alloc] initWithFrame:frame];
    myMultiselectView.delegate = self;
    [myMultiselectView setElements:arElementsPickerView];
    [myMultiselectView setElementsSelected:arSelected];
    
    textFieldEditing.inputView = myMultiselectView;
}

@end
