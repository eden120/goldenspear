//
//  PeopleTagClass.h
//  GoldenSpear
//
//  Created by Crane on 8/18/16.
//  Copyright © 2016 GoldenSpear. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FashionistaPostViewController.h"

@interface PeopleTagClass : NSObject
@property (nonatomic, strong) NSString * keywordID;
@property (nonatomic, strong) NSString * fashionistaContentID;
@property (nonatomic, strong) NSString * keywordFashionistaContentID;
@property (nonatomic, strong) NSString *userTagName;
@property NSNumber * selectedGroupToAddKeyword;
@property CGFloat xPos;
@property CGFloat yPos;
-(id)initWithValue:(NSString*)keywordID ContentID:(NSString*)contentID KewordContentID:(NSString*)keywordContentID SelectedGroup:(NSNumber*)selectedGroup Title:(NSString*)title XPos:(CGFloat)x Yos:(CGFloat)y;

@end
