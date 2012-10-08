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

@interface RootViewController : UIViewController <CPTBarPlotDataSource, CPTBarPlotDelegate, XMPPBaseNewMessageDelegate> {
    
    __weak IBOutlet UILabel *stopWatchLabel;
    __weak IBOutlet UILabel *timeIntervalLabel;
    __weak IBOutlet UIButton *startButton;
    NSTimer *intervalTimer;
    NSTimer *stopWatchTimer;
    NSDate *startDate;
    NSMutableArray *currentRFIDS;
        
    CPTGraph *graph;
    CPTXYPlotSpace *plotSpace;

}

@property (nonatomic, strong) IBOutlet CPTGraphHostingView *hostView;
@property (nonatomic, strong) CPTBarPlot *aaplPlot;
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
int scoreIncrease = 5;

NSString *  const newFoodDynamicPlot = @"newFoodDynamicPlot";

@synthesize hostView    = hostView_;
@synthesize aaplPlot    = aaplPlot_;
@synthesize priceAnnotation = priceAnnotation_;

- (AppDelegate *)appDelegate {
	return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}


#pragma mark - UIViewController lifecycle methods

-(void)viewDidLoad {
    [super viewDidLoad];
    
    self.appDelegate.xmppBaseNewMessageDelegate = self;
    currentRFIDS = [NSMutableArray array];
    [self initPlot];
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
		if ([plot.identifier isEqual:newFoodDynamicPlot]) {
            return [[DataStore sharedInstance] scoreForKey:index];
            
            
			//return [[[DataStore sharedInstance] weeklyPrices:newFoodDynamicPlot] objectAtIndex:index];
		}
	}
	return [NSDecimalNumber numberWithUnsignedInteger:index];
}

#pragma mark - CPTBarPlotDelegate methods

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
    // 3 - Create annotation, if necessary
    NSNumber *price = [self numberForPlot:plot field:CPTBarPlotFieldBarTip recordIndex:index];
    if (!self.priceAnnotation) {
        NSNumber *x = [NSNumber numberWithInt:0];
        NSNumber *y = [NSNumber numberWithInt:0];
        NSArray *anchorPoint = [NSArray arrayWithObjects:x, y, nil];
        self.priceAnnotation = [[CPTPlotSpaceAnnotation alloc] initWithPlotSpace:plot.plotSpace anchorPlotPoint:anchorPoint];
    }
    // 4 - Create number formatter, if needed
    static NSNumberFormatter *formatter = nil;
    if (!formatter) {
        formatter = [[NSNumberFormatter alloc] init];
        [formatter setMaximumFractionDigits:2];
    }
    // 5 - Create text layer for annotation
    NSString *priceValue = [formatter stringFromNumber:price];
    CPTTextLayer *textLayer = [[CPTTextLayer alloc] initWithText:priceValue style:style];
    self.priceAnnotation.contentLayer = textLayer;
    // 6 - Get plot index based on identifier
    NSInteger plotIndex = 0;
//    if ([plot.identifier isEqual:newFoodDynamicPlot] == YES) {
//        plotIndex = 0;
//    }
    // 7 - Get the anchor point for annotation
    CGFloat x = index + CPDBarInitialX + (plotIndex * CPDBarWidth);
    NSNumber *anchorX = [NSNumber numberWithFloat:x];
    CGFloat y = [price floatValue] + 40.0f;
    NSNumber *anchorY = [NSNumber numberWithFloat:y];
    self.priceAnnotation.anchorPlotPoint = [NSArray arrayWithObjects:anchorX, anchorY, nil];
    // 8 - Add the annotation 
    [plot.graph.plotAreaFrame.plotArea addAnnotation:self.priceAnnotation];
}

#pragma mark - Chart behavior

-(void)initPlot {
    //hostView_.allowPinchScaling = NO;
    [self configureGraph];
    [self configurePlots];
    [self configureAxes];
    [self.aaplPlot setHidden:NO];
}

-(void)configureGraph {
    // 1 - Create the graph
    graph = [[CPTXYGraph alloc] initWithFrame:self.hostView.bounds];
    graph.plotAreaFrame.masksToBorder = NO;
    
    
    hostView_.hostedGraph = graph;
    // 2 - Configure the graph
    [graph applyTheme:[CPTTheme themeNamed:kCPTSlateTheme]];
    graph.paddingBottom = 10.0f;
    graph.paddingLeft  = 10.0f;
    graph.paddingTop    = 1.0f;
    graph.paddingRight  = 5.0f;
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
    CGFloat xMax = [[DataStore sharedInstance] playerCount];
    CGFloat yMin = 0.0f;
    CGFloat yMax = 800.0f;  // should determine dynamically based on max price
    plotSpace = (CPTXYPlotSpace *) graph.defaultPlotSpace;
    plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(xMin) length:CPTDecimalFromFloat(xMax)];
    plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(yMin) length:CPTDecimalFromFloat(yMax)];
}

-(void)configurePlots {
    // 1 - Set up the three plots
    self.aaplPlot = [CPTBarPlot tubularBarPlotWithColor:[CPTColor greenColor] horizontalBars:NO];
    self.aaplPlot.identifier = newFoodDynamicPlot;

    // 2 - Set up line style
    CPTMutableLineStyle *barLineStyle = [[CPTMutableLineStyle alloc] init];
    barLineStyle.lineColor = [CPTColor lightGrayColor];
    barLineStyle.lineWidth = 0.1;
    // 3 - Add plots to graph
    graph = self.hostView.hostedGraph;
    CGFloat barX = CPDBarInitialX;
    NSArray *plots = [NSArray arrayWithObjects:self.aaplPlot, nil];
    for (CPTBarPlot *plot in plots) {
        plot.dataSource = self;
        plot.delegate = self;
        plot.barWidth = CPTDecimalFromDouble(CPDBarWidth);
        plot.barOffset = CPTDecimalFromDouble(CPDBarInitialX);
        plot.lineStyle = barLineStyle;
        [graph addPlot:plot toPlotSpace:graph.defaultPlotSpace];
       // barX += CPDBarWidth;
    }
    
}

-(void)configureAxes {
    
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
    
    for( NSString *rfid in currentRFIDS) {
        [[DataStore sharedInstance] addScore:[NSNumber numberWithInt:scoreIncrease] withRFID:rfid];
    }
    
    
    [graph reloadData];
}

#pragma mark - Actions


- (void)increaseByRFID:(NSString *)rfid {
    
    [[DataStore sharedInstance] addScore:[NSNumber numberWithInt:scoreIncrease] withRFID:rfid];
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
    
    NSString *msg = [messageContent objectForKey:@"msg"];
    
    
    NSArray *wordsAndEmptyStrings = [msg componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSArray *words = [wordsAndEmptyStrings filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"length > 0"]];
    
    
    if( [words[0] isEqualToString:@"add"]) {
        
        if([startButton.currentTitle isEqualToString:@"start"]) {
            [self startAndStop:nil];
        }
        
        [self addRFID:words[1]];
        [self increaseByRFID: words[1]];
    } else if( [words[0] isEqualToString:@"subtract"]) {
        
       
        [self decreaseByRFID: words[1]];
        [currentRFIDS removeObject:words[1]];
        
       
    }
    NSLog(@"message %@", msg);
    
    
}

-(void)addRFID: (NSString *)newRFID {
    for( NSString *rfid in currentRFIDS) {
        if( [rfid isEqualToString:newRFID]){
            return;
        }
    }
    [currentRFIDS addObject:newRFID];

}

- (void)replyMessageTo:(NSString *)from {
    
}


@end
