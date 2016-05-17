//
//  Item+CoreDataProperties.h
//  GetItems
//
//  Created by Valery Ponomarenko on 17/05/16.
//  Copyright © 2016 Valery Ponomarenko. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Item.h"

NS_ASSUME_NONNULL_BEGIN

@interface Item (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *publishedDate;
@property (nullable, nonatomic, retain) NSString *shortName;
@property (nullable, nonatomic, retain) NSString *smallCoverId;

@end

NS_ASSUME_NONNULL_END
