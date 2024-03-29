//
//  MyFavoritesViewController.m
//  Fall2013IOSApp
//
//  Created by Barry on 7/27/13.
//  Copyright (c) 2013 BICSI. All rights reserved.
//

#import "MyFavoritesViewController.h"
#import "Fall2013IOSAppAppDelegate.h"
//#import "StackMob.h"
#import "MyFavoritesDetailViewController.h"
#import "MyFavoritesCell.h"

@interface MyFavoritesViewController ()

@end

@implementation MyFavoritesViewController
@synthesize exhibitorName, boothNumber, url, phone;

- (NSManagedObjectContext *)managedObjectContext {
    NSManagedObjectContext *context = nil;
    id delegate = [[UIApplication sharedApplication] delegate];
    if ([delegate performSelector:@selector(managedObjectContext)]) {
        context = [delegate managedObjectContext];
    }
    return context;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [TestFlight passCheckpoint:@"MyFavoriteExhibitorsTable-info-viewed"];
    
    NSLog(@"ViewDidLoad in MyFavoritesViewController started");

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] initWithTitle:@" " style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationItem.backBarButtonItem = backButtonItem;
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc]
                                        init];
    [refreshControl addTarget:self action:@selector(refreshTable) forControlEvents:UIControlEventValueChanged];
    
    self.refreshControl  = refreshControl;
    
    [refreshControl beginRefreshing];
    
    
    [self refreshTable];

    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
//#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
//#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return [self.objects count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    MyFavoritesCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[MyFavoritesCell alloc]
                initWithStyle:UITableViewCellStyleDefault
                reuseIdentifier:CellIdentifier];
    }
    
    NSManagedObject *object = [self.objects objectAtIndex:indexPath.row];
    cell.exhibitorNameLabel.text = [object valueForKey:@"exhibitorname"];
    cell.boothNumberLabel.text = [object valueForKey:@"boothnumber"];
        //cell.sessionTimeLabel.text = [object valueForKey:@"sessiontime"];
    
    //NSLog(@"BOOTH NUMBER IS %@", cell.boothNumberLabel.text);
    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row%2 == 0) {
        UIColor *altCellColor = [UIColor colorWithWhite:0.7 alpha:0.1];
        cell.backgroundColor = altCellColor;
    }
}

- (void) refreshTable {
    NSUUID *id = [[UIDevice currentDevice] identifierForVendor];
    NSString *deviceID = [[NSString alloc] initWithFormat:@"%@",id];
    NSString *newDeviceID = [deviceID substringWithRange:NSMakeRange(30, [deviceID length]-30)];
    
    NSLog(@"Untruncated Device ID is: %@", deviceID);
    NSLog(@"Truncated Device ID is: %@", newDeviceID);
    
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Favorites" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"deviceowner == %@ && favorite == 'Yes'", newDeviceID]];
    //NSError *error = nil;
    //NSArray *array = [self executeFetchRequest:fetchRequest error:&error];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"boothnumber" ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptor, nil];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    NSArray *results = [self.managedObjectContext executeFetchRequest:fetchRequest error:nil];
    
    //[self.managedObjectContext executeFetchRequest:fetchRequest onSuccess:^(NSArray *results) {
    [self.refreshControl endRefreshing];
    self.objects = results;
    [self.tableView reloadData];
    
    //    } onFailure:^(NSError *error) {
    //
    //        [self.refreshControl endRefreshing];
    //        NSLog(@"An error %@, %@", error, [error userInfo]);
    //    }];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return YES if you want the specified item to be editable.
    return YES;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        //add code here for when you hit delete
        
        //NSManagedObjectContext *context = [[[self appDelegate] coreDataStore] contextForCurrentThread];
        
        NSManagedObject *object = [self.objects objectAtIndex:indexPath.row];
        
        NSManagedObjectContext *context = [self managedObjectContext];
        
        [context deleteObject:[context objectWithID:[object objectID]]];
        
        NSError *error = nil;
        // Save the object to persistent store
        if (![context save:&error]) {
            NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
        }
        
        //[context saveOnSuccess:^{
        //NSLog(@"The save was successful!");
        //        } onFailure:^(NSError *error) {
        //            NSLog(@"The save wasn't successful: %@", [error localizedDescription]);
        //        }];
        
        NSMutableArray *array = [self.objects mutableCopy];
        [array removeObjectAtIndex:indexPath.row];
        self.objects = array;
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"myFavoritesDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        NSManagedObject *object = [self.objects objectAtIndex:indexPath.row];
        self.exhibitorName = [object valueForKey:@"exhibitorname"];
        self.boothNumber = [object valueForKey:@"boothnumber"];
        self.url = [object valueForKey:@"url"];
        self.phone = [object valueForKey:@"phone"];
        
        MyFavoritesDetailViewController *destViewController = segue.destinationViewController;
        destViewController.title = self.exhibitorName;
        destViewController.exhibitorName = self.exhibitorName;
        destViewController.boothNumber = self.boothNumber;
        destViewController.url = self.url;
        destViewController.phone = self.phone;
        
        NSLog(@"Segue Booth Number is %@", self.boothNumber);
        NSLog(@"Segue Exhibitor Name is %@", self.exhibitorName);
        NSLog(@"Segue URL Name is %@", self.url);
        NSLog(@"Segue Phone Name is %@", self.phone);
    }
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

@end
