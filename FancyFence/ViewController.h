//
//  ViewController.h
//  FancyFence
//
//  Created by user148018 on 5/1/19.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "AddViewController.h"
#import "FenceAnnotation.h"

@interface ViewController : UIViewController <CLLocationManagerDelegate, MKMapViewDelegate, AddFenceViewControllerDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@end

