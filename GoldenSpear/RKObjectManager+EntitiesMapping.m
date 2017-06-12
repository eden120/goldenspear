//
//  RKObjectManager+EntitiesMapping.m
//  GoldenSpear
//
//  Created by Jose Antonio Sanchez Martinez on 08/04/15.
//  Copyright (c) 2015 GoldenSpear. All rights reserved.
//

#import "RKObjectManager+EntitiesMapping.h"

@implementation RKObjectManager (EntitiesMapping)

- (void)defineMappings
{
    //// --------------------------------------------------////
    //// ---------------- ENTITIES MAPPING ----------------////
    //// --------------------------------------------------////
    
    
    // User
    
    // Instance RKEntityMapping
    RKEntityMapping *userMapping = [RKEntityMapping mappingForEntityForName:@"User" inManagedObjectStore:[RKManagedObjectStore defaultStore]];
    
    // Assign identificationAttributes ensuring that all objects stored in Core Data will have unique IDs
    userMapping.identificationAttributes = @[@"idUser"];
    
    // Add attributes mapping. The dictionary maps attributes on the JSON response to properties of the object in the data model. JSON : COREDATA
    [userMapping addAttributeMappingsFromDictionary:@{
                                                      @"id" : @"idUser",
                                                      @"uuid" : @"uuid",
                                                      @"birthDate" : @"birthdate",
                                                      @"email" : @"email",
                                                      @"emailvalidatedcode": @"emailvalidatedcode",
                                                      @"emailvalidated": @"emailvalidated",
                                                      @"gender" : @"gender",
                                                      @"name" : @"name",
                                                      @"password" : @"password",
                                                      @"phone" : @"phone",
                                                      @"phonecallingcode" : @"phonecallingcode",
                                                      @"picture" : @"picture",
                                                      @"picturepermission" : @"picturepermission",
                                                      @"lastname" : @"lastname",
                                                      @"country" : @"country",
                                                      @"addressState" : @"addressState",
                                                      @"addressCity" : @"addressCity",
                                                      @"country_id" : @"country_id",
                                                      @"addressState_id" : @"addressState_id",
                                                      @"addressCity_id" : @"addressCity_id",
                                                      @"addressPostalCode" : @"addressPostalCode",
                                                      @"address1" : @"address1",
                                                      @"address2" : @"address2",
                                                      @"fashionista" : @"isFashionista",
                                                      @"public" : @"isPublic",
                                                      @"fashionista_web" : @"fashionistaBlogURL",
                                                      @"fashionista_name" : @"fashionistaName",
                                                      @"fashionista_title" : @"fashionistaTitle",
                                                      @"facebook_id": @"facebook_id",
                                                      @"twitter_id": @"twitter_id",
                                                      @"instagram_id":@"instagram_id",
                                                      @"pinterest_id": @"pinterest_id",
                                                      @"pinterest_token": @"pinterest_token",
                                                      @"linkedin_id":@"linkedin_id",
                                                      @"typemeasures" : @"typemeasures",
                                                      @"fingerprint" : @"fingerprint",
                                                      @"typeprofession" : @"typeprofession",
                                                      @"heightM" : @"heightM",
                                                      @"heightCm" : @"heightCm",
                                                      @"weight" : @"weight",
                                                      @"bust" : @"bust",
                                                      @"waist" : @"waist",
                                                      @"hip" : @"hip",
                                                      @"cup" : @"cup",
                                                      @"dress" : @"dress",
                                                      @"shoe" : @"shoe",
                                                      @"neck" : @"neck",
                                                      @"insteam": @"insteam",
                                                      @"sleeve" : @"sleeve", 
                                                      @"haircolor" : @"haircolor",
                                                      @"hairlength": @"hairlength",
                                                      @"eyecolor" :@"eyecolor",
                                                      @"skincolor" : @"skincolor",
                                                      @"ethnicity" : @"ethnicity",
                                                      @"shootnudes" : @"shootnudes",
                                                      @"tatoos" : @"tatoos",
                                                      @"piercings" : @"piercings",
                                                      @"relationship" : @"relationship",
                                                      @"experience": @"experience",
                                                      @"compensation" :  @"compensation",
                                                      @"genre" :  @"genre",
                                                      @"datequeryvalidateprofile" : @"datequeryvalidateprofile",
                                                      @"datevalidatedprofile" : @"datevalidatedprofile",
                                                      @"validatedprofile" : @"validatedprofile",
                                                      @"tellusmore": @"tellusmore",
                                                      @"political_view" : @"politicalView",
                                                      @"political_view_visible" : @"politicalViewVisible",
                                                      @"political_party" : @"politicalParty",
                                                      @"political_party_visible" : @"politicalPartyVisible",
                                                      @"religion" : @"religion",
                                                      @"religion_visible" : @"religionVisible",
                                                      @"header_media" : @"headerMedia",
                                                      @"header_type" : @"headerType",
                                                      @"agencies" : @"agencies",
                                                      @"instruments" : @"instruments",
                                                      @"birthDate_visible" : @"birthdateVisible",
                                                      @"gender_visible" : @"genderVisible",
                                                      @"addressCity_visible" : @"addressCityVisible",
                                                      @"relationship_visible" : @"relationshipVisible",
                                                      @"genre_visible" :  @"genreVisible",
                                                      @"ethnicity_visible" : @"ethnicityVisible",
                                                      @"typeprofessionid" : @"typeprofessionId",
                                                      @"facebook_url" : @"facebook_url",
                                                      @"twitter_url" : @"twitter_url",
                                                      @"instagram_url" : @"instagram_url",
                                                      @"linkedin_url" : @"linkedin_url",
                                                      @"tumblr_id" : @"tumblr_id",
                                                      @"flicker_id" : @"flicker_id",
                                                      @"snapchat_id" : @"snapchat_id",
                                                      @"facebook_token" : @"facebook_token",
                                                      @"flicker_token" : @"flicker_token",
                                                      @"instagram_token" : @"instagram_token",
                                                      @"linkedin_token" : @"linkedin_token",
                                                      @"snapchat_token" : @"snapchat_token",
                                                      @"tumblr_token" : @"tumblr_token",
                                                      @"twitter_token" : @"twitter_token",
                                                      @"createdAt" : @"createdAt",
                                                      @"full_picture" : @"full_picture",
                                                      }];
    
    // Facebook Logging
    RKObjectMapping *facebookLoginMapping = [RKObjectMapping mappingForClass:[FacebookLogin class]];
    
    // Add attributes mapping. The dictionary maps attributes on the JSON response to properties of the object in the data model. JSON : COREDATA
    [facebookLoginMapping addAttributeMappingsFromDictionary:@{
                                                               @"facebook_token" : @"facebook_token",
                                                               @"facebook_id" : @"facebook_id",
                                                               @"email" : @"email",
                                                               }];
    // Search Query
    
    // Instance RKEntityMapping
    RKEntityMapping *searchQueryMapping = [RKEntityMapping mappingForEntityForName:@"SearchQuery" inManagedObjectStore:[RKManagedObjectStore defaultStore]];
    
    // Assign identificationAttributes ensuring that all objects stored in Core Data will have unique IDs
    searchQueryMapping.identificationAttributes = @[@"idSearchQuery"];
    
    // Add attributes mapping. The dictionary maps attributes on the JSON response to properties of the object in the data model. JSON : COREDATA
    [searchQueryMapping addAttributeMappingsFromDictionary:@{
                                                             @"searchQuery" : @"searchQuery",
                                                             @"numresults" : @"numresults",
                                                             @"date" : @"date",
                                                             @"id" : @"idSearchQuery",
                                                             }];
    
    // Results Group
    
    // Instance RKEntityMapping
    RKEntityMapping *resultsGroupMapping = [RKEntityMapping mappingForEntityForName:@"ResultsGroup" inManagedObjectStore:[RKManagedObjectStore defaultStore]];
    
    // Assign identificationAttributes ensuring that all objects stored in Core Data will have unique IDs
    resultsGroupMapping.identificationAttributes = @[@"idResultsGroup"];
    
    // Add attributes mapping. The dictionary maps attributes on the JSON response to properties of the object in the data model. JSON : COREDATA
    [resultsGroupMapping addAttributeMappingsFromDictionary:@{
                                                              @"id" : @"idResultsGroup",
                                                              @"name" : @"name",
                                                              @"order" : @"order",
                                                              @"first_order" : @"first_order",
                                                              @"last_order" : @"last_order",
                                                              //@"keywords" : @"keywords",
                                                              @"statProductQuery" : @"searchQueryId",
                                                              }];
    
    // GSBaseElement
    
    // Instance RKEntityMapping
    RKEntityMapping *baseElementMapping = [RKEntityMapping mappingForEntityForName:@"GSBaseElement" inManagedObjectStore:[RKManagedObjectStore defaultStore]];
    
    // Assign identificationAttributes ensuring that all objects stored in Core Data will have unique IDs
    baseElementMapping.identificationAttributes = @[@"idGSBaseElement"];
    
    // Add attributes mapping. The dictionary maps attributes on the JSON response to properties of the object in the data model. JSON : COREDATA
    [baseElementMapping addAttributeMappingsFromDictionary:@{
                                                             @"id" : @"idGSBaseElement",
                                                             @"name" : @"name",
                                                             @"order" : @"order",
                                                             @"group_order" : @"group",
                                                             @"preview_image" : @"preview_image",
                                                             @"preview_image_height" : @"preview_image_height",
                                                             @"preview_image_width" : @"preview_image_width",
                                                             @"price" : @"recommendedPrice",
                                                             @"info1" : @"mainInformation",
                                                             @"info2" : @"additionalInformation",
                                                             @"product" : @"productId",
                                                             @"fashionista" : @"fashionistaId",
                                                             @"fashionistapage" : @"fashionistaPageId",
                                                             @"fashionistapost" : @"fashionistaPostId",
                                                             @"wardrobe" : @"wardrobeId",
                                                             @"wardrobeQuery" : @"wardrobeQueryId",
                                                             @"style" : @"styleId",
                                                             @"brand" : @"brandId",
                                                             @"premium" : @"premium",
                                                             @"postowner_image" : @"postowner_image",
                                                             @"post_location" : @"post_location",
                                                             @"post_likes" : @"post_likes",
                                                             @"post_createdAt" : @"post_createdAt",
                                                             @"content_url" : @"content_url",
                                                             @"content_type" : @"content_type",
                                                             @"isFollowingAuthor" : @"isFollowingAuthor",
                                                             @"product_polygons" : @"product_polygons",
                                                             @"posttype": @"posttype",
                                                             @"post_magazinecategory": @"post_magazinecategory"
                                                             }];
    
    // User Report
    
    // Instance RKObjectMapping
    RKObjectMapping *userReportMapping = [RKObjectMapping mappingForClass:[UserReport class]];
    
    // Add attributes mapping. The dictionary maps attributes on the JSON response to properties of the object in the data model. JSON : COREDATA
    [userReportMapping addAttributeMappingsFromDictionary:@{
                                                               @"reportedUser" : @"reportedUserId",
                                                               @"user" : @"userId",
                                                               @"reportType" : @"reportType",
                                                               }];
    
    
    // PostContent Report
    
    // Instance RKObjectMapping
    RKObjectMapping *postContentReportMapping = [RKObjectMapping mappingForClass:[PostContentReport class]];
    
    // Add attributes mapping. The dictionary maps attributes on the JSON response to properties of the object in the data model. JSON : COREDATA
    [postContentReportMapping addAttributeMappingsFromDictionary:@{
                                                               @"reportedPost" : @"postId",
                                                               @"user" : @"userId",
                                                               @"reportType" : @"reportType",
                                                               }];
    
    
    // PostComment Report
    
    // Instance RKObjectMapping
    RKObjectMapping *postCommentReportMapping = [RKObjectMapping mappingForClass:[PostCommentReport class]];
    
    // Add attributes mapping. The dictionary maps attributes on the JSON response to properties of the object in the data model. JSON : COREDATA
    [postCommentReportMapping addAttributeMappingsFromDictionary:@{
                                                               @"reportedPostComment" : @"commentId",
                                                               @"user" : @"userId",
                                                               @"reportType" : @"reportType",
                                                               }];
    
    
    // Product Report
    
    // Instance RKObjectMapping
    RKObjectMapping *productReportMapping = [RKObjectMapping mappingForClass:[ProductReport class]];
    
    // Add attributes mapping. The dictionary maps attributes on the JSON response to properties of the object in the data model. JSON : COREDATA
    [productReportMapping addAttributeMappingsFromDictionary:@{
                                                             @"reportedProduct" : @"productId",
                                                             @"user" : @"userId",
                                                             @"reportType" : @"reportType",
                                                             }];
    
    
    // Product View
    
    // Instance RKObjectMapping
    RKObjectMapping *productViewMapping = [RKObjectMapping mappingForClass:[ProductView class]];
    
    // Add attributes mapping. The dictionary maps attributes on the JSON response to properties of the object in the data model. JSON : COREDATA
    [productViewMapping addAttributeMappingsFromDictionary:@{
                                                             @"product" : @"productId",
                                                             @"user" : @"userId",
                                                             @"post" : @"postId",
                                                             @"statProductQuery" : @"statProductQueryId",
                                                             @"fingerprint" : @"fingerprint",
                                                             @"localtime": @"localtime"
                                                             }];

    // Product Availability
    
    RKObjectMapping *productAvailabilityMapping = [RKObjectMapping mappingForClass:[ProductAvailability class]];
    
    // Add attributes mapping. The dictionary maps attributes on the JSON response to properties of the object in the data model. JSON : COREDATA
    [productAvailabilityMapping addAttributeMappingsFromDictionary:@{
                                                             @"online" : @"online",
                                                             @"website" : @"website",
                                                             @"storename" : @"storename",
                                                             @"shoppingcenter" : @"shoppingcenter",
                                                             @"address" : @"address",
                                                             @"zipcode" : @"zipcode",
                                                             @"state" : @"state",
                                                             @"city" : @"city",
                                                             @"country" : @"country",
                                                             @"telephone" : @"telephone",
                                                             @"latitude" : @"latitude",
                                                             @"longitude" : @"longitude",
                                                             @"distance" : @"distance",
                                                             @"units" : @"units",
                                                             }];
    
    // Product Availability Timetable
    
    RKObjectMapping *productAvailabilityTimeTableMapping = [RKObjectMapping mappingForClass:[ProductAvailabilityTimeTable class]];
    
    // Add attributes mapping. The dictionary maps attributes on the JSON response to properties of the object in the data model. JSON : COREDATA
    [productAvailabilityTimeTableMapping addAttributeMappingsFromDictionary:@{
                                                                     @"dayweek" : @"dayweek",
                                                                     }];
    // Product Availability timetable intervalTime
    
    RKObjectMapping *productAvailabilityTimeTableintervalTimeMapping = [RKObjectMapping mappingForClass:[ProductAvailabilityTimeTableIntervalTime class]];
    
    // Add attributes mapping. The dictionary maps attributes on the JSON response to properties of the object in the data model. JSON : COREDATA
    [productAvailabilityTimeTableintervalTimeMapping addAttributeMappingsFromDictionary:@{
                                                                     @"open" : @"open",
                                                                     @"close" : @"close",
                                                                     }];
    
    // Product Shared
    
    // Instance RKObjectMapping
    RKObjectMapping *productSharedMapping = [RKObjectMapping mappingForClass:[ProductShared class]];
    
    // Add attributes mapping. The dictionary maps attributes on the JSON response to properties of the object in the data model. JSON : COREDATA
    [productSharedMapping addAttributeMappingsFromDictionary:@{
                                                               @"id": @"idProductShared",
                                                               @"product" : @"productId",
                                                               @"user" : @"userId",
                                                               @"post" : @"postId",
                                                               @"statProductQuery" : @"statProductQueryId",
                                                               @"fingerprint" : @"fingerprint",
                                                               @"origin": @"origin",
                                                               @"origindetail": @"origindetail",
                                                               @"socialNetwork": @"socialNetwork",
                                                               @"localtime": @"localtime"
                                                               
                                                               }];
    
    
    
    // Product purchase
    
    // Instance RKObjectMapping
    RKObjectMapping *productPurchaseMapping = [RKObjectMapping mappingForClass:[ProductPurchase class]];
    
    // Add attributes mapping. The dictionary maps attributes on the JSON response to properties of the object in the data model. JSON : COREDATA
    [productPurchaseMapping addAttributeMappingsFromDictionary:@{
                                                                 @"id": @"idProductPurchase",
                                                                 @"product" : @"productId",
                                                                 @"user" : @"userId",
                                                                 @"post" : @"postId",
                                                                 @"statProductQuery" : @"statProductQueryId",
                                                                 @"statProductView" : @"statProductViewId",
                                                                 @"fingerprint" : @"fingerprint",
                                                                 @"localtime": @"localtime"
                                                                 }];

    // Post View
    
    // Instance RKObjectMapping
    RKObjectMapping *postViewMapping = [RKObjectMapping mappingForClass:[FashionistaPostView class]];
    
    // Add attributes mapping. The dictionary maps attributes on the JSON response to properties of the object in the data model. JSON : COREDATA
    [postViewMapping addAttributeMappingsFromDictionary:@{
                                                             @"post" : @"postId",
                                                             @"user" : @"userId",
                                                             @"statProductQuery" : @"statProductQueryId",
                                                             @"fingerprint" : @"fingerprint",
                                                             @"localtime": @"localtime"
                                                             }];
    
    // Post View Time
    
    // Instance RKObjectMapping
    RKObjectMapping *postViewTimeMapping = [RKObjectMapping mappingForClass:[FashionistaPostViewTime class]];
    
    // Add attributes mapping. The dictionary maps attributes on the JSON response to properties of the object in the data model. JSON : COREDATA
    [postViewTimeMapping addAttributeMappingsFromDictionary:@{
                                                              @"starttime" : @"startTime",
                                                              @"endtime" : @"endTime",
                                                              @"post" : @"postId",
                                                              @"user" : @"userId",
                                                              @"statProductQuery" : @"statProductQueryId",
                                                              @"fingerprint" : @"fingerprint",
                                                              }];
    
    // Post Shared
    
    // Instance RKObjectMapping
    RKObjectMapping *postSharedMapping = [RKObjectMapping mappingForClass:[FashionistaPostShared class]];
    
    // Add attributes mapping. The dictionary maps attributes on the JSON response to properties of the object in the data model. JSON : COREDATA
    [postSharedMapping addAttributeMappingsFromDictionary:@{
                                                            @"post" : @"postId",
                                                            @"user" : @"userId",
                                                            @"statProductQuery" : @"statProductQueryId",
                                                            @"fingerprint" : @"fingerprint",
                                                            @"socialNetwork": @"socialNetwork",
                                                            @"localtime": @"localtime"
                                                            }];
    
    //postUserMapping
    
    // Instance RKObjectMapping
    RKObjectMapping *postUserMapping = [RKObjectMapping mappingForClass:[PostUserUnfollow class]];
    
    // Add attributes mapping. The dictionary maps attributes on the JSON response to properties of the object in the data model. JSON : COREDATA
    [postUserMapping addAttributeMappingsFromDictionary:@{
                                                          @"post" : @"postId",
                                                          @"user" : @"userId",
                                                          @"id" : @"pufId",
                                                          }];

    
    //userUserMapping
    
    // Instance RKObjectMapping
    RKObjectMapping *userUserMapping = [RKObjectMapping mappingForClass:[UserUserUnfollow class]];
    
    // Add attributes mapping. The dictionary maps attributes on the JSON response to properties of the object in the data model. JSON : COREDATA
    [userUserMapping addAttributeMappingsFromDictionary:@{
                                                          @"usertoignore" : @"usertoignoreId",
                                                          @"user" : @"userId",
                                                          @"id" : @"uufId"
                                                          }];

    
    // Fashionista View
    
    // Instance RKObjectMapping
    RKObjectMapping *fashionistaViewMapping = [RKObjectMapping mappingForClass:[FashionistaView class]];
    
    // Add attributes mapping. The dictionary maps attributes on the JSON response to properties of the object in the data model. JSON : COREDATA
    [fashionistaViewMapping addAttributeMappingsFromDictionary:@{
                                                             @"fashionista" : @"fashionistaId",
                                                             @"user" : @"userId",
                                                             @"statProductQuery" : @"statProductQueryId",
                                                             @"fingerprint" : @"fingerprint",
                                                             @"localtime": @"localtime"
                                                             }];
    
    // Fashionista View Time
    
    // Instance RKObjectMapping
    RKObjectMapping *fashionistaViewTimeMapping = [RKObjectMapping mappingForClass:[FashionistaViewTime class]];
    
    // Add attributes mapping. The dictionary maps attributes on the JSON response to properties of the object in the data model. JSON : COREDATA
    [fashionistaViewTimeMapping addAttributeMappingsFromDictionary:@{
                                                                     @"starttime" : @"startTime",
                                                                     @"endtime" : @"endTime",
                                                                     @"fashionista" : @"fashionistaId",
                                                                     @"user" : @"userId",
                                                                     @"statProductQuery" : @"statProductQueryId",
                                                                     @"fingerprint" : @"fingerprint",
                                                                     }];
    
    // Wardrobe View
    
    // Instance RKObjectMapping
    RKObjectMapping *wardrobeViewMapping = [RKObjectMapping mappingForClass:[WardrobeView class]];
    
    // Add attributes mapping. The dictionary maps attributes on the JSON response to properties of the object in the data model. JSON : COREDATA
    [wardrobeViewMapping addAttributeMappingsFromDictionary:@{
                                                             @"wardrobe" : @"wardrobeId",
                                                             @"user" : @"userId",
                                                             @"statProductQuery" : @"statProductQueryId",
                                                             @"fingerprint" : @"fingerprint",
                                                             @"localtime": @"localtime"
                                                             }];
    
    
    // Comment View
    
    // Instance RKObjectMapping
    RKObjectMapping *commentViewMapping = [RKObjectMapping mappingForClass:[CommentView class]];
    
    // Add attributes mapping. The dictionary maps attributes on the JSON response to properties of the object in the data model. JSON : COREDATA
    [commentViewMapping addAttributeMappingsFromDictionary:@{
                                                             @"comment" : @"commentId",
                                                             @"user" : @"userId",
                                                             @"fingerprint" : @"fingerprint",
                                                             @"localtime": @"localtime"
                                                             }];

    // Review Product View
    
    // Instance RKObjectMapping
    RKObjectMapping *reviewProductViewMapping = [RKObjectMapping mappingForClass:[ReviewProductView class]];
    
    // Add attributes mapping. The dictionary maps attributes on the JSON response to properties of the object in the data model. JSON : COREDATA
    [reviewProductViewMapping addAttributeMappingsFromDictionary:@{
                                                             @"review" : @"reviewId",
                                                             @"user" : @"userId",
                                                             @"fingerprint" : @"fingerprint",
                                                             @"localtime": @"localtime"
                                                             }];
    
    // Brand
    
    // Instance RKEntityMapping
    RKEntityMapping *brandMapping = [RKEntityMapping mappingForEntityForName:@"Brand" inManagedObjectStore:[RKManagedObjectStore defaultStore]];
    
    // Assign identificationAttributes ensuring that all objects stored in Core Data will have unique IDs
    brandMapping.identificationAttributes = @[@"idBrand"];
    
    // Add attributes mapping. The dictionary maps attributes on the JSON response to properties of the object in the data model. JSON : COREDATA
    [brandMapping addAttributeMappingsFromDictionary:@{
                                                       @"id" : @"idBrand",
                                                       @"GBIN" : @"gbin",
                                                       @"name" : @"name",
                                                       @"logo" : @"logo",
                                                       @"information" : @"information",
                                                       @"website" : @"url",
                                                       @"priority" : @"priority",
                                                       @"order" : @"order",
                                                       }];
    
    // Product
    
    // Instance RKEntityMapping
    RKEntityMapping *productMapping = [RKEntityMapping mappingForEntityForName:@"Product" inManagedObjectStore:[RKManagedObjectStore defaultStore]];
    
    // Assign identificationAttributes ensuring that all objects stored in Core Data will have unique IDs
    productMapping.identificationAttributes = @[@"idProduct"];
    
    // Add attributes mapping. The dictionary maps attributes on the JSON response to properties of the object in the data model. JSON : COREDATA
    [productMapping addAttributeMappingsFromDictionary:@{
                                                         @"brand" : @"brandId",
                                                         @"profile_brand" : @"profile_brand",
                                                         @"category" : @"group",
                                                         @"sku" : @"sku",
                                                         @"name" : @"name",
                                                         @"preview_image" : @"preview_image",
                                                         @"url" : @"url",
                                                         @"recommendedPrice" : @"recommendedPrice",
                                                         @"id" : @"idProduct",
                                                         @"information" : @"information",
                                                         @"order" : @"order",
                                                         @"stat_viewnumber" : @"stat_viewnumber",
                                                         @"size": @"size",
                                                         @"size_array": @"size_array",
                                                         @"color_curated": @"color",
                                                         @"material_curated": @"material"
                                                         }];
    
    // VarianGroup
    
    // Instance RKEntityMapping
    RKEntityMapping *variantGroupMapping = [RKEntityMapping mappingForEntityForName:@"VariantGroup" inManagedObjectStore:[RKManagedObjectStore defaultStore]];
    
    // Assign identificationAttributes ensuring that all objects stored in Core Data will have unique IDs
    variantGroupMapping.identificationAttributes = @[@"idVariantGroup"];
    
    // Add attributes mapping. The dictionary maps attributes on the JSON response to properties of the object in the data model. JSON : COREDATA
    [variantGroupMapping addAttributeMappingsFromDictionary:@{@"id":@"idVariantGroup"
                                                              }];

    // VarianGroupElement
    
    // Instance RKEntityMapping
    RKEntityMapping *variantGroupElementMapping = [RKEntityMapping mappingForEntityForName:@"VariantGroupElement" inManagedObjectStore:[RKManagedObjectStore defaultStore]];
    
    // Add attributes mapping. The dictionary maps attributes on the JSON response to properties of the object in the data model. JSON : COREDATA
    [variantGroupElementMapping addAttributeMappingsFromDictionary:@{
                                                                     @"name" : @"name",
                                                                     @"image" : @"image",
                                                                     @"material" : @"material_name",
                                                                     @"material_image" : @"material_image",
                                                                     @"color" : @"color_name",
                                                                     @"color_image" : @"color_image",
                                                                     @"product_id" : @"product_id"
                                                              }];
    
    
    // ProductGroup
    
    // Instance RKEntityMapping
    RKEntityMapping *productGroupMapping = [RKEntityMapping mappingForEntityForName:@"ProductGroup" inManagedObjectStore:[RKManagedObjectStore defaultStore]];
    
    // Assign identificationAttributes ensuring that all objects stored in Core Data will have unique IDs
    productGroupMapping.identificationAttributes = @[@"idProductGroup"];
    
    // Add attributes mapping. The dictionary maps attributes on the JSON response to properties of the object in the data model. JSON : COREDATA
    [productGroupMapping addAttributeMappingsFromDictionary:@{
                                                              @"id" : @"idProductGroup",
                                                              @"name" : @"name",
                                                              @"app_name" : @"app_name",
                                                              @"parent" : @"parentId",
                                                              @"order" : @"order",
                                                              @"icon" : @"icon",
                                                              @"icon_m" : @"icon_m",
                                                              @"icon_w" : @"icon_w",
                                                              @"icon_b" : @"icon_b",
                                                              @"icon_g" : @"icon_g",
                                                              @"icon_u" : @"icon_u",
                                                              @"icon_k" : @"icon_k",
                                                              @"genders" : @"genders",
                                                              @"visible" : @"visible",
                                                              @"expanded" : @"expanded",
                                                              @"description": @"descriptionProductGroup",
                                                              }];
    
    // Price
    
    // Instance RKEntityMapping
    RKEntityMapping *priceMapping = [RKEntityMapping mappingForEntityForName:@"Price" inManagedObjectStore:[RKManagedObjectStore defaultStore]];
    
    // Assign identificationAttributes ensuring that all objects stored in Core Data will have unique IDs
    priceMapping.identificationAttributes = @[@"idPrice"];
    
    // Add attributes mapping. The dictionary maps attributes on the JSON response to properties of the object in the data model. JSON : COREDATA
    [priceMapping addAttributeMappingsFromDictionary:@{
                                                       @"id" : @"idPrice",
                                                       }];
    
    // Keyword
    
    // Instance RKEntityMapping
    RKEntityMapping *keywordMapping = [RKEntityMapping mappingForEntityForName:@"Keyword" inManagedObjectStore:[RKManagedObjectStore defaultStore]];
    
    // Assign identificationAttributes ensuring that all objects stored in Core Data will have unique IDs
    keywordMapping.identificationAttributes = @[@"idKeyword"];
    
    // Add attributes mapping. The dictionary maps attributes on the JSON response to properties of the object in the data model. JSON : COREDATA
    [keywordMapping addAttributeMappingsFromDictionary:@{
                                                         @"name" : @"name",
                                                         @"id" : @"idKeyword",
                                                         @"userAdded" : @"userAdded",
                                                         @"forPostContent": @"forPostContent",
                                                         @"productcategory" : @"productCategoryId",
                                                         @"feature" : @"featureId",
                                                         @"brand" : @"brandId",
                                                         @"user"    : @"userId"
                                                         }];
    
    // Suggested Keyword
    
    // Instance RKEntityMapping
    RKEntityMapping *suggestedKeywordMapping = [RKEntityMapping mappingForEntityForName:@"SuggestedKeyword" inManagedObjectStore:[RKManagedObjectStore defaultStore]];
    
    // Assign identificationAttributes ensuring that all objects stored in Core Data will have unique IDs
    suggestedKeywordMapping.identificationAttributes = @[@"idSuggestedKeyword"];
    
    // Add attributes mapping. The dictionary maps attributes on the JSON response to properties of the object in the data model. JSON : COREDATA
    [suggestedKeywordMapping addAttributeMappingsFromDictionary:@{
                                                                  @"name" : @"name",
                                                                  @"keyword" : @"idSuggestedKeyword",
                                                                  @"order" : @"order",
                                                                  }];
    
    
    // Feature
    
    // Instance RKEntityMapping
    RKEntityMapping *featureMapping = [RKEntityMapping mappingForEntityForName:@"Feature" inManagedObjectStore:[RKManagedObjectStore defaultStore]];
    
    // Assign identificationAttributes ensuring that all objects stored in Core Data will have unique IDs
    featureMapping.identificationAttributes = @[@"idFeature"];
    
    // Add attributes mapping. The dictionary maps attributes on the JSON response to properties of the object in the data model. JSON : COREDATA
    [featureMapping addAttributeMappingsFromDictionary:@{
                                                         @"name" : @"name",
                                                         @"app_name" : @"app_name",
                                                         //                                                     @"featureGroup" : @"featureGroup",
                                                         @"id" : @"idFeature",
                                                         @"image" : @"icon",
                                                         @"images" : @"icons",
                                                         @"hidden" : @"hidden",
                                                         @"featureGroup" : @"featureGroupId",
                                                         @"priority" : @"priority"
                                                         }];
    
    // FeatureGroup
    
    // Instance RKEntityMapping
    RKEntityMapping *featureGroupMapping = [RKEntityMapping mappingForEntityForName:@"FeatureGroup" inManagedObjectStore:[RKManagedObjectStore defaultStore]];
    
    // Assign identificationAttributes ensuring that all objects stored in Core Data will have unique IDs
    featureGroupMapping.identificationAttributes = @[@"idFeatureGroup"];
    
    // Add attributes mapping. The dictionary maps attributes on the JSON response to properties of the object in the data model. JSON : COREDATA
    [featureGroupMapping addAttributeMappingsFromDictionary:@{
                                                              @"id" : @"idFeatureGroup",
                                                              @"name" : @"name",
                                                              @"app_name" : @"app_name",
                                                              @"parent" : @"parentId",
                                                              }];
    
    // FeatureGroupOrder
    
    // Instance RKEntityMapping
    RKEntityMapping *featureGroupOrderMapping = [RKEntityMapping mappingForEntityForName:@"FeatureGroupOrderProductGroup" inManagedObjectStore:[RKManagedObjectStore defaultStore]];
    
    // Assign identificationAttributes ensuring that all objects stored in Core Data will have unique IDs
    featureGroupOrderMapping.identificationAttributes = @[@"idFeatureGroupOrder"];
    
    // Add attributes mapping. The dictionary maps attributes on the JSON response to properties of the object in the data model. JSON : COREDATA
    [featureGroupOrderMapping addAttributeMappingsFromDictionary:@{
                                                              @"id" : @"idFeatureGroupOrder",
                                                              @"order" : @"order",
                                                              @"featuregroup_productCategories" : @"featureGroupId",
                                                              @"productcategory_featuresGroup" : @"productGroupId",
                                                              }];
    
    // Content
    
    // Instance RKEntityMapping
    RKEntityMapping *contentMapping = [RKEntityMapping mappingForEntityForName:@"Content" inManagedObjectStore:[RKManagedObjectStore defaultStore]];
    
    // Assign identificationAttributes ensuring that all objects stored in Core Data will have unique IDs
    contentMapping.identificationAttributes = @[@"idContent"];
    
    // Add attributes mapping. The dictionary maps attributes on the JSON response to properties of the object in the data model. JSON : COREDATA
    [contentMapping addAttributeMappingsFromDictionary:@{
                                                         @"name" : @"name",
                                                         @"type" : @"type",
                                                         @"url" : @"url",
                                                         @"id" : @"idContent",
                                                         }];
    
    // Availability
    
    // Instance RKEntityMapping
    RKEntityMapping *availabilityMapping = [RKEntityMapping mappingForEntityForName:@"Availability" inManagedObjectStore:[RKManagedObjectStore defaultStore]];
    
    // Assign identificationAttributes ensuring that all objects stored in Core Data will have unique IDs
    availabilityMapping.identificationAttributes = @[@"idAvailability"];
    
    // Add attributes mapping. The dictionary maps attributes on the JSON response to properties of the object in the data model. JSON : COREDATA
    [availabilityMapping addAttributeMappingsFromDictionary:@{
                                                              @"id" : @"idAvailability",
                                                              }];
    
    // Shop
    
    // Instance RKEntityMapping
    RKEntityMapping *shopMapping = [RKEntityMapping mappingForEntityForName:@"Shop" inManagedObjectStore:[RKManagedObjectStore defaultStore]];
    
    // Assign identificationAttributes ensuring that all objects stored in Core Data will have unique IDs
    shopMapping.identificationAttributes = @[@"idShop"];
    
    // Add attributes mapping. The dictionary maps attributes on the JSON response to properties of the object in the data model. JSON : COREDATA
    [shopMapping addAttributeMappingsFromDictionary:@{
                                                      @"id" : @"idShop",
                                                      }];
    
    // Wardrobe
    
    // Instance RKEntityMapping
    RKEntityMapping *wardrobeMapping = [RKEntityMapping mappingForEntityForName:@"Wardrobe" inManagedObjectStore:[RKManagedObjectStore defaultStore]];
    
    // Assign identificationAttributes ensuring that all objects stored in Core Data will have unique IDs
    wardrobeMapping.identificationAttributes = @[@"idWardrobe"];
    
    // Add attributes mapping. The dictionary maps attributes on the JSON response to properties of the object in the data model. JSON : COREDATA
    [wardrobeMapping addAttributeMappingsFromDictionary:@{
                                                          @"id" : @"idWardrobe",
                                                          @"name" : @"name",
                                                          @"preview_image" : @"preview_image",
                                                          @"user" : @"userId",
                                                          @"fashionistaPostContent" : @"fashionistaContentId",
                                                          @"wardrobepublic": @"publicWardrobe"
                                                          }];
    
    // Review
    
    // Instance RKEntityMapping
    RKEntityMapping *reviewMapping = [RKEntityMapping mappingForEntityForName:@"Review" inManagedObjectStore:[RKManagedObjectStore defaultStore]];
    
    // Assign identificationAttributes ensuring that all objects stored in Core Data will have unique IDs
    reviewMapping.identificationAttributes = @[@"idReview"];
    
    // Add attributes mapping. The dictionary maps attributes on the JSON response to properties of the object in the data model. JSON : COREDATA
    [reviewMapping addAttributeMappingsFromDictionary:@{
                                                        @"id" : @"idReview",
                                                        @"product" : @"productId",
                                                        @"user" : @"userId",
                                                        @"location" : @"location",
                                                        @"text" : @"text",
                                                        @"overall_rating" : @"overall_rating",
                                                        @"comfort_rating" : @"comfort_rating",
                                                        @"quality_rating" : @"quality_rating",
                                                        @"video" : @"video",
                                                        @"createdAt" : @"date",
                                                        }];
    
    // Comment
    
    // Instance RKEntityMapping
    RKEntityMapping *commentMapping = [RKEntityMapping mappingForEntityForName:@"Comment" inManagedObjectStore:[RKManagedObjectStore defaultStore]];
    
    // Assign identificationAttributes ensuring that all objects stored in Core Data will have unique IDs
    commentMapping.identificationAttributes = @[@"idComment"];
    
    // Add attributes mapping. The dictionary maps attributes on the JSON response to properties of the object in the data model. JSON : COREDATA
    [commentMapping addAttributeMappingsFromDictionary:@{
                                                        @"id" : @"idComment",
                                                        @"fashionistaPost" : @"fashionistaPostId",
                                                        @"user" : @"userId",
                                                        @"location" : @"location",
                                                        @"text" : @"text",
                                                        @"likeIt" : @"likeIt",
                                                        @"video" : @"video",
                                                        @"createdAt" : @"date",
                                                        @"fashionista_name" : @"fashionistaPostName",
                                                        }];
    
    // Notification
    
    // Instance RKEntityMapping
    RKEntityMapping *notificationMapping = [RKEntityMapping mappingForEntityForName:@"Notification" inManagedObjectStore:[RKManagedObjectStore defaultStore]];
    
    // Assign identificationAttributes ensuring that all objects stored in Core Data will have unique IDs
    notificationMapping.identificationAttributes = @[@"idNotification"];
    
    // Add attributes mapping. The dictionary maps attributes on the JSON response to properties of the object in the data model. JSON : COREDATA
    [notificationMapping addAttributeMappingsFromDictionary:@{
                                                         @"id" : @"idNotification",
                                                         @"post" : @"fashionistaPostId",
                                                         @"user" : @"userId",
                                                         @"userid" : @"actionUserId",
                                                         @"username" : @"actionUsername",
                                                         @"notificationIsNew" : @"notificationIsNew",
                                                         @"commenttext" : @"comment",
                                                         @"commentvideo" : @"video",
                                                         @"postTitle" : @"postTitle",
                                                         @"type" : @"type",
                                                         @"text" : @"text",
                                                         @"date" : @"date",
                                                         @"cover_image" : @"previewImage",
                                                         }];
    
    // TagHistory
    
    // Instance RKEntityMapping
    RKEntityMapping *tagHistoryMapping = [RKEntityMapping mappingForEntityForName:@"TagHistory" inManagedObjectStore:[RKManagedObjectStore defaultStore]];
    
    // Assign identificationAttributes ensuring that all objects stored in Core Data will have unique IDs
    tagHistoryMapping.identificationAttributes = @[@"idTagHistory"];
    
    // Add attributes mapping. The dictionary maps attributes on the JSON response to properties of the object in the data model. JSON : COREDATA
    [tagHistoryMapping addAttributeMappingsFromDictionary:@{
                                                              @"id" : @"idTagHistory",
                                                              @"comment" : @"commentId",
                                                              @"user" : @"userId",
                                                              @"keyword" : @"keywordId",
                                                              @"post" : @"postId",
                                                              @"usertagged" : @"taggedUserId",
                                                              @"user_picture" : @"taggerPicture",
                                                              @"fashionista_name" : @"taggerName",
                                                              @"post_cover_image" : @"postPreview",
                                                              @"createdAt" : @"date",
                                                              }];
    
    
    // BackgroundAd
    
    // Instance RKEntityMapping
    RKEntityMapping *backgroundAdMapping = [RKEntityMapping mappingForEntityForName:@"BackgroundAd" inManagedObjectStore:[RKManagedObjectStore defaultStore]];
    
    // Assign identificationAttributes ensuring that all objects stored in Core Data will have unique IDs
    backgroundAdMapping.identificationAttributes = @[@"idBackgroundAd"];
    
    // Add attributes mapping. The dictionary maps attributes on the JSON response to properties of the object in the data model. JSON : COREDATA
    [backgroundAdMapping addAttributeMappingsFromDictionary:@{
                                                       @"id" : @"idBackgroundAd",
                                                       @"image" : @"imageURL",
                                                       @"user" : @"userId",
                                                       @"info1" : @"mainInformation",
                                                       @"info2" : @"secondaryInformation",
                                                       }];
    

    // Fashionista Page
    
    // Instance RKEntityMapping
    RKEntityMapping *fashionistaPageMapping = [RKEntityMapping mappingForEntityForName:@"FashionistaPage" inManagedObjectStore:[RKManagedObjectStore defaultStore]];
    
    // Assign identificationAttributes ensuring that all objects stored in Core Data will have unique IDs
    fashionistaPageMapping.identificationAttributes = @[@"idFashionistaPage"];
    
    // Add attributes mapping. The dictionary maps attributes on the JSON response to properties of the object in the data model. JSON : COREDATA
    [fashionistaPageMapping addAttributeMappingsFromDictionary:@{
                                                                 @"id" : @"idFashionistaPage",
                                                                 @"user" : @"userId",
                                                                 @"title" : @"title",
                                                                 @"category" : @"category",
                                                                 @"subcategory" : @"subcategory",
                                                                 @"cover_image" : @"header_image",
                                                                 @"cover_image_width" : @"header_image_width",
                                                                 @"cover_image_height" : @"header_image_height",
                                                                 @"order" : @"order",
                                                                 @"group" : @"group",
                                                                 @"stat_viewnumber" : @"stat_viewnumber",
                                                                 @"wardrobesPostNumber" : @"wardrobesPostNumber",
                                                                 @"articlesPostNumber" : @"articlesPostNumber",
                                                                 @"tutorialsPostNumber" : @"tutorialsPostNumber",
                                                                 @"reviewsPostNumber" : @"reviewsPostNumber",
                                                                 @"location" : @"location",
                                                                 @"blogURL" : @"blogURL",
                                                                 }];
    
    
    // AD GET del
    RKEntityMapping *adMappingGet = [RKEntityMapping mappingForEntityForName:@"Ad" inManagedObjectStore:[RKManagedObjectStore defaultStore]];
    
    adMappingGet.identificationAttributes = @[@"idAd"];

    
    [adMappingGet addAttributeMappingsFromDictionary:@{@"id":@"idAd",
                                                       @"post":@"postId",
                                                       @"product":@"productId",
                                                       @"profile":@"profileId",
                                                       @"updatedAt":@"endDate",
                                                       @"createdAt":@"startDate",
                                                       @"order":@"order",
                                                       @"website":@"website",
                                                       @"height":@"height",
                                                       @"width":@"width",
                                                       @"video":@"video",
                                                       @"image":@"image",
                                                       }];
    
    
    // Fashionista Post al hacer el GET del post
    
    // Instance RKEntityMapping
    RKEntityMapping *fashionistaPostMappingGet = [RKEntityMapping mappingForEntityForName:@"FashionistaPost" inManagedObjectStore:[RKManagedObjectStore defaultStore]];
    
    // Assign identificationAttributes ensuring that all objects stored in Core Data will have unique IDs
    fashionistaPostMappingGet.identificationAttributes = @[@"idFashionistaPost"];
    
    // Add attributes mapping. The dictionary maps attributes on the JSON response to properties of the object in the data model. JSON : COREDATA
    [fashionistaPostMappingGet addAttributeMappingsFromDictionary:@{
                                                                    @"id" : @"idFashionistaPost",
                                                                    @"category" : @"group",
                                                                    @"fashionistaPage" : @"fashionistaPageId",
                                                                    @"title" : @"name",
                                                                    @"order" : @"order",
                                                                    @"cover_image" : @"preview_image",
                                                                    @"cover_image_height" : @"preview_image_height",
                                                                    @"cover_image_width" : @"preview_image_width",
                                                                    @"stat_viewnumber" : @"stat_viewnumber",
                                                                    @"fashionistaPostType" : @"type",
                                                                    @"magazineCategory": @"magazineCategory",
                                                                    @"user" : @"userId",
                                                                    @"date" : @"date",
                                                                    @"createdAt" : @"createdAt",
                                                                    @"location" : @"location",
                                                                    @"imagesNum" : @"imagesNum",
                                                                    @"likesNum" : @"likesNum",
                                                                    @"commentsNum" : @"commentsNum",
                                                                    @"location_poi" : @"location_poi",
                                                                    @"magazineAuthor" : @"magazineAuthor",
                                                                    @"magazinePhotographer" : @"magazinePhotographer",
                                                                    @"public": @"publicPost"
                                                                    }];
    
    // Full fashionista Post
    RKEntityMapping *fashionistaFullPostMappingGet = [RKEntityMapping mappingForEntityForName:@"FashionistaPost" inManagedObjectStore:[RKManagedObjectStore defaultStore]];
    
    // Assign identificationAttributes ensuring that all objects stored in Core Data will have unique IDs
    fashionistaFullPostMappingGet.identificationAttributes = @[@"idFashionistaPost"];
    
    // Add attributes mapping. The dictionary maps attributes on the JSON response to properties of the object in the data model. JSON : COREDATA
    [fashionistaFullPostMappingGet addAttributeMappingsFromDictionary:@{
                                                                    @"id" : @"idFashionistaPost",
                                                                    @"category" : @"group",
                                                                    @"fashionistaPage" : @"fashionistaPageId",
                                                                    @"title" : @"name",
                                                                    @"order" : @"order",
                                                                    @"cover_image" : @"preview_image",
                                                                    @"cover_image_height" : @"preview_image_height",
                                                                    @"cover_image_width" : @"preview_image_width",
                                                                    @"stat_viewnumber" : @"stat_viewnumber",
                                                                    @"fashionistaPostType" : @"type",
                                                                    @"magazineCategory": @"magazineCategory",
                                                                    @"user" : @"userId",
                                                                    @"date" : @"date",
                                                                    @"createdAt" : @"createdAt",
                                                                    @"location" : @"location",
                                                                    @"imagesNum" : @"imagesNum",
                                                                    @"likesNum" : @"likesNum",
                                                                    @"commentsNum" : @"commentsNum",
                                                                    @"isFollowingAuthor" : @"isFollowingAuthor",
                                                                    @"location_poi" : @"location_poi",
                                                                    @"magazineAuthor" : @"magazineAuthor",
                                                                    @"magazinePhotographer" : @"magazinePhotographer",
                                                                    @"public": @"publicPost"
                                                                    }];
    
    // Fashionista Post al hacer el POST del post. No interesa enviar los imagesNum, likesNum, ni commentsNum
    
    // Instance RKEntityMapping
    RKEntityMapping *fashionistaPostMappingPost = [RKEntityMapping mappingForEntityForName:@"FashionistaPost" inManagedObjectStore:[RKManagedObjectStore defaultStore]];
    
    // Assign identificationAttributes ensuring that all objects stored in Core Data will have unique IDs
    fashionistaPostMappingPost.identificationAttributes = @[@"idFashionistaPost"];
    
    // Add attributes mapping. The dictionary maps attributes on the JSON response to properties of the object in the data model. JSON : COREDATA
    [fashionistaPostMappingPost addAttributeMappingsFromDictionary:@{
                                                                    @"id" : @"idFashionistaPost",
                                                                    @"category" : @"group",
                                                                    @"fashionistaPage" : @"fashionistaPageId",
                                                                    @"title" : @"name",
                                                                    @"order" : @"order",
                                                                    @"cover_image" : @"preview_image",
                                                                    @"cover_image_height" : @"preview_image_height",
                                                                    @"cover_image_width" : @"preview_image_width",
                                                                    @"stat_viewnumber" : @"stat_viewnumber",
                                                                    @"fashionistaPostType" : @"type",
                                                                    @"magazineCategory": @"magazineCategory",
                                                                    @"user" : @"userId",
                                                                    @"date" : @"date",
                                                                    @"createdAt" : @"createdAt",
                                                                    @"location" : @"location",
                                                                    @"location_poi" : @"location_poi",
                                                                    @"magazineAuthor" : @"magazineAuthor",
                                                                    @"magazinePhotographer" : @"magazinePhotographer",
                                                                    @"public": @"publicPost",
                                                                    }];
    
    // Fashionista Content
    
    // Instance RKEntityMapping
    RKEntityMapping *fashionistaContentMapping = [RKEntityMapping mappingForEntityForName:@"FashionistaContent" inManagedObjectStore:[RKManagedObjectStore defaultStore]];
    
    // Assign identificationAttributes ensuring that all objects stored in Core Data will have unique IDs
    fashionistaContentMapping.identificationAttributes = @[@"idFashionistaContent"];
    
    // Add attributes mapping. The dictionary maps attributes on the JSON response to properties of the object in the data model. JSON : COREDATA
    [fashionistaContentMapping addAttributeMappingsFromDictionary:@{
                                                                    @"id" : @"idFashionistaContent",
                                                                    @"text" : @"text",
                                                                    @"image" : @"image",
                                                                    @"image_width" : @"image_width",
                                                                    @"image_height" : @"image_height",
                                                                    @"imageText" : @"imageText",
                                                                    @"video" : @"video",
                                                                    @"order" : @"order",
                                                                    @"fashionistaPost" : @"fashionistaPostId",
                                                                    @"wardrobe" : @"wardrobeId",
                                                                    @"author" : @"author",
                                                                    }];
    // KeywordFashionistaContent
    
    // Instance RKEntityMapping
    RKEntityMapping *keywordFashionistaContentMapping = [RKEntityMapping mappingForEntityForName:@"KeywordFashionistaContent" inManagedObjectStore:[RKManagedObjectStore defaultStore]];
    
    // Assign identificationAttributes ensuring that all objects stored in Core Data will have unique IDs
    keywordFashionistaContentMapping.identificationAttributes = @[@"idKeywordFashionistaContent"];
    
    // Add attributes mapping. The dictionary maps attributes on the JSON response to properties of the object in the data model. JSON : COREDATA
    [keywordFashionistaContentMapping addAttributeMappingsFromDictionary:@{
                                                                   @"id" : @"idKeywordFashionistaContent",
                                                                   @"group" : @"group",
                                                                   @"keyword_fashionistaPostContents" : @"keywordId",
                                                                   @"fashionistapostcontent_keywords" : @"fashionistaContentId",
                                                                   @"tagXcoord" : @"xPos",
                                                                   @"tagYcoord" : @"yPos"
                                                                   }];
    
    RKEntityMapping *keywordFashionistaContentPopulatedMapping = [RKEntityMapping mappingForEntityForName:@"KeywordFashionistaContent" inManagedObjectStore:[RKManagedObjectStore defaultStore]];
    
    // Assign identificationAttributes ensuring that all objects stored in Core Data will have unique IDs
    keywordFashionistaContentPopulatedMapping.identificationAttributes = @[@"idKeywordFashionistaContent"];
    
    // Add attributes mapping. The dictionary maps attributes on the JSON response to properties of the object in the data model. JSON : COREDATA
    [keywordFashionistaContentPopulatedMapping addAttributeMappingsFromDictionary:@{
                                                                           @"id" : @"idKeywordFashionistaContent",
                                                                           @"group" : @"group",
                                                                           @"fashionistapostcontent_keywords" : @"fashionistaContentId",
                                                                           @"tagXCoord" : @"xPos",
                                                                           @"tagYCoord" : @"yPos"
                                                                           }];
    
    // Follow
    
    // Instance RKEntityMapping
    RKEntityMapping *followMapping = [RKEntityMapping mappingForEntityForName:@"Follow" inManagedObjectStore:[RKManagedObjectStore defaultStore]];
    
    // Assign identificationAttributes ensuring that all objects stored in Core Data will have unique IDs
    followMapping.identificationAttributes = @[@"idFollow"];
    
    // Add attributes mapping. The dictionary maps attributes on the JSON response to properties of the object in the data model. JSON : COREDATA
    [followMapping addAttributeMappingsFromDictionary:@{
                                                         @"id" : @"idFollow",
                                                         @"following" : @"followingId",
                                                         @"follower" : @"followedId",
                                                         @"verified": @"verified"
                                                         }];
    
    
    // setFollow
    
    // Instance RKObjectMapping
    RKObjectMapping *setFollowMapping = [RKObjectMapping mappingForClass:[setFollow class]];
    
    // Add attributes mapping. The dictionary maps attributes on the JSON response to properties of the object in the data model. JSON : COREDATA
    [setFollowMapping addAttributeMappingsFromDictionary:@{
                                                             @"follow" : @"follow",
                                                             }];
    
    
    // unsetFollow
    
    // Instance RKObjectMapping
    RKObjectMapping *unsetFollowMapping = [RKObjectMapping mappingForClass:[unsetFollow class]];
    
    // Add attributes mapping. The dictionary maps attributes on the JSON response to properties of the object in the data model. JSON : COREDATA
    [unsetFollowMapping addAttributeMappingsFromDictionary:@{
                                                           @"unfollow" : @"unfollow",
                                                           }];
    
    
    // PostLike
    
    // Instance RKEntityMapping
    RKEntityMapping *postLikeMapping = [RKEntityMapping mappingForEntityForName:@"PostLike" inManagedObjectStore:[RKManagedObjectStore defaultStore]];
    
    // Assign identificationAttributes ensuring that all objects stored in Core Data will have unique IDs
    postLikeMapping.identificationAttributes = @[@"idPostLike"];
    
    // Add attributes mapping. The dictionary maps attributes on the JSON response to properties of the object in the data model. JSON : COREDATA
    [postLikeMapping addAttributeMappingsFromDictionary:@{
                                                        @"id" : @"idPostLike",
                                                        @"post" : @"postId",
                                                        @"user" : @"userId",
                                                        }];
    
    
    
    // Share
    
    // Instance RKEntityMapping
    RKEntityMapping *shareMapping = [RKEntityMapping mappingForEntityForName:@"Share" inManagedObjectStore:[RKManagedObjectStore defaultStore]];
    
    // Assign identificationAttributes ensuring that all objects stored in Core Data will have unique IDs
    shareMapping.identificationAttributes = @[@"idShare"];
    
    // Add attributes mapping. The dictionary maps attributes on the JSON response to properties of the object in the data model. JSON : COREDATA
    [shareMapping addAttributeMappingsFromDictionary:@{
                                                              @"id" : @"idShare",
                                                              @"user" : @"sharingUserId",
                                                              @"fashionistaPost" : @"sharedPostId",
                                                              @"product" : @"sharedProductId",
                                                              }];

    // Country
    
    // Instance RKEntityMapping
    RKEntityMapping *countryMapping = [RKEntityMapping mappingForEntityForName:@"Country" inManagedObjectStore:[RKManagedObjectStore defaultStore]];
    
    // Assign identificationAttributes ensuring that all objects stored in Core Data will have unique IDs
    countryMapping.identificationAttributes = @[@"idCountry"];
    
    // Add attributes mapping. The dictionary maps attributes on the JSON response to properties of the object in the data model. JSON : COREDATA
    [countryMapping addAttributeMappingsFromDictionary:@{
                                                         @"id": @"idCountry",
                                                         @"name" : @"name",
                                                         @"countryCode" : @"countryCode",
                                                         @"currencyCode" : @"currencyCode",
                                                         @"currencySymbol" : @"currencySymbol",
                                                         @"currency" : @"currency",
                                                         @"callingCodes" : @"callingCodes",
                                                         }];
    
    // StateRegion
    
    // Instance RKEntityMapping
    RKEntityMapping *stateregionMapping = [RKEntityMapping mappingForEntityForName:@"StateRegion" inManagedObjectStore:[RKManagedObjectStore defaultStore]];
    
    // Assign identificationAttributes ensuring that all objects stored in Core Data will have unique IDs
    stateregionMapping.identificationAttributes = @[@"idStateRegion"];
    
    // Add attributes mapping. The dictionary maps attributes on the JSON response to properties of the object in the data model. JSON : COREDATA
    [stateregionMapping addAttributeMappingsFromDictionary:@{
                                                         @"id": @"idStateRegion",
                                                         @"name" : @"name",
                                                         @"parentstateregion" : @"parentstateregionId",
                                                         @"country" : @"countryId",
                                                         }];
    
    // City
    
    // Instance RKEntityMapping
    RKEntityMapping *cityMapping = [RKEntityMapping mappingForEntityForName:@"City" inManagedObjectStore:[RKManagedObjectStore defaultStore]];
    
    // Assign identificationAttributes ensuring that all objects stored in Core Data will have unique IDs
    cityMapping.identificationAttributes = @[@"idCity"];
    
    // Add attributes mapping. The dictionary maps attributes on the JSON response to properties of the object in the data model. JSON : COREDATA
    [cityMapping addAttributeMappingsFromDictionary:@{
                                                         @"id": @"idCity",
                                                         @"name" : @"name",
                                                         @"country" : @"countryId",
                                                         @"stateregion" : @"stateregionId",
                                                         }];

    //PostCategory
    // Instance RKEntityMapping
    RKEntityMapping *postCategoryMapping = [RKEntityMapping mappingForEntityForName:@"PostCategory" inManagedObjectStore:[RKManagedObjectStore defaultStore]];
    
    // Assign identificationAttributes ensuring that all objects stored in Core Data will have unique IDs
    postCategoryMapping.identificationAttributes = @[@"categoryId"];
    
    // Add attributes mapping. The dictionary maps attributes on the JSON response to properties of the object in the data model. JSON : COREDATA
    [postCategoryMapping addAttributeMappingsFromDictionary:@{
                                                      @"id": @"categoryId",
                                                      @"name" : @"name",
                                                      @"order" : @"order",
                                                      @"inuser" : @"inUser",
                                                      @"indiscover" : @"inDiscover",
                                                      }];
    
    //PostOrdering
    // Instance RKEntityMapping
    RKEntityMapping *postOrderingMapping = [RKEntityMapping mappingForEntityForName:@"PostOrdering" inManagedObjectStore:[RKManagedObjectStore defaultStore]];
    
    // Assign identificationAttributes ensuring that all objects stored in Core Data will have unique IDs
    postOrderingMapping.identificationAttributes = @[@"orderingId"];
    
    // Add attributes mapping. The dictionary maps attributes on the JSON response to properties of the object in the data model. JSON : COREDATA
    [postOrderingMapping addAttributeMappingsFromDictionary:@{
                                                              @"id": @"orderingId",
                                                              @"name" : @"name",
                                                              @"order" : @"order",
                                                              @"inuser" : @"inUser",
                                                              @"indiscover" : @"inDiscover",
                                                              @"field" : @"field",
                                                              @"visibleInLandingPage" : @"visibleInLandingPage",
                                                              }];
    
    // POI, Locations
    // Instance RKEntityMapping
    RKEntityMapping *poiMapping = [RKEntityMapping mappingForEntityForName:@"POI" inManagedObjectStore:[RKManagedObjectStore defaultStore]];
    
    // Assign identificationAttributes ensuring that all objects stored in Core Data will have unique IDs
    poiMapping.identificationAttributes = @[@"idPOI"];
    
    // Add attributes mapping. The dictionary maps attributes on the JSON response to properties of the object in the data model. JSON : COREDATA
    [poiMapping addAttributeMappingsFromDictionary:@{
                                                              @"_id": @"idPOI",
                                                              @"name" : @"name",
                                                              @"address" : @"address",
                                                              @"latitude" : @"latitude",
                                                              @"longitude" : @"longitude",
                                                              @"asciiname" : @"asciiname",
                                                              @"featureclass" : @"featureclass",
                                                              @"featurecode" : @"featurecode",
                                                              }];
    
    // LiveStreamingCategory
    // Instance RKEntityMapping
    RKEntityMapping *liveStreamingCategoryMapping = [RKEntityMapping mappingForEntityForName:@"LiveStreamingCategory" inManagedObjectStore:[RKManagedObjectStore defaultStore]];
    
    // Assign identificationAttributes ensuring that all objects stored in Core Data will have unique IDs
    liveStreamingCategoryMapping.identificationAttributes = @[@"idLiveStreamingCategory"];
    
    // Add attributes mapping. The dictionary maps attributes on the JSON response to properties of the object in the data model. JSON : COREDATA
    [liveStreamingCategoryMapping addAttributeMappingsFromDictionary:@{
                                                                       @"id": @"idLiveStreamingCategory",
                                                                       @"name" : @"name",
                                                                       @"order" : @"order",
                                                                       @"isNews" : @"isNews",
                                                                       @"isTrending" : @"isTrending",
                                                                       @"numLiveStreams" : @"numLiveStreams",
                                                                       @"numActiveLiveStreams" : @"numActiveLiveStreams",
//                                                                       @"livestreamings" : @"livestreamings",
                                                                       }];
    
    // LiveStreamingComment
    // Instance RKEntityMapping
    RKEntityMapping *liveStreamingCommentMapping = [RKEntityMapping mappingForEntityForName:@"LiveStreamingComment" inManagedObjectStore:[RKManagedObjectStore defaultStore]];
    
    // Assign identificationAttributes ensuring that all objects stored in Core Data will have unique IDs
    liveStreamingCommentMapping.identificationAttributes = @[@"idLiveStreamingComment"];
    
    // Add attributes mapping. The dictionary maps attributes on the JSON response to properties of the object in the data model. JSON : COREDATA
    [liveStreamingCommentMapping addAttributeMappingsFromDictionary:@{
                                                                       @"id": @"idLiveStreamingComment",
                                                                       @"location" : @"location",
                                                                       @"text" : @"text",
                                                                       @"fashionista_name" : @"fashionista_name",
                                                                       @"user_picture" : @"user_picture",
                                                                       @"user" : @"userId",
                                                                       @"livestreaming" : @"liveStreamingId",
                                                                       }];
    
    // LiveStreamingEthnicity
    // Instance RKEntityMapping
    RKEntityMapping *liveStreamingEthnicityMapping = [RKEntityMapping mappingForEntityForName:@"LiveStreamingEthnicity" inManagedObjectStore:[RKManagedObjectStore defaultStore]];
    
    // Assign identificationAttributes ensuring that all objects stored in Core Data will have unique IDs
    liveStreamingEthnicityMapping.identificationAttributes = @[@"idLiveStreamingEthnicity"];
    
    // Add attributes mapping. The dictionary maps attributes on the JSON response to properties of the object in the data model. JSON : COREDATA
    [liveStreamingEthnicityMapping addAttributeMappingsFromDictionary:@{
                                                     @"id": @"idLiveStreamingEthnicity",
                                                     @"livestreaming" : @"livestreamingId",
                                                     @"ethnicity" : @"ethnicityId",
                                                     @"other" : @"other",
                                                     }];
    
    // LiveStreamingInvitation
    // Instance RKEntityMapping
    RKEntityMapping *liveStreamingInvitationMapping = [RKEntityMapping mappingForEntityForName:@"LiveStreamingInvitation" inManagedObjectStore:[RKManagedObjectStore defaultStore]];
    
    // Assign identificationAttributes ensuring that all objects stored in Core Data will have unique IDs
    liveStreamingInvitationMapping.identificationAttributes = @[@"idLiveStreamingInvitation"];
    
    // Add attributes mapping. The dictionary maps attributes on the JSON response to properties of the object in the data model. JSON : COREDATA
    [liveStreamingInvitationMapping addAttributeMappingsFromDictionary:@{
                                                                         @"id": @"idLiveStreamingInvitation",
                                                                         @"userinvited" : @"userinvitedId",
                                                                         @"owner" : @"ownerId",
                                                                         @"livestreaming" : @"livestreamingId",
                                                                         @"ownerpicture_livestreaming" : @"ownerpicture_livestreaming",
                                                                         @"ownerusername_livestreaming" : @"ownerusername_livestreaming",
                                                                         }];
    
    // LiveStreamingLike
    // Instance RKEntityMapping
    RKEntityMapping *liveStreamingLikeMapping = [RKEntityMapping mappingForEntityForName:@"LiveStreamingLike" inManagedObjectStore:[RKManagedObjectStore defaultStore]];
    
    // Assign identificationAttributes ensuring that all objects stored in Core Data will have unique IDs
    liveStreamingLikeMapping.identificationAttributes = @[@"idLiveStreamingLike"];
    
    // Add attributes mapping. The dictionary maps attributes on the JSON response to properties of the object in the data model. JSON : COREDATA
    [liveStreamingLikeMapping addAttributeMappingsFromDictionary:@{
                                                                         @"id": @"idLiveStreamingLike",
                                                                         @"user" : @"userId",
                                                                         @"livestreaming" : @"livestreamingId",
                                                                         }];
    
    // LiveStreaming
    // Instance RKEntityMapping
    RKEntityMapping *liveStreamingMapping = [RKEntityMapping mappingForEntityForName:@"LiveStreaming" inManagedObjectStore:[RKManagedObjectStore defaultStore]];
    
    // Assign identificationAttributes ensuring that all objects stored in Core Data will have unique IDs
    liveStreamingMapping.identificationAttributes = @[@"idLiveStreaming"];
    
    // Add attributes mapping. The dictionary maps attributes on the JSON response to properties of the object in the data model. JSON : COREDATA
    [liveStreamingMapping addAttributeMappingsFromDictionary:@{
                                                     @"id": @"idLiveStreaming",
//                                                     @"ethnicities" : @"ethnicities",
//                                                     @"cities" : @"cities",
//                                                     @"stateregions" : @"stateregions",
//                                                     @"countries" : @"countries",
//                                                     @"categories" : @"categories",
//                                                     @"hashtags" : @"hashtags",
//                                                     @"productcategories" : @"productcategories",
//                                                     @"brands" : @"brands",
//                                                     @"typelooks" : @"typelooks",
                                                     @"privacy" : @"privacyId",
                                                     @"owner" : @"ownerId",
                                                     @"numLikes" : @"numLikes",
                                                     @"numShares" : @"numShares",
                                                     @"numComments" : @"numComments",
                                                     @"numViews" : @"numViews",
                                                     @"numActiveViews" : @"numActiveViews",
                                                     @"path_video" : @"path_video",
                                                     @"post" : @"postId",
                                                     @"preview_video" : @"preview_video",
                                                     @"preview_image" : @"preview_image",
                                                     @"preview_image_width" : @"preview_image_width",
                                                     @"preview_image_height" : @"preview_image_height",
                                                     @"owner_picture" : @"owner_picture",
                                                     @"owner_username" : @"owner_username",
                                                     @"location" : @"location",
                                                     @"longitud" : @"longitud",
                                                     @"latitude" : @"latitude",
                                                     @"ageRangeString" : @"ageRange",
                                                     @"genderString" : @"gender",
                                                     @"expiration_date" : @"expiration_date",
                                                     @"title" : @"title",
                                                     }];
    
    // LiveStreamingPrivacy
    // Instance RKEntityMapping
    RKEntityMapping *liveStreamingPrivacyMapping = [RKEntityMapping mappingForEntityForName:@"LiveStreamingPrivacy" inManagedObjectStore:[RKManagedObjectStore defaultStore]];
    
    // Assign identificationAttributes ensuring that all objects stored in Core Data will have unique IDs
    liveStreamingPrivacyMapping.identificationAttributes = @[@"idLiveStreamingPrivacy"];
    
    // Add attributes mapping. The dictionary maps attributes on the JSON response to properties of the object in the data model. JSON : COREDATA
    [liveStreamingPrivacyMapping addAttributeMappingsFromDictionary:@{
                                                     @"id": @"idLiveStreamingPrivacy",
                                                     @"name" : @"name",
                                                     @"value" : @"value",
                                                     }];
    
    // TypeLook
    // Instance RKEntityMapping
    RKEntityMapping *typeLookPrivacyMapping = [RKEntityMapping mappingForEntityForName:@"TypeLook" inManagedObjectStore:[RKManagedObjectStore defaultStore]];
    
    // Assign identificationAttributes ensuring that all objects stored in Core Data will have unique IDs
    typeLookPrivacyMapping.identificationAttributes = @[@"idTypeLook"];
    
    // Add attributes mapping. The dictionary maps attributes on the JSON response to properties of the object in the data model. JSON : COREDATA
    [typeLookPrivacyMapping addAttributeMappingsFromDictionary:@{
                                                                      @"id": @"idTypeLook",
                                                                      @"name" : @"name",
                                                                      @"picture" : @"picture",
                                                                      }];
    
    
    // Ad
    // Instance RKEntityMapping
    RKEntityMapping *adMapping = [RKEntityMapping mappingForEntityForName:@"Ad" inManagedObjectStore:[RKManagedObjectStore defaultStore]];
    
    // Assign identificationAttributes ensuring that all objects stored in Core Data will have unique IDs
    adMapping.identificationAttributes = @[@"idAd"];
    
    // Add attributes mapping. The dictionary maps attributes on the JSON response to properties of the object in the data model. JSON : COREDATA
    [adMapping addAttributeMappingsFromDictionary:@{
                                                                      @"id": @"idAd",
                                                                      @"image" : @"image",
                                                                      @"video" : @"video",
                                                                      @"width" : @"width",
                                                                      @"height" : @"height",
                                                                      @"website" : @"website",
                                                                      @"order" : @"order",
                                                                      @"startDate" : @"startDate",
                                                                      @"endDate" : @"endDate",
                                                                      @"profile" : @"profileId",
                                                                      @"product" : @"productId",
                                                                      @"post" : @"postId",
                                                                      }];

    
    
    
    //// -------------------------------------------------------////
    //// ------------- NESTED RELATIONSHIPS MAPPING ------------////
    //// -------------------------------------------------------////
    /*
     
     // User
     
     [userMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"wishlist"
     toKeyPath:@"uWishlists"
     withMapping:wishlistMapping]];
     
     [userMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"review"
     toKeyPath:@"uReviews"
     withMapping:reviewMapping]];
     */
    
    [baseElementMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"post_comments"
                                                                                      toKeyPath:@"post_comments"
                                                                                     withMapping:commentMapping]];
    
    // Brand
    
    [brandMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"productCategories"
                                                                                 toKeyPath:@"productGroups"
                                                                               withMapping:productGroupMapping]];
    /*
     [brandMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"product"
     toKeyPath:@"bProducts"
     withMapping:productMapping]];
     
     [brandMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"shop"
     toKeyPath:@"bShops"
     withMapping:shopMapping]];
     */
    // Results Group
    
    [resultsGroupMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"keywords"
                                                                                        toKeyPath:@"keywords"
                                                                                      withMapping:keywordMapping]];
    
    // Product
     
    [productMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"variantGroup"
                                                                                   toKeyPath:@"variantGroup"
                                                                                 withMapping:variantGroupMapping]];
    
    [variantGroupMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"colours"
                                                                                        toKeyPath:@"colours"
                                                                                      withMapping:variantGroupElementMapping]];

    [variantGroupMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"materials"
                                                                                        toKeyPath:@"materials"
                                                                                      withMapping:variantGroupElementMapping]];
    
    [variantGroupMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"variants"
                                                                                        toKeyPath:@"variants"
                                                                                      withMapping:variantGroupElementMapping]];
    
    /*
     [productMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"contents"
     toKeyPath:@"content"
     withMapping:contentMapping]];
     
     [productMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"reviews"
     toKeyPath:@"reviews"
     withMapping:reviewMapping]];
     
     [productMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"variant"
     toKeyPath:@"pVariants"
     withMapping:variantMapping]];
     
     // Variant
     
     [variantMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"brand"
     toKeyPath:@"vBrand"
     withMapping:brandMapping]];
     
     [variantMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"availability"
     toKeyPath:@"vAvailabilities"
     withMapping:availabilityMapping]];
     
     [variantMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"multimedia"
     toKeyPath:@"vMultimedias"
     withMapping:multimediaMapping]];
     
     [variantMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"price"
     toKeyPath:@"vPrices"
     withMapping:priceMapping]];
     
     [variantMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"tag"
     toKeyPath:@"vtags"
     withMapping:tagMapping]];
     
     [variantMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"product"
     toKeyPath:@"vProduct"
     withMapping:productMapping]];
     
     [variantMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"product_category"
     toKeyPath:@"vProductCategory"
     withMapping:productCategoryMapping]];
     
     [variantMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"wishlist"
     toKeyPath:@"vWishlists"
     withMapping:wishlistMapping]];
     
     [variantMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"review"
     toKeyPath:@"vReviews"
     withMapping:reviewMapping]];
     
     // Price
     
     [priceMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"shop"
     toKeyPath:@"pShops"
     withMapping:shopMapping]];
     
     [priceMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"variant"
     toKeyPath:@"pVariant"
     withMapping:variantMapping]];
     
     // tag
     
     [tagMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"variant"
     toKeyPath:@"tVariants"
     withMapping:variantMapping]];
     
     [tagMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"tag_category"
     toKeyPath:@"ttagCategory"
     withMapping:tagCategoryMapping]];
     
     // Multimedia
     
     [multimediaMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"variant"
     toKeyPath:@"mVariants"
     withMapping:variantMapping]];
     
     // Availability
     
     [availabilityMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"shop"
     toKeyPath:@"aShop"
     withMapping:shopMapping]];
     
     [availabilityMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"variant"
     toKeyPath:@"aVariant"
     withMapping:variantMapping]];
     
     // Shop
     
     [shopMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"availability"
     toKeyPath:@"sAvailabilities"
     withMapping:availabilityMapping]];
     
     [shopMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"brand"
     toKeyPath:@"sBrand"
     withMapping:brandMapping]];
     
     [shopMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"price"
     toKeyPath:@"sPrices"
     withMapping:priceMapping]];
     
     // Wishlist
     
     [wishlistMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"products"
     toKeyPath:@"wProducts"
     withMapping:variantMapping]];
     
     [wishlistMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"user"
     toKeyPath:@"wUser"
     withMapping:userMapping]];
     
     // Review
     
     [reviewMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"variant"
     toKeyPath:@"rVariant"
     withMapping:variantMapping]];
     
     [reviewMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"user"
     toKeyPath:@"rUser"
     withMapping:userMapping]];
     
     // ProductCategory
     
     //    [productCategoryMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"parent_category"
     //                                                                                  toKeyPath:@"pcParentCategory"
     //                                                                                withMapping:productCategoryMapping]];
     //
     //    [productCategoryMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"generalCat"
     //                                                                                  toKeyPath:@"pcSubCategories"
     //                                                                                withMapping:productCategoryMapping]];
     
     //    [productCategoryMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"tagCategories"
     //                                                                                           toKeyPath:@"pctagCategories"
     //                                                                                         withMapping:tagCategoryMapping]];
     
     //  [productCategoryMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"product"
     //                                                                                  toKeyPath:@"pcProducts"
     //                                                                                withMapping:productMapping]];
     
     // tagCategory
     
     //    [tagCategoryMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"parent_category"
     //                                                                                           toKeyPath:@"tcParentCategory"
     //                                                                                         withMapping:tagCategoryMapping]];
     //
     //    [tagCategoryMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"tag_category"
     //                                                                                           toKeyPath:@"tcSubCategories"
     //                                                                                         withMapping:tagCategoryMapping]];
     //
     //    [tagCategoryMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"product_category"
     //                                                                                           toKeyPath:@"tcProductCategories"
     //                                                                                         withMapping:productCategoryMapping]];
     
     [tagCategoryMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"tags"
     toKeyPath:@"tctags"
     withMapping:tagMapping]];
     */
    
    // productGroup
    //    [productGroupMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"parent"
    //                                                                                  toKeyPath:@"parent"
    //                                                                                withMapping:productGroupMapping]];
    
    [productGroupMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"productCategories"
                                                                                        toKeyPath:@"productGroups"
                                                                                      withMapping:productGroupMapping]];
    
    [productGroupMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"featuresGroup"
                                                                                        toKeyPath:@"featuresGroup"
                                                                                      withMapping:featureGroupMapping]];
    
    [productGroupMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"featuresGroup"
                                                                                        toKeyPath:@"featuresGroupOrder"
                                                                                      withMapping:featureGroupOrderMapping]];
    
    // featureGroup
    
    //    [featureGroupMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"productCategories"
    //                                                                                        toKeyPath:@"productGroups"
    //                                                                                      withMapping:productGroupMapping]];
    
    [featureGroupMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"features"
                                                                                        toKeyPath:@"features"
                                                                                      withMapping:featureMapping]];
    
    //    [featureGroupMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"featuresGroup"
    //                                                                                        toKeyPath:@"featureGroups"
    //                                                                                      withMapping:featureGroupMapping]];
    
    // features
    // NON-NESTED
    //    [featureMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"featureGroup"
    //                                                                                        toKeyPath:@"featureGroup"
    //                                                                                      withMapping:featureGroupMapping]];
    
    // city
    [cityMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"stateregion"
                                                                                toKeyPath:@"stateregion"
                                                                              withMapping:stateregionMapping]];
    
    //Fashionista post

    [fashionistaFullPostMappingGet addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"contents"
                                                                                                  toKeyPath:@"contents"
                                                                                                withMapping:fashionistaContentMapping]];
    
    [fashionistaFullPostMappingGet addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"author"
                                                                                                  toKeyPath:@"author"
                                                                                                withMapping:userMapping]];
    
    [fashionistaFullPostMappingGet addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"commentsfull"
                                                                                                  toKeyPath:@"comments"
                                                                                                withMapping:commentMapping]];
    
    // product availability
    [productAvailabilityMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"timetable"
                                                                                        toKeyPath:@"timetables"
                                                                                      withMapping:productAvailabilityTimeTableMapping]];
    
    [productAvailabilityTimeTableMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"hours"
                                                                                               toKeyPath:@"hours"
                                                                                             withMapping:productAvailabilityTimeTableintervalTimeMapping]];

    
    //// -------------------------------------------------------////
    //// ----------- NON-NESTED RELATIONSHIPS MAPPING ----------////
    //// -------------------------------------------------------////
    
    // User
    
    [userMapping addConnectionForRelationship:@"wardrobes" connectedBy:@{@"wardrobesId": @"idWardrobe"}];
    
    [userMapping addConnectionForRelationship:@"reviews" connectedBy:@{@"reviewsId": @"idReview"}];
    
    [userMapping addConnectionForRelationship:@"comments" connectedBy:@{@"commentsId": @"idComment"}];

    [userMapping addConnectionForRelationship:@"notifications" connectedBy:@{@"notificationsId": @"idNotification"}];

    // Brand
    
    [brandMapping addConnectionForRelationship:@"productGroups" connectedBy:@{@"productGroupsId": @"idProductGroup"}];
    
    /*
     //[brandMapping addConnectionForRelationship:@"bProducts" connectedBy:@{@"bProductsID": @"pId"}];
     
     [brandMapping addConnectionForRelationship:@"bShops" connectedBy:@{@"bShopsID": @"sId"}];
     */
    // Product
    
    [productMapping addConnectionForRelationship:@"brand" connectedBy:@{@"brandId": @"idBrand"}];
    
    /*    [productMapping addConnectionForRelationship:@"pVariants" connectedBy:@{@"pVariantsID": @"vId"}];
     
     // Variant
     
     [variantMapping addConnectionForRelationship:@"vAvailabilities" connectedBy:@{@"vAvailabilitiesID": @"aId"}];
     
     [variantMapping addConnectionForRelationship:@"vMultimedias" connectedBy:@{@"vMultimediasID": @"mId"}];
     
     [variantMapping addConnectionForRelationship:@"vPrices" connectedBy:@{@"vPricesID": @"pId"}];
     
     [variantMapping addConnectionForRelationship:@"vtags" connectedBy:@{@"vtagsID": @"tId"}];
     
     //[variantMapping addConnectionForRelationship:@"vProduct" connectedBy:@{@"vProductID": @"pId"}];
     
     [variantMapping addConnectionForRelationship:@"vProductCategory" connectedBy:@{@"vProductCategoryID": @"pcId"}];
     
     [variantMapping addConnectionForRelationship:@"vWishlists" connectedBy:@{@"vWishlistsID": @"wId"}];
     
     [variantMapping addConnectionForRelationship:@"vReviews" connectedBy:@{@"vReviewsID": @"rId"}];
     
     // Price
     
     [priceMapping addConnectionForRelationship:@"pShops" connectedBy:@{@"pShopsID": @"sId"}];
     
     [priceMapping addConnectionForRelationship:@"pVariant" connectedBy:@{@"pVariantID": @"vId"}];
     
     // tag
     
     [tagMapping addConnectionForRelationship:@"tVariants" connectedBy:@{@"tVariantsID": @"vId"}];
     
     [tagMapping addConnectionForRelationship:@"ttagCategory" connectedBy:@{@"ttagCategoryID": @"tcId"}];
     
     // Multimedia
     
     [contentMapping addConnectionForRelationship:@"product" connectedBy:@{@"productId": @"idProduct"}];
     
     // Availability
     
     [availabilityMapping addConnectionForRelationship:@"aShop" connectedBy:@{@"aShopID": @"sId"}];
     
     [availabilityMapping addConnectionForRelationship:@"aVariant" connectedBy:@{@"aVariantID": @"vId"}];
     
     // Shop
     
     [shopMapping addConnectionForRelationship:@"sAvailabilities" connectedBy:@{@"sAvailabilitiesID": @"aId"}];
     
     [shopMapping addConnectionForRelationship:@"sBrand" connectedBy:@{@"sBrandID": @"bId"}];
     
     [shopMapping addConnectionForRelationship:@"sPrices" connectedBy:@{@"sPricesID": @"pId"}];
     */
    // Wishlist
    
    [wardrobeMapping addConnectionForRelationship:@"user" connectedBy:@{@"userId": @"idUser"}];
    /*
     [wishlistMapping addConnectionForRelationship:@"wVariants" connectedBy:@{@"wVariantsID": @"vId"}];
     
     // Review
     
     [reviewMapping addConnectionForRelationship:@"product" connectedBy:@{@"productId": @"idProduct"}];
     */
    [reviewMapping addConnectionForRelationship:@"user" connectedBy:@{@"userId": @"idUser"}];
    
    // Comment
    
    [commentMapping addConnectionForRelationship:@"user" connectedBy:@{@"userId": @"idUser"}];
    
    // Notification
    
    [notificationMapping addConnectionForRelationship:@"actionUser" connectedBy:@{@"actionUserId": @"idUser"}];

    // ProductGroup
    
    [productGroupMapping addConnectionForRelationship:@"brands" connectedBy:@{@"brandsId": @"idBrand"}];
    [productGroupMapping addConnectionForRelationship:@"parent" connectedBy:@{@"parentId": @"idProductGroup"}];
    /*
     
     [productCategoryMapping addConnectionForRelationship:@"pcSubCategories" connectedBy:@{@"pcSubCategoriesID": @"pcId"}];
     
     [productCategoryMapping addConnectionForRelationship:@"pctagCategories" connectedBy:@{@"pctagCategoriesID": @"tcId"}];
     
     [productCategoryMapping addConnectionForRelationship:@"pcProducts" connectedBy:@{@"pcProductsID": @"vId"}];
     
     // tagCategory
     
     [tagCategoryMapping addConnectionForRelationship:@"tcParentCategory" connectedBy:@{@"tcParentCategoryID": @"tcId"}];
     
     [tagCategoryMapping addConnectionForRelationship:@"tcSubCategories" connectedBy:@{@"tcSubCategoriesID": @"tcId"}];
     
     //[tagCategoryMapping addConnectionForRelationship:@"tcProductCategories" connectedBy:@{@"tcProductCategoriesID": @"pcId"}];
     
     [tagCategoryMapping addConnectionForRelationship:@"tctags" connectedBy:@{@"tctagsID": @"tId"}];
     */
    
    // examples non nested relations
    //    [productMapping addConnectionForRelationship:@"brand" connectedBy:@{@"brandId": @"idBrand"}];
    //    [userMapping addConnectionForRelationship:@"reviews" connectedBy:@{@"reviewsId": @"idReview"}];
    
    // featureGroup
    [featureGroupMapping addConnectionForRelationship:@"featureGroups" connectedBy:@{@"featureGroupsId": @"idFeatureGroup"}];
    [featureGroupMapping addConnectionForRelationship:@"parent" connectedBy:@{@"parentId": @"idFeatureGroup"}];
    [featureGroupMapping addConnectionForRelationship:@"productGroups" connectedBy:@{@"productGroupsId": @"idProductGroup"}];
    [featureGroupMapping addConnectionForRelationship:@"productGroupsOrder" connectedBy:@{@"productGroupsOrderId": @"idFeatureGroupOrder"}];
    
    // featureGroupOrder
    [featureGroupOrderMapping addConnectionForRelationship:@"featureGroup" connectedBy:@{@"featureGroupId": @"idFeatureGroup"}];
    [featureGroupOrderMapping addConnectionForRelationship:@"productGroup" connectedBy:@{@"productGroupId": @"idProductGroup"}];
    
    // feature
    [featureMapping addConnectionForRelationship:@"featureGroup" connectedBy:@{@"featureGroupId": @"idFeatureGroup"}];
    
    
    //    [featureGroupMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"parent"
    //                                                                                        toKeyPath:@"parent"
    //                                                                                      withMapping:featureGroupMapping]];
    //    [featureGroupMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"productCategories"
    //                                                                                        toKeyPath:@"productGroups"
    //                                                                                      withMapping:productGroupMapping]];
    //
    //    [featureGroupMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"featuresGroup"
    //                                                                                        toKeyPath:@"featureGroups"
    //                                                                                      withMapping:featureGroupMapping]];
    //
    //    [productGroupMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"featuresGroup"
    //                                                                                        toKeyPath:@"featuresGroup"
    //                                                                                      withMapping:featureGroupMapping]];
    // Fashionista Content
    
    //[fashionistaContentMapping addConnectionForRelationship:@"fashionistaPost" connectedBy:@{@"fashionistaPostId": @"idFashionistaPost"}];
    
        [keywordFashionistaContentPopulatedMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"keyword_fashionistaPostContents"
                                                                                                    toKeyPath:@"keyword"
                                                                                                   withMapping:keywordMapping]];
    
    [keywordFashionistaContentMapping addConnectionForRelationship:@"fashionistaContent" connectedBy:@{@"fashionistaContentId": @"idFashionistaContent"}];
    [keywordFashionistaContentMapping addConnectionForRelationship:@"keyword" connectedBy:@{@"keywordId": @"idKeyword"}];
    
    // FashionistaPage
    
    [fashionistaPageMapping addConnectionForRelationship:@"user" connectedBy:@{@"userId": @"idUser"}];
    
    // feature
//    [fashionistaContentMapping addConnectionForRelationship:@"keywords" connectedBy:@{@"keywordsId": @"idKeyword"}];
    
    
    // StateRegion
    
    [stateregionMapping addConnectionForRelationship:@"states" connectedBy:@{@"statesId": @"idStateRegion"}];
    [stateregionMapping addConnectionForRelationship:@"parentstateregion" connectedBy:@{@"parentstateregionId": @"idStateRegion"}];

    // CityMapping
    [cityMapping addConnectionForRelationship:@"stateregion" connectedBy:@{@"stateregionId": @"idStateRegion"}];
    
    
    //// ------------------------------------------------------////
    //// ---------------- RESPONSE DESCRIPTORS ----------------////
    //// ------------------------------------------------------////
    
    // Register mappings with the provider using a response descriptor, which describes an object mapping that is applicable to an HTTP response
    
    // User
    
    RKResponseDescriptor *userResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:userMapping
                                                                                                method:RKRequestMethodAny
                                                                                           pathPattern:@"/user" //URLs for which the mapping should be used. This is appended to the base URL
                                                                                               keyPath:nil //Subset of the parsed JSON response data for which the mapping should be used (tells RestKit where to find the objects)
                                                                                           statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    RKResponseDescriptor *loginResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:userMapping
                                                                                                 method:RKRequestMethodAny
                                                                                            pathPattern:@"/login"
                                                                                                keyPath:nil
                                                                                            statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    RKResponseDescriptor *loginFacebookResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:userMapping
                                                                                                         method:RKRequestMethodAny
                                                                                                    pathPattern:@"/loginfacebook"
                                                                                                        keyPath:nil
                                                                                                    statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    RKResponseDescriptor *fingerprintResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:userMapping
                                                                                                 method:RKRequestMethodAny
                                                                                            pathPattern:@"/fingerprint"
                                                                                                keyPath:nil
                                                                                            statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    RKResponseDescriptor *updateUserResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:userMapping
                                                                                                      method:RKRequestMethodAny pathPattern:@"/user/:idUser"
                                                                                                     keyPath:nil
                                                                                                 statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    RKResponseDescriptor *getUserByNameResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:userMapping
                                                                                                         method:RKRequestMethodGET
                                                                                                    pathPattern:@"/user"
                                                                                                        keyPath:nil
                                                                                                    statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];

    RKResponseDescriptor *getUsersForAutofillResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:userMapping
                                                                                                         method:RKRequestMethodGET
                                                                                                    pathPattern:@"/getuserstoautofill/:idUser"
                                                                                                        keyPath:nil
                                                                                                    statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    RKResponseDescriptor *fashionistaPageAuthorResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:userMapping
                                                                                                      method:RKRequestMethodAny pathPattern:@"/fashionistapage/:idFashionistaPage/user"
                                                                                                     keyPath:nil
                                                                                                 statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];

    
    // SearchQuery
    
    RKResponseDescriptor *searchQueryResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:searchQueryMapping
                                                                                                       method:RKRequestMethodAny
                                                                                                  pathPattern:@"/search/:id" //URLs for which the mapping should be used. This is appended to the base URL
                                                                                                      keyPath:nil //Subset of the parsed JSON response data for which the mapping should be used (tells RestKit where to find the objects)
                                                                                                  statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    RKResponseDescriptor *searchQueryCppResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:searchQueryMapping
                                                                                                          method:RKRequestMethodAny
                                                                                                     pathPattern:@"/searchcpp/:id" //URLs for which the mapping should be used. This is appended to the base URL
                                                                                                         keyPath:nil //Subset of the parsed JSON response data for which the mapping should be used (tells RestKit where to find the objects)
                                                                                                     statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    
    // Similar
    
    RKResponseDescriptor *searchQueryViaSimilarSearchResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:searchQueryMapping
                                                                                                       method:RKRequestMethodAny
                                                                                                  pathPattern:@"/similar/:id" //URLs for which the mapping should be used. This is appended to the base URL
                                                                                                      keyPath:nil //Subset of the parsed JSON response data for which the mapping should be used (tells RestKit where to find the objects)
                                                                                                  statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    RKResponseDescriptor *searchQueryCppViaSimilarSearchResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:searchQueryMapping
                                                                                                                          method:RKRequestMethodAny
                                                                                                                     pathPattern:@"/similarcpp/:id" //URLs for which the mapping should be used. This is appended to the base URL
                                                                                                                         keyPath:nil //Subset of the parsed JSON response data for which the mapping should be used (tells RestKit where to find the objects)
                                                                                                                     statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    
    // SearchQuery for Trending
    
    RKResponseDescriptor *searchQueryViaTrendingResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:searchQueryMapping
                                                                                                                  method:RKRequestMethodAny
                                                                                                             pathPattern:@"/newgettrending/:searchString" //URLs for which the mapping should be used. This is appended to the base URL
                                                                                                                 keyPath:nil //Subset of the parsed JSON response data for which the mapping should be used (tells RestKit where to find the objects)
                                                                                                             statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    
    // SearchQuery for Trending
    
    RKResponseDescriptor *searchQueryViaTrendingWithoutSearchStringResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:searchQueryMapping
                                                                                                                                     method:RKRequestMethodAny
                                                                                                                                pathPattern:@"/newgettrending/" //URLs for which the mapping should be used. This is appended to the base URL
                                                                                                                                    keyPath:nil //Subset of the parsed JSON response data for which the mapping should be used (tells RestKit where to find the objects)
                                                                                                                                statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    
    // SearchQuery for newsfeed
    
    RKResponseDescriptor *searchQueryViaNewsfeedWithoutSearchStringResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:searchQueryMapping
                                                                                                                                     method:RKRequestMethodAny
                                                                                                                                pathPattern:@"/newsfeed/:idUser" //URLs for which the mapping should be used. This is appended to the base URL
                                                                                                                                    keyPath:nil //Subset of the parsed JSON response data for which the mapping should be used (tells RestKit where to find the objects)
                                                                                                                                statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    // SearchQuery for fashionista posts
    
    RKResponseDescriptor *searchQueryViaFashionistaPostsResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:searchQueryMapping
                                                                                                                          method:RKRequestMethodAny
                                                                                                                     pathPattern:@"/searchfashionistapostofuser/:idUser" //URLs for which the mapping should be used. This is appended to the base URL
                                                                                                                         keyPath:nil //Subset of the parsed JSON response data for which the mapping should be used (tells RestKit where to find the objects)
                                                                                                                     statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    // SearchQuery for fashionista like a post
    
    RKResponseDescriptor *searchQueryViaFashionistasLikePostResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:searchQueryMapping
                                                                                                                              method:RKRequestMethodAny
                                                                                                                         pathPattern:@"/searchfashionistalikepostcpp/:idPost/:searchString" //URLs for which the mapping should be used. This is appended to the base URL
                                                                                                                             keyPath:nil //Subset of the parsed JSON response data for which the mapping should be used (tells RestKit where to find the objects)
                                                                                                                         statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    RKResponseDescriptor *searchQueryViaFashionistasLikePost2ResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:searchQueryMapping
                                                                                                                              method:RKRequestMethodAny
                                                                                                                         pathPattern:@"/searchfashionistalikepostcpp/:idPost/" //URLs for which the mapping should be used. This is appended to the base URL
                                                                                                                             keyPath:nil //Subset of the parsed JSON response data for which the mapping should be used (tells RestKit where to find the objects)
                                                                                                                         statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    // SearchQuery for discover
    
    RKResponseDescriptor *searchQueryViaDiscoverResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:searchQueryMapping
                                                                                                                                     method:RKRequestMethodAny
                                                                                                                                pathPattern:@"/discover" //URLs for which the mapping should be used. This is appended to the base URL
                                                                                                                                    keyPath:nil //Subset of the parsed JSON response data for which the mapping should be used (tells RestKit where to find the objects)
                                                                                                                                statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    // SearchQuery for Fashionistas
    
    RKResponseDescriptor *searchQueryViaFashionistasResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:searchQueryMapping
                                                                                                                      method:RKRequestMethodAny
                                                                                                                 pathPattern:@"/searchfashionista/:searchString/:stylistRelationship" //URLs for which the mapping should be used. This is appended to the base URL
                                                                                                                     keyPath:nil //Subset of the parsed JSON response data for which the mapping should be used (tells RestKit where to find the objects)
                                                                                                                 statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    RKResponseDescriptor *searchQueryCppViaFashionistasResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:searchQueryMapping
                                                                                                                         method:RKRequestMethodAny
                                                                                                                    pathPattern:@"/searchfashionistacpp/:searchString/:stylistRelationship" //URLs for which the mapping should be used. This is appended to the base URL
                                                                                                                        keyPath:nil //Subset of the parsed JSON response data for which the mapping should be used (tells RestKit where to find the objects)
                                                                                                                    statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    RKResponseDescriptor *searchQueryViaSocialNetworkResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:searchQueryMapping
                                                                                                                      method:RKRequestMethodAny
                                                                                                                 pathPattern:@"/getfriendsfromsocialnetwork" //URLs for which the mapping should be used. This is appended to the base URL
                                                                                                                     keyPath:nil //Subset of the parsed JSON response data for which the mapping should be used (tells RestKit where to find the objects)
                                                                                                                 statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    // SearchQuery for Fashionistas
    
    RKResponseDescriptor *searchQueryViaFashionistasWithoutSearchStringResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:searchQueryMapping
                                                                                                                                         method:RKRequestMethodAny
                                                                                                                                    pathPattern:@"/searchfashionista//:stylistRelationship" //URLs for which the mapping should be used. This is appended to the base URL
                                                                                                                                        keyPath:nil //Subset of the parsed JSON response data for which the mapping should be used (tells RestKit where to find the objects)
                                                                                                                                    statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    RKResponseDescriptor *searchQueryCppViaFashionistasWithoutSearchStringResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:searchQueryMapping
                                                                                                                                            method:RKRequestMethodAny
                                                                                                                                       pathPattern:@"/searchfashionistacpp//:stylistRelationship" //URLs for which the mapping should be used. This is appended to the base URL
                                                                                                                                           keyPath:nil //Subset of the parsed JSON response data for which the mapping should be used (tells RestKit where to find the objects)
                                                                                                                                       statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    
    // SearchQuery for Fashionistas
    
    RKResponseDescriptor *searchQueryViaFashionistaPostResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:searchQueryMapping
                                                                                                                      method:RKRequestMethodAny
                                                                                                                 pathPattern:@"/searchfashionistapost/:searchString/:postType/:stylistRelationship" //URLs for which the mapping should be used. This is appended to the base URL
                                                                                                                     keyPath:nil //Subset of the parsed JSON response data for which the mapping should be used (tells RestKit where to find the objects)
                                                                                                                 statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    
    // SearchQuery for Fashionistas
    
    RKResponseDescriptor *searchQueryViaFashionistaPostWithoutSearchStringResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:searchQueryMapping
                                                                                                                                         method:RKRequestMethodAny
                                                                                                                                    pathPattern:@"/searchfashionistapost//:postType/:stylistRelationship" //URLs for which the mapping should be used. This is appended to the base URL
                                                                                                                                        keyPath:nil //Subset of the parsed JSON response data for which the mapping should be used (tells RestKit where to find the objects)
                                                                                                                                    statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    
    // SearchQuery for Fashionistas
    
    RKResponseDescriptor *searchQueryViaFashionistaPostWithoutPostTypeResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:searchQueryMapping
                                                                                                                         method:RKRequestMethodAny
                                                                                                                    pathPattern:@"/searchfashionistapost/:searchString//:stylistRelationship" //URLs for which the mapping should be used. This is appended to the base URL
                                                                                                                        keyPath:nil //Subset of the parsed JSON response data for which the mapping should be used (tells RestKit where to find the objects)
                                                                                                                    statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    
    // SearchQuery for Fashionistas
    
    RKResponseDescriptor *searchQueryViaFashionistaPostWithoutSearchStringNorPostTypeResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:searchQueryMapping
                                                                                                                                            method:RKRequestMethodAny
                                                                                                                                       pathPattern:@"/searchfashionistapost///:stylistRelationship" //URLs for which the mapping should be used. This is appended to the base URL
                                                                                                                                           keyPath:nil //Subset of the parsed JSON response data for which the mapping should be used (tells RestKit where to find the objects)
                                                                                                                                       statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    RKResponseDescriptor *searchQueryCppViaFashionistaPostResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:searchQueryMapping
                                                                                                                            method:RKRequestMethodAny
                                                                                                                       pathPattern:@"/searchfashionistapostcpp/:searchString/:postType/:stylistRelationship" //URLs for which the mapping should be used. This is appended to the base URL
                                                                                                                           keyPath:nil //Subset of the parsed JSON response data for which the mapping should be used (tells RestKit where to find the objects)
                                                                                                                       statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    
    // SearchQuery for Fashionistas Post
    
    RKResponseDescriptor *searchQueryCppViaFashionistaPostWithoutSearchStringResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:searchQueryMapping
                                                                                                                                               method:RKRequestMethodAny
                                                                                                                                          pathPattern:@"/searchfashionistapostcpp//:postType/:stylistRelationship" //URLs for which the mapping should be used. This is appended to the base URL
                                                                                                                                              keyPath:nil //Subset of the parsed JSON response data for which the mapping should be used (tells RestKit where to find the objects)
                                                                                                                                          statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    
    // SearchQuery for Fashionistas Post
    
    RKResponseDescriptor *searchQueryCppViaFashionistaPostWithoutPostTypeResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:searchQueryMapping
                                                                                                                                           method:RKRequestMethodAny
                                                                                                                                      pathPattern:@"/searchfashionistapostcpp/:searchString//:stylistRelationship" //URLs for which the mapping should be used. This is appended to the base URL
                                                                                                                                          keyPath:nil //Subset of the parsed JSON response data for which the mapping should be used (tells RestKit where to find the objects)
                                                                                                                                      statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    
    // SearchQuery for Fashionistas Post
    
    RKResponseDescriptor *searchQueryCppViaFashionistaPostWithoutSearchStringNorPostTypeResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:searchQueryMapping
                                                                                                                                                          method:RKRequestMethodAny
                                                                                                                                                     pathPattern:@"/searchfashionistapostcpp///:stylistRelationship" //URLs for which the mapping should be used. This is appended to the base URL
                                                                                                                                                         keyPath:nil //Subset of the parsed JSON response data for which the mapping should be used (tells RestKit where to find the objects)
                                                                                                                                                     statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    // SearchQuery for brands
    
    RKResponseDescriptor *searchQueryViaBrandWithoutSearchStringResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:searchQueryMapping
                                                                                                                                            method:RKRequestMethodAny
                                                                                                                                       pathPattern:@"/searchbrand/" //URLs for which the mapping should be used. This is appended to the base URL
                                                                                                                                           keyPath:nil //Subset of the parsed JSON response data for which the mapping should be used (tells RestKit where to find the objects)
                                                                                                                                       statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    // SearchQuery for brands
    
    RKResponseDescriptor *searchQueryViaBrandResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:searchQueryMapping
                                                                                                                                      method:RKRequestMethodAny
                                                                                                                                 pathPattern:@"/searchbrand/:searchString" //URLs for which the mapping should be used. This is appended to the base URL
                                                                                                                                     keyPath:nil //Subset of the parsed JSON response data for which the mapping should be used (tells RestKit where to find the objects)
                                                                                                                                 statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    // SearchQuery for brands
    
    RKResponseDescriptor *searchQueryViaBrandOnlyInitialResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:searchQueryMapping
                                                                                                               method:RKRequestMethodAny
                                                                                                          pathPattern:@"/searchbrand//:searchString" //URLs for which the mapping should be used. This is appended to the base URL
                                                                                                              keyPath:nil //Subset of the parsed JSON response data for which the mapping should be used (tells RestKit where to find the objects)
                                                                                                          statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    // SearchQuery for brands
    RKResponseDescriptor *searchQueryViaBrandInitialAndRegexResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:searchQueryMapping
                                                                                                               method:RKRequestMethodAny
                                                                                                          pathPattern:@"/searchbrand/:searchString/:initial" //URLs for which the mapping should be used. This is appended to the base URL
                                                                                                              keyPath:nil //Subset of the parsed JSON response data for which the mapping should be used (tells RestKit where to find the objects)
                                                                                                          statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    
    // SearchQuery for History
    
    RKResponseDescriptor *searchQueryViaHistoryResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:searchQueryMapping
                                                                                                                 method:RKRequestMethodAny
                                                                                                            pathPattern:@"/user/:IdUser/newhistory/:Date/:searchString" //URLs for which the mapping should be used. This is appended to the base URL
                                                                                                                keyPath:nil //Subset of the parsed JSON response data for which the mapping should be used (tells RestKit where to find the objects)
                                                                                                            statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    
    // SearchQuery for History
    
    RKResponseDescriptor *searchQueryViaHistoryWithoutSearchStringResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:searchQueryMapping
                                                                                                                                    method:RKRequestMethodAny
                                                                                                                               pathPattern:@"/user/:IdUser/newhistory/:Date/" //URLs for which the mapping should be used. This is appended to the base URL
                                                                                                                                   keyPath:nil //Subset of the parsed JSON response data for which the mapping should be used (tells RestKit where to find the objects)
                                                                                                                               statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    
    // SearchQuery when coming from visual search
    
    RKResponseDescriptor *searchQueryViaDetectionResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:searchQueryMapping
                                                                                                                   method:RKRequestMethodAny
                                                                                                              pathPattern:@"/statproductsquery/:idSearchQuery" //URLs for which the mapping should be used. This is appended to the base URL
                                                                                                                  keyPath:nil //Subset of the parsed JSON response data for which the mapping should be used (tells RestKit where to find the objects)
                                                                                                              statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    
    // SearchQuery for Get The Look
    
    RKResponseDescriptor *searchQueryViaGetTheLookResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:searchQueryMapping
                                                                                                                         method:RKRequestMethodAny
                                                                                                                    pathPattern:@"/getthelooks/:idProduct" //URLs for which the mapping should be used. This is appended to the base URL
                                                                                                                        keyPath:nil //Subset of the parsed JSON response data for which the mapping should be used (tells RestKit where to find the objects)
                                                                                                                    statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    RKResponseDescriptor *searchQueryCppViaGetTheLookResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:searchQueryMapping
                                                                                                                       method:RKRequestMethodAny
                                                                                                                  pathPattern:@"/getthelookscpp/:idProduct" //URLs for which the mapping should be used. This is appended to the base URL
                                                                                                                      keyPath:nil //Subset of the parsed JSON response data for which the mapping should be used (tells RestKit where to find the objects)
                                                                                                                  statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    
    // SearchQuery for Get The Look
    
    RKResponseDescriptor *searchQueryViaGetTheLookWithSearchResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:searchQueryMapping
                                                                                                                    method:RKRequestMethodAny
                                                                                                               pathPattern:@"/getthelooks/:idProduct/:searchString" //URLs for which the mapping should be used. This is appended to the base URL
                                                                                                                   keyPath:nil //Subset of the parsed JSON response data for which the mapping should be used (tells RestKit where to find the objects)
                                                                                                               statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    RKResponseDescriptor *searchQueryCppViaGetTheLookWithSearchResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:searchQueryMapping
                                                                                                                                 method:RKRequestMethodAny
                                                                                                                            pathPattern:@"/getthelookscpp/:idProduct/:searchString" //URLs for which the mapping should be used. This is appended to the base URL
                                                                                                                                keyPath:nil //Subset of the parsed JSON response data for which the mapping should be used (tells RestKit where to find the objects)
                                                                                                                            statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    RKResponseDescriptor *searchQueryViaGetUserLikesWithSearchResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:searchQueryMapping
                                                                                                                              method:RKRequestMethodAny
                                                                                                                         pathPattern:@"/fashionistapost/:idPost/likesuser" //URLs for which the mapping should be used. This is appended to the base URL
                                                                                                                             keyPath:nil //Subset of the parsed JSON response data for which the mapping should be used (tells RestKit where to find the objects)
                                                                                                                         statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];

    
    // ResultsGroup
    
    RKResponseDescriptor *resultsGroupResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:resultsGroupMapping
                                                                                                        method:RKRequestMethodAny
                                                                                                   pathPattern:@"/resultgroup" //URLs for which the mapping should be used. This is appended to the base URL
                                                                                                       keyPath:nil //Subset of the parsed JSON response data for which the mapping should be used (tells RestKit where to find the objects)
                                                                                                   statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    RKResponseDescriptor *resultsQueryResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:fashionistaPostMappingGet
                                                                                                        method:RKRequestMethodAny
                                                                                                   pathPattern:@"/resultQuery" //URLs for which the mapping should be used. This is appended to the base URL
                                                                                                       keyPath:@"fashionistapost" //Subset of the parsed JSON response data for which the mapping should be used (tells RestKit where to find the objects)
                                                                                                   statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    // GSBaseElement when getting it through a search response
    
    RKResponseDescriptor *baseElementResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:baseElementMapping
                                                                                                       method:RKRequestMethodAny
                                                                                                  pathPattern:@"/statproductsquery/:idSearchQuery/resultQueries" //URLs for which the mapping should be used. This is appended to the base URL
                                                                                                      keyPath:nil //Subset of the parsed JSON response data for which the mapping should be used (tells RestKit where to find the objects)
                                                                                                  statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    // GSBaseElement when getting it as the content of a wardrobe
    
    RKResponseDescriptor *baseElementAfterGettingWardrobeContentResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:baseElementMapping
                                                                                                                                  method:RKRequestMethodGET
                                                                                                                             pathPattern:@"/wardrobe/:idWardrobe/resultqueries" //URLs for which the mapping should be used. This is appended to the base URL
                                                                                                                                 keyPath:nil //Subset of the parsed JSON response data for which the mapping should be used (tells RestKit where to find the objects)
                                                                                                                             statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    // GSBaseElement when getting it as the content of a populated wardrobe
    
    RKResponseDescriptor *baseElementAfterGettingPopulatedWardrobeContentResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:baseElementMapping
                                                                                                                                           method:RKRequestMethodGET
                                                                                                                                      pathPattern:@"/wardrobe/:idWardrobe" //URLs for which the mapping should be used. This is appended to the base URL
                                                                                                                                          keyPath:@"resultQueries" //Subset of the parsed JSON response data for which the mapping should be used (tells RestKit where to find the objects)
                                                                                                                                      statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    // GSBaseElement when getting it as the result of adding an item to a wardrobe
    
    RKResponseDescriptor *baseElementAfterAddingAnItemToAWardrobeResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:baseElementMapping
                                                                                                                                   method:RKRequestMethodPOST
                                                                                                                              pathPattern:@"/wardrobe/:idWardrobe/addElement/:idResultQuery" //URLs for which the mapping should be used. This is appended to the base URL
                                                                                                                                  keyPath:nil //Subset of the parsed JSON response data for which the mapping should be used (tells RestKit where to find the objects)
                                                                                                                              statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];

    RKResponseDescriptor *baseElementAfterAddingAPostToAWardrobeResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:baseElementMapping
                                                                                                                                   method:RKRequestMethodPOST
                                                                                                                              pathPattern:@"/wardrobe/:idWardrobe/addFashionistaPost/:idPost" //URLs for which the mapping should be used. This is appended to the base URL
                                                                                                                                  keyPath:nil //Subset of the parsed JSON response data for which the mapping should be used (tells RestKit where to find the objects)
                                                                                                                              statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    // GSBaseElement updating
    RKResponseDescriptor *baseElementUpdatingResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:baseElementMapping
                                                                                                                                  method:RKRequestMethodPOST
                                                                                                                             pathPattern:@"/resultquery/:idBaseElement" //URLs for which the mapping should be used. This is appended to the base URL
                                                                                                                                 keyPath:nil //Subset of the parsed JSON response data for which the mapping should be used (tells RestKit where to find the objects)
                                                                                                                             statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    
    
    // UserReport
    
    RKResponseDescriptor *userReportResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:userReportMapping
                                                                                                         method:RKRequestMethodAny
                                                                                                    pathPattern:@"/reportUser" //URLs for which the mapping should be used. This is appended to the base URL
                                                                                                        keyPath:nil //Subset of the parsed JSON response data for which the mapping should be used (tells RestKit where to find the objects)
                                                                                                    statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    
    // PostContentReport
    
    RKResponseDescriptor *postContentReportResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:postContentReportMapping
                                                                                                         method:RKRequestMethodAny
                                                                                                    pathPattern:@"/reportPostContent" //URLs for which the mapping should be used. This is appended to the base URL
                                                                                                        keyPath:nil //Subset of the parsed JSON response data for which the mapping should be used (tells RestKit where to find the objects)
                                                                                                    statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    
    // PostCommentReport
    
    RKResponseDescriptor *postCommentReportResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:postCommentReportMapping
                                                                                                         method:RKRequestMethodAny
                                                                                                    pathPattern:@"/reportPostComment" //URLs for which the mapping should be used. This is appended to the base URL
                                                                                                        keyPath:nil //Subset of the parsed JSON response data for which the mapping should be used (tells RestKit where to find the objects)
                                                                                                    statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    
    // ProductReport
    
    RKResponseDescriptor *productReportResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:productReportMapping
                                                                                                       method:RKRequestMethodAny
                                                                                                  pathPattern:@"/reportProduct" //URLs for which the mapping should be used. This is appended to the base URL
                                                                                                      keyPath:nil //Subset of the parsed JSON response data for which the mapping should be used (tells RestKit where to find the objects)
                                                                                                  statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    
    // ProductView
    
    RKResponseDescriptor *productViewResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:productViewMapping
                                                                                                       method:RKRequestMethodAny
                                                                                                  pathPattern:@"/statproductview" //URLs for which the mapping should be used. This is appended to the base URL
                                                                                                      keyPath:nil //Subset of the parsed JSON response data for which the mapping should be used (tells RestKit where to find the objects)
                                                                                                  statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];

    // Product Availability
    
    RKResponseDescriptor *productAvailabilityResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:productAvailabilityMapping
                                                                                                       method:RKRequestMethodAny
                                                                                                  pathPattern:@"/product/:idProduct/availability" //URLs for which the mapping should be used. This is appended to the base URL
                                                                                                      keyPath:nil //Subset of the parsed JSON response data for which the mapping should be used (tells RestKit where to find the objects)
                                                                                                  statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    // ProductShared
    
    RKResponseDescriptor *productSharedResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:productSharedMapping
                                                                                                         method:RKRequestMethodAny
                                                                                                    pathPattern:@"/statProductShared" //URLs for which the mapping should be used. This is appended to the base URL
                                                                                                        keyPath:nil //Subset of the parsed JSON response data for which the mapping should be used (tells RestKit where to find the objects)
                                                                                                    statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    // ProductPurchase
    
    RKResponseDescriptor *productPurchaseResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:productPurchaseMapping
                                                                                                           method:RKRequestMethodAny
                                                                                                      pathPattern:@"/statProductPurchase" //URLs for which the mapping should be used. This is appended to the base URL
                                                                                                          keyPath:nil //Subset of the parsed JSON response data for which the mapping should be used (tells RestKit where to find the objects)
                                                                                                      statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    // PosttView
    
    RKResponseDescriptor *postViewResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:postViewMapping
                                                                                                       method:RKRequestMethodAny
                                                                                                  pathPattern:@"/statpostview" //URLs for which the mapping should be used. This is appended to the base URL
                                                                                                      keyPath:nil //Subset of the parsed JSON response data for which the mapping should be used (tells RestKit where to find the objects)
                                                                                                  statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    // PostViewTime
    
    RKResponseDescriptor *postViewTimeResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:postViewTimeMapping
                                                                                                        method:RKRequestMethodAny
                                                                                                   pathPattern:@"/statPostViewTime" //URLs for which the mapping should be used. This is appended to the base URL
                                                                                                       keyPath:nil //Subset of the parsed JSON response data for which the mapping should be used (tells RestKit where to find the objects)
                                                                                                   statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    // PosttShared
    
    RKResponseDescriptor *postSharedResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:postSharedMapping
                                                                                                      method:RKRequestMethodAny
                                                                                                 pathPattern:@"/statPostShared" //URLs for which the mapping should be used. This is appended to the base URL
                                                                                                     keyPath:nil //Subset of the parsed JSON response data for which the mapping should be used (tells RestKit where to find the objects)
                                                                                                 statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];

    RKResponseDescriptor *postUserUnfollowResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:postUserMapping
                                                                                                    method:RKRequestMethodAny
                                                                                               pathPattern:@"/postunfollow" //URLs for which the mapping should be used. This is appended to the base URL
                                                                                                   keyPath:nil //Subset of the parsed JSON response data for which the mapping should be used (tells RestKit where to find the objects)
                                                                                               statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    RKResponseDescriptor *postUserUnfollowDeleteResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:postUserMapping
                                                                                                               method:RKRequestMethodDELETE
                                                                                                          pathPattern:@"/postunfollow/:idPuf" //URLs for which the mapping should be used. This is appended to the base URL
                                                                                                              keyPath:nil //Subset of the parsed JSON response data for which the mapping should be used (tells RestKit where to find the objects)
                                                                                                          statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    RKResponseDescriptor *postUserIgnoreResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:postUserMapping
                                                                                                            method:RKRequestMethodAny
                                                                                                       pathPattern:@"/postignorenotices" //URLs for which the mapping should be used. This is appended to the base URL
                                                                                                           keyPath:nil //Subset of the parsed JSON response data for which the mapping should be used (tells RestKit where to find the objects)
                                                                                                       statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    RKResponseDescriptor *postUserIgnoreDeleteResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:postUserMapping
                                                                                                                  method:RKRequestMethodDELETE
                                                                                                             pathPattern:@"/postignorenotices/:idPuf" //URLs for which the mapping should be used. This is appended to the base URL
                                                                                                                 keyPath:nil //Subset of the parsed JSON response data for which the mapping should be used (tells RestKit where to find the objects)
                                                                                                             statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    RKResponseDescriptor *userUserIgnoreResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:userUserMapping
                                                                                                          method:RKRequestMethodAny
                                                                                                     pathPattern:@"/userignorenotices" //URLs for which the mapping should be used. This is appended to the base URL
                                                                                                         keyPath:nil //Subset of the parsed JSON response data for which the mapping should be used (tells RestKit where to find the objects)
                                                                                                     statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    // FashionistaView
    
    RKResponseDescriptor *fashionistaViewResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:fashionistaViewMapping
                                                                                                       method:RKRequestMethodAny
                                                                                                  pathPattern:@"/statfashionistaview" //URLs for which the mapping should be used. This is appended to the base URL
                                                                                                      keyPath:nil //Subset of the parsed JSON response data for which the mapping should be used (tells RestKit where to find the objects)
                                                                                                  statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    // FashionistaViewTime
    
    RKResponseDescriptor *fashionistaViewTimeResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:fashionistaViewTimeMapping
                                                                                                               method:RKRequestMethodAny
                                                                                                          pathPattern:@"/statFashionistaViewTime" //URLs for which the mapping should be used. This is appended to the base URL
                                                                                                              keyPath:nil //Subset of the parsed JSON response data for which the mapping should be used (tells RestKit where to find the objects)
                                                                                                          statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    RKResponseDescriptor *followFriendsFromSNResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:fashionistaViewMapping
                                                                                                           method:RKRequestMethodAny
                                                                                                      pathPattern:@"/user/:idUser/followfriendsfromsocialnetwork/:idSearchQuery" //URLs for which the mapping should be used. This is appended to the base URL
                                                                                                          keyPath:nil //Subset of the parsed JSON response data for which the mapping should be used (tells RestKit where to find the objects)
                                                                                                      statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    // WardrobeView
    
    RKResponseDescriptor *wardrobeViewResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:wardrobeViewMapping
                                                                                                       method:RKRequestMethodAny
                                                                                                  pathPattern:@"/statwardrobeview" //URLs for which the mapping should be used. This is appended to the base URL
                                                                                                      keyPath:nil //Subset of the parsed JSON response data for which the mapping should be used (tells RestKit where to find the objects)
                                                                                                  statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    // CommentView
    
    RKResponseDescriptor *commentViewResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:commentViewMapping
                                                                                                       method:RKRequestMethodAny
                                                                                                  pathPattern:@"/statcommentview" //URLs for which the mapping should be used. This is appended to the base URL
                                                                                                      keyPath:nil //Subset of the parsed JSON response data for which the mapping should be used (tells RestKit where to find the objects)
                                                                                                  statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    // reviewView
    
    RKResponseDescriptor *reviewProductViewResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:reviewProductViewMapping
                                                                                                       method:RKRequestMethodAny
                                                                                                  pathPattern:@"/statreviewproductview" //URLs for which the mapping should be used. This is appended to the base URL
                                                                                                      keyPath:nil //Subset of the parsed JSON response data for which the mapping should be used (tells RestKit where to find the objects)
                                                                                                  statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    /*
     
     // ProductView when coming form posting a new Productview
     
     RKResponseDescriptor *productViewAfterPostingProductViewResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:productViewMapping
     method:RKRequestMethodAny
     pathPattern:@"/statproductview" //URLs for which the mapping should be used. This is appended to the base URL
     keyPath:nil //Subset of the parsed JSON response data for which the mapping should be used (tells RestKit where to find the objects)
     statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];*/
    
    // Brand when getting it directly
    
    RKResponseDescriptor *brandResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:brandMapping
                                                                                                 method:RKRequestMethodAny
                                                                                            pathPattern:@"/product/:idProduct/brand" //URLs for which the mapping should be used. This is appended to the base URL
                                                                                                keyPath:nil //Subset of the parsed JSON response data for which the mapping should be used (tells RestKit where to find the objects)
                                                                                            statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    // Brand when getting it as a property of the product
    
    RKResponseDescriptor *brandViaProductResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:brandMapping
                                                                                                           method:RKRequestMethodAny
                                                                                                      pathPattern:@"product/:idBrand" //URLs for which the mapping should be used. This is appended to the base URL
                                                                                                          keyPath:@"brand" //Subset of the parsed JSON response data for which the mapping should be used (tells RestKit where to find the objects)
                                                                                                      statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    // Brand when getting all of them
    
    RKResponseDescriptor *brandViaAllThemResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:brandMapping
                                                                                                           method:RKRequestMethodAny
                                                                                                      pathPattern:@"/brand" //URLs for which the mapping should be used. This is appended to the base URL
                                                                                                          keyPath:nil //Subset of the parsed JSON response data for which the mapping should be used (tells RestKit where to find the objects)
                                                                                                      statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    
    // Brand when getting priority
    
    RKResponseDescriptor *brandPriorityResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:brandMapping
                                                                                                         method:RKRequestMethodAny
                                                                                                    pathPattern:@"/brand?where={\"priority\":{\"$gt\":0}}&sort=priority desc&limit=-1" //URLs for which the mapping should be used. This is appended to the base URL
                                                                                                        keyPath:nil //Subset of the parsed JSON response data for which the mapping should be used (tells RestKit where to find the objects)
                                                                                                    statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    // Product when getting it directly
    
    RKResponseDescriptor *productResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:productMapping
                                                                                                   method:RKRequestMethodGET
                                                                                              pathPattern:@"/product/:idProduct" //URLs for which the mapping should be used. This is appended to the base URL
                                                                                                  keyPath:nil //Subset of the parsed JSON response data for which the mapping should be used (tells RestKit where to find the objects)
                                                                                              statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    
    // Product when getting it as the content of a populated statproductview
    
    RKResponseDescriptor *productAfterGettingPopulatedStatProductViewResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:productMapping
                                                                                                                                       method:RKRequestMethodGET
                                                                                                                                  pathPattern:@"/statproductview" //URLs for which the mapping should be used. This is appended to the base URL
                                                                                                                                      keyPath:@"product" //Subset of the parsed JSON response data for which the mapping should be used (tells RestKit where to find the objects)
                                                                                                                                  statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    // FashionistaPage when getting it directly
    
    RKResponseDescriptor *fashionistaPageResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:fashionistaPageMapping
                                                                                                           method:RKRequestMethodGET
                                                                                                      pathPattern:@"/fashionistapage/:idFashionistaPage" //URLs for which the mapping should be used. This is appended to the base URL
                                                                                                          keyPath:nil //Subset of the parsed JSON response data for which the mapping should be used (tells RestKit where to find the objects)
                                                                                                      statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    // FashionistaPost when getting it directly
    
    RKResponseDescriptor *fashionistaPostResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:fashionistaPostMappingGet
                                                                                                           method:RKRequestMethodGET
                                                                                                      pathPattern:@"/fashionistapost/:idFashionistapost" //URLs for which the mapping should be used. This is appended to the base URL
                                                                                                          keyPath:nil //Subset of the parsed JSON response data for which the mapping should be used (tells RestKit where to find the objects)
                                                                                                      statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    RKResponseDescriptor *adResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:adMappingGet
                                                                                              method:RKRequestMethodAny
                                                                                         pathPattern:@"/getAdForUser/:idUser/:appsection"
                                                                                             keyPath:nil
                                                                                         statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    
    // FashionistaPost when getting it within the list of a FashionistaPage
    
    RKResponseDescriptor *fashionistaPostViaFashionistaPageResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:fashionistaPostMappingGet
                                                                                                           method:RKRequestMethodAny pathPattern:@"/fashionistapage/:IdFashionstaPage/fashionistaPosts"
                                                                                                          keyPath:nil
                                                                                                      statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    // ProductGroup
    
    RKResponseDescriptor *productGroupParentResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:productGroupMapping
                                                                                                              method:RKRequestMethodAny
                                                                                                         pathPattern:@"/productcategory" //URLs for which the mapping should be used. This is appended to the base URL
                                                                                                             keyPath:nil //Subset of the parsed JSON response data for which the mapping should be used (tells RestKit where to find the objects)
                                                                                                         statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    RKResponseDescriptor *subproductGroupResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:productGroupMapping
                                                                                                           method:RKRequestMethodAny
                                                                                                      pathPattern:@"/productcategory/:idProductCategoryParent/productCategories" //URLs for which the mapping should be used. This is appended to the base URL
                                                                                                          keyPath:nil //Subset of the parsed JSON response data for which the mapping should be used (tells RestKit where to find the objects)
                                                                                                      statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    RKResponseDescriptor *productGroupResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:productGroupMapping
                                                                                                        method:RKRequestMethodAny
                                                                                                   pathPattern:@"/product/:idProduct/category" //URLs for which the mapping should be used. This is appended to the base URL
                                                                                                       keyPath:nil //Subset of the parsed JSON response data for which the mapping should be used (tells RestKit where to find the objects)
                                                                                                   statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    
    
    // Price
    
    RKResponseDescriptor *priceResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:priceMapping
                                                                                                 method:RKRequestMethodAny
                                                                                            pathPattern:@"price" //URLs for which the mapping should be used. This is appended to the base URL
                                                                                                keyPath:@"price" //Subset of the parsed JSON response data for which the mapping should be used (tells RestKit where to find the objects)
                                                                                            statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    // Keyword when coming from a search
    
    RKResponseDescriptor *keywordResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:keywordMapping
                                                                                                   method:RKRequestMethodAny
                                                                                              pathPattern:@"/statproductsquery/:idSearchQuery/keywords" //URLs for which the mapping should be used. This is appended to the base URL
                                                                                                  keyPath:nil //Subset of the parsed JSON response data for which the mapping should be used (tells RestKit where to find the objects)
                                                                                              statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    // Keyword when getting all of them to be used in the KeyboardSuggestionBar
    
    RKResponseDescriptor *keywordViaGetAllThemResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:keywordMapping
                                                                                                                method:RKRequestMethodAny
                                                                                                           pathPattern:@"/keyword" //URLs for which the mapping should be used. This is appended to the base URL
                                                                                                               keyPath:nil //Subset of the parsed JSON response data for which the mapping should be used (tells RestKit where to find the objects)
                                                                                                           statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    RKResponseDescriptor *keywordGetFromStringResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:keywordMapping
                                                                                                                method:RKRequestMethodAny
                                                                                                           pathPattern:@"/getkeywordsFrom/:string" //URLs for which the mapping should be used. This is appended to the base URL
                                                                                                               keyPath:nil //Subset of the parsed JSON response data for which the mapping should be used (tells RestKit where to find the objects)
                                                                                                           statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    
    // Keyword when getting it as the content of a populated ResultsGroup
    
    RKResponseDescriptor *keywordAfterGettingPopulatedResultGroupResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:keywordMapping
                                                                                                                                   method:RKRequestMethodGET
                                                                                                                              pathPattern:@"/resultgroup" //URLs for which the mapping should be used. This is appended to the base URL
                                                                                                                                  keyPath:@"keyword" //Subset of the parsed JSON response data for which the mapping should be used (tells RestKit where to find the objects)
                                                                                                                              statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    
    
    // SuggestedKeyword
    
    RKResponseDescriptor *suggestedKeywordResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:suggestedKeywordMapping
                                                                                                            method:RKRequestMethodAny
                                                                                                       pathPattern:@"/statproductsquery/:idSearchQuery/suggestedKeywords" //URLs for which the mapping should be used. This is appended to the base URL
                                                                                                           keyPath:nil //Subset of the parsed JSON response data for which the mapping should be used (tells RestKit where to find the objects)
                                                                                                       statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    // Feature when getting it as a property of the product
    
    RKResponseDescriptor *featureFromProductResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:featureMapping
                                                                                                              method:RKRequestMethodAny
                                                                                                         pathPattern:@"/product/:idProduct/features" //URLs for which the mapping should be used. This is appended to the base URL
                                                                                                             keyPath:nil //Subset of the parsed JSON response data for which the mapping should be used (tells RestKit where to find the objects)
                                                                                                         statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    // Feature when getting it as a member of FeatureGroup
    
    RKResponseDescriptor *featureViaFeatureGroupResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:featureMapping
                                                                                                                  method:RKRequestMethodAny
                                                                                                             pathPattern:@"/featureGroup/:idFeatureGroup/featuresrecursive" //URLs for which the mapping should be used. This is appended to the base URL
                                                                                                                 keyPath:nil //Subset of the parsed JSON response data for which the mapping should be used (tells RestKit where to find the objects)
                                                                                                             statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    // Feature when getting it as a member of FeatureGroup
    
    RKResponseDescriptor *featureResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:featureMapping
                                                                                                   method:RKRequestMethodAny
                                                                                              pathPattern:@"/feature" //URLs for which the mapping should be used. This is appended to the base URL
                                                                                                  keyPath:nil //Subset of the parsed JSON response data for which the mapping should be used (tells RestKit where to find the objects)
                                                                                              statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    // Feature Group
    
    RKResponseDescriptor *featureGroupResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:featureGroupMapping
                                                                                                        method:RKRequestMethodAny
                                                                                                   pathPattern:@"/featureGroup" //URLs for which the mapping should be used. This is appended to the base URL
                                                                                                       keyPath:nil //Subset of the parsed JSON response data for which the mapping should be used (tells RestKit where to find the objects)
                                                                                                   statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    // FeatureGroup
    RKResponseDescriptor *featureGroupFromProductCategoryResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:featureGroupOrderMapping
                                                                                                                           method:RKRequestMethodAny
                                                                                                                      pathPattern:@"/productCategory/:idProductGroup/featuresGroup" //URLs for which the mapping should be used. This is appended to the base URL
                                                                                                                          keyPath:nil //Subset of the parsed JSON response data for which the mapping should be used (tells RestKit where to find the objects)
                                                                                                                      statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    // Content
    
    RKResponseDescriptor *contentResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:contentMapping
                                                                                                   method:RKRequestMethodAny
                                                                                              pathPattern:@"/product/:idProduct/contents" //URLs for which the mapping should be used. This is appended to the base URL
                                                                                                  keyPath:nil //Subset of the parsed JSON response data for which the mapping should be used (tells RestKit where to find the objects)
                                                                                              statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    // Fashionista Content when getting it directly
    
    RKResponseDescriptor *fashionistaContentResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:fashionistaContentMapping
                                                                                                              method:RKRequestMethodAny
                                                                                                         pathPattern:@"/fashionistaPostContent/:idFashionistaContent" //URLs for which the mapping should be used. This is appended to the base URL
                                                                                                             keyPath:nil //Subset of the parsed JSON response data for which the mapping should be used (tells RestKit where to find the objects)
                                                                                                         statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    // Fashionista Content when getting it as a property of the Post
    
    RKResponseDescriptor *fashionistaContentViaPostResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:fashionistaContentMapping
                                                                                                              method:RKRequestMethodAny
                                                                                                         pathPattern:@"/fashionistapost/:idFashionistaPost/fashionistaPostContents" //URLs for which the mapping should be used. This is appended to the base URL
                                                                                                             keyPath:nil //Subset of the parsed JSON response data for which the mapping should be used (tells RestKit where to find the objects)
                                                                                                         statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    // Availability
    
    RKResponseDescriptor *availabilityResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:availabilityMapping
                                                                                                        method:RKRequestMethodAny
                                                                                                   pathPattern:@"availability" //URLs for which the mapping should be used. This is appended to the base URL
                                                                                                       keyPath:@"availability" //Subset of the parsed JSON response data for which the mapping should be used (tells RestKit where to find the objects)
                                                                                                   statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    // Shop
    
    RKResponseDescriptor *shopResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:shopMapping
                                                                                                method:RKRequestMethodAny
                                                                                           pathPattern:@"/shop" //URLs for which the mapping should be used. This is appended to the base URL
                                                                                               keyPath:@"shop" //Subset of the parsed JSON response data for which the mapping should be used (tells RestKit where to find the objects)
                                                                                           statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    // Wardrobe when getting it as a property of the user
    
    RKResponseDescriptor *wardrobeResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:wardrobeMapping
                                                                                                    method:RKRequestMethodAny
                                                                                               pathPattern:@"/user/:idUser/wardrobes" //URLs for which the mapping should be used. This is appended to the base URL
                                                                                                   keyPath:nil //Subset of the parsed JSON response data for which the mapping should be used (tells RestKit where to find the objects)
                                                                                               statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    // Wardrobe when getting it as an answer to posting a new one
    
    RKResponseDescriptor *wardrobeAfterPostResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:wardrobeMapping
                                                                                                             method:RKRequestMethodAny
                                                                                                        pathPattern:@"/wardrobe" //URLs for which the mapping should be used. This is appended to the base URL
                                                                                                            keyPath:nil //Subset of the parsed JSON response data for which the mapping should be used (tells RestKit where to find the objects)
                                                                                                        statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    // Wardrobe when getting it as an answer to changing its name or deleting the wardrobe itself
    
    RKResponseDescriptor *wardrobeAfterRenameResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:wardrobeMapping
                                                                                                               method:RKRequestMethodAny
                                                                                                          pathPattern:@"/wardrobe/:idWardrobe" //URLs for which the mapping should be used. This is appended to the base URL
                                                                                                              keyPath:nil //Subset of the parsed JSON response data for which the mapping should be used (tells RestKit where to find the objects)
                                                                                                          statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    // Wardrobe when getting it as an answer to adding an item
    
    //    RKResponseDescriptor *wardrobeAfterAddingItemResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:wardrobeMapping
    //                                                                                                                      method:RKRequestMethodPOST
    //                                                                                                              pathPattern:@"/wardrobe/:idWardrobe/addElement/:idResultQuery" //URLs for which the mapping should be used. This is appended to the base URL
    //                                                                                                                     keyPath:nil //Subset of the parsed JSON response data for which the mapping should be used (tells RestKit where to find the objects)
    //                                                                                                                 statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    // Wardrobe when getting it as an answer to removing an item
    
    RKResponseDescriptor *wardrobeAfterRemovingItemResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:wardrobeMapping
                                                                                                                     method:RKRequestMethodDELETE
                                                                                                                pathPattern:@"/wardrobe/:idWardrobe/resultQueries/:idProduct" //URLs for which the mapping should be used. This is appended to the base URL
                                                                                                                    keyPath:nil //Subset of the parsed JSON response data for which the mapping should be used (tells RestKit where to find the objects)
                                                                                                                statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    // Wardrobe when getting it together with its content
    
    RKResponseDescriptor *wardrobeAfterGettingWardrobeContentResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:wardrobeMapping
                                                                                                                               method:RKRequestMethodGET
                                                                                                                          pathPattern:@"/wardrobe/:idWardrobe" //URLs for which the mapping should be used. This is appended to the base URL
                                                                                                                              keyPath:nil //Subset of the parsed JSON response data for which the mapping should be used (tells RestKit where to find the objects)
                                                                                                                          statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    // Review
    
    RKResponseDescriptor *reviewResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:reviewMapping
                                                                                                  method:RKRequestMethodGET
                                                                                             pathPattern:@"/product/:idProduct/reviews" //URLs for which the mapping should be used. This is appended to the base URL
                                                                                                 keyPath:nil //Subset of the parsed JSON response data for which the mapping should be used (tells RestKit where to find the objects)
                                                                                             statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    
    RKResponseDescriptor *reviewUploadResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:reviewMapping
                                                                                                  method:RKRequestMethodPOST
                                                                                             pathPattern:@"/review" //URLs for which the mapping should be used. This is appended to the base URL
                                                                                                 keyPath:nil //Subset of the parsed JSON response data for which the mapping should be used (tells RestKit where to find the objects)
                                                                                             statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    // Comment
    
    RKResponseDescriptor *commentResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:commentMapping
                                                                                                  method:RKRequestMethodGET
                                                                                             pathPattern:@"/fashionistaPost/:fashionistaPost/comments" //URLs for which the mapping should be used. This is appended to the base URL
                                                                                                 keyPath:nil //Subset of the parsed JSON response data for which the mapping should be used (tells RestKit where to find the objects)
                                                                                             statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    
    RKResponseDescriptor *commentUploadResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:commentMapping
                                                                                                        method:RKRequestMethodPOST
                                                                                                   pathPattern:@"/comment" //URLs for which the mapping should be used. This is appended to the base URL
                                                                                                       keyPath:nil //Subset of the parsed JSON response data for which the mapping should be used (tells RestKit where to find the objects)
                                                                                                   statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    RKResponseDescriptor *commentUpdateResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:commentMapping
                                                                                                         method:RKRequestMethodAny
                                                                                                    pathPattern:@"/comment/:idComment" //URLs for which the mapping should be used. This is appended to the base URL
                                                                                                        keyPath:nil //Subset of the parsed JSON response data for which the mapping should be used (tells RestKit where to find the objects)
                                                                                                    statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    // Notification
    
    RKResponseDescriptor *notificationResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:notificationMapping
                                                                                                   method:RKRequestMethodGET
                                                                                              pathPattern:@"/user/:userId/notifications" //URLs for which the mapping should be used. This is appended to the base URL
                                                                                                  keyPath:nil //Subset of the parsed JSON response data for which the mapping should be used (tells RestKit where to find the objects)
                                                                                              statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    // TagHistory
    
    RKResponseDescriptor *tagHistoryResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:tagHistoryMapping
                                                                                                        method:RKRequestMethodGET
                                                                                                   pathPattern:@"/taghistory" //URLs for which the mapping should be used. This is appended to the base URL
                                                                                                       keyPath:nil //Subset of the parsed JSON response data for which the mapping should be used (tells RestKit where to find the objects)
                                                                                                   statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    // BackgroundAd
    
    RKResponseDescriptor *fullBackgroundAdResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:backgroundAdMapping
                                                                                                        method:RKRequestMethodGET
                                                                                                   pathPattern:@"/getFullScreenBackgroundAdForUser/:idUser" //URLs for which the mapping should be used. This is appended to the base URL
                                                                                                       keyPath:nil //Subset of the parsed JSON response data for which the mapping should be used (tells RestKit where to find the objects)
                                                                                                   statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    
    // BackgroundAd
    
    RKResponseDescriptor *fullBackgroundAdWithoutUserResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:backgroundAdMapping
                                                                                                        method:RKRequestMethodGET
                                                                                                   pathPattern:@"/getFullScreenBackgroundAdForUser/" //URLs for which the mapping should be used. This is appended to the base URL
                                                                                                       keyPath:nil //Subset of the parsed JSON response data for which the mapping should be used (tells RestKit where to find the objects)
                                                                                                   statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    
    // BackgroundAd
    
    RKResponseDescriptor *searchAdaptedBackgroundAdResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:backgroundAdMapping
                                                                                                        method:RKRequestMethodGET
                                                                                                   pathPattern:@"/getSearchAdaptedBackgroundAdForUser/:idUser" //URLs for which the mapping should be used. This is appended to the base URL
                                                                                                       keyPath:nil //Subset of the parsed JSON response data for which the mapping should be used (tells RestKit where to find the objects)
                                                                                                   statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    
    // BackgroundAd
    
    RKResponseDescriptor *searchAdaptedBackgroundAdWithoutUserResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:backgroundAdMapping
                                                                                                                   method:RKRequestMethodGET
                                                                                                              pathPattern:@"/getSearchAdaptedBackgroundAdForUser/" //URLs for which the mapping should be used. This is appended to the base URL
                                                                                                                  keyPath:nil //Subset of the parsed JSON response data for which the mapping should be used (tells RestKit where to find the objects)
                                                                                                              statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    
    // BackgroundAd
    
    RKResponseDescriptor *postAdaptedBackgroundAdResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:backgroundAdMapping
                                                                                                            method:RKRequestMethodGET
                                                                                                       pathPattern:@"/getPostAdaptedBackgroundAdForUser/:idUser" //URLs for which the mapping should be used. This is appended to the base URL
                                                                                                           keyPath:nil //Subset of the parsed JSON response data for which the mapping should be used (tells RestKit where to find the objects)
                                                                                                       statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    
    // BackgroundAd
    
    RKResponseDescriptor *postAdaptedBackgroundAdWithoutUserResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:backgroundAdMapping
                                                                                                                       method:RKRequestMethodGET
                                                                                                                  pathPattern:@"/getPostAdaptedBackgroundAdForUser/" //URLs for which the mapping should be used. This is appended to the base URL
                                                                                                                      keyPath:nil //Subset of the parsed JSON response data for which the mapping should be used (tells RestKit where to find the objects)
                                                                                                                  statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    
    // FashionistaPage
    
    RKResponseDescriptor *fashionistaResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:fashionistaPageMapping
                                                                                                       method:RKRequestMethodAny pathPattern:@"/user/:idUser/fashionistapages"
                                                                                                      keyPath:nil
                                                                                                  statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    // FashionistaPage when getting it as an answer to posting a new one
    
    RKResponseDescriptor *fashionistaPageAfterPostResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:fashionistaPageMapping
                                                                                                             method:RKRequestMethodAny
                                                                                                        pathPattern:@"/fashionistapage" //URLs for which the mapping should be used. This is appended to the base URL
                                                                                                            keyPath:nil //Subset of the parsed JSON response data for which the mapping should be used (tells RestKit where to find the objects)
                                                                                                        statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    // FashionistaPage when getting it as an answer to updating or deleting it
    
    RKResponseDescriptor *fashionistaPageAfterEditingResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:fashionistaPageMapping
                                                                                                               method:RKRequestMethodAny
                                                                                                          pathPattern:@"/fashionistapage/:idFashionistapage" //URLs for which the mapping should be used. This is appended to the base URL
                                                                                                              keyPath:nil //Subset of the parsed JSON response data for which the mapping should be used (tells RestKit where to find the objects)
                                                                                                          statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    // FashionistaPost when getting it as an answer to posting a new one
    
    RKResponseDescriptor *fashionistaPostAfterPostResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:fashionistaPostMappingGet
                                                                                                                    method:RKRequestMethodAny
                                                                                                               pathPattern:@"/fashionistapost" //URLs for which the mapping should be used. This is appended to the base URL
                                                                                                                   keyPath:nil //Subset of the parsed JSON response data for which the mapping should be used (tells RestKit where to find the objects)
                                                                                                               statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    RKResponseDescriptor *fashionistaFullPostResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:fashionistaFullPostMappingGet
                                                                                                                    method:RKRequestMethodAny
                                                                                                               pathPattern:@"/getFullPost/:idFashionistaPost" //URLs for which the mapping should be used. This is appended to the base URL
                                                                                                                   keyPath:nil //Subset of the parsed JSON response data for which the mapping should be used (tells RestKit where to find the objects)
                                                                                                               statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    // FashionistaPost when getting it as an answer to updating or deleting it
    
    RKResponseDescriptor *fashionistaPostAfterEditingResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:fashionistaPostMappingGet
                                                                                                                       method:RKRequestMethodAny
                                                                                                                  pathPattern:@"/fashionistapost/:idFashionistapost" //URLs for which the mapping should be used. This is appended to the base URL
                                                                                                                      keyPath:nil //Subset of the parsed JSON response data for which the mapping should be used (tells RestKit where to find the objects)
                                                                                                                  statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    // FashionistaContent when getting it as an answer to posting a new one
    
    RKResponseDescriptor *fashionistaContentAfterPostResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:fashionistaContentMapping
                                                                                                                    method:RKRequestMethodAny
                                                                                                               pathPattern:@"/fashionistaPostContent" //URLs for which the mapping should be used. This is appended to the base URL
                                                                                                                   keyPath:nil //Subset of the parsed JSON response data for which the mapping should be used (tells RestKit where to find the objects)
                                                                                                               statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    // FashionistaPage when getting it as an answer to updating or deleting it
    
    RKResponseDescriptor *fashionistaContentAfterEditingResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:fashionistaContentMapping
                                                                                                                       method:RKRequestMethodAny
                                                                                                                  pathPattern:@"/fashionistaPostContent/:idFashionistaPostContent" //URLs for which the mapping should be used. This is appended to the base URL
                                                                                                                      keyPath:nil //Subset of the parsed JSON response data for which the mapping should be used (tells RestKit where to find the objects)
                                                                                                                  statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    // FashionistaContent when getting it as an answer to posting a new one
    
    RKResponseDescriptor *fashionistaContentAfterAddingKeywordResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:fashionistaContentMapping
                                                                                                                       method:RKRequestMethodAny
                                                                                                                  pathPattern:@"/fashionistaPostContent/:idFashionistaPostContent/keywords" //URLs for which the mapping should be used. This is appended to the base URL
                                                                                                                      keyPath:nil //Subset of the parsed JSON response data for which the mapping should be used (tells RestKit where to find the objects)
                                                                                                                  statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    RKResponseDescriptor *fashionistaContentKeywordsResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:keywordFashionistaContentMapping
                                                                                                                          method:RKRequestMethodAny
                                                                                                                     pathPattern:@"/fashionistaPostContent/:id/keywords" //URLs for which the mapping should be used. This is appended to the base URL
                                                                                                                         keyPath:nil //Subset of the parsed JSON response data for which the mapping should be used (tells RestKit where to find the objects)
                                                                                                                     statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    RKResponseDescriptor *fashionistaContentKeywordsPopulatedResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:keywordFashionistaContentPopulatedMapping
                                                                                                                       method:RKRequestMethodGET
                                                                                                                  pathPattern:@"/fashionistapostcontent_keywords__keyword_fashionistapostcontents" //URLs for which the mapping should be used. This is appended to the base URL
                                                                                                                      keyPath:nil //Subset of the parsed JSON response data for which the mapping should be used (tells RestKit where to find the objects)
                                                                                                                  statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    RKResponseDescriptor *fashionistaContentKeywords2ResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:keywordFashionistaContentMapping
                                                                                                                      method:RKRequestMethodPOST|RKRequestMethodDELETE
                                                                                                                 pathPattern:@"/fashionistapostcontent_keywords__keyword_fashionistapostcontents" //URLs for which the mapping should be used. This is appended to the base URL
                                                                                                                     keyPath:nil //Subset of the parsed JSON response data for which the mapping should be used (tells RestKit where to find the objects)
                                                                                                                 statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    RKResponseDescriptor *fashionistaContentKeywordsRemoveResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:keywordFashionistaContentMapping
                                                                                                                       method:RKRequestMethodAny
                                                                                                                  pathPattern:@"/fashionistapostcontent_keywords__keyword_fashionistapostcontents/:id" //URLs for which the mapping should be used. This is appended to the base URL
                                                                                                                      keyPath:nil //Subset of the parsed JSON response data for which the mapping should be used (tells RestKit where to find the objects)
                                                                                                                  statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    
    // GSBaseElement when getting it as the result of adding an item to a wardrobe
    
    RKResponseDescriptor *wardrobeAfterAddingAWardrobeToAContentResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:wardrobeMapping
                                                                                                                                   method:RKRequestMethodPOST
                                                                                                                              pathPattern:@"/fashionistaPostContent/:idFashionistaPostContent/setWardrobe/:idWardrobe" //URLs for which the mapping should be used. This is appended to the base URL
                                                                                                                                  keyPath:nil //Subset of the parsed JSON response data for which the mapping should be used (tells RestKit where to find the objects)
                                                                                                                              statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    RKResponseDescriptor *fashionistaPostContentAfterRemovingItemResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:wardrobeMapping
                                                                                                                     method:RKRequestMethodDELETE
                                                                                                                pathPattern:@"/fashionistaPostContent/:idFashionistaPostContent/keywords/:idKeyword" //URLs for which the mapping should be used. This is appended to the base URL
                                                                                                                    keyPath:nil //Subset of the parsed JSON response data for which the mapping should be used (tells RestKit where to find the objects)
                                                                                                                statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    // FashionistaContent when getting it as an answer to posting a new one
    
    RKResponseDescriptor *fashionistaContentWardrobeResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:wardrobeMapping
                                                                                                                      method:RKRequestMethodAny
                                                                                                                 pathPattern:@"/fashionistaPostContent/:idFashionistaPostContent/wardrobe" //URLs for which the mapping should be used. This is appended to the base URL
                                                                                                                     keyPath:nil //Subset of the parsed JSON response data for which the mapping should be used (tells RestKit where to find the objects)
                                                                                                                 statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    
    
    // FashionistaPost for user
    
    RKResponseDescriptor *fashionistaPostUserResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:fashionistaPostMappingGet
                                                                                                                       method:RKRequestMethodAny
                                                                                                                  pathPattern:@"/fashionistapost?user=:idUser" //URLs for which the mapping should be used. This is appended to the base URL
                                                                                                                      keyPath:nil //Subset of the parsed JSON response data for which the mapping should be used (tells RestKit where to find the objects)
                                                                                                                  statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    RKResponseDescriptor *fashionistaPostOwnerResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:fashionistaPostMappingGet
                                                                                                               method:RKRequestMethodAny
                                                                                                          pathPattern:@"/fashionistapost?owner=:idUser" //URLs for which the mapping should be used. This is appended to the base URL
                                                                                                              keyPath:nil //Subset of the parsed JSON response data for which the mapping should be used (tells RestKit where to find the objects)
                                                                                                          statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    // Follow when getting a follower
    
    RKResponseDescriptor *followResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:followMapping
                                                                                                   method:RKRequestMethodAny
                                                                                              pathPattern:@"/follower" //URLs for which the mapping should be used. This is appended to the base URL
                                                                                                  keyPath:nil //Subset of the parsed JSON response data for which the mapping should be used (tells RestKit where to find the objects)
                                                                                              statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    // Follow when setting a follower
    
    RKResponseDescriptor *followViaSettingFollowResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:followMapping
                                                                                                  method:RKRequestMethodAny
                                                                                             pathPattern:@"/user/:idUser/followTo" //URLs for which the mapping should be used. This is appended to the base URL
                                                                                                 keyPath:nil //Subset of the parsed JSON response data for which the mapping should be used (tells RestKit where to find the objects)
                                                                                             statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    // Follow when unsetting a follower
    
    RKResponseDescriptor *followViaUnsettingFollowResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:followMapping
                                                                                                                    method:RKRequestMethodAny
                                                                                                               pathPattern:@"/user/:idUser/unfollowTo" //URLs for which the mapping should be used. This is appended to the base URL
                                                                                                                   keyPath:nil //Subset of the parsed JSON response data for which the mapping should be used (tells RestKit where to find the objects)
                                                                                                               statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    // validating follower
    
    RKResponseDescriptor *followValidateResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:followMapping
                                                                                                                    method:RKRequestMethodAny
                                                                                                               pathPattern:@"/user/:idUser/verifyFollower/:idUserToVerify" //URLs for which the mapping should be used. This is appended to the base URL
                                                                                                                   keyPath:nil //Subset of the parsed JSON response data for which the mapping should be used (tells RestKit where to find the objects)
                                                                                                               statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    
    // PostLike when getting it for a given Post
    
    RKResponseDescriptor *postLikeResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:postLikeMapping
                                                                                                  method:RKRequestMethodAny
                                                                                             pathPattern:@"/fashionistaPost/:fashionistaPostId/likes" //URLs for which the mapping should be used. This is appended to the base URL
                                                                                                 keyPath:nil //Subset of the parsed JSON response data for which the mapping should be used (tells RestKit where to find the objects)
                                                                                             statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    // Postlike when setting a Like
    
    RKResponseDescriptor *postLikeViaSettingLikeResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:postLikeMapping
                                                                                                                  method:RKRequestMethodPOST|RKRequestMethodDELETE
                                                                                                             pathPattern:@"/postlike" //URLs for which the mapping should be used. This is appended to the base URL
                                                                                                                 keyPath:nil //Subset of the parsed JSON response data for which the mapping should be used (tells RestKit where to find the objects)
                                                                                                             statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    RKResponseDescriptor *getLikeViaLikeHistoryResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:baseElementMapping
                                                                                                                  method:RKRequestMethodGET
                                                                                                             pathPattern:@"/user/:idUser/getpostlikes" //URLs for which the mapping should be used. This is appended to the base URL
                                                                                                                 keyPath:nil //Subset of the parsed JSON response data for which the mapping should be used (tells RestKit where to find the objects)
                                                                                                             statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    // Postlike when deleting a Like
//    
//    RKResponseDescriptor *postLikeViaUnsettingLikeResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:postLikeMapping
//                                                                                                                    method:RKRequestMethodAny
//                                                                                                               pathPattern:@"/user/:idUser/unlikepost/:idPost" //URLs for which the mapping should be used. This is appended to the base URL
//                                                                                                                   keyPath:nil //Subset of the parsed JSON response data for which the mapping should be used (tells RestKit where to find the objects)
//                                                                                                               statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    
    // Share
    
    RKResponseDescriptor *shareResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:shareMapping
                                                                                                            method:RKRequestMethodAny
                                                                                                       pathPattern:@"/share/:idShare" //URLs for which the mapping should be used. This is appended to the base URL
                                                                                                           keyPath:nil //Subset of the parsed JSON response data for which the mapping should be used (tells RestKit where to find the objects)
                                                                                                       statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    
    // Share
    
    RKResponseDescriptor *shareViaUploadingShareResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:shareMapping
                                                                                                                  method:RKRequestMethodAny
                                                                                                             pathPattern:@"/share" //URLs for which the mapping should be used. This is appended to the base URL
                                                                                                                 keyPath:nil //Subset of the parsed JSON response data for which the mapping should be used (tells RestKit where to find the objects)
                                                                                                             statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    // Country
    
    RKResponseDescriptor *countryResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:countryMapping
                                                                                                   method:RKRequestMethodAny
                                                                                              pathPattern:@"/country" //URLs for which the mapping should be used. This is appended to the base URL
                                                                                                  keyPath:nil //Subset of the parsed JSON response data for which the mapping should be used (tells RestKit where to find the objects)
                                                                                              statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    // StateRegion
    
    RKResponseDescriptor *stateregionResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:stateregionMapping
                                                                                                   method:RKRequestMethodAny
                                                                                              pathPattern:@"/stateregion" //URLs for which the mapping should be used. This is appended to the base URL
                                                                                                  keyPath:nil //Subset of the parsed JSON response data for which the mapping should be used (tells RestKit where to find the objects)
                                                                                              statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    // City
    
    RKResponseDescriptor *cityResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:cityMapping
                                                                                                   method:RKRequestMethodAny
                                                                                              pathPattern:@"/city" //URLs for which the mapping should be used. This is appended to the base URL
                                                                                                  keyPath:nil //Subset of the parsed JSON response data for which the mapping should be used (tells RestKit where to find the objects)
                                                                                              statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    // PostCategory
    
    RKResponseDescriptor *postCategoryResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:postCategoryMapping
                                                                                                method:RKRequestMethodAny
                                                                                           pathPattern:@"/postCategory" //URLs for which the mapping should be used. This is appended to the base URL
                                                                                               keyPath:nil //Subset of the parsed JSON response data for which the mapping should be used (tells RestKit where to find the objects)
                                                                                           statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    // PostOrdering
    
    RKResponseDescriptor *postOrderingResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:postOrderingMapping
                                                                                                        method:RKRequestMethodAny
                                                                                                   pathPattern:@"/postOrder" //URLs for which the mapping should be used. This is appended to the base URL
                                                                                                       keyPath:nil //Subset of the parsed JSON response data for which the mapping should be used (tells RestKit where to find the objects)
                                                                                                   statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    // POI
    RKResponseDescriptor *poiNearestResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:poiMapping
                                                                                                        method:RKRequestMethodAny
                                                                                                   pathPattern:@"/getNearestPois/:latitue/:longitude" //URLs for which the mapping should be used. This is appended to the base URL
                                                                                                       keyPath:nil //Subset of the parsed JSON response data for which the mapping should be used (tells RestKit where to find the objects)
                                                                                                   statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    // LiveStreaming when creating
    
    RKResponseDescriptor *liveStreamingCreateesponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:liveStreamingMapping
                                                                                                              method:RKRequestMethodAny
                                                                                                         pathPattern:@"/Livestreaming" //URLs for which the mapping should be used. This is appended to the base URL
                                                                                                             keyPath:nil //Subset of the parsed JSON response data for which the mapping should be used (tells RestKit where to find the objects)
                                                                                                         statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    // LiveStreamingEthnicity when creating
    
    RKResponseDescriptor *liveStreamingEthnicityCreateesponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:liveStreamingEthnicityMapping
                                                                                                              method:RKRequestMethodAny
                                                                                                         pathPattern:@"/LivestreamingEthnicity" //URLs for which the mapping should be used. This is appended to the base URL
                                                                                                             keyPath:nil //Subset of the parsed JSON response data for which the mapping should be used (tells RestKit where to find the objects)
                                                                                                         statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    // LiveStreaming when updating
    
    RKResponseDescriptor *liveStreamingUpdateResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:liveStreamingMapping
                                                                                                              method:RKRequestMethodAny
                                                                                                         pathPattern:@"/Livestreaming/:idLiveStreaming" //URLs for which the mapping should be used. This is appended to the base URL
                                                                                                             keyPath:nil //Subset of the parsed JSON response data for which the mapping should be used (tells RestKit where to find the objects)
                                                                                                         statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    // Adding category to LiveStreaming
    
    RKResponseDescriptor *addCategoryLiveStreamingResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:liveStreamingMapping
                                                                                                               method:RKRequestMethodAny
                                                                                                          pathPattern:@"/Livestreaming/:idLiveStreaming/categories/:idLiveStreamingCategory" //URLs for which the mapping should be used. This is appended to the base URL
                                                                                                              keyPath:nil //Subset of the parsed JSON response data for which the mapping should be used (tells RestKit where to find the objects)
                                                                                                          statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    // Adding country to LiveStreaming
    
    RKResponseDescriptor *addCountryLiveStreamingResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:liveStreamingMapping
                                                                                                                    method:RKRequestMethodAny
                                                                                                               pathPattern:@"/Livestreaming/:idLiveStreaming/countries/:idCountry" //URLs for which the mapping should be used. This is appended to the base URL
                                                                                                                   keyPath:nil //Subset of the parsed JSON response data for which the mapping should be used (tells RestKit where to find the objects)
                                                                                                               statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    // Adding state to LiveStreaming
    
    RKResponseDescriptor *addStateLiveStreamingResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:liveStreamingMapping
                                                                                                                   method:RKRequestMethodAny
                                                                                                              pathPattern:@"/Livestreaming/:idLiveStreaming/stateregions/:idStateRegion" //URLs for which the mapping should be used. This is appended to the base URL
                                                                                                                  keyPath:nil //Subset of the parsed JSON response data for which the mapping should be used (tells RestKit where to find the objects)
                                                                                                              statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    // Adding cities to LiveStreaming
    
    RKResponseDescriptor *addCityLiveStreamingResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:liveStreamingMapping
                                                                                                                 method:RKRequestMethodAny
                                                                                                            pathPattern:@"/Livestreaming/:idLiveStreaming/cities/:idCity" //URLs for which the mapping should be used. This is appended to the base URL
                                                                                                                keyPath:nil //Subset of the parsed JSON response data for which the mapping should be used (tells RestKit where to find the objects)
                                                                                                            statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    // Adding typelook to LiveStreaming
    
    RKResponseDescriptor *addTypeLookLiveStreamingResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:liveStreamingMapping
                                                                                                                method:RKRequestMethodAny
                                                                                                           pathPattern:@"/Livestreaming/:idLiveStreaming/typelooks/:idTypeLook" //URLs for which the mapping should be used. This is appended to the base URL
                                                                                                               keyPath:nil //Subset of the parsed JSON response data for which the mapping should be used (tells RestKit where to find the objects)
                                                                                                           statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    // Adding hashtag to LiveStreaming
    
    RKResponseDescriptor *addHashTagLiveStreamingResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:liveStreamingMapping
                                                                                                                    method:RKRequestMethodAny
                                                                                                               pathPattern:@"/Livestreaming/:idLiveStreaming/hashtags/:idHashtag" //URLs for which the mapping should be used. This is appended to the base URL
                                                                                                                   keyPath:nil //Subset of the parsed JSON response data for which the mapping should be used (tells RestKit where to find the objects)
                                                                                                               statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    // Adding Product Category to LiveStreaming
    
    RKResponseDescriptor *addProductCatLiveStreamingResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:liveStreamingMapping
                                                                                                                   method:RKRequestMethodAny
                                                                                                              pathPattern:@"/Livestreaming/:idLiveStreaming/productcategories/:idProductCategory" //URLs for which the mapping should be used. This is appended to the base URL
                                                                                                                  keyPath:nil //Subset of the parsed JSON response data for which the mapping should be used (tells RestKit where to find the objects)
                                                                                                              statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    // Adding Brand to LiveStreaming
    
    RKResponseDescriptor *addBrandLiveStreamingResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:liveStreamingMapping
                                                                                                                      method:RKRequestMethodAny
                                                                                                                 pathPattern:@"/Livestreaming/:idLiveStreaming/brands/:idBrand" //URLs for which the mapping should be used. This is appended to the base URL
                                                                                                                     keyPath:nil //Subset of the parsed JSON response data for which the mapping should be used (tells RestKit where to find the objects)
                                                                                                                 statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    // LiveStreamingPrivacy when creating
    
    RKResponseDescriptor *liveStreamingPrivacyCreateesponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:liveStreamingPrivacyMapping
                                                                                                              method:RKRequestMethodAny
                                                                                                         pathPattern:@"/LivestreamingPrivacy" //URLs for which the mapping should be used. This is appended to the base URL
                                                                                                             keyPath:nil //Subset of the parsed JSON response data for which the mapping should be used (tells RestKit where to find the objects)
                                                                                                         statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    // LiveStreamingCategory when creating
    
    RKResponseDescriptor *liveStreamingCategoryCreateesponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:liveStreamingCategoryMapping
                                                                                                                     method:RKRequestMethodAny
                                                                                                                pathPattern:@"/LivestreamingCategory" //URLs for which the mapping should be used. This is appended to the base URL
                                                                                                                    keyPath:nil //Subset of the parsed JSON response data for which the mapping should be used (tells RestKit where to find the objects)
                                                                                                                statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    // TypeLook getAll
    
    RKResponseDescriptor *liveFilterTypeLookCreateesponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:typeLookPrivacyMapping
                                                                                                                      method:RKRequestMethodAny
                                                                                                                 pathPattern:@"/TypeLook" //URLs for which the mapping should be used. This is appended to the base URL
                                                                                                                     keyPath:nil //Subset of the parsed JSON response data for which the mapping should be used (tells RestKit where to find the objects)
                                                                                                                 statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    // Popular tags
    RKResponseDescriptor *liveFilterTagsCreateesponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:keywordMapping
                                                                                                                   method:RKRequestMethodAny
                                                                                                              pathPattern:@"/getMostPopularHashTags" //URLs for which the mapping should be used. This is appended to the base URL
                                                                                                                  keyPath:nil //Subset of the parsed JSON response data for which the mapping should be used (tells RestKit where to find the objects)
                                                                                                              statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
   
    //// -----------------------------------------------------////
    //// ---------------- REQUEST DESCRIPTORS ----------------////
    //// -----------------------------------------------------////
    
    // Register mappings with the provider using a request descriptor, which describes an object serialization that is applicable to an HTTP request
    
    // CUser
    
    RKObjectMapping* uploadUserRequestMapping = [userMapping inverseMapping];
    
    RKRequestDescriptor *uploadUserRequestDescriptor = [RKRequestDescriptor requestDescriptorWithMapping:uploadUserRequestMapping
                                                                                             objectClass:[User class]
                                                                                             rootKeyPath:nil
                                                                                                  method:RKRequestMethodAny];
    // facebooklogin
    
    RKObjectMapping* facebookLoginRequestMapping = [facebookLoginMapping inverseMapping];
    
    RKRequestDescriptor *facebookLoginUserRequestDescriptor = [RKRequestDescriptor requestDescriptorWithMapping:facebookLoginRequestMapping
                                                                                                    objectClass:[FacebookLogin class]
                                                                                                    rootKeyPath:nil
                                                                                                         method:RKRequestMethodAny];
    
    
    
    // Review
    
    RKObjectMapping* uploadReviewRequestMapping = [reviewMapping inverseMapping];
    
    RKRequestDescriptor *uploadReviewRequestDescriptor = [RKRequestDescriptor requestDescriptorWithMapping:uploadReviewRequestMapping
                                                                                               objectClass:[Review class]
                                                                                               rootKeyPath:nil
                                                                                                    method:RKRequestMethodAny];
    
    
    // Comment
    
    RKObjectMapping* uploadCommentRequestMapping = [commentMapping inverseMapping];
    
    RKRequestDescriptor *uploadCommentRequestDescriptor = [RKRequestDescriptor requestDescriptorWithMapping:uploadCommentRequestMapping
                                                                                               objectClass:[Comment class]
                                                                                               rootKeyPath:nil
                                                                                                    method:RKRequestMethodAny];
    /*    RKObjectMapping* loginRequestMapping = [loginMapping inverseMapping];
     
     RKRequestDescriptor *loginRequestDescriptor = [RKRequestDescriptor requestDescriptorWithMapping:loginRequestMapping
     objectClass:[UserLoginForApiRest class]
     rootKeyPath:nil
     method:RKRequestMethodAny];*/
    
    RKObjectMapping* uploadWardrobeRequestMapping = [wardrobeMapping inverseMapping];
    
    RKRequestDescriptor *uploadWardrobeRequestDescriptor = [RKRequestDescriptor requestDescriptorWithMapping:uploadWardrobeRequestMapping
                                                                                                 objectClass:[Wardrobe class]
                                                                                                 rootKeyPath:nil
                                                                                                      method:RKRequestMethodAny];
    
    RKObjectMapping* uploadGSBaseElementRequestMapping = [baseElementMapping inverseMapping];
    
    RKRequestDescriptor *uploadGSBaseElementRequestDescriptor = [RKRequestDescriptor requestDescriptorWithMapping:uploadGSBaseElementRequestMapping
                                                                                                      objectClass:[GSBaseElement class]
                                                                                                      rootKeyPath:nil
                                                                                                           method:RKRequestMethodAny];
    
    RKObjectMapping* uploadFashionistaPageRequestMapping = [fashionistaPageMapping  inverseMapping];
    
    RKRequestDescriptor *uploadFashionistaPageRequestDescriptor = [RKRequestDescriptor requestDescriptorWithMapping:uploadFashionistaPageRequestMapping
                                                                                                 objectClass:[FashionistaPage class]
                                                                                                 rootKeyPath:nil
                                                                                                      method:RKRequestMethodAny];
    
    RKObjectMapping* uploadFashionistaPostRequestMapping = [fashionistaPostMappingPost  inverseMapping];
    
    RKRequestDescriptor *uploadFashionistaPostRequestDescriptor = [RKRequestDescriptor requestDescriptorWithMapping:uploadFashionistaPostRequestMapping
                                                                                                        objectClass:[FashionistaPost class]
                                                                                                        rootKeyPath:nil
                                                                                                             method:RKRequestMethodAny];
    
    RKObjectMapping* uploadFashionistaContentRequestMapping = [fashionistaContentMapping  inverseMapping];
    
    RKRequestDescriptor *uploadFashionistaContentRequestDescriptor = [RKRequestDescriptor requestDescriptorWithMapping:uploadFashionistaContentRequestMapping
                                                                                                        objectClass:[FashionistaContent class]
                                                                                                        rootKeyPath:nil
                                                                                                             method:RKRequestMethodAny];
    
    RKObjectMapping* uploadKeywordRequestMapping = [keywordMapping  inverseMapping];
    
    RKRequestDescriptor *uploadKeywordRequestDescriptor = [RKRequestDescriptor requestDescriptorWithMapping:uploadKeywordRequestMapping
                                                                                                           objectClass:[Keyword class]
                                                                                                           rootKeyPath:nil
                                                                                                                method:RKRequestMethodAny];

    RKObjectMapping* uploadKeywordFashionistaContentRequestMapping = [keywordFashionistaContentMapping  inverseMapping];
    
    RKRequestDescriptor *uploadKeywordFashionistaContentRequestDescriptor = [RKRequestDescriptor requestDescriptorWithMapping:uploadKeywordFashionistaContentRequestMapping
                                                                                                objectClass:[KeywordFashionistaContent class]
                                                                                                rootKeyPath:nil
                                                                                                     method:RKRequestMethodAny];
    
    // Product View Query
    
    /*    RKObjectMapping *uploadProductViewMapping = [RKObjectMapping mappingForClass:[NSMutableDictionary class]];
     
     [uploadProductViewMapping addAttributeMappingsFromDictionary:@{
     @"productId" : @"product",
     @"userId" : @"user",
     @"statProductQueryId" : @"statProductQuery",
     }];
     
     RKRequestDescriptor *uploadProductViewRequestDescriptor = [RKRequestDescriptor requestDescriptorWithMapping:uploadProductViewMapping
     objectClass:[ProductView class]
     rootKeyPath:nil
     method:RKRequestMethodAny];
     */
    
    RKObjectMapping *uploadUserReportMapping = [userReportMapping inverseMapping];
    
    RKRequestDescriptor *uploadUserReportRequestDescriptor = [RKRequestDescriptor requestDescriptorWithMapping:uploadUserReportMapping
                                                                                                      objectClass:[UserReport class]
                                                                                                      rootKeyPath:nil
                                                                                                           method:RKRequestMethodAny];
    
    RKObjectMapping *uploadPostContentReportMapping = [postContentReportMapping inverseMapping];
    
    RKRequestDescriptor *uploadPostContentReportRequestDescriptor = [RKRequestDescriptor requestDescriptorWithMapping:uploadPostContentReportMapping
                                                                                                      objectClass:[PostContentReport class]
                                                                                                      rootKeyPath:nil
                                                                                                           method:RKRequestMethodAny];
    
    RKObjectMapping *uploadPostCommentReportMapping = [postCommentReportMapping inverseMapping];
    
    RKRequestDescriptor *uploadPostCommentReportRequestDescriptor = [RKRequestDescriptor requestDescriptorWithMapping:uploadPostCommentReportMapping
                                                                                                      objectClass:[PostCommentReport class]
                                                                                                      rootKeyPath:nil
                                                                                                           method:RKRequestMethodAny];
    
    RKObjectMapping *uploadProductReportMapping = [productReportMapping inverseMapping];
    
    RKRequestDescriptor *uploadProductReportRequestDescriptor = [RKRequestDescriptor requestDescriptorWithMapping:uploadProductReportMapping
                                                                                                    objectClass:[ProductReport class]
                                                                                                    rootKeyPath:nil
                                                                                                         method:RKRequestMethodAny];
    RKObjectMapping *uploadProductViewMapping = [productViewMapping inverseMapping];
    
    RKRequestDescriptor *uploadProductViewRequestDescriptor = [RKRequestDescriptor requestDescriptorWithMapping:uploadProductViewMapping
                                                                                                    objectClass:[ProductView class]
                                                                                                    rootKeyPath:nil
                                                                                                         method:RKRequestMethodAny];
    
    RKObjectMapping *uploadProductSharedMapping = [productSharedMapping inverseMapping];
    
    RKRequestDescriptor *uploadProductSharedRequestDescriptor = [RKRequestDescriptor requestDescriptorWithMapping:uploadProductSharedMapping
                                                                                                      objectClass:[ProductShared class]
                                                                                                      rootKeyPath:nil
                                                                                                           method:RKRequestMethodAny];
    
    RKObjectMapping *uploadProductPurchaseMapping = [productPurchaseMapping inverseMapping];
    
    RKRequestDescriptor *uploadProductPurchaseRequestDescriptor = [RKRequestDescriptor requestDescriptorWithMapping:uploadProductPurchaseMapping
                                                                                                        objectClass:[ProductPurchase class]
                                                                                                        rootKeyPath:nil
                                                                                                             method:RKRequestMethodAny];
    
    RKObjectMapping *uploadPostViewMapping = [postViewMapping inverseMapping];
    
    RKRequestDescriptor *uploadPostViewRequestDescriptor = [RKRequestDescriptor requestDescriptorWithMapping:uploadPostViewMapping
                                                                                                    objectClass:[FashionistaPostView class]
                                                                                                    rootKeyPath:nil
                                                                                                         method:RKRequestMethodAny];
    RKObjectMapping *uploadPostViewTimeMapping = [postViewTimeMapping inverseMapping];
    
    RKRequestDescriptor *uploadPostViewTimeRequestDescriptor = [RKRequestDescriptor requestDescriptorWithMapping:uploadPostViewTimeMapping
                                                                                                     objectClass:[FashionistaPostViewTime class]
                                                                                                     rootKeyPath:nil
                                                                                                          method:RKRequestMethodAny];
    
    RKObjectMapping *uploadPostSharedMapping = [postSharedMapping inverseMapping];
    
    RKRequestDescriptor *uploadPostSharedRequestDescriptor = [RKRequestDescriptor requestDescriptorWithMapping:uploadPostSharedMapping
                                                                                                   objectClass:[FashionistaPostShared class]
                                                                                                   rootKeyPath:nil
                                                                                                        method:RKRequestMethodAny];

    
    RKObjectMapping *uploadPostUserMapping = [postUserMapping inverseMapping];
    
    RKRequestDescriptor *uploadPostUserRequestDescriptor = [RKRequestDescriptor requestDescriptorWithMapping:uploadPostUserMapping
                                                                                                 objectClass:[PostUserUnfollow class]
                                                                                                 rootKeyPath:nil
                                                                                                      method:RKRequestMethodAny];
    
    RKObjectMapping *uploadUserUserMapping = [userUserMapping inverseMapping];
    
    RKRequestDescriptor *uploadUserUserRequestDescriptor = [RKRequestDescriptor requestDescriptorWithMapping:uploadUserUserMapping
                                                                                                 objectClass:[UserUserUnfollow class]
                                                                                                 rootKeyPath:nil
                                                                                                      method:RKRequestMethodAny];
    
    
    
    RKObjectMapping *uploadFashionistaViewMapping = [fashionistaViewMapping inverseMapping];
    
    RKRequestDescriptor *uploadFashionistaViewRequestDescriptor = [RKRequestDescriptor requestDescriptorWithMapping:uploadFashionistaViewMapping
                                                                                                    objectClass:[FashionistaView class]
                                                                                                    rootKeyPath:nil
                                                                                                         method:RKRequestMethodAny];
    
    RKObjectMapping *uploadFashionistaViewTimeMapping = [fashionistaViewTimeMapping inverseMapping];
    
    RKRequestDescriptor *uploadFashionistaViewTimeRequestDescriptor = [RKRequestDescriptor requestDescriptorWithMapping:uploadFashionistaViewTimeMapping
                                                                                                            objectClass:[FashionistaViewTime class]
                                                                                                            rootKeyPath:nil
                                                                                                                 method:RKRequestMethodAny];
    
    RKObjectMapping *uploadWardrobeViewMapping = [wardrobeViewMapping inverseMapping];
    
    RKRequestDescriptor *uploadWardrobeViewRequestDescriptor = [RKRequestDescriptor requestDescriptorWithMapping:uploadWardrobeViewMapping
                                                                                                    objectClass:[WardrobeView class]
                                                                                                    rootKeyPath:nil
                                                                                                         method:RKRequestMethodAny];
    
    RKObjectMapping *uploadCommentViewMapping = [commentViewMapping inverseMapping];
    
    RKRequestDescriptor *uploadCommentViewRequestDescriptor = [RKRequestDescriptor requestDescriptorWithMapping:uploadCommentViewMapping
                                                                                                    objectClass:[CommentView class]
                                                                                                    rootKeyPath:nil
                                                                                                         method:RKRequestMethodAny];

    RKObjectMapping *uploadReviewProductViewMapping = [reviewProductViewMapping inverseMapping];
    
    RKRequestDescriptor *uploadReviewProductViewRequestDescriptor = [RKRequestDescriptor requestDescriptorWithMapping:uploadReviewProductViewMapping
                                                                                                    objectClass:[ReviewProductView class]
                                                                                                    rootKeyPath:nil
                                                                                                         method:RKRequestMethodAny];
    
    RKObjectMapping *uploadFollowMapping = [followMapping inverseMapping];
    
    RKRequestDescriptor *uploadFollowRequestDescriptor = [RKRequestDescriptor requestDescriptorWithMapping:uploadFollowMapping
                                                                                                     objectClass:[Follow class]
                                                                                                     rootKeyPath:nil
                                                                                                          method:RKRequestMethodAny];
    
    RKObjectMapping *uploadSetFollowMapping = [setFollowMapping inverseMapping];
    
    RKRequestDescriptor *uploadSetFollowRequestDescriptor = [RKRequestDescriptor requestDescriptorWithMapping:uploadSetFollowMapping
                                                                                               objectClass:[setFollow class]
                                                                                               rootKeyPath:nil
                                                                                                    method:RKRequestMethodAny];
    
    RKObjectMapping *uploadUnsetFollowMapping = [unsetFollowMapping inverseMapping];
    
    RKRequestDescriptor *uploadUnsetFollowRequestDescriptor = [RKRequestDescriptor requestDescriptorWithMapping:uploadUnsetFollowMapping
                                                                                               objectClass:[unsetFollow class]
                                                                                               rootKeyPath:nil
                                                                                                    method:RKRequestMethodAny];
    
    RKObjectMapping *uploadPostLikeMapping = [postLikeMapping inverseMapping];
    
    RKRequestDescriptor *uploadPostLikeRequestDescriptor = [RKRequestDescriptor requestDescriptorWithMapping:uploadPostLikeMapping
                                                                                               objectClass:[PostLike class]
                                                                                               rootKeyPath:nil
                                                                                                    method:RKRequestMethodAny];
    
    
    // Comment
    
    RKObjectMapping* uploadShareRequestMapping = [shareMapping inverseMapping];
    
    RKRequestDescriptor *uploadShareRequestDescriptor = [RKRequestDescriptor requestDescriptorWithMapping:uploadShareRequestMapping
                                                                                                objectClass:[Share class]
                                                                                                rootKeyPath:nil
                                                                                                     method:RKRequestMethodAny];

    // LiveStreaming
    
    RKObjectMapping* uploadLiveStreamingRequestMapping = [liveStreamingMapping  inverseMapping];
    
    RKRequestDescriptor *uploadLiveStreamingRequestDescriptor = [RKRequestDescriptor requestDescriptorWithMapping:uploadLiveStreamingRequestMapping
                                                                                                      objectClass:[LiveStreaming class]
                                                                                                      rootKeyPath:nil
                                                                                                           method:RKRequestMethodAny];

    
    // LiveStreamingEthnicity
    
    RKObjectMapping* uploadLiveStreamingEthnicityRequestMapping = [liveStreamingEthnicityMapping  inverseMapping];
    
    RKRequestDescriptor *uploadLiveStreamingEthnicityRequestDescriptor = [RKRequestDescriptor requestDescriptorWithMapping:uploadLiveStreamingEthnicityRequestMapping
                                                                                                      objectClass:[LiveStreamingEthnicity class]
                                                                                                      rootKeyPath:nil
                                                                                                           method:RKRequestMethodAny];
    
    //// ----------------------------------------------------------////
    //// ---------------- REQUEST RESPONSE MAPPING ----------------////
    //// ----------------------------------------------------------////

    
    // PostLikes
    
    RKObjectMapping *postLikesNumberResponseMapping = [RKObjectMapping mappingForClass:[NSMutableDictionary class]];
    
    [postLikesNumberResponseMapping addAttributeMappingsFromDictionary:@{
                                                                @"likes" : @"likes",
                                                                }];
    
    RKResponseDescriptor *postLikesNumberRequestResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:postLikesNumberResponseMapping
                                                                                                                  method:RKRequestMethodAny
                                                                                                             pathPattern:@"/fashionistaPost/:idFashionistaPost/likescount"
                                                                                                                 keyPath:nil
                                                                                                             statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    RKObjectMapping *userLikesPostResponseMapping = [RKObjectMapping mappingForClass:[NSMutableDictionary class]];
    
    [userLikesPostResponseMapping addAttributeMappingsFromDictionary:@{
                                                                       @"like" : @"like",
                                                                       @"post" : @"post",
                                                                         }];
    
    RKResponseDescriptor *userLikesPostRequestResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:userLikesPostResponseMapping
                                                                                                                  method:RKRequestMethodAny
                                                                                                             pathPattern:@"/user/:idUser/likepost/:idFashionistaPost"
                                                                                                                 keyPath:nil
                                                                                                             statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    RKResponseDescriptor *postLikeViaUnsettingLikeResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:userLikesPostResponseMapping
                                                                                                                method:RKRequestMethodAny
                                                                                                           pathPattern:@"/user/:idUser/unlikepost/:idFashionistaPost"
                                                                                                               keyPath:nil
                                                                                                           statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];

    // following/followers
    RKObjectMapping *followingFollowersNumberResponseMapping = [RKObjectMapping mappingForClass:[NSMutableDictionary class]];
    
    [followingFollowersNumberResponseMapping addAttributeMappingsFromDictionary:@{
                                                                         @"followers" : @"followers",
                                                                         @"followings" : @"followings"
                                                                         }];
    
    RKResponseDescriptor *followingFollowersNumberRequestResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:followingFollowersNumberResponseMapping
                                                                                                                  method:RKRequestMethodAny
                                                                                                             pathPattern:@"/user/:id/followersfollowingcount"
                                                                                                                 keyPath:nil
                                                                                                             statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];

    
    // config
    
    RKObjectMapping *configResponseMapping = [RKObjectMapping mappingForClass:[NSMutableDictionary class]];
    
    [configResponseMapping addAttributeMappingsFromDictionary:@{
                                                                @"visual_search" : @"visual_search",
                                                                @"tag_post_auto_swap" : @"tag_post_auto_swap",
                                                                }];
    
    RKResponseDescriptor *configRequestResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:configResponseMapping
                                                                                                              method:RKRequestMethodAny
                                                                                                         pathPattern:@"/config"
                                                                                                             keyPath:nil
                                                                                                         statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];

    // Check Search
    
    RKObjectMapping *checkSearchResponseMapping = [RKObjectMapping mappingForClass:[CheckSearch class]];
    
    [checkSearchResponseMapping addAttributeMappingsFromDictionary:@{
                                                                @"keyword" : @"keyword",
                                                                @"results" : @"results",
                                                                
                                                                }];
    
    RKResponseDescriptor *checkSearchRequestResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:checkSearchResponseMapping
                                                                                                         method:RKRequestMethodAny
                                                                                                    pathPattern:@"/checksearch/:id"
                                                                                                        keyPath:nil
                                                                                                    statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    RKResponseDescriptor *checkSearchSuggestedRequestResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:checkSearchResponseMapping
                                                                                                              method:RKRequestMethodAny
                                                                                                         pathPattern:@"/checksuggestionsextended/:id"
                                                                                                             keyPath:nil
                                                                                                         statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    RKResponseDescriptor *checkSearchCppRequestResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:checkSearchResponseMapping
                                                                                                                 method:RKRequestMethodAny
                                                                                                            pathPattern:@"/checksearchcpp/:id"
                                                                                                                keyPath:nil
                                                                                                            statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    RKResponseDescriptor *checkSearchSuggestedCppRequestResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:checkSearchResponseMapping
                                                                                                                          method:RKRequestMethodAny
                                                                                                                     pathPattern:@"/checksuggestionsextendedcpp/:id"
                                                                                                                         keyPath:nil
                                                                                                                     statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    // Identification image upload
    
    RKObjectMapping *uploadImageResponseMapping = [RKObjectMapping mappingForClass:[NSMutableDictionary class]];
    
    [uploadImageResponseMapping addAttributeMappingsFromDictionary:@{
                                                                     @"code" : @"code",
                                                                     @"image": @"image",
                                                                     @"message": @"message",
                                                                     @"path": @"path",
                                                                     @"cat_name": @"cat_name",
                                                                     @"ext_name": @"ext_name",
                                                                     @"state": @"state",
                                                                     @"id": @"id",
                                                                     @"result": @"result",
                                                                     @"header_type": @"header_type",
                                                                     @"full_picture" : @"full_picture",
                                                                     }];
    
    
    RKResponseDescriptor *uploadImageRequestResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:uploadImageResponseMapping
                                                                                                              method:RKRequestMethodAny
                                                                                                         pathPattern:@"/user/:idUser/upload-picture"
                                                                                                             keyPath:nil
                                                                                                         statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    RKResponseDescriptor *uploadHeaderRequestResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:uploadImageResponseMapping
                                                                                                              method:RKRequestMethodAny
                                                                                                         pathPattern:@"/user/:idUser/upload-header"
                                                                                                             keyPath:nil
                                                                                                         statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    RKResponseDescriptor *retrievePasswordRequestResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:uploadImageResponseMapping
                                                                                                                   method:RKRequestMethodAny
                                                                                                              pathPattern:@"/forgot_password"
                                                                                                                  keyPath:nil
                                                                                                              statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];

    RKResponseDescriptor *retrievePasswordGetCodeRequestResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:uploadImageResponseMapping
                                                                                                                   method:RKRequestMethodAny
                                                                                                              pathPattern:@"/forgot_password_get_code"
                                                                                                                  keyPath:nil
                                                                                                              statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];

    RKResponseDescriptor *retrievePasswordWithCodeRequestResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:uploadImageResponseMapping
                                                                                                                           method:RKRequestMethodAny
                                                                                                                      pathPattern:@"/forgot_password_with_code"
                                                                                                                          keyPath:nil
                                                                                                                      statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    RKResponseDescriptor *retrieveCodeEmailVerificationRequestResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:uploadImageResponseMapping
                                                                                                                           method:RKRequestMethodAny
                                                                                                                      pathPattern:@"/resend_code_email_validation"
                                                                                                                          keyPath:nil
                                                                                                                      statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    
    // Detection when coming from visual search
    
    RKResponseDescriptor *visualSearchRequestResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:uploadImageResponseMapping
                                                                                                               method:RKRequestMethodAny
                                                                                                          pathPattern:@"/detect"
                                                                                                              keyPath:nil
                                                                                                          statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    
    
    // Detection when coming from retry detection
    
    RKResponseDescriptor *detectionRequestResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:uploadImageResponseMapping
                                                                                                            method:RKRequestMethodAny
                                                                                                       pathPattern:@"/detection/:idDetection"
                                                                                                           keyPath:nil
                                                                                                       statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    // Fashionista Page when coming from upload header image
    
    RKResponseDescriptor *uploadFashionistaPageHeaderImageRequestResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:uploadImageResponseMapping
                                                                                                              method:RKRequestMethodAny
                                                                                                         pathPattern:@"/fashionistapage/:idFashionistaPage/upload-coverimage"
                                                                                                             keyPath:nil
                                                                                                         statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    // Fashionista Page when coming from upload header image
    
    RKResponseDescriptor *uploadFashionistaPostPreviewImageRequestResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:uploadImageResponseMapping
                                                                                                                                   method:RKRequestMethodAny
                                                                                                                              pathPattern:@"/fashionistapost/:idFashionistaPost/upload-coverimage"
                                                                                                                                  keyPath:nil
                                                                                                                              statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    // Fashionista Content when coming from upload content image
    
    RKResponseDescriptor *uploadFashionistaContentImageRequestResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:uploadImageResponseMapping
                                                                                                                                   method:RKRequestMethodAny
                                                                                                                              pathPattern:@"/fashionistaPostContent/:idFashionistaContent/upload-image"
                                                                                                                                  keyPath:nil
                                                                                                                              statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    // Fashionista Content when coming from upload content image
    
    RKResponseDescriptor *uploadFashionistaContentVideoRequestResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:uploadImageResponseMapping
                                                                                                                                method:RKRequestMethodAny
                                                                                                                           pathPattern:@"/fashionistaPostContent/:idFashionistaContent/upload-video"
                                                                                                                               keyPath:nil
                                                                                                                           statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    
    // Review video upload
    
    RKResponseDescriptor *uploadReviewVideoRequestResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:uploadImageResponseMapping
                                                                                                                                method:RKRequestMethodAny
                                                                                                                           pathPattern:@"/review/:idReview/upload-video"
                                                                                                                               keyPath:nil
                                                                                                                           statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    
    // Comment video upload
    
    RKResponseDescriptor *uploadCommentVideoRequestResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:uploadImageResponseMapping
                                                                                                                    method:RKRequestMethodAny
                                                                                                               pathPattern:@"/comment/:idComment/upload-video"
                                                                                                                   keyPath:nil
                                                                                                               statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    //// --------------------------------------------------////
    //// ---------------- ERROR MANAGEMENT ----------------////
    //// --------------------------------------------------////
    
    RKObjectMapping *errorMapping = [RKObjectMapping mappingForClass:[RKErrorMessage class]];
    
    [errorMapping addPropertyMapping: [RKAttributeMapping attributeMappingFromKeyPath:nil toKeyPath:@"errorMessage"]];
    
    RKResponseDescriptor *errorResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:errorMapping
                                                                                                 method:RKRequestMethodAny
                                                                                            pathPattern:nil
                                                                                                keyPath:@"error"
                                                                                            statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassClientError)];
    
    
    
    //// -------------------------------------------------------------------////
    //// ---------------- ADD DESCRIPTORS TO OBJECT MANAGER ----------------////
    //// -------------------------------------------------------------------////
    
    // Add response descriptors
    
    [self addResponseDescriptorsFromArray:@[userResponseDescriptor,
                                            liveStreamingCreateesponseDescriptor,
                                            liveStreamingUpdateResponseDescriptor,
                                            liveStreamingEthnicityCreateesponseDescriptor,
                                            addCategoryLiveStreamingResponseDescriptor,
                                            addCountryLiveStreamingResponseDescriptor,
                                            addStateLiveStreamingResponseDescriptor,
                                            addCityLiveStreamingResponseDescriptor,
                                            addTypeLookLiveStreamingResponseDescriptor,
                                            
                                            addHashTagLiveStreamingResponseDescriptor,
                                            addProductCatLiveStreamingResponseDescriptor,
                                            addBrandLiveStreamingResponseDescriptor,
                                            liveStreamingPrivacyCreateesponseDescriptor,
                                           liveStreamingCategoryCreateesponseDescriptor,
                                            liveFilterTypeLookCreateesponseDescriptor,
                                            liveFilterTagsCreateesponseDescriptor,
                                            searchQueryResponseDescriptor,
                                            searchQueryCppResponseDescriptor,
                                            searchQueryViaSimilarSearchResponseDescriptor,
                                            searchQueryCppViaSimilarSearchResponseDescriptor,
                                            searchQueryViaTrendingResponseDescriptor,
                                            searchQueryViaTrendingWithoutSearchStringResponseDescriptor,
                                            searchQueryViaNewsfeedWithoutSearchStringResponseDescriptor,
                                            searchQueryViaDiscoverResponseDescriptor,
                                            searchQueryViaFashionistaPostsResponseDescriptor,
                                            searchQueryViaFashionistasLikePostResponseDescriptor,
                                            searchQueryViaFashionistasLikePost2ResponseDescriptor,
                                            searchQueryViaFashionistasResponseDescriptor,
                                            searchQueryCppViaFashionistasResponseDescriptor,
                                            searchQueryViaSocialNetworkResponseDescriptor,
                                            searchQueryViaFashionistasWithoutSearchStringResponseDescriptor,
                                            searchQueryCppViaFashionistasWithoutSearchStringResponseDescriptor,
                                            searchQueryViaHistoryResponseDescriptor,
                                            searchQueryViaHistoryWithoutSearchStringResponseDescriptor,
                                            searchQueryViaFashionistaPostResponseDescriptor,
                                            searchQueryCppViaFashionistaPostResponseDescriptor,
                                            searchQueryViaFashionistaPostWithoutSearchStringResponseDescriptor,
                                            searchQueryCppViaFashionistaPostWithoutSearchStringResponseDescriptor,
                                            searchQueryViaBrandResponseDescriptor,
                                            searchQueryViaBrandWithoutSearchStringResponseDescriptor,
                                            searchQueryViaBrandOnlyInitialResponseDescriptor,
                                            searchQueryViaBrandInitialAndRegexResponseDescriptor,
                                            searchQueryViaGetTheLookResponseDescriptor,
                                            searchQueryCppViaGetTheLookResponseDescriptor,
                                            searchQueryViaGetTheLookWithSearchResponseDescriptor,
                                            searchQueryCppViaGetTheLookWithSearchResponseDescriptor,
                                            searchQueryViaGetUserLikesWithSearchResponseDescriptor,
                                            baseElementAfterAddingAnItemToAWardrobeResponseDescriptor,
                                            baseElementAfterAddingAPostToAWardrobeResponseDescriptor,
                                            baseElementUpdatingResponseDescriptor,
                                            visualSearchRequestResponseDescriptor,
                                            detectionRequestResponseDescriptor,
                                            searchQueryViaDetectionResponseDescriptor,
                                            resultsGroupResponseDescriptor,
                                            resultsQueryResponseDescriptor,
                                            userReportResponseDescriptor,
                                            postContentReportResponseDescriptor,
                                            postCommentReportResponseDescriptor,
                                            productReportResponseDescriptor,
                                            productViewResponseDescriptor,
                                            productSharedResponseDescriptor,
                                            productPurchaseResponseDescriptor,
                                            productAvailabilityResponseDescriptor,
                                            postViewResponseDescriptor,
                                            postViewTimeResponseDescriptor,
                                            postSharedResponseDescriptor,
                                            postUserUnfollowResponseDescriptor,
                                            postUserUnfollowDeleteResponseDescriptor,
                                            postUserIgnoreResponseDescriptor,
                                            postUserIgnoreDeleteResponseDescriptor,
                                            userUserIgnoreResponseDescriptor,
                                            fashionistaViewResponseDescriptor,
                                            fashionistaViewTimeResponseDescriptor,
                                            followFriendsFromSNResponseDescriptor,
                                            wardrobeViewResponseDescriptor,
                                            commentViewResponseDescriptor,
                                            reviewProductViewResponseDescriptor,
                                            brandResponseDescriptor,
                                            brandViaProductResponseDescriptor,
                                            brandPriorityResponseDescriptor,
                                            brandViaAllThemResponseDescriptor,
                                            baseElementResponseDescriptor,
                                            baseElementAfterGettingWardrobeContentResponseDescriptor,
                                            baseElementAfterGettingPopulatedWardrobeContentResponseDescriptor,
                                            productGroupResponseDescriptor,
                                            productGroupParentResponseDescriptor,
                                            productResponseDescriptor,
                                            productAfterGettingPopulatedStatProductViewResponseDescriptor,
                                            fashionistaPageResponseDescriptor,
                                            fashionistaPostResponseDescriptor,
                                            adResponseDescriptor,
                                            fashionistaPostViaFashionistaPageResponseDescriptor,
                                            subproductGroupResponseDescriptor,
                                            priceResponseDescriptor,
                                            keywordResponseDescriptor,
                                            keywordAfterGettingPopulatedResultGroupResponseDescriptor,
                                            featureFromProductResponseDescriptor,
                                            featureViaFeatureGroupResponseDescriptor,
                                            featureResponseDescriptor,
                                            featureGroupFromProductCategoryResponseDescriptor,
                                            featureGroupResponseDescriptor,
                                            contentResponseDescriptor,
                                            fashionistaContentResponseDescriptor,
                                            availabilityResponseDescriptor,
                                            shopResponseDescriptor,
                                            wardrobeResponseDescriptor,
                                            reviewResponseDescriptor,
                                            errorResponseDescriptor,
                                            loginResponseDescriptor,
                                            loginFacebookResponseDescriptor,
                                            fingerprintResponseDescriptor,
                                            wardrobeAfterPostResponseDescriptor,
                                            updateUserResponseDescriptor,
                                            getUserByNameResponseDescriptor,
                                            getUsersForAutofillResponseDescriptor,
                                            uploadImageRequestResponseDescriptor,
                                            uploadHeaderRequestResponseDescriptor,
                                            wardrobeAfterRenameResponseDescriptor,
                                            //                                            wardrobeAfterAddingItemResponseDescriptor,
                                            wardrobeAfterRemovingItemResponseDescriptor,
                                            wardrobeAfterGettingWardrobeContentResponseDescriptor,
                                            retrievePasswordRequestResponseDescriptor,
                                            retrievePasswordGetCodeRequestResponseDescriptor,
                                            retrievePasswordWithCodeRequestResponseDescriptor,
                                            retrieveCodeEmailVerificationRequestResponseDescriptor,
                                            suggestedKeywordResponseDescriptor,
                                            keywordViaGetAllThemResponseDescriptor,
                                            keywordGetFromStringResponseDescriptor,
                                            fashionistaResponseDescriptor,
                                            fashionistaPageAuthorResponseDescriptor,
                                            fashionistaPageAfterPostResponseDescriptor,
                                            fashionistaPageAfterEditingResponseDescriptor,
                                            uploadFashionistaPageHeaderImageRequestResponseDescriptor,
                                            fashionistaContentViaPostResponseDescriptor,
                                            uploadFashionistaPostPreviewImageRequestResponseDescriptor,
                                            uploadFashionistaContentImageRequestResponseDescriptor,
                                            uploadFashionistaContentVideoRequestResponseDescriptor,
                                            uploadReviewVideoRequestResponseDescriptor,
                                            commentResponseDescriptor,
                                            commentUploadResponseDescriptor,
                                            commentUpdateResponseDescriptor,
                                            uploadCommentVideoRequestResponseDescriptor,
                                            notificationResponseDescriptor,
                                            tagHistoryResponseDescriptor,
                                            fullBackgroundAdResponseDescriptor,
                                            fullBackgroundAdWithoutUserResponseDescriptor,
                                            searchAdaptedBackgroundAdResponseDescriptor,
                                            searchAdaptedBackgroundAdWithoutUserResponseDescriptor,
                                            postAdaptedBackgroundAdResponseDescriptor,
                                            postAdaptedBackgroundAdWithoutUserResponseDescriptor,
                                            fashionistaPostAfterPostResponseDescriptor,
                                            fashionistaFullPostResponseDescriptor,
                                            fashionistaPostAfterEditingResponseDescriptor,
                                            fashionistaContentAfterEditingResponseDescriptor,
                                            fashionistaContentAfterPostResponseDescriptor,
                                            fashionistaContentAfterAddingKeywordResponseDescriptor,
                                            fashionistaContentKeywordsResponseDescriptor,
                                            fashionistaContentKeywords2ResponseDescriptor,
                                            fashionistaContentKeywordsPopulatedResponseDescriptor,
                                            fashionistaContentKeywordsRemoveResponseDescriptor,
                                            wardrobeAfterAddingAWardrobeToAContentResponseDescriptor,
                                            fashionistaPostContentAfterRemovingItemResponseDescriptor,
                                            fashionistaContentWardrobeResponseDescriptor,
                                            searchQueryViaFashionistaPostWithoutPostTypeResponseDescriptor,
                                            searchQueryCppViaFashionistaPostWithoutPostTypeResponseDescriptor,
                                            searchQueryViaFashionistaPostWithoutSearchStringNorPostTypeResponseDescriptor,
                                            searchQueryCppViaFashionistaPostWithoutSearchStringNorPostTypeResponseDescriptor,
                                            fashionistaPostUserResponseDescriptor,
                                            fashionistaPostOwnerResponseDescriptor,
                                            configRequestResponseDescriptor,
                                            reviewUploadResponseDescriptor,
                                            followResponseDescriptor,
                                            followViaSettingFollowResponseDescriptor,
                                            followViaUnsettingFollowResponseDescriptor,
                                            followValidateResponseDescriptor,
                                            postLikeResponseDescriptor,
                                            postLikeViaSettingLikeResponseDescriptor,
                                            getLikeViaLikeHistoryResponseDescriptor,
                                            postLikeViaUnsettingLikeResponseDescriptor,
                                            postLikesNumberRequestResponseDescriptor,
                                            userLikesPostRequestResponseDescriptor,
                                            followingFollowersNumberRequestResponseDescriptor,
                                            checkSearchRequestResponseDescriptor,
                                            checkSearchCppRequestResponseDescriptor,
                                            checkSearchSuggestedRequestResponseDescriptor,
                                            checkSearchSuggestedCppRequestResponseDescriptor,
                                            shareResponseDescriptor,
                                            shareViaUploadingShareResponseDescriptor,
                                            countryResponseDescriptor,
                                            stateregionResponseDescriptor,
                                            cityResponseDescriptor,
                                            postCategoryResponseDescriptor,
                                            postOrderingResponseDescriptor,
                                            poiNearestResponseDescriptor
                                            ]];
    
    // Add request descriptors
    
    [self addRequestDescriptorsFromArray:@[uploadUserRequestDescriptor,
                                           uploadLiveStreamingRequestDescriptor,
                                           uploadLiveStreamingEthnicityRequestDescriptor,
                                           facebookLoginUserRequestDescriptor,
                                           uploadWardrobeRequestDescriptor,
                                           uploadReviewRequestDescriptor,
                                           uploadGSBaseElementRequestDescriptor,
                                           uploadUserReportRequestDescriptor,
                                           uploadPostContentReportRequestDescriptor,
                                           uploadPostCommentReportRequestDescriptor,
                                           uploadProductReportRequestDescriptor,
                                           uploadProductViewRequestDescriptor,
                                           uploadProductSharedRequestDescriptor,
                                           uploadProductPurchaseRequestDescriptor,
                                           uploadPostViewRequestDescriptor,
                                           uploadPostViewTimeRequestDescriptor,
                                           uploadPostSharedRequestDescriptor,
                                           uploadPostUserRequestDescriptor,
                                           uploadUserUserRequestDescriptor,
                                           uploadFashionistaViewRequestDescriptor,
                                           uploadFashionistaViewTimeRequestDescriptor,
                                           uploadWardrobeViewRequestDescriptor,
                                           uploadCommentViewRequestDescriptor,
                                           uploadReviewProductViewRequestDescriptor,
                                           uploadFashionistaPageRequestDescriptor,
                                           uploadFashionistaPostRequestDescriptor,
                                           uploadFashionistaContentRequestDescriptor,
                                           uploadKeywordRequestDescriptor,
                                           uploadKeywordFashionistaContentRequestDescriptor,
                                           uploadFollowRequestDescriptor,
                                           uploadSetFollowRequestDescriptor,
                                           uploadUnsetFollowRequestDescriptor,
                                           uploadCommentRequestDescriptor,
                                           uploadPostLikeRequestDescriptor,
                                           uploadShareRequestDescriptor
                                           /*loginRequestDescriptor*/]];
    
}

@end
