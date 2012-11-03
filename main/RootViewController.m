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
#import "PinPointGroup.h";
#import "UIColor-Expanded.h"

@interface RootViewController : UIViewController <XMPPBaseNewMessageDelegate, XMPPBaseOnlineDelegate> {
    
    __weak IBOutlet UILabel *timeIntervalLabel;
    __weak IBOutlet UILabel *calorieLabel;

    
    UILabel *feedRatioLabel;
    NSTimer *intervalTimer;
    NSDate *startDate;
    NSMutableArray *currentRFIDS;
    NSNumber *feedRatio;

}

- (AppDelegate *)appDelegate;


- (IBAction)increaseIntervalTime:(id)sender;
- (IBAction)decreaseIntervalTime:(id)sender;
- (IBAction)startAndStop:(id)sender;

@end


@implementation RootViewController

int labelFontSize = 41;

NSString *  const calorieStr = @"Each animal is getting";
NSString *  const caloriePerMinuteStr = @"Calories per Minute";

NSMutableArray *pinPointGroups;

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
//    
//    feedRatioLabel = [[UILabel alloc] initWithFrame:CGRectMake(-475, 450, 1000, 50)];
//    
//    feedRatioLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:labelFontSize];
//    
//    feedRatioLabel.text = [[NSString alloc] initWithFormat:@"%@ 0 %@",calorieStr, caloriePerMinuteStr];
//    [feedRatioLabel setTransform:CGAffineTransformMakeRotation(-M_PI / 2)];
//    feedRatioLabel.backgroundColor = [UIColor clearColor];
//    
//    feedRatioLabel.textColor = [UIColor whiteColor];
    //[self.view addSubview:feedRatioLabel];
    
    calorieLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:450];
    
    [[DataStore sharedInstance] addPlayerSpacing];
    
    [self drawCircleGrid];
    
}

#pragma mark - Drawing methods

-(void) drawCircleGrid {
    
    float widthOfLandscape = 1024.0f;
    float heightOfLandscape = 768.0f;
    float labelHeight = 55.0f;
    
    float widthOfCircle = 45.0;
    float heightOfCircle = widthOfCircle;
    
    
    float yOfCircle = heightOfLandscape - (40 + labelHeight  + heightOfCircle );
    float xOfCircle = 0;
    
    float xOffset = 6.0f;
    
    
    int numOfViews = [[[DataStore sharedInstance] playersCollection] count];
    
    widthOfCircle = floorf(( widthOfLandscape/ numOfViews )-xOffset);
    heightOfCircle = widthOfCircle;
    
    float totalViewWidth = ((widthOfCircle * numOfViews) + (numOfViews * xOffset));
    
    float outsidePadding = ( 1024.0 - totalViewWidth ) / 2;
    
    xOfCircle = xOffset;
    
    
    for (Player *player in [[DataStore sharedInstance] playersCollection]) {
        PinPoint *dv = [[PinPoint alloc] initWithFrame:CGRectMake(xOfCircle, yOfCircle, widthOfCircle, heightOfCircle)];
        
        NSString* cleanedString = [player.color stringByReplacingOccurrencesOfString:@"#" withString:@""];
        UIColor *playerColor = [UIColor colorWithHexString:cleanedString];
        
        //dv.isFILLED = YES;
        dv.color = playerColor;
        
        if (player.rfid.length == 0) {
            dv.isON = NO;
        }
        
        
        PinPointGroup *pg = [[PinPointGroup alloc] initWithPlayer:player AndPinPoint:dv];
        
        [pinPointGroups addObject:pg];
        
        [self.view addSubview:dv];
        
        xOfCircle = heightOfCircle + xOfCircle + xOffset;
        
    }

}
- (IBAction)changeFill:(id)sender {
    
    
    
    
}

//-(CPTFill *)barFillForBarPlot:(CPTBarPlot *)barPlot
//                  recordIndex:(NSUInteger)index {
//
//    
//    if ( [barPlot.identifier isEqual:trianglePlot] ) {
//        
//        NSString *color = [[DataStore sharedInstance] colorForKey:index];
//        
//        if( [color isEqualToString:@"blank"] )
//            return [CPTFill fillWithColor:[CPTColor clearColor]];
//        
//        NSString* cleanedString = [color stringByReplacingOccurrencesOfString:@"#" withString:@""];
//
//
//        UIColor *myColor = [UIColor colorWithHexString:cleanedString];
//
//        
//        CPTFill *fill = [CPTFill fillWithColor:[CPTColor colorWithCGColor:myColor.CGColor]];
//        
//        return fill;
//        
//    }
//    return [CPTFill fillWithColor:[CPTColor colorWithComponentRed:1.0 green:1.0 blue:1.0 alpha:1.0]];
//    
//}

-(void)updateFeedRatioLabelWith: (float)ratio {
    feedRatioLabel.text = @"";
    
    int intRatio = ratio;
    
    feedRatioLabel.text = [NSString stringWithFormat:@"%@ %d %@", calorieStr, intRatio, caloriePerMinuteStr];
    [feedRatioLabel setNeedsDisplay];
}



#pragma mark - Game methods

- (void)resetScoreByRFID:(NSString *)rfid {
    [[DataStore sharedInstance] resetScoreWithRFID:rfid];
}


-(void)resetGame {
    [currentRFIDS removeAllObjects];
    [ [DataStore sharedInstance] zeroOutPlayersScore];
    feedRatio = @(0);
    isRUNNING = NO;
    isGAME_STOPPED = NO;
    [self sendGroupChatMessage:[self patchInitMessage]];
    //[self updateFeedRatioLabelWith:0.0f];
    
}

-(void)startTimer {
    
    
    intervalTimer = [NSTimer scheduledTimerWithTimeInterval:.2
                                                     target:self
                                                   selector:@selector(updateGraph)
                                                   userInfo:nil
                                                    repeats:YES];
    
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
        }
        
        if( ! [destination isEqualToString:[self origin]] )
            return;
        
        if( event != nil) {
            if( [event isEqualToString:@"patch_init_data"]){
                
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
                
                [[DataStore sharedInstance] printPlayers];
                
                [[DataStore sharedInstance] addPlayerSpacing];
                


            } else if( [event isEqualToString:@"rfid_update"] ){
                NSDictionary *payload = [jsonObjects objectForKey:@"payload"];
                
            
                NSArray *arrivals = [payload objectForKey:@"arrivals"];
                NSArray *departures = [payload objectForKey:@"departures"];
                
                if( arrivals != nil && arrivals.count > 0 ) {
                    for (NSString *rfid in arrivals) {
                        [self addRFID:rfid];
                    }
                    
                    if( (isRUNNING == NO && isGAME_STOPPED == NO)) {
                        isRUNNING = YES;
                        [self startTimer];
                        
                    }
                }
                
                if( departures != nil && departures.count > 0 ) {
                    for (NSString *rfid in departures) {
                        [self sendOutScoreUpdateWith:rfid];
                        [self resetScoreByRFID: rfid];
                        [self removeRFID:rfid];
                        
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
