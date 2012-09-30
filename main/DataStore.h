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
-(void)removeAnimal;
@end
