//
//  MCYARPresenter+Stacking.m
//  MCY_AR
//
//  Created by machunyan on 2017/7/21.
//  Copyright © 2017年 machunyan. All rights reserved.
//

#import "MCYARPresenter+Stacking.h"

@implementation MCYARPresenter (Stacking)

- (void)stackAnnotationViews
{
    if (self.annotationViews.count == 0) return;
    
    if (self.arViewController && self.arViewController.arStatus) {
        
        MCYARStatus *arStatus = self.arViewController.arStatus;
        
        
        // Sorting makes stacking faster 降序排列
        NSArray *tempArry = self.annotationViews;
        NSArray *sortedAnnotationViews = [tempArry sortedArrayUsingComparator:^(id obj1, id obj2){
            
            MCYARAnnotationView *anno1 = obj1;
            MCYARAnnotationView *anno2 = obj2;
            
            if (anno1.frame.origin.y > anno2.frame.origin.y) {
                return (NSComparisonResult)NSOrderedAscending;
            }
            
            if (anno1.frame.origin.y < anno2.frame.origin.y) {
                return (NSComparisonResult)NSOrderedDescending;
            }
            
            return (NSComparisonResult)NSOrderedSame;
        }];
        self.annotationViews = sortedAnnotationViews;
        
        CGFloat centerX = self.bounds.size.width * 0.5;
        CGFloat totalWidth = (CGFloat)arStatus.hPixelsPerDegree * 360;
        CGFloat rightBorder = centerX + totalWidth / 2;
        CGFloat leftBorder = centerX - totalWidth / 2;
        
        // This is simple brute-force comparing of frames, compares annotationView1 to all annotationsViews beneath(before) it, if overlap is found,
        // annotationView1 is moved above it. This is done until annotationView1 is not overlapped by any other annotationView beneath it. Then it moves to
        // the next annotationView.
        for (MCYARAnnotationView *annotationView1 in sortedAnnotationViews) {
            //===== Alternate frame
            // Annotation views are positioned left(0° - -180°) and right(0° - 180°) from the center of the screen. So if annotationView1
            // is on -180°, its x position is ~ -6000px, and if annoationView2 is on 180°, its x position is ~ 6000px. These two annotationViews
            // are basically on the same position (180° = -180°) but simply by comparing frames -6000px != 6000px we cannot know that.
            // So we are construcing alternate frame so that these near-border annotations can "see" each other.
            BOOL hasAlternateFrame = false;
            CGFloat left = annotationView1.frame.origin.x;
            CGFloat right = left + annotationView1.frame.size.width;
            // Assuming that annotationViews have same width
            if (right > (rightBorder - annotationView1.frame.size.width)) {
               
                CGFloat originX = annotationView1.frame.origin.x - totalWidth;
                CGRect tempFrame = CGRectMake(originX, annotationView1.frame.origin.y, annotationView1.frame.size.width, annotationView1.frame.size.height);
                annotationView1.arStackAlternateFrame = tempFrame;
                hasAlternateFrame = true;
            } else if (left < (leftBorder + annotationView1.frame.size.width)) {
                
                CGFloat originX = annotationView1.frame.origin.x + totalWidth;
                CGRect tempFrame = CGRectMake(originX, annotationView1.frame.origin.y, annotationView1.frame.size.width, annotationView1.frame.size.height);
                annotationView1.arStackAlternateFrame = tempFrame;
                hasAlternateFrame = true;
            }
            
            //====== Detecting collision
            BOOL hasCollision = false;
            CGFloat y = annotationView1.frame.origin.y;
            NSInteger i = 0;
            while (i < sortedAnnotationViews.count) {
                MCYARAnnotationView *annotationView2 = sortedAnnotationViews[i];
                if (annotationView1 == annotationView2) {
                    
                    // If collision, start over because movement could cause additional collisions
                    if (hasCollision) {
                        hasCollision = false;
                        i = 0;
                        continue;
                    }
                    break;
                }
                
                BOOL collision = CGRectIntersectsRect(annotationView1.frame, annotationView2.frame);
                if (collision) {
                    
                    CGRect annotationView1Frame = CGRectMake(annotationView1.frame.origin.x, annotationView2.frame.origin.y - annotationView1.frame.size.height - 5, annotationView1.frame.size.width, annotationView1.frame.size.height);
                    annotationView1.frame = annotationView1Frame;
                    
                    CGRect arStackAlternateFrame = CGRectMake(annotationView1.arStackAlternateFrame.origin.x, annotationView1.frame.origin.y, annotationView1.arStackAlternateFrame.size.width, annotationView1.arStackAlternateFrame.size.height);
                    annotationView1.arStackAlternateFrame = arStackAlternateFrame;
                    
                    hasCollision = true;
                    
                } else if (hasAlternateFrame && CGRectIntersectsRect(annotationView1.arStackAlternateFrame, annotationView2.frame)) {
                   
                    CGRect annotationView1Frame = CGRectMake(annotationView1.frame.origin.x, annotationView2.frame.origin.y - annotationView1.frame.size.height - 5, annotationView1.frame.size.width, annotationView1.frame.size.height);
                    annotationView1.frame = annotationView1Frame;
                    
                    CGRect arStackAlternateFrame = CGRectMake(annotationView1.arStackAlternateFrame.origin.x, annotationView1.frame.origin.y, annotationView1.arStackAlternateFrame.size.width, annotationView1.arStackAlternateFrame.size.height);
                    annotationView1.arStackAlternateFrame = arStackAlternateFrame;
                    
                    hasCollision = true;
                }
                
                i = i + 1;
            }
            
            CGPoint tempPoint = CGPointMake(annotationView1.arStackOffset.x, annotationView1.frame.origin.y - y);
            annotationView1.arStackOffset = tempPoint;
        }
    }
}

- (void)sortArray{}

- (void)resetStackParameters
{
    for (MCYARAnnotationView *annotationView in self.annotationViews) {
        annotationView.arStackOffset = CGPointZero;
        annotationView.arStackAlternateFrame = CGRectZero;
    }
}

@end
