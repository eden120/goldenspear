//
//  MenuEntry.m
//  GoldenSpear
//
//  Created by Jose Antonio Sanchez Martinez on 14/04/15.
//  Copyright (c) 2015 GoldenSpear. All rights reserved.
//

#import "MenuEntry.h"

@implementation MenuEntry

- (void)dealloc
{
    self.entryText = nil;
    self.entryIcon = nil;
    self.destinationVC = nil;
}

@end
