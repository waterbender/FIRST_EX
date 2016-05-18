//
//  DataManager.h
//  TestAppBigDig
//
//  Created by  ZHEKA on 17.05.16.
//  Copyright © 2016  ZHEKA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface DataManager : NSObject

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;
- (void) setNewDictProductIntoDB: (NSDictionary*) dict;

+ (DataManager*) sharedManager;

@end
