//
//  PHAreaDay.m
//  PHStreets44 project - Streets '44 iOS app
//
//  Created by Pawel Hryczuk on 9.05.2015.
//  Copyright (c) 2015 Pawel Hryczuk. All rights reserved.
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation; either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program. If not, see <http://www.gnu.org/licenses/>.
//

#import "PHAreaDay.h"
#import "PHPoint.h"
#import "NSValueTransformer+MTLPredefinedTransformerAdditions.h"
#import "MTLValueTransformer.h"
#import "PHUtils.h"

@implementation PHAreaDay

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
            @"date": @"date",
            @"points": @"points"
    };
}

+ (NSValueTransformer *)pointsJSONTransformer
{
    return [NSValueTransformer mtl_JSONArrayTransformerWithModelClass:[PHPoint class]];
}

+ (NSValueTransformer *)dateJSONTransformer
{
    return [MTLValueTransformer reversibleTransformerWithForwardBlock:^(NSString *str) {
        return [[PHUtils jsonDateFormatter] dateFromString:str];
    } reverseBlock:^(NSDate *date) {
        return [[PHUtils jsonDateFormatter] stringFromDate:date];
    }];
}

@end
