//
//  MCYARViewController.h
//  MCY_AR
//
//  Created by machunyan on 2017/7/15.
//  Copyright © 2017年 machunyan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MCYARConfiguration.h"
#import "MCYARTrackingManager.h"
#import "MCYARPresenter.h"
#import "MCYCameraView.h"
#import "MCYARRadar.h"

typedef enum : NSUInteger {
    ReloadTypeHeadingChanged = 0,
    ReloadTypeUserLocationChanged = 1,
    ReloadTypeReloadLocationChanged = 2,
    ReloadTypeAnnotationsChanged = 3,
} ReloadType;

typedef void(^onDidFailToFindLocation)(NSTimeInterval timeElapsed, BOOL acquiredLocationBefore);

@class UiOptions;
@class MCYARPresenter;
@class MCYARStatus;
@protocol MCYARDataSource;

@interface MCYARViewController : UIViewController

/**
 * Data source - source of annotation views for ARViewController/ARPresenter, implement it to provide annotation views.
 */
@property (nonatomic, weak) id<MCYARDataSource> dataSource;

/**
 * Orientation mask for view controller. Make sure orientations are enabled in project settings also.
 */
@property (nonatomic, assign) UIInterfaceOrientationMask interfaceOrientationMask;

/**
 * Class for tracking location/heading/pitch. Use it to set properties like reloadDistanceFilter, userDistanceFilter etc.
 */
@property (nonatomic, strong) MCYARTrackingManager *trackingManager;

@property (nonatomic, strong) UIImage *closeButtonImage;

/**
 * Called every 5 seconds after location tracking is started but failed to deliver location. It is also called when tracking has just started with timeElapsed = 0.
 * The timer is restarted when app comes from background or on didAppear.
 */
@property (nonatomic, copy) onDidFailToFindLocation onDidFailToFindLocation;

/**
 * Some ui options. Set it before controller is shown, changes made afterwards are disregarded.
 */
@property (nonatomic, strong) UiOptions *uiOptions;

@property (nonatomic, strong) MCYARPresenter *presenter;

@property (nonatomic, strong) MCYARStatus *arStatus;

@property (nonatomic, copy) NSArray<MCYARAnnotation*> *annotations;
@property (nonatomic, strong) MCYCameraView *cameraView;

@property (nonatomic, strong) MCYARRadar *radar; // 雷达

/**
 * 是否显示雷达， 默认显示
 */
@property (nonatomic) BOOL showRadar;

@end

@interface UiOptions : NSObject

/**
 * Enables/Disables debug map
 */
@property (nonatomic) BOOL debugMap;

/**
 * Enables/Disables debug sliders for heading/pitch and simulates userLocation to center of annotations
 */
@property (nonatomic) BOOL simulatorDebugging;

/**
 * Enables/Disables debug label at bottom and some indicator views when updating/reloading.
 */
@property (nonatomic) BOOL debugLabel;

/**
 * If true, it will set debugLocation to center of all annotations. Usefull for simulator debugging
 */
@property (nonatomic) BOOL setUserLocationToCenterOfAnnotations;

/**
 * Enables/Disables close button.
 */
@property (nonatomic) BOOL closeButtonEnabled;

@end
