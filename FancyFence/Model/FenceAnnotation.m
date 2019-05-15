//
//  NSObject+FenceAnnotation.h
//  FancyFence
//
//  Created by user148018 on 5/7/19.
//

#import "FenceAnnotation.h"

@interface FenceAnnotation ()

@end

@implementation FenceAnnotation


- (id)initWithFence:(NSManagedObject*)fence {
    
    if ((self = [super init])) {
        self.fence = fence;
    }
    return self;
}

- (id)initWithName:(NSString *)name Range:(NSNumber *)range Lat:(NSNumber *)lat Lon:(NSNumber *)lon Entry:(NSString *)entry Exit:(NSString *)exit {

    if ((self = [super init])) {
        
        // Create a new managed object
        self.fence = [NSEntityDescription insertNewObjectForEntityForName:@"Fence" inManagedObjectContext:FenceModel.context];
        
        [self.fence setValue:name forKey:@"name"];
        [self.fence setValue:range forKey:@"range"];
        [self.fence setValue:lat forKey:@"latitude"];
        [self.fence setValue:lon forKey:@"longitude"];
        [self.fence setValue:entry forKey:@"entry"];
        [self.fence setValue:exit forKey:@"exit"];
        [self.fence setValue:[[NSUUID UUID] UUIDString] forKey:@"identifier"];
        
        // Save the object to persistent store
        [FenceModel saveModel];
    }
    return self;
}

- (void)editWithName:(NSString *)name Range:(NSNumber *)range Lat:(NSNumber *)lat Lon:(NSNumber *)lon Entry:(NSString *)entry Exit:(NSString *)exit {
    
    [self.fence setValue:name forKey:@"name"];
    [self.fence setValue:range forKey:@"range"];
    [self.fence setValue:lat forKey:@"latitude"];
    [self.fence setValue:lon forKey:@"longitude"];
    [self.fence setValue:entry forKey:@"entry"];
    [self.fence setValue:exit forKey:@"exit"];
    
    // Save the object to persistent store
    [FenceModel saveModel];
}

-(int)radius {
    return [[self.fence valueForKey:@"range"] intValue];
}

-(NSString *)identifier {
    return [self.fence valueForKey:@"identifier"];
}

-(NSString *)title {
    return [self.fence valueForKey:@"name"];
}

-(NSString *)subtitle {

    NSMutableString *sub = [[NSMutableString alloc] initWithString:[NSString stringWithFormat:@"Radius: %d m", self.radius]];
    
//    if([[self.fence valueForKey:@"uponEntry"] boolValue]) {
//        [sub appendString:@", upon Entry"];
//    } else {
//        [sub appendString:@", upon Exit"];
//    }
    
    return sub;
}

- (NSString *)entry {
    return [self.fence valueForKey:@"entry"];
}

- (NSString *)exit {
    return [self.fence valueForKey:@"exit"];
}

-(CLLocationCoordinate2D)coordinate {
    return CLLocationCoordinate2DMake([[self.fence valueForKey:@"latitude"] doubleValue], [[self.fence valueForKey:@"longitude"] doubleValue]);
}

- (CLCircularRegion *)getRegion {
    
    CLCircularRegion *region = [[CLCircularRegion alloc] initWithCenter:self.coordinate radius:[[self.fence valueForKey:@"range"] doubleValue] identifier:self.identifier];
    
    region.notifyOnEntry = ![self.entry isEqual:@""];
    region.notifyOnExit = ![self.exit isEqual:@""];
    
    return region;
}

- (NSString *)getCSV {
    return [NSString stringWithFormat:@"%@,%@,%@,%d,%f,%f\n",self.title, self.entry, self.exit, self.radius, self.coordinate.latitude, self.coordinate.longitude];
}

@end
