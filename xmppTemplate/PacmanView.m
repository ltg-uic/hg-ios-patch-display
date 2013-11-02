//
//  PacmanView.m
//  Pacman
//
//  Created by Romain Vincens on 08/03/2011.
//  Copyright 2011 Nomad Planet. All rights reserved.
//

#import "PacmanView.h"
#import "UIView+Animation.h"

#define ANIM_MOUTH_DURATION	0.2
#define ANIM_KILL_DURATION	0.9

#define PAC_OPEN			35.0
#define PAC_CLOSE			0.0
#define PAC_KILL			180.0

@interface PacmanView ()

- (CABasicAnimation*) _animationForKeyPath:(NSString*)keyPath fromValue:(NSNumber*)fromValue toValue:(NSNumber*)toValue;
- (void) _animateToAngle:(CGFloat)angle;
- (void) _openMouth;
- (void) _closeMouth;

@end


@implementation PacmanView

#pragma mark -
#pragma mark UIView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.frame = frame;
        self.backgroundColor = [UIColor clearColor];
        self.opaque = YES;
        animating = NO;
        
        PacmanLayer *pl = [[PacmanLayer alloc] init];
        pl.needsDisplayOnBoundsChange = YES;
        pl.frame = self.bounds;
        pl.startAngle = PAC_OPEN;
        pl.endAngle = 360.0 - PAC_OPEN;
        _pacmanLayer = pl;

        
        [self.layer addSublayer:_pacmanLayer];
        
    }
    return self;
}

- (id) initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if( self ) {
        self.backgroundColor = [UIColor clearColor];
        self.opaque = YES;
        animating = NO;
        _pacmanLayer = [[PacmanLayer alloc] init];
        _pacmanLayer.pacColor = [UIColor clearColor];
        _pacmanLayer.needsDisplayOnBoundsChange = YES;
        _pacmanLayer.frame = self.bounds;
        _pacmanLayer.startAngle = PAC_OPEN;
        _pacmanLayer.endAngle = 360.0 - PAC_OPEN;
        
        
        [self.layer addSublayer:_pacmanLayer];
        
    }
    return self;
}




#pragma mark -
#pragma mark Internal

- (CABasicAnimation*) _animationForKeyPath:(NSString*)keyPath 
								 fromValue:(NSNumber*)fromValue 
								   toValue:(NSNumber*)toValue {
	
	CAMediaTimingFunction *timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
	
	CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:keyPath];
	anim.fromValue = fromValue;
	anim.toValue = toValue;
	anim.timingFunction = timingFunction;
	return anim;
}

- (void) _animateToAngle:(CGFloat)angle {
	// Get current presentation layer values
	NSNumber *sAngle = [_pacmanLayer lastValueForKey:@"startAngle"];
	NSNumber *eAngle = [_pacmanLayer lastValueForKey:@"endAngle"];
	
	// Create animations
	CABasicAnimation *animStartAngle = [self _animationForKeyPath:@"startAngle" fromValue:sAngle toValue:[NSNumber numberWithFloat:angle]];
	CABasicAnimation *animEndAngle = [self _animationForKeyPath:@"endAngle" fromValue:eAngle toValue:[NSNumber numberWithFloat:360.0 - angle]];

	// Start animations
	[_pacmanLayer addAnimation:animStartAngle forKey:@"animateStartAngle"];	
	[_pacmanLayer addAnimation:animEndAngle forKey:@"animateEndAngle"];	
	
	// Put layer to final state
	[_pacmanLayer setValue:[NSNumber numberWithFloat:angle] forKey:@"startAngle"];
	[_pacmanLayer setValue:[NSNumber numberWithFloat:360.0 - angle] forKey:@"endAngle"];
}

- (void) _openMouth {
	if(killing)
		return;
	
	[CATransaction begin];
	[CATransaction setAnimationDuration:ANIM_MOUTH_DURATION];
	[CATransaction setAnimationTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
	[CATransaction setCompletionBlock:^{
		[self _closeMouth];
	}];
	
	[self _animateToAngle:PAC_OPEN];
	
	[CATransaction commit];
}

- (void) _closeMouth {
    
    
    
	if(!animating) {
		return;
    }
	
	if(killing)
		return;
	
	[CATransaction begin];
	[CATransaction setAnimationDuration:ANIM_MOUTH_DURATION];
	[CATransaction setAnimationTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn]];
	[CATransaction setCompletionBlock:^{
		[self _openMouth];
	}];
	
	[self _animateToAngle:PAC_CLOSE];
	
	[CATransaction commit];
}

#pragma mark -
#pragma mark Public API

- (void) animate:(BOOL)animate {
	animating = animate;
	
    if(animate == YES) {
        _pacmanLayer.isCOMPING = YES;
        _pacmanLayer.isFILLED = YES;
        //[_pacmanLayer display];
    } else {
        _pacmanLayer.isCOMPING = NO;
        _pacmanLayer.isFILLED = YES;
        
    }
    
	if(animating) {	
		[self _closeMouth];
	}
}

- (void) die:(BOOL)isDead {
	
	
    if(isDead) {
        [self animate:NO];
        _pacmanLayer.isCOMPING = NO;
        _pacmanLayer.isFILLED = YES;
        _pacmanLayer.isSMILE = YES;
        [_pacmanLayer setNeedsDisplay];
    } else {
        _pacmanLayer.isON = YES;
        _pacmanLayer.isCOMPING = NO;
        _pacmanLayer.isFILLED = NO;
        
    }
    
	if(animating) {
		[self _closeMouth];
	}
}

- (void) collapse {
	if(killing)
		return;
	
	animating = NO;
	killing = YES;
	
	[CATransaction begin];
	[CATransaction setAnimationDuration:ANIM_KILL_DURATION];
	[CATransaction setAnimationTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
	[CATransaction setCompletionBlock:^{
		killing = NO;
        [self afterCollapse];
	}];
	[self _animateToAngle:PAC_KILL];
	[CATransaction commit];
}

- (void) collapseLeave {
	
	[CATransaction begin];
	[CATransaction setAnimationDuration:.3];
	[CATransaction setAnimationTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
	[CATransaction setCompletionBlock:^{
		
        [self afterCollapseLeave];
      
        
	}];
	//[self _animateToAngle:PAC_KILL];
	[CATransaction commit];
}

- (void) collapseDead {
	
	
	animating = NO;
	
	
	[CATransaction begin];
	[CATransaction setAnimationDuration:.3];
	[CATransaction setAnimationTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
	[CATransaction setCompletionBlock:^{
		
        [self afterCollapseLeave];
        
        
	}];
	[self _animateToAngle:PAC_KILL];
	[CATransaction commit];
}

-(void) afterCollapseLeave {
    
    
    animating = NO;

    _pacmanLayer.startAngle = PAC_OPEN;
    _pacmanLayer.endAngle = 360.0 - PAC_OPEN;
    
    [self resetPacmanView];
    

}

-(void)resetPacmanView {
    
    self.player_id = nil;
    [self hideViewWithFadeAnimation:self duration:.4 option:nil];

 
}

-(void) afterCollapse {
    
   // pl.startAngle = PAC_OPEN;
    //pl.endAngle = 360.0 - PAC_OPEN;
    
    [_pacmanLayer setValue:[NSNumber numberWithFloat:0] forKey:@"startAngle"];
    [_pacmanLayer setValue:[NSNumber numberWithFloat:360] forKey:@"endAngle"];
    
    _pacmanLayer.isFILLED = YES;
    _pacmanLayer.isSMILE = YES;
    _pacmanLayer.isHAPPY= NO;
    
    [_pacmanLayer display];
    [_pacmanLayer setNeedsDisplay];
    [self setNeedsDisplay];
}

@end
