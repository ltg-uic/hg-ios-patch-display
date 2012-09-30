//
//  LoginViewController.m
//  ios-xmppBase
//
//  Created by Anthony Perritano on 9/17/12.
//  Copyright (c) 2012 Learning Technologies Group. All rights reserved.
//

#import "AppDelegate.h"

@interface LoginViewController : UIViewController {
    
    __weak IBOutlet UITextField *loginTextField;
    __weak IBOutlet UITextField *passTextField;
}
- (IBAction)done:(id)sender;


@end

@implementation LoginViewController


#pragma mark - UIViewController lifecycle methods

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (AppDelegate *)appDelegate {
	return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    //dont hardcode fucking passwords in the code.
    
    NSString *l = [[NSUserDefaults standardUserDefaults] stringForKey:@"kXMPPmyJID"];
    NSString *p = [[NSUserDefaults standardUserDefaults] stringForKey:@"kXMPPmyPassword"];
    
    if( l != nil ) {
        loginTextField.text = l;
    } else {
        loginTextField.text = @"@phenomena.evl.uic.edu";
    }
    
    if( p != nil ) {
        passTextField.text = p;
    } else {
         passTextField.text = @"password";
    }

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Input methods

- (void)setField:(UITextField *)field forKey:(NSString *)key {
    if (field.text != nil)
    {
        [[NSUserDefaults standardUserDefaults] setObject:field.text forKey:key];
    } else {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:key];
    }
}


- (IBAction)done:(id)sender
{
    [self setField:loginTextField forKey:@"kXMPPmyJID"];
    [self setField:passTextField forKey:@"kXMPPmyPassword"];
    
    [self dismissViewControllerAnimated:YES completion:^(void){
        [[self appDelegate] connect];
    }];
}

@end
