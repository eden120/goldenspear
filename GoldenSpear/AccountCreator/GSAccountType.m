//
//  GSAccountType.m
//  GoldenSpear
//
//  Created by Adria Vernetta Rubio on 14/4/16.
//  Copyright © 2016 GoldenSpear. All rights reserved.
//

#import "GSAccountType.h"
#import "AppDelegate.h"
#import "GSAccountModule.h"

#define GSAccountTypeAppName    @"appName"
#define GSAccountTypeIcon       @"icon"
#define GSAccountTypeModules    @"modules"
#define GSAccountTypeId         @"id"

@implementation GSAccountType

- (void)setAccountWithDictionary:(NSDictionary*)json{
    self.appName = [json objectForKey:GSAccountTypeAppName];
    self.iconUrl = [NSString stringWithFormat:@"%@/%@",IMAGESBASEURL,[json objectForKey:GSAccountTypeIcon]];
    
    if (self.iconUrl != nil)
    {
        // Preload images in the background
        NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
            
            [UIImage cachedImageWithURL:self.iconUrl];
        }];
        
        operation.queuePriority = NSOperationQueuePriorityVeryHigh;
        
        self.preloadImagesQueue = [[NSOperationQueue alloc] init];
        self.preloadImagesQueue.maxConcurrentOperationCount = 3;
        [self.preloadImagesQueue addOperation:operation];
    }
    
    self.typeId = [json objectForKey:GSAccountTypeId];
    [self processModules:[json objectForKey:GSAccountTypeModules]];
}

- (void)processModules:(NSArray*)modules{
    NSMutableArray* theModules = [NSMutableArray new];
    for (int i =0; i<[modules count]; i++) {
        [theModules addObject:[NSNumber numberWithInt:i]];
    }
    for (NSDictionary* module in modules) {
        GSAccountModule* aModule = [GSAccountModule new];
        [aModule setModuleWithDictionary:module];
        [theModules replaceObjectAtIndex:aModule.order-1 withObject:aModule];
    }
    self.modules = theModules;
}

@end
