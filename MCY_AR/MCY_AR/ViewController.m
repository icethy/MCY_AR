//
//  ViewController.m
//  MCY_AR
//
//  Created by machunyan on 2017/7/15.
//  Copyright © 2017年 machunyan. All rights reserved.
//

#import "ViewController.h"
#import "MCYARConfiguration.h"
#import "MCYARAnnotation.h"
#import "MCYARAnnotationView.h"
#import "MCYARViewController.h"
#import "TestAnnotationView.h"

@class Platform;

@interface ViewController ()<MCYARDataSource>

@property (nonatomic, strong) MCYARViewController *arViewController;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib；
    
    UIButton *tempBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [tempBtn addTarget:self action:@selector(buttonClick) forControlEvents:UIControlEventTouchUpInside];
    tempBtn.backgroundColor = [UIColor redColor];
    [tempBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [tempBtn setTitle:@"展示AR视图" forState:UIControlStateNormal];
    tempBtn.frame = CGRectMake((self.view.frame.size.width - 100)/2, (self.view.frame.size.height-50)/2, 100, 50);
    [self.view addSubview:tempBtn];
}

- (void)buttonClick
{
    [self showARViewController];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Test AR

- (void)showARViewController
{
    double lat = 30.540017;
    double lon = 104.063377;
    double deltaLat = 0.04;
    double deltaLon = 0.07;
    double altitudeDelta = 0;
    NSInteger count = 20;
    
    NSArray *dummyAnnotations = [self getDummyAnnotation:lat centerLongitude:lon deltaLat:deltaLat deltaLon:deltaLon altitudeDelta:altitudeDelta count:count];
    
    // Present ARViewController
    self.arViewController = [[MCYARViewController alloc] init];
    self.arViewController.dataSource = self;
    // Vertical offset by distance
    self.arViewController.presenter.distanceOffsetMode = DistanceOffsetModeManual;
    self.arViewController.presenter.distanceOffsetMultiplier = 0.1; // Pixels per meter
    self.arViewController.presenter.distanceOffsetMinThreshold = 500;
    self.arViewController.presenter.maxDistance = 6000;
    self.arViewController.presenter.maxVisibleAnnotations = 100;
    self.arViewController.presenter.verticalStackingEnabled = true;
    self.arViewController.trackingManager.userDistanceFilter = 15;
    self.arViewController.trackingManager.reloadDistanceFilter = 50;
    // 雷达
    self.arViewController.radar.maxDistance = 6000;
    // debug
    self.arViewController.uiOptions.closeButtonEnabled = false;
    self.arViewController.uiOptions.debugLabel = false;
    self.arViewController.uiOptions.closeButtonEnabled = true;
    self.arViewController.uiOptions.debugMap = false;
    self.arViewController.uiOptions.simulatorDebugging = [Platform isSimulator];;
    self.arViewController.uiOptions.setUserLocationToCenterOfAnnotations = [Platform isSimulator];
    // Interface orientation
    self.arViewController.interfaceOrientationMask = UIInterfaceOrientationMaskAll;
    __weak typeof(self) weakSelf;
    self.arViewController.onDidFailToFindLocation = ^(NSTimeInterval timeElapsed, BOOL acquiredLocationBefore) {
        [weakSelf handleLocationFailure:timeElapsed acquiredLocationBefore:acquiredLocationBefore arViewController:weakSelf.arViewController];
    };
    [self.arViewController setAnnotations:dummyAnnotations];
    [self presentViewController:self.arViewController animated:YES completion:nil];
}

- (NSArray*)getDummyAnnotation:(double)centerLatitude centerLongitude:(double)centerLongitude deltaLat:(double)deltaLat deltaLon:(double)deltaLon altitudeDelta:(double)altitudeDelta count:(NSInteger)count
{
    NSMutableArray *annotations = [NSMutableArray array];
    srand48(2);
    
    for (int i = 0; i < count; i++) {
        CLLocation *location = [self getRandomLocation:centerLatitude centerLongitude:centerLongitude deltaLat:deltaLat deltaLon:deltaLon altitudeDelta:altitudeDelta];
        
        MCYARAnnotation *annotation = [[MCYARAnnotation alloc] initWithIdentifier:nil title:[NSString stringWithFormat:@"POI(%d)", i] location:location];
        [annotations addObject:annotation];
    }
    
    return annotations;
}

- (NSArray*)addDummyAnnotationWithLat:(double)lat lon:(double)lon altitude:(double)altitude title:(NSString*)title
{
    NSMutableArray *annotations = [NSMutableArray array];
    CLLocation *location = [[CLLocation alloc] initWithCoordinate:CLLocationCoordinate2DMake(lat, lon) altitude:altitude horizontalAccuracy:0 verticalAccuracy:0 timestamp:[NSDate date]];
    MCYARAnnotation *annotation = [[MCYARAnnotation alloc] initWithIdentifier:nil title:title location:location];
    [annotations addObject:annotation];
    
    return annotations;
}

- (CLLocation*)getRandomLocation:(double)centerLatitude centerLongitude:(double)centerLongitude deltaLat:(double)deltaLat deltaLon:(double)deltaLon altitudeDelta:(double)altitudeDelta
{
    double lat = centerLatitude;
    double lon = centerLongitude;
    
    double latDelta = -(deltaLat / 2) + drand48() * deltaLat;
    double lonDelta = -(deltaLon / 2) + drand48() * deltaLon;
    lat = lat + latDelta;
    lon = lon + lonDelta;
    
    double altitude = drand48() * altitudeDelta;
    
    return [[CLLocation alloc] initWithCoordinate:CLLocationCoordinate2DMake(lat, lon) altitude:altitude horizontalAccuracy:1 verticalAccuracy:1 timestamp:[NSDate date]];
}

- (void)handleLocationFailure:(NSTimeInterval)elapsedSeconds acquiredLocationBefore:(BOOL)acquiredLocationBefore
             arViewController:(MCYARViewController*)arViewController
{
    MCYARViewController *arVC = arViewController;
    if (arVC == nil) return;
    if ([Platform isSimulator]) return;
    
    NSLog(@"Failed to find location after: (%f) seconds, acquiredLocationBefore: (%d)", elapsedSeconds, acquiredLocationBefore);
    
    // Example of handling location failure
    if (elapsedSeconds >= 20 && !acquiredLocationBefore) {
        
        // Stopped bcs we don't want multiple alerts
        [arVC.trackingManager stopTracking];
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Problems" message:@"Cannot find location, use Wi-Fi if possible!" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Close" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            [self dismissViewControllerAnimated:YES completion:nil];
        }];
        [alert addAction:okAction];
        
        [self presentViewController:alert animated:YES completion:nil];
    }
}

#pragma mark - MCYARDatasource
- (MCYARAnnotationView*)ar:(MCYARViewController*)arViewController viewForAnnotation:(MCYARAnnotation*)annotation
{
    TestAnnotationView *annotationView = [[TestAnnotationView alloc] init];
    annotationView.frame = CGRectMake(0, 0, 150, 50);
    
    return annotationView;
}

@end
