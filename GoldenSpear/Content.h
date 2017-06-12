//
//  Content.h
//  GoldenSpear
//
//  Created by Jose Antonio Sanchez Martinez on 26/05/15.
//  Copyright (c) 2015 GoldenSpear. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Content : NSManagedObject

@property (nonatomic, retain) NSString * idContent;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) NSString * url;

@end
