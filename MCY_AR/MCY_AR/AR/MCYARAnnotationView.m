//
//  MCYARAnnotationView.m
//  MCY_AR
//
//  Created by machunyan on 2017/7/15.
//  Copyright © 2017年 machunyan. All rights reserved.
//

#import "MCYARAnnotationView.h"

@implementation MCYARAnnotationView

- (instancetype)init
{
    self = [super initWithFrame:CGRectZero];
    if (self) {
        [self initializeInternal];
    }
    
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initializeInternal];
    }
    
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initializeInternal];
    }
    
    return self;
}

- (void)initializeInternal
{
    if (self.initialized) return;
    
    self.initialized = true;
    [self initialize];
}

// Will always be called once, no need to call super
- (void)initialize
{
    _centerOffset = CGPointMake(0.5, 0.5);
    
    _arStackOffset = CGPointMake(0, 0);
    _arStackAlternateFrame = CGRectZero;
    _arStackAlternateFrameExists = false;
    _arZeroPoint = CGPointMake(0, 0);
    _initialized = false;
    
}

// Called when distance/azimuth changes, intended to be used in subclasses
- (void)bindUi
{

}

/**
 * 加载UI时调用
 */
- (void)drawRect:(CGRect)rect
{
    [self bindUi];
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self bindUi];
}

@end
