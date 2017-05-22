//
//  CountryViewController.m
//  CountryBucketList
//
//  Created by Diel Barnes on 20/05/2017.
//  Copyright © 2017 Diel Barnes. All rights reserved.
//

#import "CountryViewController.h"

@interface CountryViewController () <UITableViewDataSource, UITableViewDelegate>
{
    Country *_country;
    NSString *languagesString;
    NSString *currenciesString;
}

@property (nonatomic, strong) Country *country;

@property (nonatomic, strong) IBOutlet UIImageView *flagView;
@property (nonatomic, strong) IBOutlet UILabel *nameLabel;
@property (nonatomic, strong) IBOutlet UILabel *regionLabel;
@property (nonatomic, strong) IBOutlet UITableView *infoTableView;

@end

@implementation CountryViewController

@synthesize country = _country;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.infoTableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.infoTableView.frame.size.width, 10.0)];
    self.infoTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

#pragma mark - Data Handling

- (void)loadData:(Country *)country {
    
    _country = country;
    
    self.flagView.image = _country.flag;
    self.nameLabel.text = _country.name;
    self.regionLabel.text = _country.region;
    
    languagesString = @"";
    for (NSString *language in _country.languages) {
        languagesString = [languagesString stringByAppendingString:language];
        if (language != _country.languages.lastObject) {
            languagesString = [languagesString stringByAppendingString:@", "];
        }
    }
    
    currenciesString = @"";
    for (NSString *currency in _country.currencies) {
        currenciesString = [currenciesString stringByAppendingString:currency];
        if (currency != _country.currencies.lastObject) {
            currenciesString = [currenciesString stringByAppendingString:@", "];
        }
    }
    
    [self.infoTableView reloadData];
}

#pragma mark - Table View Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 5;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"InfoCell"];
    
    UILabel *textLabel = [cell viewWithTag:123];
    UILabel *detailTextLabel = [cell viewWithTag:456];
    
    if (indexPath.row == 0) {
        
        textLabel.text = @"Capital";
        
        if (_country.capital.length > 0) {
            detailTextLabel.text = _country.capital;
        }
        else {
            detailTextLabel.text = @"None";
        }
    }
    else if (indexPath.row == 1) {
        
        textLabel.text = @"Area";
        
        if (_country.area > 1000) {
            detailTextLabel.text = [NSString stringWithFormat:@"%.2fK sq. km", _country.area/1000.0];
        }
        else {
            detailTextLabel.text = [NSString stringWithFormat:@"%.2fM sq. km", _country.area/1000000.0];
        }
    }
    else if (indexPath.row == 2) {
        
        textLabel.text = @"Population";
        
        if (_country.population > 1000000) {
            detailTextLabel.text = [NSString stringWithFormat:@"%.2fK", _country.population/1000.0];
        }
        else {
            detailTextLabel.text = [NSString stringWithFormat:@"%.2fM", _country.population/1000000.0];
        }
    }
    else if (indexPath.row == 3) {
        
        textLabel.text = @"Languages";
        detailTextLabel.text = languagesString;
    }
    else {
        
        textLabel.text = @"Currencies";
        detailTextLabel.text = currenciesString;
        
        cell.separatorInset = UIEdgeInsetsMake(0, 3000.0, 0, 0);
    }
    
    return cell;
}

@end
