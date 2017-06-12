//
//  User+Manage.h
//  GoldenSpear
//
//  Created by Jose Antonio Sanchez Martinez on 08/04/15.
//  Copyright (c) 2015 GoldenSpear. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "User+CoreDataProperties.h"
#import "Wardrobe.h"
#import "Review.h"

@class User;

// Set up a delegate to notify the view controller when the user logs in or out
@protocol UserDelegate

- (void)userAccount:(User *)user didLogInSuccessfully:(BOOL)bLogInSuccess;
- (void)userAccount:(User *)user didLogOut:(BOOL)bLogOutSuccess;

- (void)userAccount:(User *)user didSignUpSuccessfully:(BOOL)bSignUpSuccess;
-(void) userAccount:(User*)user results:(NSArray*)results;

@optional
- (void)userAccount:(User *)user updateFinishedWithError:(NSString*)errorString;

@end

@interface User (Manage)

// Fill properties
-(void)setUserWithUUID:(NSString *)newUUID andUserID: (NSString *)newUserID andName:(NSString *)newName andSurname:(NSString *)newSurname andEmail:(NSString *)newEmail andPassword:(NSString *)newPassword andPhone:(NSString *)newPhone andBirthdate:(NSDate *)newBirthdate andGender:(NSNumber *)newGender andPicpermision:(BOOL)newPicpermission andPicPath:(NSString *)newPicPath andPic:(UIImage *) newPic andWardrobes:(NSSet *)newWardrobes andReviews:(NSSet *)newReviews andCountry:(NSString *)newCountry andState:(NSString *)newState andCity:(NSString *)newCity andAddress1:(NSString *)newAddress1 andAddress2:(NSString *)newAddress2 andPostalCode:(NSString *)newPostalCode andUserName: (NSString *)newUsername andWebsite: (NSString *)newWebsite andBio: (NSString *)newBio;

// Save user to iOS defaults system
- (BOOL)saveUserToSystemDefaults;
- (void)removeUserFromSystemDefaults;

// Save user information to the GS database
- (BOOL)saveUserToServerDB;

// Update user information to the GS database
- (BOOL)updateUserToServerDBVerbose:(BOOL) bVerbose;


// Log in user
- (BOOL)logInUserWithUsername:(NSString *)email andPassword:(NSString *)password andVerbose:(BOOL)bVerbose;

// Log in with facebook
- (BOOL) loginFacebookWithEmail:(NSString *) email andToken:(NSString *)sToken andFacebookID:(NSString *)sFacebookId;

// Log out user
- (void)logOut;

// fingerprint
- (void)setFingerPrint:(NSString *) fingerprint;

-(NSString*) sGetTextGender;
-(NSString*) sGetTextLocation;
-(NSString*) sGetTextProfession;
-(NSString*) sGetTextCup;
-(NSString*) sGetTextDress;
-(NSString*) sGetTextShoe;
-(NSString*) sGetTextHairColor;
-(NSString*) sGetTextHairLength;
-(NSString*) sGetTextEyeColor;
-(NSString*) sGetTextSkinColor;
-(NSString*) sGetTextEthnicity;
-(NSString*) sGetTextShootnudes;
-(NSString*) sGetTextTatoos;
-(NSString*) sGetTextPiercings;
-(NSString*) sGetTextRealtionship;
-(NSString*) sGetTextMeasuring;
-(NSString*) sGetTextExperience;
-(NSString*) sGetTextCompensation;
-(NSString*) sGetTextGenre;
+(NSString *) sGetTextGenreFromString:(NSString *)sGenreString;

-(BOOL) isUserComplete;
+(User*) getUserWithId:(NSString*)userId;

- (void)copyAllFields:(User*)outUser;
-(void) copyLocationFields:(User *)user;

// Track delegate
@property (assign) id <UserDelegate> delegate;
//@property (nonatomic, retain) NSString * picturePath;
@property UIImage * picImage;
@property id headerMediaPath;
@property NSString * passwordClear;
@property NSString * fingerprint;
@property BOOL bFacebookUser;

@end

@interface UserNotManaged: NSObject
@property (nonatomic, retain) NSString *address1;
@property (nonatomic, retain) NSString *address2;
@property (nonatomic, retain) NSString *addressCity;
@property (nonatomic, retain) NSString *addressPostalCode;
@property (nonatomic, retain) NSString *addressState;
@property (nonatomic, retain) NSDate *birthdate;
@property (nonatomic, retain) NSString *country;
@property (nonatomic, retain) NSString *email;
@property (nonatomic, retain) NSString *fashionistaBlogURL;
@property (nonatomic, retain) NSString *fashionistaName;
@property (nonatomic, retain) NSString *fashionistaTitle;
@property (nonatomic, retain) NSNumber *gender;
@property (nonatomic, retain) NSString *idUser;
@property (nonatomic, retain) NSNumber *isFashionista;
@property (nonatomic, retain) NSString *lastname;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *password;
@property (nonatomic, retain) NSString *phone;
@property (nonatomic, retain) NSString *picture;
@property (nonatomic, retain) NSNumber *picturepermission;
@property (nonatomic, retain) NSString *uuid;
@property (nonatomic, retain) NSNumber *type;
@property (nonatomic, retain) NSNumber *heightM;
@property (nonatomic, retain) NSNumber *heightCm;
@property (nonatomic, retain) NSNumber *weight;
@property (nonatomic, retain) NSNumber *bust;
@property (nonatomic, retain) NSNumber *waist;
@property (nonatomic, retain) NSNumber *cup;
@property (nonatomic, retain) NSNumber *dress;
@property (nonatomic, retain) NSNumber *shoe;
@property (nonatomic, retain) NSNumber *haircolor;
@property (nonatomic, retain) NSNumber *hairlength;
@property (nonatomic, retain) NSNumber *eyecolor;
@property (nonatomic, retain) NSNumber *skincolor;
@property (nonatomic, retain) NSNumber *ethnicity;
@property (nonatomic, retain) NSNumber *shootnudes;
@property (nonatomic, retain) NSNumber *tatoos;
@property (nonatomic, retain) NSNumber *piercings;
@property (nonatomic, retain) NSNumber *experience;
@property (nonatomic, retain) NSString *compensation;
@property (nonatomic, retain) NSNumber *genre;
@property (nonatomic, retain) NSDate *datequeryvalidateprofile;
@property (nonatomic, retain) NSDate *datevalidatedprofile;
@property (nonatomic, retain) NSNumber *validatedprofile;

-(void) copyFromUser: (User *) userManaged;
-(void) copyToUser:(User *) userManaged;
-(NSString*) sGetTextGender;
-(NSString*) sGetTextLocation;

@end

@interface FashionistaView : NSObject

@property (nonatomic, retain) NSString * fashionistaId;
@property (nonatomic, retain) NSString * userId;
@property (nonatomic, retain) NSString * statProductQueryId;
@property (nonatomic, retain) NSString * fingerprint;
@property (nonatomic, retain) NSDate * localtime;

@end

@interface FashionistaViewTime : NSObject

@property (nonatomic, retain) NSDate * startTime;
@property (nonatomic, retain) NSDate * endTime;
@property (nonatomic, retain) NSString * fashionistaId;
@property (nonatomic, retain) NSString * userId;
@property (nonatomic, retain) NSString * statProductQueryId;
@property (nonatomic, retain) NSString * fingerprint;

@end

@interface UserFollowersFollowing : NSObject 

@property (nonatomic, retain) NSNumber * followers;
@property (nonatomic, retain) NSNumber * followings;

@end;

@interface UserReport : NSObject

@property (nonatomic, retain) NSString * reportedUserId;
@property (nonatomic, retain) NSString * userId;
@property (nonatomic, retain) NSNumber * reportType;

@end

@interface FacebookLogin : NSObject

@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) NSString * facebook_id;
@property (nonatomic, retain) NSString * facebook_token;

@end


@interface UserUserUnfollow : NSObject

@property (nonatomic, retain) NSString * usertoignoreId;
@property (nonatomic, retain) NSString * userId;
@property (nonatomic, retain) NSString * uufId;

@end

@interface User (UnfollowsAndNotices)

@property (nonatomic, retain) NSMutableDictionary* unfollowedPosts;
@property (nonatomic, retain) NSMutableDictionary* unnoticedPosts;
@property (nonatomic, retain) NSMutableDictionary* unnoticedUsers;

- (void)getUserPostUnfollows;
- (void)getUserPostUnnoticed;
- (void)getUserUserUnnoticed;

@end

@interface User (Ethnicity)

#define kGroupKey   @"group"
#define kIdKey      @"id"
#define kEthnicityKey   @"ethnicity"
#define kNameKey    @"name"
#define kOtherKey   @"other"

@property (nonatomic, retain) NSMutableDictionary* groupEthniesDict;
@property (nonatomic, retain) NSMutableArray* groupsArray;
@property (nonatomic, retain) NSMutableDictionary* ethnyGroupRefDictionary;

- (void)getAllEthnicities;

@end
