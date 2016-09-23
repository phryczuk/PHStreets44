//
//  PHAppState.m
//  PHStreets44 project - Streets '44 iOS app
//
//  Created by Pawel Hryczuk on 1.05.2015.
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

#import "PHAppState.h"
#import "PHConstants.h"
#import "PHAppContext.h"
#import "PHUtils.h"

NSString *const kPHAppStateTodayKey = @"kPHAppStateToday";
NSString *const kPHAppStateMapInitialZoomScale = @"kPHAppStateMapInitialZoomScale";
NSString *const kPHAppStateMapInitialContentOffset = @"kPHAppStateMapInitialContentOffset";

CGPoint const kPHAppStateNoPointValue = {-1, -1};

@interface PHAppState ()

@property (nonatomic, strong) NSDate *currentDate;

@end

@implementation PHAppState

- (id)init {
    self = [super init];

    if (self) {
        [self registerDefaults];
        [self loadDefaults];
    }

    return self;
}

#pragma mark - NSUserDefaults

- (void)registerDefaults {
    NSDictionary *defaultValues = @{
            kPHAppStateTodayKey : [[PHUtils jsonDateFormatter] dateFromString:kPHDefaultDate],
            kPHAppStateMapInitialContentOffset : NSStringFromCGPoint(kPHAppStateNoPointValue)
    };
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults registerDefaults:defaultValues];
}

- (void)loadDefaults {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    _currentDate = [defaults objectForKey:kPHAppStateTodayKey];
    _mapInitialZoomScale = [defaults floatForKey:kPHAppStateMapInitialZoomScale];
    _mapInitialContentOffset = CGPointFromString([defaults objectForKey:kPHAppStateMapInitialContentOffset]);
}

- (void)saveDefaults {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:self.currentDate forKey:kPHAppStateTodayKey];
    [defaults setFloat:self.mapInitialZoomScale forKey:kPHAppStateMapInitialZoomScale];
    [defaults setObject:NSStringFromCGPoint(self.mapInitialContentOffset) forKey:kPHAppStateMapInitialContentOffset];
    [defaults synchronize];
}

#pragma mark - Overridden property accessors

- (void)setCurrentDate:(NSDate *)currentDate {
    _currentDate = currentDate;
    [self saveDefaults];
}

- (NSDate *)earliestDate {
    return [[PHUtils jsonDateFormatter] dateFromString:kPHEarliestDate];
}

- (NSDate *)latestDate {
    return [[PHUtils jsonDateFormatter] dateFromString:kPHLatestDate];
}

- (void)setMapInitialZoomScale:(CGFloat)mapInitialZoomScale {
    _mapInitialZoomScale = mapInitialZoomScale;
    [self saveDefaults];
}

- (void)setMapInitialContentOffset:(CGPoint)mapInitialContentOffset {
    _mapInitialContentOffset = mapInitialContentOffset;
    [self saveDefaults];
}

#pragma mark - Public methods

- (void)addDays:(int)day weeks:(int)week {
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    dateComponents.day = day;
    dateComponents.weekOfYear = week;
    NSDate *newCurrentDate = [[NSCalendar currentCalendar] dateByAddingComponents:dateComponents toDate:self.currentDate options:kNilOptions];
    self.currentDate = [self dateWithinValidRange:newCurrentDate];
}

- (NSDate *)dateWithinValidRange:(NSDate *)date {
    NSDate *validDate = date;
    if ([date compare:APP_STATE.earliestDate] == NSOrderedAscending) {
        validDate = APP_STATE.earliestDate;
    }

    if ([date compare:APP_STATE.latestDate] == NSOrderedDescending) {
        validDate = APP_STATE.latestDate;
    }
    return validDate;
}

- (BOOL)isMapInitialContentOffset {
    return !CGPointEqualToPoint(self.mapInitialContentOffset, kPHAppStateNoPointValue);
}

@end
