//
//  CaptureManager.m
//  GoldenSpear
//
//  Created by Jose Antonio Sanchez Martinez on 03/05/15.
//  Copyright (c) 2015 GoldenSpear. All rights reserved.
//

#import "CaptureManager.h"

@implementation CaptureManager

#pragma mark Capture Session Configuration

- (id)init
{
    if ((self = [super init]))
    {
        [self setCaptureSession:[[AVCaptureSession alloc] init]];
    }
    
    return self;
}

- (void)addVideoPreviewLayer
{
    [self setPreviewLayer:[[AVCaptureVideoPreviewLayer alloc] initWithSession:[self captureSession]]];
    
    [[self previewLayer] setVideoGravity:AVLayerVideoGravityResizeAspectFill];
}

- (BOOL)addVideoInput
{
    AVCaptureDevice *videoDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    if (videoDevice)
    {
        NSError *error;
        
        AVCaptureDeviceInput *videoIn = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:&error];
        
        if (!error)
        {
            if ([[self captureSession] canAddInput:videoIn])
            {
                [[self captureSession] addInput:videoIn];
                
                return TRUE;
            }
            else
            {
                NSLog(@"Couldn't add video input");
                
                return FALSE;
            }
        }
        else
        {
            NSLog(@"Couldn't create video input");
            
            return FALSE;
        }
    }
    else
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_NO_CAMERA_", nil) message:NSLocalizedString(@"_CAMERA_NEEDED_FOR_AI_", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
        
        [alertView show];
        
        NSLog(@"Couldn't create video capture device");
        
        return FALSE;
    }
}

- (void)addStillImageOutput
{
    [self setStillImageOutput:[[AVCaptureStillImageOutput alloc] init]];
    
    NSDictionary *outputSettings = [[NSDictionary alloc] initWithObjectsAndKeys:AVVideoCodecJPEG,AVVideoCodecKey,nil];
    
    [[self stillImageOutput] setOutputSettings:outputSettings];
    
    AVCaptureConnection *videoConnection = nil;
    
    for (AVCaptureConnection *connection in [[self stillImageOutput] connections])
    {
        for (AVCaptureInputPort *port in [connection inputPorts])
        {
            if ([[port mediaType] isEqual:AVMediaTypeVideo] )
            {
                videoConnection = connection;
                break;
            }
        }
        if (videoConnection)
        {
            break;
        }
    }
    
    [[self captureSession] addOutput:[self stillImageOutput]];
}

- (void)captureStillImage
{
    AVCaptureConnection *videoConnection = nil;
    
    for (AVCaptureConnection *connection in [[self stillImageOutput] connections])
    {
        for (AVCaptureInputPort *port in [connection inputPorts])
        {
            if ([[port mediaType] isEqual:AVMediaTypeVideo])
            {
                videoConnection = connection;
                break;
            }
        }
        if (videoConnection)
        {
            break;
        }
    }
    
    if (![[self captureSession] isRunning])
    {
        [[self captureSession] startRunning];
    }
    
    //NSLog(@"About to request a capture from: %@", [self stillImageOutput]);
    
    NSLog(@"About to request a capture");
    
    [[self stillImageOutput] captureStillImageAsynchronouslyFromConnection:videoConnection
                                                         completionHandler:^(CMSampleBufferRef imageSampleBuffer, NSError *error) {
                                                             
                                                             [[self captureSession] stopRunning];
                                                             
                                                             /*CFDictionaryRef exifAttachments = CMGetAttachment(imageSampleBuffer, kCGImagePropertyExifDictionary, NULL);
                                                              
                                                              if (exifAttachments)
                                                              {
                                                              NSLog(@"attachements: %@", exifAttachments);
                                                              }
                                                              else
                                                              {
                                                              NSLog(@"no attachments");
                                                              }
                                                              */
                                                             NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageSampleBuffer];
                                                             
                                                             UIImage *image = [[UIImage alloc] initWithData:imageData];
                                                             
                                                             [self setStillImage:image];
                                                             
                                                             [[NSNotificationCenter defaultCenter] postNotificationName:@"imageCapturedSuccessfully" object:nil];
                                                         }];
}

@end
