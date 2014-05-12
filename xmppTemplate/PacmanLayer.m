//
//  PacmanLayer.m
//  Pacman
//
//  Created by Romain Vincens on 08/03/2011.
//  Copyright 2011 Nomad Planet. All rights reserved.
//

#import "PacmanLayer.h"
#import "UIColor+Expanded.h"

static inline double radians (double degrees) {return degrees * M_PI/180;}


@implementation PacmanLayer

@synthesize startAngle;
@synthesize endAngle;

#pragma mark -
#pragma mark CALayer

- (id)initWithLayer:(id)layer {
	if((self = [super initWithLayer:layer])) {
		if([layer isKindOfClass:[PacmanLayer class]]) {
			PacmanLayer *other = (PacmanLayer*)layer;
			self.startAngle = other.startAngle;
			self.endAngle = other.endAngle;
            self.isCOMPING = other.isCOMPING;
            self.isFILLED = other.isFILLED;
            self.pacColor = other.pacColor;
		}
	}
	return self;
}

+ (BOOL)needsDisplayForKey:(NSString *)key {
	if ([key isEqualToString:@"startAngle"]
		|| [key isEqualToString:@"endAngle"]) {
        return YES;
    }
	else {
        return [super needsDisplayForKey:key];
    }
}

- (void)drawCircleAtPoint:(CGPoint)p
               withRadius:(CGFloat)r
                inContext:(CGContextRef)context
{
    UIGraphicsPushContext(context);
    
    CGContextBeginPath(context);
    CGContextAddArc(context, p.x, p.y, r, 0, 2*M_PI, YES);
    CGContextStrokePath(context);
    
    UIGraphicsPopContext();
}



- (UIColor *) getEyeColorFromColor:(UIColor *) newColor
{
    const CGFloat *componentColors = CGColorGetComponents(newColor.CGColor);
    
    NSLog(@"%@", [newColor hexStringFromColor]);
          
    CGFloat colorBrightness = ((componentColors[0] * 299) + (componentColors[1] * 587) + (componentColors[2] * 114)) / 1000;
    if (colorBrightness < 0.5)
    {
        
        NSLog(@"my color is dark");
        return [UIColor whiteColor];
    }
    else
    {
        NSLog(@"my color is light");
        return [UIColor blackColor];
    }
}

- (void)drawInContext:(CGContextRef)ctx {
	   

 
    
    
	/* Getting some values */
	CGFloat radius = fmin(self.bounds.size.width, self.bounds.size.height)/2;
    
	CGPoint centerPoint = CGPointMake(CGRectGetWidth(self.bounds)/2, CGRectGetHeight(self.bounds)/2);
	CGFloat sAngle = radians(self.startAngle);
	CGFloat eAngle = radians(self.endAngle);
	
	/* Drawing arc */
	CGContextMoveToPoint(ctx, centerPoint.x, centerPoint.y);
    
    if( _isCOMPING )
        CGContextAddArc(ctx, centerPoint.x, centerPoint.y, radius, sAngle, eAngle, 0);
    else
        CGContextAddArc(ctx, centerPoint.x, centerPoint.y, radius, 0, 360, 0);
    
    CGContextClosePath(ctx);
	
	/* Filling it */
    
    
    
	CGContextSetFillColorWithColor(ctx, _pacColor.CGColor);
	CGContextFillPath(ctx);
    
    
    if( _isFILLED == NO ) {
    
            CGContextMoveToPoint(ctx, centerPoint.x, centerPoint.y);
            CGContextAddArc(ctx, centerPoint.x, centerPoint.y, radius-3, 0, 360, 0);
            CGContextClosePath(ctx);
    
            /* Filling it */
            CGContextSetFillColorWithColor(ctx, _pacColor.CGColor);
            CGContextFillPath(ctx);
    }
 
    
    if (_isSMILE) {
        
#define EYE_H .35
#define EYE_V 0.2
#define EYE_RADIUS 0.1

        
        
            CGContextSetStrokeColorWithColor(ctx, [self getEyeColorFromColor:_pacColor].CGColor);
            CGContextSetLineWidth(ctx, 2);
            
            //left eye
        
            // move the pen to the starting point
            CGContextMoveToPoint(ctx, 26.5, 27);
            
            // draw a line to another point
            CGContextAddLineToPoint(ctx, 36.5, 40);
            CGContextStrokePath(ctx);
        
        
            CGContextSetStrokeColorWithColor(ctx, [self getEyeColorFromColor:_pacColor].CGColor);
            CGContextMoveToPoint(ctx, 36.5, 27);
            CGContextAddLineToPoint(ctx, 26.5, 40);
            CGContextStrokePath(ctx);
        
            //right eye
        
            // move the pen to the starting point
            CGContextMoveToPoint(ctx, 58.7, 27);
        
            // draw a line to another point
            CGContextAddLineToPoint(ctx, 68.7, 40);
            CGContextStrokePath(ctx);
        
        
            CGContextSetStrokeColorWithColor(ctx, [self getEyeColorFromColor:_pacColor].CGColor);
            CGContextMoveToPoint(ctx, 68.7, 27);
            CGContextAddLineToPoint(ctx, 58.7, 40);
            CGContextStrokePath(ctx);

        
                 
#define MOUTH_H 0.45
#define MOUTH_V 0.40
#define MOUTH_SMILE 0.25
        
            CGContextSetStrokeColorWithColor(ctx, [self getEyeColorFromColor:_pacColor].CGColor);

        // move the pen to the starting point
        CGContextMoveToPoint(ctx, 25, 62);
        
        // draw a line to another point
        CGContextAddLineToPoint(ctx, 71, 62);
        
        CGContextSetStrokeColorWithColor(ctx, [self getEyeColorFromColor:_pacColor].CGColor);
        CGContextStrokePath(ctx);
        //tongue
        //            CGContextMoveToPoint(ctx, 48, 63);
        //
        //            CGContextAddLineToPoint(ctx, 60, 63);
        //            CGContextAddLineToPoint(ctx, 60, 77);
        //            CGContextAddLineToPoint(ctx, 48, 77);
        //            CGContextMoveToPoint(ctx, 48, 63);
        
        
        
        CGContextSetFillColorWithColor(ctx, [self getEyeColorFromColor:_pacColor].CGColor);
        
        CGContextSetLineWidth(ctx, 1);
        
        CGContextFillRect(ctx, CGRectMake(52, 63, 10.7, 10));
        
        CGContextFillEllipseInRect(ctx, CGRectMake(52.5, 67.6, 10, 10));
        CGContextStrokePath(ctx);


        }
        

    
}

#pragma mark -
#pragma mark Public API

- (id) lastValueForKey:(NSString*)key {
	PacmanLayer *last = (PacmanLayer*)self.presentationLayer;
	return [last valueForKey:key];
}

@end
