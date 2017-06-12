//
//  KeywordFashionistaContent+CoreDataProperties.h
//  
//
//  Created by Adria Vernetta Rubio on 22/4/16.
//
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "KeywordFashionistaContent.h"

NS_ASSUME_NONNULL_BEGIN

@interface KeywordFashionistaContent (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *fashionistaContentId;
@property (nullable, nonatomic, retain) NSNumber *group;
@property (nullable, nonatomic, retain) NSString *idKeywordFashionistaContent;
@property (nullable, nonatomic, retain) NSString *keywordId;
@property (nullable, nonatomic, retain) NSNumber *xPos;
@property (nullable, nonatomic, retain) NSNumber *yPos;
@property (nullable, nonatomic, retain) FashionistaContent *fashionistaContent;
@property (nullable, nonatomic, retain) Keyword *keyword;

@end

NS_ASSUME_NONNULL_END
