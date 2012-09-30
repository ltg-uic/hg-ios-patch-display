//
//  ViewController.h
//  xmppTemplate
//
//  Created by Anthony Perritano on 9/14/12.
//  Copyright (c) 2012 Learning Technologies Group. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CorePlot-CocoaTouch.h"

@interface RootViewController : UIViewController <CPTBarPlotDataSource, CPTBarPlotDelegate> {
    
    __weak IBOutlet UILabel *stopWatchLabel;
    __weak IBOutlet UILabel *timeIntervalLabel;
}

@property (nonatomic, strong) IBOutlet CPTGraphHostingView *hostView;
@property (nonatomic, strong) CPTBarPlot *aaplPlot;
@property (nonatomic, strong) CPTPlotSpaceAnnotation *priceAnnotation;

-(void)initPlot;
-(void)configureGraph;
-(void)configurePlots;
-(void)configureAxes;
-(void)hideAnnotation:(CPTGraph *)graph;
- (IBAction)increaseIntervalTime:(id)sender;
- (IBAction)decreaseIntervalTime:(id)sender;
- (IBAction)startAndStop:(id)sender;
- (IBAction)decrease:(id)sender;

@end
