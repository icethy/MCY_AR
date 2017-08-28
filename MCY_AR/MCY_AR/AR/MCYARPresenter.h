//
//  MCYARPresenter.h
//  MCY_AR
//
//  Created by machunyan on 2017/7/15.
//  Copyright © 2017年 machunyan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "MCYARViewController.h"
#import "MCYARAnnotation.h"
#import "MCYARAnnotationView.h"
#import "MCYARConfiguration.h"

@class MCYARStatus;
@class MCYARViewController;

/**
 * Distance offset mode, it affects vertical offset of annotations by distance.
 */
typedef enum : NSUInteger {
    // Annotations are not offset vertically with distance.
    DistanceOffsetModeNone,
    // Use distanceOffsetMultiplier and distanceOffsetMinThreshold to control offset.
    DistanceOffsetModeManual,
    // distanceOffsetMinThreshold is set to closest annotation, distanceOffsetMultiplier must be set by user.
    DistanceOffsetModeAutomaticOffsetMinDistance,
    // distanceOffsetMinThreshold is set to closest annotation and distanceOffsetMultiplier is set to fit all annotations on screen vertically(before stacking)
    DistanceOffsetModeAutomatic,
} DistanceOffsetMode;

typedef enum : NSUInteger {
    PresenterReloadTypeeHeadingChanged = 0,
    PresenterReloadTypeUserLocationChanged = 1,
    PresenterReloadTypeReloadLocationChanged = 2,
    PresenterReloadTypeAnnotationsChanged = 3,
} PresenterReloadType;

typedef double(^distanceOffsetFunction)(double distance);

/**
 * Adds ARAnnotationViews on the screen and calculates its screen positions. Before anything
 * is done, it first filters annotations by distance and count for improved performance. This
 * class is also responsible for vertical stacking of the annotation views.
 
 * It can be subclassed if custom positioning is needed, e.g. if you wan't to position
 * annotations relative to its altitudes you would subclass ARPresenter and override
 * xPositionForAnnotationView and yPositionForAnnotationView.
 */
@interface MCYARPresenter : UIView

/**
 * Stacks overlapping annotations vertically.
 */
@property (nonatomic, assign) BOOL verticalStackingEnabled;

/**
 * How much to vertically offset annotations by distance, in pixels per meter. Use it if distanceOffsetMode is manual or automaticOffsetMinDistance.
 
 * Also look at distanceOffsetMinThreshold and distanceOffsetMode.
 */
@property (nonatomic, assign) double distanceOffsetMultiplier;

/**
 * All annotations farther(from user) than this value will be offset using distanceOffsetMultiplier. Use it if distanceOffsetMode is manual.
 
 * Also look at distanceOffsetMultiplier and distanceOffsetMode.
 */
@property (nonatomic, assign) double distanceOffsetMinThreshold;

/**
 * Distance offset mode, it affects vertical offset of annotations by distance.
 */
@property (nonatomic, assign) DistanceOffsetMode distanceOffsetMode;

/**
 * If set, it will be used instead of distanceOffsetMultiplier and distanceOffsetMinThreshold if distanceOffsetMode != none
 * Use it to calculate vartical offset by given distance.
 */
@property (nonatomic, copy) distanceOffsetFunction distanceOffsetFunction;

/**
 * How low on the screen is nearest annotation. 0 = top, 1  = bottom.
 */
@property (nonatomic, assign) double bottomBorder;

@property (nonatomic, weak) MCYARViewController *arViewController;
/**
 * All annotations
 */
@property (nonatomic, copy) NSArray<MCYARAnnotation*> *annotations;
/**
 * Annotations filtered by distance/maxVisibleAnnotations. Look at activeAnnotationsFromAnnotations.
 */
@property (nonatomic, copy) NSArray<MCYARAnnotation*> *activeAnnotations;
/**
 * AnnotionViews for all active annotations, this is set in createAnnotationViews.
 */
@property (nonatomic, copy) NSArray<MCYARAnnotationView*> *annotationViews;
/**
 * AnnotationViews that are on visible part of the screen or near its border.
 */
@property (nonatomic, copy) NSArray<MCYARAnnotationView*> *visibleAnnotationViews;

/**
 * Total maximum number of visible annotation views. Default value is 100. Max value is 500.
 * This will affect performance, especially if verticalStackingEnabled.
 */
@property (nonatomic, assign) NSInteger maxVisibleAnnotations;

/**
 * Maximum distance(in meters) for annotation to be shown.
 * Default value is 0 meters, which means that distances of annotations don't affect their visiblity.
 
 * This can be used to increase performance.
 */
@property (nonatomic, assign) double maxDistance;

- (instancetype)initWithARViewController:(MCYARViewController*)arViewController;

/**
 * This is called from ARViewController, it handles main logic, what is called and when.
 */
- (void)reload:(NSArray<MCYARAnnotation*>*)annotations reloadType:(PresenterReloadType)reloadType;

/**
 * Gives opportunity to the presenter to filter annotations and reduce number of items it is working with.
 
 * Default implementation filters by maxVisibleAnnotations and maxDistance.
 */
- (NSArray<MCYARAnnotation*>*)activeAnnotationsFromAnnotations:(NSArray<MCYARAnnotation*>*)annotations;

/**
 * Creates views for active annotations and removes views from inactive annotations.
 * @IMPROVEMENT: Add reuse logic
 */
- (void)createAnnotationViews;

/**
 * Removes all annotation views from screen and resets annotations
 */
- (void)clear;

/**
 * Adds/removes annotation views to/from superview depending if view is on visible part of the screen.
 * Also, if annotation view is on visible part, it is added to visibleAnnotationViews.
 */
- (void)addRemoveAnnotationViews:(MCYARStatus*)arStatus;

/**
 * Layouts annotation views.
 * - Parameter relayoutAll: If true it will call xPositionForAnnotationView/yPositionForAnnotationView for each annotation view, else
 * it will only take previously calculated x/y positions and add heading/pitch offsets to visible annotation views.
 */
- (void)layoutAnnotationViews:(MCYARStatus*)arStatus relayoutAll:(BOOL)relayoutAll;

/**
 * x position without the heading, heading offset is added in layoutAnnotationViews due to performance.
 */
- (CGFloat)xPositionForAnnotationView:(MCYARAnnotationView*)annotationView arStatus:(MCYARStatus*)arStatus;

/**
 * y position without the pitch, pitch offset is added in layoutAnnotationViews due to performance.
 */
- (CGFloat)yPositionForAnnotationView:(MCYARAnnotationView*)annotationView arStatus:(MCYARStatus*)arStatus;

- (void)adjustDistanceOffsetParameters;

@end
