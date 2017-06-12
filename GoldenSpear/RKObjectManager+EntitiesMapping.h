//
//  RKObjectManager+EntitiesMapping.h
//  GoldenSpear
//
//  Created by Jose Antonio Sanchez Martinez on 08/04/15.
//  Copyright (c) 2015 GoldenSpear. All rights reserved.
//

#import <RestKit/RestKit.h>
#import "User+Manage.h"
#import "SearchQuery+Manage.h"
#import "ResultsGroup+Manage.h"
#import "GSBaseElement+Manage.h"
#import "Brand+Manage.h"
#import "Product+Manage.h"
#import "ProductGroup+Manage.h"
#import "Price+Manage.h"
#import "Keyword+Manage.h"
#import "KeywordFashionistaContent+Manage.h"
#import "SuggestedKeyword+Manage.h"
#import "Feature+Manage.h"
#import "FeatureGroup+Manage.h"
#import "Content+Manage.h"
#import "Availability+Manage.h"
#import "Shop+Manage.h"
#import "Review+Manage.h"
#import "Wardrobe+Manage.h"
#import "FashionistaPage+Manage.h"
#import "FashionistaPost+Manage.h"
#import "FashionistaContent+Manage.h"
#import "Follow+Manage.h"
#import "Comment+Manage.h"
#import "PostLike+Manage.h"
#import "Notification+Manage.h"
#import "BackgroundAd+Manage.h"
#import "Share+Manage.h"
#import "VariantGroup+Manage.h"
#import "VariantGroupElement+Manage.h"
#import "POI+Manage.h"
#import "LiveStreamingCategory+Manage.h"
#import "LiveStreamingEthnicity+Manage.h"
#import "LiveStreamingInvitation+Manage.h"
#import "LiveStreaming+Manage.h"
#import "LiveStreamingPrivacy+Manage.h"


@interface RKObjectManager (EntitiesMapping)

- (void)defineMappings;

@end
