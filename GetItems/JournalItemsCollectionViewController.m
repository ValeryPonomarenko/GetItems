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
    
    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Register cell classes
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:reuseIdentifier];
    
    // Do any additional setup after loading the view.
    
    self.array = [[NSMutableArray alloc] init];
    
    NSURL *url = [[NSURL alloc] initWithString:@"http://pubbledone.devsky.ru/api/items?appId=deus"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration ephemeralSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:config];
    
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request
                                  completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error)
    {
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        dispatch_async(dispatch_get_main_queue(), ^{ [self makeView:dict]; });
    }];
    
    [task resume];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)makeView:(NSDictionary *)dict
{
    for(id item in dict[@"_embedded"][@"items"])
    {
        JournalItem *journalItem= [[JournalItem alloc] init];
        journalItem.shortName = item[@"shortName"];
        journalItem.publishedDate = item[@"publishedDate"];
        journalItem.smallCoverId = [item[@"smallCoverId"] integerValue];
        [self.array addObject:journalItem];
    }
    
    [self.collectionView performBatchUpdates:^{
        NSMutableArray *arrayWithIndexPaths = [NSMutableArray array];
        
        for(int i = 0; i < [self.array count]; i++)
        {
            [arrayWithIndexPaths addObject:[NSIndexPath indexPathForRow:i inSection:0]];
        }
        [self.collectionView insertItemsAtIndexPaths:arrayWithIndexPaths];
    } completion:nil];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

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
    
    return cell;
}

#pragma mark <UICollectionViewDelegate>

/*
// Uncomment this method to specify if the specified item should be highlighted during tracking
- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
}
*/

/*
// Uncomment this method to specify if the specified item should be selected
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
*/

/*
// Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
- (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath {
	return NO;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	return NO;
}

- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	
}
*/

@end
