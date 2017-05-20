//
//  Country.m
//  CountryBucketList
//
//  Created by Diel Barnes on 20/05/2017.
//  Copyright © 2017 Diel Barnes. All rights reserved.
//

#import "Country.h"

@implementation Country

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.languages = [[NSMutableArray alloc] init];
        self.currencies = [[NSMutableArray alloc] init];
    }
    return self;
}

@end
