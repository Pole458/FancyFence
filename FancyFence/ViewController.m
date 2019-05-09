//
//  ViewController.m
//  FancyFence
//
//  Created by user148018 on 5/1/19.
//

#import "ViewController.h"
#import "AppDelegate.h"


@interface ViewController ()

@property (nonatomic, strong) AppDelegate *appDelegate;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic) int fenceCount;
@property bool alreadyCentered;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
	//Set mapview delegate
    self.mapView.delegate = self;
  
    // Setup locationManager
    self.locationManager.delegate = self;
    
    [self loadAllFences];
    
    self.alreadyCentered = NO;
    
}

- (CLLocationManager *)locationManager{
    // Lazy loading location manager
    if(!_locationManager) _locationManager = [[CLLocationManager alloc] init];
    return _locationManager;
}

- (void)loadAllFences {
  
    // Add all pre existing fences to the mapview
    for (NSManagedObject *fence in [self.appDelegate getFences]) {
        [self addFenceAnnotation:[[FenceAnnotation alloc] initWithFence:fence]];
    }
}

- (AppDelegate*)appDelegate {
    // Lazy loading app delegate
    if(!_appDelegate) _appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    return _appDelegate;
}

- (void)setFenceCount:(int)fenceCount {
    _fenceCount = fenceCount;
    [self.addButton setEnabled: _fenceCount < 20];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"toAddFenceVC"]) {
        
        UINavigationController *nav = segue.destinationViewController;
        AddViewController *addVC = (AddViewController*)nav.topViewController;
        
        addVC.delegate = self;
        addVC.userCoordinate = self.mapView.region;
    }
}

#pragma mark - LocationManager Delegate

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    self.mapView.showsUserLocation = (status == kCLAuthorizationStatusAuthorizedAlways);
}

#pragma mark - MapView Delegate

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation {
    if(!self.alreadyCentered) {
        [self centerUserLocation];
        self.alreadyCentered = YES;
    }
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
	// Remove annotation when user taps delete button
    FenceAnnotation *annotation = view.annotation;
    [self removeFenceAnnotation:annotation];
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {

    NSString *identifier = @"fence";
    if ([annotation isKindOfClass:[FenceAnnotation class]]) {
        MKPinAnnotationView *annotationView = (MKPinAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:identifier];

        if(!annotationView) {
            annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
            annotationView.canShowCallout = YES;
            UIButton *removeButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 23, 23)];
            [removeButton setImage:[UIImage imageNamed:@"DeleteFence"] forState:normal];
            annotationView.leftCalloutAccessoryView = removeButton;
        } else {
            annotationView.annotation = annotation;
        }
        return annotationView;
    }
    return  nil;
}

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay {
   
	// Renders overlay for FenceAnnotation
    if([overlay isKindOfClass:[MKCircle class]]) {
        MKCircleRenderer *circleRenderer = [[MKCircleRenderer alloc] initWithOverlay:overlay];
        circleRenderer.lineWidth = 1.0;
        circleRenderer.strokeColor = [UIColor purpleColor];
        circleRenderer.fillColor = [[UIColor purpleColor] colorWithAlphaComponent:0.4];
        return circleRenderer;
    }
    return [[MKOverlayRenderer alloc] initWithOverlay:overlay];
}

#pragma mark - Functions that update model and view

- (void)addFenceAnnotation:(FenceAnnotation*)annotation {
	// Add fence to the model
    
    [self.mapView addAnnotation:annotation];
    [self addRadiusOverlayForFenceAnnotation:annotation];
    self.fenceCount++;
}

- (void)removeFenceAnnotation:(FenceAnnotation*)annotation {
    // Remove fence from the model
    [self.mapView removeAnnotation:annotation];
    [self removeRadiusOverlayforFenceAnnotation:annotation];
	[self stopMonitoringFence:annotation.fence];
    self.fenceCount--;
    
    NSManagedObjectContext *context = [self.appDelegate managedObjectContext];
    [context deleteObject: annotation.fence];
    NSError *error = nil;
    if (![context save:&error]) {
        NSLog(@"Couldn't save: %@", error);
    }
}

- (void)addRadiusOverlayForFenceAnnotation:(FenceAnnotation*)annotation {
	// Add circle to the annotation for radius
    [self.mapView addOverlay:[MKCircle circleWithCenterCoordinate:annotation.coordinate radius:annotation.radius]];
}

- (void)removeRadiusOverlayforFenceAnnotation:(FenceAnnotation*)annotation {
    // Remove radius overlay for annotation
    for (id<MKOverlay> overlay in [self.mapView overlays]) {
        MKCircle *circle = overlay;
		if(circle.coordinate.latitude == annotation.coordinate.latitude && circle.coordinate.longitude == annotation.coordinate.longitude && (int)(circle.radius) == annotation.radius) {
            [self.mapView removeOverlay:circle];
            break;
        }
    }
}

- (void)startMonitoring:(NSManagedObject *)fence {
    
    if(![CLLocationManager isMonitoringAvailableForClass:[CLCircularRegion class]]) {
        NSLog(@"Geofencing not supported on this device!");
        return;
    }
   
    if( CLLocationManager.authorizationStatus != kCLAuthorizationStatusAuthorizedAlways) {
        NSLog(@"Your geotification is saved but will only be activated once you grant Geotify permission to access the device location.");
    }
    
    CLCircularRegion *region = [self convert:fence];
    [self.locationManager startMonitoringForRegion:region];

}

- (void)stopMonitoringFence:(NSManagedObject*)fence {
    for (CLRegion *region in self.locationManager.monitoredRegions) {
        if(region.identifier == [fence valueForKey:@"identifier"]) {
            [self.locationManager stopMonitoringForRegion:region];
            NSLog(@"Deleted region with identifier: %@", region.identifier);
            return;
        }
    }
    
    NSLog(@"Could not delete region with identifier: %@", [fence valueForKey:@"identifier"]);
}

- (CLCircularRegion *)convert:(NSManagedObject *)fence {
    
    CLCircularRegion *region = [[CLCircularRegion alloc] initWithCenter:CLLocationCoordinate2DMake([[fence valueForKey:@"latitude"] doubleValue], [[fence valueForKey:@"longitude"] doubleValue]) radius:[[fence valueForKey:@"range"] doubleValue] identifier:[fence valueForKey:@"identifier"]];
    
    NSLog(@"Inserted region with identiier: %@", region.identifier);
    
	region.notifyOnEntry = [fence valueForKey:@"uponEntry"];
    region.notifyOnExit = !region.notifyOnEntry;   

    return region;
}

#pragma mark - AddFence Delegate

- (void)addFenceWithMessage:(NSString *)message Range:(NSNumber *)range Type:(NSNumber *)type Lat:(NSNumber *)lat Lon:(NSNumber *)lon {
    
    //Check max radius
    NSNumber *maxRange = [NSNumber numberWithDouble:self.locationManager.maximumRegionMonitoringDistance];
    NSComparisonResult result = [range compare:maxRange];
    range = (result == NSOrderedDescending) ? maxRange : range;
    
    // Create annotation and add it to the NSManagedObjectContext
    FenceAnnotation *annotation = [[FenceAnnotation alloc] initWithMessage:message Range:range Type:type Lat:lat Lon:lon WithContext:self.appDelegate.managedObjectContext];
    
    // Add annotation to the mapview
    [self addFenceAnnotation:annotation];
    
    // Start monitoring
    [self startMonitoring:annotation.fence];
    
}

#pragma mark - UI

- (IBAction)userLocationButton:(id)sender {
    [self centerUserLocation];
}

- (void)centerUserLocation {
    // Center the map to user position when it gets updated
    
    MKCoordinateRegion mapRegion;
    mapRegion.center = self.mapView.userLocation.coordinate;
    mapRegion.span.latitudeDelta = 0.2;
    mapRegion.span.longitudeDelta = 0.2;
    
    [self.mapView setRegion:mapRegion animated: YES];
}

@end

