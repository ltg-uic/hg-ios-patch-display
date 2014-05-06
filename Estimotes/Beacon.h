//
//  Beacon.h
//  hg-ios-patch-display
//
//  Created by PauloGF on 4/14/14.
//  Copyright (c) 2014 Learning Technologies Group. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Beacon : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *identifier;
@property (nonatomic, strong) NSString *type;
@property (nonatomic, strong) NSNumber *rssi;
@property (nonatomic, strong) NSNumber *lastSighted;

//@property (nonatomic, strong) NSNumber *previousRSSI;
//@property (nonatomic, strong) NSNumber *batteryLevel;
//@property (nonatomic, strong) NSNumber *temperature;

@end
