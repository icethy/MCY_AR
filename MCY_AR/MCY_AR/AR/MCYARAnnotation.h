//
//  MCYARAnnotation.h
//  MCY_AR
//
//  Created by machunyan on 2017/7/15.
//  Copyright © 2017年 machunyan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "MCYARAnnotationView.h"

@class MCYARAnnotationView;

/**
 * Serves as the source of information(location, title etc.) about a single annotation. Annotation objects do not provide
 * the visual representation of the annotation. It is analogue to MKAnnotation. It can be subclassed if additional
 * information for some annotation is needed.
 */
@interface MCYARAnnotation : NSObject

/**
 * Identifier of annotation, not used by HDAugmentedReality internally.
 */
@property (nonatomic, strong) NSString *identifier;

/**
 * Title of annotation, can be used in ARAnnotationView
 */
@property (nonatomic, strong) NSString *title;

/**
 * Location of the annotation, it is guaranteed to be valid location(coordinate). It is set in init or by validateAndSetLocation.
 */
@property (nonatomic, strong) CLLocation *location;

/**
 * View for annotation. It is set inside ARPresenter after fetching view from dataSource.
 */
@property (nonatomic, strong) MCYARAnnotationView *annotationView;

/**
 * Internal use only, do not set this properties
 */
@property (nonatomic) double distanceFromUser;
@property (nonatomic) double azimuth;
@property (nonatomic) BOOL active;

/**
 *  Returns annotation if location(coordinate) is valid.
 */
- (instancetype)initWithIdentifier:(NSString*)identifier title:(NSString*)title location:(CLLocation*)location;

/**
 *  Validates location.coordinate and sets it.
 */
- (BOOL)validateAndSetLocation:(CLLocation*)location;

@end
