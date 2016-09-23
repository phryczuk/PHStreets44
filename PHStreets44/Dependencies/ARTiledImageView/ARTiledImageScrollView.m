//
//  ARTiledImageViewScrollView.m
//  ARTiledImageView
//
//  Created by Daniel Doubrovkine on 3/10/14.
//  Copyright (c) 2014 Artsy. All rights reserved.
//
//  Updated by Pawel Hryczuk on 16.05.2015
//

#import "ARTiledImageScrollView.h"
#import "ARTiledImageView.h"

const CGFloat ARTiledImageScrollViewDefaultZoomStep = 1.5f;
const CGFloat ARMaxZoomScaleFactor = 3.0f;

@interface ARTiledImageScrollView ()
@property (nonatomic, strong) ARTiledImageView *tiledImageView;
@property (nonatomic, readonly) UIView *contentView;
@property (nonatomic, readonly) UIImageView *backgroundImageView;
@end

@implementation ARTiledImageScrollView


- (void)setupWithDataSource:(NSObject <ARTiledImageViewDataSource> *)dataSource
{
    self.dataSource = dataSource;
    [self.tiledImageView setupWithDataSource:dataSource];

    self.delegate = self;

    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
    [doubleTap setNumberOfTapsRequired:2];
    [self addGestureRecognizer:doubleTap];

    UITapGestureRecognizer *twoFingerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTwoFingerTap:)];
    [twoFingerTap setNumberOfTouchesRequired:2];
    [self addGestureRecognizer:twoFingerTap];

    [self.panGestureRecognizer addTarget:self action:@selector(mapPanGestureHandler:)];
}


- (void)setDisplayTileBorders:(BOOL)displayTileBorders
{
    self.tiledImageView.displayTileBorders = displayTileBorders;
    _displayTileBorders = displayTileBorders;
}


- (void)setMaxMinZoomScalesForCurrentBounds
{
    CGSize boundsSize = self.bounds.size;
    CGSize imageSize = [self.dataSource imageSizeForImageView:nil];

    // Calculate min/max zoomscale.
    CGFloat xScale = boundsSize.width / imageSize.width; // the scale needed to perfectly fit the image width-wise
    CGFloat yScale = boundsSize.height / imageSize.height; // the scale needed to perfectly fit the image height-wise
    CGFloat minScale = MAX(xScale, yScale); // use minimum of these to allow the image to become fully visible

    CGFloat maxScale = 1.0;

    // Don't let minScale exceed maxScale.
    // If the image is smaller than the screen, we don't want to force it to be zoomed.
    if (minScale > maxScale) {
        minScale = maxScale;
    }

    self.maximumZoomScale = (CGFloat) (maxScale * ARMaxZoomScaleFactor);
    self.minimumZoomScale = minScale;
}


- (void)zoomToFit:(BOOL)animate
{
    [self setZoomScale:self.minimumZoomScale animated:animate];
}


- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    self.backgroundImageView.frame = self.tiledImageView.frame;
    if (self.tileZoomLevel != self.tiledImageView.currentZoomLevel) {
        _tileZoomLevel = self.tiledImageView.currentZoomLevel;
        [self tileZoomLevelDidChange];
    }
}


- (void)tileZoomLevelDidChange
{

}


- (void)setBackgroundImage:(UIImage *)backgroundImage
{
    UIImageView *backgroundImageView = [[UIImageView alloc] initWithFrame:self.tiledImageView.frame];
    [self insertSubview:backgroundImageView belowSubview:self.tiledImageView];
    [backgroundImageView setImage:backgroundImage];
    _backgroundImageView = backgroundImageView;
}


- (void)mapPanGestureHandler:(UIPanGestureRecognizer *)panGesture
{
    if (panGesture.state == UIGestureRecognizerStateBegan) {
        _centerPoint = CGPointZero;
    }
}


- (void)centerOnPoint:(CGPoint)point animated:(BOOL)animate
{
    CGFloat x = (point.x * self.zoomScale) - (self.frame.size.width / 2.0f);
    CGFloat y = (point.y * self.zoomScale) - (self.frame.size.height / 2.0f);
    [self setContentOffset:CGPointMake(round(x), round(y)) animated:animate];
    _centerPoint = point;
}


- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    BOOL zoomedOut = self.zoomScale == self.minimumZoomScale;
    if (!CGPointEqualToPoint(self.centerPoint, CGPointZero) && !zoomedOut) {
        [self centerOnPoint:self.centerPoint animated:NO];
    }
}

#pragma mark - UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.contentView;
}

- (CGFloat)zoomLevel
{
    return self.zoomScale / self.maximumZoomScale;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {

}


#pragma mark - Tap to Zoom

- (void)handleDoubleTap:(UIGestureRecognizer *)gestureRecognizer
{
    // Double tap zooms in, but returns to normal zoom level if it reaches max zoom.
    if (self.zoomScale >= self.maximumZoomScale) {
        [self setZoomScale:self.minimumZoomScale animated:YES];
    } else {
        // The location tapped becomes the new center
        CGPoint tapCenter = [gestureRecognizer locationInView:self.tiledImageView];
        CGFloat newScale = MIN(self.zoomScale * (self.zoomStep ? : ARTiledImageScrollViewDefaultZoomStep), self.maximumZoomScale);
        CGRect maxZoomRect = [self rectAroundPoint:tapCenter atZoomScale:newScale];
        [self zoomToRect:maxZoomRect animated:YES];
    }
}


- (CGRect)rectAroundPoint:(CGPoint)point atZoomScale:(CGFloat)zoomScale
{
    // Define the shape of the zoom rect.
    CGSize boundsSize = self.bounds.size;

    // Modify the size according to the requested zoom level.
    // For example, if we're zooming in to 0.5 zoom, then this will increase the bounds size by a factor of two.
    CGSize scaledBoundsSize = CGSizeMake(boundsSize.width / zoomScale, boundsSize.height / zoomScale);

    return CGRectMake(point.x - scaledBoundsSize.width / 2,
            point.y - scaledBoundsSize.height / 2,
            scaledBoundsSize.width,
            scaledBoundsSize.height);
}


- (void)handleTwoFingerTap:(UIGestureRecognizer *)gestureRecognizer
{
    // Two-finger tap zooms out, but returns to normal zoom level if it reaches min zoom.
    CGFloat newScale = self.zoomScale <= self.minimumZoomScale ? self.maximumZoomScale : self.zoomScale / (self.zoomStep ? : ARTiledImageScrollViewDefaultZoomStep);
    [self setZoomScale:newScale animated:YES];
}


- (UIView *)contentView {
    return self.subviews[0];
}

- (ARTiledImageView *)tiledImageView {
    if (!_tiledImageView) {
        _tiledImageView = [self findTiledImageView:self];
    }
    return _tiledImageView;
}

- (ARTiledImageView *)findTiledImageView:(UIView *)view {
    for (UIView *subview in view.subviews) {
        if ([subview isKindOfClass:[ARTiledImageView class]]) {
            return (ARTiledImageView *) subview;
        }
        ARTiledImageView *v = [self findTiledImageView:subview];
        if (v) {
            return v;
        }
    }
    return nil;
}


@end
