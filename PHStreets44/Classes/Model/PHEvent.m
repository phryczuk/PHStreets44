//
//  PHEvent.m
//  PHStreets44 project - Streets '44 iOS app
//
//  Created by Pawel Hryczuk on 2.05.2015.
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

#import "PHEvent.h"
#import "PHUtils.h"
#import "MTLValueTransformer.h"

@interface PHEvent ()

@property (nonatomic, readonly, assign) CGFloat gpsLatitude;
@property (nonatomic, readonly, assign) CGFloat gpsLongitude;
@property (nonatomic, readonly, assign) CGFloat mapX;
@property (nonatomic, readonly, assign) CGFloat mapY;

@end

@implementation PHEvent

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
            @"id": @"id",
            @"date": @"date",
            @"photoName" : @"photo",
            @"lead_en" : @"lead_en",
            @"lead_pl" : @"lead_pl",
            @"storyTitle": @"story_title",
            @"storyBody_en": @"story_body_en",
            @"storyBody_pl": @"story_body_pl",
            @"district": @"district",
            @"gpsLatitude": @"gps_latitude",
            @"gpsLongitude": @"gps_longitude",
            @"mapX": @"map_x",
            @"mapY": @"map_y",
            @"photoCreditText_en": @"photoCreditText_en",
            @"photoCreditText_pl": @"photoCreditText_pl",
            @"photoCreditUrl": @"photoCreditUrl"
    };
}

+ (NSString *)jsonFilename {
    return @"events";
}

+ (NSValueTransformer *)dateJSONTransformer
{
    return [MTLValueTransformer reversibleTransformerWithForwardBlock:^(NSString *str) {
        return [[PHUtils jsonDateFormatter] dateFromString:str];
    } reverseBlock:^(NSDate *date) {
        return [[PHUtils jsonDateFormatter] stringFromDate:date];
    }];
}

- (CGPoint)gps {
    return CGPointMake(self.gpsLongitude, self.gpsLatitude);
}

- (CGPoint)map {
    return CGPointMake(self.mapX, self.mapY);
}

@end
