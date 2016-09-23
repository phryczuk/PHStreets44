//
//  PHUtils.m
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

#import "PHUtils.h"

NSString *const kPHJSONDateFormat = @"yyyy-MM-dd";

@implementation PHUtils

+ (NSDateFormatter *)jsonDateFormatter {
    static dispatch_once_t once;
    static NSDateFormatter *formatter = nil;
    dispatch_once(&once, ^{
        formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = kPHJSONDateFormat;
    });
    return formatter;
}

+ (NSDateFormatter *)longDateFormatter {
    static dispatch_once_t once;
    static NSDateFormatter *formatter = nil;
    dispatch_once(&once, ^{
        formatter = [[NSDateFormatter alloc] init];
        formatter.locale = [NSLocale localeWithLocaleIdentifier:[self languageCode]];
        formatter.dateStyle = NSDateFormatterLongStyle;
        formatter.timeStyle = NSDateFormatterNoStyle;
    });
    return formatter;
}

+ (NSString *)languageCode {
    NSArray *preferredLanguages = [NSLocale preferredLanguages];
    for (NSString *languageCode in preferredLanguages) {
        if ([languageCode isEqualToString:@"pl"] || [languageCode isEqualToString:@"en"]) {
            return languageCode;
        }
    }
    return @"en";
}

@end
