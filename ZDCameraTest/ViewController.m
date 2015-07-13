//
//  ViewController.m
//  ZDCameraTest
//
//  Created by 0day on 15/7/13.
//  Copyright (c) 2015年 Pili Engineering. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface ViewController ()
<
AVCaptureVideoDataOutputSampleBufferDelegate
>
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSArray *devices = [AVCaptureDevice devices];
    AVCaptureDevice *captureDevice = nil;
    
    for (AVCaptureDevice *device in devices) {
        if ([device hasMediaType:AVMediaTypeVideo] && device.position == AVCaptureDevicePositionBack) {
            captureDevice = device;
            
            NSError *error;
            [device lockForConfiguration:&error];
            
            device.activeVideoMinFrameDuration = CMTimeMake(1, 30);
            device.activeVideoMaxFrameDuration = CMTimeMake(1, 30);
            
            [device unlockForConfiguration];
            
            break;
        }
    }
    
    NSAssert(captureDevice, @"target capture device can not be found.");
    
    // Do any additional setup after loading the view, typically from a nib.
    AVCaptureSession *captureSession = [[AVCaptureSession alloc] init];
    AVCaptureDeviceInput *input = nil;
    AVCaptureVideoDataOutput *output = nil;
    
    input = [[AVCaptureDeviceInput alloc] initWithDevice:captureDevice error:nil];
    output = [[AVCaptureVideoDataOutput alloc] init];
    
    captureSession.sessionPreset = AVCaptureSessionPresetHigh;
    
    // setup output
    output.videoSettings = @{(NSString *)kCVPixelBufferPixelFormatTypeKey: @(kCVPixelFormatType_32BGRA)};
    
    dispatch_queue_t cameraQueue = dispatch_queue_create("com.pili.camera", 0);
    [output setSampleBufferDelegate:self queue:cameraQueue];
    
    // add input && output
    if ([captureSession canAddInput:input]) {
        [captureSession addInput:input];
    }
    
    if ([captureSession canAddOutput:output]) {
        [captureSession addOutput:output];
    }
    
    AVCaptureVideoPreviewLayer* previewLayer;
    previewLayer =  [AVCaptureVideoPreviewLayer layerWithSession:captureSession];
    previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    previewLayer.frame = self.view.bounds;
    [self.view.layer addSublayer:previewLayer];
    
    [captureSession startRunning];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - <AVCaptureVideoDataOutputSampleBufferDelegate>

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
}

@end
