//
//  MCYARConfiguration.h
//  MCY_AR
//
//  Created by machunyan on 2017/7/15.
//  Copyright © 2017年 machunyan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MCYARViewController.h"
#import "MCYARAnnotation.h"
#import "MCYARAnnotationView.h"
#import <CoreLocation/CoreLocation.h>

@class MCYARViewController;
@class Platform;
@class MCYARRadar;

#define LAT_LON_FACTOR 1.33975031663  // Used in azimuzh calculation, don't change
#define MAX_VISIBLE_ANNOTATIONS 500   // Do not change, can affect performance

#define max(x,y) (x > y ? x : y)
#define min(x,y) (x < y ? x : y)

#define HORIZ_SENS   14 // Counterpart of the VERTICAL_SENS --> How fast they move left & right with the accelerometer data

@interface MCYARConfiguration : NSObject

double radiansToDegrees(double radians);

double degreesToRadians(double degrees);

double normalizeDegree(double degree);

double deltaAngle(double angle1, double angle2);

@end

@protocol MCYARDataSource <NSObject>

- (MCYARAnnotationView*)ar:(MCYARViewController*)arViewController viewForAnnotation:(MCYARAnnotation*)annotation;

@optional
- (NSArray<MCYARAnnotation*>*)ar:(MCYARViewController*)arViewController shouldReloadWithLocation:(CLLocation*)location;
- (MCYARRadar*)ar:(MCYARRadar*)arRadar viewForRadar:(MCYARRadar*)radar;

@end

@interface MCYARStatus : NSObject

/// Horizontal field of view od device. Changes when device rotates(hFov becomes vFov).
@property (nonatomic, assign) double hFov;
/// Vertical field of view od device. Changes when device rotates(vFov becomes hFov).
@property (nonatomic, assign) double vFov;
/// How much pixels(logical) on screen is 1 degree, horizontally.
@property (nonatomic, assign) double hPixelsPerDegree;
/// How much pixels(logical) on screen is 1 degree, vertically.
@property (nonatomic, assign) double vPixelsPerDegree;
/// Heading of the device, 0-360.
@property (nonatomic, assign) double heading;
/// Pitch of the device, device pointing straight = 0, up(upper edge tilted toward user) = 90, down = -90.
@property (nonatomic, assign) double pitch;
/// Last known location of the user.
@property (nonatomic, assign) CLLocation *userLocation;

/// True if all properties have been set.
@property (nonatomic, assign) BOOL ready;

@end

@interface Platform : NSObject

+ (BOOL)isSimulator;

@end
