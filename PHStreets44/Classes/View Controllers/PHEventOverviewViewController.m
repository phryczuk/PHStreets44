//
//  PHEventOverviewViewController.m
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

#import "PHEventOverviewViewController.h"
#import "PHConstants.h"
#import "PHEventDataSourceAndDelegate.h"
#import "UIViewController+PHGoogleAnalytics.h"
#import "PHUtils.h"

CGSize const kPHTitleMargin = {10, 5};

@interface PHEventOverviewViewController ()

@property (weak, nonatomic) UIImageView *photoView;
@property (weak, nonatomic) UILabel *titleLabel;

@property (nonatomic, weak) id<PHEventDataSourceAndDelegate> delegate;

@end

@implementation PHEventOverviewViewController

- (instancetype)initWithDelegate:(id<PHEventDataSourceAndDelegate>)delegate {
    self = [super init];
    if (self) {
        _delegate = delegate;
    }

    return self;
}

- (void)loadView {
    UIView *view = [[UIView alloc] initWithFrame:CGRectZero];

    UIImageView *photoView = [[UIImageView alloc] initWithFrame:CGRectZero];
    photoView.contentMode = UIViewContentModeScaleAspectFit;
    [view addSubview:photoView];
    self.photoView = photoView;

    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    titleLabel.font = [UIFont fontWithName:@"GNUTypewriter" size:14];
    titleLabel.numberOfLines = 0;
    titleLabel.adjustsFontSizeToFitWidth = YES;
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [view addSubview:titleLabel];
    self.titleLabel = titleLabel;
    
    self.view = view;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    UITapGestureRecognizer *viewTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTapped:)];
    viewTap.numberOfTapsRequired = 1;
    [self.view addGestureRecognizer:viewTap];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];

    self.view.frame = CGRectMake(0, 0, kPHEventOverviewViewSize.width, kPHEventOverviewViewSize.height);
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self analyticsView];
    [self updateView];
}

- (void)updateView {
    UIImage *photo = [self eventOverviewPhoto];
    CGFloat photoHeight = photo.size.height * (kPHEventOverviewViewSize.width / photo.size.width);
    self.photoView.frame = CGRectMake(0, 0, kPHEventOverviewViewSize.width, photoHeight);
    self.photoView.image = photo;

    self.titleLabel.frame = CGRectMake(kPHTitleMargin.width, photoHeight + kPHTitleMargin.height, kPHEventOverviewViewSize.width - (2 * kPHTitleMargin.width), kPHEventOverviewViewSize.height - photoHeight - kPHTitleMargin.height);
    self.titleLabel.text = [[PHUtils languageCode] isEqualToString:@"pl"] ? self.delegate.eventLead_pl : self.delegate.eventLead_en;
}

- (UIImage *)eventOverviewPhoto {
    UIImage *photo = [UIImage imageNamed:[NSString stringWithFormat:@"%@-overview.jpg", self.delegate.eventPhotoName]];
    if (!photo) {
        photo = [UIImage imageNamed:[NSString stringWithFormat:@"%@.jpg", self.delegate.eventPhotoName]];
    }
    assert(photo);
    return photo;
}

- (void)viewTapped:(UITapGestureRecognizer *)sender {
    [self dismissViewControllerAnimated:NO completion:^{
        [self.delegate overviewTapped];
    }];
}

@end
