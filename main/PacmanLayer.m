//
//  PacmanLayer.m
//  Pacman
//
//  Created by Romain Vincens on 08/03/2011.
//  Copyright 2011 Nomad Planet. All rights reserved.
//

#import "PacmanLayer.h"


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
            self.isON = other.isON;
            self.pacColor = other.pacColor;
            self.isHAPPY = other.isHAPPY;
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

-(void)drawSmiley: (CGContextRef) context {
    
#define DEFAULT_SCALE 0.2

    CGFloat scale = DEFAULT_SCALE;
    
    CGFloat radius = fmin(self.bounds.size.width, self.bounds.size.height)/2;
    
	CGPoint midpoint = CGPointMake(CGRectGetWidth(self.bounds)/2, CGRectGetHeight(self.bounds)/2);
    
   
    CGFloat faceSize;
    if (self.bounds.size.width < self.bounds.size.height) {
        faceSize = self.bounds.size.width / 2 * scale;
    } else {
        faceSize = self.bounds.size.height / 2 * scale;
    }
    
    CGContextSetLineWidth(context, 5);
    [[UIColor blueColor] setStroke];
    
    CGContextAddArc(context, midpoint.x, midpoint.y, 30, 0, 360, 0);
    
    //[self drawCircleAtPoint:midpoint withRadius:30 inContext:context];
    
#define EYE_H 0.35
#define EYE_V 0.35
#define EYE_RADIUS 0.10
    
    CGPoint eyePoint;
    eyePoint.x = midpoint.x - faceSize * EYE_H;
    eyePoint.y = midpoint.y - faceSize * EYE_V;
    
    [self drawCircleAtPoint:eyePoint withRadius:faceSize * EYE_RADIUS inContext:context]; // left eye
    eyePoint.x += faceSize * EYE_H * 2;
    [self drawCircleAtPoint:eyePoint withRadius:faceSize * EYE_RADIUS inContext:context]; // right eye
    
#define MOUTH_H 0.45
#define MOUTH_V 0.40
#define MOUTH_SMILE 0.25
    
    CGPoint mouthStart;
    mouthStart.x = midpoint.x - MOUTH_H * faceSize;
    mouthStart.y = midpoint.y + MOUTH_V * faceSize;
    CGPoint mouthEnd = mouthStart;
    mouthEnd.x += MOUTH_H * faceSize * 2;
    CGPoint mouthCP1 = mouthStart;
    mouthCP1.x += MOUTH_H * faceSize * 2/3;
    CGPoint mouthCP2 = mouthEnd;
    mouthCP2.x -= MOUTH_H * faceSize * 2/3;
    
   // float smile = [self.dataSource smileForFaceView:self];
    //if (smile < -1) smile = -1;
    //if (smile > 1) smile = 1;
    
    float smile = 1;
    
    CGFloat smileOffset = MOUTH_SMILE * faceSize * smile;
    mouthCP1.y += smileOffset;
    mouthCP2.y += smileOffset;
    
    CGContextBeginPath(context);
    CGContextMoveToPoint(context, mouthStart.x, mouthStart.y);
    CGContextAddCurveToPoint(context, mouthCP1.x, mouthCP2.y, mouthCP2.x, mouthCP2.y, mouthEnd.x, mouthEnd.y); // bezier curve
    CGContextStrokePath(context);
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
    
    
    CGFloat _innerRadius = radius - 3.0f;
    
    if( _isFILLED == NO ) {
    
            CGContextMoveToPoint(ctx, centerPoint.x, centerPoint.y);
            CGContextAddArc(ctx, centerPoint.x, centerPoint.y, radius-3, 0, 360, 0);
            CGContextClosePath(ctx);
    
            /* Filling it */
            CGContextSetFillColorWithColor(ctx, [UIColor blackColor].CGColor);
            CGContextFillPath(ctx);
    }
 
    
    if (_isSMILE) {
        
#define EYE_H .35
#define EYE_V 0.2
#define EYE_RADIUS 0.1
        
        if(_isHAPPY) {
        
            
            
            CGFloat faceSize = radius;
            
            CGPoint eyePoint;
            eyePoint.x = centerPoint.x - faceSize * EYE_H;
            eyePoint.y = centerPoint.y - faceSize * EYE_V;
            
            // move the pen to the starting point
            CGContextMoveToPoint(ctx, eyePoint.x , eyePoint.y);
            // draw a line to another point
            CGContextAddLineToPoint(ctx, eyePoint.x, centerPoint.y);
            
            CGContextStrokePath(ctx);
            
            
            eyePoint.x += faceSize * EYE_H * 2;
            
            // move the pen to the starting point
            CGContextMoveToPoint(ctx, eyePoint.x , eyePoint.y);
            CGContextAddLineToPoint(ctx, eyePoint.x, centerPoint.y);
        } else {
        

        
        
        // move the pen to the starting point
        CGContextMoveToPoint(ctx, centerPoint.x-10, centerPoint.y+7);
        
        // draw a line to another point
        CGContextAddLineToPoint(ctx, centerPoint.x+10, centerPoint.y+7);
        CGContextStrokePath(ctx);
        
        
        
        CGFloat faceSize = radius;
        
        CGPoint eyePoint;
        eyePoint.x = centerPoint.x - faceSize * EYE_H;
        eyePoint.y = centerPoint.y - faceSize * EYE_V;
        
        // move the pen to the starting point
        CGContextMoveToPoint(ctx, eyePoint.x , eyePoint.y);
        // draw a line to another point
        CGContextAddLineToPoint(ctx, eyePoint.x+2, centerPoint.y+2);
        
        CGContextMoveToPoint(ctx, eyePoint.x , eyePoint.y);
        
        CGContextAddLineToPoint(ctx, eyePoint.x+2, centerPoint.y-8);
        
        CGContextMoveToPoint(ctx, eyePoint.x , eyePoint.y);
        CGContextAddLineToPoint(ctx, eyePoint.x-2, centerPoint.y-8);
        CGContextMoveToPoint(ctx, eyePoint.x , eyePoint.y);
        CGContextAddLineToPoint(ctx, eyePoint.x-2, centerPoint.y+2);
        CGContextStrokePath(ctx);
        
        
        eyePoint.x += faceSize * EYE_H * 2;
        
        // move the pen to the starting point
        CGContextMoveToPoint(ctx, eyePoint.x , eyePoint.y);
        // draw a line to another point
        CGContextAddLineToPoint(ctx, eyePoint.x+2, centerPoint.y+2);
        
        CGContextMoveToPoint(ctx, eyePoint.x , eyePoint.y);
        
        CGContextAddLineToPoint(ctx, eyePoint.x+2, centerPoint.y-8);
        
        CGContextMoveToPoint(ctx, eyePoint.x , eyePoint.y);
        CGContextAddLineToPoint(ctx, eyePoint.x-2, centerPoint.y-8);
        CGContextMoveToPoint(ctx, eyePoint.x , eyePoint.y);
        CGContextAddLineToPoint(ctx, eyePoint.x-2, centerPoint.y+2);
        CGContextStrokePath(ctx);
        }
        
        //    // move the pen to the starting point
        //    CGContextMoveToPoint(ctx, eyePoint.x , eyePoint.y);
        //    // draw a line to another point
        //    CGContextAddLineToPoint(ctx, eyePoint.x+2, centerPoint.y-2);
        //
        //    // move the pen to the starting point
        //    CGContextMoveToPoint(ctx, eyePoint.x , eyePoint.y);
        //    // draw a line to another point
        //    CGContextAddLineToPoint(ctx, eyePoint.x-2, centerPoint.y+2);
        //    CGContextStrokePath(ctx);
        
        
        
        
        //[self drawCircleAtPoint:eyePoint withRadius:faceSize * EYE_RADIUS inContext:ctx]; // left eye
        
        //[self drawCircleAtPoint:eyePoint withRadius:faceSize * EYE_RADIUS inContext:ctx]; // right eye
        
#define MOUTH_H 0.45
#define MOUTH_V 0.40
#define MOUTH_SMILE 0.25
        
        // move the pen to the starting point
        CGContextMoveToPoint(ctx, centerPoint.x-10, centerPoint.y+7);
        
        // draw a line to another point
        CGContextAddLineToPoint(ctx, centerPoint.x+10, centerPoint.y+7);
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
