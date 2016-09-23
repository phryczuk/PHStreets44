//
//  PHMapViewController.m
//  PHStreets44 project - Streets '44 iOS app
//
//  Created by Pawel Hryczuk on 1.05.2015.
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

#import <Mantle/MTLJSONAdapter.h>
#import "PHMapViewController.h"
#import "PHConstants.h"
#import "PHAppState.h"
#import "PHAppContext.h"
#import "PHDataManager.h"
#import "PHAreaView.h"
#import "PHArea.h"
#import "PHUtils.h"
#import "ARLocalTiledImageDataSource.h"
#import "ARTiledImageScrollView.h"
#import "PHEventsView.h"
#import "PHEventOverviewViewController.h"
#import "PHStoryViewController.h"
#import "UIViewController+PHGoogleAnalytics.h"
#import "PHEventOverviewBackgroundView.h"

NSTimeInterval const kPHMapViewAppearsAnimationDuration = 2.0;

CGSize const kPHMapSize = {7506, 6230};

NSInteger const kPHMapTileSize = 512;
NSInteger const kPHMapMinTileLevel = 11;
NSInteger const kPHMapMaxTileLevel = 13;
NSString *const kPHMapTilesPath = @"Map/tiles";
NSString *const kPHMapTileFormat = @"jpg";

@interface PHMapViewController ()

@property (weak, nonatomic) IBOutlet ARTiledImageScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet PHAreaView *areasView;
@property (weak, nonatomic) IBOutlet PHEventsView *eventsView;

@property (weak, nonatomic) IBOutlet UILabel *todayLabel;

@property (weak, nonatomic) IBOutlet UIButton *previousWeekButton;
@property (weak, nonatomic) IBOutlet UIButton *previousDayButton;
@property (weak, nonatomic) IBOutlet UIButton *nextDayButton;
@property (weak, nonatomic) IBOutlet UIButton *nextWeekButton;

@property (nonatomic, strong) ARLocalTiledImageDataSource *mapDataSource;

@property (nonatomic, strong) PHEvent *selectedEvent;
@property (nonatomic, assign) BOOL startup;

@end

@implementation PHMapViewController

#pragma mark - Initialization and data loading

- (void)viewDidLoad {
    [super viewDidLoad];
    self.startup = YES;

    [self setupScrollView];
    [self updateTodayLabel];
    [self setupAreas];
    [self setupEvents];
    [self setupTiledMap];
}

- (void)setupScrollView {
    NSDictionary *views = @{@"contentView": self.contentView};
    NSDictionary *metrics = @{@"width": @(kPHMapSize.width), @"height": @(kPHMapSize.height)};
    [self.scrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[contentView(width)]|" options:kNilOptions metrics:metrics views:views]];
    [self.scrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[contentView(height)]|" options:kNilOptions metrics:metrics views:views]];

    self.scrollView.alpha = 0;
    self.scrollView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"mapBackground.jpg"]];
}

- (void)setupAreas {
    [DATA_MANAGER.areas enumerateObjectsUsingBlock:^(PHArea *area, NSUInteger idx, BOOL *stop) {
        PHAreaView *areaView = [[PHAreaView alloc] initWithFrame:[DATA_MANAGER frameForAreaId:area.id] id:area.id];
        [self.areasView addSubview:areaView];
    }];
}

- (void)setupEvents {
    [self.eventsView setup:self];
}

- (void)setupTiledMap {
    self.mapDataSource = [[ARLocalTiledImageDataSource alloc] init];
    self.mapDataSource.tileBasePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:kPHMapTilesPath];
    self.mapDataSource.maxTiledWidth = (NSInteger)kPHMapSize.width;
    self.mapDataSource.maxTiledHeight = (NSInteger)kPHMapSize.height;
    self.mapDataSource.minTileLevel = kPHMapMinTileLevel;
    self.mapDataSource.maxTileLevel = kPHMapMaxTileLevel;
    self.mapDataSource.tileSize = kPHMapTileSize;
    self.mapDataSource.tileFormat = kPHMapTileFormat;
    [self.scrollView setupWithDataSource:self.mapDataSource]; // ARTiledImageScrollView stores dataSource with a weak pointer
}

-(void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
}

- (void)viewDidLayoutSubviews {
    if (!self.startup) return;
    [super viewDidLayoutSubviews];

    // Scroll view has now correct bounds set by Autolayout
    [self.scrollView setMaxMinZoomScalesForCurrentBounds];
}

#pragma mark - View will appear and disappear

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self analyticsView];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userLocationUpdated:) name:kPHUserLocationUpdatedNotification object:nil];
    [self updateView];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    if (self.startup) {
        // Initial zoom setup needs to be called here
        [self initialContentZoomAndScroll];

        [UIView animateWithDuration:kPHMapViewAppearsAnimationDuration animations:^{
            self.scrollView.alpha = 1.0;
        }];

        self.startup = NO;
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)userLocationUpdated:(NSNotification *)notification {
//    CGFloat x = [notification.userInfo[kPHUserLocationUpdatedNotificationMapX] floatValue];
//    CGFloat y = [notification.userInfo[kPHUserLocationUpdatedNotificationMapY] floatValue];
//    DDLogDebug(@"Map received user location update to point %f %f", x, y);
}

#pragma mark - Actions

- (IBAction)previousWeekTapped:(id)sender {
    [self analyticsEvent:@"previous week" label:@"tap"];
    [APP_STATE addDays:0 weeks:-1];
    [self updateView];
}

- (IBAction)previousDayTapped:(id)sender {
    [self analyticsEvent:@"previous day" label:@"tap"];
    [APP_STATE addDays:-1 weeks:0];
    [self updateView];
}

- (IBAction)nextDayTapped:(id)sender {
    [self analyticsEvent:@"next day" label:@"tap"];
    [APP_STATE addDays:1 weeks:0];
    [self updateView];
}

- (IBAction)nextWeekTapped:(id)sender {
    [self analyticsEvent:@"next week" label:@"tap"];
    [APP_STATE addDays:0 weeks:1];
    [self updateView];
}

- (void)updateTodayLabel {
    self.todayLabel.text = [[PHUtils longDateFormatter] stringFromDate:APP_STATE.currentDate];
}

- (void)updateView {
    [self updateTodayLabel];
    [self updateTimelineButtons];
    [self updateAreaViews];
    [self updateEventsViews];
}

- (void)updateAreaViews {
    [self.areasView.subviews enumerateObjectsUsingBlock:^(PHAreaView *areaView, NSUInteger idx, BOOL *stop) {
        NSArray *points = [DATA_MANAGER pointsForAreaId:areaView.id andDate:APP_STATE.currentDate];
        [areaView display:points];
    }];
}

- (void)updateEventsViews {
    [self.eventsView display:[DATA_MANAGER eventsForDate:APP_STATE.currentDate]];
}

- (void)updateTimelineButtons {
    self.previousDayButton.enabled = ![APP_STATE.currentDate isEqualToDate:APP_STATE.earliestDate];
    self.nextDayButton.enabled = ![APP_STATE.currentDate isEqualToDate:APP_STATE.latestDate];

    self.previousWeekButton.enabled = self.previousDayButton.enabled;
    self.nextWeekButton.enabled = self.nextDayButton.enabled;
}

#pragma mark - Events

- (void)eventTapped:(PHEventView *)eventView {
    self.selectedEvent = eventView.event;
    [self analyticsEvent:@"event overview" label:@"tap" value:[self.selectedEvent.id doubleValue]];

    PHEventOverviewViewController *contentViewController = [[PHEventOverviewViewController alloc] initWithDelegate:self];
    contentViewController.modalPresentationStyle = UIModalPresentationPopover;
    contentViewController.preferredContentSize = kPHEventOverviewViewSize;

    UIPopoverPresentationController *eventOverviewPopover = contentViewController.popoverPresentationController;
    CGRect eventViewFrame = [eventView poiCanvasFrame];
    eventOverviewPopover.sourceRect = [self.view convertRect:eventViewFrame fromView:self.eventsView];
    eventOverviewPopover.sourceView = self.view;
    eventOverviewPopover.popoverBackgroundViewClass = [PHEventOverviewBackgroundView class];
    eventOverviewPopover.permittedArrowDirections = UIPopoverArrowDirectionAny;
    eventOverviewPopover.delegate = self;

    [self presentViewController:contentViewController animated:YES completion:nil];
}

#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:kPHStorySegue]) {
        [self prepareStorySegue:segue.destinationViewController];
    } else {
        [super prepareForSegue:segue sender:sender];
    }
}

- (void)prepareStorySegue:(PHStoryViewController *)storyViewController {
    storyViewController.delegate = self;
}

#pragma mark - PHEventDataSourceAndDelegate methods

- (void)overviewTapped {
    [self analyticsEvent:@"story" label:@"tap" value:[self.selectedEvent.id doubleValue]];
    [self performSegueWithIdentifier:kPHStorySegue sender:self];
}

#pragma mark - UIPopoverPresentationControllerDelegate methods

- (UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller {
    return UIModalPresentationNone;
}

- (BOOL)popoverPresentationControllerShouldDismissPopover:(UIPopoverPresentationController *)popoverPresentationController {
    return YES;
}

#pragma mark - PHEventDataSourceAndDelegate methods

- (NSString *)eventId {
    return self.selectedEvent.id;
}

- (NSString *)eventLead_en {
    return self.selectedEvent.lead_en;
}

- (NSString *)eventLead_pl {
    return self.selectedEvent.lead_pl;
}

- (NSString *)eventDistrictAndDate {
    NSString *date = [[PHUtils longDateFormatter] stringFromDate:self.selectedEvent.date];
    return [NSString stringWithFormat:@"%@, %@", self.selectedEvent.district, date];
}

- (NSString *)eventStoryTitle {
    return self.selectedEvent.storyTitle;
}

- (NSString *)eventStoryBody_en {
    return self.selectedEvent.storyBody_en;
}

- (NSString *)eventStoryBody_pl {
    return self.selectedEvent.storyBody_pl;
}

- (NSString *)eventPhotoName {
    return self.selectedEvent.photoName;
}

- (NSString *)eventPhotoCreditText_en {
    return self.selectedEvent.photoCreditText_en;
}

- (NSString *)eventPhotoCreditText_pl {
    return self.selectedEvent.photoCreditText_pl;
}

- (NSString *)eventPhotoCreditUrl {
    return self.selectedEvent.photoCreditUrl;
}

#pragma mark - Helpers

- (void)initialContentZoomAndScroll {
    BOOL isInitialContentOffset = APP_STATE.isMapInitialContentOffset;
    CGPoint initialContentOffset = APP_STATE.mapInitialContentOffset;

    self.scrollView.zoomScale = APP_STATE.mapInitialZoomScale ? APP_STATE.mapInitialZoomScale : self.scrollView.minimumZoomScale;
    self.scrollView.contentOffset = [self mapCenterOffset];
    self.scrollView.contentOffset = isInitialContentOffset ? initialContentOffset : [self mapCenterOffset];
}

- (CGPoint)mapCenterOffset {
    CGSize visibleMapSize = CGSizeMake(kPHMapSize.width * self.scrollView.zoomScale, kPHMapSize.height * self.scrollView.zoomScale);
    return CGPointMake(
            (visibleMapSize.width - CGRectGetWidth(self.scrollView.frame)) / 2.0f,
            (visibleMapSize.height - CGRectGetHeight(self.scrollView.frame)) / 2.0f
    );
}

@end
