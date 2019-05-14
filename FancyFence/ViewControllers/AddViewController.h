//
//  AddViewController.h
//  FancyFence
//
//  Created by user148018 on 5/1/19.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "FenceAnnotation.h"

NS_ASSUME_NONNULL_BEGIN

@protocol AddFenceViewControllerDelegate

- (void)addFenceWithName:(NSString*)name Radius:(NSNumber*)range Lat:(NSNumber*)lat Lon:(NSNumber*)lon Entry:(NSString*)entry Exit:(NSString*)exit Identifier:(NSString*)identifier;

- (void)editFence:(FenceAnnotation*)annotation withName:(NSString*)name Radius:(NSNumber*)radius Lat:(NSNumber*)lat Lon:(NSNumber*)lon Entry:(NSString*)entry Exit:(NSString*)exit;

@end

@interface AddViewController : UIViewController

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *rangeTextField;
@property (weak, nonatomic) IBOutlet UITextField *entryTextField;
@property (weak, nonatomic) IBOutlet UITextField *exitTextField;


@property (nonatomic, retain) id delegate;

@property MKCoordinateRegion userRegion;
@property FenceAnnotation *annotation;

- (IBAction)cancel:(id)sender;
- (IBAction)save:(id)sender;

@end

NS_ASSUME_NONNULL_END
