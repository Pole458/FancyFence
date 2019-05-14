
#import "FenceModel.h"

@implementation FenceModel

static NSManagedObjectContext *_context = 0;

+ (NSManagedObjectContext *)context {
    if(!_context)
        _context = ((AppDelegate *)[[UIApplication sharedApplication]delegate]).managedObjectContext;
    return _context;
}

+ (void)saveModel {
    NSError *error = nil;
    if (![FenceModel.context save:&error]) {
        NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
    }
}

+ (void)removeFence:(NSManagedObject *)fence {
    [FenceModel.context deleteObject:fence];
    
    [FenceModel saveModel];
}

@end
