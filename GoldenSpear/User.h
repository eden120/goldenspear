//
//  User.h
//  GoldenSpear
//
//  Created by Jose Antonio on 30/06/16.
//  Copyright © 2016 GoldenSpear. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Comment, FashionistaPage, FashionistaPost, Notification, Review, Wardrobe;

NS_ASSUME_NONNULL_BEGIN

@interface User : NSManagedObject

// Insert code here to declare functionality of your managed object subclass

@end

NS_ASSUME_NONNULL_END

#import "User+CoreDataProperties.h"
