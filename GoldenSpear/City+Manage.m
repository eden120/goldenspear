//
//  City+Manage.m
//  GoldenSpear
//
//  Created by Alberto Seco on 27/10/15.
//  Copyright © 2015 GoldenSpear. All rights reserved.
//

#import "City+Manage.h"
#import "StateRegion+Manage.h"

@implementation City (Manage)

-(NSString *) getNameWithFullStates
{
    NSString *sRes = self.name;
    if (self.stateregion != nil)
    {
        StateRegion * firstState = self.stateregion;
        StateRegion * secondState = firstState.parentstateregion;
        sRes = [sRes stringByAppendingFormat:@" (%@", firstState.name];
        if (secondState != nil)
        {
            sRes = [sRes stringByAppendingFormat:@" - %@", secondState.name];
        }
        sRes = [sRes stringByAppendingFormat:@")"];
    }
    
    return sRes;
}

-(NSString *) getNameWithState
{
    NSString *sRes = self.name;
    if (self.stateregion != nil)
    {
        StateRegion * firstState = self.stateregion;
        sRes = [sRes stringByAppendingFormat:@" (%@", firstState.name];
        sRes = [sRes stringByAppendingFormat:@")"];
    }
    
    return sRes;
}

-(NSString *) getNameFullStates
{
    NSString *sRes = @"";
    if (self.stateregion != nil)
    {
        StateRegion * firstState = self.stateregion;
        StateRegion * secondState = firstState.parentstateregion;
        sRes = [sRes stringByAppendingFormat:@"%@", firstState.name];
        if (secondState != nil)
        {
            sRes = [sRes stringByAppendingFormat:@" - %@", secondState.name];
        }
    }
    
    return sRes;
}

-(NSString *) getNameOFState
{
    NSString *sRes = @"";
    if (self.stateregion != nil)
    {
        StateRegion * firstState = self.stateregion;
        sRes = [sRes stringByAppendingFormat:@"%@", firstState.name];
    }
    
    return sRes;
}

@end
