//
//  CustomTextField.m
//  CountryBucketList
//
//  Created by Diel on 01/06/2017.
//  Copyright © 2017 Diel Barnes. All rights reserved.
//

#import "CustomTextField.h"

@implementation CustomTextField

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    
    if (action == @selector(select:) || action == @selector(selectAll:) || action == @selector(cut:) || action == @selector(paste:)) {
        return NO;
    }
    else {
        return [super canPerformAction:action withSender:sender];
    }
}

@end
