//
//  WizardReviewPageViewController.m
//  hg-ios-class-display
//
//  Created by Anthony Perritano on 8/21/13.
//  Copyright (c) 2013 Learning Technologies Group. All rights reserved.
//

#import "WizardReviewPageViewController.h"
#import "AppDelegate.h"

@interface WizardReviewPageViewController ()

@end

@implementation WizardReviewPageViewController

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
    
    
    [yesButton setTitle:[[_botInfo.name uppercaseString] stringByAppendingString:@"!!"] forState: UIControlStateNormal];

	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)cancelLogin:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)doLoginWithStudentName:(id)sender {
    
    
    NSString *xmppId = _botInfo.xmppName;
    NSString *currentPatchId = [_botInfo.name lowercaseString];
    
    [[NSUserDefaults standardUserDefaults] setObject:[xmppId stringByAppendingString:XMPP_TAIL] forKey:kXMPPmyJID];
    
    [[NSUserDefaults standardUserDefaults] setObject:xmppId forKey:kXMPPmyPassword];
    
    [[NSUserDefaults standardUserDefaults] setObject:_configurationInfo.run_id forKey:kXMPProomJID];

    //[[NSUserDefaults standardUserDefaults] setObject:_botInfo.name forKey:current_patch_id];
    
    [self dismissViewControllerAnimated:YES completion:^(void){
        
        [[self appDelegate] setupConfigurationAndRosterWithRunId:_configurationInfo.run_id WithPatchId:currentPatchId];
        
        
        
        [[self appDelegate] disconnect];
        [[self appDelegate] connect];
    }];
    
    
}

- (AppDelegate *)appDelegate
{
	return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}



@end
