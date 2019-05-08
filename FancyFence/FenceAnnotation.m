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

- (id)initWithFence:(NSManagedObject *)fence {
    
    if ((self = [super init])) {
        self.fence = fence;
//        self.coordinate = CLLocationCoordinate2DMake([[fence valueForKey:@"latitude"] doubleValue], [[fence valueForKey:@"longitude"] doubleValue]);

    }
    return self;
}

-(int)radius {
    return [[self.fence valueForKey:@"range"] intValue];
}

-(NSString *)identifier {
    return [self.fence valueForKey:@"identifier"];
}

-(NSString *)title {
    return [self.fence valueForKey:@"message"];
}

-(NSString *)subtitle {

    NSMutableString *sub = [[NSMutableString alloc] initWithString:[NSString stringWithFormat:@"Radius: %d", self.radius]];
    
    if([[self.fence valueForKey:@"uponEntry"] boolValue]) {
        [sub appendString:@", upon Entry"];
    } else {
        [sub appendString:@", upon Exit"];
    }
    
    return sub;
}

-(CLLocationCoordinate2D)coordinate {
    return CLLocationCoordinate2DMake([[self.fence valueForKey:@"latitude"] doubleValue], [[self.fence valueForKey:@"longitude"] doubleValue]);
}

@end
