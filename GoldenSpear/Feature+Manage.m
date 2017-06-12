//
//  Feature+Manage.m
//  GoldenSpear
//
//  Created by Jose Antonio Sanchez Martinez on 24/05/15.
//  Copyright (c) 2015 GoldenSpear. All rights reserved.
//

#import "Feature+Manage.h"
#import "AppDelegate.h"
#import "NSObject+ButtonSlideView.h"
#import <objc/runtime.h>

static char INSUGGESTEDKEYWORD_KEY;

@interface Feature (PrimitiveAccessors)
- (NSString *)primitiveIcon;
@end

@implementation Feature (Manage)

-(NSString *) icon
{
    [self willAccessValueForKey:@"icon"];
    NSString *preview_image = [self primitiveIcon];
    [self didAccessValueForKey:@"icon"];
    
    if (preview_image != nil)
    {
        if(!([preview_image isEqualToString:@""]))
        {
            if(!([preview_image hasPrefix:IMAGESBASEURL]))
            {
                preview_image = [NSString stringWithFormat:@"%@%@",IMAGESBASEURL, preview_image];
            }
        }
        
        if(!NSEqualRanges( [preview_image rangeOfString:@" "], NSMakeRange(NSNotFound, 0) ) )
        {
            preview_image = [preview_image stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
        }
    }
    
    return preview_image;
}

-(NSString *) getIconForGender:(int) gender andProductCategoryParent:(ProductGroup *) pgParent andProductCategoryChild:(ProductGroup *) pgChild byDefault:(NSString *) sPathByDefault
{
    NSString * iconGeneral = self.icon;
    NSString * iconToShow = nil;
    
    NSString * sGender = [self sGetGenderInitial:gender];
    
    NSArray * arIcons = [self.icons componentsSeparatedByString:@"\n"];
    
    if (pgChild != nil)
    {
        iconToShow = [self sGetFileForProductCategory:pgChild.idProductGroup andForGender:sGender inArray:arIcons];
    }
    
    if ((pgParent != nil) && (iconToShow == nil))
    {
        iconToShow = [self sGetFileForProductCategory:pgParent.idProductGroup andForGender:sGender inArray:arIcons];
    }
    
    
    if ((iconToShow != nil) && !([iconToShow isEqualToString:@""]))
    {
        iconGeneral = [self completeIconPath:iconToShow];
    }

    if (iconGeneral != nil)
    {
        if (![iconGeneral  isEqualToString: @""])
        {
            return iconGeneral;
        }
    }
    
    return sPathByDefault;
}

-(NSString *) getIconForGender:(int) gender andProductCategoryParent:(ProductGroup *) pgParent andSubProductCategories:(NSMutableArray *) subProductCategories byDefault:(NSString *) sPathByDefault
{
    NSString * iconGeneral = self.icon;
    NSString * iconToShow = nil;
    
    NSString * sGender = [self sGetGenderInitial:gender];
    
    NSArray * arIcons = [self.icons componentsSeparatedByString:@"\n"];
    
    ProductGroup * pgSelectedChild = nil;
    NSMutableArray * allParentsSelected = nil;
    
    unsigned long iNumParents = 0;
    
    // bucle recorriendo el array de sub product categories seleccionadas
    for(ProductGroup * pgChild in subProductCategories)
    {
        NSMutableArray * allparents = [pgChild getAllParents];
        if (allparents.count > iNumParents)
        {
            allParentsSelected = allparents;
            iNumParents = allparents.count;
            pgSelectedChild = pgChild;
        }
    }
    
    BOOL bAllLineal = YES;
    for(ProductGroup * pgChild in subProductCategories)
    {
        if ([allParentsSelected containsObject:pgChild] == NO)
        {
            bAllLineal = NO;
            break;
        }
    }
    
    if ((pgSelectedChild != nil) && (bAllLineal))
    {
        // bucle recorriendo los padres buscando el primer icono que cumpla los requisitos de feature y product category
        ProductGroup * pgParentRecursive = pgSelectedChild;
        while ((pgParentRecursive != nil) && (iconToShow == nil))
        {
            iconToShow = [self sGetFileForProductCategory:pgParentRecursive.idProductGroup andForGender:sGender inArray:arIcons];
            pgParentRecursive = pgParentRecursive.parent;
        }
        
    }
    
    if ((pgParent != nil) && (iconToShow == nil))
    {
        iconToShow = [self sGetFileForProductCategory:pgParent.idProductGroup andForGender:sGender inArray:arIcons];
    }
    
    
    if ((iconToShow != nil) && !([iconToShow isEqualToString:@""]))
    {
        iconGeneral = [self completeIconPath:iconToShow];
    }
    
    if (iconGeneral != nil)
    {
        if (![iconGeneral  isEqualToString: @""])
        {
            return iconGeneral;
        }
    }
    
    return sPathByDefault;
}

-(NSString *) sGetFileForProductCategory:(NSString * )idProductCategory andForGender:(NSString *) sGender inArray:(NSArray *)arIcons
{
    NSString * sIconRes = nil;
    
    for(NSString * sIcon in arIcons)
    {
        NSRange rangeIdProductCategory = [sIcon rangeOfString:idProductCategory];
        NSRange rangeGender;
        rangeGender.location = NSNotFound;
        BOOL bWithGender = NO;
        if ([sGender isEqualToString:@""] == NO)
        {
            rangeGender = [sIcon rangeOfString:sGender];
            bWithGender = YES;
        }
        
        if ((rangeIdProductCategory.location != NSNotFound) && (bWithGender && (rangeGender.location != NSNotFound)))
        {
            return sIcon;
        }
        if ((rangeIdProductCategory.location != NSNotFound) && ((bWithGender== NO) && (rangeGender.location == NSNotFound)))
        {
            sIconRes = sIcon;
        }
    }
    
    return sIconRes;
}


-(NSString *) sGetGenderInitial:(int) gender
{
    // return the initial of the gender that we must find in the filename. This is because return _initial and not only initial
    if (gender == 1)
    {
        return @"_m";
    }
    else if (gender == 2)
    {
        return @"_w";
    }
    else if (gender == 4)
    {
        return @"_b";
    }
    else if (gender == 8)
    {
        return @"_g";
    }
    else if (gender == 16)
    {
        return @"_u";
    }
    else if (gender == 32)
    {
        return @"_k";
    }
    
    return @"";
}

- (NSString *) completeIconPath:(NSString *) sIconPath
{
    NSString * sIconFulPath = nil;
    if (sIconPath != nil)
    {
        if(!([sIconPath isEqualToString:@""]))
        {
            if(!([sIconPath hasPrefix:IMAGESBASEURL]))
            {
                sIconFulPath = [NSString stringWithFormat:@"%@%@",IMAGESBASEURL, sIconPath];
            }
        }
        
        if(!NSEqualRanges( [sIconPath rangeOfString:@" "], NSMakeRange(NSNotFound, 0) ) )
        {
            sIconFulPath = [sIconPath stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
        }
    }
    
    return sIconFulPath;
    
}

-(BOOL) isVisibleForGender:(int) gender andProductCategory:(ProductGroup *) productCategory andSubProductCategories:(NSMutableArray *) subProductCategories
{
    NSMutableArray * allproductCategories = [[NSMutableArray alloc] initWithArray:subProductCategories];
    // add teh product ctagoery main to the arr of selected
    if (productCategory != nil)
        [allproductCategories addObject:productCategory];
    
    NSString * sGender = [self sGetGenderInitial:gender];
    
    NSArray * arHidden = [self.hidden componentsSeparatedByString:@"\n"];
    
    ProductGroup * pgSelectedChild = nil;
    NSMutableArray * allParentsSelected = nil;
    
    unsigned long iNumParents = 0;
    
    // bucle recorriendo el array de sub product categories seleccionadas
    for(ProductGroup * pgChild in allproductCategories)
    {
        NSMutableArray * allparents = [pgChild getAllParents];
        if (allparents.count > iNumParents)
        {
            allParentsSelected = allparents;
            iNumParents = allparents.count;
            pgSelectedChild = pgChild;
        }
    }
    
    BOOL bAllLineal = YES;
    NSMutableArray * arProductGroupToCheck = [NSMutableArray new];
    NSMutableArray * arProductGroupVisible = [NSMutableArray new];
    
    // add the selected product group
    if (pgSelectedChild != nil)
    {
        [arProductGroupToCheck addObject:pgSelectedChild];
        [arProductGroupVisible addObject:[NSNumber numberWithBool:YES]];
    }
    
    for(ProductGroup * pgChild in allproductCategories)
    {
        if ([allParentsSelected containsObject:pgChild] == NO)
        {
            bAllLineal = NO;
            [arProductGroupToCheck addObject:pgChild];
            [arProductGroupVisible addObject:[NSNumber numberWithBool:YES]];
        }
    }
    
    
    int iIdx = 0;
    for (ProductGroup * pgToCheck in arProductGroupToCheck)
    {
        for(NSString * sHidden in arHidden)
        {
            NSRange rangeIdProductCategory = [sHidden rangeOfString:pgToCheck.idProductGroup];
            NSRange rangeGender;
            rangeGender.location = NSNotFound;
            BOOL bWithGender = NO;
            if ([sGender isEqualToString:@""] == NO)
            {
                rangeGender = [sHidden rangeOfString:sGender];
                bWithGender = YES;
            }
            
            if ((rangeIdProductCategory.location != NSNotFound) && (bWithGender && (rangeGender.location != NSNotFound)))
            {
                arProductGroupVisible[iIdx] = [NSNumber numberWithBool:NO];
                break;
            }
            if ((rangeIdProductCategory.location != NSNotFound) && ((bWithGender== NO) && (rangeGender.location == NSNotFound)))
            {
                arProductGroupVisible[iIdx] = [NSNumber numberWithBool:NO];
            }
        }
        iIdx++;
    }
    
    for(NSNumber * bVisible in arProductGroupVisible)
    {
        if ([bVisible boolValue])
        {
            return YES;
        }
    }
    
    return NO;
}

#pragma mark - Name for App

-(NSString *) getNameForApp
{
    if (self.app_name != nil)
    {
        if (![self.app_name isEqualToString: @""])
        {
            return self.app_name;
        }
    }
    
    return self.name;
}


#pragma mark - Properties

// Getter and setter for selected
- (BOOL)isInSuggestedKeywords
{
    return [(NSNumber *)objc_getAssociatedObject(self, &INSUGGESTEDKEYWORD_KEY) boolValue];
}

- (void)setIsInSuggestedKeywords:(BOOL)selected
{
    NSNumber * nsValue = [NSNumber numberWithBool:selected];
    //    NSLog(@"setSelected %@", (nsValue.boolValue?@"YES":@"NO"));
    objc_setAssociatedObject(self, &INSUGGESTEDKEYWORD_KEY, nsValue, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#pragma mark - Functions for slidebutton view


-(NSString*)toStringButtonSlideView
{
    return self.name;
//    return [self getNameForApp];
}

-(NSString*)toImageButtonSlideView
{
    return self.icon;
}

#pragma mark - Image url manage

/*
-(void)awakeFromFetch
{
    [self addObserver:self forKeyPath:@"icon" options:NSKeyValueObservingOptionNew context:(__bridge void*)self];
//    [self addObserver:self forKeyPath:@"name" options:NSKeyValueObservingOptionNew context:(__bridge void*)self];
}

-(void)awakeFromInsert
{
    [self addObserver:self forKeyPath:@"icon" options:NSKeyValueObservingOptionNew context:(__bridge void*)self];
//    [self addObserver:self forKeyPath:@"name" options:NSKeyValueObservingOptionNew context:(__bridge void*)self];
}

- (void) willTurnIntoFault
{
    [super willTurnIntoFault];
    
    [self removeObserver:self forKeyPath:@"icon" context:(__bridge void*)self];
//    [self removeObserver:self forKeyPath:@"name" context:(__bridge void*)self];
}

- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ((__bridge id)context == self)
    {
        if([keyPath isEqualToString:@"icon"])
        {
            if (self.icon != nil)
            {
                if(!([self.icon isEqualToString:@""]))
                {
                    if(!([self.icon hasPrefix:IMAGESBASEURL]))
                    {
                        self.icon = [NSString stringWithFormat:@"%@%@",IMAGESBASEURL, self.icon];
                    }
                }
                
                if(!NSEqualRanges( [self.icon rangeOfString:@" "], NSMakeRange(NSNotFound, 0) ) )
                {
                    self.icon = [self.icon stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
                }
            }
        }
        else if([keyPath isEqualToString:@"name"])
        {
            if (self.name != nil)
            {
                if(self.name != [self.name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]])
                    self.name = [self.name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            }
        }
    }
    else
    {
        [super observeValueForKeyPath: keyPath ofObject: object change: change context: context];
    }
}
*/

@end
