//
//  WizClassPageViewController.m
//  hg-ios-class-display
//
//  Created by Anthony Perritano on 8/19/13.
//  Copyright (c) 2013 Learning Technologies Group. All rights reserved.
//

#import "WizardClassPageViewController.h"
#import "WizardPatchPageViewController.h"
#import "WizardClassCell.h"


@interface WizardClassPageViewController ()

@end

@implementation WizardClassPageViewController

@synthesize classes;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
    }
    return self;
}

- (id)initWithCoder:(NSCoder*)aDecoder
{
    if(self = [super initWithCoder:aDecoder])
    {
        //self.man
        

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    

}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self setupFetchedResultsController];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - JSON Requests


#pragma mark - Table view data source

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"wizcell_class";
    WizardClassCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    
    
    
    if (cell == nil) {
        cell = [[WizardClassCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    
   ConfigurationInfo *ci = [self.fetchedResultsController objectAtIndexPath:indexPath];//
//   
//    // Configure the cell.
    cell.classNameLabel.text = ci.run_id;
    
    return cell;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"patch_segue"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        ConfigurationInfo *ci = [self.fetchedResultsController objectAtIndexPath:indexPath];
        WizardPatchPageViewController *destViewController = segue.destinationViewController;
        [destViewController setConfigurationInfo:ci];
    }
}

- (void)setupFetchedResultsController
{

          // After 20 are faulted

    NSFetchedResultsController *theFetchedResultsController = [ConfigurationInfo MR_fetchAllSortedBy:@"run_id" ascending:NO withPredicate:nil groupBy:nil delegate:self];
    self.fetchedResultsController = theFetchedResultsController;
    self.fetchedResultsController.delegate = self;



    
}

- (IBAction)cancelLogin:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (AppDelegate *)appDelegate
{
	return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}

@end
