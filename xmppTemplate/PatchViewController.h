//
//  ViewController.h
//  SidebarDemo
//
//  Created by Simon on 28/6/13.
//  Copyright (c) 2013 Appcoda. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PlayerDataDelegate.h"

@interface PatchViewController : UIViewController<PlayerDataDelegate> {
    __weak IBOutlet UILabel *currentYieldLabel;
    __weak IBOutlet UILabel *extraPlayersLabel;
    IBOutletCollection(UIImageView) NSArray *acorns;

}
@property (weak, nonatomic) IBOutlet UIBarButtonItem *revealButtonItem;
@property(nonatomic) BOOL hasInitialized;

@end
