//
//  MCYARRadar.h
//  MCY_AR
//
//  Created by machunyan on 2017/7/22.
//  Copyright © 2017年 machunyan. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 * 雷达
 */
@interface MCYARRadar : UIView

//加载的数据最大半径 单位 m
@property (nonatomic,assign) double maxDistance;

- (instancetype)initWithFrame:(CGRect)frame;

- (void)setupAnnotations:(NSArray*)annotations;

- (void)clearDots;

- (void)moveDots:(int)angle;

@end
