//
//  PHEvent.h
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

#import <Mantle/MTLModel.h>
#import <Mantle/MTLJSONAdapter.h>
#import "PHLocalStaticModel.h"

@interface PHEvent : MTLModel<MTLJSONSerializing, PHLocalStaticModel>

@property (nonatomic, readonly, copy) NSString *id;
@property (nonatomic, readonly, strong) NSDate *date;
@property (nonatomic, readonly, copy) NSString *photoName;
@property (nonatomic, readonly, copy) NSString *lead_en;
@property (nonatomic, readonly, copy) NSString *lead_pl;
@property (nonatomic, readonly, copy) NSString *storyTitle;
@property (nonatomic, readonly, copy) NSString *storyBody_en;
@property (nonatomic, readonly, copy) NSString *storyBody_pl;
@property (nonatomic, readonly, copy) NSString *district;
@property (nonatomic, readonly, copy) NSString *photoCreditText_en;
@property (nonatomic, readonly, copy) NSString *photoCreditText_pl;
@property (nonatomic, readonly, copy) NSString *photoCreditUrl;
@property (nonatomic, readonly) CGPoint gps;
@property (nonatomic, readonly) CGPoint map;

@end
