//
//  PHDataManager.m
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

#import "PHDataManager.h"
#import "MTLJSONAdapter.h"
#import "PHEvent.h"
#import "PHArea.h"
#import "PHAreaDay.h"
#import "PHPoint.h"

@interface PHDataManager ()

@property (nonatomic, strong) NSArray *events;
@property (nonatomic, strong) NSArray *areas;

@end

@implementation PHDataManager

#pragma mark - Data loading

- (id)init {
    self = [super init];
    if (self) {
        [self loadData];
    }
    return self;
}

- (void)loadData {
    self.events = [self loadJson:[PHEvent class]];
    self.areas = [self loadJson:[PHArea class]];
}

- (NSArray *)loadJson:(Class<PHLocalStaticModel>)modelClass {
    NSString *filePath = [[NSBundle mainBundle] pathForResource:[modelClass jsonFilename] ofType:@"json"];
    NSInputStream *stream = [NSInputStream inputStreamWithFileAtPath:filePath];
    [stream open];
    NSError *error;
    NSArray *json = [NSJSONSerialization JSONObjectWithStream:stream options:kNilOptions error:&error];
    NSAssert(json, @"File %@.json must be a valid json (error: %@)", [modelClass jsonFilename], error);
    [stream close];

    NSArray *models = [MTLJSONAdapter modelsOfClass:modelClass fromJSONArray:json error:&error];
    NSAssert(models, @"Contents of %@.json must map to %@ model class (error: %@)", [modelClass jsonFilename], NSStringFromClass(modelClass), error);
    return models;
}

#pragma mark - Queries

#pragma mark Areas

- (NSArray *)pointsForAreaId:(NSString *)areaId andDate:(NSDate *)date {
    for (PHArea *area in self.areas) {
        if ([area.id isEqualToString:areaId]) {
            NSArray *lastDatePoints;
            for (PHAreaDay *day in area.days) {
                if ([day.points count] > 0) lastDatePoints = day.points;
                if ([day.date isEqualToDate:date]) {
                    return [day.points count] > 0 ? day.points : lastDatePoints;
                }
            }
        }
    }
    return nil;
}

- (CGRect)frameForAreaId:(NSString *)areaId {
    for (PHArea *area in self.areas) {
        if ([area.id isEqualToString:areaId]) {
            CGFloat minX = CGFLOAT_MAX;
            CGFloat minY = CGFLOAT_MAX;
            CGFloat maxX = 0;
            CGFloat maxY = 0;

            for (PHAreaDay *day in area.days) {
                if ([day.points count] > 0) {
                    for (PHPoint *point in day.points) {
                        minX = MIN(minX, point.point.x);
                        minY = MIN(minY, point.point.y);
                        maxX = MAX(maxX, point.point.x);
                        maxY = MAX(maxY, point.point.y);
                    }
                }
            }
            return CGRectMake(minX, minY, maxX - minX, maxY - minY);
        }
    }
    return CGRectZero;
}

#pragma mark Events

- (CGPoint)mapPointFromLatitude:(CGFloat)latitude longitude:(CGFloat)longitude {
    CGPoint mapPoint = CGPointMake(latitude * 10, longitude * 10);
    return mapPoint;
}

- (NSArray *)eventsForDate:(NSDate *)date {
    NSMutableArray *events = [[NSMutableArray alloc] init];
    for (PHEvent *event in self.events) {
        if ([self date:event.date isWithinLastWeekOf:date]) {
            [events addObject:event];
        }
    }
    return [events copy];
}

- (BOOL)date:(NSDate *)targetDate isWithinLastWeekOf:(NSDate *)referenceDate {
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    dateComponents.weekOfYear = -1;
    NSDate *weekEarlier = [[NSCalendar currentCalendar] dateByAddingComponents:dateComponents toDate:referenceDate options:kNilOptions];

    NSComparisonResult comparedWithToday = [targetDate compare:referenceDate];
    NSComparisonResult comparedWithWeekEarlier = [targetDate compare:weekEarlier];

    return (comparedWithToday != NSOrderedDescending) && (comparedWithWeekEarlier == NSOrderedDescending);
}

@end
