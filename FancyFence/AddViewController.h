//
//  AddViewController.h
//  FancyFence
//
//  Created by user148018 on 5/1/19.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol AddFenceViewControllerDelegate
- (void)addFenceWithMessage:(NSString*)message Range:(NSNumber*)range Type:(NSNumber*)type Lat:(NSNumber*)lat Lon:(NSNumber*)lon;
@end

@interface AddViewController : UIViewController

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UITextField *rangeTextField;
@property (weak, nonatomic) IBOutlet UITextField *messageTextField;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *typeSegControl;
@property (nonatomic, retain) id delegate;
@property (nonatomic) MKCoordinateRegion userCoordinate;

-(IBAction)cancel:(id)sender;
-(IBAction)save:(id)sender;

@end

NS_ASSUME_NONNULL_END
