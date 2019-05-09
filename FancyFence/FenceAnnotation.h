//
//  FenceAnnotation.h
//  FancyFence
//
//  Created by user148018 on 5/7/19.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import <MapKit/MapKit.h>

@interface FenceAnnotation :NSObject <MKAnnotation>

@property NSManagedObject *fence;
@property (readonly) int radius;
@property (readonly) NSString *identifier;
@property (copy, nonatomic) NSString *title;
@property (copy, nonatomic) NSString *subtitle;
@property (readonly) CLLocationCoordinate2D coordinate;

-(id)initWithFence:(NSManagedObject*)fence;

@end



