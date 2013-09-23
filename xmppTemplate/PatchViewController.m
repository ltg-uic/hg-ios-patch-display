//
//  ViewController.m
//  SidebarDemo
//
//  Created by Simon on 28/6/13.
//  Copyright (c) 2013 Appcoda. All rights reserved.
//

#import "PatchViewController.h"
#import "PatchInfo.h"
#import "UIColor-Expanded.h"
#import "SWRevealViewController.h"
#import "PacmanView.h"
#import "PinPoint.h"
#import <AudioToolbox/AudioToolbox.h>

@interface PatchViewController () {
    NSArray *patchInfos;
    NSMutableDictionary *playerPacmanViews;
}

@end

@implementation PatchViewController

- (id)initWithCoder:(NSCoder *)aDecoder {
    if(self = [super initWithCoder:aDecoder])
    {
        self.appDelegate.playerDataDelegate = self;
        playerPacmanViews = [[NSMutableDictionary alloc] init];
    }
    return self;
}


#pragma mark - PLAYER DATA DELEGATE

-(void)playerDataDidUpdate {
    [self drawCircleGrid];
}

#pragma mark - Drawing methods

-(void) drawCircleGrid {
    
    float landscapeWidth = 1024.0f;
    float heightOfLandscape = 768.0f;
    float labelHeight = 55.0f;
    
    float circleWidth = 45.0;
    float circleHeight = circleWidth;
    
    
    float circleY = heightOfLandscape - (40 + labelHeight  + circleHeight );
    float circleX = 0;
    
    float xOffset = 6.0f;
    
    
    int numOfViews = [[self playerDataPoints] count];
    
    
    
    circleWidth = floorf(( landscapeWidth/ numOfViews )-xOffset);
    circleHeight = circleWidth;
    
   // float totalViewWidth = ((circleWidth * numOfViews) + (numOfViews * xOffset));
    
    circleX = xOffset;
    
    
    for (PlayerDataPoint *player in [self playerDataPoints]) {
        PacmanView *dv = [[PacmanView alloc] initWithFrame:CGRectMake(circleX, circleY, circleWidth, circleHeight)];
        NSString* cleanedString = [player.color stringByReplacingOccurrencesOfString:@"#" withString:@""];
        
        dv.pacmanLayer.isSMILE = NO;
        
        UIColor *playerColor = [UIColor colorWithHexString:cleanedString];
        
        
        dv.pacmanLayer.pacColor =  playerColor;
        dv.pacmanLayer.isFILLED = NO;
        dv.pacmanLayer.isSMILE = NO;
        dv.pacmanLayer.isHAPPY = NO;
        
//        if (player.rfid.length == 0) {
//            dv.pacmanLayer.isON = NO;
//            
//        }
        //
       // PinPointGroup *pg = [[PinPointGroup alloc] initWithPlayer:player AndPinPoint:dv];
        //
        //[pinPointGroups addObject:pg];
        
        [playerPacmanViews setObject:dv forKey:player.rfid_tag];
        
        [self.view addSubview:dv];
        
        
        circleX = circleWidth + circleX + xOffset;
        
    }
    
    //[self createClusterLabelsWithCircleWidth:circleWidth WithPadding:xOffset];
    
}


-(void)playerDataDidUpdateWithArrival:(NSString *)arrival_patch_id WithDeparture:(NSString *)departure_patch_id WithPlayerDataPoint:(PlayerDataPoint *)playerDataPoint {
    
    
    
}




- (void)viewDidLoad
{
    [super viewDidLoad];

    //self.title = @"News";

    // Change button color
    //_sidebarButton.tintColor = [UIColor colorWithWhite:0.96f alpha:0.2f];

    // Set the side bar button action. When it's tapped, it'll show up the sidebar.
    
    [self.revealButtonItem setTarget: self.revealViewController];
    [self.revealButtonItem setAction: @selector( revealToggle: )];
    [self.navigationController.navigationBar addGestureRecognizer: self.revealViewController.panGestureRecognizer];


    // Set the gesture
    [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    
    
    [self drawCircleGrid];
}

-(void)adjustPlayer: (NSString *)rfid isOn:(BOOL)isOn {
    
    PacmanView *pc = [playerPacmanViews objectForKey:rfid];
    
    
    
    
    if ( pc != nil ) {
        
        if( isOn == YES) {
            pc.pacmanLayer.isHAPPY = NO;
            pc.pacmanLayer.isSMILE = NO;
            pc.pacmanLayer.isFILLED = YES;
        } else {
            pc.pacmanLayer.isHAPPY = NO;
            pc.pacmanLayer.isSMILE = NO;
            pc.pacmanLayer.isFILLED = NO;
        }
        
        [pc animate:isOn];
        [pc.pacmanLayer setNeedsDisplay];
        [pc setNeedsDisplay];
    }
    
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.appDelegate.playerDataDelegate = self;
}

- (AppDelegate *)appDelegate
{
	return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}

-(NSArray *)playerDataPoints {
    
    return [[[[self appDelegate] configurationInfo ] players ] allObjects];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
