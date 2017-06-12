//
//  GSAccountDetailViewController.m
//  GoldenSpear
//
//  Created by Adria Vernetta Rubio on 18/5/16.
//  Copyright © 2016 GoldenSpear. All rights reserved.
//

#import "GSAccountDetailViewController.h"
#import "BaseViewController+TopBarManagement.h"
#import "GSAccountCreatorManager.h"
#import "GSAccountModuleView.h"
#import "GSSocialAccountModuleView.h"
#import "GSSwitchAccountModuleView.h"
#import "GSTextAccountModuleView.h"
#import "GSVerificationAccountModuleView.h"


@interface GSAccountDetailViewController (){
    GSAccountType* currentAccountType;
    UIView* previousView;
    GSImageAccountModuleView* currentlyUploading;
    BOOL alreadyLoaded;
    GSAccountDetailModalMode modalMode;
    GSAccountModuleView* editingModule;
    UITextField* textFieldEditing;
    NSMutableArray * arElementsPickerView;
    NSInteger iIdxElementSelectedInPickerView;
    NSInteger iIdxOldElementSelectedInPickerView;
    
    CGFloat keyboardHeight;
}

@end

#define kGrayBackground [UIColor colorWithRed:(184.0/255.0) green:(184.0/255.0) blue:(184.0/255.0) alpha:1.0]

@implementation GSAccountDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.moduleContainer.translatesAutoresizingMaskIntoConstraints = NO;
    
    for (UIView* v in self.modalViews) {
        v.layer.masksToBounds = YES;
        v.layer.borderWidth = 2;
        v.layer.borderColor = [kGrayBackground CGColor];
    }
    keyboardHeight = 0;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidChangeFrameWithNotification:) name:UIKeyboardWillChangeFrameNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShowNotification:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHideNotification:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)setAutoLayoutForView:(UIView*)theView{
    //Leading
    NSLayoutConstraint* aConstraint = [NSLayoutConstraint constraintWithItem:theView.superview
                                                                   attribute:NSLayoutAttributeLeading
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:theView
                                                                   attribute:NSLayoutAttributeLeading
                                                                  multiplier:1
                                                                    constant:0];
    [theView.superview addConstraint:aConstraint];
    
    //Trailing
    aConstraint = [NSLayoutConstraint constraintWithItem:theView.superview
                                               attribute:NSLayoutAttributeTrailing
                                               relatedBy:NSLayoutRelationEqual
                                                  toItem:theView
                                               attribute:NSLayoutAttributeTrailing
                                              multiplier:1
                                                constant:0];
    [theView.superview addConstraint:aConstraint];
    
    //Height
    aConstraint = [NSLayoutConstraint constraintWithItem:theView
                                               attribute:NSLayoutAttributeHeight
                                               relatedBy:NSLayoutRelationEqual
                                                  toItem:nil
                                               attribute:NSLayoutAttributeNotAnAttribute
                                              multiplier:1
                                                constant:theView.frame.size.height];
    [theView.superview addConstraint:aConstraint];
    
    if([theView isKindOfClass:[GSAccountModuleVaryingHeightView class]]){
        ((GSAccountModuleVaryingHeightView*)theView).moduleHeightConstraint = aConstraint;
    }
    
    //Top
    if(previousView){
        aConstraint = [NSLayoutConstraint constraintWithItem:previousView
                                                   attribute:NSLayoutAttributeBottom
                                                   relatedBy:NSLayoutRelationEqual
                                                      toItem:theView
                                                   attribute:NSLayoutAttributeTop
                                                  multiplier:1
                                                    constant:0];
    }else{
        aConstraint = [NSLayoutConstraint constraintWithItem:theView.superview
                                                   attribute:NSLayoutAttributeTop
                                                   relatedBy:NSLayoutRelationEqual
                                                      toItem:theView
                                                   attribute:NSLayoutAttributeTop
                                                  multiplier:1
                                                    constant:-10];
    }
    [theView.superview addConstraint:aConstraint];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    // Do any additional setup after loading the view.
    currentAccountType = [[GSAccountCreatorManager sharedManager] getAccountTypeWithId:self.editingUser.typeprofessionId];
    [self setTopBarTitle:[currentAccountType.appName uppercaseString] andSubtitle:nil];
    //Create needed modules
    if(!alreadyLoaded){
        CGFloat totalHeight = 0;
        for (GSAccountModule* module in currentAccountType.modules) {
            GSAccountModuleView* moduleView = [self getModuleViewWithModule:module];
            totalHeight += moduleView.frame.size.height;
            previousView = moduleView;
        }
        self.containterHeightConstraint.constant = totalHeight;
        [self.moduleContainer.superview layoutIfNeeded];
        alreadyLoaded = YES;
    }
}

- (GSAccountModuleView*)getModuleViewWithModule:(GSAccountModule*)module{
    GSAccountModuleView* theModule = nil;
    switch (module.moduleType) {
        case GSAccountModuleAgency:
            theModule = [GSAgencyAccountModuleView new];
            ((GSAgencyAccountModuleView*)theModule).agencyDelegate = self;
            break;
        case GSAccountModuleImage:
            theModule = [GSImageAccountModuleView new];
            ((GSImageAccountModuleView*)theModule).imageDelegate = self;
            break;
        case GSAccountModuleModel:
            theModule = [GSModelAccountModuleView new];
            ((GSModelAccountModuleView*)theModule).modelDelegate = self;
            break;
        case GSAccountModuleSocial:
            theModule = [GSSocialAccountModuleView new];
            break;
        case GSAccountModuleSwitch:
            theModule = [GSSwitchAccountModuleView new];
            break;
        case GSAccountModuleText:
            theModule = [GSTextAccountModuleView new];
            break;
        case GSAccountModuleVerification:
            theModule = [GSVerificationAccountModuleView new];
            break;
        default:
            break;
    }
    theModule.delegate = self;
    [self.moduleContainer addSubview:theModule];
    [self setAutoLayoutForView:theModule];
    [theModule fillModule:self.editingUser withAccountModule:module];
    return theModule;
}

- (BOOL)shouldCenterTitle{
    return YES;
}

- (BOOL)shouldCreateMenuButton{
    return NO;
}


- (IBAction)saveData:(id)sender {
    [self.accountDelegate commitSave];
}

- (void)module:(GSAccountModuleView *)module increasedItsSize:(CGFloat)variation{
    self.containterHeightConstraint.constant += variation;
    [self.view layoutIfNeeded];
}

- (void)uploadImageOnImageAccountModule:(GSImageAccountModuleView *)imageModule{
    if ([UIStoryboard storyboardWithName:@"BasicScreens" bundle:nil] != nil)
    {
        CustomCameraViewController *imagePicker = nil;
        
        @try {
            
            imagePicker = [[UIStoryboard storyboardWithName:@"BasicScreens" bundle:nil] instantiateViewControllerWithIdentifier:[@(CUSTOMCAMERA_VC) stringValue]];
            
        }
        @catch (NSException *exception) {
            
            return;
            
        }
        
        if (imagePicker != nil)
        {
            imagePicker.delegate = self;
            
            [self presentViewController:imagePicker animated:YES completion:nil];
            
            [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
        }
        currentlyUploading = imageModule;
    }
}

- (void)imagePickerController:(CustomCameraViewController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *chosenImage = [info objectForKey:@"data"];
    User* theUser = self.editingUser;
    
    UIImage * finalProfilePic = [[chosenImage fixOrientation] scaleToSizeKeepAspect:CGSizeMake(600, 600)];
    theUser.picImage = finalProfilePic;
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    currentlyUploading.theImage.image = finalProfilePic;
    currentlyUploading = nil;
}

// In case user cancels changing image
- (void) imagePickerControllerDidCancel:(CustomCameraViewController *)picker
{
    currentlyUploading = nil;
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)showModalView:(BOOL)showOrNot{
    if (showOrNot) {
        self.modalViewShow.hidden = NO;
        [self.modalViewShow.superview bringSubviewToFront:self.modalViewShow];
    }else{
        self.modalViewShow.hidden = YES;
        [self.modalViewShow.superview sendSubviewToBack:self.modalViewShow];
    }
}

- (void)setUserData{
    NSInteger commonFieldsTag = (modalMode==GSAccountDetailModalModeModelMale?0:1);
    
    User* theUser = self.editingUser;
    
    for (UITextField* f in self.heightFields) {
        if (f.tag == commonFieldsTag) {
            NSInteger height = [f.text integerValue];
            theUser.heightM = [NSNumber numberWithInteger:height/100];
            theUser.heightCm = [NSNumber numberWithInteger:height%100];
        }
    }
    for (UITextField* f in self.hairColorFields) {
        if (f.tag == commonFieldsTag) {
            theUser.haircolor = [NSNumber numberWithInteger:f.tag];
        }
    }
    for (UITextField* f in self.eyeColorFields) {
        if (f.tag == commonFieldsTag) {
            theUser.eyecolor = [NSNumber numberWithInteger:f.tag];
        }
    }
    for (UITextField* f in self.waistFields) {
        if (f.tag == commonFieldsTag) {
            theUser.waist = [NSNumber numberWithInteger:[f.text integerValue]];
        }
        f.text = [theUser.waist stringValue];
    }
    for (UITextField* f in self.shoeFields) {
        if (f.tag == commonFieldsTag) {
            theUser.shoe = [NSNumber numberWithInteger:f.tag];
        }
    }
    switch (modalMode) {
        case GSAccountDetailModalModeModelMale:
            theUser.bust = [NSNumber numberWithInteger:self.shirtField.tag];
            break;
        case GSAccountDetailModalModeModelFemale:
            theUser.bust = [NSNumber numberWithInteger:self.bustField.tag];
            break;
        default:
            break;
    }
    
    theUser.hip = [NSNumber numberWithInteger:[self.hipsField.text integerValue]];
    theUser.dress = [NSNumber numberWithInteger:self.suitSizeField.tag];
    theUser.insteam = [NSNumber numberWithInteger:[self.inseamField.text integerValue]];
}

- (IBAction)closeModal:(id)sender {
    [self.view endEditing:YES];
    [self showModalView:NO];
    switch (modalMode) {
        case GSAccountDetailModalModeAgency:
        {
            self.agencyView.hidden = YES;
            NSMutableArray* gatheredData = [NSMutableArray new];
            for (UITextField* f in self.agencyFields) {
                [gatheredData addObject:f.text];
            }
            [(GSAgencyAccountModuleView*)editingModule setAgencyDataForEditingField:gatheredData];
        }
            break;
        case GSAccountDetailModalModeModelFemale:
        {
            self.femaleModelView.hidden = YES;
            [self setUserData];
        }
            break;
        case GSAccountDetailModalModeModelMale:
        {
            self.maleModelView.hidden = YES;
            [self setUserData];
        }
            break;
        default:
            break;
    }
    editingModule = nil;
    modalMode = GSAccountDetailModalModeNone;
}

- (void)modelViewPushed:(GSModelAccountModuleView *)module withOption:(GSModelAccountOption)modelOption{
    switch (modelOption) {
        case GSModelAccountOptionFemale:
            modalMode = GSAccountDetailModalModeModelFemale;
            [self.femaleModelView.superview bringSubviewToFront:self.femaleModelView];
            self.femaleModelView.hidden = NO;
            break;
        case GSModelAccountOptionMale:
            modalMode = GSAccountDetailModalModeModelMale;
            [self.maleModelView.superview bringSubviewToFront:self.maleModelView];
            self.maleModelView.hidden = NO;
            break;
    }
    
    AppDelegate* appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    User* theUser = self.editingUser;
    
    for (UITextField* f in self.heightFields) {
        f.text = [NSString stringWithFormat:@"%d%d",[theUser.heightM intValue],[theUser.heightCm intValue]];
    }
    for (UITextField* f in self.hairColorFields) {
        NSArray * objs = [appDelegate.config valueForKey:@"haircolor_types"];
        f.text = [objs objectAtIndex:[theUser.haircolor intValue]];
        f.tag = [theUser.haircolor intValue];
    }
    for (UITextField* f in self.eyeColorFields) {
        NSArray * objs = [appDelegate.config valueForKey:@"eyecolor_types"];
        f.text = [objs objectAtIndex:[theUser.eyecolor intValue]];
        f.tag = [theUser.eyecolor intValue];
    }
    for (UITextField* f in self.waistFields) {
        f.text = [theUser.waist stringValue];
    }
    for (UITextField* f in self.shoeFields) {
        NSArray * objs = [appDelegate.config valueForKey:@"shoe_types"];
        f.text = [objs objectAtIndex:[theUser.shoe intValue]];
        f.tag = [theUser.shoe intValue];
    }
    
    NSArray * objs = [appDelegate.config valueForKey:@"cup_types"];
    self.bustField.text = [objs objectAtIndex:[theUser.bust intValue]];
    self.bustField.tag = [theUser.bust integerValue];
    self.hipsField.text = [theUser.hip stringValue];
    
    objs = [appDelegate.config valueForKey:@"dress_types"];
    self.suitSizeField.text = [objs objectAtIndex:[theUser.dress intValue]];
    self.suitSizeField.tag = [theUser.dress integerValue];
    self.shirtField.text = [objs objectAtIndex:[theUser.bust intValue]];
    self.shirtField.tag = [theUser.bust integerValue];
    
    self.inseamField.text = [theUser.insteam stringValue];
    
    editingModule = module;
    [self showModalView:YES];
}

- (void)agencyViewPushed:(GSAgencyAccountModuleView *)module withData:(NSArray *)agencyData andPosition:(CGPoint)position{
    for(int i=0;i<[self.agencyFields count];i++){
        UITextField* theField = [self.agencyFields objectAtIndex:i];
        NSString* text = @"";
        if (i<[agencyData count]) {
            text = [agencyData objectAtIndex:i];
        }
        theField.text = text;
    }
    editingModule = module;
    modalMode = GSAccountDetailModalModeAgency;
    [self.agencyView.superview bringSubviewToFront:self.agencyView];
    self.agencyView.hidden = NO;
    [self showModalView:YES];
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    [textField resignFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

- (IBAction)hairColorStartEdit:(UITextField *)sender {
    AppDelegate* appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    NSArray * objs = [appDelegate.config valueForKey:@"haircolor_types"];
    [self initPickerViewWithElements:objs forTextField:sender withElementSelected:sender.tag];
}

- (IBAction)eyeColorStartEdit:(UITextField *)sender {
    AppDelegate* appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    NSArray * objs = [appDelegate.config valueForKey:@"eyecolor_types"];
    [self initPickerViewWithElements:objs forTextField:sender withElementSelected:sender.tag];
}

- (IBAction)suitSizeStartEdit:(UITextField *)sender {
    AppDelegate* appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    NSArray * objs = [appDelegate.config valueForKey:@"dress_types"];
    [self initPickerViewWithElements:objs forTextField:sender withElementSelected:sender.tag];
}

- (IBAction)shirtSizeStatEdit:(UITextField *)sender {
    AppDelegate* appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    NSArray * objs;
    if(modalMode==GSAccountDetailModalModeModelFemale){
        objs = [appDelegate.config valueForKey:@"cup_types"];
    }else{
        objs = [appDelegate.config valueForKey:@"dress_types"];
    }
    [self initPickerViewWithElements:objs forTextField:sender withElementSelected:sender.tag];
}

- (IBAction)showSizeStartEdit:(UITextField *)sender {
    AppDelegate* appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    NSArray * objs = [appDelegate.config valueForKey:@"shoe_types"];
    [self initPickerViewWithElements:objs forTextField:sender withElementSelected:sender.tag];
}

- (IBAction)cancelPushed:(id)sender {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:^{
        
    }];
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

#pragma mark - dynamic keyboard moving content

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
    self.scrollViewBottom.constant = MAX(height,0);
    [self.view layoutIfNeeded];
}

// Animate the Add Terms text box when keyboard appears
- (void)animateTextViewFrameForVerticalOffset:(CGFloat)offset
{
    CGFloat constant = self.scrollViewBottom.constant;
    CGFloat newConstant = constant + offset;// + 50;
    [self animateTextViewFrameForVerticalHeight:newConstant];
}

@end
