//
//  PHEventOverviewBackgroundView.m
//  PHStreets44 project - Streets '44 iOS app
//
//  Created by Pawel Hryczuk on 30.05.2015.
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

#import "PHEventOverviewBackgroundView.h"

UIEdgeInsets const kPHContentViewInsets = {10, 10, 0, 10};

@interface PHEventOverviewBackgroundView ()

@property (nonatomic, strong) UIImageView *backgroundImageView;

@end

@implementation PHEventOverviewBackgroundView {
    CGFloat _arrowOffset;
    UIPopoverArrowDirection _arrowDirection;
}

#pragma mark - Initialization

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _backgroundImageView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"eventOverviewBackground"] resizableImageWithCapInsets:UIEdgeInsetsZero]];
        [self addSubview:_backgroundImageView];
    }
    return self;
}

-  (void)layoutSubviews {
    _backgroundImageView.frame = self.bounds;
}

#pragma mark - Overridden methods

- (CGFloat)arrowOffset {
    return _arrowOffset;
}

- (UIPopoverArrowDirection)arrowDirection {
    return _arrowDirection;
}

- (void)setArrowOffset:(CGFloat)offset {
    _arrowOffset = offset;
    [self setNeedsLayout];
}

- (void)setArrowDirection:(UIPopoverArrowDirection)direction {
    _arrowDirection = direction;
    [self setNeedsLayout];
}

+ (UIEdgeInsets)contentViewInsets {
    return kPHContentViewInsets;
}

+ (CGFloat)arrowBase {
    return 0;
}

+ (CGFloat)arrowHeight {
    return 0;
}

@end