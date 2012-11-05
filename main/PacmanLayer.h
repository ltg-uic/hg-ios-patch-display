//
//  PacmanLayer.h
//  Pacman
//
//  Created by Romain Vincens on 08/03/2011.
//  Copyright 2011 Nomad Planet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>


@interface PacmanLayer : CALayer {
	CGFloat	startAngle;
	CGFloat endAngle;
}

@property (nonatomic, assign)	CGFloat	startAngle;
@property (nonatomic, assign)	CGFloat	endAngle;
@property (nonatomic, retain)	UIColor	*pacColor;
@property (nonatomic, assign)   BOOL isON;
@property (nonatomic, assign)   BOOL isFILLED;
@property (nonatomic, assign)   BOOL isCOMPING;
@property (nonatomic, assign)   BOOL isSMILE;

- (id) lastValueForKey:(NSString*)key;

@end
