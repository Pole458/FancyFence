
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


#pragma mark - Queries

+ (NSArray*)getFences {
    // Fetch all the fences from persistent data store
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Fence"];
    NSMutableArray *fences = [[NSMutableArray alloc] initWithCapacity:0];
    
    for (NSManagedObject *fence in [[FenceModel.context executeFetchRequest:fetchRequest error:nil] mutableCopy]) {
        [fences addObject:[[FenceAnnotation alloc] initWithFence:fence]];
    }
    
    return fences;
}

+ (id)getFenceWithIdentifier:(NSString*)identifier {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Fence"];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat: @"%K == %@", @"identifier", identifier];
    [fetchRequest setPredicate:predicate];
    
    return [[FenceAnnotation alloc] initWithFence:[[FenceModel.context executeFetchRequest:fetchRequest error:nil] mutableCopy][0]];
}

+ (void)exportAsCSV {
    NSArray *fences = [FenceModel getFences];
    NSMutableString *csv = [[NSMutableString alloc] initWithCapacity:0];
    for (FenceAnnotation *fence in fences) {
        [csv appendString:[fence getCSV]];
    }
    
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = csv;
}

+ (NSArray*)importAsCSV {
    
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    NSString *csv = pasteboard.string;
    
    NSMutableArray *fences = [[NSMutableArray alloc] initWithCapacity:0];
    
    NSArray* rows = [csv componentsSeparatedByString:@"\n"];
    for (NSString *row in rows){
        
        NSArray* columns = [row componentsSeparatedByString:@","];
        
        if(columns.count == 6) {
            NSString *name = columns[0];
            NSString *entry = columns[1];
            NSString *exit = columns[2];
            NSNumber *radius = [NSNumber numberWithInt: [columns[3] intValue]];
            NSNumber *lat = [NSNumber numberWithDouble:[columns[4] doubleValue]];
            NSNumber *lon = [NSNumber numberWithDouble:[columns[5] doubleValue]];
            
            [fences addObject:[[FenceAnnotation alloc] initWithName:name Range:radius Lat:lat Lon:lon Entry:entry Exit:exit]];
        }
    }
    
    return fences;
}

@end
