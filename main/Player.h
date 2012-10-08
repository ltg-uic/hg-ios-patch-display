//
//  Player.h
//  foraging-patch-ios-client
//
//  Created by Anthony Perritano on 10/7/12.
//  Copyright (c) 2012 Learning Technologies Group. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Player : NSObject {
    
    
}

@property(strong) NSString *rfid;
@property(strong) NSString *name;
@property(strong) NSNumber *score;

-(id)initWithRFID:(NSString *)rfid AndName:(NSString *)name AndScore:(NSNumber *)score;


@end
