//
//  MCYARPresenter+Stacking.h
//  MCY_AR
//
//  Created by machunyan on 2017/7/21.
//  Copyright © 2017年 machunyan. All rights reserved.
//

#import "MCYARPresenter.h"

@interface MCYARPresenter (Stacking)

/**
 Stacks annotationViews vertically if they are overlapping. This works by comparing frames of annotationViews.
 
 This must be called if parameters that affect relative x,y of annotations changed.
 - if azimuths on annotations are calculated(This can change relative horizontal positions of annotations)
 - when adjustVerticalOffsetParameters is called because that can affect relative vertical positions of annotations
 
 Pitch/heading of the device doesn't affect relative positions of annotationViews.
 */
- (void)resetStackParameters;

/**
 * Resets temporary stacking fields. This must be called before stacking and before layout.
 */
- (void)stackAnnotationViews;

@end
