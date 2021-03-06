//
//  Country.h
//  CountryBucketList
//
//  Created by Diel Barnes on 20/05/2017.
//  Copyright © 2017 Diel Barnes. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface Country : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *alpha2Code;
@property (nonatomic, strong) NSString *alpha3Code;
@property (nonatomic, strong) UIImage *flag;
@property (nonatomic, strong) NSString *region;
@property (nonatomic, strong) NSString *capital;
@property (nonatomic) float area;
@property (nonatomic) int population;
@property (nonatomic, strong) NSMutableArray *languages;
@property (nonatomic, strong) NSMutableArray *currencies;
@property (nonatomic) CLLocationCoordinate2D coordinate;
@property (nonatomic, strong) NSMutableArray *polygons;

@end
