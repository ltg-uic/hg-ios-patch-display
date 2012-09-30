//
//  Created by Anthony Perritano on 9/14/12.
//  Copyright (c) 2012 Learning Technologies Group. All rights reserved.
//

#import "DataStore.h"

@implementation DataStore

static NSMutableDictionary *dataPoints;

#pragma mark - Class methods

+ (DataStore *)sharedInstance
{
    static DataStore *sharedInstance;
    
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
        
    });
    
    return sharedInstance;
}

- (id)init {
    self = [super init];
    if (self) {
        [self initDatapoints];
    }
    return self;
}

-(void)initDatapoints {
     dataPoints = [NSMutableDictionary dictionary];
    //[dataPoints setObject: [NSNumber numberWithInt:320]  forKey: [NSNumber numberWithInt:0]];
    //[dataPoints setObject: [NSNumber numberWithInt:450]  forKey: [NSNumber numberWithInt:1]];
    
}

#pragma mark - data access methods

-(void)resetAnimalCount {
    [dataPoints removeAllObjects];
}
- (int)animalCount {
    return [dataPoints count];
}

-(void)removeAnimal {
    [dataPoints removeObjectForKey:[NSNumber numberWithInt:dataPoints.count-1]];
}

- (NSNumber *)animalFoodForKey: (NSUInteger)key {
    return [dataPoints objectForKey:[NSNumber numberWithInt:key]];;
}


- (void)addFood:(NSNumber *)food withKey: (NSNumber *)key {
    [dataPoints setObject: food  forKey: key];
}

- (void)addFood:(int)food {
    
    for (NSString *key in [dataPoints allKeys]) {
        
        
        NSNumber *oldValue =(NSNumber *)[dataPoints objectForKey:key];
        
        
        
        [dataPoints setObject:[NSNumber numberWithInt:[oldValue intValue]+food] forKey:key];
        

    }
}

@end
