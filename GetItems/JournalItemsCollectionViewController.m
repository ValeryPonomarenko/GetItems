//
//  JournalItemsCollectionViewController.m
//  GetItems
//
//  Created by Valery Ponomarenko on 10/05/16.
//  Copyright © 2016 Valery Ponomarenko. All rights reserved.
//

#import "JournalItemsCollectionViewController.h"
#import "ItemCollectionViewCell.h"
#import "JournalItem.h"

@interface JournalItemsCollectionViewController ()
@property (strong, nonatomic) IBOutlet UICollectionView *collectionVIew;
@property (nonatomic, strong) NSMutableArray* array;
@end

@implementation JournalItemsCollectionViewController

static NSString * const reuseIdentifier = @"Cell";

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:reuseIdentifier];

    self.array = [[NSMutableArray alloc] init];
    [self downloadData];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    NSURLCache *URLCache = [[NSURLCache alloc] initWithMemoryCapacity:20*1024*1024
                                                         diskCapacity:40*1024*1024
                                                             diskPath:nil];
    [NSURLCache setSharedURLCache:URLCache];
    sleep(1);
    
    return YES;
}

- (void)downloadData
{
    NSURL *url = [[NSURL alloc] initWithString:@"http://pubbledone.devsky.ru/api/items?appId=deus"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration ephemeralSessionConfiguration];
    config.URLCache = [NSURLCache sharedURLCache];
    config.requestCachePolicy = NSURLRequestReturnCacheDataElseLoad;
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:config];
    
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request
                                            completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error)
    {
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        
        for(id item in dict[@"_embedded"][@"items"])
        {
            JournalItem *journalItem= [[JournalItem alloc] init];
            journalItem.shortName = item[@"shortName"];
            journalItem.publishedDate = item[@"publishedDate"];
            journalItem.smallCoverId = [item[@"smallCoverId"] integerValue];

            [self.array addObject:journalItem];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{ [self makeView]; });
    }];
    [task resume];
}

- (void)makeView
{
    [self.collectionView performBatchUpdates:^{
        NSMutableArray *arrayWithIndexPaths = [NSMutableArray array];
        
        for(int i = 0; i < [self.array count]; i++)
        {
            [arrayWithIndexPaths addObject:[NSIndexPath indexPathForRow:i inSection:0]];
        }
        [self.collectionView insertItemsAtIndexPaths:arrayWithIndexPaths];
    } completion:nil];
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.array count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ItemCollectionViewCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ItemCell" forIndexPath:indexPath];
    
    JournalItem *item = [self.array objectAtIndex:indexPath.row];
    
    cell.publishedDate.text = item.publishedDate;
    cell.title.text = item.shortName;

    //download img from the web
    NSString *imgPath = [NSString stringWithFormat:@"http://pubbledone.devsky.ru/api/images/%d", item.smallCoverId];
    NSURL *url = [[NSURL alloc] initWithString:imgPath];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration ephemeralSessionConfiguration];
    config.URLCache = [NSURLCache sharedURLCache];
    config.requestCachePolicy = NSURLRequestReturnCacheDataElseLoad;
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:config];
    
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request
                                            completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error)
    {
        item.imgUrl = [[NSURL alloc] initWithString:[NSJSONSerialization JSONObjectWithData:data options:0 error:nil][@"filePath"]];
        
        
        //download image
        NSURLRequest *request = [NSURLRequest requestWithURL:item.imgUrl];
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration ephemeralSessionConfiguration];
        config.URLCache = [NSURLCache sharedURLCache];
        config.requestCachePolicy = NSURLRequestReturnCacheDataElseLoad;
        
        NSURLSession *session = [NSURLSession sessionWithConfiguration:config];
        
        NSURLSessionDataTask *task = [session dataTaskWithRequest:request
                                                completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error)
        {
            item.smallCover = [UIImage imageWithData:data];
            dispatch_async(dispatch_get_main_queue(), ^{ cell.image.image = item.smallCover; });
        }];
        [task resume];
    }];
    [task resume];
    
    return cell;
}

@end
