//
//  User+Manage.m
//  GoldenSpear
//
//  Created by Jose Antonio Sanchez Martinez on 08/04/15.
//  Copyright (c) 2015 GoldenSpear. All rights reserved.
//

#import "User+Manage.h"
#import <RestKit/RestKit.h>
#import <objc/runtime.h>
#import "AppDelegate.h"
#import "GSAccountCreatorManager.h"
#import "NSString+URLEncoding.h"

#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>

@import Foundation;

static char DELEGATE_KEY;
static char PICIMAGE_KEY;
//static char PICPATH_KEY;
static char PASSWORDCLEAR_KEY;
static char FINGERPRINT_KEY;
static char BFACEBOOKUSER_KEY;
static char HEADERPATH_KEY;

@interface User (PrimitiveAccessors)
- (NSString *)primitivePicture;
- (NSString *)primitiveFashionistaBlogURL;
- (NSString *)primitiveHeaderMedia;
- (NSString *)primitiveFull_picture;
@end

@implementation User (Manage)

-(NSString *) picture
{
    [self willAccessValueForKey:@"picture"];
    NSString *preview_image = [self primitivePicture];
    [self didAccessValueForKey:@"picture"];
    
    //    NSString * preview_image = self.preview_image;
    if (preview_image != nil)
    {
        if(!([preview_image isEqualToString:@""]))
        {
            if(!([preview_image hasPrefix:PROFILESPICIMAGESBASEURL]))
            {
                preview_image = [NSString stringWithFormat:@"%@%@",PROFILESPICIMAGESBASEURL, preview_image];
            }
        }
        
        if(!NSEqualRanges( [preview_image rangeOfString:@" "], NSMakeRange(NSNotFound, 0) ) )
        {
            preview_image = [preview_image stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
        }
    }
    
    //    self.picturePath = preview_image;
    
    return preview_image;
}

-(NSString *) full_picture
{
    [self willAccessValueForKey:@"full_picture"];
    NSString *preview_image = [self primitiveFull_picture];
    [self didAccessValueForKey:@"full_picture"];
    
    //    NSString * preview_image = self.preview_image;
    if (preview_image != nil)
    {
        if(!([preview_image isEqualToString:@""]))
        {
            if(!([preview_image hasPrefix:PROFILESPICIMAGESBASEURL]))
            {
                preview_image = [NSString stringWithFormat:@"%@%@",PROFILESPICIMAGESBASEURL, preview_image];
            }
        }
        
        if(!NSEqualRanges( [preview_image rangeOfString:@" "], NSMakeRange(NSNotFound, 0) ) )
        {
            preview_image = [preview_image stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
        }
    }
    
//    self.picturePath = preview_image;
    
    return preview_image;
}

-(NSString *) headerMedia
{
    [self willAccessValueForKey:@"headerMedia"];
    NSString *preview_image = [self primitiveHeaderMedia];
    [self didAccessValueForKey:@"headerMedia"];
    
    //    NSString * preview_image = self.preview_image;
    if (preview_image != nil)
    {
        if(!([preview_image isEqualToString:@""]))
        {
            if(!([preview_image hasPrefix:PROFILESPICIMAGESBASEURL]))
            {
                preview_image = [NSString stringWithFormat:@"%@%@",PROFILESPICIMAGESBASEURL, preview_image];
            }
        }
        
        if(!NSEqualRanges( [preview_image rangeOfString:@" "], NSMakeRange(NSNotFound, 0) ) )
        {
            preview_image = [preview_image stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
        }
    }
    
    //    self.picturePath = preview_image;
    
    return preview_image;
}

-(NSString *) fashionistaBlogURL
{
    [self willAccessValueForKey:@"fashionistaBlogURL"];
    NSString *path = [self primitiveFashionistaBlogURL];
    [self didAccessValueForKey:@"fashionistaBlogURL"];
    
    //    NSString * preview_image = self.preview_image;
    if (path != nil)
    {
        if(!NSEqualRanges( [path rangeOfString:@" "], NSMakeRange(NSNotFound, 0) ) )
        {
            path = [path stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
        }
    }
    
    return path;
}

// Getter and setter for picImage
/*
- (NSString *)picturePath
{
    return objc_getAssociatedObject(self, &PICPATH_KEY);
}

- (void)setPicturePath:(NSString *)picturePath
{
    objc_setAssociatedObject(self, &PICPATH_KEY, picturePath, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
*/

// Getter and setter for picImage
- (UIImage *)picImage
{
    return objc_getAssociatedObject(self, &PICIMAGE_KEY);
}

- (void)setPicImage:(UIImage *)picImage
{
    objc_setAssociatedObject(self, &PICIMAGE_KEY, picImage, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

// Getter and setter for headerMedia
- (id)headerMediaPath
{
    return objc_getAssociatedObject(self, &HEADERPATH_KEY);
}

- (void)setHeaderMediaPath:(id)headerMediaPath
{
    objc_setAssociatedObject(self, &HEADERPATH_KEY, headerMediaPath, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

// Getter and setter for psswordClear
- (NSString *)passwordClear
{
    return objc_getAssociatedObject(self, &PASSWORDCLEAR_KEY);
}

- (void)setPasswordClear:(NSString *)passwordClear
{
    objc_setAssociatedObject(self, &PASSWORDCLEAR_KEY, passwordClear, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
// Getter and setter for psswordClear
- (NSString *)fingerprint
{
    return objc_getAssociatedObject(self, &FINGERPRINT_KEY);
}

- (void)setFingerprint:(NSString *)fingerprint
{
    objc_setAssociatedObject(self, &FINGERPRINT_KEY, fingerprint, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

// Getter and setter for fFacebookUser
- (BOOL)bFacebookUser
{
    NSNumber *numberFacebookUser = objc_getAssociatedObject(self, &BFACEBOOKUSER_KEY);
    return [numberFacebookUser boolValue];
}

- (void)setBFacebookUser:(BOOL)bFacebookUser
{
    NSNumber *numberFacebookUser = [NSNumber numberWithBool: bFacebookUser];
    objc_setAssociatedObject(self, &BFACEBOOKUSER_KEY, numberFacebookUser, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}



// Getter and setter for delegate
- (id<UserDelegate>)delegate
{
    return objc_getAssociatedObject(self, &DELEGATE_KEY);
}

- (void)setDelegate:(id<UserDelegate>)delegate
{
    objc_setAssociatedObject(self, &DELEGATE_KEY, delegate, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


int numRetries;

-(NSString*) sGetTextGender
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSArray * objs = [appDelegate.config valueForKey:@"gender_types"];
    
    if (self.gender != nil)
    {
        if ((self.gender.intValue >= 0) || (self.gender.intValue < objs.count))
        {
            return [objs objectAtIndex:self.gender.intValue];
        }
    }
    
    return @"";
//    NSString * sGender = @"";
//    switch ([self.gender intValue])
//    {
//        case 0:
//            // not defined so return ""
//            break;
//        case 1:
//            sGender = NSLocalizedString(@"Male",nil);
//            break;
//        case 2:
//            sGender = NSLocalizedString(@"Female",nil);
//            break;
//        case 3:
//            sGender = NSLocalizedString(@"It's complicated",nil);
//            break;
//    }
//    
//    return sGender;
}

-(NSString*) sGetTextLocation
{
    NSString * sLocation = @"";
    
//    if (self.address1)
//    {
//        if (![self.address1  isEqualToString: @""])
//            sLocation = [sLocation stringByAppendingFormat:@"%@", self.address1];
//    }
    if (self.addressCity)
    {
        if (![self.addressCity  isEqualToString: @""])
            sLocation = [sLocation stringByAppendingFormat:@"%@", self.addressCity];
    }
    if (self.country)
    {
        if (![self.country  isEqualToString: @""])
            sLocation = [sLocation stringByAppendingFormat:@" (%@)", self.country];
    }
    
//    if ([sLocation isEqualToString: @""])
//    {
//        if (self.addressState)
//        {
//            if (![self.addressState  isEqualToString: @""])
//                sLocation = [sLocation stringByAppendingFormat:@"%@", self.addressState];
//        }
//        if (self.country)
//        {
//            if (![self.country  isEqualToString: @""])
//                sLocation = [sLocation stringByAppendingFormat:@" (%@)", self.country];
//        }
//    }
    
//    if ([sLocation isEqualToString: @""])
//        sLocation = NSLocalizedString(@"Location not set correctly", nil);
    
    
    return sLocation;
}

-(NSString*) sGetTextProfession
{
    GSAccountType* acType = [[GSAccountCreatorManager sharedManager] getAccountTypeWithId:self.typeprofessionId];
    if (acType!=nil) {
        return acType.appName;
    }
    return @"";
}


-(NSString*) sGetTextDress
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSArray * objs = [appDelegate.config valueForKey:@"dress_types"];
    
    if (self.dress != nil)
    {
        if ((self.dress.intValue >= 0) || (self.dress.intValue < objs.count))
        {
            return [objs objectAtIndex:self.dress.intValue];
        }
    }
    
    return @"";
}
-(NSString*) sGetTextShoe
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSArray * objs = [appDelegate.config valueForKey:@"shoe_types"];
    
    if (self.shoe != nil)
    {
        if ((self.shoe.intValue >= 0) || (self.shoe.intValue < objs.count))
        {
            return [objs objectAtIndex:self.shoe.intValue];
        }
    }
    
    return @"";
}


-(NSString*) sGetTextCup
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSArray * objs = [appDelegate.config valueForKey:@"cup_types"];
    
    if (self.cup != nil)
    {
        if ((self.cup.intValue >= 0) || (self.cup.intValue < objs.count))
        {
            return [objs objectAtIndex:self.cup.intValue];
        }
    }
    
    return @"";
}
-(NSString*) sGetTextHairColor
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSArray * objs = [appDelegate.config valueForKey:@"haircolor_types"];
    
    if (self.haircolor != nil)
    {
        if ((self.haircolor.intValue >= 0) || (self.haircolor.intValue < objs.count))
        {
            return [objs objectAtIndex:self.haircolor.intValue];
        }
    }
    
    return @"";
}
-(NSString*) sGetTextHairLength
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSArray * objs = [appDelegate.config valueForKey:@"hairlength_types"];
    
    if (self.hairlength != nil)
    {
        if ((self.hairlength.intValue >= 0) || (self.hairlength.intValue < objs.count))
        {
            return [objs objectAtIndex:self.hairlength.intValue];
        }
    }
    
    return @"";
}
-(NSString*) sGetTextEyeColor
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSArray * objs = [appDelegate.config valueForKey:@"eyecolor_types"];
    
    if (self.eyecolor != nil)
    {
        if ((self.eyecolor.intValue >= 0) || (self.eyecolor.intValue < objs.count))
        {
            return [objs objectAtIndex:self.eyecolor.intValue];
        }
    }
    
    return @"";
}
-(NSString*) sGetTextSkinColor
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSArray * objs = [appDelegate.config valueForKey:@"skincolor_types"];
    
    if (self.skincolor != nil)
    {
        if ((self.skincolor.intValue >= 0) || (self.skincolor.intValue < objs.count))
        {
            return [objs objectAtIndex:self.skincolor.intValue];
        }
    }
    
    return @"";
}
-(NSString*) sGetTextEthnicity
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSArray * objs = [appDelegate.config valueForKey:@"ethnicity_types"];
    
    if (self.ethnicity != nil)
    {
        if ((self.ethnicity.intValue >= 0) || (self.ethnicity.intValue < objs.count))
        {
            return [objs objectAtIndex:self.ethnicity.intValue];
        }
    }
    
    return @"";
}
-(NSString*) sGetTextShootnudes
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSArray * objs = [appDelegate.config valueForKey:@"shootnudes_types"];
    
    if (self.shootnudes != nil)
    {
        if ((self.shootnudes.intValue >= 0) || (self.shootnudes.intValue < objs.count))
        {
            return [objs objectAtIndex:self.shootnudes.intValue];
        }
    }
    
    return @"";
}
-(NSString*) sGetTextTatoos
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSArray * objs = [appDelegate.config valueForKey:@"tatoos_types"];
    
    if (self.tatoos != nil)
    {
        if ((self.tatoos.intValue >= 0) || (self.tatoos.intValue < objs.count))
        {
            return [objs objectAtIndex:self.tatoos.intValue];
        }
    }
    
    return @"";
}
-(NSString*) sGetTextPiercings
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSArray * objs = [appDelegate.config valueForKey:@"piercings_types"];
    
    if (self.piercings != nil)
    {
        if ((self.piercings.intValue >= 0) || (self.piercings.intValue < objs.count))
        {
            return [objs objectAtIndex:self.piercings.intValue];
        }
    }
    
    return @"";
}
-(NSString*) sGetTextRealtionship
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSArray * objs = [appDelegate.config valueForKey:@"relationship_types"];
    
    if (self.relationship != nil)
    {
        if ((self.relationship.intValue >= 0) || (self.relationship.intValue < objs.count))
        {
            return [objs objectAtIndex:self.relationship.intValue];
        }
    }
    
    return @"";
}

-(NSString*) sGetTextMeasuring
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSArray * objs = [appDelegate.config valueForKey:@"measure_types"];
    
    if (self.typemeasures != nil)
    {
        if ((self.typemeasures.intValue >= 0) || (self.typemeasures.intValue < objs.count))
        {
            return [objs objectAtIndex:self.typemeasures.intValue];
        }
    }
    
    return @"";
}
-(NSString*) sGetTextExperience
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSArray * objs = [appDelegate.config valueForKey:@"experience_types"];
    
    if (self.experience != nil)
    {
        if ((self.experience.intValue >= 0) || (self.experience.intValue < objs.count))
        {
            return [objs objectAtIndex:self.experience.intValue];
        }
    }
    
    return @"";
}
-(NSString*) sGetTextCompensation
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSArray * objs = [appDelegate.config valueForKey:@"compensation_types"];
    
    if (self.compensation != nil)
    {
        if ((self.compensation.intValue >= 0) || (self.compensation.intValue < objs.count))
        {
            return [objs objectAtIndex:self.compensation.intValue];
        }
    }
    
    return @"";
}
-(NSString*) sGetTextGenre
{
    return [User sGetTextGenreFromString:self.genre];
}

+(NSString *) sGetTextGenreFromString:(NSString *)sGenreString
{
    NSString * sGenreFinal = @"";
    if (sGenreString != nil && ![sGenreString isEqualToString:@""])
    {
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        NSArray * objs = [appDelegate.config valueForKey:@"gender_types"];
        NSMutableArray* finalObjs = [NSMutableArray new];
        for(NSString* s in objs){
            if (![s isEqualToString:@""]) {
                [finalObjs addObject:s];
            }
        }
        
        NSArray * genres = [sGenreString componentsSeparatedByString:@","];
        int i = 0;
        for(NSString * genre in genres)
        {
            if ((genre.intValue >= 0) || (genre.intValue < finalObjs.count))
            {
                NSString * sGenre = [finalObjs objectAtIndex:genre.intValue];
                if (i == 0)
                {
                    sGenreFinal = sGenre;
                }
                else
                {
                    sGenreFinal = [NSString stringWithFormat:@"%@,%@",sGenreFinal,sGenre ];
                }
                i++;
            }
        }
        
        
    }
    
    return sGenreFinal;
}

// check if the user has filled all the required fields
-(BOOL) isUserComplete
{
    if (([self.name isEqualToString:@""]) ||
        ([self.lastname isEqualToString:@""]) ||
//        ([self.country isEqualToString:@""]) ||
//        ([self.addressCity isEqualToString:@""]) ||
//        (self.birthdate == nil) ||
        self.typeprofession.intValue == 0)
    {
        return NO;
    }
    if (self.typeprofession.intValue < 17) // user
    {
//        if ((self.gender != nil) && (self.gender.intValue == 0))
//        {
//            return NO;
//        }
    }
/*
    if (self.typeprofession.intValue == 1) // user
    {
        if ((self.birthdate == nil) ||
//            (self.genre == nil) ||
            ((self.gender != nil) && (self.gender.intValue == 0)))
        {
            return NO;
        }
    }
    else if (self.typeprofession.intValue == 2) // model
    {
        if ((self.birthdate == nil) ||
            (self.genre == nil) ||
            ((self.genre != nil) && (self.genre.intValue == 0)) ||
            (self.gender == nil) ||
            ((self.gender != nil) && (self.gender.intValue == 0)))
        {
            return NO;
        }
    }
    else if (self.typeprofession.intValue ==3)  // photographer
    {
        if ((self.birthdate == nil) ||
            (self.genre == nil) ||
            ((self.genre != nil) && (self.genre.intValue == 0)) ||
            (self.gender == nil) ||
            ((self.gender != nil) && (self.gender.intValue == 0)))
        {
            return NO;
        }
    }
    else if ((self.typeprofession.intValue >=4) && (self.typeprofession.intValue <= 5))  // filmaker
    {
        if ((self.birthdate == nil) ||
            (self.genre == nil) ||
            ((self.genre != nil) && (self.genre.intValue == 0)))
        {
            return NO;
        }
    }
    else if ((self.typeprofession.intValue >=6) && (self.typeprofession.intValue <= 13))  // default fashion
    {
        if ((self.birthdate == nil) ||
            (self.genre == nil) ||
            ((self.genre != nil) && (self.genre.intValue == 0)) ||
            (self.gender == nil) ||
            ((self.gender != nil) && (self.gender.intValue == 0)))
        {
            return NO;
        }
    }
    else if ((self.typeprofession.intValue >=14) && (self.typeprofession.intValue <= 15)) // Event planner
    {
        if ((self.birthdate == nil) ||
            (self.genre == nil) ||
            ((self.genre != nil) && (self.genre.intValue == 0)))
        {
            return NO;
        }
    }
    else if (self.typeprofession.intValue ==16)  // brand
    {
        if ((self.birthdate == nil) ||
            (self.genre == nil) ||
            ((self.genre != nil) && (self.genre.intValue == 0)) ||
            (self.gender == nil) ||
            ((self.gender != nil) && (self.gender.intValue == 0)) ||
            ([self.fashionistaBlogURL isEqualToString:@""]))
        {
            return NO;
        }
    }
    else if ((self.typeprofession.intValue >=17) && (self.typeprofession.intValue <= 21))  // publication
    {
        if ((self.birthdate == nil) ||
            (self.genre == nil) ||
            ((self.genre != nil) && (self.genre.intValue == 0)) ||
            ([self.fashionistaBlogURL isEqualToString:@""]))
        {
            return NO;
        }
    }
 */
    
    return YES;
}

-(void) copyLocationFields:(User *)user{
    user.address1 = self.address1;
    user.address2 = self.address2;
    user.addressCity = self.addressCity;
    user.addressCity_id = self.addressCity_id;
    user.addressPostalCode = self.addressPostalCode;
    user.addressState = self.addressState;
    user.addressState_id = self.addressState_id;
    user.country = self.country;
    user.country_id = self.country_id;
}

- (void)copyAllFields:(User*)user{
    [self copyLocationFields:user];
    user.addressCityVisible = self.addressCityVisible;
    user.agencies = self.agencies;
    user.birthdate = self.birthdate;
    user.birthdateVisible = self.birthdateVisible;
    user.bust = self.bust;
    user.commentsId = self.commentsId;
    user.compensation = self.compensation;
    user.cup = self.cup;
    user.datequeryvalidateprofile = self.datequeryvalidateprofile;
    user.datevalidatedprofile = self.datevalidatedprofile;
    user.dress = self.dress;
    user.email = self.email;
    user.ethnicity = self.ethnicity;
    user.ethnicityVisible = self.ethnicityVisible;
    user.experience = self.experience;
    user.eyecolor = self.eyecolor;
    user.facebook_id = self.facebook_id;
    user.facebook_token = self.facebook_token;
    user.facebook_url = self.facebook_url;
    user.fashionistaBlogURL = self.fashionistaBlogURL;
    user.fashionistaName = self.fashionistaName;
    user.fashionistaPagesId = self.fashionistaPagesId;
    user.fashionistaTitle = self.fashionistaTitle;
    user.flicker_id = self.flicker_id;
    user.flicker_token = self.flicker_token;
    user.gender = self.gender;
    user.genderVisible = self.genderVisible;
    user.genre = self.genre;
    user.genreVisible = self.genreVisible;
    user.haircolor = self.haircolor;
    user.hairlength = self.hairlength;
    user.headerMedia = self.headerMedia;
    user.headerType = self.headerType;
    user.heightCm = self.heightCm;
    user.heightM = self.heightM;
    user.hip = self.hip;
    user.idUser = self.idUser;
    user.instagram_id = self.instagram_id;
    user.instagram_token = self.instagram_token;
    user.instagram_url = self.instagram_url;
    user.insteam = self.insteam;
    user.instruments = self.instruments;
    user.isFashionista = self.isFashionista;
    user.lastname = self.lastname;
    user.linkedin_id = self.linkedin_id;
    user.linkedin_token = self.linkedin_token;
    user.linkedin_url = self.linkedin_url;
    user.name = self.name;
    user.neck = self.neck;
    user.notificationsId = self.notificationsId;
    user.password = self.password;
    user.phone = self.phone;
    user.phonecallingcode = self.phonecallingcode;
    user.picture = self.picture;
    user.picturepermission = self.picturepermission;
    user.piercings = self.piercings;
    user.pinterest_id = self.pinterest_id;
    user.politicalParty = self.politicalParty;
    user.politicalPartyVisible = self.politicalPartyVisible;
    user.politicalView = self.politicalView;
    user.politicalViewVisible = self.politicalViewVisible;
    user.relationship = self.relationship;
    user.relationshipVisible = self.relationshipVisible;
    user.religion = self.religion;
    user.religionVisible = self.religionVisible;
    user.reviewsId = self.reviewsId;
    user.shoe = self.shoe;
    user.shootnudes = self.shootnudes;
    user.skincolor = self.skincolor;
    user.sleeve = self.sleeve;
    user.snapchat_id = self.snapchat_id;
    user.snapchat_token = self.snapchat_token;
    user.specialization = self.specialization;
    user.tatoos = self.tatoos;
    user.tellusmore = self.tellusmore;
    user.tumblr_id = self.tumblr_id;
    user.tumblr_token = self.tumblr_token;
    user.twitter_id = self.twitter_id;
    user.twitter_token = self.twitter_token;
    user.twitter_url = self.twitter_url;
    user.typemeasures = self.typemeasures;
    user.typeprofession = self.typeprofession;
    user.typeprofessionId = self.typeprofessionId;
    user.uuid = self.uuid;
    user.validatedprofile = self.validatedprofile;
    user.waist = self.waist;
    user.wardrobesId = self.wardrobesId;
    user.weight = self.weight;
    user.createdAt = self.createdAt;
    
    user.comments = [self.comments copy];
    user.fashionistaPages = [self.fashionistaPages copy];
    user.fashionistaPosts = [self.fashionistaPosts copy];
    user.notifications = [self.notifications copy];
    user.reviews = [self.reviews copy];
    user.wardrobes = [self.wardrobes copy];
    
    user.bFacebookUser = self.bFacebookUser;
}

+(User*) getUserWithId:(NSString*)userId{
    User* fetchedUser = nil;
    NSManagedObjectContext *currentContext = [RKObjectManager sharedManager].managedObjectStore.mainQueueManagedObjectContext;
    
    NSFetchRequest * fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"User" inManagedObjectContext:currentContext];
    [fetchRequest setEntity:entity];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"idUser like %@",userId];
    [fetchRequest setPredicate:predicate];
    
    NSError *error;
    NSArray *items = [currentContext executeFetchRequest:fetchRequest error:&error];
    fetchedUser = [items firstObject];
    return fetchedUser;
}

// Create new user
-(void)setUserWithUUID:(NSString *)newUUID andUserID: (NSString *)newUserID andName:(NSString *)newName andSurname:(NSString *)newSurname andEmail:(NSString *)newEmail andPassword:(NSString *)newPassword andPhone:(NSString *)newPhone andBirthdate:(NSDate *)newBirthdate andGender:(NSNumber *)newGender andPicpermision:(BOOL)newPicpermission andPicPath:(NSString *)newPicPath andPic:(UIImage *) newPic andWardrobes:(NSSet *)newWardrobes andReviews:(NSSet *)newReviews andCountry:(NSString *)newCountry andState:(NSString *)newState andCity:(NSString *)newCity andAddress1:(NSString *)newAddress1 andAddress2:(NSString *)newAddress2 andPostalCode:(NSString *)newPostalCode andUserName: (NSString *)newUsername andWebsite: (NSString *)newWebsite andBio: (NSString *)newBio
{
    self.fashionistaName = newUsername;
    self.fashionistaBlogURL = newWebsite;
    self.fashionistaTitle = newBio;
    
    self.uuid = newUUID;
    self.idUser = newUserID;
    self.name = newName;
    self.lastname = newSurname;
    self.email = newEmail;
    self.password = newPassword;
    self.phone = newPhone;
    self.birthdate = newBirthdate;
    self.gender = newGender;
    self.picturepermission = [NSNumber numberWithBool:newPicpermission];
    self.picture = newPicPath;
    self.picImage = newPic;
    self.wardrobes = newWardrobes;
    self.reviews = newReviews;
    self.country = newCountry;
    self.addressState = newState;
    self.addressCity = newCity;
    self.address1 = newAddress1;
    self.address2 = newAddress2;
    self.addressPostalCode = newPostalCode;
    self.isFashionista = [NSNumber numberWithBool:YES];
    
    for (Wardrobe *wardrobe in self.wardrobes)
    {
        [self.wardrobesId addObject:wardrobe.idWardrobe];
    }
    
    for (Review *review in self.reviews)
    {
        [self.reviewsId addObject:review.idReview];
    }
    
    self.delegate = nil;
}

#pragma mark - save user to systemdefaults

// Save user to iOS defaults system
- (BOOL)saveUserToSystemDefaults
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    [defaults setObject:self.idUser forKey:@"UserID"];
    [defaults setObject:self.name forKey:@"Name"];
    [defaults setObject:self.lastname forKey:@"Surname"];
//    if (self.bFacebookUser)
//    {
//        NSString * last_email = [defaults stringForKey:@"eMail"];
//        if ([self.email isEqualToString:last_email] == NO)
//        {
//            [defaults setObject:[NSString stringWithFormat:@""] forKey:@"eMail"];
//            [defaults setObject:[NSString stringWithFormat:@""] forKey:@"Password"];
//            [defaults setObject:[NSString stringWithFormat:@""] forKey:@"Password2"];
//        }
//    }
//    else
//    {
//        [defaults setObject:self.passwordClear forKey:@"Password"];
//        [defaults setObject:self.password forKey:@"Password2"];
//    }

    [defaults setObject:self.email forKey:@"eMail"];
    [defaults setObject:self.passwordClear forKey:@"Password"];
    [defaults setObject:self.password forKey:@"Password2"];
    
    [defaults setObject:self.phone forKey:@"Phonenumber"];
    [defaults setObject:self.birthdate forKey:@"Birthdate"];
    [defaults setObject:self.country forKey:@"Country"];
    [defaults setObject:self.addressState forKey:@"State"];
    [defaults setObject:self.addressCity forKey:@"City"];
    [defaults setObject:self.address1 forKey:@"Address1"];
    [defaults setObject:self.address2 forKey:@"Address2"];
    [defaults setObject:self.addressPostalCode forKey:@"PostalCode"];
    [defaults setInteger:self.gender.intValue forKey:@"Gender"];
    [defaults setBool:(BOOL)self.picturepermission forKey:@"ProfilePicPermission"];
    [defaults setObject:self.picture forKey:@"ProfilePicPath"];
    [defaults setBool:TRUE forKey:@"UserSignedIn"];
    [defaults setBool:self.bFacebookUser forKey:@"FacebookUser"];
    
    // Save to device defaults
    if (![defaults synchronize])
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_ERROR_", nil) message:NSLocalizedString(@"_SAVE_USR_DFLTS_ERROR_MSG_", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"_OK_", nil) otherButtonTitles: nil];
        
        [alertView show];
        
        return FALSE;
    }
    
    
    
    return TRUE;
}

-(void) removeUserFromSystemDefaults
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
//    BOOL bFacebookUser = NO;
//    if ([defaults boolForKey:@"FacebookUser"] == YES)
//    {
//        bFacebookUser = YES;
//    }

    [defaults setInteger:-1 forKey:@"UserID"];
    [defaults setObject:[NSString stringWithFormat:NSLocalizedString(@"_NAME_", nil)] forKey:@"Name"];
    [defaults setObject:[NSString stringWithFormat:NSLocalizedString(@"_SURNAME_", nil)] forKey:@"Surname"];

//    if (bFacebookUser)
//    {
//        NSString * sPwdSet = [defaults stringForKey:@"Password"];
//        if ([sPwdSet isEqualToString:@""])
//        {
//            [defaults setObject:[NSString stringWithFormat:@""] forKey:@"eMail"];
//        }
//    }
//    [defaults setObject:[NSString stringWithFormat:NSLocalizedString(@"_EMAIL_", nil)] forKey:@"eMail"];
//    [defaults setObject:[NSString stringWithFormat:NSLocalizedString(@"_PASSWORD_1_", nil)] forKey:@"Password"];
//    [defaults setObject:[NSString stringWithFormat:NSLocalizedString(@"_PASSWORD_2_", nil)] forKey:@"Password2"];
    [defaults setObject:[NSString stringWithFormat:NSLocalizedString(@"_PHONE_NUMBER_", nil)] forKey:@"Phonenumber"];
    [defaults setObject:[NSString stringWithFormat:NSLocalizedString(@"_BIRTHDATE_", nil)] forKey:@"Birthdate"];
    [defaults setInteger:0 forKey:@"Gender"];
    [defaults setBool:YES forKey:@"ProfilePicPermission"];
    [defaults setBool:FALSE forKey:@"UserSignedIn"];
    
    // Save to device defaults
    if (![defaults synchronize])
    {
        NSLog(@"Could not reset defaults!");
    }
}

//// Log in
//- (void)LogIn
//{
//    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_SIGN_IN_", nil) message:NSLocalizedString(@"_SIGN_IN_INSTR_MSG_", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"_CANCEL_", nil) otherButtonTitles:NSLocalizedString(@"_LOG_IN_", nil), nil];
//    
//    alertView.alertViewStyle = UIAlertViewStyleLoginAndPasswordInput;
//    
//    [alertView textFieldAtIndex:0].keyboardType = UIKeyboardTypeEmailAddress;
//    
//    [alertView textFieldAtIndex:0].placeholder = NSLocalizedString(@"_USERNAME_", nil);
//    
//    [alertView textFieldAtIndex:1].keyboardType = UIKeyboardTypeDefault;
//    
//    [alertView textFieldAtIndex:1].placeholder = NSLocalizedString(@"_PWD_", nil);
//    
//    [alertView show];
//}
//
//- (BOOL)alertViewShouldEnableFirstOtherButton:(UIAlertView *)alertView
//{
//    NSString *title = [alertView buttonTitleAtIndex:1];
//    
//    if([title isEqualToString:NSLocalizedString(@"_LOG_IN_", nil)])
//    {
//        // Check if email has a correct format
//        if(![self validateEmail:[[alertView textFieldAtIndex:0] text]])
//        {
//            return NO;
//        }
//        
//        if(![[[alertView textFieldAtIndex:1] text] length] >= 1)
//        {
//            return NO;
//        }
//    }
//    
//    return YES;
//}
//
//// Checks if a string fits into a regular expresion representing an email address
//- (BOOL)validateEmail:(NSString *)emailString
//{
//    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
//    
//    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
//    
//    return [emailTest evaluateWithObject:emailString];
//}
//- (void)LogOut
//{
//    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_SIGN_OUT_", nil) message:NSLocalizedString(@"_SIGN_OUT_INSTR_MSG_", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"_NO_", nil) otherButtonTitles:NSLocalizedString(@"_YES_", nil), nil];
//    
//    [alertView show];
//}
//
//- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
//{
//    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
//    
//    if([title isEqualToString:NSLocalizedString(@"_LOG_IN_", nil)])
//    {
//        [self logInUserWithUsername:[alertView textFieldAtIndex:0].text andPassword:[alertView textFieldAtIndex:1].text andVerbose:TRUE];
//    }
//    else if ([title isEqualToString:NSLocalizedString(@"_YES_", nil)])
//    {
//        NSLog(@"User confirms Sign Out!");
//        
//        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
//        
//        [defaults setBool:FALSE forKey:@"UserSignedIn"];
//        
//        // Save to device defaults
//        [defaults synchronize];
//        
//        if (self.delegate != nil)
//            [self.delegate userAccount:self didLogOut:YES];
//    }
//}

#pragma mark - update user data in the server

// Save user information to the GS database
- (BOOL)updateUserToServerDBVerbose:(BOOL) bVerbose
{
    BOOL __block bSuccess = FALSE;
    
    [[RKObjectManager sharedManager] postObject:self
                                           path:[NSString stringWithFormat:@"/user/%@", self.idUser]
                                     parameters:nil
                                        success:^(RKObjectRequestOperation * operation, RKMappingResult * mappingResult)
     {
         [self updateUserToServerDBSuccess: mappingResult andVerbose:bVerbose];
         
         AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
         if (appDelegate.finger.bLoadedFingerPrint)
         {
             [self setFingerPrint:appDelegate.finger.fingerprint];
         }
     }
                                        failure:^(RKObjectRequestOperation * operation, NSError *error)
     {
         if (operation.HTTPRequestOperation.response.statusCode >= 400)
             [self updateUserToServerDBSuccessError:error withResponseString:operation.HTTPRequestOperation.responseString];
         else
             [self updateUserToServerDBSuccess:nil andVerbose:bVerbose];
     }];
    
    return bSuccess;
}


#pragma mark - signup / save user data in the server

// Save user information to the GS database
- (BOOL)saveUserToServerDB
{
    BOOL __block bSuccess = FALSE;

    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    [dateFormatter setLocale:[NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"]];
    
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"];
    
    NSString * device = [AppDelegate getDeviceName];
    NSString * iOSversion = [AppDelegate getOSVersion];
    
    [[RKObjectManager sharedManager] postObject:self
                                           path:[NSString stringWithFormat:@"/user?createdAtLocal=%@&inapplogin=true&device=%@&os=iOS&osversion=%@",[dateFormatter stringFromDate:[NSDate date]], device, iOSversion]
                                     parameters:nil
                                        success:^(RKObjectRequestOperation * operation, RKMappingResult * mappingResult)
    {
        [self saveUserToServerDBSuccess: mappingResult];
        
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        if (appDelegate.finger.bLoadedFingerPrint)
        {
            [self setFingerPrint:appDelegate.finger.fingerprint];
        }
    }
                                        failure:^(RKObjectRequestOperation * operation, NSError *error)
    {
        [self saveUserToServerDBSuccessError:error withResponseString:operation.HTTPRequestOperation.responseString];
        NSManagedObjectContext * currentContext = [RKObjectManager sharedManager].managedObjectStore.mainQueueManagedObjectContext;
        [currentContext deleteObject:self];
        NSError * errorcd = nil;
        if (![currentContext save:&errorcd])
        {
            NSLog(@"Error saving context! %@", errorcd);
        }
        
    }];
    
    return bSuccess;
}

-(void) saveUserHeaderMediaToServerDBUpdating:(BOOL) bUpdate
{
    NSData* mediaData = nil;
    NSString* fileName = nil;
    NSString* mimeType = nil;
    // Setup request to upload user information
    if ([self.headerMediaPath isKindOfClass:[UIImage class]]) {
        mediaData = UIImageJPEGRepresentation(self.headerMediaPath, 0.5);
        fileName = @"image_avatar.jpg";
        mimeType = @"image/jpg";
    }else{
        mediaData = [NSData dataWithContentsOfURL:[NSURL fileURLWithPath: self.headerMediaPath]];
        fileName = @"content_video.m4v";
        mimeType = @"video/mp4";
    }
    
    // Serialize the Article attributes then attach a file
    NSMutableURLRequest *request = [[RKObjectManager sharedManager] multipartFormRequestWithObject:nil
                                                                                            method:RKRequestMethodPOST
                                                                                              path:[NSString stringWithFormat:@"/user/%@/upload-header", self.idUser]
                                                                                        parameters:nil
                                                                         constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
                                                                             [formData appendPartWithFileData:mediaData
                                                                                                         name:@"media"
                                                                                                     fileName:fileName
                                                                                                     mimeType:mimeType];
                                                                         }];
    
    RKObjectRequestOperation *operation = [[RKObjectManager sharedManager] objectRequestOperationWithRequest:request
                                                                                                     success:^(RKObjectRequestOperation * operation, RKMappingResult * mappingResult)
                                           {
                                               [self saveUserHeaderMediaToServerDBSuccess: mappingResult updating:bUpdate];
                                           }
                                                                                                     failure:^(RKObjectRequestOperation * operation, NSError *error)
                                           {
                                               if (operation.HTTPRequestOperation.response.statusCode >= 400)
                                                   [self saveUserHeaderMediaToServerDBSuccessError:error updating:bUpdate];
                                               else
                                                   [self saveUserHeaderMediaToServerDBSuccess:nil updating:bUpdate];
                                           }];
    [[RKObjectManager sharedManager] enqueueObjectRequestOperation:operation]; // NOTE: Must be enqueued rather than started
}

-(void) saveUserImageToServerDBUpdating:(BOOL) bUpdate
{
        // Setup request to upload user information
    
    // Serialize the Article attributes then attach a file
    NSMutableURLRequest *request = [[RKObjectManager sharedManager] multipartFormRequestWithObject:nil
                                                                                            method:RKRequestMethodPOST
                                                                                              path:[NSString stringWithFormat:@"/user/%@/upload-picture", self.idUser]
                                                                                        parameters:nil
                                                                         constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileData:UIImageJPEGRepresentation(self.picImage, 0.5)
                                    name:@"picture"
                                fileName:@"image_avatar.jpg"
                                mimeType:@"image/jpg"];
    }];
    
    RKObjectRequestOperation *operation = [[RKObjectManager sharedManager] objectRequestOperationWithRequest:request
                                                                                                     success:^(RKObjectRequestOperation * operation, RKMappingResult * mappingResult)
         {
             [self saveUserImageToServerDBSuccess: mappingResult updating:bUpdate];
         }
                                                                                                     failure:^(RKObjectRequestOperation * operation, NSError *error)
         {
             if (operation.HTTPRequestOperation.response.statusCode >= 400)
                 [self saveUserImageToServerDBSuccessError:error updating:bUpdate];
             else
                 [self saveUserImageToServerDBSuccess:nil updating:bUpdate];
         }];
    [[RKObjectManager sharedManager] enqueueObjectRequestOperation:operation]; // NOTE: Must be enqueued rather than started
    
}

-(NSMutableData *) addImageToMultiPartBody:(NSMutableData *)body withBoundary:(NSString *) boundary
{
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
//    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"filenames\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
//    
//    [body appendData:[@"_identificationImage" dataUsingEncoding:NSUTF8StringEncoding]];
//    
//    [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"picture\"; filename=\"%@\"\r\n", self.picture] dataUsingEncoding:NSUTF8StringEncoding]];
    
    [body appendData:[@"Content-Type: application/octet-stream\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    
    [body appendData:UIImageJPEGRepresentation(self.picImage, 0.5)];
    
    return body;
}

-(NSMutableData *) addParameterMultiPartBody:(NSMutableData *) body withBoundary:(NSString *) boundary
{
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"user\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    
    [body appendData:[[NSString stringWithFormat:@"{"] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"\"name\": \"%@\",",self.name] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"\"lastName\": \"%@\",",self.lastname] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"\"email\": \"%@\",",self.email] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"\"password\": \"%@\",",self.password] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"\"phone\": \"%@\",",self.phone] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"\"birthDate\": \"%@\",",self.birthdate] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"\"gender\": \"%@\",",self.gender] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"\"picturepermission\": %@,",self.picturepermission] dataUsingEncoding:NSUTF8StringEncoding]];
//    [body appendData:[[NSString stringWithFormat:@"\"picPath\": \"%@\",",self.uPic] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"\"uuid\": \"%@\",",self.uuid] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"\"country\": \"%@\",",self.country] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"\"addressState\": \"%@\",",self.addressState] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"\"addressCity\": \"%@\",",self.addressCity] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"\"address1\": \"%@\",",self.address1] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"\"address2\": \"%@\",",self.address2] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"\"addressPostalCode\": \"%@\"",self.addressPostalCode] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"}"] dataUsingEncoding:NSUTF8StringEncoding]];
    
    return body;
}



#pragma mark - login

// make login sending the request to the server
- (BOOL)logInUserWithUsername:(NSString *)email andPassword:(NSString *)password andVerbose:(BOOL)bVerbose
{
    BOOL __block bSuccess = FALSE;
    NSLog(@"*** Login with email: %@" /*and Password: %@ ***"*/, email/*, password*/);
    self.passwordClear = password;
    self.email = email;
    self.password = password;
    self.bFacebookUser = NO;
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    [dateFormatter setLocale:[NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"]];
    
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"];
    
    NSString * device = [AppDelegate getDeviceName];
    NSString * iOSversion = [AppDelegate getOSVersion];
    
    NSString *requestURL = [[NSString stringWithFormat:@"/login?createdAtLocal=%@&inapplogin=true&device=%@&os=iOS&osversion=%@", [dateFormatter stringFromDate:[NSDate date]], device, iOSversion] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

    [[RKObjectManager sharedManager] postObject:self
                                           path:requestURL
                                     parameters:nil
                                        success:^(RKObjectRequestOperation * operation, RKMappingResult * mappingResult)
    {
        NSDictionary * allHeaders = operation.HTTPRequestOperation.response.allHeaderFields;
        NSArray * cookies = [NSHTTPCookie cookiesWithResponseHeaderFields:allHeaders forURL:[NSURL URLWithString:RESTBASEURL]];
        NSHTTPCookieStorage * cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
        for(NSHTTPCookie *cookie in cookies)
        {
            NSLog(@"****** Cookie\n****** Login.\n****** Name: %@, Value: %@", cookie.name, cookie.value);
            if ([cookie.name isEqualToString:@"sails.sid"])
            {
                NSLog(@"****** Asignar Cookie");
                
                [cookieStorage setCookie:cookie];
                [[[RKObjectManager sharedManager]  HTTPClient] setDefaultHeader:cookie.name value:cookie.value];
            }
        }

        [self logInUserWithUsernameSuccess:mappingResult andVerbose:bVerbose];
        
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        if (appDelegate.finger.bLoadedFingerPrint)
        {
            [self setFingerPrint:appDelegate.finger.fingerprint];
        }

        
    }
                                        failure:^(RKObjectRequestOperation * operation, NSError *error)
    {
        NSLog(@"Status code: %ld",(long)operation.HTTPRequestOperation.response.statusCode);
        
        [self getUserInfoWithEmail:self.email];
//        [self logInUserWithUsernameError:error withResponseString:operation.HTTPRequestOperation.responseString andVerbose:bVerbose];
        
        NSManagedObjectContext * currentContext = [RKObjectManager sharedManager].managedObjectStore.mainQueueManagedObjectContext;
        [currentContext deleteObject:self];
        
        NSError * errorcd = nil;
        if (![currentContext save:&errorcd])
        {
            NSLog(@"Error saving context! %@", errorcd);
        }
    }];

//    // Setup request to upload user information
//
//    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//    
//    [dateFormatter setLocale:[NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"]];
//    
//    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"];
//
//    NSMutableURLRequest *request = [[RKObjectManager sharedManager] multipartFormRequestWithObject:nil
//                                                                                            method:RKRequestMethodPOST
//                                                                                              path:[NSString stringWithFormat:@"/login?createdAtLocal=%@", [dateFormatter stringFromDate:[NSDate date]]]
//                                                                                        parameters:nil
//                                                                         constructingBodyWithBlock:^(id<AFMultipartFormData> formData)
//                                    {
//                                        /* DOESN'T WORK!! :-( */
//                                    }];
//    
//    // Check that the request is properly created
//    if (request == nil)
//    {
//        // If the request wasn't properly created, cancel identification process
//        
//        if (bVerbose)
//        {
//            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_ERROR_", nil) message:NSLocalizedString(@"_LOG_IN_ERROR_MSG_", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"_OK_", nil) otherButtonTitles:nil];
//            
//            [alertView show];
//        }
//        
//        return FALSE;
//    }
//    
//    // Construct the request body, appending image to upload
//    
//    NSMutableData *body = [NSMutableData data];
//    
//    [body appendData:[[NSString stringWithFormat:@"{\n"] dataUsingEncoding:NSUTF8StringEncoding]];
//    [body appendData:[[NSString stringWithFormat:@"\"email\": \"%@\",\n",username] dataUsingEncoding:NSUTF8StringEncoding]];
//    [body appendData:[[NSString stringWithFormat:@"\"password\": \"%@\"\n",password] dataUsingEncoding:NSUTF8StringEncoding]];
//    [body appendData:[[NSString stringWithFormat:@"}"] dataUsingEncoding:NSUTF8StringEncoding]];
//    
//    [request setHTTPBody:body];
//    
//    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
//    
//    [request setTimeoutInterval:20];
//    
//    // Construct the upload operation based on the created request
//    NSManagedObjectContext *currentContext = [RKObjectManager sharedManager].managedObjectStore.mainQueueManagedObjectContext;
//    
//    RKManagedObjectRequestOperation *operation = [[RKObjectManager sharedManager] managedObjectRequestOperationWithRequest:request
//                                                                                                      managedObjectContext:currentContext
//                                                                                                                   success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult)
//                                                  {
//                                                      [self logInUserWithUsernameSuccess:mappingResult andVerbose:bVerbose];
//                                                  }
//                                                                                                                   failure:^(RKObjectRequestOperation *operation, NSError *error)
//                                                  {
//                                                      [self logInUserWithUsernameError: error andVerbose:YES];
//                                                  }];
//    
//    // Enqueue operation
//    [[RKObjectManager sharedManager] enqueueObjectRequestOperation:operation];
    
    return bSuccess;
}

- (void)getUserInfoWithEmail:(NSString*)email {
    
    NSString *requestString = [NSString stringWithFormat:@"/user?email=%@", email];
    
     NSDate *methodStart = [NSDate date];
    
    [[RKObjectManager sharedManager] getObjectsAtPath:requestString
                                           parameters:nil
                                              success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult)
     {
         // If the GS server provided an answer, check wheter that answer could be mapped into our data classes
         
         NSDate *methodFinish = [NSDate date];
         
         NSTimeInterval executionTime = [methodFinish timeIntervalSinceDate:methodStart];
         
         NSLog(@"Operation <%@> succeed!! It took: %f", operation.HTTPRequestOperation.request.URL, executionTime);
         
         [self.delegate userAccount:self results:[mappingResult array]];
     }
                                              failure:^(RKObjectRequestOperation *operation, NSError *error)
     {
         //Message to show if no results were provided
         NSArray *errorMessage = [NSArray arrayWithObjects:NSLocalizedString(@"_ERROR_", nil), NSLocalizedString(@"_CONNECTION_ERROR_MSG_", nil), NSLocalizedString(@"_OK_", nil), nil];
         
         // If 'failedAnswerErrorMessage' is nil, it means that we don't want to provide messages to the user
         
         NSLog(@"Operation <%@> failed with error: %ld", operation.HTTPRequestOperation.request.URL, (long)operation.HTTPRequestOperation.response.statusCode);
         
         [self logInUserWithUsernameError:error withResponseString:operation.HTTPRequestOperation.responseString andVerbose:NO];
         
         NSManagedObjectContext * currentContext = [RKObjectManager sharedManager].managedObjectStore.mainQueueManagedObjectContext;
         [currentContext deleteObject:self];
         
         NSError * errorcd = nil;
         if (![currentContext save:&errorcd])
         {
             NSLog(@"Error saving context! %@", errorcd);
         }
     }];

}

- (void)setFingerPrint:(NSString *) fingerprint
{
    NSLog(@"*** Set fingerprint: %@", fingerprint);
    self.fingerprint = fingerprint;
    NSLog(@"%@", self.fingerprint);
    
    [[RKObjectManager sharedManager] postObject:self
                                           path:[NSString stringWithFormat:@"/fingerprint"]
                                     parameters:nil
                                        success:^(RKObjectRequestOperation * operation, RKMappingResult * mappingResult)
     {
         NSLog(@"Fingerprint ok");
         
     }
                                        failure:^(RKObjectRequestOperation * operation, NSError *error)
     {
         
         NSLog(@"Fingerprint error: %ld",(long)operation.HTTPRequestOperation.response.statusCode);
     }];
}

#pragma mark - login facebook
-(BOOL) loginFacebookWithEmail:(NSString *) email andToken:(NSString *)sToken andFacebookID:(NSString *)sFacebookId
{
    
    FacebookLogin * newFacebookLogin = [[FacebookLogin alloc] init];
    newFacebookLogin.facebook_id = sFacebookId;
    newFacebookLogin.facebook_token = sToken;
    newFacebookLogin.email = email;
    
    BOOL __block bSuccess = FALSE;
    NSLog(@"*** LoginFacebook with email: %@" /*and Password: %@ ***"*/, email/*, password*/);
    
    self.email = email;
    self.facebook_id = sFacebookId;
    self.bFacebookUser = YES;
    
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    [dateFormatter setLocale:[NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"]];
    
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"];
    
    [[RKObjectManager sharedManager] postObject:newFacebookLogin
                                           path:[NSString stringWithFormat:@"/loginfacebook?createdAtLocal=%@", [dateFormatter stringFromDate:[NSDate date]]]
                                     parameters:nil
                                        success:^(RKObjectRequestOperation * operation, RKMappingResult * mappingResult)
     {
         NSDictionary * allHeaders = operation.HTTPRequestOperation.response.allHeaderFields;
         NSArray * cookies = [NSHTTPCookie cookiesWithResponseHeaderFields:allHeaders forURL:[NSURL URLWithString:RESTBASEURL]];
         NSHTTPCookieStorage * cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
         for(NSHTTPCookie *cookie in cookies)
         {
             NSLog(@"****** Cookie\n****** Login.\n****** Name: %@, Value: %@", cookie.name, cookie.value);
             if ([cookie.name isEqualToString:@"sails.sid"])
             {
                 NSLog(@"****** Asignar Cookie");
                 
                 [cookieStorage setCookie:cookie];
                 [[[RKObjectManager sharedManager]  HTTPClient] setDefaultHeader:cookie.name value:cookie.value];
             }
         }
         
         [self logInUserWithUsernameSuccess:mappingResult andVerbose:NO];
         
         AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
         if (appDelegate.finger.bLoadedFingerPrint)
         {
             [self setFingerPrint:appDelegate.finger.fingerprint];
         }
         
         
     }
                                        failure:^(RKObjectRequestOperation * operation, NSError *error)
     {
         // error login normal, logout of the facebook user
         if (self.bFacebookUser)
         {
             // logout of facebook
             FBSDKLoginManager *login = [[FBSDKLoginManager alloc] init];
             if ([FBSDKAccessToken currentAccessToken])
             {
                 [login logOut];
             }
         }
         
         
         NSLog(@"Status code: %ld",(long)operation.HTTPRequestOperation.response.statusCode);
         
         [self logInUserWithUsernameError:error withResponseString:operation.HTTPRequestOperation.responseString andVerbose:NO];
         
         NSManagedObjectContext * currentContext = [RKObjectManager sharedManager].managedObjectStore.mainQueueManagedObjectContext;
         [currentContext deleteObject:[currentContext objectWithID:[self objectID]]];
         //         [currentContext deleteObject:self];
         
         NSError * errorcd = nil;
         if (![currentContext save:&errorcd])
         {
             NSLog(@"Error saving context! %@", errorcd);
         }
     }];
    
    return bSuccess;
}


#pragma mark - logout
-(void) logOut
{
    // TODO: Ojo! cambio el alert por la accion directa, así soy
    /*
    // if it is, then sign out. Because of the menu, is sign out
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Sign Out", nil) message:NSLocalizedString(@"Are you sure to sign out?", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"No", nil) otherButtonTitles:NSLocalizedString(@"Yes", nil), nil];
    
    [alertView show];
    */
    if (self.bFacebookUser)
    {
        // logout of facebook
        FBSDKLoginManager *login = [[FBSDKLoginManager alloc] init];
        if ([FBSDKAccessToken currentAccessToken])
        {
            [login logOut];
        }
    }
    
    [self removeUserFromSystemDefaults];
    
    if (self.delegate != nil)
        [self.delegate userAccount:self didLogOut:YES];
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    
    if ([title isEqualToString:NSLocalizedString(@"Yes", nil)])
    {
        NSLog(@"User confirms Sign Out!");
        
        if (self.bFacebookUser)
        {
            // logout of facebook
            FBSDKLoginManager *login = [[FBSDKLoginManager alloc] init];
            if ([FBSDKAccessToken currentAccessToken])
            {
                [login logOut];
            }
        }
        
        [self removeUserFromSystemDefaults];
        
        if (self.delegate != nil)
            [self.delegate userAccount:self didLogOut:YES];
        
    }
}

#pragma mark - delegates for server functions

-(void) logInUserWithUsernameSuccess:(RKMappingResult *) mappingResult andVerbose:(BOOL)bVerbose
{
    // If the GS server provided an answer, check wheter that answer could be mapped into our data classes
    
    __block NSInteger downloadResult = -1;
    __block User *mappedUser = nil;//[NSEntityDescription insertNewObjectForEntityForName:@"User" inManagedObjectContext:[RKObjectManager sharedManager].managedObjectStore.mainQueueManagedObjectContext];
    
    if (mappingResult == nil)
    {
        // No mapping
        downloadResult = -1;
    }
    else if (!(mappingResult.count > 0))
    {
        // No mapping
        downloadResult = -1;
    }
    else
    {
        // The answer was mapped.
        
        // Then, check if the mapping contains the expected information
        [mappingResult.array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
         {
             // Does the answer contain any user (as expected)?
             if (([obj isKindOfClass:[User class]]))
             {
                 downloadResult = 0;
                 
                 mappedUser = obj;
                 
                 // Stop the enumeration
                 *stop = YES;
             }
         }];
        
        // The answer didn't provide the expected information (but something was mapped, actually)
        // Then assume that the only mapped information was the "code" feedback
        if (downloadResult < 0)
        {
            NSNumber * code = [[mappingResult firstObject] valueForKey:@"code"];
            
            downloadResult = code.intValue;
        }
    }
    
    NSLog(@"logInUserWithUsername succeed! Code ID: %ld", (long)downloadResult);
    [self getAllEthnicities];
    //   Code = -2 or -1 if something went wrong with the identification process
    //   Code = 0 if the identification process was correct.
    
    if (downloadResult >=0)
    {
        // Request succeed! Finish request process
        if (bVerbose)
        {
            /*
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_SIGN_IN_", nil) message:NSLocalizedString(@"_CORRECT_SIGN_IN_MSG_", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"_OK_", nil) otherButtonTitles:nil];
            
            [alertView show];
             */
        }
        mappedUser.bFacebookUser = self.bFacebookUser;
        mappedUser.passwordClear = self.passwordClear;
        [mappedUser saveUserToSystemDefaults];
        
        if (self.delegate != nil)
            [self.delegate userAccount:mappedUser didLogInSuccessfully:YES];
    }
    else
    {
        // Something went wrong with the request process...
        
        NSLog(@"Ooops! logInUserWithUsername failed.");
        
        if (bVerbose)
        {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_ERROR_", nil) message:NSLocalizedString(@"_LOG_IN_ERROR_MSG_", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"_OK_", nil) otherButtonTitles:nil];
            
            [alertView show];
        }
        
        if (self.delegate != nil)
            [self.delegate userAccount:self didLogInSuccessfully:NO];
    }
}



-(void) logInUserWithUsernameError:(NSError *)error withResponseString:(NSString *) responseString andVerbose:(BOOL)bVerbose
{
    // If upload failed, cancel identification process
    
    NSError *e = nil;
    NSData *jsonResponseString = [NSData dataWithBytes:[responseString UTF8String] length:[responseString length]];
    NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData: jsonResponseString options: NSJSONReadingMutableContainers error: &e];
    
    if (jsonArray) {
        responseString = [jsonArray valueForKey:@"raw"];
    }
    NSLog(@"Ooops! logInUserWithUsername error: *** %@Response: %@ ***", error, responseString);
    
    if (bVerbose)
    {
        NSString * message = NSLocalizedString(@"_CONNECTION_ERROR_MSG_", nil);

        if (responseString != nil)
        {
            if (![responseString  isEqualToString: @""])
                message = NSLocalizedString(responseString,nil);
        }
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_ERROR_", nil) message:message delegate:nil cancelButtonTitle:NSLocalizedString(@"_OK_", nil) otherButtonTitles:nil];
        
        
        [alertView show];
    }
    
    if (self.delegate != nil)
        [self.delegate userAccount:self didLogInSuccessfully:NO];
}


-(void) saveUserToServerDBSuccess:(RKMappingResult *) mappingResult
{
    __block NSInteger downloadResult = -1;
    
    if (mappingResult == nil)
    {
        // No mapping
        downloadResult = -1;
    }
    else if (!(mappingResult.count > 0))
    {
        // No mapping
        downloadResult = -1;
    }
    else
    {
        // The answer was mapped.
        
        // Then, check if the mapping contains the expected information
        [mappingResult.array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
         {
             // Does the answer contain any user (as expected)?
             if (([obj isKindOfClass:[User class]]))
             {
                 downloadResult = 0;
                 
                 // Stop the enumeration
                 *stop = YES;
             }
         }];
        
        // The answer didn't provide the expected information (but something was mapped, actually)
        // Then assume that the only mapped information was the "code" feedback
        if (downloadResult < 0)
        {
            NSNumber * code = [[mappingResult firstObject] valueForKey:@"code"];
            
            downloadResult = code.intValue;
        }
    }
    
    NSLog(@"saveUserToServerDB succeed! Code ID: %ld", (long)downloadResult);
    
    //   Code = -2 or -1 if something went wrong with the identification process
    //   Code = 0 if the identification process was correct.
    
    if (downloadResult >=0)
    {
        // Request succeed!
        //bSuccess = YES;
        
        [self saveUserToSystemDefaults];
        
        if (self.picImage)
        {
            [self saveUserImageToServerDBUpdating:NO];
        }
        else if(self.headerMediaPath){
            [self saveUserHeaderMediaToServerDBUpdating:NO];
        }
        else
        {
//            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_SIGN_UP_", nil) message:NSLocalizedString(@"_CORRECT_SIGNUP_MSG_", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"_OK_", nil) otherButtonTitles:nil];
//            
//            [alertView show];
            
            if (self.delegate != nil)
                [self.delegate userAccount:self didSignUpSuccessfully:YES];
            
        }
    }
    else
    {
        // Something went wrong with the request process...
        
        NSLog(@"Ooops! saveUserToServerDB failed.");

        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_ERROR_", nil) message:NSLocalizedString(@"_USR_REGISTERED_ERROR_MSG_", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"_OK_", nil) otherButtonTitles:nil];

        numRetries = 0;

        [alertView show];

        if (self.delegate != nil)
            [self.delegate userAccount:self didSignUpSuccessfully:NO];
    }
}

-(void) saveUserToServerDBSuccessError:(NSError *)error withResponseString:(NSString *) responseString
{
    // If upload failed, cancel identification process
    NSError *e = nil;
    NSData *jsonResponseString = [NSData dataWithBytes:[responseString UTF8String] length:[responseString length]];
    NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData: jsonResponseString options: NSJSONReadingMutableContainers error: &e];
    
    if (jsonArray) {
        responseString = [jsonArray valueForKey:@"raw"];
    }
    
    NSLog(@"Ooops! saveUserToServerDB error: %@ *** Response: %@ ***", error, responseString);
    
    NSString * message = NSLocalizedString(@"_CONNECTION_ERROR_MSG_", nil) ;
    if (responseString != nil)
    {
        if (![responseString  isEqualToString: @""])
            message = NSLocalizedString(responseString,nil);
    }
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_ERROR_", nil) message:message delegate:nil cancelButtonTitle:NSLocalizedString(@"_OK_", nil) otherButtonTitles:nil];
    
    [alertView show];
    
    if (self.delegate != nil)
        [self.delegate userAccount:self didSignUpSuccessfully:NO];
}

-(void) saveUserImageToServerDBSuccess:(RKMappingResult *) mappingResult updating:(BOOL) bUpdate
{
    NSLog(@"saveUserImageToServerDB succeed!");
    
    self.picture = [[mappingResult firstObject] valueForKey:@"image"];
    self.full_picture = [[mappingResult firstObject] valueForKey:@"full_picture"];
    
    [self saveUserToSystemDefaults];
    
    if(self.headerMediaPath){
        [self saveUserHeaderMediaToServerDBUpdating:NO];
    }else{
        if (self.delegate != nil)
            [self.delegate userAccount:self didSignUpSuccessfully:YES];
    }
    
}

-(void) saveUserImageToServerDBSuccessError:(NSError *)error updating:(BOOL)bUpdate
{
    // If upload failed, cancel identification process
    
    NSLog(@"Ooops! saveUserImageToServerDB error: %@", error);
    
    NSString * sMessage = NSLocalizedString(@"_SIGN_UP_ERROR_IMG_", nil);
    NSString * sTitle = NSLocalizedString(@"_SIGN_UP_", nil);
    
    if (bUpdate)
    {
        sMessage = NSLocalizedString(@"_UPDATE_ACCOUNT_ERROR_MSG_", nil);
        sTitle = NSLocalizedString(@"_UPDATE_ACCOUNT_", nil);
    }
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:sTitle message:sMessage delegate:self cancelButtonTitle:NSLocalizedString(@"_OK_", nil) otherButtonTitles:nil];
    
    [alertView show];
    
    if(self.headerMediaPath){
        [self saveUserHeaderMediaToServerDBUpdating:NO];
    }else{
        if (self.delegate != nil)
            [self.delegate userAccount:self didSignUpSuccessfully:YES];
    }
}

-(void) saveUserHeaderMediaToServerDBSuccess:(RKMappingResult *) mappingResult updating:(BOOL) bUpdate
{
    NSLog(@"saveUserHeaderMediaToServerDB succeed!");
    
    self.headerMedia = [[mappingResult firstObject] valueForKey:@"image"];
    self.headerType = [[mappingResult firstObject] valueForKey:@"header_type"];
    
    [self saveUserToSystemDefaults];
    
    
        if (self.delegate != nil)
            [self.delegate userAccount:self didSignUpSuccessfully:YES];
}

-(void) saveUserHeaderMediaToServerDBSuccessError:(NSError *)error updating:(BOOL)bUpdate
{
    // If upload failed, cancel identification process
    
    NSLog(@"Ooops! saveUserHeaderMediaToServerDB error: %@", error);
    
    NSString * sMessage = NSLocalizedString(@"_SIGN_UP_ERROR_IMG_", nil);
    NSString * sTitle = NSLocalizedString(@"_SIGN_UP_", nil);
    
    if (bUpdate)
    {
        sMessage = NSLocalizedString(@"_UPDATE_ACCOUNT_ERROR_MSG_", nil);
        sTitle = NSLocalizedString(@"_UPDATE_ACCOUNT_", nil);
    }
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:sTitle message:sMessage delegate:self cancelButtonTitle:NSLocalizedString(@"_OK_", nil) otherButtonTitles:nil];
    
    [alertView show];
    
    if (self.delegate != nil)
        [self.delegate userAccount:self didSignUpSuccessfully:YES];
}

-(void) updateUserToServerDBSuccess:(RKMappingResult *) mappingResult andVerbose:(BOOL)bVerbose
{
    __block NSInteger downloadResult = -1;
    
    if (mappingResult == nil)
    {
        // No mapping
        downloadResult = -1;
    }
    else if (!(mappingResult.count > 0))
    {
        // No mapping
        downloadResult = -1;
    }
    else
    {
        // The answer was mapped.
        
        // Then, check if the mapping contains the expected information
        [mappingResult.array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
         {
             // Does the answer contain any brand, product or variant (as expected)?
             if (([obj isKindOfClass:[User class]]))
             {
                 downloadResult = 0;
                 
                 // Stop the enumeration
                 *stop = YES;
             }
         }];
        
        // The answer didn't provide the expected information (but something was mapped, actually)
        // Then assume that the only mapped information was the "code" feedback
        if (downloadResult < 0)
        {
            NSNumber * code = [[mappingResult firstObject] valueForKey:@"code"];
            
            downloadResult = code.intValue;
        }
    }
    
    NSLog(@"updateUserToServerDB succeed! Code ID: %ld", (long)downloadResult);
    
    //   Code = -2 or -1 if something went wrong with the identification process
    //   Code = 0 if the identification process was correct.
    
    if (downloadResult >=0)
    {
        // Request succeed!
        //bSuccess = YES;
        
        [self saveUserToSystemDefaults];
        
        if (self.picImage)
        {
            [self saveUserImageToServerDBUpdating:YES];
        }
        else if(self.headerMediaPath){
            [self saveUserHeaderMediaToServerDBUpdating:YES];
        }
        else{
            if (bVerbose)
            {
                /*
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_UPDATE_ACCOUNT_", nil) message:NSLocalizedString(@"_CORRECT_UPDATE_ACCOUNT_MSG_", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"_OK_", nil) otherButtonTitles:nil];
                
                [alertView show];
                 */
            }
            
            if (self.delegate != nil)
                [self.delegate userAccount:self didSignUpSuccessfully:YES];
            
        }
    }
    else
    {
        // Something went wrong with the request process...
        
        NSLog(@"Ooops! updateUserToServerDB failed.");
        if (bVerbose)
        {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_ERROR_", nil) message:NSLocalizedString(@"_UPDATE_ACCOUNT_ERROR_MSG_", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"_OK_", nil) otherButtonTitles:nil];
            
            
            [alertView show];
        }
        numRetries = 0;
        
        if (self.delegate != nil)
            [self.delegate userAccount:self didSignUpSuccessfully:NO];
    }
}

-(void) updateUserToServerDBSuccessError:(NSError *)error withResponseString:(NSString *) responseString
{
    // If upload failed, cancel identification process
    NSError *e = nil;
    NSData *jsonResponseString = [NSData dataWithBytes:[responseString UTF8String] length:[responseString length]];
    NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData: jsonResponseString options: NSJSONReadingMutableContainers error: &e];
    
    if (jsonArray) {
        responseString = [jsonArray valueForKey:@"raw"];
    }
    
    NSLog(@"Ooops! updateUserToServerDB error: %@ *** Response: %@ ***", error, responseString);
    
    NSString * message = NSLocalizedString(@"_CONNECTION_ERROR_MSG_", nil) ;
    if (![responseString  isEqualToString: @""])
        message = NSLocalizedString(responseString,nil);
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_ERROR_", nil) message:message delegate:nil cancelButtonTitle:NSLocalizedString(@"_OK_", nil) otherButtonTitles:nil];
    
    [alertView show];
    if (self.delegate) {
        [self.delegate userAccount:self updateFinishedWithError:responseString];
    }
}
/*
-(void)awakeFromFetch
{
    [self addObserver:self forKeyPath:@"fashionistaBlogURL" options:NSKeyValueObservingOptionNew context:(__bridge void*)self];
    
    [self addObserver:self forKeyPath:@"picture" options:NSKeyValueObservingOptionNew context:(__bridge void*)self];
}

-(void)awakeFromInsert
{
    [self addObserver:self forKeyPath:@"fashionistaBlogURL" options:NSKeyValueObservingOptionNew context:(__bridge void*)self];
    
    [self addObserver:self forKeyPath:@"picture" options:NSKeyValueObservingOptionNew context:(__bridge void*)self];
}

- (void) willTurnIntoFault
{
    [super willTurnIntoFault];
    
    [self removeObserver:self forKeyPath:@"fashionistaBlogURL" context:(__bridge void*)self];
    
    [self removeObserver:self forKeyPath:@"picture" context:(__bridge void*)self];
}

- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ((__bridge id)context == self)
    {
        if([keyPath isEqualToString:@"fashionistaBlogURL"])
        {
            if (self.fashionistaBlogURL != nil)
            {
                if(!NSEqualRanges( [self.fashionistaBlogURL rangeOfString:@" "], NSMakeRange(NSNotFound, 0) ) )
                {
                    self.fashionistaBlogURL = [self.fashionistaBlogURL stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
                }
            }
        }
        else if([keyPath isEqualToString:@"picture"])
        {
            if (self.picture != nil)
            {
//                NSString * sTrimmed =[self.picture stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
//                self.picture = sTrimmed;
                if (![self.picture isEqual:@""])
                {
                    if(!([self.picture hasPrefix:PROFILESPICIMAGESBASEURL]))
                    {
                        self.picturePath = [NSString stringWithFormat:@"%@%@",PROFILESPICIMAGESBASEURL, self.picture];
                    }
                    
                    if(!NSEqualRanges( [self.picturePath rangeOfString:@" "], NSMakeRange(NSNotFound, 0) ) )
                    {
                        self.picturePath = [self.picturePath stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
                    }
                }
            }
        }
    }
    else
    {
        [super observeValueForKeyPath: keyPath ofObject: object change: change context: context];
    }
}
*/
@end

@implementation FashionistaView

@end

@implementation FashionistaViewTime

@end

@implementation UserFollowersFollowing
@end;

@implementation UserNotManaged

-(void) copyFromUser: (User *) userManaged
{
    self.address1 = userManaged.address1;
    self.address2 = userManaged.address2;
    self.addressCity = userManaged.addressCity;
    self.addressPostalCode = userManaged.addressPostalCode;
    self.addressState = userManaged.addressState;
    self.birthdate = userManaged.birthdate;
    self.bust = userManaged.bust;
    self.compensation = userManaged.compensation;
    self.country = userManaged.country;
    self.cup = userManaged.cup;
    self.datequeryvalidateprofile = userManaged.datequeryvalidateprofile;
    self.datevalidatedprofile = userManaged.datevalidatedprofile;
    self.dress = userManaged.dress;
    self.email = userManaged.email;
    self.ethnicity = userManaged.ethnicity;
    self.experience = userManaged.experience;
    self.eyecolor = userManaged.eyecolor;
    self.fashionistaBlogURL = userManaged.fashionistaBlogURL;
    self.fashionistaName = userManaged.fashionistaName;
    self.fashionistaTitle = userManaged.fashionistaTitle;
    self.gender = userManaged.gender;
    self.genre = userManaged.genre;
    self.haircolor = userManaged.haircolor;
    self.hairlength = userManaged.hairlength;
    self.heightM = userManaged.heightM;
    self.heightCm = userManaged.heightCm;
    self.idUser = userManaged.idUser;
    self.isFashionista = userManaged.isFashionista;
    self.lastname = userManaged.lastname;
    self.name = userManaged.name;
    self.password = userManaged.password;
    self.phone = userManaged.phone;
    self.picture = userManaged.picture;
    self.picturepermission = userManaged.picturepermission;
    self.piercings = userManaged.piercings;
    self.shoe = userManaged.shoe;
    self.shootnudes = userManaged.shootnudes;
    self.skincolor = userManaged.skincolor;
    self.tatoos = userManaged.tatoos;
    self.type = userManaged.typeprofession;
    self.uuid = userManaged.uuid;
    self.validatedprofile = userManaged.validatedprofile;
    self.waist = userManaged.waist;
    self.weight = userManaged.weight;
}

-(void) copyToUser:(User *)userManaged
{
    userManaged.address1 = self.address1;
    userManaged.address2 = self.address2;
    userManaged.addressCity = self.addressCity;
    userManaged.addressPostalCode = self.addressPostalCode;
    userManaged.addressState = self.addressState;
    userManaged.birthdate = self.birthdate;
    userManaged.bust = self.bust;
    userManaged.compensation = self.compensation;
    userManaged.country = self.country;
    userManaged.cup = self.cup;
    userManaged.datequeryvalidateprofile = self.datequeryvalidateprofile;
    userManaged.datevalidatedprofile = self.datevalidatedprofile;
    userManaged.dress = self.dress;
    userManaged.email = self.email;
    userManaged.ethnicity = self.ethnicity;
    userManaged.experience = self.experience;
    userManaged.eyecolor = self.eyecolor;
    userManaged.fashionistaBlogURL = self.fashionistaBlogURL;
    userManaged.fashionistaName = self.fashionistaName;
    userManaged.fashionistaTitle = self.fashionistaTitle;
    userManaged.gender = self.gender;
    userManaged.genre = self.genre;
    userManaged.haircolor = self.haircolor;
    userManaged.hairlength = self.hairlength;
    userManaged.heightM = self.heightM;
    userManaged.heightCm = self.heightCm;
    userManaged.idUser = self.idUser;
    userManaged.isFashionista = self.isFashionista;
    userManaged.lastname = self.lastname;
    userManaged.name = self.name;
    userManaged.password = self.password;
    userManaged.phone = self.phone;
    userManaged.picture = self.picture;
    userManaged.picturepermission = self.picturepermission;
    userManaged.piercings = self.piercings;
    userManaged.shoe = self.shoe;
    userManaged.shootnudes = self.shootnudes;
    userManaged.skincolor = self.skincolor;
    userManaged.tatoos = self.tatoos;
    userManaged.typeprofession = self.type;
    userManaged.uuid = self.uuid;
    userManaged.validatedprofile = self.validatedprofile;
    userManaged.waist = self.waist;
    userManaged.weight = self.weight;
}

-(NSString*) sGetTextGender
{
    NSString * sGender = @"";
    switch ([self.gender intValue])
    {
        case 0:
            // not defined so return ""
            break;
        case 1:
            sGender = NSLocalizedString(@"Male",nil);
            break;
        case 2:
            sGender = NSLocalizedString(@"Female",nil);
            break;
        case 3:
            sGender = NSLocalizedString(@"It's complicated",nil);
            break;
    }
    
    return sGender;
}

-(NSString*) sGetTextLocation
{
    NSString * sLocation = @"";
    
    if (self.addressCity)
    {
        if (![self.addressCity  isEqualToString: @""])
            sLocation = [sLocation stringByAppendingFormat:@"%@", self.addressCity];
    }
    if (self.country)
    {
        if (![self.country  isEqualToString: @""])
            sLocation = [sLocation stringByAppendingFormat:@" (%@)", self.country];
    }
    
    return sLocation;
}

@end


@implementation UserReport

@end

@implementation FacebookLogin

@end


@implementation UserUserUnfollow

@end

static char UNNOTICEDPOSTS_KEY;
static char UNFOLLOWEDPOSTS_KEY;
static char UNNOTICEDUSERS_KEY;

@implementation User (UnfollowsAndNotices)

- (NSMutableDictionary *)unnoticedPosts
{
    return objc_getAssociatedObject(self, &UNNOTICEDPOSTS_KEY);
}

- (void)setUnnoticedPosts:(NSMutableDictionary *)unnoticedPosts{
    objc_setAssociatedObject(self, &UNNOTICEDPOSTS_KEY, unnoticedPosts, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSMutableDictionary *)unfollowedPosts
{
    return objc_getAssociatedObject(self, &UNFOLLOWEDPOSTS_KEY);
}

- (void)setUnfollowedPosts:(NSMutableDictionary *)unfollowedPosts{
    objc_setAssociatedObject(self, &UNFOLLOWEDPOSTS_KEY, unfollowedPosts, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSMutableDictionary *)unnoticedUsers
{
    return objc_getAssociatedObject(self, &UNNOTICEDUSERS_KEY);
}

- (void)setUnnoticedUsers:(NSMutableDictionary *)unnoticedUsers{
    objc_setAssociatedObject(self, &UNNOTICEDUSERS_KEY, unnoticedUsers, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)dealloc{
    self.unfollowedPosts = nil;
    self.unnoticedUsers = nil;
    self.unnoticedPosts = nil;
}

- (void)getUserPostUnfollows{
    self.unfollowedPosts = [NSMutableDictionary new];
    [[RKObjectManager sharedManager] getObject:nil
                                           path:[NSString stringWithFormat:@"/postunfollow?user=%@",self.idUser]
                                     parameters:nil
                                        success:^(RKObjectRequestOperation * operation, RKMappingResult * mappingResult)
     {
         
         for(PostUserUnfollow* puF in mappingResult.array){
             if ([puF isKindOfClass:[PostUserUnfollow class]]) {
                 [self.unfollowedPosts setObject:puF forKey:puF.postId];
             }
         }
         
         
     }
                                        failure:^(RKObjectRequestOperation * operation, NSError *error)
     {
         
         
     }];
}

- (void)getUserPostUnnoticed{
    self.unnoticedPosts = [NSMutableDictionary new];
    [[RKObjectManager sharedManager] getObject:nil
                                          path:[NSString stringWithFormat:@"/postignorenotices?user=%@",self.idUser]
                                    parameters:nil
                                       success:^(RKObjectRequestOperation * operation, RKMappingResult * mappingResult)
     {
         
         for(PostUserUnfollow* puF in mappingResult.array){
             if ([puF isKindOfClass:[PostUserUnfollow class]]) {
                 [self.unnoticedPosts setObject:puF forKey:puF.postId];
             }
         }
         
         
     }
                                       failure:^(RKObjectRequestOperation * operation, NSError *error)
     {
         
         
     }];
}

- (void)getUserUserUnnoticed{
    self.unnoticedUsers = [NSMutableDictionary new];
    [[RKObjectManager sharedManager] getObject:nil
                                          path:[NSString stringWithFormat:@"/userignorenotices?user=%@",self.idUser]
                                    parameters:nil
                                       success:^(RKObjectRequestOperation * operation, RKMappingResult * mappingResult)
     {
         
         for(UserUserUnfollow* uuF in mappingResult.array){
             if ([uuF isKindOfClass:[UserUserUnfollow class]]) {
                 [self.unnoticedUsers setObject:uuF forKey:uuF.usertoignoreId];
             }
         }
         
         
     }
                                       failure:^(RKObjectRequestOperation * operation, NSError *error)
     {
         
         
     }];
}
@end

static char GROUPETHNIES_KEY;
static char GROUPSARRAY_KEY;
static char ETHNYGROUPREF_KEY;

@implementation User (Ethnicity)

- (NSMutableDictionary *)groupEthniesDict
{
    return objc_getAssociatedObject(self, &GROUPETHNIES_KEY);
}

- (void)setGroupEthniesDict:(NSMutableDictionary *)groupEthniesDict{
    objc_setAssociatedObject(self, &GROUPETHNIES_KEY, groupEthniesDict, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSMutableArray *)groupsArray
{
    return objc_getAssociatedObject(self, &GROUPSARRAY_KEY);
}

- (void)setGroupsArray:(NSMutableArray *)groupsArray{
    objc_setAssociatedObject(self, &GROUPSARRAY_KEY, groupsArray, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSMutableDictionary *)ethnyGroupRefDictionary
{
    return objc_getAssociatedObject(self, &ETHNYGROUPREF_KEY);
}

- (void)setEthnyGroupRefDictionary:(NSMutableDictionary *)ethnyGroupRefDictionary{
    objc_setAssociatedObject(self, &ETHNYGROUPREF_KEY, ethnyGroupRefDictionary, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)getAllEthnicities{
    NSMutableURLRequest *configRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/ethnicity?limit=-1", RESTBASEURL]] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:30];
    [configRequest setHTTPMethod:@"GET"];
    
    [configRequest setValue:@"application/json;charset=UTF-8" forHTTPHeaderField:@"content-type"];
    
    NSError *requestError;
    
    NSURLResponse *requestResponse;
    
    NSData *configResponseData = [NSURLConnection sendSynchronousRequest:configRequest returningResponse:&requestResponse error:&requestError];
    int statusCode = (int)[((NSHTTPURLResponse *)requestResponse) statusCode];
    
    if(!(configResponseData == nil) && statusCode != 404)
    {
        id json = [NSJSONSerialization JSONObjectWithData:configResponseData options: NSJSONReadingMutableContainers error: &requestError];
        [self processEtnicities:json];
    }
}

- (void)processEtnicities:(NSArray*)ethnicities{
    if(!self.groupEthniesDict){
        self.groupEthniesDict = [NSMutableDictionary new];
        self.ethnyGroupRefDictionary = [NSMutableDictionary new];
        self.groupsArray = [NSMutableArray new];
    }
    for (NSDictionary* ethny in ethnicities) {
        NSString* groupName = [ethny objectForKey:kGroupKey];
        NSMutableArray* groupEthnies = [self.groupEthniesDict objectForKey:groupName];
        if(!groupEthnies){
            groupEthnies = [NSMutableArray new];
            [self.groupEthniesDict setObject:groupEthnies forKey:groupName];
            [self.groupsArray addObject:groupName];
        }
        [self.ethnyGroupRefDictionary setObject:groupName forKey:[ethny objectForKey:kIdKey]];
        [groupEthnies addObject:ethny];
    }
}

@end
