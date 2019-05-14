//
//  FenceAnnotation.h
//  FancyFence
//
//  Created by user148018 on 5/7/19.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import <MapKit/MapKit.h>
#import "AppDelegate.h"
#import "FenceModel.h"

@interface FenceAnnotation :NSObject <MKAnnotation>



@property NSManagedObject *fence;
@property (readonly) int radius;
@property (readonly) NSString *identifier;
@property (copy, nonatomic) NSString *title;
@property (copy, nonatomic) NSString *subtitle;
@property (readonly) CLLocationCoordinate2D coordinate;
@property (readonly) NSString *entry;
@property (readonly) NSString *exit;


- (id)initWithFence:(NSManagedObject*)fence;

- (id)initWithName:(NSString *)name Range:(NSNumber *)range Lat:(NSNumber *)lat Lon:(NSNumber *)lon Entry:(NSString*)entry Exit:(NSString*)exit Identifier:(NSString*)identifier;

- (void)editWithName:(NSString *)name Range:(NSNumber *)range Lat:(NSNumber *)lat Lon:(NSNumber *)lon Entry:(NSString*)entry Exit:(NSString*)exit;

- (CLCircularRegion*)getRegion;

@end



