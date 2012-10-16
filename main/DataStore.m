//
//  Created by Anthony Perritano on 9/14/12.
//  Copyright (c) 2012 Learning Technologies Group. All rights reserved.
//

#import "Player.h"
#import "DataStore.h"

@implementation DataStore

static NSMutableDictionary *dataPoints;
static NSMutableArray *players;

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
    players = [NSMutableArray array];
    
    
    [players addObject:[[Player alloc] initWithRFID:@"1612507" AndName:@"tony" AndScore:[NSNumber numberWithInt:0]]];
    [players addObject:[[Player alloc] initWithRFID:@"034" AndName:@"tony" AndScore:[NSNumber numberWithInt:0]]];
    [players addObject:[[Player alloc] initWithRFID:@"034" AndName:@"tony" AndScore:[NSNumber numberWithInt:0]]];
    [players addObject:[[Player alloc] initWithRFID:@"034" AndName:@"tony" AndScore:[NSNumber numberWithInt:0]]];
    [players addObject:[[Player alloc] initWithRFID:@"034" AndName:@"tony" AndScore:[NSNumber numberWithInt:0]]];
    [players addObject:[[Player alloc] initWithRFID:@"034" AndName:@"tony" AndScore:[NSNumber numberWithInt:0]]];
    [players addObject:[[Player alloc] initWithRFID:@"034" AndName:@"tony" AndScore:[NSNumber numberWithInt:0]]];
    [players addObject:[[Player alloc] initWithRFID:@"034" AndName:@"tony" AndScore:[NSNumber numberWithInt:0]]];
    [players addObject:[[Player alloc] initWithRFID:@"1623454" AndName:@"tony" AndScore:[NSNumber numberWithInt:0]]];
    [players addObject:[[Player alloc] initWithRFID:@"034" AndName:@"tony" AndScore:[NSNumber numberWithInt:0]]];
    [players addObject:[[Player alloc] initWithRFID:@"034" AndName:@"tony" AndScore:[NSNumber numberWithInt:0]]];
    [players addObject:[[Player alloc] initWithRFID:@"034" AndName:@"tony" AndScore:[NSNumber numberWithInt:0]]];
    [players addObject:[[Player alloc] initWithRFID:@"034" AndName:@"tony" AndScore:[NSNumber numberWithInt:0]]];
    [players addObject:[[Player alloc] initWithRFID:@"1623728" AndName:@"tony" AndScore:[NSNumber numberWithInt:0]]];
    [players addObject:[[Player alloc] initWithRFID:@"034" AndName:@"tony" AndScore:[NSNumber numberWithInt:0]]];
    [players addObject:[[Player alloc] initWithRFID:@"034" AndName:@"tony" AndScore:[NSNumber numberWithInt:0]]];
    [players addObject:[[Player alloc] initWithRFID:@"034" AndName:@"tony" AndScore:[NSNumber numberWithInt:0]]];
    [players addObject:[[Player alloc] initWithRFID:@"034" AndName:@"tony" AndScore:[NSNumber numberWithInt:0]]];
    [players addObject:[[Player alloc] initWithRFID:@"1623972" AndName:@"tony" AndScore:[NSNumber numberWithInt:0]]];
    [players addObject:[[Player alloc] initWithRFID:@"034" AndName:@"tony" AndScore:[NSNumber numberWithInt:0]]];
    
}

#pragma mark - data access methods

-(void)resetPlayerCount {
    [players removeAllObjects];
}

- (int)playerCount {
    return [players count];
}


- (void)addScore:(NSNumber *)score withRFID: (NSString *)rfid {
    
    for (int i = 0; i < [players count]; i++) {
        Player *p = [players objectAtIndex: i];
        if([p.rfid isEqualToString:rfid]){
            p.score = [NSNumber numberWithDouble:[p.score doubleValue] + [score doubleValue]];
            break;
        }
    }
}


- (void)addScore:(NSNumber *)score withKey: (NSNumber *)key {
    Player *p = [players objectAtIndex:[key integerValue]];
    p.score = [NSNumber numberWithDouble:[p.score doubleValue] + [score doubleValue]];
}

-(void)resetScoreWithRFID:rfid {
    for (int i = 0; i < [players count]; i++) {
        Player *p = [players objectAtIndex: i];
        if([p.rfid isEqualToString:rfid]){
            p.score = 0;
            break;
        }
    }
}

-(NSNumber *)scoreForKey: (NSUInteger)key {
    Player *player = [players objectAtIndex:key];
    return player.score;
}


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
