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
#import "DataDownloader.h"
#import <CoreData/CoreData.h>

@interface JournalItemsCollectionViewController ()
@property (strong, nonatomic) IBOutlet UICollectionView *collectionVIew;
@property (nonatomic, strong) NSMutableArray *array;
@property (nonatomic, strong) DataDownloader *downloader;
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
    self.downloader = [[DataDownloader alloc] init];
    [self fillArrayFromCoreData];
    
    void (^downloadData)(NSData *data, NSURLResponse *response, NSError *error) = ^void(NSData *data, NSURLResponse *response, NSError *error)
    {
        if(!data)
        {
            //нет интернет соединения
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"No network connection"
                                                                           message:@"You must be connected to the internet to download the newest journals."
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK"
                                                         style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction *action) {
                                                           [alert dismissViewControllerAnimated:YES completion:nil];
                                                         }];
            [alert addAction:ok];
            
            [self presentViewController:alert animated:YES completion:nil];
            return;
        }
        
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        
        for(id item in dict[@"_embedded"][@"items"])
        {
            JournalItem *journalItem= [[JournalItem alloc] init];
            journalItem.shortName = item[@"shortName"];
            journalItem.publishedDate = item[@"publishedDate"];
            journalItem.smallCoverId = [item[@"smallCoverId"] integerValue];
            
            if(![self.array containsObject:journalItem])
            {
                [self saveIntoCoreData:journalItem];
                [self.array addObject:journalItem];
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{ [self.collectionView reloadData]; });
    };
    
    NSURL *url = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"%@api/items?appId=%@", SERVER_ADDRESS, USER_ID]];
    [self.downloader downloadWithUrl:url andCompletionHandler:downloadData];
}

- (void)fillArrayFromCoreData
{
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Item"];
    NSMutableArray *items = [[NSMutableArray alloc] init];
    
    items = [[managedObjectContext executeFetchRequest:fetchRequest error:nil] mutableCopy];
    
    for(id item in items)
    {
        JournalItem *journalItem= [[JournalItem alloc] init];
        journalItem.shortName = [item valueForKey:@"shortName"];
        journalItem.publishedDate = [item valueForKey:@"publishedDate"];
        journalItem.smallCoverId = [[item valueForKey:@"smallCoverId"] integerValue];
        
        [self.array addObject:journalItem];
    }
}

- (void)downloadJournalImages:(JournalItem *)item withCell:(ItemCollectionViewCell *)cell
{
    void (^downloadImg)(NSData *data, NSURLResponse *response, NSError *error) = ^void(NSData *data, NSURLResponse *response, NSError *error)
    {
        item.smallCover = [UIImage imageWithData:data];
        [self saveImage:[NSString  stringWithFormat:@"%ld", (long)item.smallCoverId] andImage:[UIImage imageWithData:data]];
        
        dispatch_async(dispatch_get_main_queue(), ^{ cell.image.image = item.smallCover; });
    };
    
    void (^downloadImgUrl)(NSData *data, NSURLResponse *response, NSError *error) = ^void(NSData *data, NSURLResponse *response, NSError *error)
    {
        if(!data)
            return;
        
        item.imgUrl = [[NSURL alloc] initWithString:[NSJSONSerialization JSONObjectWithData:data options:0 error:nil][@"filePath"]];
        
        [self.downloader downloadWithUrl:item.imgUrl andCompletionHandler:downloadImg];
    };
    
    NSString *imgPath = [NSString stringWithFormat:@"%@api/images/%ld", SERVER_ADDRESS, (long)item.smallCoverId];
    NSURL *url = [[NSURL alloc] initWithString:imgPath];
    
    [self.downloader downloadWithUrl:url andCompletionHandler:downloadImgUrl];
}

- (void)saveIntoCoreData:(JournalItem *)item
{
    NSManagedObjectContext *context = [self managedObjectContext];
    
    NSManagedObject *newItem = [NSEntityDescription insertNewObjectForEntityForName:@"Item"
                                                               inManagedObjectContext:context];
    
    [newItem setValue:item.shortName forKey:@"shortName"];
    [newItem setValue:item.publishedDate forKey:@"publishedDate"];
    [newItem setValue:[NSString stringWithFormat:@"%ld", (long)item.smallCoverId] forKey:@"smallCoverId"];
    
    NSError *error = nil;
    if(![context save:&error])
    {
        NSLog(@"Can't save %@ %@", error, [error localizedDescription]);
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)saveImage:(NSString *)name andImage:(UIImage *)image
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *filePath = [[paths objectAtIndex:0] stringByAppendingString:[NSString stringWithFormat:@"%@.png", name]];
    
    [UIImagePNGRepresentation(image) writeToFile:filePath atomically:YES];
}

- (UIImage *)getImage:(NSString *)name
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *filePath = [[paths objectAtIndex:0] stringByAppendingString:[NSString stringWithFormat:@"%@.png", name]];

    NSData *img = [NSData dataWithContentsOfFile:filePath];
    UIImage *image = [UIImage imageWithData:img];
    
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
    JournalItem *item = [self.array objectAtIndex:indexPath.row];
    item.smallCover = [self getImage:[NSString stringWithFormat: @"%ld", (long)item.smallCoverId]];
    
    ItemCollectionViewCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ItemCell" forIndexPath:indexPath];
    cell.publishedDate.text = item.publishedDate;
    cell.title.text = item.shortName;
    if(item.smallCover == nil)
        [self downloadJournalImages:item withCell:cell];
    else
        cell.image.image = item.smallCover;
    
    return cell;
}

@end
