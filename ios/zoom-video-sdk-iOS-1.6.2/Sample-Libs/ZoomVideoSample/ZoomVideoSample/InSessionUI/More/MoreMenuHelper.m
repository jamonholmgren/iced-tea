//
//  MoreMenuHelper.m
//  ZoomVideoSample
//
//  Created by Zoom on 2022/1/6.
//  Copyright © 2022 Zoom. All rights reserved.
//

#import "MoreMenuHelper.h"
#import <AudioToolbox/AudioToolbox.h>

static MoreMenuHelper *instance = nil;
static dispatch_once_t onceToken;

@implementation MoreMenuHelper

+ (MoreMenuHelper*)sharedInstance
{
    dispatch_once(&onceToken, ^{
        instance = [[MoreMenuHelper alloc] init];
    });
    return instance;
}

- (void)switchSpeaker
{
#define COMPARE(FIRST,SECOND) (CFStringCompare(FIRST, SECOND, kCFCompareCaseInsensitive) == kCFCompareEqualTo)
    CFDictionaryRef route;
    UInt32 size = sizeof (route);
    OSStatus status = AudioSessionGetProperty(kAudioSessionProperty_AudioRouteDescription, &size, &route);
    if (status != noErr) {
        return;
    }
    
    CFArrayRef outputs = (CFArrayRef)CFDictionaryGetValue(route, kAudioSession_AudioRouteKey_Outputs);
    if (!outputs || CFArrayGetCount(outputs) == 0) {
        if(route) CFRelease(route);
        return;
    }
    
    CFDictionaryRef item = (CFDictionaryRef)CFArrayGetValueAtIndex(outputs, 0);
    CFStringRef device = (CFStringRef)CFDictionaryGetValue(item, kAudioSession_AudioRouteKey_Type);
    if (device && COMPARE(device, kAudioSessionOutputRoute_BuiltInReceiver))
    {
        UInt32 isSpeaker = kAudioSessionOverrideAudioRoute_Speaker;
        AudioSessionSetProperty(kAudioSessionProperty_OverrideAudioRoute, sizeof(isSpeaker), &isSpeaker);
        self.isSpeaker = YES;
    }
    else if (device && COMPARE(device, kAudioSessionOutputRoute_BuiltInSpeaker))
    {
        UInt32 isSpeaker = kAudioSessionOverrideAudioRoute_None;
        AudioSessionSetProperty(kAudioSessionProperty_OverrideAudioRoute, sizeof(isSpeaker), &isSpeaker);
        self.isSpeaker = NO;
    }
    
    if(route) CFRelease(route);
}

@end
