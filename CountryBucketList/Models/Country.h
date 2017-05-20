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
@property (nonatomic, strong) NSString *alphaCode;
@property (nonatomic, strong) UIImage *flag;
@property (nonatomic, strong) NSString *region;
@property (nonatomic, strong) NSString *capital;
@property (nonatomic) int area;
@property (nonatomic) int population;
@property (nonatomic, strong) NSMutableArray *languages;
@property (nonatomic, strong) NSMutableArray *currencies;
@property (nonatomic) CLLocationCoordinate2D coordinates;

@end
