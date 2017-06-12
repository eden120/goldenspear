//
//  GSAccountModuleView.m
//  GoldenSpear
//
//  Created by Adria Vernetta Rubio on 18/5/16.
//  Copyright © 2016 GoldenSpear. All rights reserved.
//

#import "GSAccountModuleView.h"

@implementation GSAccountModuleView

- (void)dealloc{
    self.theModule = nil;
}

- (id)init{
    NSArray *arrayOfViews = [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class])
                                                          owner:nil
                                                        options:nil];
    int i = 0;
    while(i<[arrayOfViews count]){
        if([[arrayOfViews objectAtIndex:i] isKindOfClass:[self class]]){
            self = [arrayOfViews objectAtIndex:i];
            self.translatesAutoresizingMaskIntoConstraints = NO;
            return self;
        }
        i++;
    }
    return nil;
}

- (void)fillModule:(User*)user withAccountModule:(GSAccountModule*)module{
    self.theModule = module;
    moduleUser = user;
}

@end
