//
//  UIViewController+PHGoogleAnalytics.m
//  PHStreets44 project - Streets '44 iOS app
//
//  Created by Pawel Hryczuk on 18.02.2015.
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

#import <GoogleAnalytics-iOS-SDK/GAITracker.h>
#import <GoogleAnalytics-iOS-SDK/GAI.h>
#import "UIViewController+PHGoogleAnalytics.h"
#import "GAIDictionaryBuilder.h"
#import "GAIFields.h"
#import "PHConstants.h"
#import "PHAppContext.h"
#import "PHAppState.h"

@implementation UIViewController (PHGoogleAnalytics)

- (void)analyticsView {
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:NSStringFromClass([self class])];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
}

- (void)analyticsEvent:(NSString *)action label:(NSString *)label {
    [self analyticsEvent:action label:label value:[APP_STATE.currentDate timeIntervalSince1970]];
}

- (void)analyticsEvent:(NSString *)action label:(NSString *)label value:(double)value {
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:NSStringFromClass([self class]) action:action label:label value:@(value)] build]];
}

@end