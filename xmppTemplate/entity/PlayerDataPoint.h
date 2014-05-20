//
//  PlayerDataPoint.h
//  hg-ios-patch-display
//
//  Created by PauloGF on 5/20/14.
//  Copyright (c) 2014 Learning Technologies Group. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class ConfigurationInfo;

@interface PlayerDataPoint : NSManagedObject

@property (nonatomic, retain) NSString * color;
@property (nonatomic, retain) NSString * currentPatch;
@property (nonatomic, retain) NSString * player_id;
@property (nonatomic, retain) NSString * rfid_tag;
@property (nonatomic, retain) NSNumber * score;
@property (nonatomic, retain) NSNumber * student;
@property (nonatomic, retain) ConfigurationInfo *configurationInfo;

@end
