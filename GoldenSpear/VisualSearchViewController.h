//
//  VisualSearchViewController.h
//  GoldenSpear
//
//  Created by Jose Antonio Sanchez Martinez on 30/05/15.
//  Copyright (c) 2015 GoldenSpear. All rights reserved.
//

#import "BaseViewController.h"
#include "CaptureManager.h"

// Possible visual search contexts
typedef enum visualSearchContext
{
    PRODUCT_VISUAL_SEARCH,
    FASHIONISTAPOSTS_VISUAL_SEARCH,
    
    maxVisualSearchContext
}
visualSearchContext;

@interface VisualSearchViewController : BaseViewController <UINavigationControllerDelegate,UIImagePickerControllerDelegate>

@property (retain) CaptureManager *captureManager;
@property UIImage *identificationImage;
@property visualSearchContext currentVisualSearchContext;

@end
