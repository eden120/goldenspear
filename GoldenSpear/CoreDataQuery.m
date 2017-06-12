//
//  CoreDataQuery.m
//  GoldenSpear
//
//  Created by Alberto Seco on 15/2/16.
//  Copyright © 2016 GoldenSpear. All rights reserved.
//

#import "CoreDataQuery.h"

@implementation CoreDataQuery
{
    // dictionaries
    NSMutableDictionary * dictBrandsById;
    NSMutableDictionary * dictBrandsByName;
    NSMutableDictionary * dictFeaturesById;
    NSMutableDictionary * dictFeaturesByName;
    NSMutableDictionary * dictProductGroupsById;
    NSMutableDictionary * dictProductGroupsByName;
    NSMutableDictionary * dictProductGroupsByAppName;
    NSMutableDictionary * dictFeatureGroupsById;
    NSMutableDictionary * dictFeatureGroupsByName;
    
    __block BOOL bLoadingLocalDatabase;
    __block BOOL bLoadedBrands;
    __block BOOL bLoadedFeatures;
    __block BOOL bLoadedProductCategories;
    __block BOOL bLoadedFeaturesGroups;
}


#pragma mark - Singleton
+ (CoreDataQuery *)sharedCoreDataQuery
{
    static CoreDataQuery *sharedMyCoreDataQuery = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyCoreDataQuery = [[self alloc] init];
    });
    return sharedMyCoreDataQuery;
}

- (id)init
{
    if (self = [super init])
    {
    }
    return self;
}

-(void) initDataFromLocalDatabase
{
//    if ((bLoadingLocalDatabase == NO) && (bLoadedFeaturesGroups == NO))
    {
        NSLog(@"initDataFromLocalDatabase");
        bLoadingLocalDatabase = YES;
        //dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        
        bLoadedBrands = NO;
        bLoadedFeatures = NO;
        bLoadedFeaturesGroups = NO;
        bLoadedProductCategories = NO;
        
        if (dictBrandsById != nil)
            [ dictBrandsById removeAllObjects];
        if (dictBrandsByName != nil)
            [ dictBrandsByName removeAllObjects];
        dictBrandsById = [[NSMutableDictionary alloc] init];
        dictBrandsByName = [[NSMutableDictionary alloc] init];
        [self getAllBrandsToDict];
        bLoadedBrands = YES;
        
        if (dictProductGroupsById != nil)
            [ dictProductGroupsById removeAllObjects];
        if (dictProductGroupsByName != nil)
            [ dictProductGroupsByName removeAllObjects];
        if (dictProductGroupsByAppName != nil)
            [ dictProductGroupsByAppName removeAllObjects];
        dictProductGroupsById = [[NSMutableDictionary alloc] init];
        dictProductGroupsByName = [[NSMutableDictionary alloc] init];
        dictProductGroupsByAppName = [[NSMutableDictionary alloc] init];
        [self getAllProductGroupsToDict];
        bLoadedProductCategories = YES;
        
        if (dictFeaturesById != nil)
            [ dictFeaturesById removeAllObjects];
        if (dictFeaturesByName != nil)
            [ dictFeaturesByName removeAllObjects];
        dictFeaturesById = [[NSMutableDictionary alloc] init];
        dictFeaturesByName = [[NSMutableDictionary alloc] init];
        [self getAllFeaturesToDict];
        bLoadedFeatures = YES;
        
        if (dictFeatureGroupsById != nil)
            [ dictFeatureGroupsById removeAllObjects];
        if (dictFeatureGroupsByName != nil)
            [ dictFeatureGroupsByName removeAllObjects];
        dictFeatureGroupsById = [[NSMutableDictionary alloc] init];
        dictFeatureGroupsByName = [[NSMutableDictionary alloc] init];
        [self getAllFeatureGroupsToDict];
        bLoadedFeaturesGroups = YES;
        
        bLoadingLocalDatabase = NO;
    }
}

#pragma mark - CoreData queries

// Initialize a specific Fetched Results Controller to fetch the local keywords in order to force user to select one
- (NSFetchedResultsController *)fetchedResultsControllerWithEntity:(NSString *)entityName andPredicate:(NSString *)predicate withString:(NSString *)stringForPredicate sortingWithKey:(NSString *)sortKey ascending:(BOOL)ascending
{
    NSFetchedResultsController * keywordsFetchedResultsController = nil;
    NSFetchRequest * keywordssFetchRequest = nil;
    NSManagedObjectContext *currentContext = [RKObjectManager sharedManager].managedObjectStore.mainQueueManagedObjectContext;
    
    if (keywordssFetchRequest == nil)
    {
        if(!(stringForPredicate == nil))
        {
            if(!([stringForPredicate isEqualToString:@""]))
            {
                keywordssFetchRequest = [[NSFetchRequest alloc] init];
                
                // Entity to look for
                
                NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:currentContext];
                
                [keywordssFetchRequest setEntity:entity];
                
                // Filter results
                
                [keywordssFetchRequest setPredicate:[NSPredicate predicateWithFormat:predicate, stringForPredicate]];
                
                // Sort results
                
                NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:sortKey ascending:ascending];
                
                [keywordssFetchRequest setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
                
                [keywordssFetchRequest setFetchBatchSize:20];
            }
        }
    }
    
    if(keywordssFetchRequest)
    {
        // Initialize Fetched Results Controller
        
        //NSSortDescriptor *tmpSortDescriptor = (NSSortDescriptor *)[_wardrobesFetchRequest sortDescriptors].firstObject;
        
        NSFetchedResultsController *fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:keywordssFetchRequest managedObjectContext:currentContext sectionNameKeyPath:nil cacheName:nil];
        
        keywordsFetchedResultsController = fetchedResultsController;
        
        //        keywordsFetchedResultsController.delegate = self;
    }
    
    if(keywordsFetchedResultsController)
    {
        // Perform fetch
        
        NSError *error = nil;
        
        if (![keywordsFetchedResultsController performFetch:&error])
        {
            NSLog(@"Couldn't fetch elements. Unresolved error: %@, %@", error, [error userInfo]);
            
            return nil;
        }
    }
    
    return keywordsFetchedResultsController;
}

- (NSFetchedResultsController *)fetchedResultsControllerWithEntity:(NSString *)entityName andPredicateObject:(NSPredicate *)predicate sortingWithKey:(NSString *)sortKey ascending:(BOOL)ascending
{
    NSFetchedResultsController * keywordsFetchedResultsController = nil;
    NSFetchRequest * keywordssFetchRequest = nil;
    NSManagedObjectContext *currentContext = [RKObjectManager sharedManager].managedObjectStore.mainQueueManagedObjectContext;
    
    if (keywordssFetchRequest == nil)
    {
        if(!(predicate == nil))
        {
            keywordssFetchRequest = [[NSFetchRequest alloc] init];
            
            // Entity to look for
            
            NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:currentContext];
            
            [keywordssFetchRequest setEntity:entity];
            
            // Filter results
            
            [keywordssFetchRequest setPredicate:predicate];
            
            // Sort results
            
            NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:sortKey ascending:ascending];
            
            [keywordssFetchRequest setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
            
            [keywordssFetchRequest setFetchBatchSize:20];
        }
    }
    
    if(keywordssFetchRequest)
    {
        // Initialize Fetched Results Controller
        
        //NSSortDescriptor *tmpSortDescriptor = (NSSortDescriptor *)[_wardrobesFetchRequest sortDescriptors].firstObject;
        
        NSFetchedResultsController *fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:keywordssFetchRequest managedObjectContext:currentContext sectionNameKeyPath:nil cacheName:nil];
        
        keywordsFetchedResultsController = fetchedResultsController;
        
        //        keywordsFetchedResultsController.delegate = self;
    }
    
    if(keywordsFetchedResultsController)
    {
        // Perform fetch
        
        NSError *error = nil;
        
        if (![keywordsFetchedResultsController performFetch:&error])
        {
            NSLog(@"Couldn't fetch elements. Unresolved error: %@, %@", error, [error userInfo]);
            
            return nil;
        }
    }
    
    return keywordsFetchedResultsController;
}

#pragma mark - [ProductGroup]

-(ProductGroup *) getProductGroupFromName:(NSString *) name
{
    if (dictProductGroupsByName != nil)
    {
        ProductGroup * tmpProductGroup = [dictProductGroupsByName objectForKey:name];
        if (tmpProductGroup == nil)
        {
            if (dictProductGroupsByAppName != nil)
            {
                tmpProductGroup = [dictProductGroupsByAppName objectForKey:name];
            }
        }
        return tmpProductGroup;
    }
    
    // Fetch keywords to force selecting one of them
    NSFetchedResultsController * keywordsFetchedResultsController = nil;
    
    //    NSString *regexString  = [NSString stringWithFormat:@"%@.*", [name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
    
    keywordsFetchedResultsController = [self fetchedResultsControllerWithEntity:@"ProductGroup" andPredicate:@"name matches[cd] %@" withString:name sortingWithKey:@"idProductGroup" ascending:YES];
    
    
    if (!(keywordsFetchedResultsController == nil))
    {
        if ([[keywordsFetchedResultsController fetchedObjects] count] == 0)
        {
            keywordsFetchedResultsController = [self fetchedResultsControllerWithEntity:@"ProductGroup" andPredicate:@"app_name matches[cd] %@" withString:name sortingWithKey:@"idProductGroup" ascending:YES];
            
        }
        
        
        for (int i = 0; i < [[keywordsFetchedResultsController fetchedObjects] count]; i++)
        {
            ProductGroup * tmpProductGroup = [[keywordsFetchedResultsController fetchedObjects] objectAtIndex:i];
            
            if(!(tmpProductGroup == nil))
            {
                if(!(tmpProductGroup.idProductGroup == nil))
                {
                    if(!([tmpProductGroup.idProductGroup isEqualToString:@""]))
                    {
                        return tmpProductGroup;
                    }
                }
            }
        }
    }
    return nil;
}

-(ProductGroup *) getProductGroupFromId:(NSString *) idProductGroup
{
    if (dictProductGroupsById != nil)
    {
        return [dictProductGroupsById objectForKey:idProductGroup];
    }
    
    // Fetch keywords to force selecting one of them
    NSFetchedResultsController * keywordsFetchedResultsController = nil;
    
    keywordsFetchedResultsController = [self fetchedResultsControllerWithEntity:@"ProductGroup" andPredicate:@"idProductGroup = %@" withString:idProductGroup sortingWithKey:@"idProductGroup" ascending:YES];
    
    if (!(keywordsFetchedResultsController == nil))
    {
        for (int i = 0; i < [[keywordsFetchedResultsController fetchedObjects] count]; i++)
        {
            ProductGroup * tmpProductGroup = [[keywordsFetchedResultsController fetchedObjects] objectAtIndex:i];
            
            if(!(tmpProductGroup == nil))
            {
                if(!(tmpProductGroup.idProductGroup == nil))
                {
                    if(!([tmpProductGroup.idProductGroup isEqualToString:@""]))
                    {
                        return tmpProductGroup;
                    }
                }
            }
        }
    }
    return nil;
}

-(ProductGroup *) getProductGroupParentFromId:(NSString *) idProductGroup
{
    ProductGroup * tmpProductGroup = [self getProductGroupFromId:idProductGroup];
    
    if (tmpProductGroup != nil)
    {
        ProductGroup * productGroupParent = [tmpProductGroup getTopParent];
        
        return productGroupParent;
    }
    
    return nil;
}

-(void) getAllProductGroupsToDict
{
    // Fetch keywords to force selecting one of them
    NSFetchedResultsController * keywordsFetchedResultsController = nil;
    
    //NSString *regexString  = [NSString stringWithFormat:@"%@.*", [name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
    
    //    keywordsFetchedResultsController = [self fetchedResultsControllerWithEntity:@"Brand" andPredicate:@"name matches[cd] %@" withString:name sortingWithKey:@"idBrand" ascending:YES];
    keywordsFetchedResultsController = [self fetchedResultsControllerWithEntity:@"ProductGroup" andPredicate:@"NOT (idProductGroup = %@)" withString:@"0" sortingWithKey:@"idProductGroup" ascending:YES];
    
    
    if (!(keywordsFetchedResultsController == nil))
    {
        for (int i = 0; i < [[keywordsFetchedResultsController fetchedObjects] count]; i++)
        {
            ProductGroup * tmpProductGroup = [[keywordsFetchedResultsController fetchedObjects] objectAtIndex:i];
            
            if(!(tmpProductGroup == nil))
            {
                if(!(tmpProductGroup.idProductGroup == nil))
                {
                    if(!([tmpProductGroup.idProductGroup isEqualToString:@""]))
                    {
                        [dictProductGroupsById setObject:tmpProductGroup forKey:tmpProductGroup.idProductGroup];
                        [dictProductGroupsByName setObject:tmpProductGroup forKey:tmpProductGroup.name];
                        [dictProductGroupsByAppName setObject:tmpProductGroup forKey:tmpProductGroup.app_name];
                    }
                }
            }
        }
    }
}

#pragma mark - [Features]

-(NSMutableArray *) getFeaturesOfFeatureGroupByName: (NSString *)sNameFeatureGroup
{
    sNameFeatureGroup = [[sNameFeatureGroup lowercaseString] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    NSMutableArray * arFeaturesOfFeatureGroup = [[NSMutableArray alloc] init];
    // Fetch keywords to force selecting one of them
    NSFetchedResultsController * keywordsFetchedResultsController = nil;
    
    keywordsFetchedResultsController = [self fetchedResultsControllerWithEntity:@"FeatureGroup" andPredicate:@"name matches[cd] %@" withString:sNameFeatureGroup sortingWithKey:@"idFeatureGroup" ascending:YES];
    if (!(keywordsFetchedResultsController == nil))
    {
        for (int i = 0; i < [[keywordsFetchedResultsController fetchedObjects] count]; i++)
        {
            FeatureGroup * tmpFeatureGroup = [[keywordsFetchedResultsController fetchedObjects] objectAtIndex:i];
            
            if(!(tmpFeatureGroup == nil))
            {
                if(!(tmpFeatureGroup.idFeatureGroup == nil))
                {
                    if(!([tmpFeatureGroup.idFeatureGroup isEqualToString:@""]))
                    {
                        NSMutableArray * allChildrenOfFeatureGroup = [tmpFeatureGroup getAllChildren];
                        for (FeatureGroup * fg in allChildrenOfFeatureGroup)
                        {
                            for (Feature *f in fg.features)
                            {
                                if ([arFeaturesOfFeatureGroup containsObject:f] == NO)
                                {
                                    [arFeaturesOfFeatureGroup addObject:f];
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    return arFeaturesOfFeatureGroup;
    
}

-(Feature *)getFeatureFromId:(NSString *)idFeature
{
    if (dictFeaturesById)
    {
        return [dictFeaturesById objectForKey:idFeature];
    }
    
    // Fetch keywords to force selecting one of them
    NSFetchedResultsController * keywordsFetchedResultsController = nil;
    
    keywordsFetchedResultsController = [self fetchedResultsControllerWithEntity:@"Feature" andPredicate:@"idFeature = %@" withString:idFeature sortingWithKey:@"idFeature" ascending:YES];
    
    
    if (!(keywordsFetchedResultsController == nil))
    {
        for (int i = 0; i < [[keywordsFetchedResultsController fetchedObjects] count]; i++)
        {
            Feature * tmpFeature = [[keywordsFetchedResultsController fetchedObjects] objectAtIndex:i];
            
            if(!(tmpFeature == nil))
            {
                if(!(tmpFeature.idFeature == nil))
                {
                    if(!([tmpFeature.idFeature isEqualToString:@""]))
                    {
                        return tmpFeature;
                    }
                }
            }
        }
    }
    return nil;
}

-(Feature *)getFeatureFromName:(NSString *)sName
{
    if (dictFeaturesByName != nil)
    {
        Feature * tmpFeature = [dictFeaturesByName objectForKey:sName];
        return tmpFeature;
    }
    
    // Fetch keywords to force selecting one of them
    NSFetchedResultsController * keywordsFetchedResultsController = nil;
    
    keywordsFetchedResultsController = [self fetchedResultsControllerWithEntity:@"Feature" andPredicate:@"name matches[cd] %@" withString:sName sortingWithKey:@"idFeature" ascending:YES];
    
    
    if (!(keywordsFetchedResultsController == nil))
    {
        for (int i = 0; i < [[keywordsFetchedResultsController fetchedObjects] count]; i++)
        {
            Feature * tmpFeature = [[keywordsFetchedResultsController fetchedObjects] objectAtIndex:i];
            
            if(!(tmpFeature == nil))
            {
                if(!(tmpFeature.idFeature == nil))
                {
                    if(!([tmpFeature.idFeature isEqualToString:@""]))
                    {
                        return tmpFeature;
                    }
                }
            }
        }
    }
    return nil;
}

-(void) getAllFeaturesToDict
{
    // Fetch keywords to force selecting one of them
    NSFetchedResultsController * keywordsFetchedResultsController = nil;
    
    //NSString *regexString  = [NSString stringWithFormat:@"%@.*", [name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
    
    //    keywordsFetchedResultsController = [self fetchedResultsControllerWithEntity:@"Brand" andPredicate:@"name matches[cd] %@" withString:name sortingWithKey:@"idBrand" ascending:YES];
    keywordsFetchedResultsController = [self fetchedResultsControllerWithEntity:@"Feature" andPredicate:@"NOT (idFeature = %@)" withString:@"0" sortingWithKey:@"idFeature" ascending:YES];
    
    
    if (!(keywordsFetchedResultsController == nil))
    {
        for (int i = 0; i < [[keywordsFetchedResultsController fetchedObjects] count]; i++)
        {
            Feature * tmpFeature = [[keywordsFetchedResultsController fetchedObjects] objectAtIndex:i];
            
            if(!(tmpFeature == nil))
            {
                if(!(tmpFeature.idFeature == nil))
                {
                    if(!([tmpFeature.idFeature isEqualToString:@""]))
                    {
                        [dictFeaturesById setObject:tmpFeature forKey:tmpFeature.idFeature];
                        [dictFeaturesByName setObject:tmpFeature forKey:tmpFeature.name];
                    }
                }
            }
        }
    }
}

#pragma mark - [FeatureGroup]

-(FeatureGroup *)getFeatureGroupFromName:(NSString *)name
{
    if (dictFeatureGroupsByName != nil)
    {
        FeatureGroup * tmpFeatureGroup = [dictFeatureGroupsByName objectForKey:name];
        return tmpFeatureGroup;
    }
    
    // Fetch keywords to force selecting one of them
    NSFetchedResultsController * keywordsFetchedResultsController = nil;
    
    keywordsFetchedResultsController = [self fetchedResultsControllerWithEntity:@"FeatureGroup" andPredicate:@"name matches[cd] %@" withString:name sortingWithKey:@"idFeatureGroup" ascending:YES];
    
    
    if (!(keywordsFetchedResultsController == nil))
    {
        for (int i = 0; i < [[keywordsFetchedResultsController fetchedObjects] count]; i++)
        {
            FeatureGroup * tmpFeatureGroup = [[keywordsFetchedResultsController fetchedObjects] objectAtIndex:i];
            
            if(!(tmpFeatureGroup == nil))
            {
                if(!(tmpFeatureGroup.idFeatureGroup == nil))
                {
                    if(!([tmpFeatureGroup.idFeatureGroup isEqualToString:@""]))
                    {
                        return tmpFeatureGroup;
                    }
                }
            }
        }
    }
    return nil;
}

-(FeatureGroup *) getFeatureGroupFromFeatureName:(NSString *) name
{
    // Fetch keywords to force selecting one of them
    NSFetchedResultsController * keywordsFetchedResultsController = nil;
    
    keywordsFetchedResultsController = [self fetchedResultsControllerWithEntity:@"Feature" andPredicate:@"name matches[cd] %@" withString:name sortingWithKey:@"idFeature" ascending:YES];
    
    if (!(keywordsFetchedResultsController == nil))
    {
        for (int i = 0; i < [[keywordsFetchedResultsController fetchedObjects] count]; i++)
        {
            Feature * tmpFeature = [[keywordsFetchedResultsController fetchedObjects] objectAtIndex:i];
            
            if(!(tmpFeature == nil))
            {
                if(!(tmpFeature.idFeature == nil))
                {
                    if(!([tmpFeature.idFeature isEqualToString:@""]))
                    {
                        return [tmpFeature.featureGroup getTopParent];
                    }
                }
            }
        }
    }
    return nil;
}

-(Keyword *) getKeywordFromKeywordName:(NSString *) name
{
    // Fetch keywords to force selecting one of them
    NSFetchedResultsController * keywordsFetchedResultsController = nil;
    
    keywordsFetchedResultsController = [self fetchedResultsControllerWithEntity:@"Keyword" andPredicate:@"name matches[cd] %@" withString:name sortingWithKey:@"idKeyword" ascending:YES];
    
    if (!(keywordsFetchedResultsController == nil))
    {
        for (int i = 0; i < [[keywordsFetchedResultsController fetchedObjects] count]; i++)
        {
            Keyword * tmpKeyword = [[keywordsFetchedResultsController fetchedObjects] objectAtIndex:i];
            
            if(!(tmpKeyword == nil))
            {
                if(!(tmpKeyword.idKeyword == nil))
                {
                    if(!([tmpKeyword.idKeyword isEqualToString:@""]))
                    {
                        return tmpKeyword;
                    }
                }
            }
        }
    }
    return nil;
}


-(FeatureGroup *)getFeatureGroupFromId:(NSString *)idFeatureGroup
{
    if (dictFeatureGroupsById != nil)
    {
        return [dictFeatureGroupsById objectForKey:idFeatureGroup];
    }
    // Fetch keywords to force selecting one of them
    NSFetchedResultsController * keywordsFetchedResultsController = nil;
    
    keywordsFetchedResultsController = [self fetchedResultsControllerWithEntity:@"FeatureGroup" andPredicate:@"idFeatureGroup = %@" withString:idFeatureGroup sortingWithKey:@"idFeatureGroup" ascending:YES];
    
    
    if (!(keywordsFetchedResultsController == nil))
    {
        for (int i = 0; i < [[keywordsFetchedResultsController fetchedObjects] count]; i++)
        {
            FeatureGroup * tmpFeatureGroup = [[keywordsFetchedResultsController fetchedObjects] objectAtIndex:i];
            
            if(!(tmpFeatureGroup == nil))
            {
                if(!(tmpFeatureGroup.idFeatureGroup == nil))
                {
                    if(!([tmpFeatureGroup.idFeatureGroup isEqualToString:@""]))
                    {
                        return tmpFeatureGroup;
                    }
                }
            }
        }
    }
    return nil;
}

-(NSString *) getChildrenFeatureGroupIdForPredicate:(NSMutableArray *) childrenFeatureGroupId
{
    NSString * sFilter = @"";
    
    int iIdx = 0;
    for (NSString * sIdFeatureGroup in childrenFeatureGroupId)
    {
        NSString *sFilterName;
        if (iIdx == 0)
        {
            sFilterName = [NSString stringWithFormat:@"(featureGroupId=='%@')", sIdFeatureGroup];
        }
        else{
            sFilterName = [NSString stringWithFormat:@" OR (featureGroupId=='%@')", sIdFeatureGroup];
        }
        sFilter = [sFilter stringByAppendingString:sFilterName];
        
        iIdx++;
    }
    
    return sFilter;
}

-(void) getAllFeatureGroupsToDict
{
    NSFetchedResultsController * keywordsFetchedResultsController = nil;
    
    keywordsFetchedResultsController = [self fetchedResultsControllerWithEntity:@"FeatureGroup" andPredicate:@"NOT (idFeatureGroup = %@)" withString:@"0" sortingWithKey:@"idFeatureGroup" ascending:YES];
    
    
    if (!(keywordsFetchedResultsController == nil))
    {
        for (int i = 0; i < [[keywordsFetchedResultsController fetchedObjects] count]; i++)
        {
            FeatureGroup * tmpFeatureGroup = [[keywordsFetchedResultsController fetchedObjects] objectAtIndex:i];
            
            if(!(tmpFeatureGroup == nil))
            {
                if(!(tmpFeatureGroup.idFeatureGroup == nil))
                {
                    if(!([tmpFeatureGroup.idFeatureGroup isEqualToString:@""]))
                    {
                        if (tmpFeatureGroup.name != nil)
                        {
                            [dictFeatureGroupsById setObject:tmpFeatureGroup forKey:tmpFeatureGroup.idFeatureGroup];
                            FeatureGroup * fg = [dictFeatureGroupsByName objectForKey:tmpFeatureGroup.name];
                            if (fg == nil)
                            {
                                [dictFeatureGroupsByName setObject:tmpFeatureGroup forKey:tmpFeatureGroup.name];
                            }
                            else
                            {
                                NSLog(@"Feature: %@ - %@ - %@", tmpFeatureGroup.name, tmpFeatureGroup.idFeatureGroup, fg.idFeatureGroup);
                            }
                        }
                    }
                }
            }
        }
    }
}


#pragma mark - [Brand]

-(Brand *) getBrandFromName:(NSString *)name
{
    if (dictBrandsByName != nil)
    {
        Brand * tmpBrand = [dictBrandsByName objectForKey:name];
        return tmpBrand;
    }
    
    // Fetch keywords to force selecting one of them
    NSFetchedResultsController * keywordsFetchedResultsController = nil;
    
    keywordsFetchedResultsController = [self fetchedResultsControllerWithEntity:@"Brand" andPredicate:@"name matches[cd] %@" withString:name sortingWithKey:@"idBrand" ascending:YES];
    
    if (!(keywordsFetchedResultsController == nil))
    {
        for (int i = 0; i < [[keywordsFetchedResultsController fetchedObjects] count]; i++)
        {
            Brand * tmpBrand = [[keywordsFetchedResultsController fetchedObjects] objectAtIndex:i];
            
            if(!(tmpBrand == nil))
            {
                if(!(tmpBrand.idBrand == nil))
                {
                    if(!([tmpBrand.idBrand isEqualToString:@""]))
                    {
                        return tmpBrand;
                    }
                }
            }
        }
    }
    return nil;
}

-(Brand *) getBrandFromId:(NSString *)idBrand
{
    if (dictBrandsById != nil)
    {
        return [dictBrandsById objectForKey:idBrand];
    }
    
    // Fetch keywords to force selecting one of them
    NSFetchedResultsController * keywordsFetchedResultsController = nil;
    
    //NSString *regexString  = [NSString stringWithFormat:@"%@.*", [name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
    
    //    keywordsFetchedResultsController = [self fetchedResultsControllerWithEntity:@"Brand" andPredicate:@"name matches[cd] %@" withString:name sortingWithKey:@"idBrand" ascending:YES];
    keywordsFetchedResultsController = [self fetchedResultsControllerWithEntity:@"Brand" andPredicate:@"idBrand = %@" withString:idBrand sortingWithKey:@"idBrand" ascending:YES];
    
    
    if (!(keywordsFetchedResultsController == nil))
    {
        for (int i = 0; i < [[keywordsFetchedResultsController fetchedObjects] count]; i++)
        {
            Brand * tmpBrand = [[keywordsFetchedResultsController fetchedObjects] objectAtIndex:i];
            
            if(!(tmpBrand == nil))
            {
                if(!(tmpBrand.idBrand == nil))
                {
                    if(!([tmpBrand.idBrand isEqualToString:@""]))
                    {
                        return tmpBrand;
                    }
                }
            }
        }
    }
    return nil;
}

-(NSMutableArray *) getAllBrands
{
    NSMutableArray * arrAllbrands = [[NSMutableArray alloc] init];
    // Fetch keywords to force selecting one of them
    NSFetchedResultsController * keywordsFetchedResultsController = nil;
    
    keywordsFetchedResultsController = [self fetchedResultsControllerWithEntity:@"Brand" andPredicate:@"NOT (idBrand = %@)" withString:@"0" sortingWithKey:@"idBrand" ascending:YES];
    
    if (!(keywordsFetchedResultsController == nil))
    {
        for (int i = 0; i < [[keywordsFetchedResultsController fetchedObjects] count]; i++)
        {
            Brand * tmpBrand = [[keywordsFetchedResultsController fetchedObjects] objectAtIndex:i];
            
            if(!(tmpBrand == nil))
            {
                if(!(tmpBrand.idBrand == nil))
                {
                    if(!([tmpBrand.idBrand isEqualToString:@""]))
                    {
                        [arrAllbrands addObject:tmpBrand];
                    }
                }
            }
        }
    }
    return arrAllbrands;
}

-(NSMutableArray *) getAllProductGroup
{
    NSMutableArray * arrAllProducts = [[NSMutableArray alloc] init];
    // Fetch keywords to force selecting one of them
    NSFetchedResultsController * keywordsFetchedResultsController = nil;
    
    keywordsFetchedResultsController = [self fetchedResultsControllerWithEntity:@"ProductGroup"  andPredicate:@"NOT (idProductGroup = %@)" withString:@"0" sortingWithKey:@"idProductGroup" ascending:YES];
    
    if (!(keywordsFetchedResultsController == nil))
    {
        for (int i = 0; i < [[keywordsFetchedResultsController fetchedObjects] count]; i++)
        {
            ProductGroup * tmpProduct = [[keywordsFetchedResultsController fetchedObjects] objectAtIndex:i];
            
            if(!(tmpProduct == nil))
            {
                if(!(tmpProduct.idProductGroup == nil))
                {
                    if(!([tmpProduct.idProductGroup isEqualToString:@""]))
                    {
                        [arrAllProducts addObject:tmpProduct];
                    }
                }
            }
        }
    }
    return arrAllProducts;
}

-(void) getAllBrandsToDict
{
    // Fetch keywords to force selecting one of them
    NSFetchedResultsController * keywordsFetchedResultsController = nil;
    
    //NSString *regexString  = [NSString stringWithFormat:@"%@.*", [name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
    
    //    keywordsFetchedResultsController = [self fetchedResultsControllerWithEntity:@"Brand" andPredicate:@"name matches[cd] %@" withString:name sortingWithKey:@"idBrand" ascending:YES];
    keywordsFetchedResultsController = [self fetchedResultsControllerWithEntity:@"Brand" andPredicate:@"NOT (idBrand = %@)" withString:@"0" sortingWithKey:@"idBrand" ascending:YES];
    
    
    if (!(keywordsFetchedResultsController == nil))
    {
        for (int i = 0; i < [[keywordsFetchedResultsController fetchedObjects] count]; i++)
        {
            Brand * tmpBrand = [[keywordsFetchedResultsController fetchedObjects] objectAtIndex:i];
            
            if(!(tmpBrand == nil))
            {
                if(!(tmpBrand.idBrand == nil))
                {
                    if(!([tmpBrand.idBrand isEqualToString:@""]))
                    {
                        [dictBrandsById setObject:tmpBrand forKey:tmpBrand.idBrand];
                        [dictBrandsByName setObject:tmpBrand forKey:tmpBrand.name];
                    }
                }
            }
        }
    }
}

#pragma mark - [Keyword]

-(Keyword *) getKeywordFromId:(NSString *)idKeyword
{
    // Fetch keywords to force selecting one of them
    NSFetchedResultsController * keywordsFetchedResultsController = nil;
    
    NSString *regexString  = idKeyword; //[NSString stringWithFormat:@"%@.*", [name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
    
    keywordsFetchedResultsController = [self fetchedResultsControllerWithEntity:@"Keyword" andPredicate:@"idKeyword = %@" withString:regexString sortingWithKey:@"idKeyword" ascending:YES];
    
    
    if (!(keywordsFetchedResultsController == nil))
    {
        for (int i = 0; i < [[keywordsFetchedResultsController fetchedObjects] count]; i++)
        {
            Keyword * tmpKeyword = [[keywordsFetchedResultsController fetchedObjects] objectAtIndex:i];
            
            if(!(tmpKeyword == nil))
            {
                if(!(tmpKeyword.idKeyword == nil))
                {
                    if(!([tmpKeyword.idKeyword isEqualToString:@""]))
                    {
                        return tmpKeyword;
                    }
                }
            }
        }
    }
    return nil;
}

-(NSObject *) getKeywordElementForName:(NSString *) sNameKeyword
{
    //get the appDelegate
    
    Brand* brand = [self getBrandFromName:sNameKeyword];
    if (brand != nil)
    {
        return brand;
    }
    
    ProductGroup* pg = [self getProductGroupFromName:sNameKeyword];
    if (pg != nil)
    {
        return pg;
    }
    
    FeatureGroup* fg = [self getFeatureGroupFromFeatureName:sNameKeyword];
    if (fg!= nil)
    {
        return fg;
    }
    
    Keyword* kw = [self getKeywordFromKeywordName:sNameKeyword];
    if (kw!= nil)
    {
        if (kw.productCategoryId != nil)
        {
            ProductGroup* pg = [self getProductGroupFromId:kw.productCategoryId];
            return pg;
        }
        if (kw.featureId != nil)
        {
            Feature* feat = [self getFeatureFromId:kw.featureId];
            return feat;
        }
        if (kw.brandId != nil)
        {
            Brand* brand = [self getBrandFromId:kw.brandId];
            return brand;
        }
        
        return kw;
    }
    
    return nil;
}

@end
