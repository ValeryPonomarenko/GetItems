//
//  JournalItem.h
//  GetItems
//
//  Created by Valery Ponomarenko on 10/05/16.
//  Copyright © 2016 Valery Ponomarenko. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface JournalItem : NSObject
@property (nonatomic, strong) NSString *publishedDate;
@property (nonatomic, strong) NSString *shortName;
@property (nonatomic) NSInteger smallCoverId;

@property (nonatomic, strong) UIImage *smallCover;
@property (nonatomic, strong) NSURL *imgUrl;

- (JournalItem *)initWithDictionary: (NSDictionary *)dictionary;
@end
