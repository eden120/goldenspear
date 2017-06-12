//
//  ShareViewController.m
//  GoldenSpear
//
//  Created by JCB on 9/4/16.
//  Copyright © 2016 GoldenSpear. All rights reserved.
//

#import "ShareViewController.h"
#import "AppDelegate.h"
#import <Social/Social.h>
#import "BaseViewController+BottomControlsManagement.h"
#import "BaseViewController+StoryboardManagement.h"

@interface ShareViewController()

@end

@implementation ShareViewController

-(void)viewDidLoad {
    [super viewDidLoad];
    
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

-(void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(BOOL)shouldCreateMenuButton {
    return NO;
}

-(BOOL)shouldCreateTopBar {
    return NO;
}

- (IBAction)onTapMESSAGE:(id)sender {
    [self onTapShare:MESSAGE];
}
- (IBAction)onTapMMS:(id)sender {
    [self onTapShare:MMS];
}
- (IBAction)onTapEmail:(id)sender {
    [self onTapShare:EMAIL];
}
- (IBAction)onTapPINTEREST:(id)sender {
    [self onTapShare:PINTEREST];
}
- (IBAction)onTapLINKEDIN:(id)sender {
    [self onTapShare:LINKEDIN];
}
- (IBAction)onTapINSTAGRAM:(id)sender {
    [self onTapShare:INSTAGRAM];
}
- (IBAction)onTapSNAPCHAT:(id)sender {
    [self onTapShare:SNAPCHAT];
}
- (IBAction)onTapFACEBOOK:(id)sender {
    [self onTapShare:FACEBOOK];
}
- (IBAction)onTapTUMBLR:(id)sender {
    [self onTapShare:TUMBLR];
}
- (IBAction)onTapFLICKER:(id)sender {
    [self onTapShare:FLIKER];
}
- (IBAction)onTapTWITTER:(id)sender {
    [self onTapShare:TWITTER];
}

-(void)onTapShare:(NSInteger)index {
    UIImage *imageToShare = [UIImage imageNamed:@"Logo.png"];
    
    NSString *messageToShare = NSLocalizedString(@"_SHARE_GENERIC_MSG_", nil);
    
    NSURL * urlToShare = [NSURL URLWithString:NSLocalizedString(@"_SHARE_GENERIC_URL_", nil)];
    
    switch (index) {
        case FACEBOOK:
            if([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook])
            {
                SLComposeViewController *facebookController=[SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
                
                SLComposeViewControllerCompletionHandler __block completionHandler=^(SLComposeViewControllerResult result){
                    
                    [facebookController dismissViewControllerAnimated:YES completion:nil];
                    
                    switch(result)
                    {
                        case SLComposeViewControllerResultDone:
                        {
                            NSLog(@"Shared...");
                            [self afterSharedIn:@"facebook"];
                            break;
                        }
                        case SLComposeViewControllerResultCancelled:
                        default:
                        {
                            NSLog(@"Cancelled...");
                            
                            break;
                        }
                    }};
                
                UIPasteboard *pasteBoard = [UIPasteboard generalPasteboard];
                pasteBoard.string = messageToShare;
                
                [facebookController setInitialText:messageToShare];
                [facebookController addImage:imageToShare];
                [facebookController addURL:urlToShare];
                [facebookController setCompletionHandler:completionHandler];
                [self presentViewController:facebookController animated:YES completion:nil];
            }
            else
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_FACEBOOK_",nil)
                                                                message:NSLocalizedString(@"_SOCIALNETWORKNOTAVAILABLE_",nil)
                                                               delegate:self
                                                      cancelButtonTitle:NSLocalizedString(@"_OK_",nil)
                                                      otherButtonTitles:nil];
                [alert show];
            }
            
            self.currentSharedObject = nil;
            self.currentPreviewImage = nil;
            break;
        case TWITTER:
            if([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter])
            {
                SLComposeViewController *twitterController=[SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
                
                SLComposeViewControllerCompletionHandler __block completionHandler=^(SLComposeViewControllerResult result){
                    
                    [twitterController dismissViewControllerAnimated:YES completion:nil];
                    
                    switch(result)
                    {
                        case SLComposeViewControllerResultDone:
                        {
                            NSLog(@"Shared...");
                            [self afterSharedIn:@"twitter"];
                            break;
                        }
                        case SLComposeViewControllerResultCancelled:
                        default:
                        {
                            NSLog(@"Cancelled...");
                            
                            break;
                        }
                    }};
                
                UIPasteboard *pasteBoard = [UIPasteboard generalPasteboard];
                pasteBoard.string = messageToShare;
                
                [twitterController setInitialText:messageToShare];
                [twitterController addURL:urlToShare];
                [twitterController setCompletionHandler:completionHandler];
                [self presentViewController:twitterController animated:YES completion:nil];
            }
            else
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_TWITTER_",nil)
                                                                message:NSLocalizedString(@"_SOCIALNETWORKNOTAVAILABLE_",nil)
                                                               delegate:self
                                                      cancelButtonTitle:NSLocalizedString(@"_OK_",nil)
                                                      otherButtonTitles:nil];
                [alert show];
            }
            
            self.currentSharedObject = nil;
            self.currentPreviewImage = nil;
            break;
        case INSTAGRAM:
            if([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"instagram://"]])
            {
                NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                
                NSString *documentsPath = [paths objectAtIndex:0];
                
                NSString* savePath = [documentsPath stringByAppendingPathComponent:@"imageToShare.igo"];
                
                BOOL result = NO;
                
                @autoreleasepool {
                    
                    NSData *imageData = UIImageJPEGRepresentation(imageToShare, 0.5);
                    result = [imageData writeToFile:savePath atomically:YES];
                    imageData = nil;
                }
                
                if(result)
                {
                    self.docController = [UIDocumentInteractionController interactionControllerWithURL:[NSURL fileURLWithPath:savePath]];
                    
                    [self.docController setDelegate:self];
                    
                    [self.docController setUTI:@"com.instagram.exclusivegram"];
                    
                    [self.docController setAnnotation:@{@"InstagramCaption" : [NSString stringWithFormat:@"%@ %@", messageToShare, urlToShare]}];
                    
                    UIPasteboard *pasteBoard = [UIPasteboard generalPasteboard];
                    pasteBoard.string = [NSString stringWithFormat:@"%@ %@", messageToShare, urlToShare];
                    
                    [self.docController presentOpenInMenuFromRect:CGRectZero inView:self.view animated:YES];
                }
                else
                {
                    NSError *error = nil;
                    
                    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                    
                    NSString *documentsPath = [paths objectAtIndex:0];
                    
                    NSString* deletePath = [documentsPath stringByAppendingPathComponent:@"imageToShare.igo"];
                    
                    if (![[NSFileManager defaultManager] removeItemAtPath:deletePath error:&error])
                    {
                        NSLog(@"Error cleaning up temporary image file: %@", error);
                    }
                    
                    self.currentSharedObject = nil;
                    self.currentPreviewImage = nil;
                    
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_INSTAGRAM_",nil)
                                                                    message:NSLocalizedString(@"_CANTSHAREIMAGE_",nil)
                                                                   delegate:self
                                                          cancelButtonTitle:NSLocalizedString(@"_OK_",nil)
                                                          otherButtonTitles:nil];
                    [alert show];
                }
            }
            else
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_INSTAGRAM_",nil)
                                                                message:NSLocalizedString(@"_SOCIALNETWORKNOTAVAILABLE_",nil)
                                                               delegate:self
                                                      cancelButtonTitle:NSLocalizedString(@"_OK_",nil)
                                                      otherButtonTitles:nil];
                [alert show];
            }
            
            self.currentSharedObject = nil;
            self.currentPreviewImage = nil;
            break;
        case MESSAGE:
        case MMS:
        case EMAIL:
        case PINTEREST:
        case LINKEDIN:
        case SNAPCHAT:
        case TUMBLR:
        case FLIKER:
        {
            // items to share
            NSArray *sharingItems =  @[messageToShare, imageToShare, urlToShare];
            
            // create the controller
            UIActivityViewController *activityVC = [[UIActivityViewController alloc]initWithActivityItems:sharingItems applicationActivities:nil];
            
            NSArray *excludeActivities = @[UIActivityTypeAirDrop,
                                           UIActivityTypePrint,
                                           UIActivityTypeCopyToPasteboard,
                                           UIActivityTypeAssignToContact,
                                           UIActivityTypeSaveToCameraRoll,
                                           UIActivityTypeAddToReadingList,
                                           UIActivityTypePostToFacebook,
                                           UIActivityTypePostToTwitter,
                                           ];
            
            
            activityVC.excludedActivityTypes = excludeActivities;
            
            activityVC.completionWithItemsHandler = ^(NSString *act, BOOL done, NSArray *returnedItems, NSError *activityError)
            {
                if ( done )
                {
                    NSLog(@"Shared in %@", act);
                    
                    [self afterSharedIn:act];
                }
            };
            
            [self presentViewController:activityVC animated:YES completion:nil];
        }
            
            self.currentSharedObject = nil;
            self.currentPreviewImage = nil;
            break;
        default:
            break;
    }
}

-(void) afterSharedIn:(NSString *) sSocialNetwork
{
    [self uploadProductSharedIn:sSocialNetwork];
}

-(void)uploadProductSharedIn:(NSString *) sSocialNetwork
{
    // Check that the name is valid
    
//    if (!(_shownProduct.idProduct == nil))
//    {
//        if(!([_shownProduct.idProduct isEqualToString:@""]))
//        {
//            // Post the ProductView object
//            
//            ProductShared * newProductShared = [[ProductShared alloc] init];
//            
//            newProductShared.localtime = [NSDate date];
//            
//            newProductShared.socialNetwork = sSocialNetwork;
//            
//            [newProductShared setProductId:_shownProduct.idProduct];
//            
//            [newProductShared setPostId:[self getPostComeFrom]];
//            
//            AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
//            
//            if (!(appDelegate.currentUser == nil))
//            {
//                if (!([appDelegate.currentUser.idUser isEqualToString:@""]))
//                {
//                    [newProductShared setUserId:appDelegate.currentUser.idUser];
//                }
//            }
//            
//            if(!(_searchQuery == nil))
//            {
//                if(!(_searchQuery.idSearchQuery == nil))
//                {
//                    if(!([_searchQuery.idSearchQuery isEqualToString:@""]))
//                    {
//                        [newProductShared setStatProductQueryId:_searchQuery.idSearchQuery];
//                    }
//                }
//            }
//            
//            [newProductShared setFingerprint:appDelegate.finger.fingerprint];
//            
//            [newProductShared setOrigin: NSStringFromClass([self.fromViewController class])];
//            
//            if ([self.fromViewController isKindOfClass:[SearchBaseViewController class]])
//            {
//                SearchBaseViewController * searchVC = (SearchBaseViewController *)self.fromViewController;
//                
//                [newProductShared setOrigindetail:[searchVC getSearchContextString]];
//            }
//            else if ([self.fromViewController isKindOfClass:[WardrobeContentViewController class]])
//            {
//                WardrobeContentViewController * wardrobeVC = (WardrobeContentViewController *)self.fromViewController;
//                
//                if (wardrobeVC.shownWardrobe != nil)
//                {
//                    [newProductShared setOrigindetail:wardrobeVC.shownWardrobe.userId];
//                }
//            }
//            
//            NSArray * requestParameters = [[NSArray alloc] initWithObjects:newProductShared, nil];
//            
//            [self performRestPost:ADD_PRODUCTSHARED withParamaters:requestParameters];
//        }
//    }
}


@end
