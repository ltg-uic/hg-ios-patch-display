//
//  Player.m
//  foraging-patch-ios-client
//
//  Created by Anthony Perritano on 10/7/12.
//  Copyright (c) 2012 Learning Technologies Group. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Player.h"

@implementation Player

- (id)init
{
    self = [super init];
    if (self) {
        _rfid = nil;
        _name = nil;
        _score = nil;
    }
    return self;
}

    
-(id)initWithRFID:(NSString *)rfid AndName:(NSString *)name AndScore:(NSNumber *)score {
    self = [super init];
    if (self) {
        _rfid = rfid;
        _name = name;
        _score = score;
    }
    return self;
}

@end
