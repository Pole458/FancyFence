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

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

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

        point.title = [fence valueForKey:@"uponEntry"];
        point.subtitle = [fence valueForKey:@"uponExit"];
        point.coordinate = CLLocationCoordinate2DMake([[fence valueForKey:@"latitude"] doubleValue], [[fence valueForKey:@"longitude"] doubleValue]);

        [self.mapView addAnnotation:point];
    }
}

@end

