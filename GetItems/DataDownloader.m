//
//  DataDownloader.m
//  GetItems
//
//  Created by Valery Ponomarenko on 17/05/16.
//  Copyright © 2016 Valery Ponomarenko. All rights reserved.
//

#import "DataDownloader.h"

@implementation DataDownloader

- (void)downloadWithUrl:(NSURL *)url andCompletionHandler:(void (^)(NSData *data, NSURLResponse *response, NSError *error))handler
{
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration ephemeralSessionConfiguration];
    config.URLCache = [NSURLCache sharedURLCache];
    config.requestCachePolicy = NSURLRequestReturnCacheDataElseLoad;
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:config];
    
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request
                                            completionHandler:handler];
    [task resume];
}

@end
