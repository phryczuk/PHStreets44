//
//  PHAreaView.m
//  PHStreets44 project - Streets '44 iOS app
//
//  Created by Pawel Hryczuk on 9.05.2015.
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

#import "PHAreaView.h"
#import "PHPoint.h"

CGFloat const kPHAreaColor[] = {1.0, 0, 0, 0.4};

CGFloat const kPHAreasPointsScale = 1.0;

NSString *const kPHAnimateActivationKey = @"kPHAnimateActivation";
NSString *const kPHAnimateUpdateKey = @"kPHAnimateUpdate";
NSString *const kPHAnimateDeactivationKey = @"kPHAnimateDeactivation";

CFTimeInterval const kPHAnimateActivationDuration = 1.0;
CFTimeInterval const kPHAnimateUpdateDuration = 1.0;
CFTimeInterval const kPHAnimateDeactivationDuration = 1.0;

@interface PHAreaView () <CAAnimationDelegate>

@property (nonatomic, strong) NSArray *currentPoints;
@property (nonatomic, strong) NSArray *targetPoints;
@property (nonatomic, assign) BOOL isAnimating;

@end

@implementation PHAreaView

#pragma mark - Initialization

- (id)initWithFrame:(CGRect)frame id:(NSString *)id {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupLayer];
        self.backgroundColor = [UIColor clearColor];
        _id = id;
        _isAnimating = NO;
    }
    return self;
}

#pragma mark - Public methods

- (void)setContentScaleFactor:(CGFloat)contentScaleFactor {
    [super setContentScaleFactor:1];
}

- (void)display:(NSArray *)points {
    self.targetPoints = points;

    if (!self.currentPoints && points) {
        self.currentPoints = points;
        [self animateActivation];

    } else if (self.currentPoints && !points) {
        [self animateDeactivation];

    } else if (self.currentPoints && points) {
        [self animateUpdate];
    }
}

#pragma mark - Drawing

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColor(context, kPHAreaColor);

    if (self.currentPoints && !self.isAnimating) {
        [self drawArea:context];
    }
}

- (void)drawArea:(CGContextRef)context {
    CGMutablePathRef path = CGPathCreateMutable();
    [self buildPath:path fromPoints:self.currentPoints];
    CGContextAddPath(context, path);
    CGContextFillPath(context);
    CGPathRelease(path);
}

#pragma mark - Layer

+ (Class)layerClass {
    return [CAShapeLayer class];
}

- (CAShapeLayer *)shapeLayer {
    return (CAShapeLayer *)self.layer;
}

- (void)setupLayer {
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGColorRef fillColor = CGColorCreate(colorSpace, kPHAreaColor);
    self.shapeLayer.fillColor = fillColor;
    self.layer.speed = 1.0;
    CGColorRelease(fillColor);
    CGColorSpaceRelease(colorSpace);
}

#pragma mark - Animations

- (void)animateActivation {
    CABasicAnimation *animation = [self animationWithKeyPath:@"opacity"
                                                   fromValue:@(0)
                                                     toValue:@(1.0)
                                                    duration:kPHAnimateActivationDuration];
    [self setNeedsDisplay];
    [self.layer addAnimation:animation forKey:kPHAnimateActivationKey];
}

- (void)animateDeactivation {
    CABasicAnimation *animation = [self animationWithKeyPath:@"opacity"
                                                   fromValue:@(1.0)
                                                     toValue:@(0)
                                                    duration:kPHAnimateDeactivationDuration];
    [self setNeedsDisplay];
    [self.layer addAnimation:animation forKey:kPHAnimateDeactivationKey];
}

- (void)animateUpdate {
    CGMutablePathRef currentPath = CGPathCreateMutable();
    [self buildPath:currentPath fromPoints:self.currentPoints];

    CGMutablePathRef targetPath = CGPathCreateMutable();
    [self buildPath:targetPath fromPoints:self.targetPoints];

    CABasicAnimation *animation = [self animationWithKeyPath:@"path"
                                                   fromValue:(__bridge id)currentPath
                                                     toValue:(__bridge id)targetPath
                                                    duration:kPHAnimateUpdateDuration];
    self.isAnimating = YES;
    [self setNeedsDisplay];
    [self.layer addAnimation:animation forKey:kPHAnimateUpdateKey];

    CGPathRelease(currentPath);
    CGPathRelease(targetPath);
}

- (CABasicAnimation *)animationWithKeyPath:(NSString *)keyPath fromValue:(id)fromValue toValue:(id)toValue duration:(NSTimeInterval)duration {
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:keyPath];
    animation.delegate = self;
    animation.fromValue = fromValue;
    animation.toValue = toValue;
    animation.duration = duration;
    animation.removedOnCompletion = NO;
    animation.fillMode = kCAFillModeForwards;
    return animation;
}

- (void)animationDidStart:(CAAnimation *)theAnimation {
    self.isAnimating = YES;
    self.currentPoints = self.targetPoints;
    self.targetPoints = nil;
}

- (void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)flag {
    self.isAnimating = NO;
    [self setNeedsDisplay];
    [self.layer removeAllAnimations];
}

#pragma mark - Helpers

- (void)buildPath:(CGMutablePathRef)path fromPoints:(NSArray *)points {
    PHPoint *startingPoint = points[0];
    CGPathMoveToPoint(path, nil, startingPoint.point.x / kPHAreasPointsScale - self.frame.origin.x, startingPoint.point.y / kPHAreasPointsScale - self.frame.origin.y);
    [points enumerateObjectsUsingBlock:^(PHPoint *point, NSUInteger idx, BOOL *stop) {
        if (idx > 0) {
            CGPathAddLineToPoint(path, nil, point.point.x / kPHAreasPointsScale - self.frame.origin.x, point.point.y / kPHAreasPointsScale - self.frame.origin.y);
        }
    }];
}

@end
