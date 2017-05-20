//
//  CountryListViewController.m
//  CountryBucketList
//
//  Created by Diel Barnes on 20/05/2017.
//  Copyright © 2017 Diel Barnes. All rights reserved.
//

#import "CountryListViewController.h"

@interface CountryListViewController ()
{
    NSMutableArray *countries;
}

@property (nonatomic, strong) IBOutlet UILabel *noResultsLabel;

@end

@implementation CountryListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    countries = [[NSMutableArray alloc] init];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.delegate countryListViewController:self pageDidAppear:self.pageIndex];
}

- (void)reloadData:(NSMutableArray *)updatedCountries {
    
    [countries removeAllObjects];
    [countries addObjectsFromArray:updatedCountries];
    [self.tableView reloadData];
}

- (void)showNoResultsLabel {
    self.noResultsLabel.hidden = false;
}

- (void)hideNoResultsLabel {
    self.noResultsLabel.hidden = YES;
}

#pragma mark - Table View Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return countries.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CountryCell"];
    
    Country *country = countries[indexPath.row];
    
    cell.imageView.image = country.flag;
    cell.textLabel.text = country.name;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [self.delegate countryListViewController:self countrySelected:countries[indexPath.row]];
}

@end
