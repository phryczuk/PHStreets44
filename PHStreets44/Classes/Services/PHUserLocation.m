//
//  PHUserLocation.m
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

#import <CoreLocation/CoreLocation.h>
#import "PHUserLocation.h"
#import "PHConstants.h"

@implementation PHUserLocation {
    CLLocationManager *locationManager;
}

- (id)init {
    self = [super init];
    if (self) {
        [self setupLocationManager];
    }

    return self;
}

- (void)setupLocationManager {
    locationManager = [CLLocationManager new];
    locationManager.delegate = self;
    locationManager.distanceFilter = kCLDistanceFilterNone;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [locationManager startUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    CGPoint mapPoint = [self mapPointForLocation:locations[0]];

    [[NSNotificationCenter defaultCenter] postNotificationName:kPHUserLocationUpdatedNotification object:self userInfo:@{
            kPHUserLocationUpdatedNotificationMapX: @(mapPoint.x),
            kPHUserLocationUpdatedNotificationMapY: @(mapPoint.y)
    }];
}

- (CGPoint)mapPointForLocation:(CLLocation *)location {
    CLLocationDegrees latitude = location.coordinate.latitude;
    CLLocationDegrees longitude = location.coordinate.longitude;
    return CGPointMake(latitude, longitude);
}

@end
