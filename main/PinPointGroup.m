//
//  PinPointGroup.m
//  foraging-patch-ios-client
//
//  Created by Anthony Perritano on 11/3/12.
//  Copyright (c) 2012 Learning Technologies Group. All rights reserved.
//

#import "PinPointGroup.h"

@implementation PinPointGroup

- (id)init
{
    self = [super init];
    if (self) {
        _player = nil;
        _pinPoint = nil;
    }
    return self;
}

-(id)initWithPlayer:(Player *)player AndPinPoint:(PinPoint *)pinPoint {
    self = [super init];
    if (self) {
        _player = player;
        _pinPoint = pinPoint;
    }
    return self;
}

@end
