//
//  ViewController.m
//  xmppTemplate
//
//  Created by Anthony Perritano on 9/14/12.
//  Copyright (c) 2012 Learning Technologies Group. All rights reserved.
//


#import "LoginViewController.h"
#import "Player.h"
#import "AppDelegate.h"
#import "DataStore.h"
#import "XMPPBaseNewMessageDelegate.h"
#import "SBJson.h"
#import "PinPoint.h"
#import "PinPointGroup.h"
#import "PacmanView.h"
#import <AudioToolbox/AudioToolbox.h>

@interface RootViewController : UIViewController <XMPPBaseNewMessageDelegate, XMPPBaseOnlineDelegate> {
    
    __weak IBOutlet UILabel *timeIntervalLabel;
    __weak IBOutlet UILabel *feedRatioLabel;



}

- (AppDelegate *)appDelegate;


- (IBAction)increaseIntervalTime:(id)sender;
- (IBAction)decreaseIntervalTime:(id)sender;
- (IBAction)startAndStop:(id)sender;

@end


@implementation RootViewController


NSString *  const calorieStr = @"Each animal is getting";
NSString *  const caloriePerMinuteStr = @"Calories per Minute";

NSMutableArray *pinPointGroups;
NSMutableArray *currentRFIDS;
NSMutableArray *killList;


NSNumber *feedRatio;
NSTimer *intervalTimer;


bool isRUNNING = NO;
bool isGAME_STOPPED = NO;

- (AppDelegate *)appDelegate {
	return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}


#pragma mark - UIViewController lifecycle methods


-(void)viewDidLoad {
    [super viewDidLoad];
    
    self.appDelegate.xmppBaseNewMessageDelegate = self;
    self.appDelegate.xmppBaseOnlineDelegate = self;
    
    currentRFIDS = [NSMutableArray array];
    pinPointGroups = [NSMutableArray array];
    killList = [NSMutableArray array];
    feedRatioLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:450];
    
//    [[DataStore sharedInstance] addPlayerSpacing];
//    
//    [self drawCircleGrid];
    
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
    
    
    int numOfViews = [[[DataStore sharedInstance] playersCollection] count];

    
    
    circleWidth = floorf(( landscapeWidth/ numOfViews )-xOffset);
    circleHeight = circleWidth;
    
    float totalViewWidth = ((circleWidth * numOfViews) + (numOfViews * xOffset));
        
    circleX = xOffset;
    
    
    for (Player *player in [[DataStore sharedInstance] playersCollection]) {
        PacmanView *dv = [[PacmanView alloc] initWithFrame:CGRectMake(circleX, circleY, circleWidth, circleHeight)];
        NSString* cleanedString = [player.color stringByReplacingOccurrencesOfString:@"#" withString:@""];
        
        dv.pacmanLayer.isSMILE = NO;
        
        UIColor *playerColor = [UIColor colorWithHexString:cleanedString];
        
        
        dv.pacmanLayer.pacColor =  playerColor;
        dv.pacmanLayer.isFILLED = NO;
        dv.pacmanLayer.isSMILE = NO;
        dv.pacmanLayer.isHAPPY = NO;

        if (player.rfid.length == 0) {
            dv.pacmanLayer.isON = NO;
        
        }
//        
        PinPointGroup *pg = [[PinPointGroup alloc] initWithPlayer:player AndPinPoint:dv];
//
        [pinPointGroups addObject:pg];
        
        [self.view addSubview:dv];
        

        circleX = circleWidth + circleX + xOffset;
        
    }
    
    [self createClusterLabelsWithCircleWidth:circleWidth WithPadding:xOffset];

}

- (void) createClusterLabelsWithCircleWidth: (float) circleWidth WithPadding: (float) xOffset {
    
    
    float x = 0.0f;
    float previousTotal = 0.0f;
    float labelSize = 50.0f;
    
    int labelFontSize = 65;
    
    float blackCircleWidth = circleWidth;
    float labelOffset = circleWidth/2.0f;
    for (NSString *label in [[DataStore sharedInstance] clusterLabels]) {
        
        float count = [[DataStore sharedInstance] clusterCountWith:label];
        
        //draw the labels
        
        float totalViewWithOffsetWidth = ((circleWidth * count) + (count * xOffset));
                
        if( x == 0 )
            x = xOffset + (totalViewWithOffsetWidth/2.0f);
        else
            x = x + (previousTotal/2.0f) + blackCircleWidth + xOffset + (totalViewWithOffsetWidth/2.0f);
            
            previousTotal = totalViewWithOffsetWidth;
        
        
        UILabel *clusterLabel = [[UILabel alloc] initWithFrame:CGRectMake(x-(labelOffset + xOffset), 684, labelSize, 60)];
        
        clusterLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:labelFontSize];
        //
        clusterLabel.text = [label uppercaseString];
        clusterLabel.backgroundColor = [UIColor clearColor];
        clusterLabel.textColor = [UIColor whiteColor];
        clusterLabel.textAlignment = NSTextAlignmentCenter;;
        
        [self.view addSubview:clusterLabel];

        
        
    }
    
}

-(void) showKillFaceWithRFID: (NSString *)rfid {
    PinPointGroup *pg = [self findPinPointGroupWithRFID:rfid];
    if ( pg != nil ) {
        pg.pinPoint.pacmanLayer.isHAPPY = NO;
        pg.pinPoint.pacmanLayer.isFILLED = YES;
        pg.pinPoint.pacmanLayer.isSMILE = YES;
        [pg.pinPoint.pacmanLayer setNeedsDisplay];
        [pg.pinPoint setNeedsDisplay];
    }

}

-(PinPointGroup *) findPinPointGroupWithRFID: (NSString *)rfid {
    for (PinPointGroup *pg in pinPointGroups) {
        if ([pg.player.rfid isEqualToString:rfid]) {
            return pg;
        }
    }
    return nil;
}

-(void)adjustPlayer: (NSString *)rfid isOn:(BOOL)isOn {
    
    PinPointGroup *pg = [self findPinPointGroupWithRFID:rfid];
    
    if ( pg != nil ) {
        
        if( isOn == YES) {
            pg.pinPoint.pacmanLayer.isHAPPY = NO;
            pg.pinPoint.pacmanLayer.isSMILE = NO;
            pg.pinPoint.pacmanLayer.isFILLED = YES;
        } else {
            pg.pinPoint.pacmanLayer.isHAPPY = NO;
            pg.pinPoint.pacmanLayer.isSMILE = NO;
            pg.pinPoint.pacmanLayer.isFILLED = NO;
        }
        
        [pg.pinPoint animate:isOn];
        [pg.pinPoint.pacmanLayer setNeedsDisplay];
        [pg.pinPoint setNeedsDisplay];
        
    
      
    }
}


- (void)killBunnyWithRFID:(NSString * )rfid {
    
    if( [killList containsObject:rfid] == NO) {
        [killList addObject:rfid];
        
        if( [currentRFIDS containsObject:rfid]) {
            PinPointGroup *pg = [self findPinPointGroupWithRFID:rfid];
            if ( pg != nil ) {
                pg.pinPoint.pacmanLayer.isSMILE = NO;
                [pg.pinPoint collapse];
               
                
            }
        }
    }
    
    [self hawkSound];

}

-(void)resetBunnies {
    for (PinPointGroup *pg in pinPointGroups) {
        pg.pinPoint.pacmanLayer.isHAPPY = NO;
        pg.pinPoint.pacmanLayer.isSMILE = NO;
        pg.pinPoint.pacmanLayer.isFILLED = NO;
        [pg.pinPoint.pacmanLayer setNeedsDisplay];
        [pg.pinPoint setNeedsDisplay];
    }
}

- (void)resurrectBunnyWithRFID:(NSString * )rfid {
    
    if( [killList containsObject:rfid] ) {
        [killList removeObject:rfid];
        
            PinPointGroup *pg = [self findPinPointGroupWithRFID:rfid];
            if ( pg != nil ) {
                if( pg.pinPoint.pacmanLayer.isSMILE){
                    pg.pinPoint.pacmanLayer.isSMILE = NO;
                    pg.pinPoint.pacmanLayer.isHAPPY = NO;
                    pg.pinPoint.pacmanLayer.isFILLED = NO;
                    //[pg.pinPoint animate:YES];
                    [pg.pinPoint.pacmanLayer setNeedsDisplay];
                    [pg.pinPoint setNeedsDisplay];
                }
                
            }
        
        
        if( [currentRFIDS containsObject:rfid] )
            [currentRFIDS removeObject:rfid];
        
    }
    
}

-(void)hawkSound {
    SystemSoundID _pewPewSound;
    
    NSString *pewPewPath = [[NSBundle mainBundle] pathForResource:@"hawk" ofType:@"caf"];
	NSURL *pewPewURL = [NSURL fileURLWithPath:pewPewPath];
	AudioServicesCreateSystemSoundID((__bridge CFURLRef)pewPewURL, &_pewPewSound);
    AudioServicesPlaySystemSound(_pewPewSound);
}


-(void)updateFeedRatioLabelWith: (float)ratio {
    feedRatioLabel.text = @"";
    
    int intRatio = ratio;
    
    
    feedRatioLabel.text = [NSString stringWithFormat:@"%d", intRatio];
    [feedRatioLabel setNeedsDisplay];
}



#pragma mark - Game methods

- (void)resetScoreByRFID:(NSString *)rfid {
    [[DataStore sharedInstance] resetScoreWithRFID:rfid];
}

-(void)stopGame {
    
    for (NSString *rfid in currentRFIDS) {
        PinPointGroup *pg = [self findPinPointGroupWithRFID:rfid];
        pg.pinPoint.pacmanLayer.isSMILE = NO;
        
        [pg.pinPoint animate:NO];
        pg.pinPoint.pacmanLayer.isFILLED = YES;
        [pg.pinPoint.pacmanLayer setNeedsDisplay];
        [pg.pinPoint setNeedsDisplay];
    }
    
    
}


-(void)resetGame {
    [currentRFIDS removeAllObjects];
    [ [DataStore sharedInstance] zeroOutPlayersScore];
    [killList removeAllObjects];
    feedRatio = @(0);
    isRUNNING = NO;
    isGAME_STOPPED = NO;
    [self resetBunnies];
    [self sendGroupChatMessage:[self patchInitMessage]];
    [self updateFeedRatioLabelWith:0.0f];
    
}

-(void)addRFID: (NSString *)newRFID {
    
    if( [currentRFIDS containsObject:newRFID ] )
        return;
    
    for( NSString *rfid in currentRFIDS) {
        if( [rfid isEqualToString:newRFID]){
            return;
        }
    }
    [currentRFIDS addObject:newRFID];
    
}

-(void)removeRFID: (NSString *)rfid {
    if( [currentRFIDS containsObject:rfid])
        [currentRFIDS removeObject:rfid];
}

-(void)updateScore {
    
    if( isRUNNING && currentRFIDS.count > 0 ) {
        
        
        //adjusted feedratio for .2 msec
        float adjustedFeedratio = [feedRatio floatValue] / 5.0f;
        
        int totalCount = 0;
        for(NSString * rfid in currentRFIDS) {
            if( [killList containsObject:rfid] == NO)
                totalCount = totalCount + 1;
        }
        
        
        float scoreIncrease;
        
        if( totalCount == 0) {
            scoreIncrease = 0;
            [self updateFeedRatioLabelWith: 0];
        } else {
            scoreIncrease =  adjustedFeedratio/totalCount;
            [self updateFeedRatioLabelWith: ([feedRatio floatValue]/totalCount) * 60.0f];
        }
        
        
    
        
        for (NSString *rfid in currentRFIDS) {
            
            
            PinPointGroup *pg = [self findPinPointGroupWithRFID:rfid];
            
            if( (pg.pinPoint.pacmanLayer.isSMILE == NO && [killList containsObject:rfid ] == NO) )
                [[DataStore sharedInstance] addScore:@( scoreIncrease ) withRFID:rfid];
        }
    
    } else {
        [self updateFeedRatioLabelWith: 0.0f];
    }
}

-(void)startTimer {
    
    
    intervalTimer = [NSTimer scheduledTimerWithTimeInterval:.2
                                                     target:self
                                                   selector:@selector(updateScore)
                                                   userInfo:nil
                                                    repeats:YES];
    
}

#pragma mark - XMPP delegate methods

- (void)newMessageReceived:(NSDictionary *)messageContent{

    NSString *msg = [messageContent objectForKey:@"msg"];
  
    SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
    NSError *error = nil;
    NSDictionary *jsonObjects = [jsonParser objectWithString:msg error:&error];
    
    
    if( jsonObjects != nil){
        NSString *destination = [jsonObjects objectForKey:@"destination"];
        
        
        NSString *event = [jsonObjects objectForKey:@"event"];
        
        if( [event isEqualToString:@"game_reset"] ) {
            [self resetGame];
        } else if( [event isEqualToString:@"game_stop"] ) {
            isRUNNING = NO;
            isGAME_STOPPED = YES;
            [self stopGame];
        } else if( [event isEqualToString:@"bunny_alive"] ) {
            NSDictionary *payload = [jsonObjects objectForKey:@"payload"];
            NSString *rfid = [payload objectForKey:@"id"];
            [self resurrectBunnyWithRFID:rfid];
        } else if ( [event isEqualToString:@"kill_bunny"] ) {
            NSDictionary *payload = [jsonObjects objectForKey:@"payload"];
            NSString *rfid = [payload objectForKey:@"id"];
            [self killBunnyWithRFID:rfid];
            [self sendOutScoreUpdateWith:rfid];
            [self resetScoreByRFID: rfid];
        }

        
        if( ! [destination isEqualToString:[self origin]] )
            return;
        
        if( event != nil) {
            if( [event isEqualToString:@"patch_init_data"]){
                
                if( pinPointGroups.count > 0) {
                    for (PinPointGroup *pg in pinPointGroups) {
                        [pg.pinPoint removeFromSuperview];
                    }
                    
                    [pinPointGroups removeAllObjects];
                    [self.view clearsContextBeforeDrawing];
                    [self.view setNeedsDisplay];
                }
            
            
                
                
                [[DataStore sharedInstance] resetPlayerCount];
                
               
                
                NSDictionary *payload = [jsonObjects objectForKey:@"payload"];

                feedRatio = @([[payload objectForKey:@"feed-ratio"] integerValue]);
                
                NSArray *tags = [payload objectForKey:@"tags"];
                
                for (NSDictionary *tag in tags) {
                    
                    NSString *tagId = [tag objectForKey:@"tag"];
                    NSString *cluster = [tag objectForKey:@"cluster"];
                    NSString *color = [tag objectForKey:@"color"];
                    
                    [[DataStore sharedInstance] addPlayerWithRFID:tagId withCluster:cluster withColor:color];
                }
                
                //[[DataStore sharedInstance] printPlayers];
                
                [[DataStore sharedInstance] addPlayerSpacing];
                
                [self drawCircleGrid];


            } else if( [event isEqualToString:@"rfid_update"] ){
                NSDictionary *payload = [jsonObjects objectForKey:@"payload"];
                
            
                NSArray *arrivals = [payload objectForKey:@"arrivals"];
                NSArray *departures = [payload objectForKey:@"departures"];
                
                if( arrivals != nil && arrivals.count > 0 ) {
                    for (NSString *rfid in arrivals) {
                        
                        if( (([killList containsObject:rfid] == NO) && ([currentRFIDS containsObject:rfid] == NO))) {
                            [self addRFID:rfid];
                            [self adjustPlayer:rfid isOn:YES];
                        }
                        
                        if( [killList containsObject:rfid] ) {
                            [self showKillFaceWithRFID:rfid];
                        }
                        
                        
                    }
                    
                    if( (isRUNNING == NO && isGAME_STOPPED == NO)) {
                        isRUNNING = YES;
                        [self startTimer];
                        
                    }
                }
                
                if( departures != nil && departures.count > 0 ) {
                    for (NSString *rfid in departures) {
                        
                        if( [killList containsObject:rfid] == YES)
                            return;
                        
                        [self sendOutScoreUpdateWith:rfid];
                        [self resetScoreByRFID: rfid];
                        [self removeRFID:rfid];
                        [self adjustPlayer:rfid isOn:NO];
                        
                    }
                }
            }            
            }
            
        }

    NSLog(@"message %@", msg);
}

- (void)replyMessageTo:(NSString *)from {
    
}
- (IBAction)test:(id)sender {
    NSString *origin = [self origin];
    
    NSString *eventType = @"\"event\": \"score_upate\"";
    
    NSString *originType = [[NSString alloc] initWithFormat:@"\"origin\": \"%@\"",origin];
    
    NSString *payloadType = [[NSString alloc] initWithFormat:@"\"payload\": { \"tag\": \"%@\", \"score\": \"%@\" }",@"3243434", @"45"];
    
    NSString *msg = [[NSString alloc] initWithFormat:@"{ %@,%@, %@ }",eventType, originType,payloadType];
    
    [self sendGroupChatMessage:msg];
    
}

- (void)isAvailable:(BOOL)available {
    [self sendGroupChatMessage:[self patchInitMessage]];
}

-(NSString *) patchInitMessage {
    NSString *origin = [self origin];
    
    NSString *eventType = @"\"event\": \"patch_init\"";
    
    NSString *originType = [[NSString alloc] initWithFormat:@"\"origin\": \"%@\"",origin];
    
    NSString *payloadType = [[NSString alloc] initWithFormat:@"\"payload\": { }"];
    
    NSString *msg = [[NSString alloc] initWithFormat:@"{ %@,%@, %@ }",eventType, originType,payloadType];
    
    return msg;
}
-(void)sendGroupChatMessage: (NSString *)msg {
    NSXMLElement *body = [NSXMLElement elementWithName:@"body"];
    [body setStringValue:msg];
    
    NSXMLElement *message = [NSXMLElement elementWithName:@"message"];
    [message addAttributeWithName:@"type" stringValue:@"groupchat"];
    [message addAttributeWithName:@"to" stringValue:ROOM_JID];
    [message addChild:body];
    
    [[[self appDelegate] xmppStream ] sendElement:message];
}

-(void)sendOutScoreUpdateWith: (NSString *)rfid {
    for( NSString *someRFID in currentRFIDS) {
        if( [someRFID isEqualToString:rfid]){
            NSNumber *score = [[DataStore sharedInstance ] scoreForRFID:rfid];
            NSString *origin = [self origin];
            
            NSString *eventType = @"\"event\": \"score_upate\"";
            
            NSString *originType = [[NSString alloc] initWithFormat:@"\"origin\": \"%@\"",origin];
            
            NSString *payloadType = [[NSString alloc] initWithFormat:@"\"payload\": { \"tag\": \"%@\", \"score\": \"%@\" }",rfid, [score stringValue]];
            
            NSString *msg = [[NSString alloc] initWithFormat:@"{ %@,%@, %@ }",eventType, originType,payloadType];
            
            [self sendGroupChatMessage:msg];
            
        }
    }
}



-(NSString *) origin {
    NSString *myJID = [[NSUserDefaults standardUserDefaults] stringForKey:kXMPPmyJID];
    NSString *origin = [[myJID componentsSeparatedByString:@"@"] objectAtIndex:0 ];
    return origin;
}

#pragma mark - Login method

- (IBAction)showLogin:(id)sender {
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPad"
                                                             bundle: nil];
    
    LoginViewController *controller = (LoginViewController*)[mainStoryboard instantiateViewControllerWithIdentifier: @"loginController"];
    [self presentViewController:controller animated:YES completion:nil];
}

@end
