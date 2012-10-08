//
//  CPDStockPriceStore.h
//  CorePlotDemo
//
//  Created by Steve Baranski on 5/4/12.
//  Copyright (c) 2012 komorka technology, llc. All rights reserved.
//

@interface DataStore : NSObject

+ (DataStore *)sharedInstance;

- (int)animalCount;

- (NSNumber *)animalFoodForKey: (NSUInteger)key;
- (void)addFood:(NSNumber *)food withKey: (NSNumber *)key;
- (void)addFood:(int)food;
- (void)resetAnimalCount;
- (void)removeAnimal;


- (void)resetPlayerCount;
- (int)playerCount;
- (void)addScore:(NSNumber *)score withKey: (NSNumber *)key;
- (NSNumber *)scoreForKey: (NSUInteger)key;
- (void)addScore:(NSNumber *)score withRFID: (NSString *)rfid;
- (void)resetScoreWithRFID:rfid;

@end
