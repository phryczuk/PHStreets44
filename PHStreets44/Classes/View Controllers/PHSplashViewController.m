//
//  PHSplashViewController.m
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

#import "PHSplashViewController.h"
#import "PHConstants.h"
#import "PHUtils.h"
#import "UIViewController+PHGoogleAnalytics.h"

NSTimeInterval const kPHAnimateSplashDuration = 1.5;
NSTimeInterval const kPHShowSplashDuration = 0.5;

@interface PHSplashViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (weak, nonatomic) IBOutlet UIImageView *foregroundImageView;

@end

@implementation PHSplashViewController

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [self loadSplashImage];
}

- (void)loadSplashImage {
    NSString *backgroundImageName = [NSString stringWithFormat:@"LaunchImage-%.0fx%.0f", CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds)];
    NSString *foregroundImageName = [NSString stringWithFormat:@"%@_%@", backgroundImageName, [PHUtils languageCode]];

    UIImage *backgroundUIImage = [UIImage imageNamed:backgroundImageName];
    UIImage *foregroundUIImage = [UIImage imageNamed:foregroundImageName];

    self.backgroundImageView.image = backgroundUIImage;
    self.foregroundImageView.image = foregroundUIImage;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self analyticsView];
    [self analyticsEvent:@"language" label:[PHUtils languageCode] value:[[PHUtils languageCode] isEqualToString:@"pl"] ? 1.0 : 2.0];

    self.foregroundImageView.alpha = 0;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    [UIView animateWithDuration:kPHAnimateSplashDuration animations:^{
        self.foregroundImageView.alpha = 1.0;
    } completion:^(BOOL finished) {
        [self performSelector:@selector(showMapViewController) withObject:nil afterDelay:kPHShowSplashDuration];
    }];
}

- (void)showMapViewController {
    [self performSegueWithIdentifier:kPHMapSegue sender:self];
}

@end
