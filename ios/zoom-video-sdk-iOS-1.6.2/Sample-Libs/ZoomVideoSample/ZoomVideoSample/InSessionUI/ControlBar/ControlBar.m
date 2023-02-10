//
//  ControlBar.m
//  ZoomVideoSample
//
//  Created by Zoom Video Communications on 2019/5/27.
//  Copyright © 2019 Zoom. All rights reserved.
//

#import "ControlBar.h"
#import "TopBarView.h"
#import <AudioToolbox/AudioToolbox.h>
#import "MoreMenuViewController.h"
#import "VBViewController.h"

#define kTagButtonVideo         2000
#define kTagButtonShare         (kTagButtonVideo+1)
#define kTagButtonAudio          (kTagButtonVideo+2)
#define kTagButtonMore          (kTagButtonVideo+3)

@interface ControlBar ()
@property (strong, nonatomic) UIButton          *videoBtn;
@property (strong, nonatomic) UIButton          *moreBtn;

@property (nonatomic, assign) BOOL              isSpeaker;
@property (nonatomic, assign) NSInteger         indexOfExternalVideoSource;
@end

@implementation ControlBar

- (id)init
{
    self = [super init];
    if (self) {
        [self initSubView];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];

    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    BOOL landscape = UIInterfaceOrientationIsLandscape(orientation);
    
    float button_width;
    if (landscape) {
        if (IS_IPAD) {
            button_width = 65.0;
        } else {
            if (SCREEN_HEIGHT <= 375.0) {
                button_width = 50;
            } else {
                button_width = 55;
            }
        }
    } else {
        button_width = 65;
    }
    
    ZoomVideoSDKUser *myUser = [[[ZoomVideoSDK shareInstance] getSession] getMySelf];
    _audioBtn.frame = CGRectMake(0, 0, button_width, button_width * ([UIImage imageNamed:@"icon_no_audio"].size.height/[UIImage imageNamed:@"icon_no_audio"].size.width));
    if (myUser.audioStatus.audioType == ZoomVideoSDKAudioType_None) {
        _audioBtn.frame = CGRectMake(0, 0, button_width, button_width * ([UIImage imageNamed:@"icon_no_audio"].size.height/[UIImage imageNamed:@"icon_no_audio"].size.width));
    } else {
        if (!myUser.audioStatus.isMuted) {
            [_audioBtn setImage:[UIImage imageNamed:@"icon_mute"] forState:UIControlStateNormal];
        } else {
            [_audioBtn setImage:[UIImage imageNamed:@"icon_unmute"] forState:UIControlStateNormal];
        }
    }
    
    _shareBtn.frame = CGRectMake(0, CGRectGetMaxY(_audioBtn.frame), button_width, button_width * ([UIImage imageNamed:@"icon_video_share"].size.height/[UIImage imageNamed:@"icon_video_share"].size.width));
    _videoBtn.frame = CGRectMake(0, CGRectGetMaxY(_shareBtn.frame), button_width, button_width * ([UIImage imageNamed:@"icon_video_on"].size.height/[UIImage imageNamed:@"icon_video_on"].size.width));
    _moreBtn.frame = CGRectMake(0, CGRectGetMaxY(_videoBtn.frame), button_width, button_width * ([UIImage imageNamed:@"icon_video_more"].size.height/[UIImage imageNamed:@"icon_video_more"].size.width));
    
    float controlBar_height = Height(_moreBtn)+Height(_videoBtn)+Height(_shareBtn)+Height(_audioBtn);
    
    float controlBar_x = SCREEN_WIDTH-button_width - 5;
    float controlBar_y;
    if (landscape) {
        if (orientation == UIInterfaceOrientationLandscapeLeft && IPHONE_X) {
            controlBar_x = SCREEN_WIDTH-button_width-SAFE_ZOOM_INSETS;
        } else {
            controlBar_x = SCREEN_WIDTH-button_width - 12;
        }
    }
    
    if (landscape && !IS_IPAD && SCREEN_HEIGHT <= 375.0) {
        controlBar_y = Top_Height + 20;
    } else {
        controlBar_y = (SCREEN_HEIGHT - controlBar_height)/2;
    }
    self.frame = CGRectMake(controlBar_x, controlBar_y, button_width, controlBar_height);
}

- (void)initSubView {
    _videoBtn = [[UIButton alloc] init];
    _videoBtn.tag = kTagButtonVideo;
    [_videoBtn setImage:[UIImage imageNamed:@"icon_video_off"] forState:UIControlStateNormal];
    [_videoBtn setImage:[UIImage imageNamed:@"icon_video_on"] forState:UIControlStateSelected];
    [_videoBtn addTarget: self action: @selector(onBarButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_videoBtn];
    
    _shareBtn = [[UIButton alloc] init];
    _shareBtn.tag = kTagButtonShare;
    [_shareBtn setImage:[UIImage imageNamed:@"icon_video_share"] forState:UIControlStateNormal];
    [_shareBtn addTarget: self action: @selector(onBarButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_shareBtn];
    
    _audioBtn = [[UIButton alloc] init];
    _audioBtn.tag = kTagButtonAudio;
    [_audioBtn setImage:[UIImage imageNamed:@"icon_no_audio"] forState:UIControlStateNormal];
    [_audioBtn addTarget: self action: @selector(onBarButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_audioBtn];
        
    _moreBtn = [[UIButton alloc] init];
    _moreBtn.tag = kTagButtonMore;
    [_moreBtn setImage:[UIImage imageNamed:@"icon_video_more"] forState:UIControlStateNormal];
    [_moreBtn addTarget: self action: @selector(onBarButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_moreBtn];
    
    
}

- (void)showAudioTestMenu:(id)sender
{
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Audio"
                                                                             message:nil
                                                                      preferredStyle:UIAlertControllerStyleActionSheet];
    
    if (!IS_IPAD) {
        NSString *speakDispaly;
        if (self.isSpeaker) {
            speakDispaly = @"On:Turn off Speaker";
        } else {
            speakDispaly = @"Off:Turn on Speaker";
        }
        [alertController addAction:[UIAlertAction actionWithTitle:speakDispaly
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction *action) {
                                                              [self switchSpeaker];
                                                          }]];
    }

    [alertController addAction:[UIAlertAction actionWithTitle:@"startAudio"
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction *action) {
                                                          [[[ZoomVideoSDK shareInstance] getAudioHelper] startAudio];
                                                      }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"stopAudio"
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction *action) {
                                                          [[[ZoomVideoSDK shareInstance] getAudioHelper] stopAudio];
                                                      }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"muteAudio:"
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction *action) {
        ZoomVideoSDKUser *myself = [[[ZoomVideoSDK shareInstance] getSession] getMySelf];
        [[[ZoomVideoSDK shareInstance] getAudioHelper] muteAudio:myself];
                                                      }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"unMuteAudio:"
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction *action) {
        ZoomVideoSDKUser *myself = [[[ZoomVideoSDK shareInstance] getSession] getMySelf];
        [[[ZoomVideoSDK shareInstance] getAudioHelper] unmuteAudio:myself];
                                                      }]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"subscribe"
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction *action) {
        [[[ZoomVideoSDK shareInstance] getAudioHelper] subscribe];
                                                      }]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"unSubscribe"
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction *action) {
        [[[ZoomVideoSDK shareInstance] getAudioHelper] unSubscribe];
                                                      }]];
    
    ZoomVideoSDKAudioSettingHelper *audioSettingHelper = [[ZoomVideoSDK shareInstance] getAudioSettingHelper];
    BOOL isOrigin = [audioSettingHelper isMicOriginalInputEnable];
    [alertController addAction:[UIAlertAction actionWithTitle:isOrigin?@"origin: set to non-origin":@"non-origin: set to origin"
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction *action) {
        [audioSettingHelper enableMicOriginalInput:!isOrigin];
                                                      }]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:nil]];
    
    UIPopoverPresentationController *popover = alertController.popoverPresentationController;
    if (popover)
    {
        UIButton *btn = (UIButton*)sender;
        popover.sourceView = btn;
        popover.sourceRect = btn.bounds;
        popover.permittedArrowDirections = UIPopoverArrowDirectionAny;
    }
    [[appDelegate topViewController] presentViewController:alertController animated:YES completion:nil];
}

- (void)showVideoTestMenu:(id)sender
{
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Video"
                                                                             message:nil
                                                                      preferredStyle:UIAlertControllerStyleActionSheet];

    [alertController addAction:[UIAlertAction actionWithTitle:@"startVideo"
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction *action) {
                                                          [[[ZoomVideoSDK shareInstance] getVideoHelper] startVideo];
                                                      }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"stopVideo"
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction *action) {
                                                          [[[ZoomVideoSDK shareInstance] getVideoHelper] stopVideo];
                                                      }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"rotateMyVideo:"
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction *action) {
        [[[ZoomVideoSDK shareInstance] getVideoHelper] rotateMyVideo:UIDeviceOrientationLandscapeLeft];
                                                      }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"switchCamera:"
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction *action) {
        [[[ZoomVideoSDK shareInstance] getVideoHelper] switchCamera];
                                                      }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"mirrorVideo"
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction *action) {
        BOOL ret = [[[ZoomVideoSDK shareInstance] getVideoHelper] isMirrorMyVideoEnabled];
        [[[ZoomVideoSDK shareInstance] getVideoHelper] mirrorMyVideo:!ret];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            NSLog(@"isMirrorMyVideoEnabled %@", @(ret));
        });
                                                      }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"videoPreference:"
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction *action) {
        ZoomVideoSDKVideoPreferenceSetting *setting = [ZoomVideoSDKVideoPreferenceSetting new];
        setting.mode = ZoomVideoSDKVideoPreferenceMode_Sharpness;
        [[[ZoomVideoSDK shareInstance] getVideoHelper] setVideoQualityPreference:setting];
                                                      }]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:nil]];
    
    UIPopoverPresentationController *popover = alertController.popoverPresentationController;
    if (popover)
    {
        UIButton *btn = (UIButton*)sender;
        popover.sourceView = btn;
        popover.sourceRect = btn.bounds;
        popover.permittedArrowDirections = UIPopoverArrowDirectionAny;
    }
    [[appDelegate topViewController] presentViewController:alertController animated:YES completion:nil];
}


- (void)showShareTestMenu:(id)sender
{
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Share"
                                                                             message:nil
                                                                      preferredStyle:UIAlertControllerStyleActionSheet];

    [alertController addAction:[UIAlertAction actionWithTitle:@"startShareWithView: check in UI"
                                                        style:UIAlertActionStyleDefault
                                                      handler:nil]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"stopShare"
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction *action) {
                                                          [[[ZoomVideoSDK shareInstance] getShareHelper] stopShare];
                                                      }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"lockShare:"
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction *action) {
        [[[ZoomVideoSDK shareInstance] getShareHelper] lockShare:YES];
                                                      }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"unlockShare:"
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction *action) {
        [[[ZoomVideoSDK shareInstance] getShareHelper] lockShare:NO];
                                                      }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"enableShareDeviceAudio:"
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction *action) {
        [[[ZoomVideoSDK shareInstance] getShareHelper] enableShareDeviceAudio:YES];
                                                      }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"unEnableShareDeviceAudio:"
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction *action) {
        [[[ZoomVideoSDK shareInstance] getShareHelper] enableShareDeviceAudio:NO];
                                                      }]];
    NSString *checkStr = [NSString stringWithFormat:@"isShareLocked:%@ isSharingOut:%@ isOtherSharing:%@",@([[ZoomVideoSDK shareInstance] getShareHelper].isShareLocked),@([[ZoomVideoSDK shareInstance] getShareHelper].isSharingOut), @([[ZoomVideoSDK shareInstance] getShareHelper].isOtherSharing)];
    [alertController addAction:[UIAlertAction actionWithTitle:checkStr
                                                        style:UIAlertActionStyleDefault
                                                      handler:nil]];
    NSString *checkStr1 = [NSString stringWithFormat:@"isScreenSharingOut:%@ isShareDeviceAudioEnabled:%@",@([[ZoomVideoSDK shareInstance] getShareHelper].isScreenSharingOut), @([[ZoomVideoSDK shareInstance] getShareHelper].isShareDeviceAudioEnabled)];
    [alertController addAction:[UIAlertAction actionWithTitle:checkStr1
                                                        style:UIAlertActionStyleDefault
                                                      handler:nil]];
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:nil]];
    
    UIPopoverPresentationController *popover = alertController.popoverPresentationController;
    if (popover)
    {
        UIButton *btn = (UIButton*)sender;
        popover.sourceView = btn;
        popover.sourceRect = btn.bounds;
        popover.permittedArrowDirections = UIPopoverArrowDirectionAny;
    }
    [[appDelegate topViewController] presentViewController:alertController animated:YES completion:nil];
}

- (void)showLiveStreamTestMenu:(id)sender
{
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"LiveStream"
                                                                             message:nil
                                                                      preferredStyle:UIAlertControllerStyleActionSheet];

    [alertController addAction:[UIAlertAction actionWithTitle:@"StartLiveStream"
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction *action) {
        [[[ZoomVideoSDK shareInstance] getLiveStreamHelper] startLiveStreamWithStreamingURL:@"" StreamingKey:@"" BroadcastURL:@""];
                                                      }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"stopLiveStream"
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction *action) {
        [[[ZoomVideoSDK shareInstance] getLiveStreamHelper] stopLiveStream];
                                                      }]];
    [alertController addAction:[UIAlertAction actionWithTitle:[NSString stringWithFormat:@"canStartLiveStream:%@",@([[ZoomVideoSDK shareInstance] getLiveStreamHelper].canStartLiveStream)]
                                                        style:UIAlertActionStyleDefault
                                                      handler:nil]];
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:nil]];
    
    UIPopoverPresentationController *popover = alertController.popoverPresentationController;
    if (popover)
    {
        UIButton *btn = (UIButton*)sender;
        popover.sourceView = btn;
        popover.sourceRect = btn.bounds;
        popover.permittedArrowDirections = UIPopoverArrowDirectionAny;
    }
    [[appDelegate topViewController] presentViewController:alertController animated:YES completion:nil];
}

- (void)showRecordTestMenu:(id)sender
{
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Record"
                                                                             message:nil
                                                                      preferredStyle:UIAlertControllerStyleActionSheet];

    NSString *canStartRecording = [NSString stringWithFormat:@"canStartRecording:%@",@([[ZoomVideoSDK shareInstance] getRecordingHelper].canStartRecording)];
    [alertController addAction:[UIAlertAction actionWithTitle:canStartRecording
                                                        style:UIAlertActionStyleDefault
                                                      handler:nil]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"startCloudRecording"
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction *action) {
        [[[ZoomVideoSDK shareInstance] getRecordingHelper] startCloudRecording];
                                                      }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"stopCloudRecording"
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction *action) {
        [[[ZoomVideoSDK shareInstance] getRecordingHelper] stopCloudRecording];
                                                      }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"pauseCloudRecording"
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction *action) {
        [[[ZoomVideoSDK shareInstance] getRecordingHelper] pauseCloudRecording];
                                                      }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"resumeCloudRecording"
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction *action) {
        [[[ZoomVideoSDK shareInstance] getRecordingHelper] resumeCloudRecording];
                                                      }]];
    [alertController addAction:[UIAlertAction actionWithTitle:[NSString stringWithFormat:@"getCloudRecordingStatus:%@",@([[ZoomVideoSDK shareInstance] getRecordingHelper].getCloudRecordingStatus)]
                                                        style:UIAlertActionStyleDefault
                                                      handler:nil]];
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:nil]];
    
    UIPopoverPresentationController *popover = alertController.popoverPresentationController;
    if (popover)
    {
        UIButton *btn = (UIButton*)sender;
        popover.sourceView = btn;
        popover.sourceRect = btn.bounds;
        popover.permittedArrowDirections = UIPopoverArrowDirectionAny;
    }
    [[appDelegate topViewController] presentViewController:alertController animated:YES completion:nil];
}

- (void)showPhoneTestMenu:(id)sender
{
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Phone"
                                                                             message:nil
                                                                      preferredStyle:UIAlertControllerStyleActionSheet];

    NSString *isSupportPhoneFeature = [NSString stringWithFormat:@"isSupportPhoneFeature:%@",@([[ZoomVideoSDK shareInstance] getPhoneHelper].isSupportPhoneFeature)];
    [alertController addAction:[UIAlertAction actionWithTitle:isSupportPhoneFeature
                                                        style:UIAlertActionStyleDefault
                                                      handler:nil]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"getSupportCountryInfo"
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction *action) {
        NSArray *infoArr = [[[ZoomVideoSDK shareInstance] getPhoneHelper] getSupportCountryInfo];
        NSLog(@"getSupportCountryInfo:%@", infoArr);
                                                      }]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"inviteByPhone:phoneNumber:name:"
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction *action) {
        [[[ZoomVideoSDK shareInstance] getPhoneHelper] inviteByPhone:@"" phoneNumber:@"" name:@""];
                                                      }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"cancelInviteByPhone"
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction *action) {
        [[[ZoomVideoSDK shareInstance] getPhoneHelper] cancelInviteByPhone];
                                                      }]];
    [alertController addAction:[UIAlertAction actionWithTitle:[NSString stringWithFormat:@"getInviteByPhoneStatus:%@",@([[ZoomVideoSDK shareInstance] getPhoneHelper].getInviteByPhoneStatus)]
                                                        style:UIAlertActionStyleDefault
                                                      handler:nil]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"Get dial in number list"
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction *action) {
        NSArray *dialInList = [[[ZoomVideoSDK shareInstance] getPhoneHelper] getSessionDialInNumbers];
        NSLog(@"dial in list:\n %@", dialInList);
                                                      }]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:nil]];
    
    UIPopoverPresentationController *popover = alertController.popoverPresentationController;
    if (popover)
    {
        UIButton *btn = (UIButton*)sender;
        popover.sourceView = btn;
        popover.sourceRect = btn.bounds;
        popover.permittedArrowDirections = UIPopoverArrowDirectionAny;
    }
    [[appDelegate topViewController] presentViewController:alertController animated:YES completion:nil];
}
- (void)showUserTestMenu:(id)sender
{
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"User"
                                                                             message:nil
                                                                      preferredStyle:UIAlertControllerStyleActionSheet];

    NSMutableArray *allUser = [[[[ZoomVideoSDK shareInstance] getSession] getRemoteUsers] mutableCopy];
    [allUser addObject:[[[ZoomVideoSDK shareInstance] getSession] getMySelf]];
    
    NSString *userProperty = @"";
    for (ZoomVideoSDKUser *user in allUser) {
        userProperty = [userProperty stringByAppendingFormat:@"\n%@ : %@",user.getUserName, user.debugDescription];
    }
    
    NSLog(@"User property:%@", userProperty);
    
    [alertController addAction:[UIAlertAction actionWithTitle:userProperty
                                                        style:UIAlertActionStyleDefault
                                                      handler:nil]];
    
    
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:nil]];
    
    UIPopoverPresentationController *popover = alertController.popoverPresentationController;
    if (popover)
    {
        UIButton *btn = (UIButton*)sender;
        popover.sourceView = btn;
        popover.sourceRect = btn.bounds;
        popover.permittedArrowDirections = UIPopoverArrowDirectionAny;
    }
    [[appDelegate topViewController] presentViewController:alertController animated:YES completion:nil];
}

- (void)showVBTestMenu:(id)sender
{
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    VBViewController *VC = [[VBViewController alloc] init];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:VC];
    nav.modalPresentationStyle = UIModalPresentationPageSheet;
    [[appDelegate topViewController] presentViewController:nav animated:YES completion:NULL];
}

- (void)onBarButtonClicked:(UIButton *)sender
{
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    switch (sender.tag) {
        case kTagButtonMore:
        {
            MoreMenuViewController *pollingVC = [[MoreMenuViewController alloc] init];
            pollingVC.modalPresentationStyle = UIModalPresentationPageSheet;
            [[appDelegate topViewController] presentViewController:pollingVC animated:YES completion:nil];
            return;
            
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil
                                                                                     message:nil
                                                                              preferredStyle:UIAlertControllerStyleActionSheet];

            [alertController addAction:[UIAlertAction actionWithTitle:@"Audio"
                                                                style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction *action) {
                [self showAudioTestMenu:sender];
                                                              }]];
            [alertController addAction:[UIAlertAction actionWithTitle:@"Video"
                                                                style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction *action) {
                [self showVideoTestMenu:sender];
                                                              }]];
            [alertController addAction:[UIAlertAction actionWithTitle:@"Share"
                                                                style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction *action) {
                [self showShareTestMenu:sender];
                                                              }]];
            [alertController addAction:[UIAlertAction actionWithTitle:@"LiveStream"
                                                                style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction *action) {
                [self showLiveStreamTestMenu:sender];
                                                              }]];
            [alertController addAction:[UIAlertAction actionWithTitle:@"Recording"
                                                                style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction *action) {
                [self showRecordTestMenu:sender];
                                                              }]];
            [alertController addAction:[UIAlertAction actionWithTitle:@"Phone"
                                                                style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction *action) {
                [self showPhoneTestMenu:sender];
                                                              }]];
            [alertController addAction:[UIAlertAction actionWithTitle:@"User"
                                                                style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction *action) {
                [self showUserTestMenu:sender];
                                                              }]];
            
            if ([[[ZoomVideoSDK shareInstance] getVirtualBackgroundHelper] isSupportVirtualBackground]) {
                [alertController addAction:[UIAlertAction actionWithTitle:@"VB"
                                                                    style:UIAlertActionStyleDefault
                                                                  handler:^(UIAlertAction *action) {
                    [self showVBTestMenu:sender];
                                                                  }]];
            }
                        
            [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:nil]];
            
            UIPopoverPresentationController *popoverControl = alertController.popoverPresentationController;
            if (popoverControl)
            {
                UIButton *btn = (UIButton*)sender;
                popoverControl.sourceView = btn;
                popoverControl.sourceRect = btn.bounds;
                popoverControl.permittedArrowDirections = UIPopoverArrowDirectionAny;
            }
            [[appDelegate topViewController] presentViewController:alertController animated:YES completion:nil];
            
            NSLog(@"Session Number: %@, Phone Passcode:%@", @([[ZoomVideoSDK shareInstance] getSession].getSessionNumber), [[ZoomVideoSDK shareInstance] getSession].getSessionPhonePasscode);
            
            return;
            
            if (!IS_IPAD) {
                NSString *speakDispaly;
                if (self.isSpeaker) {
                    speakDispaly = @"Turn off Speaker";
                } else {
                    speakDispaly = @"Turn on Speaker";
                }
                [alertController addAction:[UIAlertAction actionWithTitle:speakDispaly
                                                                    style:UIAlertActionStyleDefault
                                                                  handler:^(UIAlertAction *action) {
                                                                      [self switchSpeaker];
                                                                  }]];
            }
            
            ZoomVideoSDKUser *myUser = [[[ZoomVideoSDK shareInstance] getSession] getMySelf];
            if (myUser.getVideoPipe.videoStatus.on) {
                [alertController addAction:[UIAlertAction actionWithTitle:@"Switch Camera"
                                                                    style:UIAlertActionStyleDefault
                                                                  handler:^(UIAlertAction *action) {
                                                                      [[[ZoomVideoSDK shareInstance] getVideoHelper] switchCamera];
                                                                  }]];
            }
            
#if DEBUG
            if ((myUser.isHost || myUser.isManager) && ![[[ZoomVideoSDK shareInstance] getShareHelper] isShareLocked]) {
                [alertController addAction:[UIAlertAction actionWithTitle:@"Lock Share"
                                                                    style:UIAlertActionStyleDefault
                                                                  handler:^(UIAlertAction *action) {
                                                                      [[[ZoomVideoSDK shareInstance] getShareHelper] lockShare:YES];
                                                                  }]];
            }
            
            if ((myUser.isHost || myUser.isManager) && [[[ZoomVideoSDK shareInstance] getShareHelper] isShareLocked]) {
                [alertController addAction:[UIAlertAction actionWithTitle:@"Unlock Share"
                                                                    style:UIAlertActionStyleDefault
                                                                  handler:^(UIAlertAction *action) {
                                                                      [[[ZoomVideoSDK shareInstance] getShareHelper] lockShare:NO];
                                                                  }]];
            }
            
            if (myUser.isHost) {
                BOOL haveManager = NO;
                for (ZoomVideoSDKUser *user in [[[ZoomVideoSDK shareInstance] getSession] getRemoteUsers]) {
                    if (user.isManager) {
                        haveManager = YES;
                    }
                }
                
                if (!haveManager) {
                    [alertController addAction:[UIAlertAction actionWithTitle:@"Make Manager"
                                                                        style:UIAlertActionStyleDefault
                                                                      handler:^(UIAlertAction *action) {
                                                                          for (ZoomVideoSDKUser *user in [[[ZoomVideoSDK shareInstance] getSession] getRemoteUsers]) {
                                                                              if (![user isEqual:[[[ZoomVideoSDK shareInstance] getSession] getMySelf]] && !user.isManager) {
                                                                                  [[[ZoomVideoSDK shareInstance] getUserHelper] makeManager:user];
                                                                                  break;
                                                                              }
                                                                          }
                                                                      }]];
                }
                
                if (haveManager) {
                    [alertController addAction:[UIAlertAction actionWithTitle:@"Revoke Manager"
                                                                        style:UIAlertActionStyleDefault
                                                                      handler:^(UIAlertAction *action) {
                                                                          for (ZoomVideoSDKUser *user in [[[ZoomVideoSDK shareInstance] getSession] getRemoteUsers]) {
                                                                              if (![user isEqual:[[[ZoomVideoSDK shareInstance] getSession] getMySelf]] && user.isManager) {
                                                                                  [[[ZoomVideoSDK shareInstance] getUserHelper] revokeManager:user];
                                                                              }
                                                                          }
                                                                      }]];
                }
                
                [alertController addAction:[UIAlertAction actionWithTitle:@"Change name"
                                                                    style:UIAlertActionStyleDefault
                                                                  handler:^(UIAlertAction *action) {
                    [[[ZoomVideoSDK shareInstance] getUserHelper] changeName:@"test Change" withUser:[[[ZoomVideoSDK shareInstance] getSession] getMySelf]];
                                                                    }]];
            }
#endif
            if ([[[ZoomVideoSDK shareInstance] getShareHelper] isScreenSharingOut]) {
                NSString *shareDiviceAudioString;
                BOOL isShareDdeviceAudio = [[[ZoomVideoSDK shareInstance] getShareHelper] isShareDeviceAudioEnabled];
                if (isShareDdeviceAudio) {
                    shareDiviceAudioString = @"Turn off Device Audio";
                } else {
                    shareDiviceAudioString = @"Turn on Device Audio";
                }
                
                
                [alertController addAction:[UIAlertAction actionWithTitle:shareDiviceAudioString
                                                                    style:UIAlertActionStyleDefault
                                                                  handler:^(UIAlertAction *action) {
                                                                            [[[ZoomVideoSDK shareInstance] getShareHelper] enableShareDeviceAudio:!isShareDdeviceAudio];
                                                             
                                                                  }]];
            }
        
            [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Send Command", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                [[[ZoomVideoSDK shareInstance] getCmdChannel] sendCommand:@"test" receiveUser:nil];
            }]];
            
            [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cloud  Recording", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                [self cloudRecording:sender];
            }]];
            
            [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:nil]];
            
            UIPopoverPresentationController *popover = alertController.popoverPresentationController;
            if (popover)
            {
                UIButton *btn = (UIButton*)sender;
                popover.sourceView = btn;
                popover.sourceRect = btn.bounds;
                popover.permittedArrowDirections = UIPopoverArrowDirectionAny;
            }
            [[appDelegate topViewController] presentViewController:alertController animated:YES completion:nil];
            break;
        }

        case kTagButtonVideo:
        {
            ZoomVideoSDKUser *myUser = [[[ZoomVideoSDK shareInstance] getSession] getMySelf];
            if (myUser.getVideoPipe.videoStatus.on) {
                [[[ZoomVideoSDK shareInstance] getVideoHelper] stopVideo];
                [_videoBtn setSelected:YES];
            } else {
                [[[ZoomVideoSDK shareInstance] getVideoHelper] startVideo];
                [_videoBtn setSelected:NO];
            }
            break;
        }
        case kTagButtonShare:
        {
            if (self.shareOnClickBlock) {
                self.shareOnClickBlock();
            }
            break;
        }
        case kTagButtonAudio:
        {
            ZoomVideoSDKUser *myUser = [[[ZoomVideoSDK shareInstance] getSession] getMySelf];
            if (myUser.audioStatus.audioType == ZoomVideoSDKAudioType_None) {
                [[[ZoomVideoSDK shareInstance] getAudioHelper] startAudio];
            } else {
                if (!myUser.audioStatus.isMuted) {
                    [[[ZoomVideoSDK shareInstance] getAudioHelper] muteAudio:myUser];
                } else {
                    [[[ZoomVideoSDK shareInstance] getAudioHelper] unmuteAudio:myUser];
                }
            }
        }
        default:
            break;
    }
}

- (void)cloudRecording:(UIButton *)sender
{
    NSLog(@"Cloud Recording::canStartRecording=====>%@",[[[ZoomVideoSDK shareInstance] getRecordingHelper] canStartRecording] == Errors_Success ? @"Can start recording" : @"can not start recording");
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil
                                                                             message:nil
                                                                      preferredStyle:UIAlertControllerStyleActionSheet];
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Start Recording", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        ZoomVideoSDKError error = [[[ZoomVideoSDK shareInstance] getRecordingHelper] startCloudRecording];
        NSLog(@"Cloud Recording::startCloudRecording=====>%@",error == Errors_Success ? @"succeed" : @"failed");
    }]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Stop Recording", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        ZoomVideoSDKError error = [[[ZoomVideoSDK shareInstance] getRecordingHelper] stopCloudRecording];
        NSLog(@"Cloud Recording::stopCloudRecording=====>%@",error == Errors_Success ? @"succeed" : @"failed");
    }]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Pause Recording", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        ZoomVideoSDKError error = [[[ZoomVideoSDK shareInstance] getRecordingHelper] pauseCloudRecording];
        NSLog(@"Cloud Recording::pauseCloudRecording=====>%@",error == Errors_Success ? @"succeed" : @"failed");
    }]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Resume Recording", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        ZoomVideoSDKError error = [[[ZoomVideoSDK shareInstance] getRecordingHelper] resumeCloudRecording];
        NSLog(@"Cloud Recording::resumeCloudRecording=====>%@",error == Errors_Success ? @"succeed" : @"failed");
    }]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:nil]];
    
    UIPopoverPresentationController *popover = alertController.popoverPresentationController;
    if (popover)
    {
        UIButton *btn = (UIButton*)sender;
        popover.sourceView = btn;
        popover.sourceRect = btn.bounds;
        popover.permittedArrowDirections = UIPopoverArrowDirectionAny;
    }
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [[appDelegate topViewController] presentViewController:alertController animated:YES completion:nil];
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


