//
//  MCYCameraView.h
//  MCY_AR
//
//  Created by machunyan on 2017/7/19.
//  Copyright © 2017年 machunyan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@class CaptureSessionResult;

typedef void(^sessionBlock)(AVCaptureSession *session, NSError *error);

/**
 * UIView with video preview layer. Call startRunning/stopRunning to start/stop capture session.
 * Use createCaptureSession to check if cameraView can be initialized correctly.
 */
@interface MCYCameraView : UIView

/**
 * Media type, set it before adding to superview.
 */
@property (nonatomic, strong) NSString *mediaType;

/**
 * Capture device position, set it before adding to superview.
 */
@property (nonatomic) AVCaptureDevicePosition devicePosition;

/**
 * Video gravitry for videoPreviewLayer, set it before adding to superview.
 */
@property (nonatomic, strong) NSString *videoGravity;

- (void)startRunning;
- (void)stopRunning;

- (void)setVideoOrientation:(UIInterfaceOrientation)orientation;

- (AVCaptureDevice*)inputDevice;

- (void)createCaptureSessionWithMediaType:(NSString*)mediaType position:(AVCaptureDevicePosition)position sessionBlock:(sessionBlock)block;

+ (CaptureSessionResult*)createCaptureSessionWithMediaType:(NSString*)mediaType position:(AVCaptureDevicePosition)position;

@end

@interface CaptureSessionResult : NSObject

@property (nonatomic, strong) AVCaptureSession *session;
@property (nonatomic, strong) NSError *error;

@end
