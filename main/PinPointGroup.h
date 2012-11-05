//
//  PinPointGroup.h
//  foraging-patch-ios-client
//
//  Created by Anthony Perritano on 11/3/12.
//  Copyright (c) 2012 Learning Technologies Group. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PinPoint.h"
#import "Player.h"
#import "PacmanView.h"

@interface PinPointGroup : NSObject


@property(strong) Player *player;
@property(strong) PacmanView *pinPoint;

-(id)initWithPlayer:(Player *)player AndPinPoint:(PacmanView *)pinPoint;

@end
