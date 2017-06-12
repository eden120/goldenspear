//
//  TagHistory+CoreDataProperties.h
//  
//
//  Created by Adria Vernetta Rubio on 18/5/16.
//
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "TagHistory.h"

NS_ASSUME_NONNULL_BEGIN

@interface TagHistory (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *commentId;
@property (nullable, nonatomic, retain) NSString *keywordId;
@property (nullable, nonatomic, retain) NSString *postId;
@property (nullable, nonatomic, retain) NSString *userId;
@property (nullable, nonatomic, retain) NSString *taggedUserId;
@property (nullable, nonatomic, retain) NSString *taggerPicture;
@property (nullable, nonatomic, retain) NSString *taggerName;
@property (nullable, nonatomic, retain) NSString *postPreview;
@property (nullable, nonatomic, retain) NSString *idTagHistory;
@property (nullable, nonatomic, retain) NSDate *date;
@property (nullable, nonatomic, retain) NSString *type;

@end

NS_ASSUME_NONNULL_END
