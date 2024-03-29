//
//  ProgramPDFViewController.m
//  Fall2013IOSApp
//
//  Created by Barry on 8/31/13.
//  Copyright (c) 2013 BICSI. All rights reserved.
//

#import "ProgramPDFViewController.h"

@interface ProgramPDFViewController ()

@end

@implementation ProgramPDFViewController
@synthesize webView;
@synthesize activity;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [TestFlight passCheckpoint:@"PDFPresentations-info-viewed"];
    
    UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] initWithTitle:@" " style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationItem.backBarButtonItem = backButtonItem;
    
	// Do any additional setup after loading the view.
    
    webView.delegate = self;
    
    NSString *httpSource = @"http://www.speedyreference.com/bicsiappcms/presentationspdf.html";
    NSURL *fullUrl = [NSURL URLWithString:httpSource];
    NSURLRequest *httpRequest = [NSURLRequest requestWithURL:fullUrl];
    [webView loadRequest:httpRequest];
    
    
//    NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle]pathForResource:@"THE BICSI 2014 WINTER CONFERENCE PROGRAM.pdf" ofType:nil]];
//    NSURLRequest *request = [NSURLRequest requestWithURL:url];
//    [webView loadRequest:request];
    
 //   NSString *httpSource = @"http://barrycjulien.com/bicsi/pdf/ProgramFall2013.pdf";
//    //NSString *httpSource = @"http://www.chirpe.com/Floorplan.aspx?EventID=2027";
 //   NSURL *fullUrl = [NSURL URLWithString:httpSource];
//    NSURLRequest *httpRequest = [NSURLRequest requestWithURL:fullUrl];
//    [webView loadRequest:httpRequest];
    
    //    NSString * myURL = [NSString stringWithFormat:@"http://www.chirpe.com/Floorplan.aspx?EventID=2027"];
    //    NSURL *URL = [NSURL URLWithString:myURL];
    //	SVWebViewController *webViewController = [[SVWebViewController alloc] initWithURL:URL];
    //	[self.navigationController pushViewController:webViewController animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)webViewDidStartLoad:(UIWebView *)WebView
{
    [activity startAnimating];
    
    
}

-(void)webViewDidFinishLoad:(UIWebView *)WebView
{
    [activity stopAnimating];
    activity.hidden = TRUE;
    
}

- (IBAction)handlePinch:(UIPinchGestureRecognizer *)recognizer {
    recognizer.view.transform = CGAffineTransformScale(recognizer.view.transform, recognizer.scale, recognizer.scale);
    recognizer.scale = 1;
}

- (IBAction)handlePan:(UIPanGestureRecognizer *)recognizer {
    
    CGPoint translation = [recognizer translationInView:self.view];
    recognizer.view.center = CGPointMake(recognizer.view.center.x + translation.x,
                                         recognizer.view.center.y + translation.y);
    [recognizer setTranslation:CGPointMake(0, 0) inView:self.view];
    
}

@end
