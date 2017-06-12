//
//  GSPostCategoryOrderManager.m
//  GoldenSpear
//
//  Created by Adria Vernetta Rubio on 20/6/16.
//  Copyright © 2016 GoldenSpear. All rights reserved.
//

#import "GSPostCategoryOrderManager.h"
#import <CoreData/CoreData.h>
#import <RestKit/RestKit.h>
#import "AppDelegate.h"

@implementation GSPostCategoryOrderManager

+ (NSArray*)fetchObjectsWithEntityName:(NSString*)entityName andPredicate:(NSPredicate*)predicate andSorts:(NSArray*)sortDescriptors{
    
    NSManagedObjectContext *managedObjectContext = [RKObjectManager sharedManager].managedObjectStore.mainQueueManagedObjectContext;

    // Define our table/entity to use
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:managedObjectContext];
    // Setup the fetch request
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entity];
    
    if (predicate) {
        [request setPredicate:predicate];
    }
    
    if (sortDescriptors) {
        [request setSortDescriptors:sortDescriptors];
    }
    // Fetch the records and handle an error
    NSError *error;
    NSArray *mutableFetchResults = [managedObjectContext executeFetchRequest:request error:&error];
    if (!mutableFetchResults) {
        // Handle the error.
        // This is a serious error and should advise the user to restart the application
    }
    
    return mutableFetchResults;
}

+ (NSArray*)getPostCategoriesForSection:(NSInteger)section{
    NSArray* answer = nil;
    NSPredicate *pred = nil;
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"order" ascending:NO];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    
    switch (section) {
        case USERPROFILE_VC:
            pred = [NSPredicate predicateWithFormat:@"inUser = 1"];
            break;
        case DISCOVER_VC:
            pred = [NSPredicate predicateWithFormat:@"inDiscover = 1"];
            break;
        default:
            break;
    }
    
    answer = [self fetchObjectsWithEntityName:@"PostCategory" andPredicate:pred andSorts:sortDescriptors];
    
    return answer;
}

+ (NSArray*)getPostOrderingForSection:(NSInteger)section{
    NSArray* answer = nil;
    NSPredicate *pred = nil;
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"order" ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    
    switch (section) {
        case USERPROFILE_VC:
            pred = [NSPredicate predicateWithFormat:@"inUser = 1"];
            break;
        case DISCOVER_VC:
            pred = [NSPredicate predicateWithFormat:@"inDiscover = 1"];
            break;
        default:
            break;
    }
    
    answer = [self fetchObjectsWithEntityName:@"PostOrdering" andPredicate:pred andSorts:sortDescriptors];
    
    return answer;
}

+ (void)downloadCategories:(BOOL)force{
        [[RKObjectManager sharedManager] getObjectsAtPath:@"/postCategory?limit=-1"
                                               parameters:nil
                                                  success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult)
         {
             [self attemptOrderingDownload:force];
         }
                                                  failure:^(RKObjectRequestOperation *operation, NSError *error)
         {
             NSLog(@"Operation <%@> failed with error: %ld", operation.HTTPRequestOperation.request.URL, (long)operation.HTTPRequestOperation.response.statusCode);
             [self finishedDownloading];
         }];
}

+ (void)downloadOrdering:(BOOL)force{
    
        [[RKObjectManager sharedManager] getObjectsAtPath:@"/postOrder?limit=-1"
                                               parameters:nil
                                                  success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult)
         {
             [self finishedDownloading];
         }
                                                  failure:^(RKObjectRequestOperation *operation, NSError *error)
         {
             NSLog(@"Operation <%@> failed with error: %ld", operation.HTTPRequestOperation.request.URL, (long)operation.HTTPRequestOperation.response.statusCode);
             [self finishedDownloading];
         }];
}

+ (void)attemptOrderingDownload:(BOOL)force{
    BOOL mustDownload = force;
    if (!force) {
        mustDownload = ([[self getPostOrderingForSection:-1] count] == 0);
    }
    if (mustDownload) {
        [self downloadOrdering:force];
    }else{
        [self finishedDownloading];
    }
}

+ (void)attemptCategoriesDownload:(BOOL)force{
    BOOL mustDownload = force;
    if (!force) {
        mustDownload = ([[self getPostCategoriesForSection:-1] count] == 0);
    }
    if (mustDownload) {
        [self downloadCategories:force];
    }else{
        [self attemptOrderingDownload:force];
    }
}

+ (void)downloadData:(BOOL)force{
    [self attemptCategoriesDownload:force];
}

+ (void)finishedDownloading{
    [[NSNotificationCenter defaultCenter] postNotificationName:kGSPCOManagerFinishedDownloadingNotification object:nil];
}

@end
