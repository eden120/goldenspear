//
//  NSManagedObject+KeyboardHelper.h
//  GoldenSpear
//
//  Created by Jose Antonio Sanchez Martinez on 02/06/15.
//  Copyright (c) 2015 GoldenSpear. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface NSManagedObject (KeyboardHelper)

+ (instancetype)keyboardObjectForUniqueIdentifier:(NSString *)uniqueIdentifier
                                     inContext:(NSManagedObjectContext *)context;

+ (instancetype)keyboardNewObjectFromDictionary:(NSDictionary *)dictionary
                                   inContext:(NSManagedObjectContext *)context;

+ (instancetype)keyboardNewObjectFromDictionary:(NSDictionary *)dictionary
                                   inContext:(NSManagedObjectContext *)context
                             autoSaveContext:(BOOL)autoSave;

+ (NSArray *)keyboardObjectsForPredicate:(NSPredicate *)predicate
                      sortDescriptors:(NSArray *)sortDescriptors
                            inContext:(NSManagedObjectContext *)context;

+ (NSArray *)keyboardObjectsForPredicate:(NSPredicate *)predicate
                            inContext:(NSManagedObjectContext *)context;

//The following may be overridden
+ (NSString *)keyboardUniqueIdentifier;

+ (BOOL)keyboardShouldAutoGenerateGloballyUniqueIdentifiers;

@end
