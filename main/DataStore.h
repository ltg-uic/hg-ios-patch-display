//
//  CPDStockPriceStore.h
//  CorePlotDemo
//
//  Created by Steve Baranski on 5/4/12.
//  Copyright (c) 2012 komorka technology, llc. All rights reserved.
//

@interface DataStore : NSObject



+ (DataStore *)sharedInstance;


- (void)resetPlayerCount;
- (int)playerCount;
- (int)playerCountWithId: (NSString *)plotId;

- (void)addPlayerWithRFID:(NSString *)rfid withCluster:(NSString *)cluster withColor:(NSString *)color;

- (void) addScore: (NSNumber *)score WithIndex: (NSNumber *)index;
- (void)addScore:(NSNumber *)score withRFID: (NSString *)rfid;
- (void)addScore:(NSNumber *)score withKey: (NSNumber *)key;

- (void)resetScoreWithRFID: (NSString *)rfid;
- (NSNumber *)scoreForRFID: (NSString *)rfid;

- (NSNumber *)scoreForKey: (NSUInteger)key;
- (NSNumber *)scoreForKey: (NSUInteger)key andCluster:(NSString *)cluster;

- (NSString *)colorForKey: (NSUInteger)key;
@end
