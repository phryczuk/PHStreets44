//
//  PHEventsView.m
//  PHStreets44 project - Streets '44 iOS app
//
//  Created by Pawel Hryczuk on 23.05.2015.
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

#import "PHEventsView.h"
#import "PHEventView.h"
#import "PHEventsViewDelegate.h"
#import "PHEvent.h"
#import "PHConstants.h"
#import "PHAppContext.h"
#import "PHAppState.h"

NSInteger const kPHMaxSimultaneousEvents = 40;
NSInteger const kPHEventTagsStartFrom = 1000;

@interface PHEventsView ()

@property (nonatomic, weak) id<PHEventsViewDelegate> delegate;

@end

@implementation PHEventsView

- (void)setup:(id<PHEventsViewDelegate>)delegate {
    self.delegate = delegate;
    for(int i = 0; i < kPHMaxSimultaneousEvents; i++) {
        PHEventView *eventView = [[PHEventView alloc] initWithDelegate:delegate];
        eventView.tag = i + kPHEventTagsStartFrom;
        [self addSubview:eventView];
    }
}

- (void)setContentScaleFactor:(CGFloat)contentScaleFactor {
    [super setContentScaleFactor:1];
}

- (void)display:(NSArray *)events {
    int i;
    for(i = 0; i < [events count]; i++) {
        PHEventView *eventView = (PHEventView *)[self viewWithTag:i + kPHEventTagsStartFrom];
        eventView.hidden = NO;
        [eventView display:events[i]];
        [self makeTodayEventOnTop:events[i] subview:eventView];
    }
    for(int j = i; j < kPHMaxSimultaneousEvents; j++) {
        PHEventView *eventView = (PHEventView *)[self viewWithTag:j + kPHEventTagsStartFrom];
        eventView.hidden = YES;
    }
}

- (void)makeTodayEventOnTop:(PHEvent *)event subview:(PHEventView *)subview {
    if ([event.date isEqualToDate:APP_STATE.currentDate]) {
        [self bringSubviewToFront:subview];
    }
}

@end
