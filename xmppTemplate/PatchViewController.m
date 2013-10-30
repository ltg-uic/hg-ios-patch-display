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
    NSMutableArray *playersAtPatch;
    NSMutableDictionary *playersToLabels;
    int extraPlayersNum;
}

@end

@implementation PatchViewController

- (id)initWithCoder:(NSCoder *)aDecoder {
    if(self = [super initWithCoder:aDecoder])
    {
        self.appDelegate.playerDataDelegate = self;
        _playerPacmanViews = [[NSMutableArray alloc] init];
        playersAtPatch = [[NSMutableArray alloc] init];
        playersToLabels = [[NSMutableDictionary alloc] init];
    }
    return self;
}


#pragma mark - PLAYER DATA DELEGATE

-(void)playerDataDidUpdate {
    
}

-(void)playerDidLeave: (NSString *)player_id {
    
    if( [[self killList] containsObject:player_id] ) {
        NSArray *pacmansSearch = [_playerPacmanViews filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"player_id == %@", player_id]];
        
        
        PacmanView *oldPacmanView;
        if( pacmansSearch.count > 0 ) {
            oldPacmanView = [pacmansSearch objectAtIndex:0];
            [playersAtPatch removeObject:player_id];
            [self updateCalorieLabel];
            [oldPacmanView collapseLeave];
            [oldPacmanView setNeedsDisplay];
            [oldPacmanView.pacmanLayer setNeedsDisplay];
            
            [NSTimer scheduledTimerWithTimeInterval: 1.5
                                             target: self
                                           selector: @selector(checkForFreeSlot)
                                           userInfo: nil
                                            repeats: NO];
            
            return;
        }
    } else if( ![playersAtPatch containsObject:player_id] ) {
        return;
    }
    
    NSArray *pacmansSearch = [_playerPacmanViews filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"player_id == %@", player_id]];
    
    
    PacmanView *oldPacmanView;
    if( pacmansSearch.count > 0 ) {
        oldPacmanView = [pacmansSearch objectAtIndex:0];
        [playersAtPatch removeObject:player_id];
        [self updateCalorieLabel];
        [oldPacmanView collapseLeave];
        [oldPacmanView setNeedsDisplay];
        [oldPacmanView.pacmanLayer setNeedsDisplay];
        
        [NSTimer scheduledTimerWithTimeInterval: 1.5
                                         target: self
                                       selector: @selector(checkForFreeSlot)
                                       userInfo: nil
                                        repeats: NO];
        
        
    } else {
        [playersAtPatch removeObject:player_id];
        //[self updateExtraPlayerLabel: playersAtPatch.count];
    }
    
}

-(void)playerDidGetResurrected: (NSString *)player_id {
    NSArray *pacmansSearch = [_playerPacmanViews filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"player_id == %@",player_id]];
    
    if( pacmansSearch.count > 0 ) {
        [playersAtPatch addObject:player_id];
        PacmanView *pacman = [pacmansSearch objectAtIndex:0];
        
        [self showPlayerChompingWith:player_id With:pacman];
        [self updateCalorieLabel];
    }

}


-(void)playerDidGetKilled: (NSString *)player_id {
    
     NSArray *pacmansSearch = [_playerPacmanViews filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"player_id == %@",player_id]];
    
    if( pacmansSearch.count > 0 ) {
        [playersAtPatch removeObject:player_id];
        [self hawkKillWithPlayerId:player_id];
    }
}



-(void)playerDidArrive: (NSString *)player_id {
    
    if( [[self killList] containsObject:player_id] ) {
        NSArray *pacmansSearch = [_playerPacmanViews filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"player_id == %@",player_id]];
        
        if( pacmansSearch.count == 0 ) {
            NSArray *pacmansSearch = [_playerPacmanViews filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"player_id == nil"]];
        
            if( pacmansSearch.count > 0 ) {
                PacmanView *pacman = [pacmansSearch objectAtIndex:0];
                [self showPlayerDeadWith:player_id With:pacman];
                [self updateNameLabelWithPacman:pacman];

            }
            return;
        }
    } else if( [playersAtPatch containsObject:player_id] ) {
        return;
    }
    
    [playersAtPatch addObject:player_id];
    
    NSArray *pacmansSearch = [_playerPacmanViews filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"player_id == nil"]];
    
    
    if( pacmansSearch.count > 0 ) {
        PacmanView *pacman = [pacmansSearch objectAtIndex:0];
        [self showPlayerChompingWith:player_id With:pacman];
        [self updateCalorieLabel];
        //[self updateNameLabelWithPacman:pacman];
    }
}

-(void)updateNameLabelWithPacman:(PacmanView *)pacman {
    
//    NSString *tag = pacman.tag;
//    UILabel *label = [playersToLabels objectForKey:tag];
//    label.text = pacman.player_id;
//    label.hidden = NO;
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
    pacman.pacmanLayer.isFILLED = NO;
    pacman.pacmanLayer.isSMILE = NO;

    pacman.layer.shadowColor = [[UIColor blackColor] CGColor];
    pacman.layer.shadowOffset = CGSizeMake(1.0, 1.0);
    pacman.layer.shadowOpacity = 0.30;
    
    [pacman animate:YES];
    [pacman setNeedsDisplay];
    
    
}

-(void)showPlayerDeadWith:(NSString*)player_id With:(PacmanView*)pacman {
    
    NSArray *players = [[self.appDelegate playerDataPoints] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"player_id == %@",player_id ]];
    
    PlayerDataPoint *pdp = [players objectAtIndex:0];
    NSString *aColor = pdp.color;
    UIColor *hexColor = [UIColor colorWithHexString:[aColor stringByReplacingOccurrencesOfString:@"#" withString:@""]];
   
    pacman.hidden = NO;
    pacman.player_id = player_id;
    pacman.color = hexColor;
    pacman.pacmanLayer.pacColor =  hexColor;
    [pacman die:YES];
    
    
}

-(void)checkForFreeSlot {
    if( extraPlayersNum > 0 ) {
        
        
        //find all the pacmanviews with player ids
        NSArray *pacmansSearch = [playerPacmanViews filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"player_id != nil"]];
        
        NSArray *pacViewPlayerIds = [pacmansSearch valueForKey:@"player_id"];
        
        //find all the player ids in players patch
        
        for( NSString *p_id in playersAtPatch) {
            if( ![pacViewPlayerIds containsObject:p_id] ) {
                pacmansSearch = [_playerPacmanViews filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"player_id == nil"]];
                
                if( pacmansSearch.count > 0 ) {
                    PacmanView *pacman = [pacmansSearch objectAtIndex:0];
                    
                    [self showPlayerChompingWith:p_id With:pacman];
                    
                    
                    [pacman setNeedsDisplay];
                    [self.view setNeedsDisplay];
                    pacmansSearch = [_playerPacmanViews filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"player_id != nil"]];
                    
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
    NSArray *pacmansSearch = [_playerPacmanViews filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"player_id == %@", player_id]];
    
    if( pacmansSearch.count > 0) {
        [self hawkSound];
        PacmanView *pacmanView = [pacmansSearch objectAtIndex:0];
        [playersAtPatch removeObject:player_id];
        [self updateCalorieLabel];
        
        [pacmanView animate:NO];
        pacmanView.pacmanLayer.isFILLED = YES;
        pacmanView.pacmanLayer.isSMILE = YES;
        pacmanView.pacmanLayer.isHAPPY = NO;
        pacmanView.layer.shadowColor = [[UIColor blackColor] CGColor];
        pacmanView.layer.shadowOffset = CGSizeMake(1.0, 1.0);
        pacmanView.layer.shadowOpacity = 0.30;
        [pacmanView setNeedsDisplay];
        
//        NSArray *params = @[pacmanView];
//        
//        [NSTimer scheduledTimerWithTimeInterval: 2
//                                         target: self
//                                       selector: @selector(hawkPlayerDied:)
//                                       userInfo: params
//                                        repeats: NO];
        
        
    }
    
}

-(void)hawkPlayerDied:(NSTimer *)theTimer {
    NSArray *param = [theTimer userInfo];
    PacmanView *pm = [param objectAtIndex:0];
    [pm resetPacmanView];
}

-(void)boutReset {
    for (PacmanView *pacman in _playerPacmanViews) {
        [pacman resetPacmanView];
    }
    
    [playersAtPatch removeAllObjects];
    [self updateCalorieLabel];
    [self updateExtraPlayerLabel:0];
    [self showAcorns:NO];
}

-(void)boutStart {
    [self updateCalorieLabel];
    [self updateExtraPlayerLabel:0];
    [self showAcorns:YES];
}

-(void)boutStop {
    for (PacmanView *pacmanView in _playerPacmanViews) {
        [pacmanView animate:NO];
    }
    [self updateCalorieLabel];
}

-(void)initConnection {
    [self updateCalorieLabel];
    [self updateExtraPlayerLabel:0];
    [self showAcorns:YES];
}

-(void)showAcorns: (BOOL)update {
    if( update ) {
        int numOfAcorns = (self.appDelegate.currentPatchInfo.quality_per_minute/ 300);
        for (int i = 0; i < numOfAcorns; i++) {
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

-(void) setupPacmanViews {
    
    for( int i = 0; i < _playerPacmanViews.count; i++ ) {
        
        PacmanView *pc = _playerPacmanViews[i];
        NSString *tag = [NSString stringWithFormat:@"%d", i];

        pc.tag = tag;
        [playersToLabels setObject:_nameLabels[i] forKey:tag];
    }
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
    
    [self setupPacmanViews];
    [self.view setNeedsDisplay];
    
    
}

- (AppDelegate *)appDelegate
{
	return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}

-(NSArray *)playerDataPoints {
    
    return [[self appDelegate] playerDataPoints];
}

-(NSArray *)killList {
    
    return [[self appDelegate] killList ];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
