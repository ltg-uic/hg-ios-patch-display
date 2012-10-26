//
//  Created by Anthony Perritano on 9/14/12.
//  Copyright (c) 2012 Learning Technologies Group. All rights reserved.
//

#import "Player.h"
#import "DataStore.h"
#import "DDLog.h"
#import "DDTTYLogger.h"

@implementation DataStore

static NSMutableDictionary *dataPoints;
static NSMutableArray *players;
static NSMutableArray *clusters;

NSString *lastCluster;


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
        [self initCollections];
    }
    return self;
}

-(void)initCollections {
    dataPoints = [NSMutableDictionary dictionary];
    players = [NSMutableArray array];
    clusters = [NSMutableArray array];
}

#pragma mark - data access methods

- (void)resetPlayerCount {
    [players removeAllObjects];
}

- (int)playerCount {
    return [players count];
}

- (NSMutableArray *)clusterLabels {
    return clusters;
}

- (int)clusterCountWith: (NSString *)label {
    int i = 0;
    for (Player *p in players) {

        if( [p.cluster isEqualToString:label] ) {
            i++;
        }
    }
    return i;
}


- (void)addScore: (NSNumber *)score WithIndex: (NSNumber *)index {
    Player *p = [players objectAtIndex:[index intValue]];
    p.score = [NSNumber numberWithDouble:[p.score doubleValue] + [score doubleValue]];
}

- (void)addPlayerWithRFID:(NSString *)rfid withCluster:(NSString *)cluster withColor:(NSString *)color {
    
    [players addObject:[[Player alloc] initWithRFID:rfid  AndCluster:cluster AndColor:color AndScore:[NSNumber numberWithInt:0]]];
    
    //sort the array
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"cluster" ascending:TRUE];
    NSSortDescriptor *rfidDescriptor = [[NSSortDescriptor alloc] initWithKey:@"rfid" ascending:YES];

    [players sortUsingDescriptors:[NSArray arrayWithObjects:sortDescriptor, rfidDescriptor, nil]];
}

- (void)addPlayerSpacing {
    for (int i = 0; i < [players count]; i++) {
        Player *player = [players objectAtIndex: i];
        
        if( lastCluster == nil ) {
            lastCluster = player.cluster;
            [clusters addObject:lastCluster];
        } else if( ![lastCluster isEqualToString:player.cluster] ) {
            lastCluster = player.cluster;
            [clusters addObject:lastCluster];
            [players insertObject:[[Player alloc] initWithRFID:@"" AndCluster:@"" AndColor:@"blank" AndScore:0] atIndex:i];
        };

    }
}

- (void)printPlayers {
    NSLog(@"PRINTING LOCAL DB");
    for (Player *player in players) {
       NSLog(@"%@\n", [player description]);
        
    }
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

- (NSNumber *)scoreForRFID:(NSString *)rfid {
    for (int i = 0; i < [players count]; i++) {
        Player *p = [players objectAtIndex: i];
        if([p.rfid isEqualToString:rfid]){
            return p.score;
        }
    }
    return nil;
}

- (void)resetScoreWithRFID:  (NSString *)rfid {
    for (int i = 0; i < [players count]; i++) {
        Player *p = [players objectAtIndex: i];
        if([p.rfid isEqualToString:rfid]){
            p.score = 0;
            break;
        }
    }
}

- (NSNumber *)scoreForKey: (NSUInteger)key {
    Player *player = [players objectAtIndex:key];
    return player.score;
}

- (NSString *)colorForKey: (NSUInteger)key {
    Player *player = [players objectAtIndex:key];
    return player.color;
}

- (NSArray *)datesInMonth
{
    static NSArray *dates = nil;
    if (!dates)
    {
        dates = [NSArray arrayWithObjects:
                 @"2",
                 @"3",
                 @"4",
                 @"5",
                 @"9",
                 @"10",
                 @"11",
                 @"12",
                 @"13",
                 @"16",
                 @"17",
                 @"18",
                 @"19",
                 @"20",
                 @"23",
                 @"24",
                 @"25",
                 @"26",
                 @"27",
                 @"30",
                 nil];
    }
    return dates;
}


@end
