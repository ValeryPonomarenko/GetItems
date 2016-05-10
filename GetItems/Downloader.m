//
//  Downloader.m
//  GetItems
//
//  Created by Valery Ponomarenko on 10/05/16.
//  Copyright © 2016 Valery Ponomarenko. All rights reserved.
//

#import "Downloader.h"

@implementation Downloader

- (NSDictionary *)downloadResult:(NSURLRequest* )url;
{
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration ephemeralSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:config];
    
    NSURLSessionDataTask *task = [session dataTaskWithRequest:url
                                  completionHandler:^(NSData * data, NSURLResponse * esponse, NSError * error)
    {
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    }];
    
    [task resume];
}

@end
