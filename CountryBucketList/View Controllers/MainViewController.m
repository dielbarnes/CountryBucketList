//
//  ViewController.m
//  CountryBucketList
//
//  Created by Diel Barnes on 19/05/2017.
//  Copyright © 2017 Diel Barnes. All rights reserved.
//

#import "MainViewController.h"
#import "CountryListViewController.h"
#import "CountryViewController.h"

#define COLOR_PINK [UIColor colorWithRed:254.0/255.0 green:0/255.0 blue:89.0/255.0 alpha:1.0]
#define COLOR_TEXT [UIColor colorWithRed:16.0/255.0 green:50.0/255.0 blue:51.0/255.0 alpha:1.0]

@interface MainViewController () <UISearchBarDelegate, UIPageViewControllerDataSource, CountryListViewControllerDelegate, UIPickerViewDataSource, UIPickerViewDelegate>
{
    NSMutableArray *countries;
    NSMutableArray *filteredCountries;
    NSMutableArray *bucketList;
    NSMutableArray *filteredBucketList;
    NSMutableArray *regions;
    
    UIPageViewController *pageViewController;
    NSMutableArray *pages;
    int currentPage;
}

@property (nonatomic, strong) IBOutlet UIButton *allButton;
@property (nonatomic, strong) IBOutlet UIButton *bucketListButton;
@property (nonatomic, strong) IBOutlet UIButton *viewModeButton;
@property (nonatomic, strong) IBOutlet UISearchBar *searchBar;
@property (nonatomic, strong) IBOutlet UIButton *regionButton;
@property (nonatomic, strong) IBOutlet UIView *pageView;
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (nonatomic, strong) IBOutlet UIPickerView *picker;
@property (nonatomic, strong) IBOutlet NSLayoutConstraint *pickerBottomSpace;

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //UI
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    
    self.allButton.layer.cornerRadius = 20.0;
    self.bucketListButton.layer.cornerRadius = 20.0;
    
    [[UITextField appearance] setFont:[UIFont fontWithName:@"Avenir" size:17.0]];
    
    [self setupPageView];
    
    //Data
    
    countries = [[NSMutableArray alloc] init];
    filteredCountries = [[NSMutableArray alloc] init];
    bucketList = [[NSMutableArray alloc] init];
    filteredBucketList = [[NSMutableArray alloc] init];
    regions = [[NSMutableArray alloc] initWithObjects:@"Anywhere", nil];
    
    [self getCountries];
}

#pragma mark - Web Requests

- (void)getCountries {
    
    [self.activityIndicator startAnimating];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"https://restcountries.eu/rest/v2/all"]];
    
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        if (error != nil) { //Fail
            
            dispatch_async(dispatch_get_main_queue(), ^(void){
                
                [self.activityIndicator stopAnimating];
                
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Failed To Get Countries" message:error.localizedDescription preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
                [alertController addAction:action];
                [self presentViewController:alertController animated:YES completion:nil];
            });
        }
        else { //Success
            
            if (data != nil) {
                
                NSArray *array = [NSJSONSerialization JSONObjectWithData:data options: NSJSONReadingMutableContainers error:nil];
                for (NSDictionary *json in array) {
                    
                    Country *country = [[Country alloc] init];
                    country.name = json[@"name"];
                    country.alphaCode = json[@"alpha2Code"];
                    country.flag = [UIImage imageNamed:country.alphaCode];
                    country.region = json[@"subregion"];
                    country.capital = json[@"capital"];
                    if (![json[@"area"] isKindOfClass:[NSNull class]]) {
                        country.area = [json[@"area"] intValue];
                    }
                    if (![json[@"population"] isKindOfClass:[NSNull class]]) {
                        country.population = [json[@"population"] intValue];
                    }
                    
                    NSArray *languages = json[@"languages"];
                    for (NSDictionary *language in languages) {
                        
                        [country.languages addObject:language[@"name"]];
                    }
                    
                    NSArray *currencies = json[@"currencies"];
                    for (NSDictionary *currency in currencies) {
                        
                        NSString *currencyString = [NSString stringWithFormat:@"%@ %@", currency[@"symbol"], currency[@"name"]];
                        [country.currencies addObject:currencyString];
                    }
                    
                    NSArray *coordinates = json[@"latlng"];
                    if (coordinates != nil && coordinates.count > 0) {
                        country.coordinates = CLLocationCoordinate2DMake([coordinates[0] doubleValue], [coordinates[1] doubleValue]);
                    }
                    
                    [countries addObject:country];
                    
                    if (![regions containsObject:country.region]) {
                        [regions addObject:country.region];
                    }
                }
                
                [filteredCountries addObjectsFromArray:countries];
                
                dispatch_async(dispatch_get_main_queue(), ^(void){
                    
                    [self.activityIndicator stopAnimating];
                    
                    CountryListViewController *countryListViewController = pages[0];
                    [countryListViewController reloadData:filteredCountries];
                });
            }
        }
    }];
    [task resume];
}

#pragma mark - Button Methods

- (IBAction)allButtonTapped {
    
    if (currentPage != 0) {
        
        [self makeAllButtonActive];
        
        [pageViewController setViewControllers:@[pages[0]] direction:UIPageViewControllerNavigationDirectionReverse animated:YES completion:nil];
    }
}

- (void)makeAllButtonActive {
    
    self.allButton.backgroundColor = COLOR_PINK;
    [self.allButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.bucketListButton.backgroundColor = [UIColor clearColor];
    [self.bucketListButton setTitleColor:COLOR_TEXT forState:UIControlStateNormal];
}

- (IBAction)bucketListButtonTapped {
    
    if (currentPage != 1) {
        
        [self makeBucketListButtonActive];
        
        [pageViewController setViewControllers:@[pages[1]] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
    }
}

- (void)makeBucketListButtonActive {
    
    self.bucketListButton.backgroundColor = COLOR_PINK;
    [self.bucketListButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.allButton.backgroundColor = [UIColor clearColor];
    [self.allButton setTitleColor:COLOR_TEXT forState:UIControlStateNormal];
}

- (IBAction)viewModeButtonTapped {
    
}

#pragma mark - Search Bar Methods

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    [searchBar setShowsCancelButton:YES animated:YES];
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    [searchBar setShowsCancelButton:NO animated:YES];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    
    if (searchText.length == 0) {
        
        [filteredCountries removeAllObjects];
        [filteredCountries addObjectsFromArray:countries];
        [filteredBucketList removeAllObjects];
        [filteredBucketList addObjectsFromArray:bucketList];
        
        if (currentPage == 0) {
            CountryListViewController *countryListViewController = pages[0];
            [countryListViewController hideNoResultsLabel];
            [countryListViewController reloadData:filteredCountries];
        }
        else {
            CountryListViewController *countryListViewController = pages[1];
            [countryListViewController hideNoResultsLabel];
            [countryListViewController reloadData:filteredBucketList];
        }
    }
    else {
        [self filterCountries];
    }
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    
    [self filterCountries];
    [self.searchBar resignFirstResponder];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [self.searchBar resignFirstResponder];
}

- (void)filterCountries {
    
}

#pragma mark - Page View Methods

- (void)setupPageView {
    
    pageViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PageViewController"];
    pages = [[NSMutableArray alloc] init];
    currentPage = 0;
    
    for (int i = 0; i < 2; i++) {
        
        CountryListViewController *countryListViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"CountryListViewController"];
        countryListViewController.pageIndex = i;
        countryListViewController.delegate = self;
        [pages addObject:countryListViewController];
    }
    
    pageViewController.dataSource = self;
    [pageViewController setViewControllers:@[pages[0]] direction:UIPageViewControllerNavigationDirectionForward animated:false completion:nil];
    
    CGRect frame = self.pageView.frame;
    frame.origin.y = 0;
    pageViewController.view.frame = frame;
    [self.pageView addSubview:pageViewController.view];
    
    NSLayoutConstraint *topConstraint = [NSLayoutConstraint constraintWithItem:pageViewController.view attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.pageView attribute:NSLayoutAttributeTop multiplier:1.0 constant:0];
    NSLayoutConstraint *botConstraint = [NSLayoutConstraint constraintWithItem:pageViewController.view attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.pageView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0];
    NSLayoutConstraint *leadConstraint = [NSLayoutConstraint constraintWithItem:pageViewController.view attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.pageView attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0];
    NSLayoutConstraint *trailConstraint = [NSLayoutConstraint constraintWithItem:pageViewController.view attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.pageView attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0];
    [self.pageView addConstraints:@[topConstraint, botConstraint, leadConstraint, trailConstraint]];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    
    CountryListViewController *countryListViewController = (CountryListViewController *)viewController;
    
    if (countryListViewController.pageIndex > 0) {
        return pages[countryListViewController.pageIndex-1];
    }
    
    return nil;
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    
    CountryListViewController *countryListViewController = (CountryListViewController *)viewController;

    if (countryListViewController.pageIndex < 1) {
        return pages[countryListViewController.pageIndex+1];
    }
    
    return nil;
}

#pragma mark - Country List View Controller Delegate Methods

- (void)countryListViewController:(CountryListViewController *)countryListViewController pageDidAppear:(int)pageIndex {
    
    NSLog(@"page %i", pageIndex);
    
    currentPage = pageIndex;
    
    if (currentPage == 0) {
        [self makeAllButtonActive];
    }
    else {
        [self makeBucketListButtonActive];
    }
}

- (void)countryListViewController:(CountryListViewController *)countryListViewController countrySelected:(Country *)country {
    
    CountryViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"CountryViewController"];
    viewController.country = country;
}

- (void)countryListViewController:(CountryListViewController *)countryListViewController countryAddedToBucketList:(Country *)country {
    
}

- (void)countryListViewController:(CountryListViewController *)countryListViewController countryRemovedFromBucketList:(Country *)country {
    
}

#pragma mark - Picker Methods

- (IBAction)showPicker {
    
    self.pickerBottomSpace.constant = 0;
    
    [UIView animateWithDuration:0.4 animations:^{
        [self.view layoutIfNeeded];
    }];
}

- (void)hidePicker {
    
    self.pickerBottomSpace.constant = -self.picker.frame.size.height;;
    
    [UIView animateWithDuration:0.4 animations:^{
        [self.view layoutIfNeeded];
    }];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return regions.count;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return regions[row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    [self.regionButton setTitle:regions[row] forState:UIControlStateNormal];
    [self hidePicker];
}

@end
