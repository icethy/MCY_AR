//
//  MCYARTrackingManager.h
//  MCY_AR
//
//  Created by machunyan on 2017/7/15.
//  Copyright © 2017年 machunyan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <CoreMotion/CoreMotion.h>
#import <CoreLocation/CoreLocation.h>

@protocol MCYARTrackingManagerDelegate;

@interface MCYARTrackingManager : NSObject

/**
 * 指定新注释和注释视图重新创建的频率。 reloadDistanceFilter一定有数据
 * 默认值为50m。
 */
@property (nonatomic, assign) CLLocationDistance reloadDistanceFilter; // Will be set in init

/**
 * 指定为可见注释重新计算距离和方位角的频率。 堆叠也是在这个操作上进行的。userDistanceFilter一定有数据
 * 默认值为15m。
 */
@property (nonatomic, assign) CLLocationDistance userDistanceFilter; // Will be set in init self.locationManager.distanceFilter = self.userDistanceFilter

/**
 * Filter(Smoothing) factor for heading in range 0-1. It affects horizontal movement of annotaion views. The lower the value the bigger the smoothing.
 * Value of 1 means no smoothing, should be greater than 0. Default value is 0.05
 */
@property (nonatomic, assign) double headingFilterFactor;

/**
 *  Filter(Smoothing) factor for pitch in range 0-1. It affects vertical movement of annotaion views. The lower the value the bigger the smoothing.
 *  Value of 1 means no smoothing, should be greater than 0. Default value is 0.05
 */
@property (nonatomic, assign) double pitchFilterFactor;

@property (nonatomic, weak) id<MCYARTrackingManagerDelegate> delegate;

/**
 * Set automatically when heading changes. Also see filteredHeading.
 */
@property (nonatomic, assign) double heading;

/**
 * If set, userLocation will return this value
 */
@property (nonatomic, strong) CLLocation *debugLocation;

/**
 * If set, filteredHeading will return this value
 */
@property (nonatomic, assign) double debugHeading;

/**
 * If set, filteredPitch will return this value
 */
@property (nonatomic, assign) double debugPitch;

/**
 * Set in filterHeading. filterHeading must be called manually and often(display timer) bcs of filtering function.
 */
@property (nonatomic, assign) double filteredHeading;

/**
 * Set in filterPitch. filterPitch must be called manually and often(display timer) bcs of filtering function.
 */
@property (nonatomic, assign) double filteredPitch;

/**
 * Headings with greater headingAccuracy than this will be disregarded. In Degrees.
 */
@property (nonatomic, assign) double minimumHeadingAccuracy;

/**
 * Return value for locationManagerShouldDisplayHeadingCalibration.
 */
@property (nonatomic, assign) BOOL allowCompassCalibration;

/**
 * Locations with greater horizontalAccuracy than this will be disregarded. In meters.
 */
@property (nonatomic, assign) double minimumLocationHorizontalAccuracy;

/**
 * Locations older than this will be disregarded. In seconds.
 */
@property (nonatomic, assign) double minimumLocationAge;

/**
 * Starts location and motion manager
 * @param notifyLocationFailure If true, will call arTrackingManager:didFailToFindLocationAfter: if location is not found.
 */
- (void)startTracking:(BOOL)notifyLocationFailure;

/**
 * Stops location and motion manager
 */
- (void)stopTracking;

/**
 * stops all timers and resets all data.
 */
- (void)resetAllTrackingData;

/**
 * Returns filtered(low-pass) pitch in degrees. -90(looking down), 0(looking straight), 90(looking up)
 */
- (void)filterPitch;

- (void)filterHeading;

/**
 * location/heading/pitch 都是可选值
 */
- (void)startDebugMode:(CLLocation*)location heading:(double)heading pitch:(double)pitch;
- (void)stopDebugMode;

/**
 * rename to heading
 * bool 默认值为false
 */
- (double)azimuthFromUserToLocation:(CLLocation*)userLocation location:(CLLocation*)location approximate:(BOOL)approximate;

@end

@protocol MCYARTrackingManagerDelegate <NSObject>

- (void)arTrackingManager:(MCYARTrackingManager*)trackingManager didUpdateUserLocation:(CLLocation*)location;
- (void)arTrackingManager:(MCYARTrackingManager*)trackingManager didUpdateReloadLocation:(CLLocation*)location;
- (void)arTrackingManager:(MCYARTrackingManager*)trackingManager didFailToFindLocationAfter:(NSTimeInterval)elapsedSeconds;

- (void)logText:(NSString*)text;

@end
