//
//  MCYARAnnotation.m
//  MCY_AR
//
//  Created by machunyan on 2017/7/15.
//  Copyright © 2017年 machunyan. All rights reserved.
//

#import "MCYARAnnotation.h"

@interface MCYARAnnotation ()
{
    MCYARAnnotationView *_annotationView;
}

@end

@implementation MCYARAnnotation

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        // Init
        _distanceFromUser = 0;
        _azimuth = 0;
        _active = false;
    }
    
    return self;
}

/**
 *  Returns annotation if location(coordinate) is valid.
 */
- (instancetype)initWithIdentifier:(NSString*)identifier title:(NSString*)title location:(CLLocation*)location
{
    if (CLLocationCoordinate2DIsValid(location.coordinate)) {
        self.identifier = identifier;
        self.title = title;
        self.location = location;
    }
    
    return [self init];
}

/**
 *  Validates location.coordinate and sets it.
 */
- (BOOL)validateAndSetLocation:(CLLocation*)location
{
    if (!CLLocationCoordinate2DIsValid(location.coordinate)) return false;
    
    self.location = location;
    return true;
}


#pragma mark - Setter & Getter

/*- (MCYARAnnotationView*)annotationView
{
    if (!_annotationView) {
        _annotationView = [[MCYARAnnotationView alloc] init];
    }
    
    return _annotationView;
}

- (void)setAnnotationView:(MCYARAnnotationView *)annotationView
{
    if (annotationView) {
        _annotationView = annotationView;
    }
}*/

@end
