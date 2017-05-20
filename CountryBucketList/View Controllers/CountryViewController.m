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
    NSString *languages;
    NSString *currencies;
}

@property (nonatomic, strong) IBOutlet UIImageView *flagView;
@property (nonatomic, strong) IBOutlet UILabel *nameLabel;
@property (nonatomic, strong) IBOutlet UILabel *regionLabel;
@property (nonatomic, strong) IBOutlet UITableView *infoTableView;

@end

@implementation CountryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.infoTableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.infoTableView.frame.size.width, 10.0)];
    self.infoTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

- (void)loadData {
    
    self.flagView.image = self.country.flag;
    self.nameLabel.text = self.country.name;
    self.regionLabel.text = self.country.region;
    
    languages = @"";
    for (NSString *language in self.country.languages) {
        languages = [languages stringByAppendingString:language];
        if (language != self.country.languages.lastObject) {
            languages = [languages stringByAppendingString:@", "];
        }
    }
    
    currencies = @"";
    for (NSString *currency in self.country.currencies) {
        currencies = [currencies stringByAppendingString:currency];
        if (currency != self.country.currencies.lastObject) {
            currencies = [currencies stringByAppendingString:@", "];
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
        detailTextLabel.text = self.country.capital;
    }
    else if (indexPath.row == 1) {
        
        textLabel.text = @"Area";
        detailTextLabel.text = [NSString stringWithFormat:@"%.2fM sq. km", self.country.area/1000000.0];
    }
    else if (indexPath.row == 2) {
        
        textLabel.text = @"Population";
        detailTextLabel.text = [NSString stringWithFormat:@"%.2fM", self.country.population/1000000.0];
    }
    else if (indexPath.row == 3) {
        
        textLabel.text = @"Languages";
        detailTextLabel.text = languages;
    }
    else {
        
        textLabel.text = @"Currencies";
        detailTextLabel.text = currencies;
        
        cell.separatorInset = UIEdgeInsetsMake(0, 3000.0, 0, 0);
    }
    
    return cell;
}

@end
