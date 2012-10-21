//
//  Created by Anthony Perritano on 9/14/12.
//  Copyright (c) 2012 Learning Technologies Group. All rights reserved.
//

#import "Player.h"
#import "DataStore.h"

@implementation DataStore

static NSMutableDictionary *dataPoints;
static NSMutableDictionary *clusters;
static NSMutableArray *players;
static NSMutableArray *triangle;
static NSMutableArray *square;
static NSMutableArray *circle;
static NSMutableArray *star;


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
    
    triangle = [NSMutableArray array];
    square = [NSMutableArray array];
    circle = [NSMutableArray array];
    star = [NSMutableArray array];
    
    clusters = [NSMutableDictionary dictionary];
    [clusters setObject:triangle    forKey:@"triangle"];
    [clusters setObject:square      forKey:@"square"];
    [clusters setObject:circle      forKey:@"circle"];
    [clusters setObject:star        forKey:@"star"];
    
    
    [triangle addObject:[[Player alloc] initWithRFID:@"1623365"  AndCluster:@"triangle" AndColor:@"red" AndScore:[NSNumber numberWithInt:100]]];
    [triangle addObject:[[Player alloc] initWithRFID:@"1623641"  AndCluster:@"triangle" AndColor:@"blue" AndScore:[NSNumber numberWithInt:100]]];
    [triangle addObject:[[Player alloc] initWithRFID:@"1623683"  AndCluster:@"triangle" AndColor:@"green" AndScore:[NSNumber numberWithInt:100]]];
    [triangle addObject:[[Player alloc] initWithRFID:@"1623624"  AndCluster:@"triangle" AndColor:@"yellow" AndScore:[NSNumber numberWithInt:100]]];
    [triangle addObject:[[Player alloc] initWithRFID:@"1623352"  AndCluster:@"triangle" AndColor:@"orange" AndScore:[NSNumber numberWithInt:100]]];
    
    [square addObject:[[Player alloc] initWithRFID:@"1623678"  AndCluster:@"square" AndColor:@"red" AndScore:[NSNumber numberWithInt:30]]];
    [square addObject:[[Player alloc] initWithRFID:@"1623663"  AndCluster:@"square" AndColor:@"blue" AndScore:[NSNumber numberWithInt:30]]];
    [square addObject:[[Player alloc] initWithRFID:@"1623302"  AndCluster:@"square" AndColor:@"green" AndScore:[NSNumber numberWithInt:30]]];
    [square addObject:[[Player alloc] initWithRFID:@"1623303"  AndCluster:@"square" AndColor:@"yellow" AndScore:[NSNumber numberWithInt:30]]];
    [square addObject:[[Player alloc] initWithRFID:@"1623126"  AndCluster:@"square" AndColor:@"orange" AndScore:[NSNumber numberWithInt:30]]];

    [circle addObject:[[Player alloc] initWithRFID:@"1623238"  AndCluster:@"circle" AndColor:@"red" AndScore:[NSNumber numberWithInt:40]]];
    [circle addObject:[[Player alloc] initWithRFID:@"1623257"  AndCluster:@"circle" AndColor:@"blue" AndScore:[NSNumber numberWithInt:40]]];
    [circle addObject:[[Player alloc] initWithRFID:@"1623210"  AndCluster:@"circle" AndColor:@"green" AndScore:[NSNumber numberWithInt:40]]];
    [circle addObject:[[Player alloc] initWithRFID:@"1623305"  AndCluster:@"circle" AndColor:@"yellow" AndScore:[NSNumber numberWithInt:40]]];
    [circle addObject:[[Player alloc] initWithRFID:@"1623386"  AndCluster:@"circle" AndColor:@"orange" AndScore:[NSNumber numberWithInt:40]]];
    
    [star addObject:[[Player alloc] initWithRFID:@"1623392"  AndCluster:@"star" AndColor:@"red" AndScore:[NSNumber numberWithInt:50]]];
    [star addObject:[[Player alloc] initWithRFID:@"1623115"  AndCluster:@"star" AndColor:@"blue" AndScore:[NSNumber numberWithInt:50]]];
    [star addObject:[[Player alloc] initWithRFID:@"1623373"  AndCluster:@"star" AndColor:@"green" AndScore:[NSNumber numberWithInt:50]]];
    [star addObject:[[Player alloc] initWithRFID:@"1623110"  AndCluster:@"star" AndColor:@"yellow" AndScore:[NSNumber numberWithInt:50]]];
    [star addObject:[[Player alloc] initWithRFID:@"1623667"  AndCluster:@"star" AndColor:@"orange" AndScore:[NSNumber numberWithInt:50]]];


    [players addObject:[[Player alloc] initWithRFID:@"1623365"  AndCluster:@"triangle" AndColor:@"red" AndScore:[NSNumber numberWithInt:0]]];
    [players addObject:[[Player alloc] initWithRFID:@"1623641"  AndCluster:@"triangle" AndColor:@"blue" AndScore:[NSNumber numberWithInt:0]]];
    [players addObject:[[Player alloc] initWithRFID:@"1623683"  AndCluster:@"triangle" AndColor:@"green" AndScore:[NSNumber numberWithInt:0]]];
    [players addObject:[[Player alloc] initWithRFID:@"1623624"  AndCluster:@"triangle" AndColor:@"yellow" AndScore:[NSNumber numberWithInt:0]]];
    [players addObject:[[Player alloc] initWithRFID:@"1623352"  AndCluster:@"triangle" AndColor:@"orange" AndScore:[NSNumber numberWithInt:0]]];
    
    [players addObject:[[Player alloc] initWithRFID:@"1623678"  AndCluster:@"square" AndColor:@"red" AndScore:[NSNumber numberWithInt:0]]];
    [players addObject:[[Player alloc] initWithRFID:@"1623663"  AndCluster:@"square" AndColor:@"blue" AndScore:[NSNumber numberWithInt:0]]];
    [players addObject:[[Player alloc] initWithRFID:@"1623302"  AndCluster:@"square" AndColor:@"green" AndScore:[NSNumber numberWithInt:0]]];
    [players addObject:[[Player alloc] initWithRFID:@"1623303"  AndCluster:@"square" AndColor:@"yellow" AndScore:[NSNumber numberWithInt:0]]];
    [players addObject:[[Player alloc] initWithRFID:@"1623126"  AndCluster:@"square" AndColor:@"orange" AndScore:[NSNumber numberWithInt:0]]];
    
    [players addObject:[[Player alloc] initWithRFID:@"1623238"  AndCluster:@"circle" AndColor:@"red" AndScore:[NSNumber numberWithInt:0]]];
    [players addObject:[[Player alloc] initWithRFID:@"1623257"  AndCluster:@"circle" AndColor:@"blue" AndScore:[NSNumber numberWithInt:0]]];
    [players addObject:[[Player alloc] initWithRFID:@"1623210"  AndCluster:@"circle" AndColor:@"green" AndScore:[NSNumber numberWithInt:0]]];
    [players addObject:[[Player alloc] initWithRFID:@"1623305"  AndCluster:@"circle" AndColor:@"yellow" AndScore:[NSNumber numberWithInt:0]]];
    [players addObject:[[Player alloc] initWithRFID:@"1623386"  AndCluster:@"circle" AndColor:@"orange" AndScore:[NSNumber numberWithInt:0]]];
    
    [players addObject:[[Player alloc] initWithRFID:@"1623392"  AndCluster:@"star" AndColor:@"red" AndScore:[NSNumber numberWithInt:0]]];
    [players addObject:[[Player alloc] initWithRFID:@"1623115"  AndCluster:@"star" AndColor:@"blue" AndScore:[NSNumber numberWithInt:0]]];
    [players addObject:[[Player alloc] initWithRFID:@"1623373"  AndCluster:@"star" AndColor:@"green" AndScore:[NSNumber numberWithInt:0]]];
    [players addObject:[[Player alloc] initWithRFID:@"1623110"  AndCluster:@"star" AndColor:@"yellow" AndScore:[NSNumber numberWithInt:0]]];
    [players addObject:[[Player alloc] initWithRFID:@"1623667"  AndCluster:@"star" AndColor:@"orange" AndScore:[NSNumber numberWithInt:0]]];
    
}

#pragma mark - data access methods

-(void)resetPlayerCount {
    [clusters removeAllObjects];
}

- (int)playerCount {
    return [players count];
}

- (int)playerCountWithId: (NSString *)plotId {
    NSArray *cluster = [clusters objectForKey:plotId];
    return cluster.count;
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

-(NSNumber *)scoreForRFID:(NSString *)rfid {
    for (int i = 0; i < [players count]; i++) {
        Player *p = [players objectAtIndex: i];
        if([p.rfid isEqualToString:rfid]){
            return p.score;
        }
    }
    return nil;
}

-(void)resetScoreWithRFID:  (NSString *)rfid {
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

-(NSString *)colorForKey: (NSUInteger)key {
    Player *player = [players objectAtIndex:key];
    return player.color;
}

-(NSNumber *)scoreForKey: (NSUInteger)key andCluster:(NSString *)cluster {
    
    NSArray *c = [clusters objectForKey:cluster];
    
    if( key > c.count-1)
        return [NSNumber numberWithInt:-1 ];
    
    Player *player = [c objectAtIndex:key];
    
    if( [player.cluster isEqualToString:cluster] )
        return player.score;
    
    return [NSNumber numberWithInt:-1 ];
}



@end
