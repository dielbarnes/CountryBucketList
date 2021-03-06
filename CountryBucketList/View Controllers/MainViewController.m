//
//  ViewController.m
//  CountryBucketList
//
//  Created by Diel Barnes on 19/05/2017.
//  Copyright © 2017 Diel Barnes. All rights reserved.
//

#import <MapKit/MapKit.h>
#import "MainViewController.h"
#import "CountryListViewController.h"
#import "CountryViewController.h"
#import "CustomTextField.h"

#define COLOR_PINK [UIColor colorWithRed:254.0/255.0 green:0/255.0 blue:89.0/255.0 alpha:1.0]
#define COLOR_TEXT [UIColor colorWithRed:16.0/255.0 green:50.0/255.0 blue:51.0/255.0 alpha:1.0]

@interface MainViewController () <UISearchBarDelegate, UITextFieldDelegate, UIPageViewControllerDataSource, CountryListViewControllerDelegate, MKMapViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate, UIGestureRecognizerDelegate>
{
    NSMutableArray *regions;
    NSMutableArray *countries;
    NSMutableArray *filteredCountries;
    NSMutableArray *bucketList;
    NSMutableArray *filteredBucketList;
    NSMutableDictionary *countryPolygons;
    
    UIPageViewController *pageViewController;
    NSMutableArray *pages;
    int currentPage;
    
    BOOL mapShouldSetRegion;
    
    UIPickerView *picker;
    
    CountryViewController *countryViewController;
    UIView *dimView;
}

@property (nonatomic, strong) IBOutlet UIButton *allButton;
@property (nonatomic, strong) IBOutlet UIButton *bucketListButton;
@property (nonatomic, strong) IBOutlet UIButton *viewModeButton;
@property (nonatomic, strong) IBOutlet UIView *searchFilterView;
@property (nonatomic, strong) IBOutlet UISearchBar *searchBar;
@property (nonatomic, strong) IBOutlet CustomTextField *regionTextField;
@property (nonatomic, strong) IBOutlet UIView *pageView;
@property (nonatomic, strong) IBOutlet MKMapView *mapView;
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *activityIndicator;

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //UI
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    
    self.allButton.layer.cornerRadius = 20.0;
    self.bucketListButton.layer.cornerRadius = 20.0;
    
    [self.searchFilterView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(resignTextFields)]];
    
    [[UITextField appearance] setFont:[UIFont fontWithName:@"Avenir" size:17.0]];
    
    self.regionTextField.tintColor = [UIColor clearColor];
    self.regionTextField.rightView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"dropdown-arrow"]];
    self.regionTextField.rightViewMode = UITextFieldViewModeAlways;
    
    picker = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, 216.0)];
    picker.dataSource = self;
    picker.delegate = self;
    picker.backgroundColor = [UIColor colorWithRed:204.0/255.0 green:216.0/255.0 blue:221.0/255.0 alpha:1.0];
    self.regionTextField.inputView = picker;
    
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(pickerTapGestureRecognized)];
    gestureRecognizer.delegate = self;
    [picker addGestureRecognizer:gestureRecognizer];
    
    mapShouldSetRegion = YES;
    
    dimView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height)];
    dimView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.6];
    [dimView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideCountryView)]];
    [self.navigationController.view addSubview:dimView];
    
    [self setupPageView];
    
    //Data
    
    regions = [[NSMutableArray alloc] initWithObjects:@"Anywhere", nil];
    countries = [[NSMutableArray alloc] init];
    filteredCountries = [[NSMutableArray alloc] init];
    bucketList = [[NSMutableArray alloc] init];
    filteredBucketList = [[NSMutableArray alloc] init];
    
    [self getCountryPolygons];
    
    [self getCountries];
}

#pragma mark - Web Requests

- (void)getCountries {
    
    [self.activityIndicator startAnimating];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"https://restcountries.eu/rest/v2/all"]];
    
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        if (error) { //Fail
            
            dispatch_async(dispatch_get_main_queue(), ^(void){
                
                [self.activityIndicator stopAnimating];
                [self hideDimView];
                
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Failed To Get Countries" message:error.localizedDescription preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
                [alertController addAction:action];
                [self presentViewController:alertController animated:YES completion:nil];
            });
        }
        else { //Success
            
            if (data) {
                
                NSArray *savedBucketList = [[NSUserDefaults standardUserDefaults] objectForKey:@"bucketList"];
                
                NSArray *array = [NSJSONSerialization JSONObjectWithData:data options: NSJSONReadingMutableContainers error:nil];
                for (NSDictionary *json in array) {
                    
                    Country *country = [[Country alloc] init];
                    if (![json[@"name"] isKindOfClass:[NSNull class]]) {
                        country.name = json[@"name"];
                    }
                    if (![json[@"alpha2Code"] isKindOfClass:[NSNull class]]) {
                        country.alpha2Code = json[@"alpha2Code"];
                    }
                    if (![json[@"alpha3Code"] isKindOfClass:[NSNull class]]) {
                        country.alpha3Code = json[@"alpha3Code"];
                    }
                    country.flag = [UIImage imageNamed:country.alpha2Code];
                    if (![json[@"subregion"] isKindOfClass:[NSNull class]]) {
                        country.region = json[@"subregion"];
                    }
                    if (![json[@"capital"] isKindOfClass:[NSNull class]]) {
                        country.capital = json[@"capital"];
                    }
                    if (![json[@"area"] isKindOfClass:[NSNull class]]) {
                        country.area = [json[@"area"] floatValue];
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
                        
                        NSString *currencyString = @"";
                        if (![currency[@"symbol"] isKindOfClass:[NSNull class]]) {
                            currencyString = [currencyString stringByAppendingString:[NSString stringWithFormat:@"%@ ", currency[@"symbol"]]];
                        }
                        if (![currency[@"name"] isKindOfClass:[NSNull class]]) {
                            currencyString = [currencyString stringByAppendingString:[NSString stringWithFormat:@"%@", currency[@"name"]]];
                            
                            if (currencyString.length > 0) {
                                [country.currencies addObject:currencyString];
                            }
                        }
                    }
                    
                    NSArray *coordinates = json[@"latlng"];
                    if (coordinates && coordinates.count == 2) {
                        country.coordinate = CLLocationCoordinate2DMake([coordinates[0] doubleValue], [coordinates[1] doubleValue]);
                    }
                    
                    NSMutableArray *polygons = countryPolygons[country.alpha3Code];
                    if (polygons) {
                        country.polygons = polygons;
                    }
                    
                    [countries addObject:country];
                    
                    if (savedBucketList && [savedBucketList containsObject:country.alpha2Code]) {
                        [bucketList addObject:country];
                    }
                    
                    if (country.region.length > 0 && ![regions containsObject:country.region]) {
                        [regions addObject:country.region];
                    }
                }
                
                NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
                countries = [[countries sortedArrayUsingDescriptors:@[sortDescriptor]] mutableCopy];
                [filteredCountries addObjectsFromArray:countries];
                if (bucketList.count > 0) {
                    bucketList = [[bucketList sortedArrayUsingDescriptors:@[sortDescriptor]] mutableCopy];
                    [filteredBucketList addObjectsFromArray:bucketList];
                }
                regions = [[regions sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)] mutableCopy];
                
                //Update UI
                
                dispatch_async(dispatch_get_main_queue(), ^(void){
                    
                    [self.activityIndicator stopAnimating];
                    [self hideDimView];
                    
                    CountryListViewController *allCountriesViewController = pages[0];
                    [allCountriesViewController reloadData:filteredCountries bucketList:filteredBucketList];
                    CountryListViewController *bucketListViewController = pages[1];
                    [bucketListViewController reloadData:nil bucketList:filteredBucketList];
                    
                    [picker reloadAllComponents];
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
        
        __weak typeof(self) weakSelf = self;
        [pageViewController setViewControllers:@[pages[0]] direction:UIPageViewControllerNavigationDirectionReverse animated:YES completion:^(BOOL finished) {
            
            if (!weakSelf.mapView.hidden) {
                [weakSelf addMapOverlays];
            }
        }];
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
        
        __weak typeof(self) weakSelf = self;
        [pageViewController setViewControllers:@[pages[1]] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:^(BOOL finished) {
            
            if (!weakSelf.mapView.hidden) {
                [weakSelf addMapOverlays];
            }
        }];
    }
}

- (void)makeBucketListButtonActive {
    
    self.bucketListButton.backgroundColor = COLOR_PINK;
    [self.bucketListButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.allButton.backgroundColor = [UIColor clearColor];
    [self.allButton setTitleColor:COLOR_TEXT forState:UIControlStateNormal];
}

- (IBAction)viewModeButtonTapped {
    
    [self resignTextFields];
    
    if (self.mapView.hidden) {
        
        [self.viewModeButton setImage:[UIImage imageNamed:@"list"] forState:UIControlStateNormal];
        self.mapView.hidden = NO;
        
        if (mapShouldSetRegion) {
            
            MKCoordinateSpan span = MKCoordinateSpanMake(60.0, 60.0);
            MKCoordinateRegion region = MKCoordinateRegionMake(self.mapView.region.center, span);
            [self.mapView setRegion:region animated:NO];
            
            mapShouldSetRegion = NO;
        }
        
        [self addMapOverlays];
    }
    else {
        [self.viewModeButton setImage:[UIImage imageNamed:@"map"] forState:UIControlStateNormal];
        self.mapView.hidden = YES;
    }
}

#pragma mark - Search Methods

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    [searchBar setShowsCancelButton:YES animated:YES];
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    [searchBar setShowsCancelButton:NO animated:YES];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    
    if (searchText.length == 0 && [self.regionTextField.text isEqualToString:@"Anywhere"]) {
        [self removeFilters];
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

- (void)removeFilters {
    
    [filteredCountries removeAllObjects];
    [filteredCountries addObjectsFromArray:countries];
    [filteredBucketList removeAllObjects];
    [filteredBucketList addObjectsFromArray:bucketList];
    
    CountryListViewController *allCountriesViewController = pages[0];
    [allCountriesViewController reloadData:filteredCountries bucketList:filteredBucketList];
    CountryListViewController *bucketListViewController = pages[1];
    [bucketListViewController reloadData:nil bucketList:filteredBucketList];
    
    if (!self.mapView.hidden) {
        [self addMapOverlays];
    }
}

- (void)filterCountries {
    
    NSPredicate *predicate;
    
    NSString *searchText = [self.searchBar.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (searchText.length > 0) {
        
        if ([self.regionTextField.text isEqualToString:@"Anywhere"]) {
            predicate = [NSPredicate predicateWithFormat:@"SELF.name CONTAINS[c] %@", searchText];
        }
        else {
            predicate = [NSPredicate predicateWithFormat:@"SELF.name CONTAINS[c] %@ && SELF.region == %@", searchText, self.regionTextField.text];
        }
    }
    else {
        predicate = [NSPredicate predicateWithFormat:@"SELF.region == %@", self.regionTextField.text];
    }
    
    [filteredCountries removeAllObjects];
    [filteredCountries addObjectsFromArray:[countries filteredArrayUsingPredicate:predicate]];
    [filteredBucketList removeAllObjects];
    [filteredBucketList addObjectsFromArray:[bucketList filteredArrayUsingPredicate:predicate]];
    
    CountryListViewController *allCountriesViewController = pages[0];
    [allCountriesViewController reloadData:filteredCountries bucketList:filteredBucketList];
    CountryListViewController *bucketListViewController = pages[1];
    [bucketListViewController reloadData:nil bucketList:filteredBucketList];
    
    if (!self.mapView.hidden) {
        [self addMapOverlays];
    }
}

#pragma mark - Text Field Methods

- (void)resignTextFields {
    [self.view endEditing:YES];
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
    [pageViewController setViewControllers:@[pages[0]] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    
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
    
    currentPage = pageIndex;
    
    if (currentPage == 0) { //Page: All Countries
        [self makeAllButtonActive];
    }
    else { //Page: Bucket List
        [self makeBucketListButtonActive];
    }
}

- (void)countryListViewController:(CountryListViewController *)countryListViewController countrySelected:(Country *)country {
    
    [self resignTextFields];
    [self showCountryView:country];
}

- (void)countryListViewController:(CountryListViewController *)countryListViewController countryAddedToBucketList:(Country *)country {
    
    //Add country to bucket list
    
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
    
    [bucketList addObject:country];
    bucketList = [[bucketList sortedArrayUsingDescriptors:@[sortDescriptor]] mutableCopy];
    
    [filteredBucketList addObject:country];
    filteredBucketList = [[filteredBucketList sortedArrayUsingDescriptors:@[sortDescriptor]] mutableCopy];
    
    [self updateSavedBucketList];
    
    //Current page is always 0 (All Countries)
    //Update Bucket List page
    
    CountryListViewController *bucketListViewController = pages[1];
    [bucketListViewController reloadData:nil bucketList:filteredBucketList];
}

- (void)countryListViewController:(CountryListViewController *)countryListViewController countryRemovedFromBucketList:(Country *)country {
    
    //Remove country from bucket list
    
    NSUInteger index1 = [bucketList indexOfObjectPassingTest:^(id obj, NSUInteger idx, BOOL *stop) {
        Country *object = (Country *)obj;
        return [object.name isEqualToString:country.name];
    }];
    [bucketList removeObjectAtIndex:index1];
    
    NSUInteger index2 = [filteredBucketList indexOfObjectPassingTest:^(id obj, NSUInteger idx, BOOL *stop) {
        Country *object = (Country *)obj;
        return [object.name isEqualToString:country.name];
    }];
    [filteredBucketList removeObjectAtIndex:index2];
    
    [self updateSavedBucketList];
    
    //Update the other page
    
    if (currentPage == 0) { //Page: All Countries
        
        CountryListViewController *bucketListViewController = pages[1];
        [bucketListViewController reloadData:nil bucketList:filteredBucketList];
    }
    else { //Page: Bucket List
        
        CountryListViewController *allCountriesViewController = pages[0];
        [allCountriesViewController reloadData:filteredCountries bucketList:filteredBucketList];
    }
}

- (void)countryListViewDidScroll:(CountryListViewController *)countryListViewController {
    [self resignTextFields];
}

#pragma mark - Map Methods

- (void)getCountryPolygons {
    
    countryPolygons = [[NSMutableDictionary alloc] init];
    
    NSString *filename = [[NSBundle mainBundle] pathForResource:@"geo" ofType:@"json"];
    NSData *data = [NSData dataWithContentsOfFile:filename];
    NSArray *json = [[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil] objectForKey:@"features"];
    for (NSDictionary *item in json) {
        
        NSString *alpha3Code = item[@"id"];
        NSMutableArray *polygons = [[NSMutableArray alloc] init];
        
        NSDictionary *geometry = item[@"geometry"];
        if ([geometry[@"type"] isEqualToString:@"Polygon"]) {
           
            MKPolygon *polygon = [self polygonFromCoordinates:geometry[@"coordinates"] title:alpha3Code];
            if (polygon) {
                [polygons addObject:polygon];
            }
        }
        else if ([geometry[@"type"] isEqualToString:@"MultiPolygon"]){
            
            for (NSArray *coordinates in geometry[@"coordinates"]) {
                
                MKPolygon *polygon = [self polygonFromCoordinates:coordinates title:alpha3Code];
                if (polygon) {
                    [polygons addObject:polygon];
                }
            }
        }
        
        countryPolygons[alpha3Code] = polygons;
    }
}

- (MKPolygon *)polygonFromCoordinates:(NSArray *)coordinates title:(NSString *)title {
    
    NSMutableArray *interiorPolygons = [NSMutableArray arrayWithCapacity:coordinates.count-1];
    for (int i = 1; i < coordinates.count; i++) {
        [interiorPolygons addObject:[self polygonFromCoordinates:coordinates[i] interiorPolygons:nil]];
    }
    
    MKPolygon *polygon = [self polygonFromCoordinates:coordinates[0] interiorPolygons:interiorPolygons];
    polygon.title = title;
    return polygon;
}

- (MKPolygon *)polygonFromCoordinates:(NSArray *)coordinates interiorPolygons:(NSArray *)interiorPolygons {
    
    CLLocationCoordinate2D *polygonPoints = malloc(coordinates.count * sizeof(CLLocationCoordinate2D));
    
    for (int i = 0; i < coordinates.count; i++) {
        
        NSArray *point = coordinates[i];
        polygonPoints[i] = CLLocationCoordinate2DMake([point[1] floatValue], [point[0] floatValue]);
    }
    
    MKPolygon *polygon;
    if (interiorPolygons) {
        polygon = [MKPolygon polygonWithCoordinates:polygonPoints count:coordinates.count interiorPolygons:interiorPolygons];
    } else {
        polygon = [MKPolygon polygonWithCoordinates:polygonPoints count:coordinates.count];
    }
    
    free(polygonPoints);
    
    return polygon;
}

- (void)addMapOverlays {
    
    [self.mapView removeOverlays:self.mapView.overlays];
    [self.mapView removeAnnotations:self.mapView.annotations];
    
    for (Country *country in filteredBucketList) {
        [self.mapView addOverlays:country.polygons];
    }
    
    if (currentPage == 0) { //Page: All Countries
        
        for (Country *country in filteredCountries) {
            
            MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
            annotation.coordinate = country.coordinate;
            annotation.title = country.alpha2Code;
            [self.mapView addAnnotation:annotation];
        }
    }
    else { //Page: Bucket List
        
        for (Country *country in filteredBucketList) {
            
            MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
            annotation.coordinate = country.coordinate;
            annotation.title = country.alpha2Code;
            [self.mapView addAnnotation:annotation];
        }
    }
}

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay {
    
    MKPolygonRenderer *renderer = [[MKPolygonRenderer alloc] initWithPolygon:overlay];
    renderer.lineWidth = 1;
    renderer.strokeColor = COLOR_PINK;
    renderer.fillColor = [UIColor colorWithRed:254.0/255.0 green:0/255.0 blue:89.0/255.0 alpha:0.6];
    return renderer;
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {

    MKAnnotationView *annotationView = (MKAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:@"FlagAnnotation"];
    if (!annotationView) {
        annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"FlagAnnotation"];
    }
    
    annotationView.image = [UIImage imageNamed:annotation.title];
    
    return annotationView;
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
    
    [mapView deselectAnnotation:view.annotation animated:NO];
    
    NSString *alpha2Code = view.annotation.title;
    
    Country *country;
    
    if (currentPage == 0) { //Page: All Countries
        
        NSUInteger index = [filteredCountries indexOfObjectPassingTest:^(id obj, NSUInteger idx, BOOL *stop) {
            Country *object = (Country *)obj;
            return [object.alpha2Code isEqualToString:alpha2Code];
        }];
        
        if (index != NSNotFound) {
            country = filteredCountries[index];
        }
    }
    else { //Page: Bucket List
        
        NSUInteger index = [filteredBucketList indexOfObjectPassingTest:^(id obj, NSUInteger idx, BOOL *stop) {
            Country *object = (Country *)obj;
            return [object.alpha2Code isEqualToString:alpha2Code];
        }];
        
        if (index != NSNotFound) {
            country = filteredBucketList[index];
        }
    }
    
    [self showCountryView:country];
}

- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated {
    [self resignTextFields];
}

#pragma mark - Country View Methods

- (void)showDimView {
    
    dimView.hidden = NO;
    [UIView animateWithDuration:0.4 animations:^{
        dimView.alpha = 0.6;
    }];
}

- (void)hideDimView {
    
    if (self.activityIndicator.hidden) {
        
        [UIView animateWithDuration:0.4 animations:^{
            dimView.alpha = 0;
        } completion:^(BOOL finished) {
            dimView.hidden = YES;
        }];
    }
}

- (void)showCountryView:(Country *)country {
    
    [self showDimView];
    
    if (!countryViewController) {
        countryViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"CountryViewController"];
        countryViewController.view.frame = CGRectMake([[UIScreen mainScreen] bounds].size.width / 2.0 - 140.0, [[UIScreen mainScreen] bounds].size.height / 2.0 - 194.0, 280.0, 388.0);
        countryViewController.view.clipsToBounds = YES;
        countryViewController.view.layer.cornerRadius = 15.0;
    }
    
    [self.navigationController.view addSubview:countryViewController.view];
    
    NSLayoutConstraint *widthConstraint = [NSLayoutConstraint constraintWithItem:countryViewController.view attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:280.0];
    NSLayoutConstraint *heightConstraint = [NSLayoutConstraint constraintWithItem:countryViewController.view attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:388.0];
    [countryViewController.view addConstraints:@[widthConstraint, heightConstraint]];
    
    NSLayoutConstraint *centerXConstraint = [NSLayoutConstraint constraintWithItem:countryViewController.view attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.navigationController.view attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0];
    NSLayoutConstraint *centerYConstraint = [NSLayoutConstraint constraintWithItem:countryViewController.view attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.navigationController.view attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0];
    [self.navigationController.view addConstraints:@[centerXConstraint, centerYConstraint]];
    
    [countryViewController loadData:country];
}

- (void)hideCountryView {
    
    [countryViewController.view removeFromSuperview];
    [self hideDimView];
}

#pragma mark - Picker Methods

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return regions.count;
}

- (NSAttributedString *)pickerView:(UIPickerView *)pickerView attributedTitleForRow:(NSInteger)row forComponent:(NSInteger)component {

    NSMutableAttributedString *title = [[NSMutableAttributedString alloc] initWithString:regions[row] attributes:@{ NSForegroundColorAttributeName: COLOR_TEXT, NSFontAttributeName: [UIFont fontWithName:@"Avenir" size:17.0]}];
    return title;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    
    self.regionTextField.text = regions[row];
    
    NSString *searchText = [self.searchBar.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if ([self.regionTextField.text isEqualToString:@"Anywhere"] && searchText.length == 0) {
        [self removeFilters];
    }
    else {
        [self filterCountries];
    }
}

- (void)pickerTapGestureRecognized {
    [self.regionTextField resignFirstResponder];
}

#pragma mark - Gesture Recognizer Methods

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

#pragma mark - User Defaults

- (void)updateSavedBucketList {
    
    if (bucketList.count > 0) {
        
        NSMutableArray *array = [[NSMutableArray alloc] init];
        for (Country *country in bucketList) {
            [array addObject:country.alpha2Code];
        }
        [[NSUserDefaults standardUserDefaults] setObject:array forKey:@"bucketList"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    else {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"bucketList"];
    }
}

@end
