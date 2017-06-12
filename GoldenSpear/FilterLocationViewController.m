//
//  FilterLocationViewController.m
//  GoldenSpear
//
//  Created by Crane on 9/20/16.
//  Copyright © 2016 GoldenSpear. All rights reserved.
//

#import "FilterLocationViewController.h"

#import "FashionistaUserListViewController.h"
#import "BaseViewController+RestServicesManagement.h"
#import "BaseViewController+ActivityFeedbackManagement.h"
#import "BaseViewController+StoryboardManagement.h"
#import "BaseViewController+TopBarManagement.h"
#import "BaseViewController+FetchedResultsManagement.h"
#import "AppDelegate.h"
#import "FashionistaUserListViewCell.h"
#import "InviteView.h"

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

@interface FilterLocationViewController ()
@property (nonatomic) BOOL bLoadingCities;

@end

@implementation FilterLocationViewController {
    NSMutableArray *locaitonArry;
    NSMutableArray *searchArry;
    BOOL searchActive;
    NSMutableArray * arCountries;
    NSMutableArray * arCountriesCallingCodes;
    Country * selectedCountry;
    NSMutableArray * arRegions;
    StateRegion * selectedRegion;
    NSMutableArray * arCities;
    NSMutableArray * arAllCities;
    City * selectedCity;
    BOOL bLoadingCountries;
    BOOL bLoadingStateRegions;
    
    int iCurrentSkip;
    int iCurrentLimit;
    int cState;
    int cCity;
    
    BOOL bMoreCities;
    
    NSString * sFilterCities;
    
    Country * countrySerching;
    StateRegion * stateSearching;
    NSMutableArray *selectedArry;
}

- (void)dealloc{
    self.imagesQueue = nil;
}
- (void)viewDidLoad{
    [super viewDidLoad];
    
    selectedArry = [[NSMutableArray alloc]init];
    self.view.translatesAutoresizingMaskIntoConstraints = NO;
    self.imagesQueue = [[NSOperationQueue alloc] init];
    
    // Set max number of concurrent operations it can perform at 3, which will make things load even faster
    self.imagesQueue.maxConcurrentOperationCount = 3;
    self.searchContext = FASHIONISTAS_SEARCH;
    locaitonArry = [[NSMutableArray alloc]init];
    searchActive = NO;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldDidChange:) name:UITextFieldTextDidChangeNotification object:_searchBar];

    UIToolbar *toolbar = [UIToolbar new];
    toolbar.barStyle = UIBarStyleDefault;
    [toolbar sizeToFit];
    // [boolbar setBarStyle:UIBarStyleBlack];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setFrame:CGRectMake(0, 0, 80, 35)];
    [button setTitle:@"CLOSE" forState:UIControlStateNormal];
    button.layer.borderWidth = 2.0f;
    button.layer.borderColor = [UIColor blackColor].CGColor;
    button.layer.cornerRadius = 3.0f;
    button.layer.masksToBounds = NO;
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(btn_close:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *btn_QuickPhrase = [[UIBarButtonItem alloc] initWithCustomView:button];
    [btn_QuickPhrase setTintColor:[UIColor blackColor]];
    
    UIBarButtonItem *flex = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    
    button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setFrame:CGRectMake(0, 0, 80, 35)];
    [button setTitle:@"ADD" forState:UIControlStateNormal];
    button.backgroundColor = [UIColor blackColor];
    button.layer.cornerRadius = 3.0f;
    button.layer.masksToBounds = NO;
    [button addTarget:self action:@selector(btn_add:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *btn_SmartComments = [[UIBarButtonItem alloc] initWithCustomView:button];
    
    [btn_SmartComments setTintColor:[UIColor whiteColor]];
    
    NSArray *array = [NSArray arrayWithObjects:btn_QuickPhrase, flex, btn_SmartComments, nil];
    [toolbar setItems:array];
    
    _searchBar.inputAccessoryView = toolbar;
    [_searchBar becomeFirstResponder];
    
    switch (_searchType) {
        case 0:
            selectedArry = _countries;
            break;
        case 1:
            selectedArry = _states;
            break;
        case 2:
            selectedArry = _cities;
        default:
            break;
    }
}

-(IBAction)btn_close:(id)sender
{
    [self.view endEditing:true];
}
-(IBAction)btn_add:(id)sender
{
    if ([self.filterLocationDelegate respondsToSelector:@selector(setLocations:type:)]) {
        [self.filterLocationDelegate setLocations:selectedArry type:_searchType];
    }
    [_tableView reloadData];
}

- (void)operationAfterLoadingSearch:(BOOL)hasResults{
    if(!hasResults){
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_INFO_", nil) message:NSLocalizedString(@"_NO_RESULTS_ERROR_MSG_", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"_OK_", nil) otherButtonTitles:nil];
        
        [alertView show];
    }else{
        [self stopActivityFeedback];
    }
}

- (void)textFieldDidChange:(NSNotification *)notification {
    // Do whatever you like to respond to text changes here.
    NSString *searchtext = _searchBar.text;
    if ([searchtext isEqualToString:@""]) {
        searchActive = NO;
        if (searchArry.count > 0)
            [searchArry removeAllObjects];
        
        [self.tableView reloadData];
        return;
    }
    
    return;
    if (searchArry == nil)
        searchArry = [[NSMutableArray alloc]init];
    else if (searchArry.count > 0)
        [searchArry removeAllObjects];
    
    switch (_searchType) {
        case 0: //country
        {
            for (Country *count in arCountries) {
                NSString *name = count.name;
                NSLog(@"sss  %@", name);
                NSRange range = [name  rangeOfString: searchtext options: NSCaseInsensitiveSearch];
                if (range.location != NSNotFound) {
                    [searchArry addObject:count];
                }
                
            }
            break;
        }
        case 1: //state
        {
            for (StateRegion *state in arRegions) {
                NSString *name = state.name;
                NSLog(@"sss  %@", name);
                NSRange range = [name  rangeOfString: searchtext options: NSCaseInsensitiveSearch];
                if (range.location != NSNotFound) {
                    [searchArry addObject:state];
                }
                
            }
            
            break;
        }
        case 2: //cities
        {
            for (City *city in arAllCities) {
                NSString *name = city.name;
                NSLog(@"sss  %@", name);
                NSRange range = [name  rangeOfString: searchtext options: NSCaseInsensitiveSearch];
                if (range.location != NSNotFound) {
                    [searchArry addObject:city];
                }
                
            }
            break;
        }
        default:
            break;
    }
    
    
    searchActive = YES;
    
    [self.tableView reloadData];
}

- (IBAction)doSearchPush:(id)sender {
    NSString *searchtext = _searchBar.text;
    if ([searchtext isEqualToString:@""]) {
        searchActive = NO;
        [self.tableView reloadData];
        return;
    }
    
    if (searchArry == nil)
        searchArry = [[NSMutableArray alloc]init];
    else if (searchArry.count > 0)
        [searchArry removeAllObjects];
    
    for (POI *poi in locaitonArry) {
        NSString *name = poi.name;
        NSLog(@"sss  %@", name);
        NSRange range = [name  rangeOfString: searchtext options: NSCaseInsensitiveSearch];
        if (range.location != NSNotFound) {
            [searchArry addObject:poi];
        }
    }
    
    
    searchActive = YES;
    
    [self.tableView reloadData];
    //    [self performSearch];
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
//            if ([c.idCountry isEqualToString:editedUser.country_id])
//            {
//                selectedCountry = c;
//                [self loadStatesFromServer:c];
//            }
        }
    }
    
    NSSortDescriptor *sortDescriptor;
    sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name"
                                                 ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    
    
    arCountries = [[NSMutableArray alloc] initWithArray:[arTemp sortedArrayUsingDescriptors:sortDescriptors]];
    
//    for(Country * c in arCountries)
//    {
//        NSArray * arCallingCodes = [c getCallingCodes];
//        for(NSString * sCallingCode in arCallingCodes)
//        {
//            [arCountriesCallingCodes addObject:sCallingCode];
//        }
//    }
    
    bLoadingCountries = NO;
    
    [_tableView reloadData];
}

- (void) loadStatesFromServer {
    if (bLoadingStateRegions) return;
    if (_countries.count > cState) {
        Country *country = [_countries objectAtIndex:cState];
        [self loadStatesFromServer:country];
        cState++;
    } else {
        [_tableView reloadData];
    }
}

-(void) loadStatesFromServer:(Country *) country
{
    NSLog(@"Loading states info");
    bLoadingStateRegions = YES;
    NSArray * requestParameters = [[NSArray alloc] initWithObjects:country.idCountry, nil];
    [self stopActivityFeedback];
    [self startActivityFeedbackWithMessage:NSLocalizedString(@"_DOWNLOADING_ACTV_MSG_", nil)];

    // get all product categories
    [self performRestGet:GET_STATESOFCOUNTRY withParamaters:requestParameters];
    
}

-(void) getStatesFromServer:(NSArray *)mappingResult
{
    if (arRegions == nil)
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
//                if ([region.idStateRegion isEqualToString:editedUser.addressState_id])
//                {
//                    selectedRegion = region;
//                }
            }
        }
    }
    
    NSSortDescriptor *sortDescriptor;
    sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name"
                                                 ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    if (arRegions.count > 0) {
        NSMutableArray *tmpArry = [[NSMutableArray alloc]initWithArray:arRegions];
        [tmpArry addObjectsFromArray:arTemp];
        NSLog(@"tmp count --? %d", tmpArry.count);
        [arRegions removeAllObjects];
        arRegions = [[NSMutableArray alloc] initWithArray:[tmpArry sortedArrayUsingDescriptors:sortDescriptors]];
    } else {
        arRegions = [[NSMutableArray alloc] initWithArray:[arTemp sortedArrayUsingDescriptors:sortDescriptors]];
    }
    
    bLoadingStateRegions =NO;
    [self loadStatesFromServer];
}

- (void)loadCitiesFromServer {
    if (_countries.count <= 0) return;
    for (Country *country in _countries) {
        if (_states.count > 0) {
            for (StateRegion *state in _states) {
                [self stopActivityFeedback];
                [self startActivityFeedbackWithMessage:NSLocalizedString(@"_LOADING_CITIES_", nil)];
                [self loadCitiesFromServer:country andState:state skip:0 limit:50];
            }
        } else {
            [self stopActivityFeedback];
            [self startActivityFeedbackWithMessage:NSLocalizedString(@"_LOADING_CITIES_", nil)];
            [self loadCitiesFromServer:country andState:nil skip:0 limit:50];
        }
    }
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

- (void)loadCitiesFromServerWithString:(NSString*)filter  {
    if (_countries.count <= 0) return;
    for (Country *country in _countries) {
        if (_states.count > 0) {
            for (StateRegion *state in _states) {
                [self stopActivityFeedback];
                [self startActivityFeedbackWithMessage:NSLocalizedString(@"_LOADING_CITIES_", nil)];
                [self loadCitiesFromServerFiltering:filter Country:country andState:state];
            }
        } else {
            [self stopActivityFeedback];
            [self startActivityFeedbackWithMessage:NSLocalizedString(@"_LOADING_CITIES_", nil)];
            [self loadCitiesFromServerFiltering:filter Country:country andState:nil];
        }
    }
}

-(void) loadCitiesFromServerFiltering:(NSString *) filter Country:(Country *) country andState:(StateRegion *)state
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
        requestParameters = [[NSArray alloc] initWithObjects:country.idCountry,state.idStateRegion, [NSNumber numberWithInteger:iCurrentSkip], [NSNumber numberWithInteger:iCurrentLimit], sFilterCities, nil];
    }
    else if (stateSearching == nil)
    {
        requestParameters = [[NSArray alloc] initWithObjects:country.idCountry, [NSNumber numberWithInteger:iCurrentSkip], [NSNumber numberWithInteger:iCurrentLimit], sFilterCities, nil];
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
//            if ([c.idCity isEqualToString:editedUser.addressCity_id])
//            {
//                selectedCity = c;
//            }
        }
    }
    
    NSSortDescriptor *sortDescriptor;
    sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name"
                                                 ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    
    arCities = [[NSMutableArray alloc] initWithArray:[arTemp sortedArrayUsingDescriptors:sortDescriptors]];
    
    if (searchActive) {
        [searchArry addObjectsFromArray:arCities];
    }  else {
        unsigned long iNumOldElements = arAllCities.count;
        
        if (arAllCities == nil)
        {
            arAllCities = [[NSMutableArray alloc] init];
        }
        
        [arAllCities addObjectsFromArray:arCities];
    }
    
//    if (citiesFilter != nil)
//    {
//        NSMutableArray * objs = [[NSMutableArray alloc] init];
//        unsigned long iIdx = 0;
//        unsigned long iIdxSelected = -1;
//        for(City * c in arCities)
//        {
//            NSString * sObjet = c.name;
//            NSString * sState = @"";
//            if (selectedRegion == nil)
//                sState = [c getNameFullStates];
//            else
//                sState = [c getNameOFState];
//            
//            sObjet = [sObjet stringByAppendingFormat:@"_###_%@", sState];
//            
//            [objs addObject:sObjet];
//            
//            if (selectedCity != nil)
//            {
//                if ([c.idCity isEqualToString:selectedCity.idCity])
//                {
//                    iIdxSelected = iIdx + iNumOldElements;
//                }
//            }
//            iIdx++;
//        }
//        if (citiesFilter.bNewQuery)
//        {
//            [arElementsPickerView removeAllObjects];
//        }
//        
//        [citiesFilter.arElementsSelected removeAllObjects];
//        [citiesFilter.arElementsSelected addObject:[NSIndexPath indexPathForRow:iIdxSelected inSection:0]];
//        
//        [citiesFilter addElements:objs];
//        [arElementsPickerView addObjectsFromArray:objs];
//    }
    
    if ((arCities.count == 0) || (arCities.count < iCurrentLimit))
    {
        bMoreCities = NO;
    }
    
    _bLoadingCities = NO;
    [_tableView reloadData];
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

#pragma mark - UITableViewDelegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    FashionistaUserListViewCell* theCell = [tableView dequeueReusableCellWithIdentifier:@"userCell"];
    
    if (searchActive) {
        switch (_searchType) {
            case 0: //country
            {
                Country * c = [searchArry objectAtIndex:indexPath.row];
                theCell.userName.text = c.name;
                
                if ([selectedArry containsObject:c]) {
                    theCell.followingButton.hidden = NO;
                } else
                    theCell.followingButton.hidden = YES;
                break;
            }
            case 1: //state
            {
                StateRegion *state = [searchArry objectAtIndex:indexPath.row];
                theCell.userName.text = state.name;
                if ([selectedArry containsObject:state]) {
                    theCell.followingButton.hidden = NO;
                } else
                    theCell.followingButton.hidden = YES;
                break;
            }
            case 2: //cities
            {
                City *city = [searchArry objectAtIndex:indexPath.row];
                theCell.userName.text = city.name;
                if ([selectedArry containsObject:city]) {
                    theCell.followingButton.hidden = NO;
                } else
                    theCell.followingButton.hidden = YES;

                break;
            }
            default:
                break;
        }
    } else {
        switch (_searchType) {
            case 0: //country
            {
                Country * c = [arCountries objectAtIndex:indexPath.row];
                theCell.userName.text = c.name;
                if ([selectedArry containsObject:c]) {
                    theCell.followingButton.hidden = NO;
                } else
                    theCell.followingButton.hidden = YES;

                break;
            }
            case 1: //state
            {
                StateRegion *state = [arRegions objectAtIndex:indexPath.row];
                theCell.userName.text = state.name;
                if ([selectedArry containsObject:state]) {
                    theCell.followingButton.hidden = NO;
                } else
                    theCell.followingButton.hidden = YES;
                break;
            }
            case 2: //cities
            {
                City *city = [arAllCities objectAtIndex:indexPath.row];
                theCell.userName.text = city.name;
                if ([selectedArry containsObject:city]) {
                    theCell.followingButton.hidden = NO;
                } else
                    theCell.followingButton.hidden = YES;
                break;
            }
            default:
                break;
        }
    }
    return theCell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (searchActive)
        return searchArry.count;
    
    int count = 0;
    switch (_searchType) {
        case 0: //country
            count = arCountries.count;
            break;
        case 1: //state
            count = arRegions.count;
            break;
        
        case 2: //cities
            count = arAllCities.count;
            break;
        default:
            break;
    }
    
    return count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    // Tweak for reusing superclass function
    // Hide Add Terms text field
    NSLog(@"select  %d", indexPath.row);
  
    if (searchActive) {
        switch (_searchType) {
            case 0: //country
            {
                Country * c = [searchArry objectAtIndex:indexPath.row];
                if (![selectedArry containsObject:c])
                    [selectedArry addObject:c];
                break;
            }
            case 1: //state
            {
                StateRegion *state = [searchArry objectAtIndex:indexPath.row];
                if (![selectedArry containsObject:state])
                    [selectedArry addObject:state];
                
                
                break;
            }
            case 2: //cities
            {
                City *city = [searchArry objectAtIndex:indexPath.row];
                if (![selectedArry containsObject:city])
                    [selectedArry addObject:city];
                
                break;
            }
            default:
                break;
        }
        return;
    }
    switch (_searchType) {
        case 0: //country
        {
            Country * c = [arCountries objectAtIndex:indexPath.row];
            if (![selectedArry containsObject:c])
                [selectedArry addObject:c];
            break;
        }
        case 1: //state
        {
            StateRegion *state = [arRegions objectAtIndex:indexPath.row];
            if (![selectedArry containsObject:state])
                [selectedArry addObject:state];

            
            break;
        }
        case 2: //cities
        {
            City *city = [arAllCities objectAtIndex:indexPath.row];
            if (![selectedArry containsObject:city])
                [selectedArry addObject:city];
            
            break;
        }
        default:
            break;
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"deselect  %d", indexPath.row);

    if (searchActive) {
        switch (_searchType) {
            case 0: //country
            {
                Country * c = [searchArry objectAtIndex:indexPath.row];
                if ([selectedArry containsObject:c]) {
                    [selectedArry removeObject:c];
                }
                break;
            }
            case 1: //state
            {
                StateRegion *state = [searchArry objectAtIndex:indexPath.row];
                if ([selectedArry containsObject:state]) {
                    [selectedArry removeObject:state];
                }
                
                break;
            }
            case 2: //cities
            {
                City *city = [searchArry objectAtIndex:indexPath.row];
                if ([selectedArry containsObject:city]) {
                    [selectedArry removeObject:city];
                }
                
                break;
            }
            default:
                break;
        }
        return;
    }
    switch (_searchType) {
        case 0: //country
        {
            Country * c = [arCountries objectAtIndex:indexPath.row];
            if ([selectedArry containsObject:c]) {
                [selectedArry removeObject:c];
            }
            break;
        }
        case 1: //state
        {
            StateRegion *state = [arRegions objectAtIndex:indexPath.row];
            if ([selectedArry containsObject:state]) {
                [selectedArry removeObject:state];
            }
            
            break;
        }
        case 2: //cities
        {
            City *city = [arAllCities objectAtIndex:indexPath.row];
            if ([selectedArry containsObject:city]) {
                [selectedArry removeObject:city];
            }
            
            break;
        }
        default:
            break;
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    // Do whatever you like to respond to text changes here.
    NSString *searchtext = _searchBar.text;
    if ([searchtext isEqualToString:@""]) {
        searchActive = NO;
        [self.tableView reloadData];
        return NO;
    }
    
    if (searchArry == nil)
        searchArry = [[NSMutableArray alloc]init];
    else if (searchArry.count > 0)
        [searchArry removeAllObjects];
    
    switch (_searchType) {
        case 0: //country
        {
            for (Country *count in arCountries) {
                NSString *name = count.name;
                NSLog(@"sss  %@", name);
                NSRange range = [name  rangeOfString: searchtext options: NSCaseInsensitiveSearch];
                if (range.location != NSNotFound) {
                    [searchArry addObject:count];
                }
                
            }
            break;
        }
        case 1: //state
        {
            for (StateRegion *state in arRegions) {
                NSString *name = state.name;
                NSLog(@"sss  %@", name);
                NSRange range = [name  rangeOfString: searchtext options: NSCaseInsensitiveSearch];
                if (range.location != NSNotFound) {
                    [searchArry addObject:state];
                }
                
            }
            
            break;
        }
        case 2: //cities
        {
            [self loadCitiesFromServerWithString:searchtext];
//            for (City *city in arAllCities) {
//                NSString *name = city.name;
//                NSLog(@"sss  %@", name);
//                NSRange range = [name  rangeOfString: searchtext options: NSCaseInsensitiveSearch];
//                if (range.location != NSNotFound) {
//                    [searchArry addObject:city];
//                }
//                
//            }
            break;
        }
        default:
            break;
    }
    
    
    searchActive = YES;
    
    [self.tableView reloadData];
    
    return YES;
}

- (void)performSearch
{
    [self.view endEditing:YES];
    [self resetSearch];
    [self performSearchWithString:self.searchBar.text];
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
    [self stopActivityFeedback];
    [self startActivityFeedbackWithMessage:NSLocalizedString(@"_DOWNLOADING_ACTV_MSG_", nil)];
    switch (_searchType) {
        case 0: //country
            [self loadCountriesFromServer];
            break;
        case 1: //state
            [self loadStatesFromServer];
            break;
        case 2: //city
            [self loadCitiesFromServer];
            break;
        default:
            break;
    }
}

- (void)viewWillDisappear:(BOOL)animated {
   [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void) loadCountriesFromServer
{
    NSLog(@"Loading all countries info");
    
    // get all product categories
    [self performRestGet:GET_ALLCOUNTRIES withParamaters:nil];
    bLoadingCountries = YES;

}
@end

