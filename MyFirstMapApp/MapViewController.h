//
//  ViewController.h
//  MyFirstMapApp
//
//  Created by Chris Golding on 8/3/14.
//  Copyright (c) 2014 City of Virginia Beach. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ArcGIS/ArcGIS.h>

@interface MapViewController : UIViewController <AGSMapViewLayerDelegate>
@property (strong, nonatomic) IBOutlet AGSMapView *mapView;
@property (nonatomic, strong) AGSSketchGraphicsLayer *sketchLayer;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *resetBtn;
@property (strong, nonatomic) NSString *areaName;
@property (nonatomic, strong) IBOutlet UISegmentedControl *measureMethod;

- (IBAction)resetBtnPressed:(id)sender;

@property (nonatomic, assign) double distance;
@property (nonatomic, assign) double area;
@property (nonatomic, assign) AGSSRUnit distanceUnit;
@property (nonatomic, assign) AGSAreaUnits areaUnit;

@end
