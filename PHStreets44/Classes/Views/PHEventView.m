//
//  PHEventView.m
//  PHStreets44 project - Streets '44 iOS app
//
//  Created by Pawel Hryczuk on 16.05.2015.
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

#import "PHEventView.h"
#import "PHEvent.h"
#import "PHConstants.h"
#import "PHAppContext.h"
#import "PHEventsViewDelegate.h"
#import "PHAppState.h"

CGSize const kPHPoiImageSize = {128, 128};
CGPoint const kPHPoiImageAnchorPoint = {45, 112};
CGRect const kPHPoiImageCanvas = {38, 22, 52, 78};

CGFloat const kPHEventsPointsScale = 2.0;

CGFloat const kPHHidePastEventsThreshold = 0.12;

@interface PHEventView ()

@property (nonatomic, strong) id<PHEventsViewDelegate> delegate;

@property (nonatomic, readwrite, strong) PHEvent *event;
@property (nonatomic, assign) CGFloat scale;

@end

@implementation PHEventView

#pragma mark - Initialization

- (instancetype)initWithDelegate:(id<PHEventsViewDelegate>)delegate {
    self = [super initWithImage:[UIImage imageNamed:@"poi"]];
    if (self) {
        _delegate = delegate;
        self.userInteractionEnabled = YES;
        UITapGestureRecognizer *eventTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(eventTapped:)];
        eventTap.numberOfTapsRequired = 1;
        [self addGestureRecognizer:eventTap];

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mapDidZoom:) name:kPHMapDidZoomNotification object:nil];
    }
    return self;
}

#pragma mark - Public methods

- (void)setContentScaleFactor:(CGFloat)contentScaleFactor {
    [super setContentScaleFactor:1];
}

- (void)display:(PHEvent *)event {
    self.event = event;
    self.alpha = 1.0f - [self eventDaysAgo] * kPHHidePastEventsThreshold;
    [self updateView];
}

- (void)mapDidZoom:(NSNotification *)notification {
    self.scale = [notification.userInfo[kPHMapDidZoomNotificationScale] floatValue];
    [self updateView];
}

- (void)updateView {
    if (self.event && self.scale) {
        [self updateFrame];
    }
}

- (void)updateFrame {
    self.frame = CGRectMake(
            self.event.map.x / kPHEventsPointsScale - [self map:kPHPoiImageAnchorPoint.x],
            self.event.map.y / kPHEventsPointsScale - [self map:kPHPoiImageAnchorPoint.y],
            [self map:kPHPoiImageSize.width],
            [self map:kPHPoiImageSize.height]
    );
}

- (CGRect)poiCanvasFrame {
    return CGRectMake(
            self.frame.origin.x + [self map:kPHPoiImageCanvas.origin.x],
            self.frame.origin.y + [self map:kPHPoiImageCanvas.origin.y],
            [self map:kPHPoiImageCanvas.size.width],
            [self map:kPHPoiImageCanvas.size.height]
    );
}

#pragma mark - Actions

- (void)eventTapped:(UITapGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateEnded) {
        PHEventView *eventView = (PHEventView *) sender.view;
        [self.delegate eventTapped:eventView];
    }
}

#pragma mark - Helpers

- (CGFloat)map:(CGFloat)coordinate {
    return (coordinate / self.scale) * [self enlargeWithZoom:self.scale];
}

- (CGFloat)enlargeWithZoom:(float)zoom {
    return powf(zoom / 2.0f, 0.45);
}

- (CGFloat)eventDaysAgo {
    NSDateComponents *daysDifference = [[NSCalendar currentCalendar] components:NSCalendarUnitDay fromDate:self.event.date toDate:APP_STATE.currentDate options:kNilOptions];
    return daysDifference.day;
}

@end
