//
//  MCYARViewController.m
//  MCY_AR
//
//  Created by machunyan on 2017/7/15.
//  Copyright © 2017年 machunyan. All rights reserved.
//

#import "MCYARViewController.h"
#import "MCYARTrackingManager.h"
#import "MCYARRadar.h"

@interface MCYARViewController ()<MCYARTrackingManagerDelegate>
{
    NSArray<MCYARAnnotation*> *_annotations;
}

@property (nonatomic) BOOL initialized;
@property (nonatomic, strong) CADisplayLink *displayTimer;
@property (nonatomic, strong) UIButton *closeButton;
@property (nonatomic, strong) CLLocation *lastLocation;
@property (nonatomic) BOOL didLayoutSubviews;
@property (nonatomic, assign) ReloadType pendingHighestRankingReload;

@property (nonatomic, strong) UILabel *debugLabel;
@property (nonatomic, strong) UIButton *debugMapButton;
@property (nonatomic, strong) UISlider *debugHeadingSlider;
@property (nonatomic, strong) UISlider *debugPitchSlider;

@end

@implementation MCYARViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Init

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self initializeInternal];
    }
    
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initializeInternal];
    }
    
    return self;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self initializeInternal];
    }
    
    return self;
}

- (void)initializeInternal
{
    if (self.initialized) return;
    self.initialized = true;
    
    // Default values
    self.presenter = [[MCYARPresenter alloc] initWithARViewController:self];
    self.trackingManager.delegate = self;
    
    [self addNotification];
    [self initialize];
}

- (void)initialize
{
    // Public Property
    _interfaceOrientationMask = UIInterfaceOrientationMaskAll;
    _showRadar = true;
    
    // Private Property
    _initialized = false;
    _didLayoutSubviews = false;
}

- (void)dealloc
{
    [self deinit];
}

- (void)deinit
{
    [self removeNotification];
    [self stopCameraAndTracking];
}

- (void)addNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(locationNotification:) name:@"kNotificationLocationSet" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
}

- (void)removeNotification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - View's lifecycle

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self onViewWillAppear]; // Doing like this to prevent subclassing problems
    
    [self.view setNeedsLayout]; // making sure viewDidLayoutSubviews is called so we can handle all in there
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self onViewDidAppear]; // Doing like this to prevent subclassing problems
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self onViewDidDisappear]; // Doing like this to prevent subclassing problems
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    [self onViewDidLayoutSubviews];
}

- (void)onViewWillAppear
{
    // Set orientation and start camera
    [self setOrientation:[UIApplication sharedApplication].statusBarOrientation];
    
    // TrackingManager will reset all its values except last reload location so it will
    // call reload if user location changed significantly since disappear.
    [self startCameraAndTracking:true];
}

- (void)onViewDidAppear
{
    [self addNotification];
}

- (void)onViewDidDisappear
{
    [self removeNotification];
    [self stopCameraAndTracking];
}

- (void)onViewDidLayoutSubviews
{
    // Executed only first time when everything is layouted
    if (!self.didLayoutSubviews) {
        self.didLayoutSubviews = true;
        [self loadUi];
    }
    
    // Layout
    [self layoutUi];
}

- (void)appDidEnterBackground:(NSNotification*)notification
{
    if (self.view.window != nil) {
        // Stopping tracking and clearing presenter, it will restart and reload on appWillEnterForeground
        [self stopCameraAndTracking];
        [self.presenter clear];
        [self clearRadar];
    }
}

- (void)appWillEnterForeground:(NSNotification*)notification
{
    if (self.view.window != nil) {
        // This will make presenter reload
        [self startCameraAndTracking:true];
    }
}

#pragma mark - UI

// This is called only once when view is fully layouted.
- (void)loadUi
{
    // Presenter
    if (self.presenter.superview == nil) {
        [self.view insertSubview:self.presenter atIndex:0];
    }
    
    if (self.radar.superview == nil) {
        [self.view insertSubview:self.radar atIndex:0];
    }
    
    // Camera
    if (self.cameraView.superview == nil) {
        [self.view insertSubview:self.cameraView atIndex:0];
    }
    [self.cameraView startRunning];
    
    // Close Button
    if (self.uiOptions.closeButtonEnabled) {
        [self addCloseButton];
    }
    
    // Debug
    [self addDebugUi];
    
    // Must be called bcs of camera view
    [self setOrientation:[UIApplication sharedApplication].statusBarOrientation];
    [self.view layoutIfNeeded];
}

- (void)layoutUi
{
    self.cameraView.frame = self.view.bounds;
    self.presenter.frame = self.view.bounds;
    [self layoutDebugUi];
    [self calculateFOV];
}

#pragma mark - Radar

- (void)clearRadar
{
    if (self.radar != nil) {
        [self.radar clearDots];
    }
}

#pragma mark - Radar 未使用

- (NSArray*)getRadarSpotsWithARStatus:(MCYARStatus*)arStatus
{
    NSMutableArray *spots = [NSMutableArray arrayWithCapacity:self.annotations.count];
    
    for (MCYARAnnotation *annotation in self.annotations) {
        NSNumber *x_pos = [NSNumber numberWithInt:(int)([self getARAnnotationXPosition:annotation withARStatus:arStatus]/HORIZ_SENS)];
        NSNumber *distance = [NSNumber numberWithDouble:annotation.distanceFromUser];
        //NSLog(@"x_pos:%@  distance:%@", x_pos, distance);
        
        NSDictionary *spot = [NSDictionary dictionaryWithObjectsAndKeys:
                              x_pos, @"angle",
                              distance, @"distance", nil];
        [spots addObject:spot];
    }
    
    return [NSArray arrayWithArray:spots];
}

- (int)getARAnnotationXPosition:(MCYARAnnotation*)annotation withARStatus:(MCYARStatus*)arStatus
{
    CLLocationCoordinate2D coordinates = annotation.location.coordinate;
    
    double latitudeDistance     = max(coordinates.latitude, arStatus.userLocation.coordinate.latitude) - min(coordinates.latitude, arStatus.userLocation.coordinate.latitude);
    double longitudeDistance    = max(coordinates.longitude, arStatus.userLocation.coordinate.longitude) - min(coordinates.longitude, arStatus.userLocation.coordinate.longitude);
    
    int x_position = radiansToDegrees(atanf(longitudeDistance/(latitudeDistance*LAT_LON_FACTOR)));
    
    if ((coordinates.latitude < arStatus.userLocation.coordinate.latitude) && (coordinates.longitude > arStatus.userLocation.coordinate.longitude))
        x_position = 180-x_position;
    
    else if ((coordinates.latitude < arStatus.userLocation.coordinate.latitude) && (coordinates.longitude < arStatus.userLocation.coordinate.longitude))
        x_position += 180;
    
    else if ((coordinates.latitude > arStatus.userLocation.coordinate.latitude) && (coordinates.longitude < arStatus.userLocation.coordinate.longitude))
        x_position += 270;
    
    return x_position * HORIZ_SENS - self.radar.frame.size.width;
}

#pragma mark - Annotations , reload

/**
 * Sets annotations and calls reload on presenter
 */
- (void)setAnnotations:(NSArray<MCYARAnnotation *> *)annotations
{
    // If simulatorDebugging is true, getting center location from all annotations and setting it as current user location
    CLLocation *location = [self centerLocationFromAnnotations:annotations];
    if (self.uiOptions.setUserLocationToCenterOfAnnotations && location != nil) {
        self.arStatus.userLocation = location;
        [self.trackingManager startDebugMode:location heading:0 pitch:0];
    }
    
    _annotations = annotations;
    [self reload:ReloadTypeAnnotationsChanged];
}

- (NSArray<MCYARAnnotation*>*)annotations
{
    return _annotations;
}

- (void)reload:(ReloadType)reloadType
{
    // Explanation why pendingHighestRankingReload is used: if this method is called in this order:
    // 1. currentReload = annotationsChanged, arStatus.ready = false
    // 2. currentReload = headingChanged, arStatus.ready = false
    // 3. currentReload = headingChanged, arStatus.ready = true
    // We want to use annotationsChanged because that is most important reload even if currentReload is headingChanged.
    // Also, it is assumed that ARPresenter will on annotationsChanged do everything it does on headingChanged, and more probably.
    if (self.pendingHighestRankingReload == 0
        || reloadType > self.pendingHighestRankingReload) {
        self.pendingHighestRankingReload = reloadType;
    }
    
    if (!self.arStatus.ready) return;
    
    // Relative positions of user and annotations changed so we recalculate azimuths.
    // When azimuths are calculated, presenter should restack annotations to prevent overlapping.
    ReloadType highestRankingReload = self.pendingHighestRankingReload;
    self.pendingHighestRankingReload = 0;
    
    if (highestRankingReload == ReloadTypeAnnotationsChanged
        || highestRankingReload == ReloadTypeReloadLocationChanged
        || highestRankingReload == ReloadTypeUserLocationChanged) {
        [self calculateDistancesForAnnotations];
        [self calculateAzimuthsForAnnotations];
        
        [self.radar setupAnnotations:self.annotations];
    }
    
    NSLog(@"heading:%f  hFov:%f  vFov:%f  pitch:%f  hPixelsPerDegree:%f  vPixelsPerDegree:%f", self.arStatus.heading, self.arStatus.hFov, self.arStatus.vFov, self.arStatus.pitch, self.arStatus.hPixelsPerDegree, self.arStatus.vPixelsPerDegree);
    
    [self.radar moveDots:self.arStatus.heading]; // 雷达移动
    [self.presenter reload:self.annotations reloadType:(PresenterReloadType)highestRankingReload];
}

- (void)calculateDistancesForAnnotations
{
    if (!self.arStatus.userLocation) return;
    
    CLLocation *userLocation = self.arStatus.userLocation;

    for (MCYARAnnotation *annotation in self.annotations) {
        annotation.distanceFromUser = [annotation.location distanceFromLocation:userLocation];
    }
    
    // 升序排列
    NSArray *tempArry = self.annotations;
    NSArray *sortArry = [tempArry sortedArrayUsingComparator:^(id obj1, id obj2){
        
        MCYARAnnotation *anno1 = obj1;
        MCYARAnnotation *anno2 = obj2;
    
        if (anno1.distanceFromUser > anno2.distanceFromUser) {
            return (NSComparisonResult)NSOrderedDescending;
        }
        
        if (anno1.distanceFromUser < anno2.distanceFromUser) {
            return (NSComparisonResult)NSOrderedAscending;
        }
        
        return (NSComparisonResult)NSOrderedSame;
    }];
    
    _annotations = sortArry;
}

- (void)calculateAzimuthsForAnnotations
{
    if (!self.arStatus.userLocation) return;
    
    CLLocation *userLocation = self.arStatus.userLocation;
    for (MCYARAnnotation *annotation in self.annotations) {
        double azimuth = [self.trackingManager azimuthFromUserToLocation:userLocation location:annotation.location approximate:false];
        annotation.azimuth = azimuth;
    }
}

#pragma mark - Events: MCYARTrackingManagerDelegate/Display timer

- (void)displayTimerTick
{
    if (self.uiOptions.simulatorDebugging) {
        
        // Getting heading and pitch from sliders
        double debugHeadingValue = 0;
        double debugPitchValue = 0;
        if (self.debugHeadingSlider) {
            debugHeadingValue = self.debugHeadingSlider.value;
        }
        if (self.debugPitchSlider) {
            debugPitchValue = self.debugPitchSlider.value;
        }
        
        double heading = debugHeadingValue;
        heading = normalizeDegree(heading);
        [self.trackingManager startDebugMode:nil heading:heading pitch:debugPitchValue];
    }
    
    [self.trackingManager filterPitch];
    [self.trackingManager filterHeading];
    self.arStatus.pitch = self.trackingManager.filteredPitch;
    self.arStatus.heading = self.trackingManager.filteredHeading;
    [self reload:ReloadTypeHeadingChanged];
    
    if (self.uiOptions.debugLabel) {
        double heading = (self.trackingManager.debugHeading ? self.trackingManager.debugHeading : self.trackingManager.heading);
        NSString *headingStr = [NSString stringWithFormat:@"%.0f(%.0f)", heading, self.trackingManager.filteredHeading];
        NSString *pitchStr = [NSString stringWithFormat:@"%.3f", self.trackingManager.filteredPitch];
        [self logText:[NSString stringWithFormat:@"Heading:%@  -- Pitch:%@", headingStr, pitchStr]];
    }
}

- (void)arTrackingManager:(MCYARTrackingManager *)trackingManager didUpdateUserLocation:(CLLocation *)location
{
    self.arStatus.userLocation = location;
    self.lastLocation = location;
    [self reload:ReloadTypeUserLocationChanged];
    
    // Debug view, indicating that update was done
    if (self.uiOptions.debugLabel) {
        [self showDebugViewWithColor:[UIColor redColor]];
    }
}

- (void)arTrackingManager:(MCYARTrackingManager *)trackingManager didUpdateReloadLocation:(CLLocation *)location
{
    self.arStatus.userLocation = location;
    self.lastLocation = location;
    
    // Manual reload?
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(ar:shouldReloadWithLocation:)]) {
        NSArray *annotations = [self.dataSource ar:self shouldReloadWithLocation:location];
        if (annotations && annotations.count != 0) {
            [self setAnnotations:annotations];
        }
    }
    // If no manual reload, calling reload with .reloadLocationChanged, this will give the opportunity to the presenter
    // to filter existing annotations with distance, max count etc.
    else {
        [self reload:ReloadTypeReloadLocationChanged];
    }
    
    // Debug view, indicating that update was done
    if (self.uiOptions.debugLabel) {
        [self showDebugViewWithColor:[UIColor blueColor]];
    }
}

- (void)arTrackingManager:(MCYARTrackingManager *)trackingManager didFailToFindLocationAfter:(NSTimeInterval)elapsedSeconds
{
    if (self.onDidFailToFindLocation) {
        self.onDidFailToFindLocation(elapsedSeconds, self.lastLocation != nil);
    }
}


#pragma mark - Camera

- (void)startCameraAndTracking:(BOOL)notifyLocationFailure
{
    [self.cameraView startRunning];
    [self.trackingManager startTracking:notifyLocationFailure];
    self.displayTimer = [CADisplayLink displayLinkWithTarget:self selector:@selector(displayTimerTick)];
    [self.displayTimer addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
}

- (void)stopCameraAndTracking
{
    [self.cameraView stopRunning];
    [self.trackingManager stopTracking];
    if (self.displayTimer) {
        [self.displayTimer invalidate];
        self.displayTimer = nil;
    }
}

#pragma mark - Rotation/Orientation

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    
    __weak typeof(self) weakSelf;
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        [weakSelf setOrientation:[UIApplication sharedApplication].statusBarOrientation];
    } completion:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        [weakSelf layoutAndReloadOnOrientationChange];
    }];
}

#warning 此处需要重新实现
- (void)layoutAndReloadOnOrientationChange
{
    [UIView animateWithDuration:1.0 animations:^{
        [self layoutUi];
        [self reload:ReloadTypeAnnotationsChanged];
    }];
    
    /*
     CATransaction.begin()
     CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)
     self.layoutUi()
     self.reload(reloadType: .annotationsChanged)
     CATransaction.commit()
     */
}

- (void)setOrientation:(UIInterfaceOrientation)orientation
{
    [self.cameraView setVideoOrientation:orientation];
}

- (void)calculateFOV
{
    double hFov = 0;
    double vFov = 0;
    
    CGRect frame = (CGRectIsNull(self.cameraView.frame) ? self.view.frame : self.cameraView.frame);
    AVCaptureDevice *retrieviedDevice = [self.cameraView inputDevice];
    if (retrieviedDevice) {
        
        // Formula: hFOV = 2 * atan[ tan(vFOV/2) * (width/height) ]
        // width, height are camera width/height
        if (UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)) {
            
            hFov = (double)retrieviedDevice.activeFormat.videoFieldOfView; // This is horizontal FOV - FOV of the wider side of the screen;
            vFov = radiansToDegrees(2 * atan( tan(degreesToRadians(hFov / 2)) * (double)(frame.size.height / frame.size.width)));
        } else {
            
            vFov = (double)retrieviedDevice.activeFormat.videoFieldOfView; // This is horizontal FOV - FOV of the wider side of the screen
            hFov = radiansToDegrees(2 * atan( tan(degreesToRadians(vFov / 2)) * (double)(frame.size.width / frame.size.height)));
        }
    }
    // Used in simulator
    else {
        
        if (UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)) {
            hFov = 58.0; // This is horizontal FOV - FOV of the wider side of the screen
            vFov = radiansToDegrees(2 * atan( tan(degreesToRadians(hFov / 2)) * (double)(self.view.bounds.size.height / self.view.bounds.size.width)));
        } else {
            vFov = 58.0; // This is horizontal FOV - FOV of the wider side of the screen
            hFov = radiansToDegrees(2 * atan( tan(degreesToRadians(vFov / 2)) * (double)(self.view.bounds.size.width / self.view.bounds.size.height)));
        }
    }
    
    self.arStatus.hFov = hFov;
    self.arStatus.vFov = vFov;
    self.arStatus.hPixelsPerDegree = hFov > 0 ? (double)(frame.size.width / (float)hFov) : 0;
    self.arStatus.vPixelsPerDegree = vFov > 0 ? (double)(frame.size.height / (float)vFov) : 0;
}

#pragma mark - UI

#warning 测试 添加close按钮 图片地址为nil
- (void)addCloseButton
{
    if (self.closeButton) {
        [self.closeButton removeFromSuperview];
    }
    
    // close button - make it customizable
    UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [closeButton setImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
    closeButton.frame = CGRectMake(self.view.bounds.size.width - 45, 23, 40, 40);
    [closeButton addTarget:self action:@selector(closeButtonTap) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:closeButton];
    self.closeButton = closeButton;
}

- (void)closeButtonTap
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

+ (NSError*)isAllHardwareAvailable
{
    CaptureSessionResult *reslut = [MCYCameraView  createCaptureSessionWithMediaType:AVMediaTypeVideo position:AVCaptureDevicePositionBack];
    
    return reslut.error;
}

#pragma mark - Debug

// Called from DebugMapViewController when user fakes location.
- (void)locationNotification:(NSNotification*)sender
{
    if (sender.userInfo[@"location"] && [sender.userInfo[@"location"] isKindOfClass:[CLLocation class]]) {
        CLLocation *location = sender.userInfo[@"location"];
        [self.trackingManager startDebugMode:location heading:0 pitch:0];
        [self reload:ReloadTypeReloadLocationChanged];
    }
}

#warning 此处未实现
// Opening DebugMapViewController
- (void)debugButtonTap
{
    
}

- (void)addDebugUi
{
    float width = self.view.bounds.size.width;
    float height = self.view.bounds.size.height;
    
    if (self.uiOptions.debugMap) {
        if (self.debugMapButton) {
            [self.debugMapButton removeFromSuperview];
        }
        
        UIButton *debugMapButton = [UIButton buttonWithType:UIButtonTypeCustom];
        debugMapButton.frame = CGRectMake(5, 5, 40, 40);
        [debugMapButton addTarget:self action:@selector(debugMapButtonTap) forControlEvents:UIControlEventTouchUpInside];
        [debugMapButton setTitle:@"map" forState:UIControlStateNormal];
        debugMapButton.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.5];
        [debugMapButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [self.view addSubview:debugMapButton];
        self.debugMapButton = debugMapButton;
    }
    
    if (self.uiOptions.debugLabel) {
        if (self.debugLabel) {
            [self.debugLabel removeFromSuperview];
        }
        
        UILabel *debugLabel = [[UILabel alloc] init];
        
    }
}

- (void)layoutDebugUi
{

}

- (void)showDebugViewWithColor:(UIColor*)color
{

}

- (void)logText:(NSString *)text
{
    if (self.debugLabel) {
        self.debugLabel.text = text;
    }
}

- (CLLocation*)centerLocationFromAnnotations:(NSArray<MCYARAnnotation*>*)annotations
{
    if (annotations.count <= 0) return nil;
    
    CLLocation *location = nil;
    double minLat = 1000;
    double maxLat = -1000;
    double minLon = 1000;
    double maxLon = -1000;
    
    for (MCYARAnnotation *annotation in annotations) {
        CLLocationDegrees latitude = annotation.location.coordinate.latitude;
        CLLocationDegrees longitude = annotation.location.coordinate.longitude;
        
        if (latitude < minLat){minLat = latitude;}
        if (latitude > maxLat){maxLat = latitude;}
        if (longitude < minLon){minLon = longitude;}
        if (longitude > maxLon){maxLon = longitude;}
    }
    
    NSLog(@"minLat:%f maxLat:%f minLon:%f maxLon:%f", minLat, maxLat, minLon, maxLon);
    
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake((minLat + maxLat) * 0.5, (minLon + maxLon) * 0.5);
    if (CLLocationCoordinate2DIsValid(coordinate)) {
        location = [[CLLocation alloc] initWithLatitude:coordinate.latitude longitude:coordinate.longitude];
    }
    
    return location;
}

#pragma mark - Setter & Getter

- (MCYARTrackingManager*)trackingManager
{
    if (!_trackingManager) {
        _trackingManager = [[MCYARTrackingManager alloc] init];
    }
    
    return _trackingManager;
}

- (void)setCloseButtonImage:(UIImage *)closeButtonImage
{
    if (!closeButtonImage) {
        _closeButtonImage = closeButtonImage;
        [self.closeButton setImage:closeButtonImage forState:UIControlStateNormal];
    }
}

- (UiOptions*)uiOptions
{
    if (!_uiOptions) {
        _uiOptions = [[UiOptions alloc] init];
    }
    
    return _uiOptions;
}

#warning 此处可能需要修改
- (void)setPresenter:(MCYARPresenter *)presenter
{
    if (presenter) {
        _presenter = presenter;
        [self.presenter removeFromSuperview];
        if (self.didLayoutSubviews) {
            [self.view insertSubview:self.presenter aboveSubview:self.cameraView];
        }
    }
}

// Private

- (MCYCameraView*)cameraView
{
    if (!_cameraView) {
        _cameraView = [[MCYCameraView alloc] init];
    }
    
    return _cameraView;
}

- (MCYARRadar*)radar
{
    if (!_radar) {
        _radar = [[MCYARRadar alloc] initWithFrame:CGRectMake(20, self.view.frame.size.height-120, 80, 80)];
    }
    
    return _radar;
}

- (MCYARStatus*)arStatus
{
    if (!_arStatus) {
        _arStatus = [[MCYARStatus alloc] init];
    }
    
    return _arStatus;
}

@end

@implementation UiOptions

- (instancetype)init
{
    self = [super init];
    if (self) {
        _debugMap = false;
        _simulatorDebugging = false;
        _debugLabel = false;
        _setUserLocationToCenterOfAnnotations = false;
        _closeButtonEnabled = true;
    }
    
    return self;
}

@end
