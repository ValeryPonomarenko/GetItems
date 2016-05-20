//
//  JournalItem.m
//  GetItems
//
//  Created by Valery Ponomarenko on 10/05/16.
//  Copyright © 2016 Valery Ponomarenko. All rights reserved.
//

#import "JournalItem.h"

@implementation JournalItem

- (JournalItem *)initWithDictionary:(NSDictionary *)dictionary
{
    JournalItem *item = [[JournalItem alloc] init];
    
    if(item)
    {
        item.shortName = [dictionary valueForKey:@"shortName"];
        item.publishedDate = [dictionary valueForKey:@"publishedDate"];
        item.smallCoverId = [[dictionary valueForKey:@"smallCoverId"] integerValue];
    }
    
    return item;
}

- (BOOL)isEqual:(JournalItem *)object
{
    return [object isKindOfClass:[self class]] && [[self shortName] isEqual:[object shortName]];
}

@end
