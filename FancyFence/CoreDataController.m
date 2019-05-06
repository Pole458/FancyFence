//
//  CoreDataController.m
//  FancyFence
//
//  Created by user148018 on 5/2/19.
//

//
//  CoreDataController.m
//
//  Created by Keith Harrison http://useyourloaf.com
//  Copyright (c) 2016 Keith Harrison. All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without
//  modification, are permitted provided that the following conditions are met:
//
//  1. Redistributions of source code must retain the above copyright
//  notice, this list of conditions and the following disclaimer.
//
//  2. Redistributions in binary form must reproduce the above copyright
//  notice, this list of conditions and the following disclaimer in the
//  documentation and/or other materials provided with the distribution.
//
//  3. Neither the name of the copyright holder nor the names of its
//  contributors may be used to endorse or promote products derived from
//  this software without specific prior written permission.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
//  AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
//  IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
//  ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
//  LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
//  CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
//  SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
//  INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
//  CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
//  ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
//  POSSIBILITY OF SUCH DAMAGE.

#import "CoreDataController.h"

@interface CoreDataController ()
@property (nonatomic, getter=isStoreLoaded) BOOL storeLoaded;
@property (nonatomic, strong) NSPersistentContainer *persistentContainer;
@end

@implementation CoreDataController

+ (NSURL *)defaultDirectoryURL {
    return [NSPersistentContainer defaultDirectoryURL];
}

- (instancetype)initWithName:(NSString *)name {
    
    NSManagedObjectModel *mom = [NSManagedObjectModel mergedModelFromBundles:nil];
    if (mom == nil) return nil;
    
    self = [super init];
    if (self) {
        _storeLoaded = NO;
        _shouldAddStoreAsynchronously = YES;
        _shouldMigrateStoreAutomatically = YES;
        _shouldInferMappingModelAutomatically = YES;
        _readOnly = NO;
        _persistentContainer = [NSPersistentContainer persistentContainerWithName:name managedObjectModel:mom];
    }
    return self;
}

- (void)loadStoreWithCompletionHandler:(void(^)(NSError *))handler {
    
    [self loadStoreAtURL:self.storeURL withCompletionHandler:handler];
}

- (void)loadStoreAtURL:(NSURL *)storeURL withCompletionHandler:(void(^)(NSError *))handler {
    
    if (!self.persistentContainer) {
        NSError *error = [NSError errorWithDomain:NSCocoaErrorDomain code:NSNotFound userInfo:nil];
        if (handler) {
            dispatch_async(dispatch_get_main_queue(), ^{
                handler(error);
            });
        }
        return;
    }
    
    self.persistentContainer.persistentStoreDescriptions = @[[self storeDescriptionWithURL:storeURL]];
    [self.persistentContainer loadPersistentStoresWithCompletionHandler:
     ^(NSPersistentStoreDescription *storeDescription, NSError *error) {
         if (error == nil) {
             self.storeLoaded = YES;
             self.persistentContainer.viewContext.automaticallyMergesChangesFromParent = YES;
         }
         if (handler) {
             dispatch_async(dispatch_get_main_queue(), ^{
                 handler(error);
             });
         }
     }];
}

- (BOOL)persistentStoreExistsAtURL:(NSURL *)storeURL {
    
    if (storeURL.isFileURL &&
        [NSFileManager.defaultManager fileExistsAtPath:storeURL.path]) {
        return YES;
    }
    return NO;
}

- (NSURL *)storeURL {
    NSArray *descriptions = self.persistentContainer.persistentStoreDescriptions;
    NSPersistentStoreDescription *description = [descriptions firstObject];
    return description.URL;
}

- (BOOL)destroyPersistentStoreAtURL:(NSURL *)storeURL {
    
    NSError *error = nil;
    BOOL result = [self.persistentContainer.persistentStoreCoordinator destroyPersistentStoreAtURL:storeURL withType:NSSQLiteStoreType options:nil error:&error];
    return result;
}

- (BOOL)replacePersistentStoreAtURL:(NSURL *)destinationURL withPersistentStoreFromURL:(NSURL *)sourceURL {
    
    NSError *error = nil;
    BOOL result = [self.persistentContainer.persistentStoreCoordinator replacePersistentStoreAtURL:destinationURL destinationOptions:nil                                             withPersistentStoreFromURL:sourceURL sourceOptions:nil storeType:NSSQLiteStoreType error:&error];
    return result;
}

- (NSManagedObjectContext *)viewContext {
    
    return self.persistentContainer.viewContext;
}

- (NSManagedObjectContext *)newPrivateContext {
    
    return [self.persistentContainer newBackgroundContext];
}

- (void)performBackgroundTask:(void(^)(NSManagedObjectContext *))block {
    
    [self.persistentContainer performBackgroundTask:block];
}

- (NSManagedObjectID *)managedObjectIDForURIRepresentation:(NSURL *)url {
    return [self.persistentContainer.persistentStoreCoordinator managedObjectIDForURIRepresentation:url];
}

#pragma mark -
#pragma mark === Private methods ===
#pragma mark -

- (NSPersistentStoreDescription *)storeDescriptionWithURL:(NSURL *)URL {
    
    NSPersistentStoreDescription *description = [NSPersistentStoreDescription persistentStoreDescriptionWithURL:URL];
    description.shouldAddStoreAsynchronously = self.shouldAddStoreAsynchronously;
    description.shouldMigrateStoreAutomatically = self.shouldMigrateStoreAutomatically;
    description.shouldInferMappingModelAutomatically = self.shouldInferMappingModelAutomatically;
    description.readOnly = self.isReadOnly;
    return description;
}

@end

