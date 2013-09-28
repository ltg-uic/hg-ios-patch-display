//
//  PlayerDataDelegate.h
//  hg-ios-class-display
//
//  Created by Anthony Perritano on 9/7/13.
//  Copyright (c) 2013 Learning Technologies Group. All rights reserved.
//

#import "PlayerDataPoint.h"

@protocol PlayerDataDelegate

-(void)playerDidLeave: (NSString *)player_id;
-(void)playerDidArrive: (NSString *)player_id;
-(void)boutReset;
-(void)boutStart;
-(void)boutStop;
@end
