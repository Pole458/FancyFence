//
//  CoreDataController.h
//  FancyFence
//
//  Created by user148018 on 5/2/19.
//

//
//  CoreDataController.h
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

@import CoreData;

/**
 `CoreDataController` is a simple wrapper class for setting up
 and using a Core Data stack.
 
 @warning Requires iOS 10 as it depends on the availability of
 `NSPersistentContainer`.
 */

NS_ASSUME_NONNULL_BEGIN

API_AVAILABLE(macosx(10.12),ios(10.0),tvos(10.0),watchos(3.0))
@interface CoreDataController : NSObject

/**
 The default directory for the persistent stores on the current platform.
 
 @return An `NSURL` for the directory containing the persistent store(s). If the
 persistent store does not exist it will be created by default in this location
 when loaded.
 */
+ (NSURL *)defaultDirectoryURL;

///---------------------
/// @name Properties
///---------------------

/**
 A read-only flag indicating if the persistent store is loaded.
 */
@property (readonly, assign, getter=isStoreLoaded) BOOL storeLoaded;

/**
 The managed object context associated with the main queue (read-only). To
 perform tasks on a private background queue see `performBackgroundTask:` and
 `newPrivateContext`.
 
 The context is configured to be generational and to automatically consume save
 notifications from other contexts.
 */
@property (readonly, strong) NSManagedObjectContext *viewContext;

/**
 The `URL` of the persistent store for this Core Data Stack. If there are more
 than one stores this property returns the first store it finds. The store may
 not yet exist. It will be created at this URL by default when first loaded.
 
 This is a readonly property to create a persistent store in a different
 location use `loadStoreAtURL:withCompletionHandler`. To move an existing
 persistent store use `replacePersistentStoreAtURL:withPersistentStoreFromURL:`.
 */
@property (readonly, copy) NSURL *storeURL;

/**
 A flag that indicates whether this store is read-only. Set this value to YES
 before loading the persistent store if you want a read-only store (for example
 if you are loading a store from the application bundle).
 
 Default is NO.
 */
@property (assign, getter=isReadOnly) BOOL readOnly;

/**
 A flag that indicates whether the store is added asynchronously. Set this
 value before loading the persistent store.
 
 Default is YES.
 */
@property (assign) BOOL shouldAddStoreAsynchronously;

/**
 A flag that indicates whether the store should be migrated
 automatically if the store model version does not match the
 coordinators model version.
 
 Set this value before loading the persistent store.
 
 Default is YES.
 */
@property (assign) BOOL shouldMigrateStoreAutomatically;

/**
 A flag that indicates whether a mapping model should be inferred
 when migrating a store.
 
 Set this value before loading the persistent store.
 
 Default is YES.
 */
@property (assign) BOOL shouldInferMappingModelAutomatically;

///---------------------
/// @name Initialization
///---------------------

- (instancetype)init NS_UNAVAILABLE;

/**
 Creates and returns a `CoreDataController` object. This is the designated
 initializer for the class. It creates the managed object model, persistent
 store coordinator and main managed object context but does not load the
 persistent store.
 
 @param name The name of the `NSManagedObjectModel` and by default the name used
 for the persistent store
 @return A `CoreDataController` object initialized with the given name.
 */
- (instancetype)initWithName:(NSString *)name NS_DESIGNATED_INITIALIZER;

///---------------------------------
/// @name Loading a Persistent Store
///---------------------------------

/**
 Load the persistent store.
 
 @param handler This handler block is executed on the calling thread when the
 loading of the persistent store has completed.
 
 To override the default name and location of the persistent store use
 `loadStoreAtURL:withCompletionHandler:`.
 */
- (void)loadStoreWithCompletionHandler:(void(^)(NSError *))handler;

/**
 Load the persistent store.
 
 @param storeURL The URL for the location of the persistent store. It will be created if it does not exist.
 
 @param handler This handler block is executed on the calling thread when the
 loading of the persistent store has completed.
 */
- (void)loadStoreAtURL:(NSURL *)storeURL withCompletionHandler:(void(^)(NSError * _Nullable))handler;

///----------------------------------
/// @name Managing a Persistent Store
///----------------------------------

/**
 A flag indicating if the persistent store exists at the specified URL.
 
 @param storeURL An `NSURL` object for the location of the peristent store.
 @return YES if a file exists at the specified URL otherwise NO.
 @warning This method checks if a file exists at the specified location but
 does not verify if it is a valid persistent store.
 */
- (BOOL)persistentStoreExistsAtURL:(NSURL *)storeURL;

/**
 Replace a persistent store.
 
 @param destinationURL An `NSURL` for the persistent store to be replaced.
 @param sourceURL An `NSURL` for the source persistent store.
 @return A flag indicating if the operation was successful.
 */
- (BOOL)replacePersistentStoreAtURL:(NSURL *)destinationURL withPersistentStoreFromURL:(NSURL *)sourceURL;

/**
 Destroy a persistent store.
 
 @param storeURL An `NSURL` for the persistent store to be destroyed.
 @return A flag indicating if the operation was successful.
 */
- (BOOL)destroyPersistentStoreAtURL:(NSURL *)storeURL;

///----------------------------------
/// @name Performing Background tasks
///----------------------------------

/**
 Execute a block on a new private queue context.
 
 @param block A block to execute on a newly created private context. The context
 is passed to the block as a paramater.
 */
- (void)performBackgroundTask:(void(^)(NSManagedObjectContext *))block;

/**
 Create and return a new private queue `NSManagedObjectContext`. The new context
 is set to consume `NSManagedObjectContextSave` broadcasts automatically.
 
 @return A new private managed object context.
 */
- (NSManagedObjectContext *)newPrivateContext NS_RETURNS_RETAINED;

///------------------------
/// @name NSManagedObjectID
///------------------------

/**
 Return an object ID for the specified URI representation if a matching
 store is available.
 
 @param url An `NSURL` containing a URI of a managed object.
 @return An `NSManagedObjectID` or `nil`.
 */
- (NSManagedObjectID *)managedObjectIDForURIRepresentation:(NSURL *)url;

@end
NS_ASSUME_NONNULL_END
