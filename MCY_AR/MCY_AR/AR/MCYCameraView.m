//
//  MCYCameraView.m
//  MCY_AR
//
//  Created by machunyan on 2017/7/19.
//  Copyright © 2017年 machunyan. All rights reserved.
//

#import "MCYCameraView.h"

@interface MCYCameraView ()

@property (nonatomic, strong) AVCaptureVideoPreviewLayer *videoPreviewLayer;
@property (nonatomic, strong) AVCaptureSession *captureSession;

@end

@implementation MCYCameraView

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self initialize];
    }
    
    return self;
}

- (void)initialize
{
    _mediaType = AVMediaTypeVideo;
    _videoGravity = AVLayerVideoGravityResizeAspectFill;
}

#pragma mark - UIView overrides

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self layoutUi];
}

- (void)didMoveToSuperview
{
    [super didMoveToSuperview];
    
    if (self.superview != nil) {
        [self createSessionAndVideoPreviewLayer];
        [self setNeedsLayout];
    } else {
        [self destroySessionAndVideoPreviewLayer];
    }
}

- (void)layoutUi
{
    if (self.videoPreviewLayer) {
        self.videoPreviewLayer.frame = self.bounds;
    }
}

#pragma mark - Main logic

// Starts running capture session
- (void)startRunning
{
    if (self.captureSession) {
        [self.captureSession startRunning];
    }
}

// Stops running capture session
- (void)stopRunning
{
    if (self.captureSession) {
        [self.captureSession stopRunning];
    }
}

// Creates capture session and video preview layer, destroySessionAndVideoPreviewLayer is called.
- (void)createSessionAndVideoPreviewLayer
{
    [self destroySessionAndVideoPreviewLayer];
    
    // ======Capture session
    CaptureSessionResult *result = [MCYCameraView createCaptureSessionWithMediaType:self.mediaType position:self.devicePosition];
    if (result.error == nil && result.session != nil) {
        self.captureSession = result.session;
        
        // ===== View preview layer
        AVCaptureVideoPreviewLayer *videoPreviewLayer = [AVCaptureVideoPreviewLayer layerWithSession:self.captureSession];
        if (videoPreviewLayer) {
            videoPreviewLayer.videoGravity = self.videoGravity;
            [self.layer insertSublayer:videoPreviewLayer atIndex:0];
            self.videoPreviewLayer = videoPreviewLayer;
        }
    }
    
}

// Stops running and destroys capture session, removes and destroys video preview layer.
- (void)destroySessionAndVideoPreviewLayer
{
    [self stopRunning];
    
    if (self.videoPreviewLayer) {
        [self.videoPreviewLayer removeFromSuperlayer];
        self.videoPreviewLayer = nil;
        self.captureSession = nil;
    }
}

- (void)setVideoOrientation:(UIInterfaceOrientation)orientation
{
    if (self.videoPreviewLayer
        && self.videoPreviewLayer.connection
        && self.videoPreviewLayer.connection.isVideoOrientationSupported != false) {
        self.videoPreviewLayer.connection.videoOrientation = (AVCaptureVideoOrientation)orientation;
    }
}

#pragma mark - Utilitues

#warning 此处可能有修改
+ (CaptureSessionResult*)createCaptureSessionWithMediaType:(NSString*)mediaType position:(AVCaptureDevicePosition)position
{
    NSError *error = nil;
    AVCaptureSession *captureSession = nil;
    AVCaptureDevice *captureDevice = nil;
    
    // Get all capture devices with given media type(video/photo)
    //NSArray *captureDevices = [AVCaptureDevice devicesWithMediaType:mediaType];
    
    // Get capture device for specified position
    /*if (captureDevices && captureDevices.count != 0) {
        for (AVCaptureDevice *captureDeviceLoop in captureDevices) {
            NSLog(@"positaion:%ld  position2:%ld", (long)captureDeviceLoop.position, (long)position);
            if (captureDeviceLoop.position == position) {
                captureDevice = captureDeviceLoop;
                break;
            }
        }
    }*/
    captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    if (captureDevice) {
        // Get video input device
        AVCaptureDeviceInput *captureDeviceInput = nil;
        
        @try {
            captureDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:captureDevice error:&error];
        } @catch (NSException *exception) {
            NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:exception.reason, @"description", nil];
            error = [NSError errorWithDomain:@"MCYCameraView" code:9999 userInfo:dic];
            captureDeviceInput = nil;
        }
        
        if (captureDeviceInput && error == nil) {
            AVCaptureSession *session = [[AVCaptureSession alloc] init];
            if ([session canAddInput:captureDeviceInput]) {
                [session addInput:captureDeviceInput];
            } else {
                NSDictionary *errMsg = @{@"description" : @"Error adding video input."};
                error = [NSError errorWithDomain:@"MCYCameraView" code:10002 userInfo:errMsg];
            }
            
            captureSession = session;
            
        } else {
            NSDictionary *errMsg = @{@"description" : @"Error creating capture device input."};
            error = [NSError errorWithDomain:@"MCYCameraView" code:10001 userInfo:errMsg];
        }
    } else {
        NSDictionary *errMsg = @{@"description" : @"Back video device not found."};
        error = [NSError errorWithDomain:@"MCYCameraView" code:10000 userInfo:errMsg];
    }
    
    CaptureSessionResult *result = [[CaptureSessionResult alloc] init];
    result.session = captureSession;
    result.error = error;
    
    return result;
}

- (AVCaptureDevice*)inputDevice
{
    if (self.captureSession && self.captureSession.inputs && self.captureSession.inputs.count > 0) {
        NSArray *inputs = self.captureSession.inputs;
        AVCaptureDevice *inputDevice = nil;
        for (AVCaptureDeviceInput *input in inputs) {
            inputDevice = input.device;
            break;
        }
        
        return inputDevice;
    }
    
    return nil;
}

@end

@implementation CaptureSessionResult

@end
