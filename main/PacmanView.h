//
//  PacmanView.h
//  Pacman
//
//  Created by Romain Vincens on 08/03/2011.
//  Copyright 2011 Nomad Planet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PacmanLayer.h"


@interface PacmanView : UIView {

	
	BOOL			animating;
	BOOL			killing;
}

@property (nonatomic, assign) BOOL isON;
@property (nonatomic, assign) BOOL isFILLED;
@property (nonatomic, retain) UIColor *color;
@property (nonatomic, retain) PacmanLayer *pacmanLayer;

- (void) animate:(BOOL)animate;
- (void) collapse;
- (void) die:(BOOL)isDead;
@end
