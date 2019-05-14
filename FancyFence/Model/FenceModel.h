
#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "AppDelegate.h"
#import "FenceAnnotation.h"

@interface FenceModel : NSObject

@property (class, readonly) NSManagedObjectContext *context;

+ (void)saveModel;

+ (void)removeFence:(NSManagedObject*)fence;

@end
