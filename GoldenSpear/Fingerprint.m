//
//  Fingerprint.m
//  GoldenSpear
//
//  Created by Alberto Seco on 5/9/15.
//  Copyright (c) 2015 GoldenSpear. All rights reserved.
//

#import "Fingerprint.h"
#import <JavaScriptCore/JavaScriptCore.h>

@implementation Fingerprint

-(instancetype) init
{
    self = [super init];
    self.bLoadedFingerPrint = NO;
    return self;
}

-(void) runFingerprint
{
    if (self.bLoadedFingerPrint == NO)
    {
        if (self.webView == nil)
            self.webView = [[UIWebView alloc] init];
        
        self.webView.hidden = YES;
        
        self.webView.delegate = self;
        
        if (self.viewParent != nil)
            [self.viewParent addSubview:self.webView];
        
        NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"fingerprint" ofType:@"html"]];
        
        [self.webView loadRequest:[NSURLRequest requestWithURL:url]];
    }
/*
    JSContext *context = [[JSContext alloc] initWithVirtualMachine:[[JSVirtualMachine alloc] init]];
    NSString *path = [[NSBundle mainBundle] pathForResource:@"fingerprint_script" ofType:@"js"];
    NSString *jsCode = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    
    JSValue * script = [context evaluateScript:jsCode];
    
    JSValue * jsFuntion = context[@"getFingerprint"];
    JSValue * value = [jsFuntion callWithArguments:nil];
    
    NSLog(@"FingerPrint %@", [value toString]);

    JSValue *jsFunction
    var my_hasher = murmurHash3.x64.hash128;
    var fp = new Fingerprint({ canvas: true, ie_activex: true, screen_resolution: true, hasher: my_hasher });
    var thisFingerprint = fp.get();
    document.body.innerHTML = thisFingerprint;
*/
    
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    NSString * body = [self.webView stringByEvaluatingJavaScriptFromString:@"document.body.innerHTML;"];
    
    self.fingerprint = [body stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];;
    self.error = @"";

    self.bLoadedFingerPrint = YES;
    
    if (self.delegate != nil)
        [self.delegate fingerprintfinished:self.fingerprint];
    
    if (self.viewParent != nil)
    {
        [self.webView removeFromSuperview];
    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    self.fingerprint = @"";
    self.error = error.description;
    
    self.bLoadedFingerPrint = NO;
    
    if (self.delegate != nil)
        [self.delegate fingerprintfinishederror:error];

    if (self.viewParent != nil)
    {
        [self.webView removeFromSuperview];
    }
}

@end
