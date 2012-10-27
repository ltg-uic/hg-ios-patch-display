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
#import "CorePlot-CocoaTouch.h"
#import "XMPPBaseNewMessageDelegate.h"
#import "SBJson.h"
#import "UIColor-Expanded.h"
#import "CPTUtilities.h"

@interface RootViewController : UIViewController <CPTBarPlotDataSource, CPTBarPlotDelegate, XMPPBaseNewMessageDelegate, XMPPBaseOnlineDelegate> {
    
    __weak IBOutlet UILabel *timeIntervalLabel;

    
    UILabel *feedRatioLabel;
    NSTimer *intervalTimer;
    NSDate *startDate;
    NSMutableArray *currentRFIDS;
    NSNumber *feedRatio;
        
    CPTGraph *graph;
    CPTXYPlotSpace *plotSpace;

}

@property (nonatomic, strong) IBOutlet CPTGraphHostingView *hostView;
@property (nonatomic, strong) CPTBarPlot *trianglePlot;
@property (nonatomic, strong) CPTPlotSpaceAnnotation *scoreAnnotation;

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

int labelFontSize = 41;

NSString *  const newFoodDynamicPlot = @"newFoodDynamicPlot";
NSString *  const trianglePlot = @"triangle";
NSString *  const calorieStr = @"Each animal is getting";
NSString *  const caloriePerMinuteStr = @"Calories per Minute";


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
    
    feedRatioLabel = [[UILabel alloc] initWithFrame:CGRectMake(-475, 450, 1000, 50)];
    
    feedRatioLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:labelFontSize];
    
    feedRatioLabel.text = [[NSString alloc] initWithFormat:@"%@ 0 %@",calorieStr, caloriePerMinuteStr];
    [feedRatioLabel setTransform:CGAffineTransformMakeRotation(-M_PI / 2)];
    feedRatioLabel.backgroundColor = [UIColor clearColor];
    
    feedRatioLabel.textColor = [UIColor whiteColor];
    [self.view addSubview:feedRatioLabel];
    //[self initPlot];
    
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
    
    
    _hostView.hostedGraph = graph;
    // 2 - Configure the graph
	[graph applyTheme:[CPTTheme themeNamed:kCPTDarkGradientTheme]];
    graph.paddingBottom = 50.0f;
    graph.paddingLeft  = 1.0f;
    graph.paddingTop    = 0.0f;
    graph.paddingRight  = 1.0f;
    graph.fill = [CPTFill fillWithColor:[CPTColor blackColor]];

    graph.plotAreaFrame.borderLineStyle = nil;
    graph.plotAreaFrame.cornerRadius = 0;
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
    CGFloat yMax = 3500.0f;  // should determine dynamically based on max price
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
    self.trianglePlot.dataSource = self;
    self.trianglePlot.delegate = self;
    self.trianglePlot.barWidth = CPTDecimalFromDouble(CPDBarWidth);
    self.trianglePlot.barOffset = CPTDecimalFromDouble(.53);
    self.trianglePlot.lineStyle = barLineStyle;
    [graph addPlot:self.trianglePlot toPlotSpace:graph.defaultPlotSpace];    
}

-(void)configureAxes {
    
    // 1 - Configure styles
    // 1 - Create styles
//    CPTMutableTextStyle *axisTitleStyle = [CPTMutableTextStyle textStyle];
//    axisTitleStyle.color = [CPTColor whiteColor];
//    axisTitleStyle.fontName = @"Helvetica-Bold";
//    axisTitleStyle.fontSize = 12.0f;
    CPTMutableLineStyle *axisLineStyle = [CPTMutableLineStyle lineStyle];
    axisLineStyle.lineWidth = .5f;
    axisLineStyle.lineColor = [CPTColor whiteColor];
    CPTMutableTextStyle *axisTextStyle = [[CPTMutableTextStyle alloc] init];
    axisTextStyle.color = [CPTColor whiteColor];
    axisTextStyle.fontName = @"Helvetica-Bold";
    axisTextStyle.fontSize = labelFontSize;
//    CPTMutableLineStyle *tickLineStyle = [CPTMutableLineStyle lineStyle];
//    tickLineStyle.lineColor = [CPTColor blueColor];
//    tickLineStyle.lineWidth = 1.0f;
//    CPTMutableLineStyle *gridLineStyle = [CPTMutableLineStyle lineStyle];
//    tickLineStyle.lineColor = [CPTColor redColor];
//    tickLineStyle.lineWidth = 1.0f;
//    
    // 2 - Get axis set
    CPTXYAxisSet *axisSet = (CPTXYAxisSet *) self.hostView.hostedGraph.axisSet;
    // 3 - Configure x-axis
    CPTAxis *x = axisSet.xAxis;
   // x.title = @"Day of Month";
    //x.titleTextStyle = axisTitleStyle;
    //x.titleOffset = 10.0f;
    x.axisLineStyle = axisLineStyle;
    x.labelingPolicy = CPTAxisLabelingPolicyNone;
    x.labelTextStyle = axisTextStyle;
    x.majorTickLineStyle = axisLineStyle;
    x.majorTickLength = 10.0f;
    x.tickDirection = CPTSignNegative;
   
    
    CGFloat clusterCount = [[[DataStore sharedInstance] clusterLabels] count ];
    NSMutableSet *xLabels = [NSMutableSet setWithCapacity:clusterCount];
    NSMutableSet *xLocations = [NSMutableSet setWithCapacity:clusterCount];
        
    float i = 0.0f;
    float previousCount = 0.0f;
    
    for (NSString *label in [[DataStore sharedInstance] clusterLabels]) {
        
        float count = [[DataStore sharedInstance] clusterCountWith:label];
        
        CPTAxisLabel *clusterLabel = [[CPTAxisLabel alloc] initWithText:[label uppercaseString]  textStyle:x.labelTextStyle];
        
        float b = CPTDecimalFloatValue(_trianglePlot.barWidth);
        
        if( i == 0 )
            i = ( ( b * count) )/2.0f;
        else
            i = i + (previousCount/2.0f) + b + ( ( b * count)/2.0f );
        
        previousCount = count;
        
        CGFloat location = i;
        clusterLabel.tickLocation = CPTDecimalFromCGFloat(location);
        clusterLabel.offset = x.majorTickLength;
        if (clusterLabel) {
            [xLabels addObject:clusterLabel];
            [xLocations addObject:[NSNumber numberWithFloat:location]];
        }
    }
    x.axisLabels = xLabels;
    x.labelRotation = (M_PI/2);
    x.majorTickLocations = xLocations;
    
    // 4 - Configure y-axis
    CPTAxis *y = axisSet.yAxis;
    //y.title = @"Price";
   // y.titleTextStyle = axisTitleStyle;
    //y.titleOffset = -40.0f;
    y.axisLineStyle = axisLineStyle;
   // y.majorGridLineStyle = gridLineStyle;
    y.labelingPolicy = CPTAxisLabelingPolicyNone;
//    y.labelTextStyle = axisTextStyle;
//    y.labelOffset = 16.0f;
//    y.majorTickLineStyle = axisLineStyle;
//    y.majorTickLength = 4.0f;
//    y.minorTickLength = 2.0f;
//    y.tickDirection = CPTSignNone;
//    NSInteger majorIncrement = 100;
//    NSInteger minorIncrement = 50;
//    CGFloat yMax = 700.0f;  // should determine dynamically based on max price
//    NSMutableSet *yLabels = [NSMutableSet set];
//    NSMutableSet *yMajorLocations = [NSMutableSet set];
//    NSMutableSet *yMinorLocations = [NSMutableSet set];
//    for (NSInteger j = minorIncrement; j <= yMax; j += minorIncrement) {
//        NSUInteger mod = j % majorIncrement;
//        if (mod == 0) {
//            CPTAxisLabel *label = [[CPTAxisLabel alloc] initWithText:[NSString stringWithFormat:@"%i", j] textStyle:y.labelTextStyle];
//            NSDecimal location = CPTDecimalFromInteger(j);
//            label.tickLocation = location;
//            label.offset = -y.majorTickLength - y.labelOffset;
//            if (label) {
//                [yLabels addObject:label];
//            }
//            [yMajorLocations addObject:[NSDecimalNumber decimalNumberWithDecimal:location]];
//        } else {
//            [yMinorLocations addObject:[NSDecimalNumber decimalNumberWithDecimal:CPTDecimalFromInteger(j)]];
//        }
//    }
   // y.axisLabels = yLabels;
    //y.majorTickLocations = yMajorLocations;
    //y.minorTickLocations = yMinorLocations;

    
}

#pragma mark - Annotation methods

-(void)barPlot:(CPTBarPlot *)plot barWasSelectedAtRecordIndex:(NSUInteger)index {
    
	// 1 - Is the plot hidden?
	if (plot.isHidden == YES) {
		return;
	}
	// 2 - Create style, if necessary
	static CPTMutableTextStyle *style = nil;
	if (!style) {
		style = [CPTMutableTextStyle textStyle];
		style.color= [CPTColor yellowColor];
		style.fontSize = 16.0f;
		style.fontName = @"Helvetica-Bold";
	}
    
    
    Player *player = [[DataStore sharedInstance] playerAt:index];

    
	// 3 - Create annotation, if necessary
	NSNumber *playerScore = [self numberForPlot:plot field:CPTBarPlotFieldBarTip recordIndex:index];
	if (!self.scoreAnnotation) {
		NSNumber *x = [NSNumber numberWithInt:0];
		NSNumber *y = [NSNumber numberWithInt:0];
		NSArray *anchorPoint = [NSArray arrayWithObjects:x, y, nil];
		self.scoreAnnotation = [[CPTPlotSpaceAnnotation alloc] initWithPlotSpace:plot.plotSpace anchorPlotPoint:anchorPoint];
	}
	// 4 - Create number formatter, if needed
	static NSNumberFormatter *formatter = nil;
	if (!formatter) {
		formatter = [[NSNumberFormatter alloc] init];
		[formatter setMaximumFractionDigits:2];
	}
	// 5 - Create text layer for annotation
	NSString *playerString = [formatter stringFromNumber:playerScore];
    
	CPTTextLayer *textLayer = [[CPTTextLayer alloc] initWithText:[playerString stringByAppendingFormat:@"- %@", player.rfid] style:style];
	self.scoreAnnotation.contentLayer = textLayer;
    
	// 6 - Get plot index based on identifier
    
	// 7 - Get the anchor point for annotation
	CGFloat x = index + CPDBarInitialX;
	NSNumber *anchorX = [NSNumber numberWithFloat:x];
	CGFloat y = [playerScore floatValue] + 40.0f;
	NSNumber *anchorY = [NSNumber numberWithFloat:y];
	self.scoreAnnotation.anchorPlotPoint = [NSArray arrayWithObjects:anchorX, anchorY, nil];
    
	// 8 - Add the annotation
	[plot.graph.plotAreaFrame.plotArea addAnnotation:self.scoreAnnotation];
    
    [NSTimer scheduledTimerWithTimeInterval:1
                                     target:self
                                   selector:@selector(hideAnnotation)
                                   userInfo:nil
                                    repeats:NO];
}



-(void)hideAnnotation {
	if ((_trianglePlot.graph.plotAreaFrame.plotArea) && (self.scoreAnnotation)) {
		[_trianglePlot.graph.plotAreaFrame.plotArea removeAnnotation:self.scoreAnnotation];
		self.scoreAnnotation = nil;
	}
}

-(CPTFill *)barFillForBarPlot:(CPTBarPlot *)barPlot
                  recordIndex:(NSUInteger)index {

    
    if ( [barPlot.identifier isEqual:trianglePlot] ) {
        
        NSString *color = [[DataStore sharedInstance] colorForKey:index];
        
        if( [color isEqualToString:@"blank"] )
            return [CPTFill fillWithColor:[CPTColor clearColor]];
        
        NSString* cleanedString = [color stringByReplacingOccurrencesOfString:@"#" withString:@""];


        UIColor *myColor = [UIColor colorWithHexString:cleanedString];

        
        CPTFill *fill = [CPTFill fillWithColor:[CPTColor colorWithCGColor:myColor.CGColor]];
        
        return fill;
        
    }
    return [CPTFill fillWithColor:[CPTColor colorWithComponentRed:1.0 green:1.0 blue:1.0 alpha:1.0]];
    
}



-(void)updateGraph {
    
    if( isRUNNING && currentRFIDS.count > 0 ) {
        
        //adjusted feedratio for .2 msec
        float adjustedFeedratio = [feedRatio floatValue] / 5.0f;
        
        float scoreIncrease =  adjustedFeedratio/ (float)currentRFIDS.count;
        
        [self updateFeedRatioLabelWith: ([feedRatio floatValue]/(float)currentRFIDS.count) * 60.0f];
        
        NSMutableArray *updatedArray = [NSMutableArray array];
        
        int currentPlayerCount = currentRFIDS.count;
        
        while ([updatedArray count] !=  currentPlayerCount ) {
            NSNumber *randNum = @(arc4random() % currentPlayerCount);
            if( [randNum intValue] <= currentPlayerCount) {
                
                while ([updatedArray containsObject:randNum]) {
                    randNum = @(arc4random() % currentPlayerCount);
                }
                
                [updatedArray addObject:randNum];
                
                [[DataStore sharedInstance] addScore:@( scoreIncrease ) withRFID:[currentRFIDS objectAtIndex:[randNum intValue]]];
                
                [graph reloadData];
            }
        }
    } else {
        [self updateFeedRatioLabelWith: 0.0f];
    }
}

-(void)updateFeedRatioLabelWith: (float)ratio {
    feedRatioLabel.text = @"";
    
    int intRatio = ratio;
    
    feedRatioLabel.text = [NSString stringWithFormat:@"%@ %d %@", calorieStr, intRatio, caloriePerMinuteStr];
    [feedRatioLabel setNeedsDisplay];
}

- (void)resetScoreByRFID:(NSString *)rfid {
    [[DataStore sharedInstance] resetScoreWithRFID:rfid];
    [graph reloadData];
}

-(void)startTimer {
 
    
        intervalTimer = [NSTimer scheduledTimerWithTimeInterval:.2
                                                         target:self
                                                       selector:@selector(updateGraph)
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
        }
        
        if( ! [destination isEqualToString:[self origin]] )
            return;
        
        if( event != nil) {
            if( [event isEqualToString:@"patch_init_data"]){
                NSDictionary *payload = [jsonObjects objectForKey:@"payload"];

                feedRatio = @([[payload objectForKey:@"feed-ratio"] integerValue]);
                
                NSArray *tags = [payload objectForKey:@"tags"];
                
                for (NSDictionary *tag in tags) {
                    
                    NSString *tagId = [tag objectForKey:@"tag"];
                    NSString *cluster = [tag objectForKey:@"cluster"];
                    NSString *color = [tag objectForKey:@"color"];
                    
                    [[DataStore sharedInstance] addPlayerWithRFID:tagId withCluster:cluster withColor:color];
                }
                
                [[DataStore sharedInstance] addPlayerSpacing];
                [[DataStore sharedInstance] printPlayers];
                
                //init the graph
                [self initPlot];

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

-(void)resetGame {
    [[DataStore sharedInstance] resetPlayerCount];
    [graph reloadData];
    feedRatio = @(0);
    isRUNNING = NO;
    isGAME_STOPPED = NO;
    [self sendGroupChatMessage:[self patchInitMessage]];
    [self updateFeedRatioLabelWith:0.0f];

}

@end
