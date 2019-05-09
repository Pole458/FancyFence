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

- (id)initWithMessage:(NSString *)message Range:(NSNumber *)range Type:(NSNumber *)type Lat:(NSNumber *)lat Lon:(NSNumber *)lon WithContext:(NSManagedObjectContext *)context {

    if ((self = [super init])) {
        
        // Create a new managed object
        self.fence = [NSEntityDescription insertNewObjectForEntityForName:@"Fence" inManagedObjectContext:context];
        
        [self.fence setValue:lat forKey:@"latitude"];
        [self.fence setValue:lon forKey:@"longitude"];
        [self.fence setValue:range forKey:@"range"];
        [self.fence setValue:type forKey:@"uponEntry"];
        [self.fence setValue:message forKey:@"message"];
        [self.fence setValue:[[NSUUID UUID] UUIDString] forKey:@"identifier"];
        
        NSError *error = nil;
        // Save the object to persistent store
        if (![context save:&error]) {
            NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
        }
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
