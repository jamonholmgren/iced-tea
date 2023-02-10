//
//  AppDelegate.h
//  ZoomVideoSample
//
//  Created by Zoom Video Communications on 2019/5/24.
//  Copyright © 2019 Zoom. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
* We recommend that, you can generate jwttoken on your own server instead of hardcore in the code.
* We hardcore it here, just to run the demo.
*
* You can generate a jwttoken on the https://jwt.io/
* with this payload:
 {
   "app_key": "string",
   "version": long,
   "tpc": "string",
   "iat": long,
   "exp": long,
   "user_identity": "string",
   "role_type": long // 0 or 1
 }
*/
#define kAppToken   @"<#AppToken#>"
#define kAppDomain  @"<#AppDomain#>"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (assign, nonatomic) BOOL canRotation;

- (UIViewController *)topViewController;
@end

