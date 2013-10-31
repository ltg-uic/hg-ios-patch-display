//
//  ViewController.h
//  SidebarDemo
//
//  Created by Simon on 28/6/13.
//  Copyright (c) 2013 Appcoda. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PlayerDataDelegate.h"
#import "PacmanView.h"
#import "UIView+Animation.h"

@interface PatchViewController : UIViewController<PlayerDataDelegate> {
    __weak IBOutlet UILabel *currentYieldLabel;
    __weak IBOutlet UILabel *extraPlayersLabel;
    IBOutletCollection(UIImageView) NSArray *acorns;


}
@property (weak, nonatomic) IBOutlet UIBarButtonItem *revealButtonItem;
@property(nonatomic) BOOL hasInitialized;


@property (nonatomic) IBOutletCollection(PacmanView) NSArray *playerPacmanViews;
@property (nonatomic) IBOutletCollection(UILabel) NSArray *nameLabels;

@end
