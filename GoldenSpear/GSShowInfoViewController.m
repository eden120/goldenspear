//
//  GSShowInfoViewController.m
//  GoldenSpear
//
//  Created by Adria Vernetta Rubio on 8/5/16.
//  Copyright © 2016 GoldenSpear. All rights reserved.
//

#import "GSShowInfoViewController.h"
#import "BaseViewController+TopBarManagement.h"
#import "BaseViewController+ActivityFeedbackManagement.h"
#import "User+Manage.h"

#define kFontInLabelText @"Avenir-Light"
#define kFontInLabelBoldText @"Avenir-Heavy"
#define kFontSizeInLabelText 15
#define kLabelXMargin 20
#define kLabelYMargin 10

@interface GSShowInfoViewController (){
    BOOL alreadySetUp;
    BOOL loadingEthnicities;
    BOOL didAppear;
    NSMutableString* ethnicitiesString;
}

@end

@implementation GSShowInfoViewController

- (void)dealloc{
    ethnicitiesString = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.translatesAutoresizingMaskIntoConstraints = NO;
    [self hideTopBar];
    self.noInformationLabel.text = NSLocalizedString(@"_INFORMATION_PRIVATE_", nil);
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if(!alreadySetUp){
        loadingEthnicities = YES;
        [self startActivityFeedbackWithMessage:@""];
        
        [self getStylistEthnicities];
        
        [self stopActivityFeedback];
        loadingEthnicities = NO;
    }
}

- (void)processSelectedEtnicities:(NSArray*)ethnicities{
    User* current = [(AppDelegate*)[UIApplication sharedApplication].delegate currentUser];
    ethnicitiesString = [NSMutableString new];
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
    if(didAppear){
        [self setupInfoValues];
    }
}

- (void)getStylistEthnicities{
    NSString* userEthnicityUrl = [NSString stringWithFormat:@"%@/user_ethnicity?user=%@", RESTBASEURL, self.shownStylist.idUser];
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

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if (!alreadySetUp&&!loadingEthnicities) {
        [self setupInfoValues];
    }
    didAppear = YES;
}

- (UILabel*)getBasicLabelWithTitle:(NSString*)theString{
    UILabel* aLabel = [UILabel new];
    aLabel.font = [UIFont fontWithName:kFontInLabelText size:kFontSizeInLabelText];
    aLabel.numberOfLines = 0;
    aLabel.text = theString;
    [aLabel sizeToFit];
    [self.contentScroll addSubview:aLabel];
    return aLabel;
}

- (BOOL)isValidString:(NSString*)theString{
    return !(theString==nil||[theString isEqualToString:@""]);
}

- (CGRect)addNewLabelWithTitle:(NSString*)labelTitle atFrame:(CGRect)theFrame{
    CGSize constrainedSize = CGSizeMake(self.contentScroll.frame.size.width -2*kLabelXMargin, CGFLOAT_MAX);
    UILabel* infoLabel = [self getBasicLabelWithTitle:labelTitle];
    CGRect requiredHeight = [infoLabel.text boundingRectWithSize:constrainedSize
                                                         options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading
                                                      attributes:@{NSFontAttributeName:infoLabel.font}
                                                         context:nil];
    theFrame.size.height = ceilf(requiredHeight.size.height);
    infoLabel.frame = theFrame;
    theFrame.origin.y += theFrame.size.height+kLabelYMargin/2;
    return theFrame;
}

- (NSString*)processDate:(NSDate*)theDate
{
    return [NSDateFormatter localizedStringFromDate:theDate dateStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterNoStyle];
    
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"dd / MM / yy"];
    [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en"]];
    return [dateFormatter stringFromDate:theDate];
}

- (void)setupInfoValues{
    CGRect theFrame = CGRectMake(kLabelXMargin, kLabelYMargin, self.contentScroll.frame.size.width-2*kLabelXMargin, 0);
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    BOOL setSomeData = NO;
    if([self isValidString:self.shownStylist.tellusmore]){
        theFrame = [self addNewLabelWithTitle:[NSString stringWithFormat:@"Info: %@",self.shownStylist.tellusmore] atFrame:theFrame];
        setSomeData = YES;
    }
    if(self.shownStylist.birthdate&&[self.shownStylist.birthdateVisible boolValue]){
        theFrame = [self addNewLabelWithTitle:[NSString stringWithFormat:@"Birthday: %@",[self processDate:self.shownStylist.birthdate]] atFrame:theFrame];
        setSomeData = YES;
    }
    if(self.shownStylist.gender != nil&&[self.shownStylist.genderVisible boolValue]){
        NSArray * objs = [appDelegate.config valueForKey:@"gender_types"];
        theFrame = [self addNewLabelWithTitle:[NSString stringWithFormat:@"Gender: %@",[objs objectAtIndex:[self.shownStylist.gender integerValue]]] atFrame:theFrame];
        setSomeData = YES;
    }
    if([self isValidString:self.shownStylist.addressCity]&&[self.shownStylist.addressCityVisible boolValue]){
        theFrame = [self addNewLabelWithTitle:[NSString stringWithFormat:@"Hometown: %@",self.shownStylist.addressCity] atFrame:theFrame];
        setSomeData = YES;
    }
    if(self.shownStylist.relationship != nil&&[self.shownStylist.relationshipVisible boolValue]){
        NSArray * objs = [appDelegate.config valueForKey:@"relationship_types"];
        theFrame = [self addNewLabelWithTitle:[NSString stringWithFormat:@"Relationship: %@",[objs objectAtIndex:[self.shownStylist.relationship integerValue]]] atFrame:theFrame];
        setSomeData = YES;
    }
    if(self.shownStylist.genre != nil&&[self.shownStylist.genreVisible boolValue]){
        theFrame = [self addNewLabelWithTitle:[NSString stringWithFormat:@"Interested in: %@",[User sGetTextGenreFromString:self.shownStylist.genre]] atFrame:theFrame];
        setSomeData = YES;
    }
    if([self isValidString:self.shownStylist.politicalView]&&[self.shownStylist.politicalViewVisible boolValue]){
        theFrame = [self addNewLabelWithTitle:[NSString stringWithFormat:@"Political View: %@",self.shownStylist.politicalView] atFrame:theFrame];
        setSomeData = YES;
    }
    if([self isValidString:self.shownStylist.politicalParty]&&[self.shownStylist.politicalPartyVisible boolValue]){
        theFrame = [self addNewLabelWithTitle:[NSString stringWithFormat:@"Political Party: %@",self.shownStylist.politicalParty] atFrame:theFrame];
        setSomeData = YES;
    }
    if([self isValidString:self.shownStylist.religion]&&[self.shownStylist.religionVisible boolValue]){
        theFrame = [self addNewLabelWithTitle:[NSString stringWithFormat:@"Religion: %@",self.shownStylist.religion] atFrame:theFrame];
        setSomeData = YES;
    }
    if(self.shownStylist.ethnicity != nil&&[self isValidString:ethnicitiesString]){
        theFrame = [self addNewLabelWithTitle:[NSString stringWithFormat:@"Ethnicities: %@",ethnicitiesString] atFrame:theFrame];
        setSomeData = YES;
    }
    
    self.contentScroll.contentSize = CGSizeMake(1,theFrame.origin.y+kLabelYMargin/2);
    alreadySetUp = YES;
    
    if(setSomeData){
        self.noInformationLabel.hidden = YES;
        [self.noInformationLabel.superview sendSubviewToBack:self.noInformationLabel];
    }else{
        self.noInformationLabel.hidden = NO;
        [self.noInformationLabel.superview bringSubviewToFront:self.noInformationLabel];
    }
}

@end
