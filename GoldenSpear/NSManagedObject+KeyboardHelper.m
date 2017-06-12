//
//  NSManagedObject+KeyboardHelper.m
//  GoldenSpear
//
//  Created by Jose Antonio Sanchez Martinez on 02/06/15.
//  Copyright (c) 2015 GoldenSpear. All rights reserved.
//

#import <objc/runtime.h>
#import "NSManagedObject+KeyboardHelper.h"
#import "KeyboardCoreDataManager.h"
#import "KeyboardIDGenerator.h"


@implementation NSManagedObject (KeyboardHelper)

+ (NSString *)keyboardUniqueIdentifier
{
    return @"objectId";
}

+ (BOOL)keyboardShouldAutoGenerateGloballyUniqueIdentifiers
{
    return YES;
}

+ (instancetype)keyboardObjectForUniqueIdentifier:(NSString *)uniqueIdentifier
                                     inContext:(NSManagedObjectContext *)context
{
    return [self keyboardObjectForAttribute:[self keyboardUniqueIdentifier]
                           matchingValue:uniqueIdentifier
                               inContext:context];
}

+ (instancetype)keyboardNewObjectFromDictionary:(NSDictionary *)dictionary
                                   inContext:(NSManagedObjectContext *)context
{
    return [self keyboardNewObjectFromDictionary:dictionary
                                    inContext:context
                              autoSaveContext:YES];
}

+ (instancetype)keyboardNewObjectFromDictionary:(NSDictionary *)dictionary
                                   inContext:(NSManagedObjectContext *)context
                             autoSaveContext:(BOOL)autoSave;
{
    if (!dictionary) {
        return nil;
    }
    
    NSString *uniqueIdentifierKey = [self keyboardUniqueIdentifier];
    
    NSMutableDictionary *mutableInfo = [dictionary mutableCopy];
    
    if ([self keyboardShouldAutoGenerateGloballyUniqueIdentifiers]) {
        if (!dictionary[uniqueIdentifierKey]) {
            NSString *objectId = [keyboardIDGenerator uniqueIdentifier];
            [mutableInfo setObject:objectId forKey:uniqueIdentifierKey];
        } else {
            @throw [NSException exceptionWithName:@"KeyboardAutogeneratableIdentifierException"
                                           reason:[NSString stringWithFormat:@"`%@` is configured to auto generate unique Identifiers but there was a custom unique identifier of `%@` specified. This is an internal inconsistency and can be fixed by either setting `shouldAutoGenerateGloballyUniqueIdentifiers` to NO or removing the custom unique identifier from the passed dictionary.", NSStringFromClass([self class]), uniqueIdentifierKey]
                                         userInfo:dictionary];
        }
    }
    
    id object = nil;
    
    if (dictionary[uniqueIdentifierKey]) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%@ = %@", uniqueIdentifierKey, [mutableInfo[uniqueIdentifierKey] description]];
        NSArray *matches = [self keyboardObjectsForPredicate:predicate
                                                inContext:context];
        
        if (!matches || ([matches count] >= 1)) {
            @throw [NSException exceptionWithName:@"keyboardFetchException"
                                           reason:[NSString stringWithFormat:@"Could not insert object for dictionary `%@`. The unique identifier was either not new or there was an error executing the fetch for it. Maybe its unique identifier is not as unique as it should be?", dictionary]
                                         userInfo:dictionary];
        } else {
            object = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([self class])
                                                   inManagedObjectContext:context];
        }
    } else {
        object = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([self class])
                                               inManagedObjectContext:context];
    }
    
    
    for (NSString *key in mutableInfo) {
        Class propertyClass = [object keyboardClassOfPropertyNamed:key
                                                inObjectOfClass:[self class]];
        
        if ([[mutableInfo[key] class] isSubclassOfClass:propertyClass]) {
            if (mutableInfo[key]) {
                [object setValue:mutableInfo[key] forKey:key];
            }
        } else {
            @throw [NSException exceptionWithName:@"KeyboardPropertyTypeMismatchException"
                                           reason:[NSString stringWithFormat:@"Could not insert value `%@` to property of class `%@`. Its type does not match class in Dictionary `%@`.", key, propertyClass, [mutableInfo[key] class]]
                                         userInfo:dictionary];
        }
    }
    
    if (autoSave) {
        [KeyboardCoreDataManager saveContext:context];
    }
    
    return object;
    
}

+ (NSArray *)keyboardObjectsForPredicate:(NSPredicate *)predicate
                      sortDescriptors:(NSArray *)sortDescriptors
                            inContext:(NSManagedObjectContext *)context
{
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([self class])];
    fetchRequest.returnsObjectsAsFaults = NO;
    fetchRequest.sortDescriptors = sortDescriptors;
    fetchRequest.predicate = predicate;
    
    NSError *error = nil;
    NSArray *result = [context executeFetchRequest:fetchRequest error:&error];
    
    if (error) {
        @throw [NSException exceptionWithName:@"KeyboardFetchException"
                                       reason:[NSString stringWithFormat:@"Could get objects for predicate `%@`. Error: `%@`.", predicate, error]
                                     userInfo:nil];
    }
    
    return result;
}

+ (NSArray *)keyboardObjectsForPredicate:(NSPredicate *)predicate
                            inContext:(NSManagedObjectContext *)context
{
    NSArray *sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"objectId" ascending:YES]];
    return [self keyboardObjectsForPredicate:predicate
                          sortDescriptors:sortDescriptors
                                inContext:context];
}

#pragma mark - private helper methods

+ (instancetype)keyboardObjectForAttribute:(NSString *)attribute
                          matchingValue:(NSString *)value
                              inContext:(NSManagedObjectContext *)context
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%@ = %@", attribute, [value description]];
    NSArray *matches = [self keyboardObjectsForPredicate:predicate
                                            inContext:context];
    
    if ([matches count] == 1) {
        return [matches lastObject];
    }
    
    return nil;
}

- (Class)keyboardClassOfPropertyNamed:(NSString *)propertyName
                   inObjectOfClass:(Class)class
{
    Class propertyClass = nil;
    NSString *className = NSStringFromClass(class);
    objc_property_t property = class_getProperty(NSClassFromString(className), [propertyName UTF8String]);
    NSString *propertyAttributes = [NSString stringWithCString:property_getAttributes(property) encoding:NSUTF8StringEncoding];
    NSArray *splitPropertyAttributes = [propertyAttributes componentsSeparatedByString:@","];
    
    if (splitPropertyAttributes.count > 0) {
        // xcdoc://ios//library/prerelease/ios/documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtPropertyIntrospection.html
        NSString *encodeType = splitPropertyAttributes[0];
        NSArray *splitEncodeType = [encodeType componentsSeparatedByString:@"\""];
        
        if ([splitEncodeType count] > 1) {
            NSString *className = splitEncodeType[1];
            propertyClass = NSClassFromString(className);
        } else {
            propertyClass = [NSObject class];
        }
    }
    
    return propertyClass;
}

@end
