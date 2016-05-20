//
//  DataDownloader.h
//  GetItems
//
//  Created by Valery Ponomarenko on 17/05/16.
//  Copyright © 2016 Valery Ponomarenko. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DataDownloader : NSObject
+ (void)downloadWithUrl:(NSURL *)url andCompletionHandler:(void (^)(NSData *data, NSURLResponse *response, NSError *error))handler;
@end
