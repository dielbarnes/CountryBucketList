//
//  CountryListViewController.m
//  CountryBucketList
//
//  Created by Diel Barnes on 20/05/2017.
//  Copyright © 2017 Diel Barnes. All rights reserved.
//

#import "CountryListViewController.h"

#define NO_COUNTRIES_TEXT @"Nothing to show here!"

@interface CountryListViewController () <UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate>
{
    NSMutableArray *countries;
    NSMutableArray *bucketList;
}

@property (nonatomic, strong) IBOutlet UITableView *countryListTableView;
@property (nonatomic, strong) IBOutlet UILabel *noCountriesLabel;

@end

@implementation CountryListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.countryListTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    if (self.pageIndex == 0) { //Page: All Countries
        
        countries = [[NSMutableArray alloc] init];
        bucketList = [[NSMutableArray alloc] init];
    }
    else { //Page: Bucket List
        
        if (!bucketList) {
            bucketList = [[NSMutableArray alloc] init];
        }
        
        if (bucketList.count == 0) {
            self.noCountriesLabel.text = NO_COUNTRIES_TEXT;
            self.noCountriesLabel.hidden = NO;
        }
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.delegate countryListViewController:self pageDidAppear:self.pageIndex];
}

#pragma mark - Data Handling

- (void)reloadData:(NSMutableArray *)updatedCountries bucketList:(NSMutableArray *)updatedBucketList {
    
    if (self.pageIndex == 0) { //Page: All Countries
        
        [countries removeAllObjects];
        
        if (updatedCountries.count > 0) {
            [countries addObjectsFromArray:updatedCountries];
            self.noCountriesLabel.hidden = YES;
        }
        else {
            self.noCountriesLabel.text = NO_COUNTRIES_TEXT;
            self.noCountriesLabel.hidden = NO;
        }
        
        [bucketList removeAllObjects];
        [bucketList addObjectsFromArray:updatedBucketList];
    }
    else { //Page: Bucket List
        
        if (!self.viewLoaded) { //Page is not loaded yet
            bucketList = [[NSMutableArray alloc] init];
        }
        else {
            [bucketList removeAllObjects];
        }
        
        if (updatedBucketList.count > 0) {
            [bucketList addObjectsFromArray:updatedBucketList];
            self.noCountriesLabel.hidden = YES;
        }
        else {
            self.noCountriesLabel.text = NO_COUNTRIES_TEXT;
            self.noCountriesLabel.hidden = NO;
        }
    }
    
    [self.countryListTableView reloadData];
}

#pragma mark - Table View Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (self.pageIndex == 0) { //Page: All Countries
        return countries.count;
    }
    else { //Page: Bucket List
        return bucketList.count;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CountryCell"];
    
    Country *country;
    UIButton *heartButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    if (self.pageIndex == 0)  { //Page: All Countries
        
        country = countries[indexPath.row];
        
        //Check if country is in bucket list
        
        NSUInteger index = [bucketList indexOfObjectPassingTest:^(id obj, NSUInteger idx, BOOL *stop) {
            Country *object = (Country *)obj;
            return [object.name isEqualToString:country.name];
        }];
        
        if (index != NSNotFound) {
            [heartButton setImage:[UIImage imageNamed:@"heart-filled"] forState:UIControlStateNormal];
        }
        else {
            [heartButton setImage:[UIImage imageNamed:@"heart"] forState:UIControlStateNormal];
        }
    }
    else { //Page: Bucket List
        
        country = bucketList[indexPath.row];
        [heartButton setImage:[UIImage imageNamed:@"heart-filled"] forState:UIControlStateNormal];
    }
    
    cell.imageView.image = country.flag;
    cell.textLabel.text = country.name;
    
    heartButton.frame = CGRectMake(0, 0, 22.0, 22.0);
    heartButton.tag = indexPath.row;
    [heartButton addTarget:self action:@selector(heartButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [cell setAccessoryView:heartButton];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    Country *country;
    if (self.pageIndex == 0)  { //Page: All Countries
        country = countries[indexPath.row];
    }
    else { //Page: Bucket List
        country = bucketList[indexPath.row];
    }
    
    [self.delegate countryListViewController:self countrySelected:country];
}

#pragma mark - Button Methods

- (void)heartButtonTapped:(UIButton *)sender {
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:sender.tag inSection:0];
    
    if (self.pageIndex == 0)  { //Page: All Countries
        
        Country *country = countries[indexPath.row];
        
        //Check if country is in bucket list
        
        NSUInteger index = [bucketList indexOfObjectPassingTest:^(id obj, NSUInteger idx, BOOL *stop) {
            Country *object = (Country *)obj;
            return [object.name isEqualToString:country.name];
        }];
        
        if (index == NSNotFound) { //Add to bucket list
            
            [self.delegate countryListViewController:self countryAddedToBucketList:country];
            
            [bucketList addObject:country];
            [sender setImage:[UIImage imageNamed:@"heart-filled"] forState:UIControlStateNormal];
        }
        else { //Remove from bucket list

            [self.delegate countryListViewController:self countryRemovedFromBucketList:country];
            
            [bucketList removeObjectAtIndex:index];
            [sender setImage:[UIImage imageNamed:@"heart"] forState:UIControlStateNormal];
        }
    }
    else { //Page: Bucket List
        
        Country *country = bucketList[indexPath.row];
        [self.delegate countryListViewController:self countryRemovedFromBucketList:country];
        
        [bucketList removeObjectAtIndex:indexPath.row];
        [self.countryListTableView reloadData];
        
        if (bucketList.count == 0) {
            self.noCountriesLabel.text = NO_COUNTRIES_TEXT;
            self.noCountriesLabel.hidden = NO;
        }
    }
}

#pragma mark - Scroll View Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self.delegate countryListViewDidScroll:self];
}

@end
