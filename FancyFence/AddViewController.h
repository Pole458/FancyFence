//
//  AddViewController.h
//  FancyFence
//
//  Created by user148018 on 5/1/19.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface AddViewController : UIViewController

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UITextField *rangeTextField;
@property (weak, nonatomic) IBOutlet UITextField *entryTextField;
@property (weak, nonatomic) IBOutlet UITextField *exitTextField;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

-(IBAction)cancel:(id)sender;
-(IBAction)save:(id)sender;

@end

NS_ASSUME_NONNULL_END
