//
//  MCYARConfiguration.m
//  MCY_AR
//
//  Created by machunyan on 2017/7/15.
//  Copyright © 2017年 machunyan. All rights reserved.
//

#import "MCYARConfiguration.h"

@implementation MCYARConfiguration

double radiansToDegrees(double radians)
{
    return (radians) * (180.0 / M_PI);
}

double degreesToRadians(double degrees)
{
    return (degrees) * (M_PI / 180.0);
}

// Normalizes degree to 0-360
double normalizeDegree(double degree)
{
    double degreeNormalized = fmod(degree, 360);
    if (degreeNormalized < 0) {
        degreeNormalized = 360 + degreeNormalized;
    }
    return degreeNormalized;
}

// Finds shortes angle distance between two angles. Angles must be normalized(0-360).
double deltaAngle(double angle1, double angle2)
{
    double deltaAngle = angle1 - angle2;
    
    if (deltaAngle > 180) {
        deltaAngle -= 360;
    } else if (deltaAngle < -180) {
        deltaAngle += 360;
    }
    
    return deltaAngle;
}

@end

@implementation MCYARStatus

- (BOOL)ready
{
    BOOL hFovOK = (_hFov > 0) ? true : false;
    BOOL vFovOK = (_vFov > 0) ? true : false;
    BOOL hPixelsPerDegreeOK = (_hPixelsPerDegree > 0) ? true : false;
    BOOL vPixelsPerDegreeOK = (_vPixelsPerDegree > 0) ? true : false;
    BOOL headingOK = (_heading != 0) ? true : false;
    BOOL pitchOK = (_pitch != 0) ? true : false;
    BOOL userLocationOK = (self.userLocation != nil && CLLocationCoordinate2DIsValid(self.userLocation.coordinate));
    
    return hFovOK
    && vFovOK
    && hPixelsPerDegreeOK
    && vPixelsPerDegreeOK
    && headingOK
    && pitchOK
    && userLocationOK;
}

@end

@implementation Platform

+ (BOOL)isSimulator
{
    BOOL isSim = false;
#if TARGET_IPHONE_SIMULATOR
    isSim = true;
#elif TARGET_OS_IPHONE//真机
    isSim = false;
#endif
    return isSim;
}

@end
