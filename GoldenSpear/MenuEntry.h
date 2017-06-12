//
//  MenuEntry.h
//  GoldenSpear
//
//  Created by Jose Antonio Sanchez Martinez on 14/04/15.
//  Copyright (c) 2015 GoldenSpear. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@interface MenuEntry : NSObject

@property (copy) NSString *entryText;
@property (copy) UIImage *entryIcon;
@property (copy) NSNumber *destinationVC;

@end