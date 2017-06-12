//
//  FashionistaCoverPageViewController.m
//  GoldenSpear
//
//  Created by JCB on 9/1/16.
//  Copyright © 2016 GoldenSpear. All rights reserved.
//


#include "FashionistaCoverPageViewController.h"
#include "BaseViewController+TopBarManagement.h"
#include "BaseViewController+StoryboardManagement.h"
#include "UIImageView+WebCache.h"
#include "MagazineTappedViewController.h"
#import "BaseViewController+ActivityFeedbackManagement.h"
#import "BaseViewController+RestServicesManagement.h"

@interface FashionistaCoverPageViewController()

@end

@implementation FashionistaCoverPageViewController {
    FashionistaPost *thePost;
    User *postOwner;
    FashionistaContent *theContent;
    NSMutableArray *moreMagazines;
    NSMutableArray *relateMagazines;
}

-(void)viewDidLoad {
    [super viewDidLoad];
    
    thePost = [self.postParameters objectAtIndex:1];
    postOwner = [self.postParameters objectAtIndex:6];
    theContent = [[self.postParameters objectAtIndex:2] firstObject];
    
    NSLog(@"FashionistaContent imagetext : %@", theContent.imageText);
    NSLog(@"FashionistaContent text : %@", theContent.text);
    NSLog(@"FashionistaContent order : %li", [theContent.order integerValue]);
    
    theContent = [[self.postParameters objectAtIndex:2] objectAtIndex:1];
    
    NSLog(@"FashionistaContent imagetext : %@", theContent.imageText);
    NSLog(@"FashionistaContent text : %@", theContent.text);
    NSLog(@"FashionistaContent order : %li", [theContent.order integerValue]);
    
    NSLog(@"Post title : %@", thePost.name);
}

-(void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    NSDate *date = thePost.date;
    NSDate *created = thePost.createdAt;
    [self.previewImage sd_setImageWithURL:[NSURL URLWithString:thePost.preview_image]];
    self.nameLabel.text = thePost.name;
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapGesture:)];
    [self.containerView addGestureRecognizer:singleTap];
}

-(void)onTapGesture:(UITapGestureRecognizer*)sender {
    [self transitionToViewController:FASHIONISTAPOST_VC withParameters:self.postParameters];
}

- (IBAction)onTapStory:(id)sender {
    _storyVC = [self.storyboard instantiateViewControllerWithIdentifier:@"StoryViewVC"];
    _storyVC.postParameters = self.postParameters;
    _storyVC.moreMagazines = moreMagazines;
    _storyVC.relatedMagazines = relateMagazines;
    _storyVC.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    [self presentViewController:_storyVC animated:YES completion:nil];
}

-(void)getMoreMagazine {
    [self stopActivityFeedback];
    [self startActivityFeedbackWithMessage:NSLocalizedString(@"_UPLOADINGPOSTCONTENTREPORT_ACTV_MSG_", nil)];
    NSArray *requestParams = [[NSArray alloc] initWithObjects:postOwner.idUser, nil];
    
    [self performRestGet:GET_FASHIONISTAMAGAZINES withParamaters:requestParams];
}

-(void)getRelatedMagazine {
    [self stopActivityFeedback];
    [self startActivityFeedbackWithMessage:NSLocalizedString(@"_UPLOADINGPOSTCONTENTREPORT_ACTV_MSG_", nil)];
    NSArray *requestParams = [[NSArray alloc] initWithObjects:thePost.magazineCategory, nil];
    [self performRestGet:GET_FASHIONISTAMAGAZINES_RELATED withParamaters:requestParams];
}

-(void)actionAfterSuccessfulAnswerToRestConnection:(connectionType)connection WithResult:(NSArray *)mappingResult {
    switch (connection) {
        case GET_FASHIONISTAMAGAZINES:
        {
            [self stopActivityFeedback];
            [moreMagazines removeAllObjects];
            moreMagazines = [NSMutableArray new];
            for (FashionistaPost *result in mappingResult) {
                if ([result isKindOfClass:[FashionistaPost class]]) {
                    [moreMagazines addObject:result];
                }
            }
            
            break;
        }
        case GET_FASHIONISTAMAGAZINES_RELATED:
        {
            [self stopActivityFeedback];
            [relateMagazines removeAllObjects];
            relateMagazines = [NSMutableArray new];
            for (FashionistaPost *result in mappingResult) {
                if ([result isKindOfClass:[FashionistaPost class]]) {
                    [relateMagazines addObject:result];
                }
            }
            
            break;
        }
        default:
            break;
    }
}

@end
