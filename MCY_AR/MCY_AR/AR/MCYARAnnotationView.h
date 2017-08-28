//
//  MCYARAnnotationView.h
//  MCY_AR
//
//  Created by machunyan on 2017/7/15.
//  Copyright © 2017年 machunyan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MCYARAnnotation.h"

@class MCYARAnnotation;

/**
 * Responsible for presenting annotations visually. Analogue to MKAnnotationView.
 * It is usually subclassed to provide custom look.
 
 * Annotation views should be lightweight, try to avoid xibs and autolayout.
 */
@interface MCYARAnnotationView : UIView

/**
 * Normally, center of annotationView points to real location of POI, but this property can be used to alter that.
 * E.g. if bottom-left edge of annotationView should point to real location, centerOffset should be (0, 1)
 */
@property (nonatomic, assign) CGPoint centerOffset;

@property (nonatomic, strong) MCYARAnnotation *annotaion;

/**
 * Used internally for stacking
 */
@property (nonatomic, assign) CGPoint arStackOffset;
@property (nonatomic, assign) CGRect arStackAlternateFrame;
@property (nonatomic, assign) BOOL arStackAlternateFrameExists;
//Position of annotation view without heading, pitch, stack offsets.
@property (nonatomic, assign) CGPoint arZeroPoint;

@property (nonatomic, assign) BOOL initialized;

- (void)bindUi;
- (void)initialize;

@end
