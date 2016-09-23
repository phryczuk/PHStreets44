//
//  PHDataManager.h
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

@interface PHDataManager : NSObject

@property (nonatomic, readonly, strong) NSArray *events;
@property (nonatomic, readonly, strong) NSArray *areas;

- (NSArray *)pointsForAreaId:(NSString *)areaId andDate:(NSDate *)date;

- (CGRect)frameForAreaId:(NSString *)areaId;

- (NSArray *)eventsForDate:(NSDate *)date;

@end
