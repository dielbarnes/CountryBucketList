//
//  CountryListViewController.h
//  CountryBucketList
//
//  Created by Diel Barnes on 20/05/2017.
//  Copyright © 2017 Diel Barnes. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Country.h"

@class CountryListViewController;

@protocol CountryListViewControllerDelegate <NSObject>

@optional

- (void)countryListViewController:(nullable CountryListViewController *)countryListViewController pageDidAppear:(int)pageIndex;
- (void)countryListViewController:(nullable CountryListViewController *)countryListViewController countrySelected:(nonnull Country *)country;
- (void)countryListViewController:(nullable CountryListViewController *)countryListViewController countryAddedToBucketList:(nonnull Country *)country;
- (void)countryListViewController:(nullable CountryListViewController *)countryListViewController countryRemovedFromBucketList:(nonnull Country *)country;
- (void)countryListViewDidScroll:(nullable CountryListViewController *)countryListViewController;

@end

@interface CountryListViewController : UIViewController

@property (nonatomic, weak, nullable) id <CountryListViewControllerDelegate> delegate;
@property (nonatomic) int pageIndex;

- (void)reloadData:(nullable NSMutableArray *)updatedCountries bucketList:(nonnull NSMutableArray *)updatedBucketList;

@end
