//
//  ViewController.m
//  xmppTemplate
//
//  Created by Anthony Perritano on 9/14/12.
//  Copyright (c) 2012 Learning Technologies Group. All rights reserved.
//


#import "LoginViewController.h"
#import "AppDelegate.h"
#import "DataStore.h"
#import "CorePlot-CocoaTouch.h"
#import "XMPPBaseNewMessageDelegate.h"
#import "SBJson.h"
#import "UIColor-Expanded.h"

@interface RootViewController : UIViewController <CPTBarPlotDataSource, CPTBarPlotDelegate, XMPPBaseNewMessageDelegate, XMPPBaseOnlineDelegate> {
    
    __weak IBOutlet UILabel *stopWatchLabel;
    __weak IBOutlet UILabel *timeIntervalLabel;
    __weak IBOutlet UIButton *startButton;
    NSTimer *intervalTimer;
    NSTimer *stopWatchTimer;
    NSDate *startDate;
    NSMutableArray *currentRFIDS;
    NSNumber *feedRatio;
        
    CPTGraph *graph;
    CPTXYPlotSpace *plotSpace;

}

@property (nonatomic, strong) IBOutlet CPTGraphHostingView *hostView;
@property (nonatomic, strong) CPTBarPlot *trianglePlot;
@property (nonatomic, strong) CPTBarPlot *squarePlot;
@property (nonatomic, strong) CPTPlotSpaceAnnotation *priceAnnotation;

-(void)initPlot;
-(void)configureGraph;
-(void)configurePlots;
-(void)configureAxes;
- (AppDelegate *)appDelegate;


- (IBAction)increaseIntervalTime:(id)sender;
- (IBAction)decreaseIntervalTime:(id)sender;
- (IBAction)startAndStop:(id)sender;

@end


@implementation RootViewController

CGFloat const CPDBarWidth = 1.0f;
CGFloat const CPDBarInitialX = 0.5f;

NSString *  const newFoodDynamicPlot = @"newFoodDynamicPlot";
NSString *  const starPlot = @"star";
NSString *  const trianglePlot = @"triangle";
NSString *  const circlePlot = @"circle";
NSString *  const squarePlot = @"square";

@synthesize hostView    = hostView_;
@synthesize trianglePlot    = trianglePlot_;
@synthesize squarePlot    = squarePlot_;
@synthesize priceAnnotation = priceAnnotation_;

- (AppDelegate *)appDelegate {
	return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}


#pragma mark - UIViewController lifecycle methods

-(void)viewDidLoad {
    [super viewDidLoad];
    
    self.appDelegate.xmppBaseNewMessageDelegate = self;
    self.appDelegate.xmppBaseOnlineDelegate = self;
    
    currentRFIDS = [NSMutableArray array];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Login method

- (IBAction)showLogin:(id)sender {
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPad"
                                                             bundle: nil];

    LoginViewController *controller = (LoginViewController*)[mainStoryboard instantiateViewControllerWithIdentifier: @"loginController"];
    [self presentViewController:controller animated:YES completion:nil];
}

#pragma mark - CPTPlotDataSource methods

-(NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot {
    return [[DataStore sharedInstance] playerCount];
}

-(NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index {
	if ((fieldEnum == CPTBarPlotFieldBarTip) && (index < [[DataStore sharedInstance] playerCount])) {
		if ([plot.identifier isEqual:trianglePlot]) {
            return [[DataStore sharedInstance] scoreForKey:index];
        }
	}
	return [NSDecimalNumber numberWithUnsignedInteger:index];
}

#pragma mark - Chart behavior

-(void)initPlot {
    //hostView_.allowPinchScaling = NO;
    [self configureGraph];
    [self configurePlots];
    [self configureAxes];
    [self.trianglePlot setHidden:NO];

}

-(void)configureGraph {
    // 1 - Create the graph
    graph = [[CPTXYGraph alloc] initWithFrame:self.hostView.bounds];
    graph.plotAreaFrame.masksToBorder = NO;
    
    
    hostView_.hostedGraph = graph;
    // 2 - Configure the graph
    [graph applyTheme:[CPTTheme themeNamed:kCPTPlainBlackTheme]];
    graph.paddingBottom = 10.0f;
    graph.paddingLeft  = 10.0f;
    graph.paddingTop    = 1.0f;
    graph.paddingRight  = 5.0f;
    //graph.axisSet.paddingBottom = 10.0f;

    // 3 - Set up styles
//    CPTMutableTextStyle *titleStyle = [CPTMutableTextStyle textStyle];
//    titleStyle.color = [CPTColor whiteColor];
//    titleStyle.fontName = @"Helvetica-Bold";
//    titleStyle.fontSize = 16.0f;
//    // 4 - Set up title
//    NSString *title = @"Portfolio Prices: April 23 - 27, 2012";
//    graph.title = title;
//    graph.titleTextStyle = titleStyle;
//    graph.titlePlotAreaFrameAnchor = CPTRectAnchorTop;
//    graph.titleDisplacement = CGPointMake(0.0f, -16.0f);
    // 5 - Set up plot space
    CGFloat xMin = 0.0f;
    
    //CGFloat xMax = 25;
    CGFloat xMax = [[DataStore sharedInstance] playerCount];
    CGFloat yMin = 0.0f;
    CGFloat yMax = 3000.0f;  // should determine dynamically based on max price
    plotSpace = (CPTXYPlotSpace *) graph.defaultPlotSpace;
    plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(xMin) length:CPTDecimalFromFloat(xMax)];
    plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(yMin) length:CPTDecimalFromFloat(yMax)];
}

-(void)configurePlots {
    // 1 - Set up the three plots
    self.trianglePlot = [CPTBarPlot tubularBarPlotWithColor:[CPTColor greenColor] horizontalBars:NO];
    self.trianglePlot.identifier = trianglePlot;
    
      // 2 - Set up line style
    CPTMutableLineStyle *barLineStyle = [[CPTMutableLineStyle alloc] init];
    barLineStyle.lineColor = [CPTColor lightGrayColor];
    barLineStyle.lineWidth = 0.1;
    // 3 - Add plots to graph
    graph = self.hostView.hostedGraph;
    CGFloat barX = CPDBarInitialX;
    NSArray *plots = [NSArray arrayWithObjects:self.trianglePlot, nil];
    for (CPTBarPlot *plot in plots) {
        plot.dataSource = self;
        plot.delegate = self;
        plot.barWidth = CPTDecimalFromDouble(CPDBarWidth);
        plot.barOffset = CPTDecimalFromDouble(CPDBarInitialX);
        plot.lineStyle = barLineStyle;
        [graph addPlot:plot toPlotSpace:graph.defaultPlotSpace];
        //barX += CPDBarWidth;
    }
    
}

-(CPTFill *)barFillForBarPlot:(CPTBarPlot *)barPlot
                  recordIndex:(NSUInteger)index {
    
    
    NSDictionary *colors = @{@"red":[CPTColor redColor], @"blue":[CPTColor blueColor], @"orange": [CPTColor orangeColor], @"yellow": [CPTColor yellowColor], @"green": [CPTColor greenColor]};
    
    if ( [barPlot.identifier isEqual:trianglePlot] ) {
        
        
        
        
        NSString *color = [[DataStore sharedInstance] colorForKey:index];
        

        UIColor *myColor = [UIColor colorWithHexString:color];

        
        
        CPTGradient *gradient = [CPTGradient gradientWithBeginningColor:[CPTColor colorWithComponentRed:myColor.red green:myColor.green blue:myColor.blue alpha:myColor.alpha]
                                                            endingColor:[CPTColor colorWithComponentRed:myColor.red green:myColor.green blue:myColor.blue alpha:myColor.alpha]
                                                      beginningPosition:0.0 endingPosition:0.0 ];
        [gradient setGradientType:CPTGradientTypeAxial];
        [gradient setAngle:350];
        
        CPTFill *fill = [CPTFill fillWithColor:[CPTColor blueColor]];
        
        return fill;
        
    }
    return [CPTFill fillWithColor:[CPTColor colorWithComponentRed:1.0 green:1.0 blue:1.0 alpha:1.0]];
    
}


-(void)configureAxes {
    
    
    NSArray *customTickLocations = [NSArray arrayWithObjects:[NSDecimalNumber numberWithInt:0],
                                    [NSDecimalNumber numberWithInt:5],
                                    [NSDecimalNumber numberWithInt:10],
                                    [NSDecimalNumber numberWithInt:15],
                                    [NSDecimalNumber numberWithInt:20],
                                    nil];
    
    // 1 - Configure styles
//    CPTMutableTextStyle *axisTitleStyle = [CPTMutableTextStyle textStyle];
//    axisTitleStyle.color = [CPTColor whiteColor];
//    axisTitleStyle.fontName = @"Helvetica-Bold";
//    axisTitleStyle.fontSize = 12.0f;
    CPTMutableLineStyle *axisLineStyle = [CPTMutableLineStyle lineStyle];
    axisLineStyle.lineWidth = 1.0f;
    axisLineStyle.lineColor = [[CPTColor whiteColor] colorWithAlphaComponent:1];
    // 2 - Get the graph's axis set
    CPTXYAxisSet *axisSet = (CPTXYAxisSet *) self.hostView.hostedGraph.axisSet;
    // 3 - Configure the x-axis

   // axisSet.xAxis.majorTickLocations = customTickLocations;
    //axisSet.xAxis.tickDirection = CPTSignNegative;
    
    //axisSet.xAxis.majorTickLineStyle = axisLineStyle;
    //axisSet.xAxis.labelOffset = 10.f;
    //axisSet.xAxis.majorTickLength = 10.0f;
    
    axisSet.xAxis.labelingPolicy = CPTAxisLabelingPolicyNone;
    //axisSet.xAxis.title = @"Days of Week (Mon - Fri)";
    //axisSet.xAxis.titleTextStyle = axisTitleStyle;
    //axisSet.xAxis.titleOffset = 10.0f;
    axisSet.xAxis.axisLineStyle = axisLineStyle;
    // 4 - Configure the y-axis
    axisSet.yAxis.labelingPolicy = CPTAxisLabelingPolicyNone;
    //axisSet.yAxis.title = @"Price";
    //axisSet.yAxis.titleTextStyle = axisTitleStyle;
    //axisSet.yAxis.titleOffset = 5.0f;
    axisSet.yAxis.axisLineStyle = axisLineStyle;
    
}

-(void)updateGraph {
    
    int scoreIncrease = [feedRatio intValue] / currentRFIDS.count;
    
    for( NSString *rfid in currentRFIDS) {
        [[DataStore sharedInstance] addScore:[NSNumber numberWithInt:100] withRFID:rfid];
    }
    
    
    [graph reloadData];
    
//    int scoreIncrease = [feedRatio intValue] / [[DataStore sharedInstance] playerCount ];
//    
//    //int scoreIncrease = 100 / [[DataStore sharedInstance] playerCount ];
//
//    
//    NSMutableArray *updatedArray = [NSMutableArray array];
//    
//    int currentPlayerCount = currentRFIDS.count;
//    while ([updatedArray count] !=  currentPlayerCount ) {
//        
//        NSNumber *randNum = @(arc4random() % currentPlayerCount);
//        
//        if( [randNum intValue] <= currentPlayerCount) {
//            
//            while ([updatedArray containsObject:randNum]) {
//                randNum = @(arc4random() % currentPlayerCount);
//            }
//            
//            [updatedArray addObject:randNum];
//            
//            [[DataStore sharedInstance] addScore:@( scoreIncrease ) withRFID:[currentRFIDS objectAtIndex:[randNum intValue]]];
//            
//            [graph reloadData];
//        }
//    }
    
}

#pragma mark - Actions


- (void)increaseByRFID:(NSString *)rfid {
    
    int scoreIncrease = [feedRatio intValue] / [[DataStore sharedInstance] playerCount ];
    
    
    [[DataStore sharedInstance] addScore:[NSNumber numberWithInt:100] withRFID:rfid];
    [graph reloadData];
}

- (void)decreaseByRFID:(NSString *)rfid {
    
    [[DataStore sharedInstance] resetScoreWithRFID:rfid];
    [graph reloadData];
}

- (IBAction)increaseIntervalTime:(id)sender {
  

    int newTime = [timeIntervalLabel.text intValue] + 1;
    
    timeIntervalLabel.text = [NSString stringWithFormat:@"%d", newTime];
    
    
    [intervalTimer invalidate];
    intervalTimer = [NSTimer scheduledTimerWithTimeInterval:newTime
                                                     target:self
                                                   selector:@selector(updateGraph)
                                                   userInfo:nil
                                                    repeats:YES];
    
    
}

- (IBAction)decreaseIntervalTime:(id)sender {
   
    
    int newTime = [timeIntervalLabel.text intValue] - 1;
    
    timeIntervalLabel.text = [NSString stringWithFormat:@"%d", newTime];
    
    
    [intervalTimer invalidate];
    intervalTimer = [NSTimer scheduledTimerWithTimeInterval:newTime
                                                     target:self
                                                   selector:@selector(updateGraph)
                                                   userInfo:nil
                                                    repeats:YES];
}

- (IBAction)startAndStop:(id)sender {
    
    
    
    NSString *title = [startButton currentTitle];
    
    if( [title isEqualToString:@"start"] ){
        startDate = [[NSDate date]init];
       [startButton setTitle: @"stop" forState: UIControlStateNormal];
        
        
        stopWatchTimer = [NSTimer scheduledTimerWithTimeInterval:1.0/10.0
                                                          target:self
                                                        selector:@selector(updateTimer)
                                                        userInfo:nil
                                                         repeats:YES];
        
        
        intervalTimer = [NSTimer scheduledTimerWithTimeInterval:2.0
                                                         target:self
                                                       selector:@selector(updateGraph)
                                                       userInfo:nil
                                                        repeats:YES];
        
        //[self increase:nil];

        
        
    } else {
        [startButton setTitle: @"start" forState: UIControlStateNormal];
        [stopWatchTimer invalidate];
        [intervalTimer invalidate];
        [[DataStore sharedInstance] resetPlayerCount];
        [graph reloadData];
        stopWatchTimer = nil;
        [self updateTimer];
    }
    
    
   }

#pragma mark - Timer methods

- (void)updateTimer {
    NSDate *currentDate = [NSDate date];
    NSTimeInterval timeInterval = [currentDate timeIntervalSinceDate:startDate];
    NSDate *timerDate = [NSDate dateWithTimeIntervalSince1970:timeInterval];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HH:mm:ss.SSS"];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0.0]];
    NSString *timeString=[dateFormatter stringFromDate:timerDate];
    stopWatchLabel.text = timeString;
}

#pragma mark - XMPP delegate methods

- (void)newMessageReceived:(NSDictionary *)messageContent{
    
    //NSString *msg = @"{\"patch\": \"fg-patch-1\", \"arrivals\" : [\"student-1\"],\"departures\" : []}";

    NSString *msg = [messageContent objectForKey:@"msg"];
  
    SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
    NSError *error = nil;
    NSDictionary *jsonObjects = [jsonParser objectWithString:msg error:&error];
    
    
    if( jsonObjects != nil){
        NSString *destination = [jsonObjects objectForKey:@"destination"];
        
        if( ! [destination isEqualToString:[self origin]] )
            return;
    
        NSString *event = [jsonObjects objectForKey:@"event"];
        
        
        if( event != nil) {
            
            if( [event isEqualToString:@"game_reset"] ) {
                [self resetGame];
            } else if( [event isEqualToString:@"patch_init_data"]){
                NSDictionary *payload = [jsonObjects objectForKey:@"payload"];

                feedRatio = @([[payload objectForKey:@"feed-ratio"] integerValue]);
                
                NSArray *tags = [payload objectForKey:@"tags"];
                
                for (NSDictionary *tag in tags) {
                    
                    NSString *tagId = [tag objectForKey:@"tag"];
                    NSString *cluster = [tag objectForKey:@"cluster"];
                    NSString *color = [tag objectForKey:@"color"];
                    
                    [[DataStore sharedInstance] addPlayerWithRFID:tagId withCluster:cluster withColor:color];
                }
                
                //init the graph
                [self initPlot];

            } else if( [event isEqualToString:@"rfid_update"] ){
                NSDictionary *payload = [jsonObjects objectForKey:@"payload"];
                
            
                NSArray *arrivals = [payload objectForKey:@"arrivals"];
                NSArray *departures = [payload objectForKey:@"departures"];
                
                if([startButton.currentTitle isEqualToString:@"start"]) {
                [self startAndStop:nil];
                }
                
                if( arrivals != nil && arrivals.count > 0 ) {
                    for (NSString *rfid in arrivals) {
                        [self addRFID:rfid];
                       // [self increaseByRFID: rfid];
                    }
                }
                
                if( departures != nil && departures.count > 0 ) {
                    for (NSString *rfid in departures) {
                        [self sendOutScoreUpdateWith:rfid];
                        [self decreaseByRFID: rfid];
                        [self removeRFID:rfid];
                        
                    }
                }
            }
            
            
            }
            
        }

    NSLog(@"message %@", msg);
    
    
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
    
    
    
    
    [self sendGroupChatMessage:[self patchMessage]];
}

-(NSString *) patchMessage {
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

#pragma mark - Game methods

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

-(void)resetGame {
    [startButton setTitle: @"start" forState: UIControlStateNormal];
    stopWatchLabel.text = @"0:00";
    [stopWatchTimer invalidate];
    [intervalTimer invalidate];
    [[DataStore sharedInstance] resetPlayerCount];
    [graph reloadData];
    [self updateTimer];
    feedRatio = @(0);
    [self sendGroupChatMessage:[self patchMessage]];

}

@end
