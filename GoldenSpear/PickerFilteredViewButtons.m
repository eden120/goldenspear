//
//  PickerFilteredViewButtons.m
//  GoldenSpear
//
//  Created by Alberto Seco on 4/11/15.
//  Copyright © 2015 GoldenSpear. All rights reserved.
//
#import "PickerFilteredViewButtons.h"

#define kHeightButtons 40
#define kHeightViewSeparator 0
#define kHeightSeparatorBetweenButtons 5
#define kMarginLaterals 10
#define kDefaultFontSize 15

#define kOffsetToRefreshSearch -(self.frame.size.height*0.42)

@implementation PickerFilteredViewButtons
{
    UIView * viewSeparator;
    UIFont * fontDefault;
    //int iIdxSelected;
    NSString * filterCities;
    NSString * tempFilterCities;
}

-(void) initPickerFilteredViewButtons
{
    tempFilterCities = @"";
    filterCities = @"";
    _bNewQuery = NO;
    
    _fixedElements = YES;

    fontDefault = [UIFont boldSystemFontOfSize:kDefaultFontSize];
    UIColor * colorBlue = [UIColor colorWithRed:79/255.0 green:163/255.0 blue:255/255.0 alpha:1];
    [self setBackgroundColor:[UIColor whiteColor]];
    

    _searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0.0, 0.0, self.frame.size.width, kHeightButtons)];
    _searchBar.delegate = self;
    [self addSubview:_searchBar];
    
    //    self.backgroundColor = [UIColor whiteColor];
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0, kHeightButtons + kHeightSeparatorBetweenButtons, self.frame.size.width, self.frame.size.height-(((kHeightButtons + kHeightSeparatorBetweenButtons)*3)+kHeightViewSeparator))];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.backgroundColor = [UIColor clearColor];
    [self addSubview:_tableView];
    
    viewSeparator = [[UIView alloc] initWithFrame:CGRectMake(0.0, self.frame.size.height - (((kHeightButtons + kHeightSeparatorBetweenButtons)*2)+kHeightViewSeparator), self.frame.size.width, kHeightViewSeparator)];
    [viewSeparator setBackgroundColor:[UIColor blackColor]];
    [self addSubview:viewSeparator];
    
    _btnOk =  [UIButton buttonWithType:UIButtonTypeSystem];
    [_btnOk.titleLabel setFont:fontDefault];
    [_btnOk setTitle:NSLocalizedString(@"_OK_",nil).uppercaseString forState:UIControlStateNormal];
    [_btnOk setTitleColor:colorBlue forState:UIControlStateNormal];
    [_btnOk setBackgroundColor:[UIColor whiteColor]];
    _btnOk.layer.cornerRadius = 6.0;
    _btnOk.layer.borderWidth = 1.0;
    _btnOk.layer.borderColor = [UIColor whiteColor].CGColor;
    _btnOk.clipsToBounds = YES;
    [self addSubview:_btnOk];
    
    _btnCancel = [UIButton buttonWithType:UIButtonTypeSystem];
    [_btnCancel.titleLabel setFont:fontDefault];
    [_btnCancel setTitle:NSLocalizedString(@"_CANCEL_",nil).uppercaseString forState:UIControlStateNormal];
    [_btnCancel setTitleColor:colorBlue forState:UIControlStateNormal];
    [_btnCancel setBackgroundColor:[UIColor whiteColor]];
    _btnCancel.layer.cornerRadius = 6.0;
    _btnCancel.layer.borderWidth = 1.0;
    _btnCancel.layer.borderColor = [UIColor whiteColor].CGColor;
    _btnCancel.clipsToBounds = YES;
    [self addSubview:_btnCancel];
    
    // add event to the button
    [_btnOk addTarget:self action:@selector(btnOkClick:) forControlEvents:UIControlEventTouchUpInside];
    [_btnCancel addTarget:self action:@selector(btnCancelClick:) forControlEvents:UIControlEventTouchUpInside];
    
    //    iIdxSelected = -1;
    
    //    _pickerView.dataSource = self;
    //    _pickerView.delegate = self;
    //    [_pickerView.dataSource addTarget:self action:@selector(updateDate:) forControlEvents:UIControlEventValueChanged];
    
}

- (id)initWithFrame:(CGRect)frame
{
    NSLog(@"(X:%f y:%f) (width:%f height:%f) ", frame.origin.x, frame.origin.y, frame.size.width, frame.size.height);
    
    self = [super initWithFrame:frame];
    if (self) {
        [self initPickerFilteredViewButtons];
        [self updateFrame:frame];
    }
    
    return self;
}

// View controller can add the view via XIB
- (id)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super initWithCoder:aDecoder]))
    {
        [self initPickerFilteredViewButtons];
    }
    return self;
}

-(void) updateFrame:(CGRect) frame
{
    float fPosY = 5.0;
    
    NSLog(@"(X:%f y:%f) (width:%f height:%f) ", frame.origin.x, frame.origin.y, frame.size.width, frame.size.height);

    [self setFrame:frame];
    
    float fHeightTableView = (self.frame.size.height-(((kHeightButtons + kHeightSeparatorBetweenButtons)*3)+kHeightViewSeparator)-fPosY);

    CGRect frameSearch = frame;
    frameSearch.origin.x = 0;
    frameSearch.origin.y = fPosY;
    frameSearch.size.height = kHeightButtons;
    [_searchBar setFrame:frameSearch];
    fPosY += kHeightButtons + kHeightSeparatorBetweenButtons;
    
    CGRect frameDatePicker = frame;
    frameDatePicker.origin.x = 0;
    frameDatePicker.origin.y = fPosY;
    frameDatePicker.size.height = fHeightTableView;
    [_tableView setFrame:frameDatePicker];
    fPosY += fHeightTableView + kHeightSeparatorBetweenButtons;
    
    if (kHeightViewSeparator > 0)
    {
        CGRect frameSeparator = frame;
        frameSeparator.origin.y = fPosY;
        frameSeparator.size.height = kHeightViewSeparator;
        [viewSeparator setFrame:frameSeparator];
        fPosY += kHeightViewSeparator + kHeightSeparatorBetweenButtons;
    }
    
    CGRect frameButtons = frame;
    frameButtons.size.width -= (kMarginLaterals * 2);
    //frameButtons.size.width /= 2;
    frameButtons.origin.x = kMarginLaterals;
    frameButtons.size.height = kHeightButtons;
    frameButtons.origin.y = fPosY;
    [_btnCancel setFrame:frameButtons];
    fPosY += kHeightButtons + kHeightSeparatorBetweenButtons;
    
    frameButtons.origin.y = fPosY;
    //    frameButtons.origin.x = frameButtons.size.width;
    [_btnOk setFrame:frameButtons];
    fPosY += kHeightButtons + kHeightSeparatorBetweenButtons;
    
    self.arElements = [[NSMutableArray alloc] init];
    self.arElementsSelected = [[NSMutableArray alloc] init];
    
}

-(void) setElements: (NSMutableArray *) elements
{
    if (self.arElements != nil)
    {
        [self.arElements removeAllObjects];
    }
    if (elements == nil)
    {
        self.arElements = [[NSMutableArray alloc] init];
    }
    else{
        self.arElements = [[NSMutableArray alloc] initWithArray:elements];
    }
    
    if (self.filteredElements != nil)
    {
        [self.filteredElements removeAllObjects];
    }
    else
    {
        self.filteredElements = [[NSMutableArray alloc] initWithArray:elements];
    }
    
    [self.tableView reloadData];
}
-(void) addElements:(NSMutableArray *) elements
{
    if (self.arElements == nil)
    {
        self.arElements = [[NSMutableArray alloc] initWithArray:elements];
    }
    else
    {
        if (_bNewQuery)
        {
            [self.arElements removeAllObjects];
        }
        
        [self.arElements addObjectsFromArray:elements];
    }
    
    if (self.filteredElements == nil)
    {
        self.filteredElements = [[NSMutableArray alloc] initWithArray:elements];
    }
    else
    {
        if (_bNewQuery)
        {
            [self.filteredElements removeAllObjects];
        }
        [self.filteredElements addObjectsFromArray:elements];
    }
    
    [self.tableView reloadData];
    
    _bNewQuery = NO;
    
}

-(void) setElementsSelected: (NSMutableArray *) elements
{
    if (self.arElementsSelected != nil)
    {
        [self.arElementsSelected removeAllObjects];
    }
    if (elements == nil)
    {
        self.arElementsSelected = [[NSMutableArray alloc] init];
    }
    else{
        self.arElementsSelected = [[NSMutableArray alloc] initWithArray:elements];
    }
    [self.tableView reloadData];
}

- (IBAction)btnOkClick: (id)sender
{
    [self.delegate pickerFilteredButtonView:self didButtonClick:YES withSelected:_arElementsSelected]; //[[NSArray alloc] initWithArray:arSelected ]];
    [self removeFromSuperview];
}

- (IBAction)btnCancelClick: (id)sender
{
    [self.delegate pickerFilteredButtonView:self didButtonClick:NO withSelected:nil]; //[[NSArray alloc] initWithArray:arSelected ]];
    [self removeFromSuperview];
}

//- (void)pickerView:(UIPickerView *)pickerView didSelectRow: (NSInteger)row inComponent:(NSInteger)component {
////    iIdxSelected = (int)row;
//    [self.delegate pickerButtonView:self changeSelected:(int)row];
//}

// tell the picker how many rows are available for a given component
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.filteredElements.count;
}

// tell the picker how many components it will have
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

// tell the picker the title for a given component
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *title;
    NSIndexPath * idxCountry = [self getElement:indexPath];
    
    title = [self.arElements objectAtIndex:idxCountry.row];

    NSArray* strings = [title componentsSeparatedByString: @"_###_"];
    NSString * subtitle = @"";
    if (strings.count > 1)
    {
        title = [strings objectAtIndex:0];
        subtitle = [strings objectAtIndex:1];
    }
    
    static NSString *simpleTableIdentifier = @"SimpleTableItem";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil) {
        if (strings.count > 1)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:simpleTableIdentifier];
        }
        else
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
            
        }
    }
    cell.backgroundColor = [UIColor clearColor];
    cell.textLabel.text = title;
    cell.detailTextLabel.text = subtitle;
    
    if([_arElementsSelected containsObject:idxCountry])
    {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else
    {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)theTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [theTableView cellForRowAtIndexPath:indexPath];
    NSIndexPath * indexCountry = [self getElement:indexPath];
    
    if(cell.accessoryType == UITableViewCellAccessoryNone) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        // get index total
        
        if (indexCountry != nil)
        {
            if (self.multiSelect == NO)
            {
                [_arElementsSelected removeAllObjects];
            }
//            NSIndexPath *indexSelected = [NSIndexPath indexPathForRow:iIdxCountry inSection:0];
            [_arElementsSelected addObject:indexCountry];
        }
        
    }
    else {
        cell.accessoryType = UITableViewCellAccessoryNone;
        if (indexCountry != nil)
        {
//            NSIndexPath *indexSelected = [NSIndexPath indexPathForRow:iIdxCountry inSection:0];
            [_arElementsSelected removeObject:indexCountry];
        }
    }
    [theTableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [theTableView reloadData];
    
    [_searchBar resignFirstResponder];
    
    [self.delegate pickerFilteredButtonView:self changeSelection:_arElementsSelected]; //[[NSArray alloc] initWithArray:arSelected ]];
    
}

-(NSIndexPath *) getElement:(NSIndexPath *)indexPath
{
    if (_fixedElements)
    {
        NSIndexPath *indexSelected = nil;
        NSString * elementToSelect = [_filteredElements objectAtIndex:indexPath.row];
        int iIdxElement = 0;
        BOOL bFound = NO;
        for(NSString * element in _arElements)
        {
            if ([element isEqualToString:elementToSelect] == YES)
            {
                bFound = YES;
                break;
            }
            iIdxElement++;
        }
        
        if (bFound)
            indexSelected = [NSIndexPath indexPathForRow:iIdxElement inSection:0];
        
        return indexSelected;
    }
    else
    {
        return indexPath;
    }
}

#pragma mark Content Filtering
-(void) searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    tempFilterCities = searchText;
    
    if (_fixedElements)
    {
        [self.filteredElements removeAllObjects];
        if ([searchText isEqualToString:@""])
        {
            [self.filteredElements addObjectsFromArray:self.arElements];
        }
        else
        {
            // Filter the array using NSPredicate
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF contains[c] %@",searchText];
            self.filteredElements = [NSMutableArray arrayWithArray:[self.arElements filteredArrayUsingPredicate:predicate]];
        }
        
        [_tableView reloadData];
    }
    
    if ([searchText isEqualToString:@""])
    {
        [self performSelector:@selector(hideKeyboardWithSearchBar:) withObject:searchBar afterDelay:0];
        
        //       [searchBar resignFirstResponder];
    }
}

- (void)hideKeyboardWithSearchBar:(UISearchBar *)searchBar
{
    NSLog(@"Hide keyboard");
    if (_fixedElements == NO)
    {
        if ([tempFilterCities isEqualToString:filterCities] == NO)
        {
            _bNewQuery = YES;
            
            filterCities = tempFilterCities;
            [_ctrlBase loadCitiesFromServerFiltering:filterCities];
        }
    }
    [searchBar resignFirstResponder];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    NSLog(@"Click Search");
    if (_fixedElements == NO)
    {
        if ([tempFilterCities isEqualToString:filterCities] == NO)
        {
            _bNewQuery = YES;
            
            filterCities = tempFilterCities;
            [_ctrlBase loadCitiesFromServerFiltering:filterCities];
            
        }
    }
    [searchBar resignFirstResponder];
}

#pragma mark - Query
// Check if arrived to the end of the collection view and, if so, request more results
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGPoint offset = scrollView.contentOffset;
    CGRect bounds = scrollView.bounds;
    CGSize size = scrollView.contentSize;
    UIEdgeInsets inset = scrollView.contentInset;
    float y = offset.y + bounds.size.height - inset.bottom;
    float h = size.height;
    // NSLog(@"offset: %f", offset.y);
    // NSLog(@"content.height: %f", size.height);
    // NSLog(@"bounds.height: %f", bounds.size.height);
    // NSLog(@"inset.top: %f", inset.top);
    // NSLog(@"inset.bottom: %f", inset.bottom);
    // NSLog(@"pos: %f of %f", y, h);
    
    float reload_distance = 10;
    if((y > h + reload_distance) && (scrollView.isDragging)){
        if(!_ctrlBase.bLoadingCities)
        {
            [_ctrlBase loadNextCitiesFromServer];
        }
    }
}


@end
