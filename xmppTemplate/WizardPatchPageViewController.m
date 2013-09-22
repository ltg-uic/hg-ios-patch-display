//
//  WizardStudentPageViewController.m
//  hg-ios-class-display
//
//  Created by Anthony Perritano on 8/20/13.
//  Copyright (c) 2013 Learning Technologies Group. All rights reserved.
//

#import "WizardPatchPageViewController.h"
#import "WizardReviewPageViewController.h"
#import "PlayerDataPoint.h"
#import "WizardPatchCell.h"
#import "AFNetworking.h"
#import "UIColor-Expanded.h"
#import "BotInfo.h"

@interface WizardPatchPageViewController () {
    NSArray *bots;
}

@end

@implementation WizardPatchPageViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithCoder:(NSCoder*)aDecoder
{
    if(self = [super initWithCoder:aDecoder])
    {
       
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    bots = [[_configurationInfo bots] allObjects];
    
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES selector:@selector(caseInsensitiveCompare:)];
    
    bots = [bots sortedArrayUsingDescriptors:@[sort]];
	
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [bots count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"wizcell_patch";
    WizardPatchCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    if (cell == nil) {
        cell = [[WizardPatchCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    BotInfo *bot = [bots objectAtIndex:indexPath.row];

    cell.patchUILabel.text = [bot.name capitalizedString];
    
    return cell;
}


- (UIColor *) getTextColor:(UIColor *)color
{
    const CGFloat *componentColors = CGColorGetComponents(color.CGColor);
    
    CGFloat colorBrightness = ((componentColors[0] * 299) + (componentColors[1] * 587) + (componentColors[2] * 114)) / 1000;
    if (colorBrightness < 0.5)
    {
        NSLog(@"my color is dark");
        return [UIColor whiteColor];
    }
    else
    {
        NSLog(@"my color is light");
        return [UIColor blackColor];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"review_segue"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        BotInfo *bot = [bots objectAtIndex:indexPath.row];
        WizardReviewPageViewController *destViewController = segue.destinationViewController;
        [destViewController setConfigurationInfo:_configurationInfo];
        [destViewController setBotInfo:bot];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)cancelLogin:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
