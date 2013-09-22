//
//  ConfigurationInfo.h
//  hg-ios-patch-display
//
//  Created by Anthony Perritano on 9/21/13.
//  Copyright (c) 2013 Learning Technologies Group. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class PatchInfo, PlayerDataPoint;

@interface ConfigurationInfo : NSManagedObject

@property (nonatomic) float harvest_calculator_bout_length_in_minutes;
@property (nonatomic) float maximum_harvest;
@property (nonatomic) float predation_penalty_length_in_seconds;
@property (nonatomic) float prospering_threshold;
@property (nonatomic, retain) NSString * run_id;
@property (nonatomic) float starving_threshold;
@property (nonatomic, retain) NSSet *patches;
@property (nonatomic, retain) NSSet *players;
@property (nonatomic, retain) NSSet *bots;
@end

@interface ConfigurationInfo (CoreDataGeneratedAccessors)

- (void)addPatchesObject:(PatchInfo *)value;
- (void)removePatchesObject:(PatchInfo *)value;
- (void)addPatches:(NSSet *)values;
- (void)removePatches:(NSSet *)values;

- (void)addPlayersObject:(PlayerDataPoint *)value;
- (void)removePlayersObject:(PlayerDataPoint *)value;
- (void)addPlayers:(NSSet *)values;
- (void)removePlayers:(NSSet *)values;

- (void)addBotsObject:(NSManagedObject *)value;
- (void)removeBotsObject:(NSManagedObject *)value;
- (void)addBots:(NSSet *)values;
- (void)removeBots:(NSSet *)values;

@end
