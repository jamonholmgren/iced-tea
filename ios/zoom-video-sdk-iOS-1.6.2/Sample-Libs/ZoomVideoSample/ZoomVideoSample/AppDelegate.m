//
//  AppDelegate.m
//  ZoomVideoSample
//
//  Created by Zoom Video Communications on 2019/5/24.
//  Copyright © 2019 Zoom. All rights reserved.
//

#import "AppDelegate.h"
#import "MainViewController.h"
#import "BaseNavigationController.h"
#import "IntroViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    //     Override point for customization after application launch.

    [self initZoomSDK];
    
    NSString *version = [[ZoomVideoSDK shareInstance] getSDKVersion];
    NSLog(@"[ZoomVideoSDK] Video SDK version: %@", version);
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    IntroViewController *viewController = [IntroViewController new];

    BaseNavigationController *navigationController = [[BaseNavigationController alloc] initWithRootViewController:viewController];

    MainViewController *mainViewController = [MainViewController new];
    mainViewController.rootViewController = navigationController;
    [mainViewController setupWithType];

    UIWindow *window = UIApplication.sharedApplication.delegate.window;
    window.rootViewController = mainViewController;
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window
{
    if (self.canRotation) {
        return (UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskLandscapeLeft | UIInterfaceOrientationMaskLandscapeRight);
    }
    return UIInterfaceOrientationMaskPortrait;
}

- (UIViewController *)topViewController
{
    UIViewController *resultVC;
    resultVC = [self _topViewController:[[UIApplication sharedApplication].keyWindow rootViewController]];
    while (resultVC.presentedViewController) {
        resultVC = [self _topViewController:resultVC.presentedViewController];
    }
    return resultVC;
}

- (UIViewController *)_topViewController:(UIViewController *)vc
{
    if ([vc isKindOfClass:[UINavigationController class]]) {
        return [self _topViewController:[(UINavigationController *)vc topViewController]];
    } else if ([vc isKindOfClass:[UITabBarController class]]) {
        return [self _topViewController:[(UITabBarController *)vc selectedViewController]];
    } else {
        return vc;
    }
    return nil;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [self unInitialize];
}

- (void)unInitialize
{
    ZoomVideoSDKError ret = [[ZoomVideoSDK shareInstance] cleanup];
    NSLog(@"[ZoomVideoSDK] cleanup =====>%@", ret == Errors_Success ? @"Success" : @(ret));
}

- (void)initZoomSDK
{
    ZoomVideoSDKInitParams *context = [[ZoomVideoSDKInitParams alloc] init];
    context.domain = kAppDomain;
    /**
     * if you need use screen share feature, Here are a few things to note:
     * <1> Create your own app groupId on the Apple Developer Web site, and fill the group ID in this file and in the file SampleHandler.mm
     * <2> Create an "App Groups" Capability in the main project target and the screenshare target, and select the groupId correctly.
     * <3> If you can't select groupId correctly in "App Groups" Capability, Please check files of ZoomVideoSample.entitlements and ZoomVideoSDKScreenShare.entitlements, need to configure the correct group id. etc:
     *   <key>com.apple.security.application-groups</key>
         <array>
             <string> your group id </string>
         </array
     *
     * For details, please refer: https://marketplace.zoom.us/docs/sdk/video/ios/advanced/screen-share
     *
     * if you don't need screen share feature, appGroupId can fill an empty string, or delete the bottom line. And delete ZoomVideoSDKScreenShare target.
     */
    context.appGroupId = @"<#Group ID#>"; // please input group id from the Apple Developer Web site.
    context.enableLog = YES;
//    context.logFilePrefix = @"";
//    context.videoRawdataMemoryMode = ZoomVideoSDKRawDataMemoryModeHeap;
//    context.shareRawdataMemoryMode = ZoomVideoSDKRawDataMemoryModeHeap;
//    context.audioRawdataMemoryMode = ZoomVideoSDKRawDataMemoryModeHeap;
    
//    NSString *speakerFilePath = [[NSBundle mainBundle] pathForResource:@"" ofType:@"mp3"];
//    if (speakerFilePath.length != 0) {
//        ZoomVideoSDKExtendParams *extendParams = [[ZoomVideoSDKExtendParams alloc] init];
//        extendParams.speakerTestFilePath = speakerFilePath;
//        context.extendParam = extendParams;
//    }
    
    ZoomVideoSDKError ret = [[ZoomVideoSDK shareInstance] initialize:context];
    NSLog(@"[ZoomVideoSDK] initialize =====>%@", ret == Errors_Success ? @"Success" : @(ret));
}
@end
