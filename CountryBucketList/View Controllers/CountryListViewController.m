//
//  CountryListViewController.m
//  CountryBucketList
//
//  Created by Diel Barnes on 20/05/2017.
//  Copyright © 2017 Diel Barnes. All rights reserved.
//

#import "CountryListViewController.h"

#define EMPTY_BUCKETLIST @"Your bucket list is empty"
#define NO_RESULTS @"No search results"

@interface CountryListViewController () <UITableViewDataSource, UITableViewDelegate>
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
    
    if (self.pageIndex == 0) { //All Countries
        
        countries = [[NSMutableArray alloc] init];
        bucketList = [[NSMutableArray alloc] init];
    }
    else { //Bucket List
        
        if (!bucketList) {
            
            self.noCountriesLabel.text = EMPTY_BUCKETLIST;
            self.noCountriesLabel.hidden = NO;
            
            bucketList = [[NSMutableArray alloc] init];
        }
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.delegate countryListViewController:self pageDidAppear:self.pageIndex];
}

- (void)reloadData:(NSMutableArray *)updatedCountries bucketList:(NSMutableArray *)updatedBucketList {
    
    if (self.pageIndex == 0) {
        [countries removeAllObjects];
        [countries addObjectsFromArray:updatedCountries];
    }
    
    if (!self.viewLoaded) { //Bucket List page not loaded yet
        
        bucketList = [[NSMutableArray alloc] initWithArray:updatedBucketList];
    }
    else {
        [bucketList removeAllObjects];
        [bucketList addObjectsFromArray:updatedBucketList];
        
        if (self.pageIndex == 1) {
            
            if (bucketList.count > 0) {
                self.noCountriesLabel.hidden = YES;
            }
            else {
                self.noCountriesLabel.text = EMPTY_BUCKETLIST;
                self.noCountriesLabel.hidden = NO;
            }
        }
    }
    
    [self.countryListTableView reloadData];
}

- (void)showNoResultsText {
    self.noCountriesLabel.text = NO_RESULTS;
    self.noCountriesLabel.hidden = NO;
}

- (void)hideNoResultsText {
    self.noCountriesLabel.hidden = YES;
}

#pragma mark - Table View Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (self.pageIndex == 0) {
        return countries.count;
    }
    else {
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
    
    if (self.pageIndex == 0)  { //All Countries
        
        //Get country
        
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
    else { //Bucket List
        country = bucketList[indexPath.row];
        [heartButton setImage:[UIImage imageNamed:@"heart-filled"] forState:UIControlStateNormal];
    }
    
    cell.imageView.image = country.flag;
    cell.textLabel.text = country.name;
    
    heartButton.frame = CGRectMake(0, 0, 22.0, 22.0);
    heartButton.tag = indexPath.row;
    [heartButton addTarget:self action:@selector(accessoryButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [cell setAccessoryView:heartButton];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [self.delegate countryListViewController:self countrySelected:countries[indexPath.row]];
}

- (void)accessoryButtonTapped:(UIButton *)sender {
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:sender.tag inSection:0];
    
    Country *country;
    if (self.pageIndex == 0)  { //All Countries
        
        country = countries[indexPath.row];
        
        NSUInteger index = [bucketList indexOfObjectPassingTest:^(id obj, NSUInteger idx, BOOL *stop) {
            Country *object = (Country *)obj;
            return [object.name isEqualToString:country.name];
        }];
        
        if (index == NSNotFound) { //Add to bucket list
            
            [self.delegate countryListViewController:self countryAddedToBucketList:country];
            [bucketList addObject:country];
        }
        else { //Remove from bucket list

            [self.delegate countryListViewController:self countryRemovedFromBucketList:country];
            [bucketList removeObjectAtIndex:index];
        }

        [self.countryListTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    }
    else { //Bucket List
        
        country = bucketList[indexPath.row];
        [self.delegate countryListViewController:self countryRemovedFromBucketList:country];
        
        [bucketList removeObjectAtIndex:indexPath.row];
        [self.countryListTableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationTop];
        
        if (bucketList.count == 0) {
            self.noCountriesLabel.text = EMPTY_BUCKETLIST;
            self.noCountriesLabel.hidden = NO;
        }
    }
}

@end
