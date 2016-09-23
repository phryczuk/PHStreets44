//
//  PHSettingsViewController.m
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

#import "PHSettingsViewController.h"
#import "UIViewController+PHGoogleAnalytics.h"

static int kPHScrollViewHeightObserverContext;

CGFloat const kPHLogoNACPlaceholderHeight = 0; // NAC logo not needed in an open source version of the app

@interface PHSettingsViewController ()

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundView;
@property (weak, nonatomic) IBOutlet UITextView *aboutTextView;
@property (weak, nonatomic) IBOutlet UIImageView *logoNACView;

@property (nonatomic, strong) NSArray *scrollViewConstraints;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *backgroundHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *logoNACTopSpaceConstraint;

@end

@implementation PHSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupAboutTextView];
}

- (void)setupAboutTextView {
    NSData *data = [NSLocalizedString(@"PHSettingsAbout", nil) dataUsingEncoding:NSUnicodeStringEncoding];
    NSDictionary *options = @{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType, NSCharacterEncodingDocumentAttribute: @(NSUnicodeStringEncoding)};
    NSAttributedString *text = [[NSAttributedString alloc] initWithData:data options:options documentAttributes:nil error:nil];
    self.aboutTextView.attributedText = text;
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];

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

- (void)updateScrollView {
    NSDictionary *views = @{@"contentView": self.contentView};
    NSDictionary *metrics = @{@"width": @(CGRectGetWidth(self.scrollView.bounds))};

    if (self.scrollViewConstraints) {
        [self.scrollView removeConstraints:self.scrollViewConstraints];
    }

    self.scrollViewConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[contentView(width)]|" options:kNilOptions metrics:metrics views:views];
    [self.scrollView addConstraints:self.scrollViewConstraints];
}

#pragma mark - Adjust background image size and NAC logo position

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self analyticsView];
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
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark - Actions

- (IBAction)viewTapped:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Helpers

- (CGRect)aboutSubstringRect:(NSString *)searchTerm {
    NSRange fullRange = NSMakeRange(0, self.aboutTextView.attributedText.length);
    NSRegularExpression *regex = [[NSRegularExpression alloc] initWithPattern:searchTerm options:kNilOptions error:nil];
    NSTextCheckingResult *substringMatch = [regex firstMatchInString:self.aboutTextView.attributedText.string options:kNilOptions range:fullRange];

    UITextPosition *textBeginning = self.aboutTextView.beginningOfDocument;
    UITextPosition *textStart = [self.aboutTextView positionFromPosition:textBeginning offset:substringMatch.range.location];
    UITextPosition *textEnd = [self.aboutTextView positionFromPosition:textStart offset:searchTerm.length];
    UITextRange *textRange = [self.aboutTextView textRangeFromPosition:textStart toPosition:textEnd];
    CGRect foundRect = [self.aboutTextView firstRectForRange:textRange];
    return [self.aboutTextView convertRect:foundRect fromView:self.aboutTextView.textInputView];
}

@end
