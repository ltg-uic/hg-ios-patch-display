//
//  EstimoteDelegate.m
//  hg-ios-patch-display
//
//  Created by PauloGF on 4/14/14.
//  Copyright (c) 2014 Learning Technologies Group. All rights reserved.
//

#import "EstimoteDelegate.h"
#import "Beacon.h"
#import <ESTBeaconManager.h>
#import "AppDelegate.h"
#import "PatchInfo.h"

@interface EstimoteDelegate () <ESTBeaconManagerDelegate>

@property (nonatomic, strong) ESTBeaconManager* beaconManager;
@property (nonatomic, strong) ESTBeacon* selectedBeacon;
@property (strong,  nonatomic) AppDelegate *appDelegate;


@end

@implementation EstimoteDelegate


-(void)initEstimoteManager{
    /////////////////////////////////////////////////////////////
    // setup Estimote beacons manager
    NSLog(@"Setting up estimote manager");
    
    _appDelegate = (AppDelegate*)[[UIApplication sharedApplication]delegate];
    
    // craete manager instance
    self.beaconManager = [[ESTBeaconManager alloc] init];
    self.beaconManager.delegate = self;
    
    // create sample region object (you can additionaly pass major / minor values)
    ESTBeaconRegion* region = [[ESTBeaconRegion alloc] initWithProximityUUID:ESTIMOTE_PROXIMITY_UUID                                                             identifier:@"EstimoteSampleRegion"];
    
    // start looking for estimote beacons in region
    // when beacon ranged beaconManager:didRangeBeacons:inRegion: is invoked
    [self.beaconManager startRangingBeaconsInRegion:region];
}

//beaconManager:didRangeBeacons:inRegion gets invoke whenever a beacon is in range
-(void)beaconManager:(ESTBeaconManager *)manager
     didRangeBeacons:(NSArray *)beacons
            inRegion:(ESTBeaconRegion *)region
{
    if(_readEstimoteBeacons){
        //update estimotes label
//        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
//            self.numberOfEstimoteBeacons.text = [NSString stringWithFormat:@"%lu", (unsigned long)[beacons count]];
//        }];
        
        //count number of beacons in patch range
        for (ESTBeacon* cBeacon in beacons)
        {
            
            self.selectedBeacon = cBeacon;
            float distFactor = ((float)self.selectedBeacon.rssi + 30) / -70;
            if( distFactor < .50 ) {
                NSLog(@"Estimote Beacon sighting in Patch received %@ . RSSI: %ld Time: %@", self.selectedBeacon.minor.stringValue, (long)self.selectedBeacon.rssi, [NSDate dateWithTimeIntervalSince1970:0]);
                //Generate beacon from ID and check if exists already
                Beacon *beacon = [self beaconForID: self.selectedBeacon.minor.stringValue];
                if (!beacon) {
                    NSString *beaconName = [NSString stringWithFormat:@"EST%@", self.selectedBeacon.minor];
                    beacon = [Beacon new];
                    beacon.identifier = self.selectedBeacon.minor.stringValue;
                    beacon.name = beaconName;
                    beacon.lastSighted = [NSNumber numberWithLong:(long)[NSDate timeIntervalSinceReferenceDate]*1000];
                    beacon.rssi = [NSNumber numberWithInteger:self.selectedBeacon.rssi];
                    beacon.type = @"ESTIMOTE";
                    
                    NSLog(@"adding beacon");
                    [self addBeacon:beacon];
                    NSString *lower = [_appDelegate.currentPatchInfo.patch_id lowercaseString];
                    
                    NSString *msg = [NSString stringWithFormat:@"{\"event\":\"rfid_update\",\"payload\":{\"id\":\"%@\",\"arrival\":\"%@\",\"departure\":\"\"}}", beacon.identifier, lower];
                    NSLog(msg);
                    
                    [_appDelegate processXmppMessage:msg];
                    //generate arrival message
                }
                else{
                    beacon.lastSighted = [NSNumber numberWithLong:(long)[NSDate timeIntervalSinceReferenceDate]*1000];
                    beacon.rssi = [NSNumber numberWithInteger:self.selectedBeacon.rssi];
                }
            }//end if
        }// end for
        //update label
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [self checkBeaconsAges];
        }];
        
//        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
//            self.numberOfEstimoteBeaconsInPatch.text = [NSString stringWithFormat:@"%ld", (long)[self estimoteBeaconsInPatch]];
//        }];
        
        
    }
//    else{
//        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
//            self.numberOfEstimoteBeacons.text = [NSString stringWithFormat:@"%d", 0];
//        }];
//    }
}

#pragma mark - beaconsArray manipulation
- (void)addBeacon: (Beacon *)beacon{
    @synchronized(self.beaconsInPatch){
        [self.beaconsInPatch addObject:beacon];
    }
}

- (Beacon *)beaconForID:(NSString *)ID {
    for (Beacon *beacon in self.beaconsInPatch) {
        if ([beacon.identifier isEqualToString:ID]) {
            NSLog(@"Beacon found");
            return beacon;
        }
    }
    return nil;
}

- (void)initializeTransmitters {
    @synchronized(self.beaconsInPatch){
        if (self.beaconsInPatch == nil) {
            self.beaconsInPatch = [NSMutableArray new];
        }
    }
}

- (void)clearBeacons {
    @synchronized(self.beaconsInPatch){
        [self.beaconsInPatch removeAllObjects];
    }
}

- (void)removeBeacons: (Beacon*)beacon {
    NSInteger count = 0;
    @synchronized(self.beaconsInPatch){
        [self.beaconsInPatch removeObject:beacon];
        count =[self.beaconsInPatch count];
    }
    NSLog(@"Removing beacon");
}

- (BOOL)isBeaconAgedOut:(Beacon *)beacon {
    NSNumber *now = [NSNumber numberWithLong:(long)[NSDate timeIntervalSinceReferenceDate]*1000];
    NSNumber *ageOutPeriod = [NSNumber numberWithLong:1500];
    if (now.longLongValue-beacon.lastSighted.longLongValue > ageOutPeriod.longLongValue) {
        return YES;
    }
    return NO;
}

- (void)checkBeaconsAges {
    for(Beacon *beacon in self.beaconsInPatch){
        if([self isBeaconAgedOut:beacon]){
            [self removeBeacons:beacon];
            break;
        }
    }
    NSLog(@"Time:%li", (long)[NSDate timeIntervalSinceReferenceDate]*1000);
    
//    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
//        self.numberOfEstimoteBeaconsInPatch.text = [NSString stringWithFormat:@"%ld", (long)[self estimoteBeaconsInPatch]];
//    }];
}




@end