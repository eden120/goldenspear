//
//  Fingerprint.h
//  GoldenSpear
//
//  Created by Alberto Seco on 5/9/15.
//  Copyright (c) 2015 GoldenSpear. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

// Set up a delegate to notify the view controller when the rating changes
@protocol FingerPrintDelegate

- (void)fingerprintfinished:(NSString *)fingerprint;
- (void)fingerprintfinishederror:(NSError *)error;

@end

@interface Fingerprint : NSObject <UIWebViewDelegate>

@property (assign) id <FingerPrintDelegate> delegate;

@property (retain) UIWebView *webView;
@property (retain) UIView *viewParent;
@property (nonatomic) BOOL bLoadedFingerPrint;
@property (nonatomic) NSString * error;
@property (nonatomic) NSString * fingerprint;

-(void) runFingerprint;

@end
