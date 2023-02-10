//
//  SendYUVAdapter.m
//  ZoomVideoSample
//
//  Created by Zoom Video Communications on 2020/7/8.
//  Copyright © 2020 Zoom. All rights reserved.
//

#import "SendYUVAdapter.h"

#define Default_fps 24
#define usec_per_fps (1000000/Default_fps)

@interface SendYUVAdapter ()
@property (nonatomic, strong) ZoomVideoSDKVideoSender *videoRawdataSender;

@property (strong, nonatomic) NSThread  *workThread;
@property (assign, nonatomic) int width;
@property (assign, nonatomic) int height;
@end

@implementation SendYUVAdapter

- (instancetype)init
{
    self = [super init];
    if (self) {
    }
    return self;
}

- (void)dealloc {
    [self stop];
}

#pragma mark - send raw data cb -
- (void)onInitialize:(ZoomVideoSDKVideoSender *_Nonnull)rawDataSender supportCapabilityArray:(NSArray *_Nonnull)supportCapabilityArray suggestCapability:(ZoomVideoSDKVideoCapability *_Nonnull)suggestCapability
{
    // save video rawdata sender
    self.videoRawdataSender = rawDataSender;
    
    self.width = 640;
    self.height = 480;
}

- (void)onPropertyChange:(NSArray *_Nonnull)supportCapabilityArray suggestCapability:(ZoomVideoSDKVideoCapability *_Nonnull)suggestCapability
{
    
}

- (void)onStartSend
{
    [self beginPullVideo];
}

- (void)onStopSend
{
    [self stop];
}

- (void)onUninitialized
{
    self.videoRawdataSender = nil;
}


- (void)beginPullVideo
{
    if (self.workThread == nil) {
        self.workThread = [[NSThread alloc] initWithTarget:self selector:@selector(pullRunloop) object:nil];
        [self.workThread start];
    }
}

- (void)pullRunloop
{
    NSString *lpath = [[NSBundle mainBundle] pathForResource:@"640x480_2" ofType:@"yuv"];
    if (lpath.length == 0) {
        NSLog(@"lpath = nil");
        return;
    }
    NSURL *fileUrl = [NSURL fileURLWithPath:lpath];
    NSString *path = fileUrl.path;
    if (path.length == 0) {
        NSLog(@"path = nil");
        return;
    }
    
    FILE *yuvFile = fopen([path UTF8String], "rb");
    if (yuvFile == NULL) {
//        NSLog(@"open yuv failed");
        return;
    }
    if (self.width <= 0 || self.height <= 0) {
//        NSLog(@"yuv width or heigh = 0");
        return;
    }
    
//    NSLog(@"begain pull video");
    while (![NSThread currentThread].isCancelled) {

        unsigned char * yuvFrame = malloc(self.height*self.width* 3 / 2);
        
        size_t uAddress = self.height*self.width;
        size_t vAddress = self.height*self.width * 5 / 4;
        
        size_t size = fread(&yuvFrame[0], 1, self.width * self.height, yuvFile);
        size = fread(&yuvFrame[uAddress], 1, self.width * self.height/4, yuvFile);
        size = fread(&yuvFrame[vAddress], 1, self.width * self.height/4, yuvFile);
        
        if (size == 0) {
//            NSLog(@"read data size = 0");
            break;
        }
        
         dispatch_sync(dispatch_get_main_queue(), ^{
            [self.videoRawdataSender sendVideoFrame:(char *)yuvFrame width:self.width height:self.height dataLength:self.width*self.height*1.5 rotation:ZoomVideoSDKVideoRawDataRotationNone];
             free(yuvFrame);
         });
        
        usleep(usec_per_fps);
    }
    
    fclose(yuvFile);
    yuvFile = NULL;
//    NSLog(@"end pull video");
    [self stop];
    [self beginPullVideo];
}

- (void)stop
{
    if (self.workThread) {
        [self.workThread cancel];
        self.workThread = nil;
    }
}

@end
