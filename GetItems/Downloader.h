//
//  Downloader.h
//  GetItems
//
//  Created by Valery Ponomarenko on 10/05/16.
//  Copyright © 2016 Valery Ponomarenko. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Downloader : NSObject

- (NSDictionary *)downloadResult:(NSURLRequest* )url;

@end
