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
    NSMutableArray *playerPacmanViews;
    NSMutableArray *playersAtPatch;
    NSTimer *timer;
}

@end

@implementation PatchViewController

- (id)initWithCoder:(NSCoder *)aDecoder {
    if(self = [super initWithCoder:aDecoder])
    {
        self.appDelegate.playerDataDelegate = self;
        playerPacmanViews = [[NSMutableArray alloc] init];
        playersAtPatch = [[NSMutableArray alloc] init];
    }
    return self;
}


#pragma mark - PLAYER DATA DELEGATE

-(void)playerDataDidUpdate {
  
}

-(void)playerDidLeave: (NSString *)player_id {
    
    NSArray *pacmansSearch = [playerPacmanViews filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"player_id == %@", player_id]];
    
    if( pacmansSearch.count > 0 ) {
        PacmanView *pacman = [pacmansSearch objectAtIndex:0];
        
        [pacman collapseLeave];
         [playersAtPatch removeObject:player_id];
        
    }
    
}

-(void)playerDidArrive: (NSString *)player_id {
    [playersAtPatch addObject:player_id];
    
    NSArray *pacmansSearch = [playerPacmanViews filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"player_id == nil"]];
    NSArray *players = [[self.appDelegate playerDataPoints] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"player_id == %@",player_id ]];

    if( pacmansSearch.count > 0 && players.count > 0 ) {
        PacmanView *pacman = [pacmansSearch objectAtIndex:0];
        NSString *aColor = [[players objectAtIndex:0] color];
         UIColor *hexColor = [UIColor colorWithHexString:[aColor stringByReplacingOccurrencesOfString:@"#" withString:@""]];
        pacman.hidden = NO;
        pacman.player_id = player_id;
        pacman.pacmanLayer.pacColor =  hexColor;

        pacman.layer.shadowColor = [[UIColor blackColor] CGColor];
        pacman.layer.shadowOffset = CGSizeMake(1.0, 1.0);
        pacman.layer.shadowOpacity = 0.30;
        [pacman animate:YES];
        [pacman setNeedsDisplay];
        [self updateCalorieLabel];
        
    }
}

-(void)boutReset {
    for (PacmanView *pacman in playerPacmanViews) {
        [pacman resetPacmanView];
        
    }
}

-(void)boutStart {
    [self updateCalorieLabel];
    [self drawCircleGrid];
}

-(void)boutStop {
    for (PacmanView *pacmanView in playerPacmanViews) {
        [pacmanView animate:NO];
    }
    [self updateCalorieLabel];
}

-(void)playerDataDidUpdateWithArrival:(NSString *)arrival_patch_id WithDeparture:(NSString *)departure_patch_id WithPlayerDataPoint:(PlayerDataPoint *)playerDataPoint {
}

#pragma mark - Drawing methods

-(void) drawCircleGrid {
    
    float landscapeWidth = 1024.0f;
    float heightOfLandscape = 768.0f;
    float labelHeight = 55.0f;
    
    float circleWidth = 96.0;
    float circleHeight = circleWidth;
    
    
    float circleY = heightOfLandscape - (80+circleHeight );
    float circleX = 0;
    
    float xOffset = 6.0f;
    
    
    int numOfViews = 14;
    
    
    
    //circleWidth = floorf(( landscapeWidth/ numOfViews )-xOffset);
    circleHeight = circleWidth;
    
    // float totalViewWidth = ((circleWidth * numOfViews) + (numOfViews * xOffset));
    
    circleX = xOffset;
    
    
    for (int i = 0; i < numOfViews; i++) {
        // UIColor *playerColor = [self.appDelegate.colorMap objectForKey:player_id];
        
        // PacmanView *pacman = [playerPacmanViews objectForKey:player_id];
        
        PacmanView *pacman;
        CGRect rect = CGRectMake(circleX, circleY, circleWidth, circleHeight);
        
        
        pacman = [[PacmanView alloc] initWithFrame:rect];

        [pacman resetPacmanView];
        [playerPacmanViews addObject:pacman];
       
        [pacman.pacmanLayer setNeedsDisplay];
        circleX = circleWidth + circleX + xOffset;
        
        [self.view addSubview:pacman];
        [self.view setNeedsDisplay];
        
    }
    
    
    //[self createClusterLabelsWithCircleWidth:circleWidth WithPadding:xOffset];
    
}

-(void)updateCalorieLabel {
    
    float adjustedRichness = 0;
    //calc new richness
    if( playersAtPatch.count == 0 ) {
        adjustedRichness = self.appDelegate.currentPatchInfo.quality_per_minute;
    } else {
        adjustedRichness = (self.appDelegate.currentPatchInfo.quality_per_minute / playersAtPatch.count );
    }
    
    currentYieldLabel.text = [NSString stringWithFormat:@"%.0f", adjustedRichness];
    
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.appDelegate.playerDataDelegate = self;
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
    
    //[self drawCircleGrid];
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
