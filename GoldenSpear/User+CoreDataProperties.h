//
//  User+CoreDataProperties.h
//  GoldenSpear
//
//  Created by Alberto Seco on 17/8/16.
//  Copyright © 2016 GoldenSpear. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "User.h"

NS_ASSUME_NONNULL_BEGIN

@interface User (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *address1;
@property (nullable, nonatomic, retain) NSString *address2;
@property (nullable, nonatomic, retain) NSString *addressCity;
@property (nullable, nonatomic, retain) NSString *addressCity_id;
@property (nullable, nonatomic, retain) NSNumber *addressCityVisible;
@property (nullable, nonatomic, retain) NSString *addressPostalCode;
@property (nullable, nonatomic, retain) NSString *addressState;
@property (nullable, nonatomic, retain) NSString *addressState_id;
@property (nullable, nonatomic, retain) NSString *agencies;
@property (nullable, nonatomic, retain) NSDate *birthdate;
@property (nullable, nonatomic, retain) NSNumber *birthdateVisible;
@property (nullable, nonatomic, retain) NSNumber *bust;
@property (nullable, nonatomic, retain) id commentsId;
@property (nullable, nonatomic, retain) NSNumber *compensation;
@property (nullable, nonatomic, retain) NSString *country;
@property (nullable, nonatomic, retain) NSString *country_id;
@property (nullable, nonatomic, retain) NSDate *createdAt;
@property (nullable, nonatomic, retain) NSNumber *cup;
@property (nullable, nonatomic, retain) NSDate *datequeryvalidateprofile;
@property (nullable, nonatomic, retain) NSDate *datevalidatedprofile;
@property (nullable, nonatomic, retain) NSNumber *dress;
@property (nullable, nonatomic, retain) NSString *email;
@property (nullable, nonatomic, retain) NSNumber *ethnicity;
@property (nullable, nonatomic, retain) NSNumber *ethnicityVisible;
@property (nullable, nonatomic, retain) NSNumber *experience;
@property (nullable, nonatomic, retain) NSNumber *eyecolor;
@property (nullable, nonatomic, retain) NSString *facebook_id;
@property (nullable, nonatomic, retain) NSString *facebook_token;
@property (nullable, nonatomic, retain) NSString *facebook_url;
@property (nullable, nonatomic, retain) NSString *fashionistaBlogURL;
@property (nullable, nonatomic, retain) NSString *fashionistaName;
@property (nullable, nonatomic, retain) id fashionistaPagesId;
@property (nullable, nonatomic, retain) NSString *fashionistaTitle;
@property (nullable, nonatomic, retain) NSString *flicker_id;
@property (nullable, nonatomic, retain) NSString *flicker_token;
@property (nullable, nonatomic, retain) NSString *full_picture;
@property (nullable, nonatomic, retain) NSNumber *gender;
@property (nullable, nonatomic, retain) NSNumber *genderVisible;
@property (nullable, nonatomic, retain) NSString *genre;
@property (nullable, nonatomic, retain) NSNumber *genreVisible;
@property (nullable, nonatomic, retain) NSNumber *haircolor;
@property (nullable, nonatomic, retain) NSNumber *hairlength;
@property (nullable, nonatomic, retain) NSString *headerMedia;
@property (nullable, nonatomic, retain) NSString *headerType;
@property (nullable, nonatomic, retain) NSNumber *heightCm;
@property (nullable, nonatomic, retain) NSNumber *heightM;
@property (nullable, nonatomic, retain) NSNumber *hip;
@property (nullable, nonatomic, retain) NSString *idUser;
@property (nullable, nonatomic, retain) NSString *instagram_id;
@property (nullable, nonatomic, retain) NSString *instagram_token;
@property (nullable, nonatomic, retain) NSString *instagram_url;
@property (nullable, nonatomic, retain) NSNumber *insteam;
@property (nullable, nonatomic, retain) NSString *instruments;
@property (nullable, nonatomic, retain) NSNumber *isFashionista;
@property (nullable, nonatomic, retain) NSNumber *isPublic;
@property (nullable, nonatomic, retain) NSString *lastname;
@property (nullable, nonatomic, retain) NSString *linkedin_id;
@property (nullable, nonatomic, retain) NSString *linkedin_token;
@property (nullable, nonatomic, retain) NSString *linkedin_url;
@property (nullable, nonatomic, retain) NSString *name;
@property (nullable, nonatomic, retain) NSNumber *neck;
@property (nullable, nonatomic, retain) id notificationsId;
@property (nullable, nonatomic, retain) NSString *password;
@property (nullable, nonatomic, retain) NSString *phone;
@property (nullable, nonatomic, retain) NSString *phonecallingcode;
@property (nullable, nonatomic, retain) NSString *picture;
@property (nullable, nonatomic, retain) NSNumber *picturepermission;
@property (nullable, nonatomic, retain) NSNumber *piercings;
@property (nullable, nonatomic, retain) NSString *pinterest_id;
@property (nullable, nonatomic, retain) NSString *pinterest_token;
@property (nullable, nonatomic, retain) NSString *politicalParty;
@property (nullable, nonatomic, retain) NSNumber *politicalPartyVisible;
@property (nullable, nonatomic, retain) NSString *politicalView;
@property (nullable, nonatomic, retain) NSNumber *politicalViewVisible;
@property (nullable, nonatomic, retain) NSNumber *relationship;
@property (nullable, nonatomic, retain) NSNumber *relationshipVisible;
@property (nullable, nonatomic, retain) NSString *religion;
@property (nullable, nonatomic, retain) NSNumber *religionVisible;
@property (nullable, nonatomic, retain) id reviewsId;
@property (nullable, nonatomic, retain) NSNumber *shoe;
@property (nullable, nonatomic, retain) NSNumber *shootnudes;
@property (nullable, nonatomic, retain) NSNumber *skincolor;
@property (nullable, nonatomic, retain) NSNumber *sleeve;
@property (nullable, nonatomic, retain) NSString *snapchat_id;
@property (nullable, nonatomic, retain) NSString *snapchat_token;
@property (nullable, nonatomic, retain) NSString *specialization;
@property (nullable, nonatomic, retain) NSNumber *tatoos;
@property (nullable, nonatomic, retain) NSString *tellusmore;
@property (nullable, nonatomic, retain) NSString *tumblr_id;
@property (nullable, nonatomic, retain) NSString *tumblr_token;
@property (nullable, nonatomic, retain) NSString *twitter_id;
@property (nullable, nonatomic, retain) NSString *twitter_token;
@property (nullable, nonatomic, retain) NSString *twitter_url;
@property (nullable, nonatomic, retain) NSNumber *typemeasures;
@property (nullable, nonatomic, retain) NSNumber *typeprofession;
@property (nullable, nonatomic, retain) NSString *typeprofessionId;
@property (nullable, nonatomic, retain) NSString *uuid;
@property (nullable, nonatomic, retain) NSNumber *validatedprofile;
@property (nullable, nonatomic, retain) NSNumber *waist;
@property (nullable, nonatomic, retain) id wardrobesId;
@property (nullable, nonatomic, retain) NSNumber *weight;
@property (nullable, nonatomic, retain) NSNumber *emailvalidated;
@property (nullable, nonatomic, retain) NSString *emailvalidatedcode;
@property (nullable, nonatomic, retain) NSSet<Comment *> *comments;
@property (nullable, nonatomic, retain) NSSet<FashionistaPage *> *fashionistaPages;
@property (nullable, nonatomic, retain) NSSet<FashionistaPost *> *fashionistaPosts;
@property (nullable, nonatomic, retain) NSSet<Notification *> *notifications;
@property (nullable, nonatomic, retain) NSSet<Review *> *reviews;
@property (nullable, nonatomic, retain) NSSet<Wardrobe *> *wardrobes;

@end

@interface User (CoreDataGeneratedAccessors)

- (void)addCommentsObject:(Comment *)value;
- (void)removeCommentsObject:(Comment *)value;
- (void)addComments:(NSSet<Comment *> *)values;
- (void)removeComments:(NSSet<Comment *> *)values;

- (void)addFashionistaPagesObject:(FashionistaPage *)value;
- (void)removeFashionistaPagesObject:(FashionistaPage *)value;
- (void)addFashionistaPages:(NSSet<FashionistaPage *> *)values;
- (void)removeFashionistaPages:(NSSet<FashionistaPage *> *)values;

- (void)addFashionistaPostsObject:(FashionistaPost *)value;
- (void)removeFashionistaPostsObject:(FashionistaPost *)value;
- (void)addFashionistaPosts:(NSSet<FashionistaPost *> *)values;
- (void)removeFashionistaPosts:(NSSet<FashionistaPost *> *)values;

- (void)addNotificationsObject:(Notification *)value;
- (void)removeNotificationsObject:(Notification *)value;
- (void)addNotifications:(NSSet<Notification *> *)values;
- (void)removeNotifications:(NSSet<Notification *> *)values;

- (void)addReviewsObject:(Review *)value;
- (void)removeReviewsObject:(Review *)value;
- (void)addReviews:(NSSet<Review *> *)values;
- (void)removeReviews:(NSSet<Review *> *)values;

- (void)addWardrobesObject:(Wardrobe *)value;
- (void)removeWardrobesObject:(Wardrobe *)value;
- (void)addWardrobes:(NSSet<Wardrobe *> *)values;
- (void)removeWardrobes:(NSSet<Wardrobe *> *)values;

@end

NS_ASSUME_NONNULL_END
