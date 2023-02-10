//
//  ZoomVideoSDKAudioHelper.h
//  ZoomVideoSDK
//
//  Created by Zoom Video Communications on 2018/12/6.
//  Copyright © 2018 Zoom Video Communications, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZoomVideoSDK.h"

/*!
 @class ZoomVideoSDKAudioHelper
 @brief A class to operate the audio action.
 */
@interface ZoomVideoSDKAudioHelper : NSObject

/*!
 @brief Start audio.
 @return the result of it
 */
- (ZoomVideoSDKError)startAudio;

/*!
 @brief Stop audio.
 @return the result of it
 */
- (ZoomVideoSDKError)stopAudio;

/*!
 @brief Mute user audio by userId
 @return the result of it
 @warning If mute self use userid=0.
 @warning Only user who start the session can mute others audio..
 */
- (ZoomVideoSDKError)muteAudio:(ZoomVideoSDKUser * _Nullable)user;

/*!
 @brief Unmute user audio by userId
 @return the result of it
 @warning If unmute self use userid=0.
 @warning Only user who start the session can unmute others audio..
 */
- (ZoomVideoSDKError)unmuteAudio:(ZoomVideoSDKUser * _Nullable)user;

/*!
 @brief Call the function to subscribe audio rawdata.
 @warning please check the callack "- (void)onMixedAudioRawDataReceived:(ZoomVideoSDKAudioRawData *)rawData"
 @warning " - (void)onOneWayAudioRawDataReceived:(ZoomVideoSDKAudioRawData *)rawData user:(ZoomVideoSDKUser *)user
 */
- (ZoomVideoSDKError)subscribe;

/*!
 @brief Call the function to unSubscribe audio rawdata.
 @warning please check the callack "- (void)onMixedAudioRawDataReceived:(ZoomVideoSDKAudioRawData *)rawData"
 @warning " - (void)onOneWayAudioRawDataReceived:(ZoomVideoSDKAudioRawData *)rawData user:(ZoomVideoSDKUser *)user
 */
- (ZoomVideoSDKError)unSubscribe;

/*!
 @brief Reset Audio Session including Category and Mode.
 @return Yes means set auidio success, otherwise failed.
 */
- (BOOL)resetAudioSession;

/*!
 @brief Clean Audio Session including Category and Mode. 
 */
- (void)cleanAudioSession;

@end

