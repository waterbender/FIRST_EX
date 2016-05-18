//
//  DataManager.m
//  CoreDataTest
//
//  Created by  ZHEKA on 15.07.15.
//  Copyright (c) 2015 Pasko Eugene. All rights reserved.
//

#import "DataManager.h"
#import "Product.h"
#import "Product+CoreDataProperties.h"

@implementation DataManager

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

+ (DataManager*) sharedManager {
    
    static DataManager* manager = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[DataManager alloc] init];
    });
    
    return manager;
}

- (void) setNewDictProductIntoDB: (NSDictionary*) dict {
    
    Product *newProd = [NSEntityDescription insertNewObjectForEntityForName:@"Product"        inManagedObjectContext:self.managedObjectContext];

    newProd.name = dict[@"name"];
    newProd.price = dict[@"price"];
    newProd.info = dict[@"info"];
    newProd.images = dict[@"images"];
    
    NSError *error;
    if (![self.managedObjectContext save:&error]) {
        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
    }
    
}

- (NSArray*) allObjects {
    
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *description = [NSEntityDescription entityForName:@"Product" inManagedObjectContext:self.managedObjectContext];
    
    [request setEntity:description];
    
    NSError *requestError = nil;
    
    NSArray *resultArray = [self.managedObjectContext executeFetchRequest:request error:&requestError];
    
    if (requestError) {
        NSLog(@"%@", requestError);
    }
    
    return resultArray;
    
}

- (void) deleteAllObjects {
    
    NSArray *allObject = [self allObjects];
    
    for (id object in allObject) {
        
        [self.managedObjectContext deleteObject:object];
    }
    
    [self.managedObjectContext save:nil];
    
}

#pragma mark - Core Data stack

- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "com.bignerdranch.CoreDataTest" in the application's documents directory.
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectModel *)managedObjectModel {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"TestAppBigDig" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it.
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    // Create the coordinator and store
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"CoreDataTest.sqlite"];
    NSError *error = nil;
    
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        
        [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil];
        
        [_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error];
    }
    
    return _persistentStoreCoordinator;
}


- (NSManagedObjectContext *)managedObjectContext {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    
    return _managedObjectContext;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

@end
