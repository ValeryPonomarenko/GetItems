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
@property (nonatomic, strong) NSString *shortName;
@property (nonatomic, strong) NSString *publishedDate;
@property (nonatomic, strong) UIImage *smallCover;
@property (nonatomic, strong) NSURL *imgUrl;
@property (nonatomic) NSInteger smallCoverId;

- (BOOL)isEqual:(id)object;
@end
