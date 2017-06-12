//
//  PeopleTagClass.m
//  GoldenSpear
//
//  Created by Crane on 8/18/16.
//  Copyright © 2016 GoldenSpear. All rights reserved.
//

#import "PeopleTagClass.h"

@implementation PeopleTagClass
-(id)initWithValue:(NSString*)keywordID ContentID:(NSString*)contentID KewordContentID:(NSString*)keywordContentID SelectedGroup:(NSNumber*)selectedGroup Title:(NSString*)title XPos:(CGFloat)x Yos:(CGFloat)y {
    
    _keywordID = keywordID;
    _fashionistaContentID = contentID;
    _keywordFashionistaContentID = keywordContentID;
    _userTagName = title;
    _xPos = x;
    _yPos = y;
    _selectedGroupToAddKeyword = selectedGroup;
    
    return  self;
}
@end
