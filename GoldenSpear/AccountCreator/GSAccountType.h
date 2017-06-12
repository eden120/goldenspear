//
//  GSAccountType.h
//  GoldenSpear
//
//  Created by Adria Vernetta Rubio on 14/4/16.
//  Copyright © 2016 GoldenSpear. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GSAccountType : NSObject

// Preloaded images queue.
@property (nonatomic, strong) NSOperationQueue *preloadImagesQueue;

@property (nonatomic,retain) NSString* appName;
@property (nonatomic,retain) NSString* iconUrl;
@property (nonatomic,retain) NSString* typeId;
@property (nonatomic,retain) NSArray* modules;

- (void)setAccountWithDictionary:(NSDictionary*)json;

@end
