//
//  PickerViewButtons.m
//  GoldenSpear
//
//  Created by Alberto Seco on 5/5/15.
//  Copyright (c) 2015 GoldenSpear. All rights reserved.
//

#import "PickerViewButtons.h"

#define kHeightButtons 40
#define kHeightPickerView 150
#define kHeightViewSeparator 0
#define kHeightSeparatorBetweenButtons 5
#define kMarginLaterals 10
#define kDefaultFontSize 15

@implementation PickerViewButtons
{
UIView * viewSeparator;
UIFont * fontDefault;
//int iIdxSelected;
}

-(void) initPickerViewButton
{
    fontDefault = [UIFont boldSystemFontOfSize:kDefaultFontSize];
    //fontDefault = [UIFont systemFontOfSize:kDefaultFontSize];
    
//    fontDefault = [UIFont fontWithName:@"System Bold" size:kDefaultFontSize];

//    self.backgroundColor = [UIColor whiteColor];
    _btnOk =  [UIButton buttonWithType:UIButtonTypeSystem];
    _btnCancel = [UIButton buttonWithType:UIButtonTypeSystem];
    _pickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.frame.size.width, kHeightPickerView)];
    _pickerView.delegate = self;
    
    UIColor * colorBlue = [UIColor colorWithRed:79/255.0 green:163/255.0 blue:255/255.0 alpha:1];
    
    [_btnOk.titleLabel setFont:fontDefault];
    [_btnOk setTitle:NSLocalizedString(@"_OK_",nil).uppercaseString forState:UIControlStateNormal];
    [_btnOk setTitleColor:colorBlue forState:UIControlStateNormal];
    [_btnOk setBackgroundColor:[UIColor whiteColor]];
    _btnOk.layer.cornerRadius = 6.0;
    _btnOk.layer.borderWidth = 1.0;
    _btnOk.layer.borderColor = [UIColor whiteColor].CGColor;
    _btnOk.clipsToBounds = YES;
    
    [_btnCancel.titleLabel setFont:fontDefault];
    [_btnCancel setTitle:NSLocalizedString(@"_CANCEL_",nil).uppercaseString forState:UIControlStateNormal];
    [_btnCancel setTitleColor:colorBlue forState:UIControlStateNormal];
    [_btnCancel setBackgroundColor:[UIColor whiteColor]];
    _btnCancel.layer.cornerRadius = 6.0;
    _btnCancel.layer.borderWidth = 1.0;
    _btnCancel.layer.borderColor = [UIColor whiteColor].CGColor;
    _btnCancel.clipsToBounds = YES;
    
    [self addSubview:_pickerView];
    
    viewSeparator = [[UIView alloc] initWithFrame:CGRectMake(0.0, kHeightPickerView, self.frame.size.width, kHeightViewSeparator)];
    [viewSeparator setBackgroundColor:[UIColor blackColor]];
    [self addSubview:viewSeparator];
    
    [self addSubview:_btnOk];
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
    
    self = [super initWithFrame:frame];
    if (self) {
        [self initPickerViewButton];
        [self updateFrame:frame];
    }
    
    return self;
}

// View controller can add the view via XIB
- (id)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super initWithCoder:aDecoder]))
    {
        [self initPickerViewButton];
    }
    return self;
}
/* FOR pickerView *****
// The number of columns of data
- (long)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

// The number of rows of data
- (long)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return _dataPicker.count;
}

// The data to return for the row and component (column) that's being passed in
- (NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return _dataPicker[row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow: (NSInteger)row inComponent:(NSInteger)component {
    // Handle the selection
    // get the index of the button in the array
    [self.delegate pickerButtonView:self didSelectRow:row inComponent:component];
}
*/

-(void) updateFrame:(CGRect) frame
{
    float fPosY = 0.0;
    CGRect frameDatePicker = frame;
    frameDatePicker.origin.x = 0;
    frameDatePicker.origin.y = fPosY;
    frameDatePicker.size.height = kHeightPickerView;
    [_pickerView setFrame:frameDatePicker];
    fPosY += kHeightPickerView + kHeightSeparatorBetweenButtons;
    
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
    
    CGRect frameView = frame;
    frameView.size.height =fPosY;
    frameView.origin.y = frame.size.height - frameView.size.height;
    self.frame = frameView;
}

-(void) setElements: (NSMutableArray *) elements
{
    self.arElements = [[NSArray alloc] initWithArray:elements];
    [self.pickerView reloadAllComponents];
}


- (IBAction)btnOkClick: (id)sender
{
    [self.delegate pickerButtonView:self didButtonClick:YES withindex:[self.pickerView selectedRowInComponent:0]];
}

- (IBAction)btnCancelClick: (id)sender
{
    [self.delegate pickerButtonView:self didButtonClick:NO withindex:[self.pickerView selectedRowInComponent:0]];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow: (NSInteger)row inComponent:(NSInteger)component {
//    iIdxSelected = (int)row;
    [self.delegate pickerButtonView:self changeSelected:(int)row];
}

// tell the picker how many rows are available for a given component
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return self.arElements.count;
}

// tell the picker how many components it will have
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

// tell the picker the title for a given component
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    NSString *title;
    title = [self.arElements objectAtIndex:row];
    return title;
}

// tell the picker the width of each row for a given component
- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
    int sectionWidth = 300;
    
    return sectionWidth;
}


@end
