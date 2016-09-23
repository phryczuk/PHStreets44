//
//  PHStoryViewController.m
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

#import "PHStoryViewController.h"
#import "PHEventDataSourceAndDelegate.h"
#import "PHConstants.h"
#import "PHPhotoViewController.h"
#import "PHUtils.h"
#import "UIViewController+PHGoogleAnalytics.h"

CGFloat const kPHStoryTopMarginConstraintInitial = 15;
CGFloat const kPHPhotoWidthConstraintLarge = 675;
CGFloat const kPHPhotoConstraintAlignLeftConstant = 10;
CGFloat const kPHPhotoCreditHeightConstant = 15;

CGFloat const kPHMinimumStoryWidth = 250;
CGFloat const kPHPhotoMargin = 20;
CGFloat const kPHPhotoMaxHeightMargin = 30;
CGFloat const kPHPhotoTextMargin = 10;

static int kPHScrollViewHeightObserverContext;

@interface PHStoryViewController ()

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *photoView;
@property (weak, nonatomic) IBOutlet UILabel *photoCreditLabel;
@property (weak, nonatomic) IBOutlet UIView *photoCreditContainer;
@property (weak, nonatomic) IBOutlet UITextView *storyTextView;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundView;

@property (nonatomic, strong) NSArray *scrollViewConstraints;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *backgroundHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *storyTopMargin;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *photoLeadingSpaceConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *photoWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *photoHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *photoCreditWidthConstraint;

@end

@implementation PHStoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.photoCreditLabel.transform = CGAffineTransformMakeRotation(-M_PI_2);
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];

    [self updatePhoto];
    [self updateBackgroundView];
    [self updateScrollView];
}

- (void)updateBackgroundView {
    if (CGRectGetWidth(self.view.bounds) < CGRectGetHeight(self.view.bounds)) {
        self.backgroundView.image = [UIImage imageNamed:@"storyBackgroundPortrait"];
    } else {
        self.backgroundView.image = [UIImage imageNamed:@"storyBackgroundLandscape"];
    }
}

- (void)updateContentView {
    self.dateLabel.text = self.delegate.eventDistrictAndDate;
    self.titleLabel.text = [[PHUtils languageCode] isEqualToString:@"pl"] ? self.delegate.eventStoryTitle : self.delegate.eventLead_en; //TODO Workaround for lack of English translation of event story titles
    self.storyTextView.text = [[PHUtils languageCode] isEqualToString:@"pl"] ? self.delegate.eventStoryBody_pl : self.delegate.eventStoryBody_en;
    NSString *photoCreditText = [[PHUtils languageCode] isEqualToString:@"pl"] ? self.delegate.eventPhotoCreditText_pl : self.delegate.eventPhotoCreditText_en;
    self.photoCreditLabel.text = [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"PHStoryPhotoCreditPrefix", nil), photoCreditText];
}

- (void)updatePhoto {
    UIImage *photo = [UIImage imageNamed:[NSString stringWithFormat:@"%@.jpg", self.delegate.eventPhotoName]];
    assert(photo);

    CGFloat contentWidth = CGRectGetWidth(self.scrollView.bounds);
    CGFloat availableWidth = contentWidth - kPHPhotoMargin - kPHPhotoCreditHeightConstant;
    CGFloat availableHeight = CGRectGetHeight(self.scrollView.bounds) - CGRectGetHeight(self.titleLabel.bounds) - CGRectGetHeight(self.dateLabel.bounds) - kPHPhotoMaxHeightMargin;

    CGFloat photoWidth = contentWidth >= kPHPhotoWidthConstraintLarge ? kPHPhotoWidthConstraintLarge : availableWidth;
    CGFloat photoHeight = photo.size.height * (photoWidth / photo.size.width);
    if (photoHeight > availableHeight) {
        photoHeight = availableHeight;
        photoWidth = photo.size.width * (photoHeight / photo.size.height);
    }

    self.photoWidthConstraint.constant = photoWidth;
    self.photoHeightConstraint.constant = photoHeight;
    self.photoCreditWidthConstraint.constant = photoHeight;
    self.photoView.image = photo;
    CGFloat photoTotalWidth = photoWidth + kPHPhotoCreditHeightConstant;

    CGRect newPhotoFrame = CGRectMake(0, 0, photoTotalWidth + kPHPhotoMargin, photoHeight + kPHPhotoTextMargin); // Note: photoCredit is rotated by 90 degrees

    if (CGRectGetWidth(newPhotoFrame) + kPHMinimumStoryWidth < contentWidth) {
        UIBezierPath *photoPath = [UIBezierPath bezierPathWithRect:newPhotoFrame];
        self.storyTextView.textContainer.exclusionPaths = @[photoPath];
        self.storyTopMargin.constant = kPHStoryTopMarginConstraintInitial;
        self.photoLeadingSpaceConstraint.constant = kPHPhotoConstraintAlignLeftConstant;
    } else {
        self.storyTextView.textContainer.exclusionPaths = @[];
        self.storyTopMargin.constant = kPHStoryTopMarginConstraintInitial + photoHeight;
        self.photoLeadingSpaceConstraint.constant = (contentWidth - photoTotalWidth) / 2.0f;
    }

    [self.contentView setNeedsLayout];
}

- (void)updateScrollView {
    NSDictionary *views = @{@"contentView": self.contentView};
    NSDictionary *metrics = @{@"width": @(CGRectGetWidth(self.scrollView.bounds))};

    if (self.scrollViewConstraints) {
        [self.scrollView removeConstraints:self.scrollViewConstraints];
    }

    self.scrollViewConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[contentView(width)]|" options:kNilOptions metrics:metrics views:views];
    [self.scrollView addConstraints:self.scrollViewConstraints];
}

#pragma mark - Adjust background image size

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self analyticsView];
    [self updateContentView];

    [self.scrollView addObserver:self forKeyPath:@"contentSize" options:kNilOptions context:&kPHScrollViewHeightObserverContext];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.scrollView removeObserver:self forKeyPath:@"contentSize" context:&kPHScrollViewHeightObserverContext];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (context == &kPHScrollViewHeightObserverContext) {
        UIScrollView *scrollView = object;
        self.backgroundHeightConstraint.constant = scrollView.contentSize.height;
        [self updatePhoto];

    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark - Actions

- (IBAction)photoTapped:(id)sender {
    [self analyticsEvent:@"photo" label:@"tap" value:[self.delegate.eventId doubleValue]];
    [self performSegueWithIdentifier:kPHPhotoSegue sender:self];
}

- (IBAction)viewTapped:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)photoCreditTapped:(id)sender {
    NSURL *url = [NSURL URLWithString:self.delegate.eventPhotoCreditUrl];
    [[UIApplication sharedApplication] openURL:url];
}

#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:kPHPhotoSegue]) {
        [self preparePhotoSegue:segue.destinationViewController];
    } else {
        [super prepareForSegue:segue sender:sender];
    }
}

- (void)preparePhotoSegue:(PHPhotoViewController *)photoViewController {
    photoViewController.delegate = self.delegate;
}

@end
