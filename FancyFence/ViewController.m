//
//  ViewController.m
//  FancyFence
//
//  Created by user148018 on 5/1/19.
//

#import "ViewController.h"
#import <CoreData/CoreData.h>
#import "AppDelegate.h"


@interface ViewController ()

@property (strong) NSMutableArray *fences;
@property (nonatomic, strong) CLLocationManager *locationManager;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.mapView.delegate = self;
    
    // Setup locationManager
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    [self.locationManager requestAlwaysAuthorization];

}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // Fetch the fences from persistent data store
    AppDelegate *objAppDel = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    NSManagedObjectContext *context = [objAppDel managedObjectContext];

    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Fence"];
    self.fences = [[context executeFetchRequest:fetchRequest error:nil] mutableCopy];
    
    for (NSManagedObject *fence in self.fences) {

        MKPointAnnotation *point = [[MKPointAnnotation alloc] init];

        point.title = [fence valueForKey:@"message"];
        point.coordinate = CLLocationCoordinate2DMake([[fence valueForKey:@"latitude"] doubleValue], [[fence valueForKey:@"longitude"] doubleValue]);

        [self.mapView addAnnotation:point];
    }
}

- (CLLocationManager *)locationManager{
    if(!_locationManager) _locationManager = [[CLLocationManager alloc] init];
    return _locationManager;
}
         
- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation {
    MKCoordinateRegion mapRegion;
    mapRegion.center = mapView.userLocation.coordinate;
    mapRegion.span.latitudeDelta = 0.2;
    mapRegion.span.longitudeDelta = 0.2;
    
    [mapView setRegion:mapRegion animated: YES];
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    self.mapView.showsUserLocation = (status == kCLAuthorizationStatusAuthorizedAlways);
}

- (void)startMonitoring:(NSManagedObject *)fence {
   
    CLCircularRegion *region = [self convert:fence];
    [self.locationManager startMonitoringForRegion:region];

}

- (CLCircularRegion *)convert:(NSManagedObject *)fence {
    
    CLCircularRegion *region = [[CLCircularRegion alloc] initWithCenter:CLLocationCoordinate2DMake([[fence valueForKey:@"latitude"] doubleValue], [[fence valueForKey:@"longitude"] doubleValue]) radius:[[fence valueForKey:@"range"] doubleValue] identifier:[fence valueForKey:@"message"]];
    
    region.notifyOnExit = ![fence valueForKey:@"uponEntry"];
    region.notifyOnEntry = [fence valueForKey:@"uponEntry"];
    
    return region;
}

- (void)addFenceWithMessage:(NSString *)message Range:(NSNumber *)range Type:(NSNumber *)type Lat:(NSNumber *)lat Lon:(NSNumber *)lon {
    
    AppDelegate *objAppDel = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    NSManagedObjectContext *context = [objAppDel managedObjectContext];
    
    // Create a new managed object
    NSManagedObject *newFence = [NSEntityDescription insertNewObjectForEntityForName:@"Fence" inManagedObjectContext:context];
    
    [newFence setValue:lat forKey:@"latitude"];
    [newFence setValue:lon forKey:@"longitude"];
    [newFence setValue:range forKey:@"range"];
    [newFence setValue:type forKey:@"uponEntry"];
    [newFence setValue:message forKey:@"message"];
    
    NSError *error = nil;
    // Save the object to persistent store
    if (![context save:&error]) {
        NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
    }
}

 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
     
     if ([segue.identifier isEqualToString:@"toAddFenceVC"]) {
         
         UINavigationController *nav = segue.destinationViewController;
         AddViewController *addVC = (AddViewController*)nav.topViewController;
         
         addVC.delegate = self;
         addVC.userCoordinate = self.mapView.region;
     }
 }

@end
