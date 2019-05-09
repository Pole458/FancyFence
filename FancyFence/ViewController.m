//
//  ViewController.m
//  FancyFence
//
//  Created by user148018 on 5/1/19.
//

#import "ViewController.h"
#import "AppDelegate.h"


@interface ViewController ()

@property (nonatomic, strong) CLLocationManager *locationManager;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
	//Set mapview delegate
    self.mapView.delegate = self;
  
    // Setup locationManager
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    [self.locationManager requestAlwaysAuthorization];
    
    [self loadAllFences];
}

- (void)loadAllFences {
    // Fetch the fences from persistent data store
    AppDelegate *objAppDel = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    NSManagedObjectContext *context = [objAppDel managedObjectContext];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Fence"];
    
    for (NSManagedObject *fence in [[context executeFetchRequest:fetchRequest error:nil] mutableCopy]) {
        [self addFenceAnnotation:[[FenceAnnotation alloc] initWithFence:fence]];
    }
}

- (CLLocationManager *)locationManager{
	// Lazy loading location manager
    if(!_locationManager) _locationManager = [[CLLocationManager alloc] init];
    return _locationManager;
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
	// Center the map to user position when it gets updated
	
    MKCoordinateRegion mapRegion;
    mapRegion.center = mapView.userLocation.coordinate;
    mapRegion.span.latitudeDelta = 0.2;
    mapRegion.span.longitudeDelta = 0.2;
    
    [mapView setRegion:mapRegion animated: YES];
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

#pragma mark Functions that update model and view

- (void)addFenceAnnotation:(FenceAnnotation*)annotation {
	// Add fence to the model
    [self.mapView addAnnotation:annotation];
    [self addRadiusOverlayForFenceAnnotation:annotation];
	[self startMonitoring:annotation.fence];
    [self updateFenceCount];
}

- (void)removeFenceAnnotation:(FenceAnnotation*)annotation {
    // Remove fence from the model
    [self.mapView removeAnnotation:annotation];
    [self removeRadiusOverlayforFenceAnnotation:annotation];
	[self stopMonitoringFence:annotation.fence];
    [self updateFenceCount];
    
    AppDelegate *objAppDel = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    NSManagedObjectContext *context = [objAppDel managedObjectContext];
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

- (void)updateFenceCount {
	//TODO
//    title = "Geotifications: \(geotifications.count)"
//    navigationItem.rightBarButtonItem?.isEnabled = (geotifications.count < 20)
}

- (void)startMonitoring:(NSManagedObject *)fence {
    
    CLCircularRegion *region = [self convert:fence];
    [self.locationManager startMonitoringForRegion:region];

}

- (void)stopMonitoringFence:(NSManagedObject*)fence {
    for (CLRegion *region in self.locationManager.monitoredRegions) {
        if(region.identifier == [fence valueForKey:@"identifier"]) {
            [self.locationManager stopMonitoringForRegion:region];
            break;
        }
    }
}

- (CLCircularRegion *)convert:(NSManagedObject *)fence {
    
    CLCircularRegion *region = [[CLCircularRegion alloc] initWithCenter:CLLocationCoordinate2DMake([[fence valueForKey:@"latitude"] doubleValue], [[fence valueForKey:@"longitude"] doubleValue]) radius:[[fence valueForKey:@"range"] doubleValue] identifier:[fence valueForKey:@"message"]];
    
	region.notifyOnEntry = [fence valueForKey:@"uponEntry"];
    region.notifyOnExit = !region.notifyOnEntry;   

    return region;
}

#pragma mark - AddFence Delegate

- (void)addFenceWithMessage:(NSString *)message Range:(NSNumber *)range Type:(NSNumber *)type Lat:(NSNumber *)lat Lon:(NSNumber *)lon {
    
    AppDelegate *objAppDel = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    NSManagedObjectContext *context = [objAppDel managedObjectContext];
    
    // Create a new managed object
    NSManagedObject *newFence = [NSEntityDescription insertNewObjectForEntityForName:@"Fence" inManagedObjectContext:context];
    
    [newFence setValue:lat forKey:@"latitude"];
    [newFence setValue:lon forKey:@"longitude"];
    [newFence setValue:range forKey:@"range"];	//clamp radius here
    [newFence setValue:type forKey:@"uponEntry"];
    [newFence setValue:message forKey:@"message"];
    [newFence setValue:[[NSUUID UUID] UUIDString] forKey:@"identifier"];
    
    NSError *error = nil;
    // Save the object to persistent store
    if (![context save:&error]) {
        NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
    }
    
    FenceAnnotation *annotation = [[FenceAnnotation alloc] initWithFence:newFence];
    [self addFenceAnnotation:annotation];
    
}

@end

