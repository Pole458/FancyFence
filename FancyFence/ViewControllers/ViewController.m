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

#pragma mark - Lazy Loading

- (CLLocationManager *)locationManager {
    // Lazy loading location manager
    if(!_locationManager) _locationManager = [[CLLocationManager alloc] init];
    return _locationManager;
}

- (AppDelegate*)appDelegate {
    // Lazy loading app delegate
    if(!_appDelegate) _appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    return _appDelegate;
}

- (void)loadAllFences {
    // Add all pre existing fences to the mapview
    for (NSManagedObject *fence in [self.appDelegate getFences]) {
        [self addFenceAnnotation:[[FenceAnnotation alloc] initWithFence:fence]];
    }
}

- (void)setFenceCount:(int)fenceCount {
    // The Geofencing API is limited to 20 monitored regions
    _fenceCount = fenceCount;
    [self.addButton setEnabled: _fenceCount < 20];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    UINavigationController *nav = segue.destinationViewController;
    AddViewController *fenceVC = (AddViewController*)nav.topViewController;
    fenceVC.delegate = self;
    
    if ([segue.identifier isEqualToString:@"toAddFenceVC"]) {
        
        fenceVC.userRegion = self.mapView.region;
    }
    
    if ([[segue identifier] isEqualToString:@"toEditFenceVC"]) {
        
        fenceVC.annotation = (FenceAnnotation*)sender;
        fenceVC.userRegion = self.mapView.region;
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
    FenceAnnotation *annotation = view.annotation;
    
    if(view.leftCalloutAccessoryView == control) {
        // Remove annotation when user taps delete button
        [self removeFenceAnnotation:annotation];
    }
    
    if(view.rightCalloutAccessoryView == control) {
        //Open FenceVC to edit selected fence
        [self performSegueWithIdentifier:@"toEditFenceVC" sender:annotation];
    }
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
            
            UIButton *editButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 23, 23)];
            [editButton setImage:[UIImage imageNamed:@"compose"] forState:normal];
            annotationView.rightCalloutAccessoryView = editButton;
            
        } else {
            annotationView.annotation = annotation;
        }
        return annotationView;
    }
    return nil;
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
	// Add fence
    
    [self.mapView addAnnotation:annotation];
    [self addRadiusOverlayForFenceAnnotation:annotation];
    self.fenceCount++;
}

- (void)removeFenceAnnotation:(FenceAnnotation*)annotation {
    // Remove fence
    [self.mapView removeAnnotation:annotation];
    [self removeRadiusOverlayforFenceAnnotation:annotation];
	[self stopMonitoringFence:annotation];
    self.fenceCount--;
    
    [FenceModel removeFence:annotation.fence];
}

- (void)addRadiusOverlayForFenceAnnotation:(FenceAnnotation*)annotation {
    [self.mapView addOverlay:[MKCircle circleWithCenterCoordinate:annotation.coordinate radius:annotation.radius]];
}

- (void)removeRadiusOverlayforFenceAnnotation:(FenceAnnotation*)annotation {
    for (id<MKOverlay> overlay in [self.mapView overlays]) {
        MKCircle *circle = overlay;
		if(circle.coordinate.latitude == annotation.coordinate.latitude && circle.coordinate.longitude == annotation.coordinate.longitude && (int)(circle.radius) == annotation.radius) {
            [self.mapView removeOverlay:circle];
            break;
        }
    }
}

- (void)startMonitoring:(FenceAnnotation *)annotation {
    
    if(![CLLocationManager isMonitoringAvailableForClass:[CLCircularRegion class]]) {
        NSLog(@"Geofencing not supported on this device!");
        return;
    }
   
    if( CLLocationManager.authorizationStatus != kCLAuthorizationStatusAuthorizedAlways) {
        NSLog(@"Your geotification is saved but will only be activated once you grant Geotify permission to access the device location.");
    }

    [self.locationManager startMonitoringForRegion:[annotation getRegion]];

}

- (void)stopMonitoringFence:(FenceAnnotation*)annotation {
    for (CLRegion *region in self.locationManager.monitoredRegions) {
        if([region.identifier isEqualToString:annotation.identifier]) {
            [self.locationManager stopMonitoringForRegion:region];
            return;
        }
    }
}

#pragma mark - AddFence Delegate

- (void)addFenceWithName:(NSString *)name Radius:(NSNumber *)radius Lat:(NSNumber *)lat Lon:(NSNumber *)lon Entry:(NSString *)entry Exit:(NSString *)exit Identifier:(NSString *)identifier{
    
    //Check max radius
    NSNumber *maxRange = [NSNumber numberWithDouble:self.locationManager.maximumRegionMonitoringDistance];
    NSComparisonResult result = [radius compare:maxRange];
    radius = (result == NSOrderedDescending) ? maxRange : radius;
    
    // Create annotation and add it to the NSManagedObjectContext
    FenceAnnotation *annotation = [[FenceAnnotation alloc] initWithName:name Range:radius Lat:lat Lon:lon Entry:entry Exit:exit Identifier:identifier];
    
    // Add annotation to the mapview
    [self addFenceAnnotation:annotation];
    
    // Start monitoring
    [self startMonitoring:annotation];
    
}

- (void)editFence:(FenceAnnotation *)annotation withName:(NSString *)name Radius:(NSNumber *)radius Lat:(NSNumber *)lat Lon:(NSNumber *)lon Entry:(NSString *)entry Exit:(NSString *)exit {
    
    [self.mapView removeAnnotation:annotation];
    [self removeRadiusOverlayforFenceAnnotation:annotation];
    [self stopMonitoringFence:annotation];
    
    //Check max radius
    NSNumber *maxRange = [NSNumber numberWithDouble:self.locationManager.maximumRegionMonitoringDistance];
    NSComparisonResult result = [radius compare:maxRange];
    radius = (result == NSOrderedDescending) ? maxRange : radius;
    
    [annotation editWithName:name Range:radius Lat:lat Lon:lon Entry:entry Exit:exit];
    
    // Add annotation to the mapview
    [self.mapView addAnnotation:annotation];
    [self addRadiusOverlayForFenceAnnotation:annotation];
    
    // Start monitoring
    [self startMonitoring:annotation];
    
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

