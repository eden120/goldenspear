//
//  GSSocialAccountModuleView.m
//  GoldenSpear
//
//  Created by Adria Vernetta Rubio on 19/5/16.
//  Copyright © 2016 GoldenSpear. All rights reserved.
//

#import "GSImageAccountModuleView.h"
#import "AppDelegate.h"

@implementation GSImageAccountModuleView

- (void)dealloc{
    self.imagesQueue = nil;
}

- (id)init{
    if((self=[super init])){
        self.imagesQueue = [[NSOperationQueue alloc] init];
        // Set max number of concurrent operations it can perform at 3, which will make things load even faster
        self.imagesQueue.maxConcurrentOperationCount = 3;
        
        self.theImage.layer.borderColor = [[UIColor blackColor] CGColor];
        self.theImage.layer.borderWidth = 1;
    }
    return self;
}

- (void)fillModule:(User*)theUser withAccountModule:(GSAccountModule *)module{
    [super fillModule:theUser withAccountModule:module];
    NSString* previewImage = theUser.picture;
    if ([UIImage isCached:previewImage])
    {
        UIImage * image = [UIImage cachedImageWithURL:previewImage];
        
        if(image == nil)
        {
            image = [UIImage imageNamed:@"no_image.png"];
        }
        
        self.theImage.image = image;
    }
    else
    {
        NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
            
            UIImage * image = [UIImage cachedImageWithURL:previewImage];
            
            if(image == nil)
            {
                image = [UIImage imageNamed:@"no_image.png"];
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                self.theImage.image = image;
                [self.theImage setNeedsDisplay];
            });
        }];
        
        operation.queuePriority = NSOperationQueuePriorityHigh;
        
        [self.imagesQueue addOperation:operation];
    }
    [self.submitButton setTitle:[[NSString stringWithFormat:NSLocalizedString(@"_SUBMIT_IMAGE_TEXT_", nil),module.caption] uppercaseString] forState:UIControlStateNormal];
    
}

- (IBAction)uploadButton:(id)sender {
    [self.imageDelegate uploadImageOnImageAccountModule:self];
}

- (IBAction)removePic:(id)sender {
    moduleUser.picture = @"";
    self.theImage.image = [UIImage imageNamed:@"no_image.png"];
    [self.theImage setNeedsDisplay];
}

@end
