//
//  IpadWallPicturesViewController.m
//  Winter2014IOSApp
//
//  Created by Barry on 10/14/13.
//  Copyright (c) 2013 BICSI. All rights reserved.
//

#import "IpadWallPicturesViewController.h"
#import "IpadUploadImageViewController.h"

#import <Parse/Parse.h>

#import "Constants.h"

#import "MBProgressHUD.h"

@interface IpadWallPicturesViewController () {
    
}

@property (nonatomic, retain) NSArray *wallObjectsArray;
@property (nonatomic, retain) UIActivityIndicatorView *activityIndicator;


-(void)getWallImages;
-(void)loadWallViews;
-(void)showErrorView:errorString;

@end

@implementation IpadWallPicturesViewController

@synthesize wallObjectsArray = _wallObjectsArray;
@synthesize wallScroll = _wallScroll;
@synthesize activityIndicator = _loadingSpinner;
@synthesize actvity;



- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [TestFlight passCheckpoint:@"GalleryIpadPics-viewed"];
    
    UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] initWithTitle:@" " style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationItem.backBarButtonItem = backButtonItem;
    
//    HUD = [[MBProgressHUD alloc] initWithView:self.view];
//    HUD.labelText = @"Loading photos...";
//    //HUD.detailsLabelText = @"Just relax";
//    HUD.mode = MBProgressHUDAnimationFade;
//    //HUD.mode = MBProgressHUDModeIndeterminate;
//    [self.view addSubview:HUD];
//    [HUD showWhileExecuting:@selector(getWallImages) onTarget:self withObject:nil animated:YES];
    
    [actvity startAnimating];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    self.wallScroll = nil;
    
    [actvity stopAnimating];
    actvity.hidden = TRUE;
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //Clean the scroll view
    for (id viewToRemove in [self.wallScroll subviews]){
        if ([viewToRemove isMemberOfClass:[UIView class]])
            [viewToRemove removeFromSuperview];
    }
    
    //Reload the wall
    [self getWallImages];
    
    HUD = [[MBProgressHUD alloc] initWithView:self.view];
    HUD.labelText = @"Loading photos...";
    //HUD.detailsLabelText = @"Just relax";
    HUD.mode = MBProgressHUDAnimationFade;
    //HUD.mode = MBProgressHUDModeIndeterminate;
    [self.view addSubview:HUD];
    [HUD showWhileExecuting:@selector(getWallImages) onTarget:self withObject:nil animated:YES];
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


#pragma mark Wall Load
//Load the images on the wall
//Load the images on the wall
-(void)loadWallViews
{
    //Clean the scroll view
    for (id viewToRemove in [self.wallScroll subviews]){
        
        if ([viewToRemove isMemberOfClass:[UIView class]])
            [viewToRemove removeFromSuperview];
    }
    
    
    //For every wall element, put a view in the scroll
    int originY = 10;
    
    for (PFObject *wallObject in self.wallObjectsArray){
        
        
        //Build the view with the image and the comments
        UIView *wallImageView = [[UIView alloc] initWithFrame:CGRectMake(10, originY, self.view.frame.size.width - 20 , 600)];
        
        //Add the image
        PFFile *image = (PFFile *)[wallObject objectForKey:KEY_IMAGE];
        UIImageView *userImage = [[UIImageView alloc] initWithImage:[UIImage imageWithData:image.getData]];
        userImage.frame = CGRectMake(0, 0, wallImageView.frame.size.width, 600);
        [wallImageView addSubview:userImage];
        
        //Add the info label (User and creation date)
        NSDate *creationDate = wallObject.createdAt;
        NSDateFormatter *df = [[NSDateFormatter alloc] init];
        [df setDateFormat:@"MMM dd yyyy hh:mm a"];
        
        UILabel *infoLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 630, wallImageView.frame.size.width,15)];
        infoLabel.text = [NSString stringWithFormat:@"Uploaded by: %@, %@", [wallObject objectForKey:KEY_USER], [df stringFromDate:creationDate]];
        infoLabel.font = [UIFont fontWithName:@"Arial-ItalicMT" size:13];
        infoLabel.textColor = [UIColor grayColor];
        infoLabel.backgroundColor = [UIColor clearColor];
        [wallImageView addSubview:infoLabel];
        
        //Add the comment
        UILabel *commentLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 606, wallImageView.frame.size.width, 25)];
        commentLabel.text = [wallObject objectForKey:KEY_COMMENT];
        commentLabel.font = [UIFont fontWithName:@"ArialMT" size:20];
        commentLabel.textColor = [UIColor grayColor];
        commentLabel.backgroundColor = [UIColor clearColor];
        [wallImageView addSubview:commentLabel];
        
        [self.wallScroll addSubview:wallImageView];
        
        
        originY = originY + wallImageView.frame.size.width + 20;
        
    }
    
    //Set the bounds of the scroll
    self.wallScroll.contentSize = CGSizeMake(self.wallScroll.frame.size.width, originY);
    
    //Remove the activity indicator
    [self.activityIndicator stopAnimating];
    [self.activityIndicator removeFromSuperview];
}



#pragma mark Receive Wall Objects

//Get the list of images
-(void)getWallImages
{
    //Prepare the query to get all the images in descending order
    //    PFQuery *query = [PFQuery queryWithClassName:WALL_OBJECT];
    //    [query orderByDescending:KEY_CREATION_DATE];
    PFQuery *query = [PFQuery queryWithClassName:WALL_OBJECT];
    [query orderByDescending:KEY_CREATION_DATE];
    [query whereKey:KEY_STATUS equalTo:@"CANapproved"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        if (!error) {
            //Everything was correct, put the new objects and load the wall
            self.wallObjectsArray = nil;
            self.wallObjectsArray = [[NSArray alloc] initWithArray:objects];
            
            [self loadWallViews];
            
        } else {
            //Remove the activity indicator
            [self.activityIndicator stopAnimating];
            [self.activityIndicator removeFromSuperview];
            
            //Show the error
            NSString *errorString = [[error userInfo] objectForKey:@"error"];
            [self showErrorView:errorString];
        }
    }];
    
}


#pragma mark IB Actions


-(IBAction)logoutPressed:(id)sender
{
    
    [TestFlight passCheckpoint:@"GalleryIpadLogoutButton-pressed"];
    
    //TODO
    //If logout succesful:
    //[self.navigationController popViewControllerAnimated:YES];
    UIViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"IpadLoginViewController"];
    [self.navigationController pushViewController:controller animated:YES];
    
}

- (IBAction)refreshView:(id)sender {
    
    [self getWallImages];
}



#pragma mark Error Alert

-(void)showErrorView:(NSString *)errorMsg{
    
    UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:@"Error" message:errorMsg delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
    [errorAlertView show];
}


@end

