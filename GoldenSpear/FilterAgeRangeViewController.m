//
//  FilterAgeRangeViewController.m
//  GoldenSpear
//
//  Created by Crane on 9/21/16.
//  Copyright © 2016 GoldenSpear. All rights reserved.
//

#import "FilterAgeRangeViewController.h"
#import "LiveAddItemView.h"


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

@interface FilterAgeRangeViewController ()

@end

@implementation FilterAgeRangeViewController {
    UITextView *text_view;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.translatesAutoresizingMaskIntoConstraints = NO;
    
    LiveAddItemView *addView =
    [[[NSBundle mainBundle] loadNibNamed:@"LiveAddItemView" owner:self options:nil] objectAtIndex:0];
    addView.titleLab.text = NSLocalizedString(@"_LIVE_AGE_RANGE_", nil);
    addView.addBtn.hidden = YES;
    [addView.addBtn addTarget:self action:@selector(addAction:) forControlEvents:UIControlEventTouchUpInside];
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(textViewTapped:)];
    [addView.contentText addGestureRecognizer:gestureRecognizer];
    text_view = addView.contentText;
    
    
    addView.frame = _ageView.bounds;
    [_ageView addSubview:addView];
    
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
    [button addTarget:self action:@selector(btn_add_action:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *btn_SmartComments = [[UIBarButtonItem alloc] initWithCustomView:button];
    
    [btn_SmartComments setTintColor:[UIColor whiteColor]];
    
    NSArray *array = [NSArray arrayWithObjects:btn_QuickPhrase, flex, btn_SmartComments, nil];
    [toolbar setItems:array];
    
    _minAgeText.inputAccessoryView = toolbar;
    _maxAgeText.inputAccessoryView = toolbar;
    [_minAgeText becomeFirstResponder];
}
- (void)viewWillAppear:(BOOL)animated {
    [self setAgeView];
}

- (void)addAction:(UIButton*)button {
    
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

    NSDictionary *selectedDic;

    for (NSDictionary *dic in _ageArry) {
        NSString *str = [NSString stringWithFormat:@"%@ - %@", dic[@"MinAge"], dic[@"MaxAge"]];
        if ([str isEqualToString:allSelectedText]) {
            selectedDic = dic;
            break;
        }
    }
    
    if (selectedDic != nil) {
        [_ageArry removeObject:selectedDic];
        [self setAgeView];
    }
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
-(IBAction)btn_close:(id)sender
{
    [self.view endEditing:true];
}
-(IBAction)btn_add_action:(id)sender {
    NSString *minStr = _minAgeText.text;
    NSString *maxStr = _maxAgeText.text;
    if ([minStr isEqualToString:@""] && [maxStr isEqualToString:@""]) {
        return;
    }
    
    if (minStr == nil || [minStr isEqualToString:@""]) {
        minStr = @"0";
        _minAgeText.text = minStr;
    }
    if (maxStr == nil || [maxStr isEqualToString:@""]) {
        _maxAgeText.text = @"-";
    }
    if ( [minStr isEqualToString:@"0"] && [maxStr isEqualToString:@""]) {
        return;
    }
    if ( [minStr isEqualToString:@"0"] && [maxStr isEqualToString:@"-"]) {
        return;
    }
    if ([minStr integerValue] > [maxStr integerValue] && ![maxStr isEqualToString:@""]) {
        [self alertDlg];
        return;
    }
    NSDictionary *aDic= [NSDictionary dictionaryWithObjectsAndKeys:
                         minStr, @"MinAge",
                         maxStr, @"MaxAge",
                         nil];
    if (_ageArry == nil) {
        _ageArry = [[NSMutableArray alloc]init];
    }
    
    for (NSDictionary *dic in _ageArry) {
        NSString *min = dic[@"MinAge"];
        NSString *max = dic[@"MaxAge"];
        if ([min isEqualToString:minStr] && [max isEqualToString:maxStr]) {
            return;
        }
    }
    [_ageArry addObject:aDic];
    [self setAgeView];
}

- (void)alertDlg
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_ERROR_", nil) message:NSLocalizedString(@"_LIVE_AGE_VALUE_ERROR_", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"_OK_", nil) otherButtonTitles: nil];
    
    [alertView show];
    
    return;
}
- (void)setAgeView {
    
    NSString *ageStr = @"All";
    for (int i = 0; i < _ageArry.count; i++) {
        NSDictionary *dic = [_ageArry objectAtIndex:i];
        NSString *minStr = dic[@"MinAge"];
        NSString *maxStr = dic[@"MaxAge"];
        
        if (i == 0) {
            ageStr = [NSString stringWithFormat:@"%@ - %@", minStr, maxStr];
        } else {
            ageStr = [NSString stringWithFormat:@"%@ | %@ - %@", ageStr ,minStr, maxStr];
        }
    }
    
    text_view.text = ageStr;
    
    if ([self.filterAgeDelegate respondsToSelector:@selector(setAgeRange:type:)]) {
        [self.filterAgeDelegate setAgeRange:_ageArry type:_type];
    }

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
