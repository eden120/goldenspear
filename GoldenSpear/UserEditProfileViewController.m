//
//  UserEditProfileViewController.m
//  GoldenSpear
//
//  Created by Jose Antonio Sanchez Martinez on 28/09/15.
//  Copyright (c) 2015 GoldenSpear. All rights reserved.
//

#import "UserEditProfileViewController.h"
#import "BaseViewController+BottomControlsManagement.h"
#import "BaseViewController+MainMenuManagement.h"
#import "BaseViewController+StoryboardManagement.h"
#import "BaseViewController+UserManagement.h"
#import "BaseViewController+TopBarManagement.h"
#import "BaseViewController+ActivityFeedbackManagement.h"
#import "BaseViewController+RestServicesManagement.h"
#import "NSString+ValidateEMail.h"
#import "NSString+ValidatePhone.h"
#import "NSString+CheckWhiteSpaces.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "User+Manage.h"
#import "Country+Manage.h"
#import "City+Manage.h"

#import "PickerViewButtons.h"
#import "MultiSelectViewButtons.h"

#define kMinPasswordLength 8
#define kMinUsernameLength 3

@implementation UserEditProfileViewController
{
    UITextField * textFieldEditing;
    NSMutableArray * arElementsPickerView;
    NSString * sOldElementsSelectedInMultiSelectView;
    NSInteger iIdxElementSelectedInPickerView;
    NSInteger iIdxOldElementSelectedInPickerView;
    
    NSMutableArray * arCountries;
    NSMutableArray * arCountriesCallingCodes;
    Country * selectedCountry;
    NSMutableArray * arRegions;
    StateRegion * selectedRegion;
    NSMutableArray * arCities;
    NSMutableArray * arAllCities;
    City * selectedCity;
    
    // geo location
    
    // Object to get location data
    CLLocationManager *commentLocationManager;
    // Class providing services for converting between a GPS coordinate and a user-readable address
    CLGeocoder *commentGeocoder;
    // Object containing the result returned by CLGeocoder
    CLPlacemark *commentPlacemark;
    
    NSDate * birthDate;
    NSDate * oldBirthDate;
    AppDelegate *appDelegate;
    BOOL editingUser;
    
    PickerFilteredViewButtons *pickerFilteredPickerView;
    
    BOOL bLoadingCountries;
    BOOL bLoadingStateRegions;
    
    int iCurrentSkip;
    int iCurrentLimit;
    
    
    BOOL bMoreCities;
    
    NSString * sFilterCities;
    
    Country * countrySerching;
    StateRegion * stateSearching;
    
    PickerFilteredViewButtons * citiesFilter;
    
    User * editedUser;
    BOOL profileSaved;
    
    CGFloat oldConstant;
    CGFloat keyboardHeight;
}

/*
 - (void)viewDidAppear:(BOOL)animated{
 [super viewDidAppear:animated];
 if(appDelegate.currentUser.typeprofessionId==nil||[appDelegate.currentUser.typeprofessionId isEqualToString:@""]){
 [self performSegueWithIdentifier:@"whoAreYouSegue" sender: self];
 }
 }
 */

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _bLoadingCities = NO;
    bLoadingCountries = NO;
    bLoadingStateRegions = NO;
    arCountries = nil;
    arRegions = nil;
    selectedRegion = nil;
    arCities = nil;
    selectedCity = nil;
    selectedCountry = nil;
    
    commentLocationManager = nil;
    commentGeocoder = nil;
    
    citiesFilter = nil;
    
    // border color gray of textfields
    UIColor * color = [UIColor colorWithRed:(184.0/255.0) green:(184.0/255.0) blue:(184.0/255.0) alpha:1.0];
    [self setupBorderTextFieldsFor:self.basicSubview withColor:color];
    //    [self setupBorderTextFieldsFor:self.locationSubview withColor:color];
    
    [self setupMandatoryTextFieldsFor:self.basicSubview ];
    //    [self setupMandatoryTextFieldsFor:self.locationSubview ];
    
    [self setupHideKeyboard:self.basicSubview ];
    //    [self setupHideKeyboard:self.locationSubview ];
    
    // si usuario esta logueado mostramos la informacion
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    [self loadCountriesFromServer];
    
    if(![self shouldCreateBottomButtons]){
        self.bottomSlideConstraint.constant = 0;
        [self.view layoutIfNeeded];
    }
    oldConstant = self.bottomSlideConstraint.constant;
    keyboardHeight = 0;
}

- (BOOL)shouldCreateMenuButton{
    return self.fromViewController;
}

- (BOOL)shouldCreateBottomButtons{
    return self.fromViewController;
}

- (BOOL)shouldCreateHintButton{
    return NO;
}

- (BOOL)shouldCenterTitle{
    return YES;
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    editingUser = NO;
    if (appDelegate.currentUser != nil&&!editedUser)
    {
        editingUser = YES;
        
        NSManagedObjectContext * currentContext = [RKObjectManager sharedManager].managedObjectStore.mainQueueManagedObjectContext;
        editedUser = [[User alloc] initWithEntity:[NSEntityDescription entityForName:@"User" inManagedObjectContext: currentContext] insertIntoManagedObjectContext:currentContext];
        
        [appDelegate.currentUser copyAllFields:editedUser];
        
        [self loadDataForUser:editedUser];
        [self setupButtonsWithNext:(![[editedUser sGetTextProfession] isEqualToString:@"Fashion Lover"])];
    }
    
    BOOL bVisibleBottomButtons = YES;
    if (pickerFilteredPickerView != nil)
    {
        if (pickerFilteredPickerView.hidden == NO)
        {
            bVisibleBottomButtons = NO;
        }
    }
    
    self.leftButton.hidden = !bVisibleBottomButtons;
    self.middleLeftButton.hidden = !bVisibleBottomButtons;
    self.homeButton.hidden = !bVisibleBottomButtons;
    self.middleRightButton.hidden = !bVisibleBottomButtons;
    self.rightButton.hidden = !bVisibleBottomButtons;
    
    if(self.fromViewController){
        self.cancelButton.hidden = NO;
    }else{
        self.cancelButton.hidden = YES;
    }
}

-(void) setupBorderTextFieldsFor:(UIView *)view withColor:(UIColor * ) color
{
    for (UIView * viewChild in view.subviews)
    {
        if ([viewChild isKindOfClass:[UITextField class]])
        {
            [self borderTextEdit:(UITextField *)viewChild withColor:color withBorder:1.0f];
        }
    }
}

-(void) setupMandatoryTextFieldsFor:(UIView *)view
{
    UIFont * fontOptional = [UIFont fontWithName:@"Avenir-Medium" size:16];
    UIFont * fontMandatory = [UIFont fontWithName:@"Avenir-Black" size:16];
    
    for (UIView * viewChild in view.subviews)
    {
        if ([viewChild isKindOfClass:[UILabel class]])
        {
            UILabel * lbl = ((UILabel *)viewChild);
            if (lbl.tag == 1)
            {
                if ([lbl.text containsString:@"*"] == NO)
                {
                    lbl.text = [lbl.text stringByAppendingString:@" *"];
                }
                [lbl setFont:fontMandatory];
            }
            else if (lbl.tag == 0)
            {
                [lbl setFont:fontOptional];
            }
            
        }
    }
}

-(void) disabledFields:(UIView *) view
{
    for (UIView * viewChild in view.subviews)
    {
        if ([viewChild isKindOfClass:[UITextField class]])
        {
            UITextField * lbl = ((UITextField *)viewChild);
            lbl.enabled = NO;
        }
    }
}

-(void) setupHideKeyboard:(UIView *)view
{
    for (UIView * viewChild in view.subviews)
    {
        if ([viewChild isKindOfClass:[UITextField class]])
        {
            UITextField * textfield = ((UITextField *)viewChild);
            
            [textfield removeTarget:self action:@selector(hideKeyboard:) forControlEvents:UIControlEventEditingDidEndOnExit];
            [textfield addTarget:self action:@selector(hideKeyboard:) forControlEvents:UIControlEventEditingDidEndOnExit];
            
        }
    }
}
-(void) hideKeyboardInView:(UIView *)view
{
    for (UIView * viewChild in view.subviews)
    {
        [viewChild resignFirstResponder];
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *) event
{
    [super touchesBegan:touches withEvent:event];
    
    [self.view endEditing:YES];
}

#pragma mark - Load User data
-(void) loadDataForUser:(User * ) user
{
    self.emailTextEdit.hidden = (user.bFacebookUser == YES);
    
    if (user.bFacebookUser == YES)
    {
        //        self.basicScreenHeight.constant -= (self.constraintTopGeneralAccount.constant - 10);
        //        self.constraintTopGeneralAccount.constant = 10;
    }
    
    self.firstNameTextEdit.text = user.name;
    self.lastNameTextEdit.text = user.lastname;
    self.emailTextEdit.text = user.email;
    self.phoneNumberTextEdit.text = user.phone;
    self.publicButton.on = ![user.isPublic boolValue];
    birthDate = user.birthdate;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    self.birthdateTextEdit.text = [dateFormatter stringFromDate:user.birthdate];
    
    NSString * fullName;
    if (user.lastname != nil)
    {
        fullName =  [NSString stringWithFormat:@"%@ %@", user.name, user.lastname];
    }
    else
    {
        fullName =  [NSString stringWithFormat:@"%@", user.name];
    }
    
    [self loadLocationOfUser:user];
    
    [self loadProfessionForUser:user];
}

-(void) loadLocationOfUser:(User *)user
{
    self.address1TextEdit.text = user.address1;
    self.address2TextEdit.text = user.address2;
    self.countryTextEdit.text = user.country;
    self.stateTextEdit.text = user.addressState;
    self.postalTextEdit.text = user.addressPostalCode;
    self.cityTextEdit.text = user.addressCity;
    
    self.locationTextEdit.text = [user sGetTextLocation];
}

-(void) setLocationToUser:(User *) user
{
    user.address1 = self.address1TextEdit.text;
    user.address2 = self.address2TextEdit.text;
    user.addressPostalCode = self.postalTextEdit.text;
    
    if (selectedCountry != nil)
    {
        user.country_id = selectedCountry.idCountry;
        user.country = selectedCountry.name;
    }
    else
    {
        user.country_id = @"";
        user.country = @"";
    }
    if (selectedCity != nil)
    {
        user.addressCity_id = selectedCity.idCity;
        user.addressCity = selectedCity.name;
    }
    else
    {
        user.addressCity_id = @"";
        user.addressCity = @"";
    }
    if (selectedRegion != nil)
    {
        user.addressState_id = selectedRegion.idStateRegion;
        user.addressState = selectedRegion.name ;
    }
    else
    {
        user.addressState_id = @"";
        user.addressState = @"" ;
    }
}

-(void) loadProfessionForUser:(User *) user
{
    self.professionTextEdit.text = [user sGetTextProfession];
    
    birthDate = user.birthdate;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    self.birthdateTextEdit.text = [dateFormatter stringFromDate:user.birthdate];
}

#pragma mark - Birthdate
// Set birthdate using a UIDatePicker
- (IBAction)editBirthdate:(UITextField *)sender
{
    CGRect frame = self.view.frame;
    DatePickerViewButtons *datePicker = [[DatePickerViewButtons alloc] initWithFrame:frame ];
    [datePicker updateFrame:self.view.frame];
    [datePicker setDate:birthDate];
    oldBirthDate = birthDate;
    datePicker.delegate = self;
    
    self.birthdateTextEdit.inputView = datePicker;
}

// Update Birthdate text field
-(void)updateBirthdate:(id)sender
{
    DatePickerViewButtons *datePicker = (DatePickerViewButtons*) self.birthdateTextEdit.inputView;
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    
    
    self.birthdateTextEdit.text = [dateFormatter stringFromDate:datePicker.pickerView.date];
    
    birthDate = datePicker.pickerView.date;
}

-(void) datePickerButtonView:(DatePickerViewButtons *)datePickerView changeDate:(NSDate *)date
{
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    
    self.birthdateTextEdit.text = [dateFormatter stringFromDate:date];
    
    birthDate = datePickerView.pickerView.date;
}

-(void) datePickerButtonView:(DatePickerViewButtons *)datePickerView didButtonClick:(BOOL)bOk withDate:(NSDate *)date
{
    if (bOk == YES)
    {
        birthDate = datePickerView.pickerView.date;
    }
    else
    {
        birthDate = oldBirthDate;
    }
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    
    self.birthdateTextEdit.text = [dateFormatter stringFromDate:birthDate];
    
    
    [self.view endEditing:YES];
}

#pragma mark - Location
- (IBAction)btnLocation:(UIButton *)sender {
    // poniendo estas variables a nil forzamos a cargar los datos del usuario
    selectedCountry = nil;
    selectedCity = nil;
    selectedRegion = nil;
    
    [self showLocation];
}

- (IBAction)locateMeClick:(UIButton *)sender {
    [self.view endEditing:YES];
    
    // Initialize objects to get location data
    if (commentLocationManager == nil)
    {
        commentLocationManager = [[CLLocationManager alloc] init];
    }
    if (commentGeocoder == nil)
        commentGeocoder = [[CLGeocoder alloc] init];
    
    [self getCurrentLocation];
}

- (IBAction)setPublic:(UISwitch *)sender {
    if (_publicButton.on) {
        NSLog(@"Private");
    }
    else {
        NSLog(@"Public");
    }
}

-(void) showLocation
{
    [self.view endEditing:YES];
    self.topConstraintLocation.constant = 0;
    self.locationScrollView.hidden = NO;
    [self getCountryOfUser:editedUser];
    
    [UIView animateWithDuration:0.5
                          delay:0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^ {
                         [self.view layoutIfNeeded];
                     }
                     completion:^(BOOL finished) {
                     }];
}

-(void) getCountryOfUser:(User *) user
{
    BOOL bFound = NO;
    for(Country * country in arCountries)
    {
        if ([country.idCountry isEqualToString:user.country_id])
        {
            if (country != selectedCountry)
            {
                selectedRegion = nil;
                [arRegions removeAllObjects];
                selectedCity = nil;
                [arCities removeAllObjects];
                selectedCountry = country;
                // el estado/comunidad autonoma del usuario se asigna al recibir los estados del pais seleccionado
                [self loadStatesFromServer:selectedCountry];
            }
            
            bFound = YES;
            break;
        }
    }
    /*
     if (bFound)
     {
     int iTimeout = 0;
     while((bLoadingStateRegions == YES) && (iTimeout < 30))
     {
     [NSThread sleepForTimeInterval:.1f];
     iTimeout++;
     }
     bFound = NO;
     for(StateRegion * state in arRegions)
     {
     if ([state.idStateRegion isEqualToString:user.addressState_id])
     {
     if (state != selectedRegion)
     {
     selectedCity = nil;
     [arCities removeAllObjects];
     
     selectedRegion = state;
     }
     bFound = YES;
     break;
     }
     }
     }
     */
}

-(void) hideLocation
{
    
    [self.view endEditing:YES];
    // save the data in the CUser class
    self.topConstraintLocation.constant = self.basicView.frame.size.height;
    [UIView animateWithDuration:0.5
                          delay:0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^ {
                         [self.view layoutIfNeeded];
                     }
                     completion:^(BOOL finished) {
                         self.locationScrollView.hidden = YES;
                     }];
}

-(void) loadCountriesFromServer
{
    NSLog(@"Loading all countries info");
    bLoadingCountries = YES;
    
    // get all product categories
    [self performRestGet:GET_ALLCOUNTRIES withParamaters:nil];
    
}
-(void) getCountriesFromServer:(NSArray *)mappingResult
{
    
    if (arCountries != nil)
    {
        [arCountries removeAllObjects];
    }
    if (arCountriesCallingCodes != nil)
    {
        [arCountriesCallingCodes removeAllObjects];
    }
    else
    {
        arCountriesCallingCodes = [[NSMutableArray alloc] init];
    }
    
    NSMutableArray * arTemp = [[NSMutableArray alloc] init];
    for (Country *country in mappingResult)
    {
        if([country isKindOfClass:[Country class]])
        {
            Country * c = (Country *)country;
            [arTemp addObject:c];
            if ([c.idCountry isEqualToString:editedUser.country_id])
            {
                selectedCountry = c;
                [self loadStatesFromServer:c];
            }
        }
    }
    
    NSSortDescriptor *sortDescriptor;
    sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name"
                                                 ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    
    
    arCountries = [[NSMutableArray alloc] initWithArray:[arTemp sortedArrayUsingDescriptors:sortDescriptors]];
    
    for(Country * c in arCountries)
    {
        NSArray * arCallingCodes = [c getCallingCodes];
        for(NSString * sCallingCode in arCallingCodes)
        {
            [arCountriesCallingCodes addObject:sCallingCode];
        }
    }
    
    bLoadingCountries = NO;
    
}

-(void) loadStatesFromServer:(Country *) country
{
    NSLog(@"Loading states info");
    bLoadingStateRegions = YES;
    NSArray * requestParameters = [[NSArray alloc] initWithObjects:country.idCountry, nil];
    
    // get all product categories
    [self performRestGet:GET_STATESOFCOUNTRY withParamaters:requestParameters];
    
}

-(void) getStatesFromServer:(NSArray *)mappingResult
{
    if (arRegions != nil)
    {
        [arRegions removeAllObjects];
    }
    else
    {
        arRegions = [[NSMutableArray alloc] init];
    }
    
    NSMutableArray * arTemp = [[NSMutableArray alloc] init];
    for (StateRegion *state in mappingResult)
    {
        if([state isKindOfClass:[StateRegion class]])
        {
            StateRegion * region = (StateRegion *)state;
            if (region.parentstateregion == nil)
            {
                [arTemp addObject:region];
                if ([region.idStateRegion isEqualToString:editedUser.addressState_id])
                {
                    selectedRegion = region;
                }
            }
        }
    }
    
    NSSortDescriptor *sortDescriptor;
    sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name"
                                                 ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    
    
    arRegions = [[NSMutableArray alloc] initWithArray:[arTemp sortedArrayUsingDescriptors:sortDescriptors]];
    
    bLoadingStateRegions =NO;
}

-(void) loadCitiesFromServer:(Country *) country andState:(StateRegion *)state skip:(int)iSkip limit:(int)iLimit
{
    NSLog(@"Loading cities info");
    _bLoadingCities = YES;
    NSArray * requestParameters;
    iCurrentSkip = iSkip;
    iCurrentLimit = iLimit;
    sFilterCities = @"";
    bMoreCities = YES;
    
    if (arAllCities != nil)
    {
        [arAllCities removeAllObjects];
    }
    else
    {
        arAllCities = [NSMutableArray new];
    }
    
    if (state != nil)
    {
        requestParameters = [[NSArray alloc] initWithObjects:country.idCountry,state.idStateRegion, [NSNumber numberWithInteger:iCurrentSkip], [NSNumber numberWithInteger:iCurrentLimit], sFilterCities, nil];
    }
    else if (state == nil)
    {
        requestParameters = [[NSArray alloc] initWithObjects:country.idCountry, [NSNumber numberWithInteger:iCurrentSkip], [NSNumber numberWithInteger:iCurrentLimit], sFilterCities, nil];
    }
    
    countrySerching = country;
    stateSearching = state;
    
    // get all product categories
    [self performRestGet:GET_CITIESOFSTATE withParamaters:requestParameters];
    
}

-(void) loadCitiesFromServerFiltering:(NSString *) filter
{
    NSLog(@"Loading cities info");
    bMoreCities = YES;
    _bLoadingCities = YES;
    NSArray * requestParameters;
    iCurrentSkip = 0;
    sFilterCities = filter;
    if (arAllCities != nil)
    {
        [arAllCities removeAllObjects];
    }
    else
    {
        arAllCities = [NSMutableArray new];
    }
    
    
    if (stateSearching != nil)
    {
        requestParameters = [[NSArray alloc] initWithObjects:countrySerching.idCountry,stateSearching.idStateRegion, [NSNumber numberWithInteger:iCurrentSkip], [NSNumber numberWithInteger:iCurrentLimit], sFilterCities, nil];
    }
    else if (stateSearching == nil)
    {
        requestParameters = [[NSArray alloc] initWithObjects:countrySerching.idCountry, [NSNumber numberWithInteger:iCurrentSkip], [NSNumber numberWithInteger:iCurrentLimit], sFilterCities, nil];
    }
    
    [self stopActivityFeedback];
    [self startActivityFeedbackWithMessage:NSLocalizedString(@"_LOADING_CITIES_", nil)];
    
    // get all product categories
    [self performRestGet:GET_CITIESOFSTATE withParamaters:requestParameters];
}

-(void) loadNextCitiesFromServer
{
    if (bMoreCities)
    {
        NSLog(@"Loading cities info");
        _bLoadingCities = YES;
        NSArray * requestParameters;
        iCurrentSkip += iCurrentLimit;
        if (stateSearching != nil)
        {
            requestParameters = [[NSArray alloc] initWithObjects:countrySerching.idCountry,stateSearching.idStateRegion, [NSNumber numberWithInteger:iCurrentSkip], [NSNumber numberWithInteger:iCurrentLimit], sFilterCities, nil];
        }
        else if (stateSearching == nil)
        {
            requestParameters = [[NSArray alloc] initWithObjects:countrySerching.idCountry, [NSNumber numberWithInteger:iCurrentSkip], [NSNumber numberWithInteger:iCurrentLimit], sFilterCities, nil];
        }
        
        [self stopActivityFeedback];
        [self startActivityFeedbackWithMessage:NSLocalizedString(@"_LOADING_CITIES_", nil)];
        
        // get all product categories
        [self performRestGet:GET_CITIESOFSTATE withParamaters:requestParameters];
    }
}

-(void) getCitiesFromServer:(NSArray *)mappingResult
{
    if (arCities != nil)
    {
        [arCities removeAllObjects];
    }
    else
    {
        arCities = [[NSMutableArray alloc] init];
    }
    
    NSMutableArray * arTemp = [[NSMutableArray alloc] init];
    for (City *city in mappingResult)
    {
        if([city isKindOfClass:[City class]])
        {
            City * c = (City *)city;
            [arTemp addObject:c];
            if ([c.idCity isEqualToString:editedUser.addressCity_id])
            {
                selectedCity = c;
            }
        }
    }
    
    NSSortDescriptor *sortDescriptor;
    sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name"
                                                 ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    
    arCities = [[NSMutableArray alloc] initWithArray:[arTemp sortedArrayUsingDescriptors:sortDescriptors]];
    
    unsigned long iNumOldElements = arAllCities.count;
    
    if (arAllCities == nil)
    {
        arAllCities = [[NSMutableArray alloc] init];
    }
    
    [arAllCities addObjectsFromArray:arCities];
    
    
    if (citiesFilter != nil)
    {
        NSMutableArray * objs = [[NSMutableArray alloc] init];
        unsigned long iIdx = 0;
        unsigned long iIdxSelected = -1;
        for(City * c in arCities)
        {
            NSString * sObjet = c.name;
            NSString * sState = @"";
            if (selectedRegion == nil)
                sState = [c getNameFullStates];
            else
                sState = [c getNameOFState];
            
            sObjet = [sObjet stringByAppendingFormat:@"_###_%@", sState];
            
            [objs addObject:sObjet];
            
            if (selectedCity != nil)
            {
                if ([c.idCity isEqualToString:selectedCity.idCity])
                {
                    iIdxSelected = iIdx + iNumOldElements;
                }
            }
            iIdx++;
        }
        if (citiesFilter.bNewQuery)
        {
            [arElementsPickerView removeAllObjects];
        }
        
        [citiesFilter.arElementsSelected removeAllObjects];
        [citiesFilter.arElementsSelected addObject:[NSIndexPath indexPathForRow:iIdxSelected inSection:0]];
        
        [citiesFilter addElements:objs];
        [arElementsPickerView addObjectsFromArray:objs];
    }
    
    if ((arCities.count == 0) || (arCities.count < iCurrentLimit))
    {
        bMoreCities = NO;
    }
    
    _bLoadingCities = NO;
}


- (IBAction)countryButton:(UIButton *)sender
{
    NSMutableArray * objs = [[NSMutableArray alloc] init];
    int iIdx = 0;
    int iIdxSelected = -1;
    for(Country * c in arCountries)
    {
        [objs addObject:c.name];
        if (selectedCountry != nil)
        {
            if ([c.idCountry isEqualToString:selectedCountry.idCountry])
            {
                iIdxSelected = iIdx;
            }
        }
        iIdx++;
    }
    
    [self initPickerFilteredViewWithElements:objs forTextField:self.countryTextEdit withElementSelected:iIdxSelected];
}

- (IBAction)locationCountryEdit:(UITextField *)sender
{
    NSMutableArray * objs = [[NSMutableArray alloc] init];
    int iIdx = 0;
    int iIdxSelected = -1;
    for(Country * c in arCountries)
    {
        [objs addObject:c.name];
        if ([c.idCountry isEqualToString:editedUser.country_id])
        {
            iIdxSelected = iIdx;
        }
        iIdx++;
    }
    [self initPickerViewWithElements:objs forTextField:self.countryTextEdit withElementSelected:iIdxSelected];
}



- (IBAction)locationStateEdit:(UITextField *)sender
{
    NSMutableArray * objs = [[NSMutableArray alloc] init];
    int iIdx = 0;
    int iIdxSelected = -1;
    for(StateRegion * sr in arRegions)
    {
        [objs addObject:sr.name];
        if ([sr.idStateRegion isEqualToString:editedUser.addressState_id])
        {
            iIdxSelected = iIdx;
        }
        iIdx++;
    }
    [self initPickerViewWithElements:objs forTextField:self.stateTextEdit withElementSelected:iIdxSelected];
}

- (IBAction)locationStateRegionButton:(UIButton *)sender {
    if (bLoadingStateRegions)
    {
        [self stopActivityFeedback];
        [self startActivityFeedbackWithMessage:NSLocalizedString(@"_LOADING_STATES_CITIES_", nil)];
        return;
    }
    
    if (selectedCountry != nil)
    {
        NSMutableArray * objs = [[NSMutableArray alloc] init];
        int iIdx = 0;
        int iIdxSelected = -1;
        for(StateRegion * state in arRegions)
        {
            [objs addObject:state.name];
            if (selectedRegion != nil)
            {
                if ([state.idStateRegion isEqualToString:selectedRegion.idStateRegion])
                {
                    iIdxSelected = iIdx;
                }
            }
            iIdx++;
        }
        
        [self initPickerFilteredViewWithElements:objs forTextField:self.stateTextEdit withElementSelected:iIdxSelected];
    }
    else
    {
        // show message please select a country first
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_INFO_", nil) message:NSLocalizedString(@"_SELECT_COUNTRY_", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"_OK_", nil) otherButtonTitles: nil];
        
        [alertView show];
        
    }
}

- (IBAction)locationCityEdit:(UITextField *)sender
{
    NSMutableArray * objs = [[NSMutableArray alloc] init];
    int iIdx = 0;
    int iIdxSelected = -1;
    for(City * c in arCities)
    {
        [objs addObject:c.name];
        if ([c.idCity isEqualToString:editedUser.addressCity_id])
        {
            iIdxSelected = iIdx;
        }
        iIdx++;
    }
    [self initPickerViewWithElements:objs forTextField:self.cityTextEdit withElementSelected:iIdxSelected];
}

- (IBAction)locationCityButton:(UIButton *)sender {
    if (selectedCountry == nil)
    {
        // show message please select a country first
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_INFO_", nil) message:NSLocalizedString(@"_SELECT_COUNTRY_STATE_", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"_OK_", nil) otherButtonTitles: nil];
        
        [alertView show];
        
        return;
    }
    
    NSMutableArray * objs = [NSMutableArray new];
    [self initPickerFilteredViewWithElements:objs forTextField:self.cityTextEdit withElementSelected:-1];
    pickerFilteredPickerView.fixedElements = NO;
    citiesFilter = pickerFilteredPickerView;
    citiesFilter.ctrlBase = self;
    
    [self stopActivityFeedback];
    [self startActivityFeedbackWithMessage:NSLocalizedString(@"_LOADING_CITIES_", nil)];
    [self loadCitiesFromServer:selectedCountry andState:selectedRegion skip:0 limit:50];
    /*
     if (bLoadingCities)
     {
     [self stopActivityFeedback];
     [self startActivityFeedbackWithMessage:NSLocalizedString(@"_LOADING_CITIES_", nil)];
     return;
     }
     
     if ((selectedCountry != nil) && (selectedRegion != nil))
     {
     NSMutableArray * objs = [[NSMutableArray alloc] init];
     int iIdx = 0;
     int iIdxSelected = -1;
     for(City * c in arCities)
     {
     [objs addObject:c.name];
     if (selectedCity != nil)
     {
     if ([c.idCity isEqualToString:selectedCity.idCity])
     {
     iIdxSelected = iIdx;
     }
     }
     iIdx++;
     }
     
     [self initPickerFilteredViewWithElements:objs forTextField:self.cityTextEdit withElementSelected:iIdxSelected];
     }
     else
     {
     // show message please select a country first
     UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_INFO_", nil) message:NSLocalizedString(@"_SELECT_COUNTRY_STATE_", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"_OK_", nil) otherButtonTitles: nil];
     
     [alertView show];
     
     }
     */
}

-(void) updateLocationData
{
    if (textFieldEditing == self.countryTextEdit)
    {
        selectedRegion = nil;
        [arRegions removeAllObjects];
        self.stateTextEdit.text = @"";
        selectedCity = nil;
        [arCities removeAllObjects];
        self.cityTextEdit.text = @"";
        
        [self stopActivityFeedback];
        [self startActivityFeedbackWithMessage:NSLocalizedString(@"_LOADING_STATES_CITIES_", nil)];
        [self loadStatesFromServer:selectedCountry];
    }
    else if (textFieldEditing == self.stateTextEdit)
    {
        [arCities removeAllObjects];
        if (selectedRegion != nil)
        {
            self.stateTextEdit.text = selectedRegion.name;
        }
        else
        {
            self.stateTextEdit.text = @"";
        }
        if (selectedCity == nil)
        {
            self.cityTextEdit.text = @"";
        }
    }
    else if (textFieldEditing == self.cityTextEdit)
    {
        if (selectedCity != nil)
        {
            self.cityTextEdit.text = selectedCity.name;
            self.stateTextEdit.text = selectedRegion.name;
        }
    }
}

-(StateRegion *) getRegionOfCity:(City *)city
{
    NSString * sIdRegion = city.stateregionId;
    
    for(StateRegion *state in arRegions)
    {
        if ([state.idStateRegion isEqualToString:sIdRegion])
        {
            return state;
        }
    }
    
    return nil;
}


#pragma mark - CLLocationManagerDelegate

- (void)getCurrentLocation
{
    [commentLocationManager requestWhenInUseAuthorization];
    
    commentLocationManager.delegate = self;
    
    commentLocationManager.pausesLocationUpdatesAutomatically = NO;
    
    commentLocationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
    
    if ([CLLocationManager locationServicesEnabled])
    {
        [commentLocationManager startUpdatingLocation];
    }
    else
    {
        NSLog(@"Location services is not enabled");
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"Location failed with error: %@", error);
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    NSLog(@"Location updated to location: %@", newLocation);
    
    CLLocation *currentLocation = newLocation;
    
    if (currentLocation != nil)
    {
        // Stop Location Manager
        [commentLocationManager stopUpdatingLocation];
        
        // Reverse Geocoding
        NSLog(@"Resolving the address...");
        
        [commentGeocoder reverseGeocodeLocation:currentLocation completionHandler:^(NSArray *placemarks, NSError *error){
            
            NSLog(@"Found placemarks: %@, error: %@", placemarks, error);
            
            if (error == nil && [placemarks count] > 0)
            {
                commentPlacemark = [placemarks lastObject];
                
                // For full address
                
                selectedCity = nil;
                selectedCountry = nil;
                selectedRegion = nil;
                self.cityTextEdit.text = commentPlacemark.locality;
                self.countryTextEdit.text = commentPlacemark.country;
                self.postalTextEdit.text = commentPlacemark.postalCode;
                self.address1TextEdit.text = commentPlacemark.thoroughfare;
                self.stateTextEdit.text = commentPlacemark.administrativeArea;
                if (self.locationScrollView.hidden)
                {
                    [self setLocationToUser:editedUser];
                    self.locationTextEdit.text = [self sGetTextLocation];
                }
            }
            else
            {
                NSLog(@"%@", error.debugDescription);
            }
        } ];
    }
}

#pragma mark - updateUser
// Save user profile
- (void)updateUser
{
    // Hide keyboard if the user press the 'Create' button
    [self.view endEditing:YES];
    
    if ([self checkFieldsBasic])
    {
        if ([self checkUserMandatoryInfo]) {
            profileSaved = YES;
            [self getDataUserForUser:appDelegate.currentUser originalUser:editedUser];
            [appDelegate.currentUser setDelegate:self];
            appDelegate.completeUser = YES;
            [self stopActivityFeedback];
            [self startActivityFeedbackWithMessage:NSLocalizedString(@"_UPDATING_USER_ACTV_MSG_", nil)];
            [appDelegate.currentUser updateUserToServerDBVerbose:YES];
            [self cancelEditUser];
        }
        else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_PROFILE_COMPLETE_ERROR_",nil)
                                                            message:NSLocalizedString(@"_PROFILE_CONFIRM_MSG_",nil)
                                                           delegate:self
                                                  cancelButtonTitle:NSLocalizedString(@"_OK_",nil)
                                                  otherButtonTitles:NSLocalizedString(@"_COMPLETE_FIELDS_", nil),nil];
            [alert show];
        }
    }
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        NSLog(@"OK");
        profileSaved = YES;
        [self getDataUserForUser:appDelegate.currentUser originalUser:editedUser];
        [appDelegate.currentUser setDelegate:self];
        appDelegate.completeUser = NO;
        [self stopActivityFeedback];
        [self startActivityFeedbackWithMessage:NSLocalizedString(@"_UPDATING_USER_ACTV_MSG_", nil)];
        [appDelegate.currentUser updateUserToServerDBVerbose:YES];
        [self cancelEditUser];
    }
    else if (buttonIndex == 1) {
        NSLog(@"Complete");
    }
}

-(BOOL)checkUserMandatoryInfo {
    if (_firstNameTextEdit.text == nil || [_firstNameTextEdit.text isEqualToString:@""]) {
        return NO;
    }
    if (_lastNameTextEdit.text == nil || [_lastNameTextEdit.text isEqualToString:@""]) {
        return NO;
    }
    if (_emailTextEdit.text == nil || [_emailTextEdit.text isEqualToString:@""]) {
        return NO;
    }
    if (_birthdateTextEdit.text == nil || [_birthdateTextEdit.text isEqualToString:@""]) {
        return NO;
    }
    return YES;
}

- (void)userAccount:(User *)user didSignUpSuccessfully:(BOOL)bSignUpSuccess{
    [self stopActivityFeedback];
    [self swipeRightAction];
    
    /*
     if(self.fromViewController){
     [self stopActivityFeedback];
     [self swipeRightAction];
     }else{
     UIStoryboard *initialStoryboard = [UIStoryboard storyboardWithName:@"FashionistaContents" bundle:nil];
     
     [appDelegate.window setRootViewController:[initialStoryboard instantiateViewControllerWithIdentifier:[@(NEWSFEED_VC) stringValue]]];
     [((BaseViewController*)appDelegate.window.rootViewController) actionAfterLogIn];
     }
     */
}

- (void)cancelEditUser{
    if(editedUser!=nil){
        NSManagedObjectContext * currentContext = [RKObjectManager sharedManager].managedObjectStore.mainQueueManagedObjectContext;
        [currentContext deleteObject:editedUser];
        editedUser = nil;
    }
}

-(void) getDataUserForUser:(User*) user originalUser:(User*)originalUser
{
    // Get UUID from iOS defaults system
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    [user setUserWithUUID:[defaults objectForKey:@"UUID"]
                andUserID:originalUser.idUser
                  andName:self.firstNameTextEdit.text
               andSurname:self.lastNameTextEdit.text
                 andEmail:originalUser.email
              andPassword:originalUser.password
                 andPhone:self.phoneNumberTextEdit.text
             andBirthdate:birthDate
                andGender:originalUser.gender
          andPicpermision:YES
               andPicPath:originalUser.picture
                   andPic:originalUser.picImage
             andWardrobes:originalUser.wardrobes
               andReviews:originalUser.reviews
               andCountry:self.countryTextEdit.text
                 andState:self.stateTextEdit.text
                  andCity:self.cityTextEdit.text
              andAddress1:self.address1TextEdit.text
              andAddress2:self.address2TextEdit.text
            andPostalCode:self.postalTextEdit.text
              andUserName:originalUser.fashionistaName
               andWebsite:originalUser.fashionistaBlogURL
                   andBio:originalUser.fashionistaTitle];
    
    user.isPublic = [NSNumber numberWithBool:!_publicButton.on];
    
    user.phonecallingcode = originalUser.phonecallingcode;
    // data come from combobox
    user.country_id = originalUser.country_id;
    user.addressState_id = originalUser.addressState_id;
    user.addressCity_id = originalUser.addressCity_id;
    user.typeprofession = originalUser.typeprofession;
    user.typeprofessionId = originalUser.typeprofessionId;
    
    
    user.ethnicity = originalUser.ethnicity;
    user.experience = originalUser.experience;
    
    user.hairlength = originalUser.hairlength;
    user.piercings = originalUser.piercings;
    user.relationship = originalUser.relationship;
    user.shootnudes = originalUser.shootnudes;
    user.skincolor = originalUser.skincolor;
    user.tatoos = originalUser.tatoos;
    user.compensation = originalUser.compensation;
    user.typemeasures = originalUser.typemeasures;
    
    user.genre = originalUser.genre;
    user.heightM = originalUser.heightM;
    user.heightCm = originalUser.heightCm;
    user.haircolor = originalUser.haircolor;
    user.eyecolor = originalUser.eyecolor;
    user.cup = originalUser.cup;
    user.bust = originalUser.bust;
    user.waist = originalUser.waist;
    user.hip = originalUser.hip;
    user.shoe = originalUser.shoe;
    user.insteam = originalUser.insteam;
    
    user.validatedprofile = originalUser.validatedprofile;
    user.datequeryvalidateprofile = originalUser.datequeryvalidateprofile;
    user.datevalidatedprofile = originalUser.datevalidatedprofile;
    
    user.instruments = originalUser.instruments;
    user.agencies = originalUser.agencies;
    user.specialization = originalUser.specialization;
}


#pragma mark - createUser
/*
 -(void) showTermsConditions
 {
 if (self.viewTermsConditions.hidden)
 {
 NSURL *websiteUrl = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"terms_conditions" ofType:@"html"]];
 
 //NSURL *websiteUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@/terms_conditions.html",IMAGESBASEURL]];
 NSURLRequest *urlRequest = [NSURLRequest requestWithURL:websiteUrl];
 [self.webViewTermsConditions loadRequest:urlRequest];
 
 self.viewTermsConditions.layer.cornerRadius = 6.0;
 self.viewTermsConditions.layer.borderWidth = 1.0;
 self.viewTermsConditions.layer.borderColor = [UIColor blackColor].CGColor;
 self.viewTermsConditions.clipsToBounds = YES;
 
 self.viewTermsConditions.hidden = NO;
 self.viewTermsConditions.alpha = 0.0;
 [UIView animateWithDuration:0.5
 delay:0
 options:UIViewAnimationOptionCurveEaseOut
 animations:^ {
 self.viewTermsConditions.alpha = 1.0;
 }
 completion:^(BOOL finished) {
 //[self setBottomControlsLeftTitle:NSLocalizedString(@"_CANCEL_", nil) andRightTitle:NSLocalizedString(@"_ACCEPT_", nil) ];
 [self setLeftTitle:NSLocalizedString(@"_CANCEL_", nil) andImage:[UIImage imageNamed:@"left_arrow.png"]];
 [self setRightTitle:NSLocalizedString(@"_ACCEPT_", nil) andImage:[UIImage imageNamed:@"ok.png"]];
 }];
 }
 }
 
 -(void) hideTermsConditions
 {
 [UIView animateWithDuration:0.5
 delay:0
 options:UIViewAnimationOptionCurveEaseOut
 animations:^ {
 self.viewTermsConditions.alpha = 0.0;
 }
 completion:^(BOOL finished) {
 self.viewTermsConditions.hidden = YES;
 if (appDelegate.currentUser != nil)
 {
 //[self setBottomControlsLeftTitle:NSLocalizedString(@"_CANCEL_", nil) andRightTitle:NSLocalizedString(@"_UPDATE_ACCOUNT_", nil) ];
 [self setLeftTitle:NSLocalizedString(@"_CANCEL_", nil) andImage:[UIImage imageNamed:@"left_arrow.png"]];
 [self setRightTitle:NSLocalizedString(@"_UPDATE_ACCOUNT_", nil) andImage:[UIImage imageNamed:@"ok.png"]];
 }
 else
 {
 //[self setBottomControlsLeftTitle:NSLocalizedString(@"_CANCEL_", nil) andRightTitle:NSLocalizedString(@"_SIGN_UP_", nil) ];
 [self setLeftTitle:NSLocalizedString(@"_CANCEL_", nil) andImage:[UIImage imageNamed:@"left_arrow.png"]];
 [self setRightTitle:NSLocalizedString(@"_SIGN_UP_", nil) andImage:[UIImage imageNamed:@"right_arrow.png"]];
 }
 }];
 }
 
 
 // Save user profile
 - (void)createUser
 {
 // Hide keyboard if the user press the 'Create' button
 [self.view endEditing:YES];
 
 if([self checkFieldsBasic])
 {
 // Create User
 User *newUser;
 NSManagedObjectContext * currentContext = [RKObjectManager sharedManager].managedObjectStore.mainQueueManagedObjectContext;
 //        newUser = [NSEntityDescription insertNewObjectForEntityForName:@"User" inManagedObjectContext:currentContext];
 newUser = [[User alloc] initWithEntity:[NSEntityDescription entityForName:@"User" inManagedObjectContext: currentContext] insertIntoManagedObjectContext:currentContext];
 
 // Get UUID from iOS defaults system
 NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
 
 [newUser setUserWithUUID:[defaults objectForKey:@"UUID"]
 andUserID: nil
 andName:self.firstNameTextEdit.text
 andSurname:self.lastNameTextEdit.text
 andEmail:self.emailTextEdit.text
 andPassword:self.passwordTextEdit.text
 andPhone:self.phoneNumberTextEdit.text
 andBirthdate:birthDate
 andGender:[NSNumber numberWithInteger:_iGenderSelected]
 andPicpermision:YES
 andPicPath:@""
 andPic:(bPictureDirty?self.avatarImage.image:nil)
 andWardrobes:nil
 andReviews:nil
 andCountry:self.countryTextEdit.text
 andState:self.stateTextEdit.text
 andCity:self.cityTextEdit.text
 andAddress1:self.address1TextEdit.text
 andAddress2:self.address2TextEdit.text
 andPostalCode:self.postalTextEdit.text
 andUserName:[self.usernameTextEdit.text stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceCharacterSet]]
 andWebsite:self.websiteTextEdit.text
 andBio:self.bioTextEdit.text];
 
 
 newUser.passwordClear = self.passwordTextEdit.text;
 
 [newUser setDelegate:self];
 
 [self stopActivityFeedback];
 [self startActivityFeedbackWithMessage:NSLocalizedString(@"_SIGNUP_ACTV_MSG_", nil)];
 [newUser saveUserToServerDB];
 }
 }
 */

- (void)actionAfterSignUp
{
    [super actionAfterSignUp];
    
    return;
}

#pragma mark - Login actions

// Peform an action once the user logs in
- (void)actionAfterLogIn
{
    //[super actionAfterLogIn];
    return;
}

// Peform an action once the user logs out
- (void)actionAfterLogOut
{
    [super actionAfterLogOut];
    return;
}


#pragma mark - Events to control when the keyboard appears, and adapt the constraint to it

- (CGFloat)keyboardVerticalIncreaseForNotification:(NSNotification *)notification {
    CGFloat keyboardBeginY = [notification.userInfo[UIKeyboardFrameBeginUserInfoKey] CGRectValue].origin.y;
    CGFloat keyboardEndY = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue].origin.y;
    CGFloat keyboardVerticalIncrease = keyboardBeginY - keyboardEndY;
    return keyboardVerticalIncrease;
}

- (void)animateTextViewFrameForVerticalOffset:(CGFloat)offset {
    CGFloat constant = self.bottomSlideConstraint.constant;
    CGFloat newConstant = constant + offset + 50;
    if (offset > 0)
        newConstant = constant + offset - 50;
    
    self.bottomSlideConstraint.constant = newConstant;
    [self.view layoutIfNeeded];
    
    constant = self.bottomSlideConstraint.constant;
    if(constant<=oldConstant){
        constant = 0;
    }
    newConstant = constant + offset;// + 50;
    [self animateTextViewFrameForVerticalHeight:newConstant];
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    [self.view endEditing:YES];
    return YES;
}

#pragma mark - PrrotectedFunctions
-(void) borderTextEdit:(UITextField *) _textField withColor:(UIColor *)_color withBorder:(float) _fBorderWith
{
    _textField.layer.borderColor = _color.CGColor;
    _textField.layer.borderWidth= _fBorderWith;
    
}

#pragma mark - PrivateFunctions
// Provides the path for a given file
- (NSString *)documentsPathForFileName:(NSString *)name
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString *documentsPath = [paths objectAtIndex:0];
    
    return [documentsPath stringByAppendingPathComponent:name];
}


- (IBAction)hideKeyboard:(id)sender
{
    if (sender == self.phoneNumberTextEdit)
    {
        NSLog(@"Validate Phone %@", [NSString validatePhone:self.phoneNumberTextEdit.text] ? @"OK" : @"KO");
    }
    
    [self.view endEditing:YES];
    [sender resignFirstResponder];
}



-(NSString *) sGetTextLocation
{
    NSString * sLocation = @"";
    
    //    if (self.address1TextEdit.text)
    //    {
    //        if (![self.address1TextEdit.text  isEqualToString: @""])
    //            sLocation = [sLocation stringByAppendingFormat:@"%@", self.address1TextEdit.text];
    //    }
    if (self.cityTextEdit.text)
    {
        if (![self.cityTextEdit.text  isEqualToString: @""])
            sLocation = [sLocation stringByAppendingFormat:@"%@", self.cityTextEdit.text];
    }
    if (self.countryTextEdit.text)
    {
        if (![self.countryTextEdit.text  isEqualToString: @""])
            sLocation = [sLocation stringByAppendingFormat:@" (%@)", self.countryTextEdit.text];
    }
    
    //    if ([sLocation isEqualToString: @""])
    //    {
    //        if (self.stateTextEdit.text)
    //        {
    //            if (![self.stateTextEdit.text  isEqualToString: @""])
    //                sLocation = [sLocation stringByAppendingFormat:@"%@", self.stateTextEdit.text];
    //        }
    //        if (self.countryTextEdit.text)
    //        {
    //            if (![self.countryTextEdit.text  isEqualToString: @""])
    //                sLocation = [sLocation stringByAppendingFormat:@" (%@)", self.countryTextEdit.text];
    //        }
    //    }
    
    //    if ([sLocation isEqualToString: @""])
    //        sLocation = NSLocalizedString(@"_INCORRECT_LOCATION", nil);
    
    
    return sLocation;
}

-(BOOL) checkFieldsMandatoryInView:(UIView *)viewToCheck
{
    for(UIView * viewChild in viewToCheck.subviews)
    {
        if ([viewChild isKindOfClass:[UITextField class]])
        {
            UITextField * textToCheck = (UITextField *)viewChild;
            
            if (textToCheck.tag == 1)
            {
                if ([textToCheck.text isEqualToString:@""])
                {
                    return NO;
                }
            }
        }
    }
    
    return YES;
}

-(BOOL) checkFieldsBasic
{
    if ([self checkFieldsMandatoryInView:self.basicSubview] == NO)
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_ERROR_", nil) message:NSLocalizedString(@"_PLEASE_FILL_MANDATORY_FIELDS_", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"_OK_", nil) otherButtonTitles: nil];
        
        [alertView show];
        
        return NO;
    }
    
    // Check if telephone has a correct format
    if (![self.phoneNumberTextEdit.text  isEqualToString: @""])
    {
        if(![NSString validatePhone:self.phoneNumberTextEdit.text])
        {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_ERROR_", nil) message:NSLocalizedString(@"_ENTER_VALID_PHONE_", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"_OK_", nil) otherButtonTitles: nil];
            
            [alertView show];
            
            return NO;
            
        }
    }
    
    if(editedUser.typeprofessionId==nil||[editedUser.typeprofessionId isEqualToString:@""]){
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_ERROR_", nil) message:NSLocalizedString(@"_ENTER_WHOAREYOU_", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"_OK_", nil) otherButtonTitles: nil];
        
        [alertView show];
        
        return NO;
    }
    return YES;
}

-(BOOL) checkFieldsLocation
{
    if ([self checkFieldsMandatoryInView:self.locationSubview] == NO)
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_ERROR_", nil) message:NSLocalizedString(@"_PLEASE_FILL_MANDATORY_FIELDS_", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"_OK_", nil) otherButtonTitles: nil];
        
        [alertView show];
        
        return NO;
    }
    
    return YES;
}

/*
 -(BOOL) checkFieldsProfession
 {
 if ([self checkFieldsMandatoryInView:subviewProfessionSelected] == NO)
 {
 UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_ERROR_", nil) message:NSLocalizedString(@"_PLEASE_FILL_MANDATORY_FIELDS_", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"_OK_", nil) otherButtonTitles: nil];
 
 [alertView show];
 
 return NO;
 }
 
 return YES;
 }
 */

/*
 #pragma mark - Select profession
 
 - (IBAction)professionEdit:(UITextField *)sender {
 textFieldEditing = self.professionTextEdit;
 if (arElementsPickerView == nil)
 {
 arElementsPickerView = [[NSMutableArray alloc] init];
 }
 [arElementsPickerView removeAllObjects];
 iIdxElementSelectedInPickerView = -1;
 
 iIdxOldElementSelectedInPickerView = -1;
 
 // AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
 NSArray * objs = [appDelegate.config valueForKey:@"profession_stylist"];
 
 for (int i = 0; i < objs.count; i++)
 {
 [arElementsPickerView addObject:NSLocalizedString([objs objectAtIndex:i],nil)];
 }
 
 iIdxOldElementSelectedInPickerView = appDelegate.currentUser.typeprofession.intValue;
 
 
 CGRect frame = self.view.frame;
 
 PickerViewButtons *myPickerView = [[PickerViewButtons alloc] initWithFrame:frame];
 myPickerView.delegate = self;
 [myPickerView setElements:arElementsPickerView];
 if (iIdxOldElementSelectedInPickerView != -1)
 {
 [myPickerView.pickerView selectRow:iIdxOldElementSelectedInPickerView inComponent:0 animated:YES];
 }
 
 textFieldEditing.inputView = myPickerView;
 }
 */
#pragma mark - MultiviewSelector management
-(void) multiSelectButtonView:(MultiSelectViewButtons *)pickerView didButtonClick:(BOOL)bOk withSelected:(NSArray *)arSelected
{
    if (bOk)
    {
        /*
         if ((textFieldEditing == self.modelgenreview)||
         (textFieldEditing == self.photographergenre) ||
         (textFieldEditing == self.filmakergenre) ||
         (textFieldEditing == self.deafultfashiongenre) ||
         (textFieldEditing == self.eventplannergenre) ||
         (textFieldEditing == self.brandgenre) ||
         (textFieldEditing == self.publicationgenre))
         
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
         appDelegate.currentUser.genre = genre;
         }
         */
    }
    else
    {
        
        textFieldEditing.text = [editedUser sGetTextGenre];
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
    
    
    CGRect frame = self.view.frame;
    
    MultiSelectViewButtons *myMultiselectView = [[MultiSelectViewButtons alloc] initWithFrame:frame];
    myMultiselectView.delegate = self;
    [myMultiselectView setElements:arElementsPickerView];
    [myMultiselectView setElementsSelected:arSelected];
    
    textFieldEditing.inputView = myMultiselectView;
}

#pragma mark - Picker Management

-(void) initPickerViewWithMaxElements:(NSInteger) iNumElements andWithLocalizedString:(NSString *)sString forTextField:(UITextField *)uitextfield withElementSelected:(NSInteger) iIdxSelected
{
    textFieldEditing = uitextfield;
    if (arElementsPickerView == nil)
    {
        arElementsPickerView = [[NSMutableArray alloc] init];
    }
    [arElementsPickerView removeAllObjects];
    iIdxElementSelectedInPickerView = -1;
    
    iIdxOldElementSelectedInPickerView = iIdxSelected;
    
    for (int i = 0; i < iNumElements; i++)
    {
        [arElementsPickerView addObject:NSLocalizedString(([NSString stringWithFormat:sString,i]), nil)];
    }
    
    
    CGRect frame = self.view.frame;
    
    PickerViewButtons *myPickerView = [[PickerViewButtons alloc] initWithFrame:frame];
    myPickerView.delegate = self;
    [myPickerView setElements:arElementsPickerView];
    if (iIdxSelected != -1)
    {
        [myPickerView.pickerView selectRow:iIdxOldElementSelectedInPickerView inComponent:0 animated:YES];
    }
    
    textFieldEditing.inputView = myPickerView;
}
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
    
    
    CGRect frame = self.view.frame;
    
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
    [self setFieldOfUserFromPickerViewWinIndex:iRow];
}

- (void) pickerButtonView:(PickerViewButtons *)pickerView didButtonClick:(BOOL)bOk withindex:(NSInteger) iRow
{
    if (bOk)
    {
        [self setFieldOfUserFromPickerViewWinIndex:iRow];
        [self setLocationToUser:editedUser];
        [self updateLocationData];
    }
    else
    {
        if (iIdxOldElementSelectedInPickerView != -1)
        {
            [self setFieldOfUserFromPickerViewWinIndex:iIdxOldElementSelectedInPickerView];
            textFieldEditing.text = [arElementsPickerView objectAtIndex:iIdxOldElementSelectedInPickerView];
        }
        else
        {
            if (textFieldEditing == self.countryTextEdit)
            {
                textFieldEditing.text = editedUser.country;
            }
            else
            {
                textFieldEditing.text = @"";
            }
        }
    }
    // hide the picker view
    [textFieldEditing resignFirstResponder];
}


-(void) setFieldOfUserFromPickerViewWinIndex:(NSInteger) iRow
{
    /*
     if (iRow > -1)
     {
     textFieldEditing.text = [arElementsPickerView objectAtIndex:iRow];
     if (textFieldEditing == self.professionTextEdit)
     {
     iIdxProfessionSelected = iRow;
     appDelegate.currentUser.typeprofession = [NSNumber numberWithLong:iIdxProfessionSelected];
     }
     else if ((textFieldEditing == self.modelgender) ||
     (textFieldEditing == self.photographergender) ||
     (textFieldEditing == self.deafultfashiongender) ||
     (textFieldEditing == self.brandgender) ||
     (textFieldEditing == self.genderTextEdit) ||
     (textFieldEditing == self.userstandardgender))
     {
     _iGenderSelected = iRow;
     appDelegate.currentUser.gender = [NSNumber numberWithLong:iRow];
     }
     else if ((textFieldEditing == self.modelcompensation) ||
     (textFieldEditing == self.photographercompensation) ||
     (textFieldEditing == self.filmakercompensation) ||
     (textFieldEditing == self.deafultfashioncompensation) ||
     (textFieldEditing == self.eventplannercompensation) ||
     (textFieldEditing == self.brandcompensation) ||
     (textFieldEditing == self.publicationcompensation))
     {
     appDelegate.currentUser.compensation = [NSNumber numberWithLong:iRow];
     }
     else if (textFieldEditing == self.modelcup)
     {
     appDelegate.currentUser.cup = [NSNumber numberWithLong:iRow];
     }
     else if (textFieldEditing == self.modelmeasuringtypes)
     {
     appDelegate.currentUser.typemeasures = [NSNumber numberWithLong:iRow];
     // label of the measures types
     if (appDelegate.currentUser.typemeasures.intValue == 1)
     {
     self.modelheightlabel.text = @"m";
     self.modelheightcmlabel.text = @"cm";
     }
     else if (appDelegate.currentUser.typemeasures.intValue == 2)
     {
     self.modelheightlabel.text = @"feet";
     self.modelheightcmlabel.text = @"inches";
     }
     else
     {
     self.modelheightlabel.text = @"";
     self.modelheightcmlabel.text = @"";
     }
     }
     else if (textFieldEditing == self.modelethnicity)
     {
     appDelegate.currentUser.ethnicity = [NSNumber numberWithLong:iRow];
     }
     else if ((textFieldEditing == self.modelexperience) ||
     (textFieldEditing == self.photographerexperience) ||
     (textFieldEditing == self.filmakerexperience) ||
     (textFieldEditing == self.deafultfashionexperience) ||
     (textFieldEditing == self.eventplannerexperience) ||
     (textFieldEditing == self.brandexperience) ||
     (textFieldEditing == self.publicationexperience))
     {
     appDelegate.currentUser.experience = [NSNumber numberWithLong:iRow];
     }
     else if (textFieldEditing == self.modeleyecolor)
     {
     appDelegate.currentUser.eyecolor = [NSNumber numberWithLong:iRow];
     
     }
     //            else if ((textFieldEditing == self.modelgenreview)||
     //                     (textFieldEditing == self.photographergenre) ||
     //                     (textFieldEditing == self.filmakergenre) ||
     //                     (textFieldEditing == self.deafultfashiongenre) ||
     //                     (textFieldEditing == self.eventplannergenre) ||
     //                     (textFieldEditing == self.brandgenre) ||
     //                     (textFieldEditing == self.publicationgenre))
     //
     //            {
     //                appDelegate.currentUser.genre = [NSNumber numberWithLong:iRow];
     //            }
     else if (textFieldEditing == self.modeldress)
     {
     appDelegate.currentUser.dress = [NSNumber numberWithLong:iRow];
     }
     else if (textFieldEditing == self.modelshoe)
     {
     appDelegate.currentUser.shoe = [NSNumber numberWithLong:iRow];
     }
     else if (textFieldEditing == self.modelhaircolor)
     {
     appDelegate.currentUser.haircolor = [NSNumber numberWithLong:iRow];
     }
     else if (textFieldEditing == self.modelhairlength)
     {
     appDelegate.currentUser.hairlength = [NSNumber numberWithLong:iRow];
     }
     else if (textFieldEditing == self.modelpiercings)
     {
     appDelegate.currentUser.piercings = [NSNumber numberWithLong:iRow];
     }
     else if ((textFieldEditing == self.modelrelationship)||
     (textFieldEditing == self.photographerrealtionship) ||
     (textFieldEditing == self.filmakerrelationship) ||
     (textFieldEditing == self.deafultfashionrelationship) ||
     (textFieldEditing == self.eventplannerrelationship))
     {
     appDelegate.currentUser.relationship = [NSNumber numberWithLong:iRow];
     }
     else if ((textFieldEditing == self.modelshootnudes) ||
     (textFieldEditing == self.photographershootnudes) ||
     (textFieldEditing == self.filmakershootnudes))
     {
     appDelegate.currentUser.shootnudes = [NSNumber numberWithLong:iRow];
     }
     else if (textFieldEditing == self.modelskincolor)
     {
     appDelegate.currentUser.skincolor = [NSNumber numberWithLong:iRow];
     }
     else if (textFieldEditing == self.countryTextEdit)
     {
     //            appDelegate.currentUser.country = textFieldEditing.text;
     selectedCountry = [arCountries objectAtIndex:iRow];
     //            appDelegate.currentUser.country_id = selectedCountry.idCountry;
     }
     else if (textFieldEditing == self.stateTextEdit)
     {
     //            appDelegate.currentUser.addressState = textFieldEditing.text;
     selectedRegion = [arRegions objectAtIndex:iRow];
     //            appDelegate.currentUser.addressState_id = selectedRegion.idStateRegion;
     }
     else if (textFieldEditing == self.cityTextEdit)
     {
     //            appDelegate.currentUser.addressCity = textFieldEditing.text;
     selectedCity = [arCities objectAtIndex:iRow];
     //            appDelegate.currentUser.addressCity_id = selectedCity.idCity;
     }
     else if (textFieldEditing == self.prefixPhonenumberTextEdit)
     {
     //            NSString * countryName = [arElementsPickerView objectAtIndex:iRow];
     //            NSRange rangeName = [countryName rangeOfString:@"+"];
     //
     //            if (rangeName.location != NSNotFound)
     //            {
     //                countryName = [countryName substringToIndex:rangeName.location-2];
     //                for(Country * c in arCountries)
     //                {
     //                    if ([c.name isEqualToString:countryName])
     //                    {
     //                        if (selectedCountry != c)
     //                        {
     //                            selectedCountry = c;
     //                            selectedCity = nil;
     //                            selectedRegion = nil;
     //                            self.countryTextEdit.text = c.name;
     //                            self.stateTextEdit.text = @"";
     //                            self.cityTextEdit.text = @"";
     //                            self.address1TextEdit.text = @"";
     //                            self.address2TextEdit.text = @"";
     //                            break;
     //                        }
     //                    }
     //                }
     //            }
     
     NSString * sCallingCodePlus = [NSString stringWithFormat:@"+%@", [arCountriesCallingCodes objectAtIndex:iRow]];
     textFieldEditing.text = sCallingCodePlus;
     //            appDelegate.currentUser.phonecallingcode = [arCountriesCallingCodes objectAtIndex:iRow];
     
     }
     }
     else
     {
     if (textFieldEditing == self.countryTextEdit)
     {
     self.countryTextEdit.text = @"";
     selectedCountry = nil;
     }
     else if (textFieldEditing == self.stateTextEdit)
     {
     self.stateTextEdit.text = @"";
     selectedRegion = nil;
     }
     else if (textFieldEditing == self.cityTextEdit)
     {
     self.cityTextEdit.text = @"";
     selectedCity = nil;
     }
     else if (textFieldEditing == self.prefixPhonenumberTextEdit)
     {
     self.prefixPhonenumberTextEdit.text = @"";
     //            appDelegate.currentUser.phonecallingcode = @"";
     }
     }
     */
    if (iRow > -1)
    {
        textFieldEditing.text = [arElementsPickerView objectAtIndex:iRow];
        if (textFieldEditing == self.countryTextEdit)
        {
            Country * tempCountry = [arCountries objectAtIndex:iRow];
            if ([tempCountry.idCountry isEqualToString:selectedCountry.idCountry] == NO)
            {
                selectedCountry = tempCountry;
                selectedRegion = nil;
                selectedCity = nil;
            }
        }
        else if (textFieldEditing == self.stateTextEdit)
        {
            StateRegion * tempStateRegion = [arRegions objectAtIndex:iRow];
            if ([tempStateRegion.idStateRegion isEqualToString:selectedRegion.idStateRegion] == NO)
            {
                selectedRegion = tempStateRegion;
                selectedCity = nil;
            }
            
            if (selectedCity.stateregion != selectedRegion)
            {
                selectedCity = nil;
            }
        }
        else if (textFieldEditing == self.cityTextEdit)
        {
            selectedCity = [arAllCities objectAtIndex:iRow];
            // search for the state region top
            StateRegion *stateregiontop = selectedCity.stateregion;
            while(stateregiontop != nil)
            {
                if (stateregiontop.parentstateregion != nil)
                    stateregiontop = stateregiontop.parentstateregion;
                else
                    break;
            }
            if (stateregiontop != nil)
            {
                selectedRegion = stateregiontop;//[self getRegionOfCity:selectedCity];
            }
        }
    }
    else
    {
        if (textFieldEditing == self.countryTextEdit)
        {
            self.countryTextEdit.text = @"";
            selectedCountry = nil;
        }
        else if (textFieldEditing == self.stateTextEdit)
        {
            self.stateTextEdit.text = @"";
            selectedRegion = nil;
        }
        else if (textFieldEditing == self.cityTextEdit)
        {
            self.cityTextEdit.text = @"";
            selectedCity = nil;
        }
    }
}

#pragma mark - Picker Filtered Management

-(void) initPickerFilteredViewWithElements:(NSArray *) arElements forTextField:(UITextField *)uitextfield withElementSelected:(NSInteger) iIdxSelected
{
    // split the string by coma
    NSMutableArray * arSelected = [[NSMutableArray alloc] init];
    if ((iIdxSelected >= 0) && (iIdxSelected < arElements.count))
    {
        [arSelected addObject:[NSIndexPath indexPathForRow:iIdxSelected inSection:0]];
    }
    
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
    
    
    CGRect frame2 = CGRectMake(0.0, 60, self.view.frame.size.width, self.view.frame.size.height - 60);
    PickerFilteredViewButtons *myPickerView = [[PickerFilteredViewButtons alloc] initWithFrame:frame2];
    myPickerView.delegate = self;
    [myPickerView setElements:arElementsPickerView];
    [myPickerView setElementsSelected:arSelected];
    
    pickerFilteredPickerView = myPickerView;
    [self.view addSubview:pickerFilteredPickerView];
    [self.view bringSubviewToFront:pickerFilteredPickerView];
    
    self.leftButton.hidden = YES;
    self.middleLeftButton.hidden = YES;
    self.homeButton.hidden = YES;
    self.middleRightButton.hidden = YES;
    self.rightButton.hidden =YES;
    
}

-(void) pickerFilteredButtonView:(PickerFilteredViewButtons *)pickerView changeSelection:(NSArray *)arSelected
{
    long iIdxCountrySelected = 0;
    if (arSelected.count > 0)
    {
        NSIndexPath * index = (NSIndexPath *)([arSelected objectAtIndex:0]);
        iIdxCountrySelected = (long)index.row;
    }
    /*
     if (textFieldEditing == self.prefixPhonenumberTextEdit)
     {
     textFieldEditing.text = [arCountriesCallingCodes objectAtIndex:iIdxCountrySelected];
     }
     else
     {
     textFieldEditing.text = [arElementsPickerView objectAtIndex:iIdxCountrySelected];
     }
     */
    textFieldEditing.text = [arElementsPickerView objectAtIndex:iIdxCountrySelected];
    [self setFieldOfUserFromPickerViewWinIndex:iIdxCountrySelected];
}

-(void) pickerFilteredButtonView:(PickerFilteredViewButtons *)pickerView didButtonClick:(BOOL)bOk withSelected:(NSArray *)arSelected
{
    citiesFilter = nil;
    pickerFilteredPickerView = nil;
    self.leftButton.hidden = NO;
    self.middleLeftButton.hidden = NO;
    self.homeButton.hidden = NO;
    self.middleRightButton.hidden = NO;
    self.rightButton.hidden = NO;
    if (bOk)
    {
        long iIdxElementSelected = -1;
        if (arSelected.count > 0)
        {
            NSIndexPath * index = (NSIndexPath *)([arSelected objectAtIndex:0]);
            iIdxElementSelected = (long)index.row;
        }
        
        [self setFieldOfUserFromPickerViewWinIndex:iIdxElementSelected];
        [self updateLocationData];
        //        self.locationTextEdit.text = [self sGetTextLocation];
    }
    else
    {
        if (iIdxOldElementSelectedInPickerView != -1)
        {
            [self setFieldOfUserFromPickerViewWinIndex:iIdxOldElementSelectedInPickerView];
            /*
             if (textFieldEditing == self.prefixPhonenumberTextEdit)
             {
             NSString * sCallingCodePlus = [NSString stringWithFormat:@"+%@", [arCountriesCallingCodes objectAtIndex:iIdxOldElementSelectedInPickerView]];
             
             textFieldEditing.text = sCallingCodePlus;
             }
             else
             {
             textFieldEditing.text = [arElementsPickerView objectAtIndex:iIdxOldElementSelectedInPickerView];
             }
             */
            textFieldEditing.text = [arElementsPickerView objectAtIndex:iIdxOldElementSelectedInPickerView];
        }
        else
        {
            
            if (textFieldEditing == self.countryTextEdit)
            {
                textFieldEditing.text = editedUser.country;
                //                selectedCountry = nil;
            }
            else if (textFieldEditing == self.stateTextEdit)
            {
                textFieldEditing.text = editedUser.addressState;
                //                selectedRegion = nil;
            }
            else if (textFieldEditing == self.cityTextEdit)
            {
                textFieldEditing.text = editedUser.addressCity;
                //                selectedCity = nil;
            }
            else
            {
                textFieldEditing.text = @"";
            }
        }
    }
}


#pragma mark - Rest Services call
// Action to perform if the connection succeed
- (void) actionAfterSuccessfulAnswerToRestConnection:(connectionType)connection WithResult:(NSArray *)mappingResult
{
    // AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    switch (connection)
    {
        case GET_ALLCOUNTRIES:
        {
            [self getCountriesFromServer:mappingResult];
            [self stopActivityFeedback];
            break;
        }
        case GET_STATESOFCOUNTRY:
        {
            [self getStatesFromServer:mappingResult];
            [self stopActivityFeedback];
            break;
        }
        case GET_CITIESOFSTATE:
        {
            [self getCitiesFromServer:mappingResult];
            [self stopActivityFeedback];
            break;
        }
            
        default:
            break;
    }
}

-(void) processRestConnection:(connectionType)connection WithErrorMessage:(NSArray *)errorMessage forOperation:(RKObjectRequestOperation *)operation
{
    [super processRestConnection:connection WithErrorMessage:errorMessage forOperation:operation];
    
    switch (connection)
    {
        case GET_ALLCOUNTRIES:
        {
            bLoadingCountries = NO;
            break;
        }
        case GET_STATESOFCOUNTRY:
        {
            bLoadingStateRegions =NO;
            break;
        }
        case GET_CITIESOFSTATE:
        {
            _bLoadingCities = NO;
            break;
        }
            
        default:
            break;
    }
}

#pragma mark - WhoAreYouDelegate

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender{
    if([identifier isEqualToString:@"nextSegue"]){
        return [self checkFieldsBasic];
    }
    return YES;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([segue.identifier isEqualToString:@"whoAreYouSegue"]){
        GSUserWhoAreYouViewController* whoAreVC = (GSUserWhoAreYouViewController*)segue.destinationViewController;
        whoAreVC.delegate = self;
    }else if([segue.identifier isEqualToString:@"nextSegue"]){
        GSAccountDetailViewController* accountDetail = (GSAccountDetailViewController*)segue.destinationViewController;
        accountDetail.editingUser = editedUser;
        accountDetail.accountDelegate = self;
        //[self updateUser];
        //[appDelegate.currentUser updateUserToServerDBVerbose:NO];
    }
}

- (void)setupButtonsWithNext:(BOOL)nextOrNot{
    if(nextOrNot){
        self.nextStepButton.hidden = NO;
        self.saveButton.hidden = YES;
        [self.nextStepButton.superview bringSubviewToFront:self.nextStepButton];
    }else{
        self.nextStepButton.hidden = YES;
        self.saveButton.hidden = NO;
        [self.saveButton.superview bringSubviewToFront:self.saveButton];
    }
}

- (void)setUserIdentity:(GSAccountType *)account{
    editedUser.typeprofessionId = account.typeId;
    self.professionTextEdit.text = [editedUser sGetTextProfession];
    [self setupButtonsWithNext:([account.modules count]>0)];
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (IBAction)saveProfile:(id)sender {
    [self updateUser];
    //[self swipeRightAction];
}

- (void)swipeRightAction{
    if(self.locationScrollView.hidden){
        if(!profileSaved){
            [self cancelEditUser];
        }
        
        if(self.fromViewController){
            [super swipeRightAction];
        }else if(profileSaved){
            [self transitionToViewController:USERPROFILE_VC withParameters:nil];
        }
        profileSaved = NO;
    }else{
        [self hideLocation];
    }
}

- (IBAction)hideLocationView:(id)sender {
    // restore location
    [self loadLocationOfUser:appDelegate.currentUser];
    [appDelegate.currentUser copyLocationFields:editedUser];
    
    // hide the location view
    [self hideLocation];
}

- (IBAction)saveLocation:(id)sender {
    self.locationTextEdit.text = [self sGetTextLocation];
    editedUser.country = @"";
    editedUser.country_id = @"";
    editedUser.addressCity_id = @"";
    editedUser.addressCity = @"";
    editedUser.addressState_id = @"";
    editedUser.addressState = @"";
    if (selectedCountry != nil)
    {
        editedUser.country = selectedCountry.name;
        editedUser.country_id = selectedCountry.idCountry;
    }
    if (selectedRegion != nil)
    {
        editedUser.addressCity_id = selectedCity.idCity;
        editedUser.addressCity = selectedCity.name;
    }
    if (selectedRegion != nil)
    {
        editedUser.addressState_id = selectedRegion.idStateRegion;
        editedUser.addressState = selectedRegion.name;
    }
    [self hideLocation];
}

- (IBAction)cancelProfile:(id)sender {
    [super swipeRightAction];
}

- (void)commitSave{
    [self dismissViewControllerAnimated:YES completion:^{
        [self saveProfile:nil];
    }];
}

#pragma mark - dynamic keyboard moving content

- (void)animateTextViewFrameForVerticalHeight:(CGFloat)height{
    if (oldConstant<height) {
        height = height;
        self.bottomSlideConstraint.constant = MAX(height,oldConstant);
        [self.view layoutIfNeeded];
    }
}

- (void)keyboardWillHideNotification:(NSNotification *)notification
{
    [self animateTextViewFrameForVerticalHeight:oldConstant];
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

@end
