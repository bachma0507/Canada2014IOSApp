//
//  ContactUsViewController.h
//  Fall2013IOSApp
//
//  Created by Barry on 6/23/13.
//  Copyright (c) 2013 BICSI. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ContactUsViewController : UIViewController <UIWebViewDelegate>
@property (strong, nonatomic) IBOutlet UIWebView *webView;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activity;

@end
