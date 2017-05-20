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
    
    self.flagView.image = self.country.flag;
    self.nameLabel.text = self.country.name;
    self.regionLabel.text = self.country.region;
    
    self.infoTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
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
    return 44.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"InfoCell"];
    
    if (indexPath.row == 0) {
        
        cell.textLabel.text = @"Capital";
        cell.detailTextLabel.text = self.country.capital;
    }
    else if (indexPath.row == 1) {
        
        cell.textLabel.text = @"Area";
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%.2fM sq. km", self.country.area/1000000.0];
    }
    else if (indexPath.row == 2) {
        
        cell.textLabel.text = @"Population";
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%.2fM", self.country.population/1000000.0];
    }
    else if (indexPath.row == 3) {
        
        cell.textLabel.text = @"Languages";
        cell.detailTextLabel.text = languages;
    }
    else {
        
        cell.textLabel.text = @"Currencies";
        cell.detailTextLabel.text = currencies;
    }
    
    return cell;
}

@end
