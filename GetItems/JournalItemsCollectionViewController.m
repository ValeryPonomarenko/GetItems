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
#import <CoreData/CoreData.h>

@interface JournalItemsCollectionViewController ()
@property (strong, nonatomic) IBOutlet UICollectionView *collectionVIew;
@property (nonatomic, strong) NSMutableArray* array;
@end

@implementation JournalItemsCollectionViewController

static NSString * const reuseIdentifier = @"Cell";

- (NSManagedObjectContext *)managedObjectContext
{
    NSManagedObjectContext *context = nil;
    id delegate = [[UIApplication sharedApplication] delegate];
    if([delegate performSelector:@selector(managedObjectContext)])
    {
        context = [delegate managedObjectContext];
    }
    return context;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:reuseIdentifier];

    self.array = [[NSMutableArray alloc] init];
    
    void (^downloadData)(NSData *data, NSURLResponse *response, NSError *error) = ^void(NSData *data, NSURLResponse *response, NSError *error)
    {
        if(!data)
            return;
        
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        
        for(id item in dict[@"_embedded"][@"items"])
        {
            JournalItem *journalItem= [[JournalItem alloc] init];
            journalItem.shortName = item[@"shortName"];
            journalItem.publishedDate = item[@"publishedDate"];
            journalItem.smallCoverId = [item[@"smallCoverId"] integerValue];
            [self saveIntoCoreData:journalItem];
            
            [self saveIntoCoreData:journalItem];
            [self.array addObject:journalItem];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{ [self makeView]; });
    };
    
    
    NSURL *url = [[NSURL alloc] initWithString:@"http://pubbledone.devsky.ru/api/items?appId=deus"];
    [self downloadWithUrl:url andCompletionHandler:downloadData];
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

- (void)downloadJournalImages:(JournalItem *)item withCell:(ItemCollectionViewCell *)cell
{
    void (^downloadImg)(NSData *data, NSURLResponse *response, NSError *error) = ^void(NSData *data, NSURLResponse *response, NSError *error)
    {
        item.smallCover = [self getImage:[NSString stringWithFormat: @"%d", item.smallCoverId]];
        
        if(item.smallCover == nil)
        {
            NSLog(@"Download image");
            item.smallCover = [UIImage imageWithData:data];
            [self saveImage:[NSString  stringWithFormat:@"%d", item.smallCoverId] andImage:[UIImage imageWithData:data]];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{ cell.image.image = item.smallCover; });
    };
    
    void (^downloadImgUrl)(NSData *data, NSURLResponse *response, NSError *error) = ^void(NSData *data, NSURLResponse *response, NSError *error)
    {
        if(!data)
            return;
        
        item.imgUrl = [[NSURL alloc] initWithString:[NSJSONSerialization JSONObjectWithData:data options:0 error:nil][@"filePath"]];
        
        [self downloadWithUrl:item.imgUrl andCompletionHandler:downloadImg];
    };
    
    NSString *imgPath = [NSString stringWithFormat:@"http://pubbledone.devsky.ru/api/images/%d", item.smallCoverId];
    NSURL *url = [[NSURL alloc] initWithString:imgPath];
    
    [self downloadWithUrl:url andCompletionHandler:downloadImgUrl];
}

- (void)saveIntoCoreData:(JournalItem *)item
{
    NSManagedObjectContext *context = [self managedObjectContext];
    
    NSManagedObject *newDevice = [NSEntityDescription insertNewObjectForEntityForName:@"Item"
                                                               inManagedObjectContext:context];
    
    [newDevice setValue:item.shortName forKey:@"shortName"];
    [newDevice setValue:item.publishedDate forKey:@"publishedDate"];
    [newDevice setValue:[NSString stringWithFormat:@"%d", item.smallCoverId] forKey:@"smallCoverId"];
    
    NSError *error = nil;
    if(![context save:&error])
    {
        NSLog(@"Can't save %@ %@", error, [error localizedDescription]);
    }
    [self dismissViewControllerAnimated:YES completion:nil];
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

- (void)saveImage:(NSString *)name andImage:(UIImage *)image
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *filePath = [[paths objectAtIndex:0] stringByAppendingString:[NSString stringWithFormat:@"%@.png", name]];
    
    [UIImagePNGRepresentation(image) writeToFile:filePath atomically:YES];
    
    NSLog(@"%@", filePath);
}

- (UIImage *)getImage:(NSString *)name
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *filePath = [[paths objectAtIndex:0] stringByAppendingString:[NSString stringWithFormat:@"%@.png", name]];

    NSData *img = [NSData dataWithContentsOfFile:filePath];
    UIImage *image = [UIImage imageWithData:img];
    
    
        NSLog(@"getImage: %@", filePath);
    return image;
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
    [self downloadJournalImages:item withCell:cell];
    
    return cell;
}

@end
