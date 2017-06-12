//
//  Notification+CoreDataProperties.h
//  
//
//  Created by Adria Vernetta Rubio on 17/5/16.
//
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Notification.h"

NS_ASSUME_NONNULL_BEGIN

@interface Notification (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *actionUserId;
@property (nullable, nonatomic, retain) NSString *actionUsername;
@property (nullable, nonatomic, retain) NSString *comment;
@property (nullable, nonatomic, retain) NSDate *date;
@property (nullable, nonatomic, retain) NSString *fashionistaPostId;
@property (nullable, nonatomic, retain) NSString *idNotification;
@property (nullable, nonatomic, retain) NSNumber *notificationIsNew;
@property (nullable, nonatomic, retain) NSString *postTitle;
@property (nullable, nonatomic, retain) NSString *text;
@property (nullable, nonatomic, retain) NSString *type;
@property (nullable, nonatomic, retain) NSString *userId;
@property (nullable, nonatomic, retain) NSString *video;
@property (nullable, nonatomic, retain) NSString *previewImage;
@property (nullable, nonatomic, retain) User *actionUser;

@end

NS_ASSUME_NONNULL_END
