//
//  ViewController.m
//  MyFirstMapApp
//
//  Created by Chris Golding on 8/3/14.
//  Copyright (c) 2014 City of Virginia Beach. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    // Register for geometry changed notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(respondToGeomChanged:) name:AGSSketchGraphicsLayerGeometryDidChangeNotification object:nil];
    
    //Add a basemap tiled layer
    NSURL* url = [NSURL URLWithString:@"http://server.arcgisonline.com/ArcGIS/rest/services/World_Topo_Map/MapServer"];
    AGSTiledMapServiceLayer *tiledLayer = [AGSTiledMapServiceLayer tiledMapServiceLayerWithURL:url];
    [self.mapView addMapLayer:tiledLayer withName:@"Basemap Tiled Layer"];

    
    AGSEnvelope *vbEnv = [AGSEnvelope envelopeWithXmin:-75.872749
                                                     ymin:36.562283
                                                     xmax:-76.240791
                                                     ymax:36.923781
                                         spatialReference:[AGSSpatialReference wgs84SpatialReference]];
    [self.mapView zoomToEnvelope:vbEnv animated:YES];
    
    self.mapView.layerDelegate = self;
    
    // Set the default measures and units
    self.distance = 0;
    self.area = 0;
    self.distanceUnit = AGSSRUnitSurveyMile;
    self.areaUnit = AGSAreaUnitsAcres;
    
    self.resetBtn.enabled = false;
}

- (void)mapViewDidLoad:(AGSMapView *) mapView {
    //do something now that the map is loaded
    //for example, show the current location on the map
    [mapView.locationDisplay startDataSource];
    
    // Create and add a sketch layer to the map
    self.sketchLayer = [AGSSketchGraphicsLayer graphicsLayer];
    self.sketchLayer.geometry = [[AGSMutablePolyline alloc] initWithSpatialReference:self.mapView.spatialReference];
    [self.mapView addMapLayer:self.sketchLayer withName:@"Sketch layer"];
    self.mapView.touchDelegate = self.sketchLayer;
    
    self.sketchLayer.geometry = [[AGSMutablePolygon alloc] initWithSpatialReference:self.mapView.spatialReference];
}

- (void)respondToGeomChanged:(NSNotification*)notification {
    
    // Enable/Disable redo, undo, and add buttons
//    self.undoButton.enabled = [self.sketchLayer.undoManager  canUndo];
//    self.redoButton.enabled = [self.sketchLayer.undoManager canRedo];
    self.resetBtn.enabled = ![self.sketchLayer.geometry isEmpty] && self.sketchLayer.geometry !=nil;
    
    //return if we don't have a valid geometry yet
    //polyline must have atleast 2 vertices, polygon must have atleast 3
    AGSGeometry *sketchGeometry = self.sketchLayer.geometry;
    if (![sketchGeometry isValid]) {
        return;
    }
    
    // Update the distance and area whenever the geometry changes
    if ([sketchGeometry isKindOfClass:[AGSMutablePolyline class]]) {
        [self updateDistance:self.distanceUnit];
    }
    else if ([sketchGeometry isKindOfClass:[AGSMutablePolygon class]]){
        [self updateArea:self.areaUnit];
    }
}

- (void)updateDistance:(AGSSRUnit)unit {
    
    // Get the sketch layer's geometry
    AGSGeometry *sketchGeometry = self.sketchLayer.geometry;
    AGSGeometryEngine *geometryEngine = [AGSGeometryEngine defaultGeometryEngine];
    
    // Get the geodesic distance of the current line
    self.distance = [geometryEngine geodesicLengthOfGeometry:sketchGeometry inUnit:self.distanceUnit];
    
    // Display the current unit
    NSString *distanceUnitString = nil;
    switch (self.distanceUnit) {
        case AGSSRUnitSurveyMile:
            distanceUnitString = @"Miles";
            break;
        case AGSSRUnitSurveyYard:
            distanceUnitString = @"Yards";
            break;
        case AGSSRUnitSurveyFoot:
            distanceUnitString = @"Feet";
            break;
        case AGSSRUnitKilometer:
            distanceUnitString = @"Kilometers";
            break;
        case AGSSRUnitMeter:
            distanceUnitString = @"Meters";
            break;
        default:
            break;
    }
    
    NSNumberFormatter* formatter = [[NSNumberFormatter alloc] init];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    [formatter setMaximumFractionDigits:0];
    
//    self.userInstructions.text = [NSString stringWithFormat:@"%@", [formatter stringFromNumber:[NSNumber numberWithDouble:self.distance]]];
//    [self.selectUnitButton setTitle:distanceUnitString forState:UIControlStateNormal];
    self.title = [NSString stringWithFormat:@"%@ %@", [formatter stringFromNumber:[NSNumber numberWithDouble:self.distance]], distanceUnitString];

    
}

- (void)updateArea:(AGSAreaUnits)unit {
    
    // Get the sketch layer's geometry
    AGSGeometry *sketchGeometry = self.sketchLayer.geometry;
    AGSGeometryEngine *geometryEngine = [AGSGeometryEngine defaultGeometryEngine];
    
    // Get the area of the current polygon
    self.area = [geometryEngine shapePreservingAreaOfGeometry:sketchGeometry inUnit:self.areaUnit];
    
    // Display the current unit
    NSString *areaUnitString = nil;
    switch (self.areaUnit) {
        case AGSAreaUnitsSquareMiles:
            areaUnitString = @"Square Miles";
            break;
        case AGSAreaUnitsAcres:
            areaUnitString = @"Acres";
            break;
        case AGSAreaUnitsSquareYards:
            areaUnitString = @"Square Yards";
            break;
        case AGSAreaUnitsSquareKilometers:
            areaUnitString = @"Square Kilometers";
            break;
        case AGSAreaUnitsSquareMeters:
            areaUnitString = @"Square Meters";
        default:
            break;
    }
    
    NSNumberFormatter* formatter = [[NSNumberFormatter alloc] init];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    [formatter setMaximumFractionDigits:0];
    
//    self.userInstructions.text = [NSString stringWithFormat:@"%@", [formatter stringFromNumber:[NSNumber numberWithDouble:self.area]]];
//    [self.selectUnitButton setTitle:areaUnitString forState:UIControlStateNormal];
    self.title = [NSString stringWithFormat:@"%@ %@", [formatter stringFromNumber:[NSNumber numberWithDouble:self.area]], areaUnitString];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)resetBtnPressed:(id)sender {
    self.title = @"";
    [self.sketchLayer clear];
}

@end
