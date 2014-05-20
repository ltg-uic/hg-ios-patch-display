//
//  EstimoteDelegate.h
//  hg-ios-patch-display
//
//  Created by PauloGF on 4/14/14.
//  Copyright (c) 2014 Learning Technologies Group. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@interface EstimoteDelegate : NSObject

@property (nonatomic, assign) BOOL readEstimoteBeacons;
@property (nonatomic, assign) float rangeThreshold;
@property (strong, nonatomic) NSMutableArray *beaconsInPatch;

- (void)initEstimoteManager;
@end