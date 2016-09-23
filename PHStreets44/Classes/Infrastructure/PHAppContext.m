//
//  PHAppContext.m
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

#import "PHAppContext.h"
#import "PHUserLocation.h"
#import "PHAppState.h"
#import "PHDataManager.h"

@interface PHAppContext ()

@property (nonatomic, strong) PHAppState *appState;
@property (nonatomic, strong) PHDataManager *dataManager;

@property (nonatomic, strong) PHUserLocation *userLocation;

@end

@implementation PHAppContext

+ (PHAppContext *)sharedContext
{
    static dispatch_once_t token = 0;
    __strong static PHAppContext *sharedContext = nil;
    dispatch_once(&token, ^{
        sharedContext = [[self alloc] init];
    });

    return sharedContext;
}

- (id)init {
    self = [super init];
    if (self) {
        self.appState = [[PHAppState alloc] init];
        self.userLocation = [[PHUserLocation alloc] init];
        self.dataManager = [[PHDataManager alloc] init];
    }
    return self;
}

@end
