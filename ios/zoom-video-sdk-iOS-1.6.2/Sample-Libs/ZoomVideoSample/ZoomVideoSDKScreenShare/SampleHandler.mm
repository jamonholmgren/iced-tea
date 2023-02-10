//
//  SampleHandler.m
//  ZoomVideoSDKScreenShare
//
//  Created by Zoom Video Communications on 2019/5/22.
//  Copyright © 2019 Zoom Video Communications. All rights reserved.
//


#import "SampleHandler.h"
#import <ZoomVideoSDKScreenShare/ZoomVideoSDKScreenShareService.h>

@interface SampleHandler () <ZoomVideoSDKScreenShareServiceDelegate>

@property (strong, nonatomic) ZoomVideoSDKScreenShareService * screenShareService;

@end

@implementation SampleHandler

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        ZoomVideoSDKScreenShareServiceInitParams *params = [[ZoomVideoSDKScreenShareServiceInitParams alloc] init];
        /**
         * if you need use screen share feature, Here are a few things to note:
         * <1> Create your own groupid on the Apple Developer Web site, and fill the group ID in here and in the AppDelegate.m
         * <2> Create an "App Groups" Capability in the main project target and the replayKit project target, and select the groupId correctly.
         * <3> If you can't select groupId correctly in "App Groups" Capability, Please check ZoomVideoSample.Entitlements and ZoomVideoSDKScreenShare.entitlements this two files, here also need to configure the correct group id.
         *   <key>com.apple.security.application-groups</key>
             <array>
                <string> your group id </string>
             </array
         *
         * For details, please refer: https://marketplace.zoom.us/docs/sdk/video/ios/advanced/screen-share
         *
         * if you don't need screen share, please delete ZoomVideoSDKScreenShare target.
         *
         */
        params.appGroupId = @"<#Group ID#>"; // please input group id from the Apple Developer Web site.
        params.isWithDeviceAudio = YES;
        
        ZoomVideoSDKScreenShareService * service = [[ZoomVideoSDKScreenShareService alloc]initWithParams:params];
        self.screenShareService = service;
        self.screenShareService.delegate = self;
    }
    return self;
}

- (void)dealloc
{
    self.screenShareService.delegate = nil;
    self.screenShareService = nil;
}


- (void)broadcastStartedWithSetupInfo:(NSDictionary<NSString *,NSObject *> *)setupInfo {
    // User has requested to start the broadcast. Setup info from the UI extension can be supplied but optional.
    [self.screenShareService broadcastStartedWithSetupInfo:setupInfo];
    
}

- (void)broadcastPaused {
    [self.screenShareService broadcastPaused];
    // User has requested to pause the broadcast. Samples will stop being delivered.
}

- (void)broadcastResumed {
    [self.screenShareService broadcastResumed];
    // User has requested to resume the broadcast. Samples delivery will resume.
}

- (void)broadcastFinished {
    // User has requested to finish the broadcast.
    [self.screenShareService broadcastFinished];
}

- (void)processSampleBuffer:(CMSampleBufferRef)sampleBuffer withType:(RPSampleBufferType)sampleBufferType {
    [self.screenShareService processSampleBuffer:sampleBuffer withType:sampleBufferType];
}

- (void)ZoomVideoSDKScreenShareServiceFinishBroadcastWithError:(NSError *)error
{
    [self finishBroadcastWithError:error];
}

@end
