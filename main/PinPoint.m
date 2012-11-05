//
//  PinPoint.m
//  DrawingForaging
//
//  Created by Anthony Perritano on 11/3/12.
//  Copyright (c) 2012 Learning Technologies Group. All rights reserved.
//

#import "PinPoint.h"
#import "UIColor-Expanded.h"

@implementation PinPoint

float radius = 0;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        radius = frame.size.width;
        _isON = YES;
        _isFILLED = NO;
    }
    return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    float dRed=0.0f;
    float dGreen=0.0f;
    float dBlue=0.0f;
    
    float lRed=0.0f;
    float lGreen=0.0f;
    float lBlue=0.0f;
 
    float _outerRadius=radius;
    float _innerRadius=radius-3;
    
    
    // Create the context
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //Make sure the remove the anti-alias effect from circle
    CGContextSetAllowsAntialiasing(context, true);
    CGContextSetShouldAntialias(context, true);
    
    // Set the border width
	CGContextSetLineWidth(context, 5.0);
	
	// Set the border color to RED
	CGContextSetRGBStrokeColor(context, 255.0, 0.0, 0.0, 1.0);
	
	// Draw the border along the view edge
	//CGContextStrokeRect(context, rect);
    
    if( ! _isON ) {
    
        //orange
        dRed=0.0f;
        dGreen=0.0f;
        dBlue=0.0f;
        
        lRed=0.0f;
        lGreen=0.0f;
        lBlue=0.0f;
    
    } else {
        //gray
        dRed=[[UIColor whiteColor] red];
        dGreen=[[UIColor whiteColor] green];
        dBlue=[[UIColor whiteColor] blue];
        
        lRed=[_color red];
        lGreen=[_color green];
        lBlue=[_color blue];
    }

    CGContextAddArc(context, _outerRadius/2, _outerRadius/2, _outerRadius/2, 0, 360, 0);
    CGContextClip(context);
    
    //Create the gradient
    CGGradientRef glossGradient;
    CGColorSpaceRef rgbColorspace;
    size_t num_locations = 2;
    CGFloat locations[2] = { 0.5, 1.0 };
    CGFloat components[8] = { lRed, lGreen, lBlue, 1.0 ,   // Start color
        dRed, dGreen, dBlue, .9}; // Mid color and End color
    rgbColorspace = CGColorSpaceCreateDeviceRGB();
    glossGradient = CGGradientCreateWithColorComponents(rgbColorspace, components, locations, num_locations);
    
    //Draw the gradient
    
    CGPoint start = CGPointMake(_outerRadius,self.center.y);
    CGPoint end = CGPointMake(_outerRadius,self.center.y);
    CGContextDrawLinearGradient(context, glossGradient, start, end, kCGGradientDrawsBeforeStartLocation);
    
    if( ! _isFILLED ) {
        
        //Draw the hole to make it look like doughnut
        CGContextSetFillColorWithColor( context, [UIColor clearColor].CGColor );
        CGContextSetBlendMode(context, kCGBlendModeClear);
        CGRect holeRect= CGRectMake((_outerRadius-_innerRadius)/2, (_outerRadius-_innerRadius)/2, _innerRadius, _innerRadius);
        CGContextFillEllipseInRect( context, holeRect );
    }
    
}

@end
