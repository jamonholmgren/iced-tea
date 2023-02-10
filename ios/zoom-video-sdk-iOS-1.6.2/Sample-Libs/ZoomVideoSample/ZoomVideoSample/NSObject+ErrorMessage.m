//
//  NSObject+ErrorMessage.m
//  ZoomVideoSample
//
//  Created by Zoom Video Communications on 2019/11/29.
//  Copyright © 2019 Zoom. All rights reserved.
//

#import "NSObject+ErrorMessage.h"

@implementation NSObject (ErrorMessage)

- (NSString *)formatErrorString:(ZoomVideoSDKError)errorCode {
    switch (errorCode) {
        case Errors_Wrong_Usage:
            return @"Incorrect use";
        case Errors_Internal_Error:
            return @"Internal error";
        case Errors_Uninitialize:
            return @"Uninitialized";
        case Errors_Memory_Error:
            return @"Memory error";
        case Errors_Load_Module_Error:
            return @"Load module failed";
        case Errors_UnLoad_Module_Error:
            return @"Unload module failed";
        case Errors_Invalid_Parameter:
            return @"Parameter error";
        case Errors_Unknown:
            return @"Unknown error";
        case Errors_Auth_Error:
            return @"Authentication error";
        case Errors_Auth_Empty_Key_or_Secret:
            return @"Empty key or secret";
        case Errors_Auth_Wrong_Key_or_Secret:
            return @"Incorrect key or secret";
        case Errors_Auth_DoesNot_Support_SDK:
            return @"Authenticated key or secret does not support SDK";
        case Errors_Auth_Disable_SDK:
            return @"Disabled SDK with authenticated key or secret";
        case Errors_Session_Module_Not_Found:
            return @"Module not found";
        case Errors_Session_Service_Invaild:
            return @"The service is invalid";
        case Errors_Session_Join_Failed:
            return @"Join session failed";
        case Errors_Session_No_Rights:
            return @"You don’t have permission to join this session";
        case Errors_Session_Already_In_Progress:
            return @"Joining session…";
        case Errors_Session_Dont_Support_SessionType:
            return @"Unsupported session type";
        case Errors_Session_Reconncting:
            return @"Reconnecting session…";
        case Errors_Session_Disconncting:
            return @"Disconnecting session…";
        case Errors_Session_Not_Started:
            return @"This session has not started";
        case Errors_Session_Need_Password:
            return @"This session requires password";
        case Errors_Session_Password_Wrong:
            return @"Incorrect password";
        case Errors_Session_Remote_DB_Error:
            return @"Error received from remote database";
        case Errors_Session_Invalid_Param:
            return @"Parameter error when joining the session";
        case Errors_Session_Audio_Error:
            return @"Session audio module error";
        case Errors_Session_Audio_No_Microphone:
            return @"Session audio no microphone";
        case Errors_Session_Video_Error:
            return @"Session video module error";
        case Errors_Session_Video_Device_Error:
            return @"Session video device module error";
        case Errors_Session_Live_Stream_Error:
            return @"Live stream error";
        case Errors_Malloc_Failed:
            return @"Raw data memory allocation error";
        case Errors_Not_In_Session:
            return @"Not in session when subscribing to raw data";
        case Errors_No_License:
            return @"License without raw data";
        case Errors_Video_Module_Not_Ready:
            return @"Video module is not ready";
        case Errors_Video_Module_Error:
            return @"Video module error";
        case Errors_Video_device_error:
            return @"Video device error";
        case Errors_No_Video_Data:
            return @"No video data";
        case Errors_Share_Module_Not_Ready:
            return @"Share module is not ready";
        case Errors_Share_Module_Error:
            return @"Share module error";
        case Errors_No_Share_Data:
            return @"No sharing data";
        case Errors_Audio_Module_Not_Ready:
            return @"Audio module is not ready";
        case Errors_Audio_Module_Error:
            return @"Audio module error";
        case Errors_No_Audio_Data:
            return @"No audio data";
        default:
            break;
    }
    
    return nil;
}

@end
