//
//  WizardStudentPageViewController.h
//  hg-ios-class-display
//
//  Created by Anthony Perritano on 8/20/13.
//  Copyright (c) 2013 Learning Technologies Group. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoreDataTableViewController.h"

@interface WizardPatchPageViewController :  UITableViewController {
   
}

@property (nonatomic, retain) ConfigurationInfo *configurationInfo;
@property (nonatomic, retain) NSString *choosen_student;
- (IBAction)chooseStudent:(id)sender;

@end

