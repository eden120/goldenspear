//
//  GSSocialAccountModuleView.h
//  GoldenSpear
//
//  Created by Adria Vernetta Rubio on 19/5/16.
//  Copyright © 2016 GoldenSpear. All rights reserved.
//

#import "GSAccountModuleView.h"

@class GSImageAccountModuleView;

@protocol GSImageAccountModuleViewDelegate <NSObject>

- (void)uploadImageOnImageAccountModule:(GSImageAccountModuleView*)imageModule;

@end

@interface GSImageAccountModuleView : GSAccountModuleView

@property (weak, nonatomic) IBOutlet UIImageView *theImage;
@property (nonatomic, strong) NSOperationQueue *imagesQueue;
@property (weak, nonatomic) id<GSImageAccountModuleViewDelegate> imageDelegate;
@property (weak, nonatomic) IBOutlet UIButton *submitButton;

- (IBAction)uploadButton:(id)sender;
- (IBAction)removePic:(id)sender;

@end
