//
//  JournalItem.m
//  GetItems
//
//  Created by Valery Ponomarenko on 10/05/16.
//  Copyright © 2016 Valery Ponomarenko. All rights reserved.
//

#import "JournalItem.h"

@implementation JournalItem

- (BOOL)isEqual:(id)object
{
    if([object isKindOfClass:[self class]])
    {
        if([self.shortName isEqual:[object shortName]])
            return YES;
    }
    return NO;
}

@end
