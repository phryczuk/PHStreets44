//
//  PHPhotoViewController.m
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

#import "PHPhotoViewController.h"
#import "PHEventDataSourceAndDelegate.h"
#import "UIViewController+PHGoogleAnalytics.h"

CGFloat const kPHPhotoMaximumZoomScale = 5.0;

@interface PHPhotoViewController ()

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIImageView *photoView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *photoViewWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *photoViewHeightConstraint;

@end

@implementation PHPhotoViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setupPhotoView];
    [self setupScrollView];
}

- (void)setupPhotoView {
    self.photoView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@.jpg", self.delegate.eventPhotoName]];
    [self.photoView sizeToFit];

    self.photoViewWidthConstraint.constant = CGRectGetWidth(self.photoView.bounds);
    self.photoViewHeightConstraint.constant = CGRectGetHeight(self.photoView.bounds);
}

- (void)setupScrollView {
    NSDictionary *views = @{@"contentView": self.photoView};
    NSDictionary *metrics = @{@"width": @(CGRectGetWidth(self.photoView.bounds)), @"height": @(CGRectGetHeight(self.photoView.bounds))};
    [self.scrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[contentView(width)]|" options:kNilOptions metrics:metrics views:views]];
    [self.scrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[contentView(height)]|" options:kNilOptions metrics:metrics views:views]];

    self.scrollView.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self analyticsView];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];

    CGFloat zoomScaleX = CGRectGetWidth(self.view.bounds) / CGRectGetWidth(self.photoView.bounds);
    CGFloat zoomScaleY = CGRectGetHeight(self.view.bounds) / CGRectGetHeight(self.photoView.bounds);
    CGFloat zoomScale = MIN(zoomScaleX, zoomScaleY);

    self.scrollView.minimumZoomScale = zoomScale;
    self.scrollView.zoomScale = zoomScale;
    self.scrollView.maximumZoomScale = kPHPhotoMaximumZoomScale;
}

#pragma mark - UIScrollViewDelegate methods

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.photoView;
}

#pragma mark - Actions

- (IBAction)viewTapped:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
