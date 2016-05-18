//
//  Product+CoreDataProperties.h
//  TestAppBigDig
//
//  Created by  ZHEKA on 17.05.16.
//  Copyright © 2016  ZHEKA. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Product.h"

NS_ASSUME_NONNULL_BEGIN

@interface Product (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *name;
@property (nullable, nonatomic, retain) NSNumber *price;
@property (nullable, nonatomic, retain) NSString *info;
@property (nullable, nonatomic, retain) NSData *images;

@end

NS_ASSUME_NONNULL_END
