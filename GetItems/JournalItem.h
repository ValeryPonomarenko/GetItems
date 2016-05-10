//
//  JournalItem.h
//  GetItems
//
//  Created by Valery Ponomarenko on 10/05/16.
//  Copyright © 2016 Valery Ponomarenko. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JournalItem : NSObject
@property (nonatomic, copy) NSString *shortName;
@property (nonatomic, copy) NSString *publishedDate;
@property (nonatomic) NSUInteger smallCoverId;
@end
