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
    NSMutableArray *playerPacmanViews;
    NSMutableArray *playersAtPatch;
    NSTimer *timer;
    int extraPlayersNum;
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
    
    if( ![playersAtPatch containsObject:player_id] )
        return;
    
    NSArray *pacmansSearch = [playerPacmanViews filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"player_id == %@", player_id]];
    
    
    PacmanView *oldPacmanView;
    if( pacmansSearch.count > 0 ) {
        oldPacmanView = [pacmansSearch objectAtIndex:0];
        [playersAtPatch removeObject:player_id];
        [self updateCalorieLabel];
        [oldPacmanView collapseLeave];
        [oldPacmanView setNeedsDisplay];
        [oldPacmanView.pacmanLayer setNeedsDisplay];
        
        [NSTimer scheduledTimerWithTimeInterval: 3.0
                                         target: self
                                       selector: @selector(checkForFreeSlot)
                                       userInfo: nil
                                        repeats: NO];
        
        
    } else {
        [playersAtPatch removeObject:player_id];
        [self updateExtraPlayerLabel: playersAtPatch.count];
    }
    
}

-(void)playerDidGetKilled: (NSString *)player_id {
    [self hawkKillWithPlayerId:player_id];
}



-(void)playerDidArrive: (NSString *)player_id {
    
    if( [playersAtPatch containsObject:player_id ])
        return;
    
    [playersAtPatch addObject:player_id];
    
    NSArray *pacmansSearch = [playerPacmanViews filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"player_id == nil"]];
    
    
    if( pacmansSearch.count > 0 ) {
        PacmanView *pacman = [pacmansSearch objectAtIndex:0];
        [self showPlayerChompingWith:player_id With:pacman];
        [self updateCalorieLabel];
    } else {
        pacmansSearch = [playerPacmanViews filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"player_id != nil"]];
        [self updateExtraPlayerLabel: abs(pacmansSearch.count-playersAtPatch.count)];
    }
}

-(void)showPlayerChompingWith:(NSString*)player_id With:(PacmanView*)pacman {
    
    NSArray *players = [[self.appDelegate playerDataPoints] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"player_id == %@",player_id ]];
    
    PlayerDataPoint *pdp = [players objectAtIndex:0];
    NSString *aColor = pdp.color;
    UIColor *hexColor = [UIColor colorWithHexString:[aColor stringByReplacingOccurrencesOfString:@"#" withString:@""]];
    pacman.hidden = NO;
    pacman.player_id = player_id;
    pacman.color = hexColor;
    pacman.pacmanLayer.pacColor =  hexColor;
    
    pacman.layer.shadowColor = [[UIColor blackColor] CGColor];
    pacman.layer.shadowOffset = CGSizeMake(1.0, 1.0);
    pacman.layer.shadowOpacity = 0.30;
    
    [pacman animate:YES];
    [pacman setNeedsDisplay];
    
    
}

-(void)checkForFreeSlot {
    if( extraPlayersNum > 0 ) {
        
        
        //find all the pacmanviews with player ids
        NSArray *pacmansSearch = [playerPacmanViews filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"player_id != nil"]];
        
        NSArray *pacViewPlayerIds = [pacmansSearch valueForKey:@"player_id"];
        
        //find all the player ids in players patch
        
        for( NSString *p_id in playersAtPatch) {
            if( ![pacViewPlayerIds containsObject:p_id] ) {
                pacmansSearch = [playerPacmanViews filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"player_id == nil"]];
                
                if( pacmansSearch.count > 0 ) {
                    PacmanView *pacman = [pacmansSearch objectAtIndex:0];
                    
                    [self showPlayerChompingWith:p_id With:pacman];
                    
                    
                    [pacman setNeedsDisplay];
                    [self.view setNeedsDisplay];
                    pacmansSearch = [playerPacmanViews filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"player_id != nil"]];
                    
                    [self updateExtraPlayerLabel: extraPlayersNum-1];
                }
                return;
            }
            
        }
        
        
        
    }
}

#pragma mark - THE HAWK

-(void)hawkSound {
    SystemSoundID _pewPewSound;
    
    NSString *pewPewPath = [[NSBundle mainBundle] pathForResource:@"hawk" ofType:@"caf"];
	NSURL *pewPewURL = [NSURL fileURLWithPath:pewPewPath];
	AudioServicesCreateSystemSoundID((__bridge CFURLRef)pewPewURL, &_pewPewSound);
    AudioServicesPlaySystemSound(_pewPewSound);
}

-(void)hawkKillWithPlayerId:(NSString *)player_id {
    NSArray *pacmansSearch = [playerPacmanViews filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"player_id == %@", player_id]];
    
    if( pacmansSearch.count > 0) {
        [self hawkSound];
        PacmanView *pacmanView = [pacmansSearch objectAtIndex:0];
        [playersAtPatch removeObject:player_id];
        [self updateCalorieLabel];
        
        [pacmanView animate:NO];
        pacmanView.pacmanLayer.isFILLED = YES;
        pacmanView.pacmanLayer.isSMILE = YES;
        pacmanView.pacmanLayer.isHAPPY = NO;
        [pacmanView setNeedsDisplay];
        
        NSArray *params = @[pacmanView];
        
        [NSTimer scheduledTimerWithTimeInterval: 2
                                         target: self
                                       selector: @selector(hawkPlayerDied:)
                                       userInfo: params
                                        repeats: NO];
        
        
    }
    
}

-(void)hawkPlayerDied:(NSTimer *)theTimer {
    NSArray *param = [theTimer userInfo];
    PacmanView *pm = [param objectAtIndex:0];
    [pm resetPacmanView];
}

-(void)boutReset {
    for (PacmanView *pacman in playerPacmanViews) {
        [pacman resetPacmanView];
    }
    [self updateExtraPlayerLabel:0];
    [self showAcorns:NO];
}

-(void)boutStart {
    [self updateCalorieLabel];
    [self updateExtraPlayerLabel:0];
    [self showAcorns:YES];
}

-(void)boutStop {
    for (PacmanView *pacmanView in playerPacmanViews) {
        [pacmanView animate:NO];
    }
    [self updateCalorieLabel];
}

-(void)showAcorns: (BOOL)update {
    if( update ) {
        int numOfAcorns = (self.appDelegate.currentPatchInfo.quality_per_minute/ 300);
        for (int i = 0; i <= numOfAcorns; i++) {
            UIImageView *ac = acorns[i];
            ac.hidden = NO;
        }
    } else {
        for( UIImageView *acorn in acorns ) {
            acorn.hidden = YES;
        }
    }
}

-(void)updateExtraPlayerLabel:(int) numOfExtraPlayers {
    
    extraPlayersNum = numOfExtraPlayers;
    if ( numOfExtraPlayers == 0 ) {
        extraPlayersLabel.text = @"";
    } else {
        extraPlayersLabel.text = [NSString stringWithFormat:@"+%d others not shown",extraPlayersNum];
    }
    
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
    
    
    int numOfViews = 10;
    
    
    
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
    
    [self drawCircleGrid];
    
    
    
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
