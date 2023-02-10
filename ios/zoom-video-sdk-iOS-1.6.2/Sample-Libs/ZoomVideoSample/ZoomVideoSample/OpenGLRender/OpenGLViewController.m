//
//  OpenGLSessionViewController.m
//  ZoomVideoSample
//
//  Created by Zoom Video Communications on 2019/5/27.
//  Copyright © 2019 Zoom. All rights reserved.
//

#import "OpenGLViewController.h"
#import "TopBarView.h"
#import "ControlBar.h"
#import "ChatInputView.h"
#import "BottomBarView.h"
#import "ChatView.h"
#import "KGModal.h"
#import "AppDelegate.h"
#import <pthread.h>
#import <ReplayKit/ReplayKit.h>
#import "SwitchBtn.h"
#import "MoreMenuViewController.h"
#import "SimulateStorage.h"
#import "LowerThirdPanel.h"

#define kBroadcastPickerTag 10001

@interface OpenGLRawdataRenderer () <ZoomVideoSDKRawDataPipeDelegate>

@end

@implementation OpenGLRawdataRenderer

- (void)onRawDataFrameReceived:(ZoomVideoSDKVideoRawData *)rawData {
    if (!rawData) {
        return;
    }

    if ([rawData canAddRef]) {
        [rawData addRef];
    }
    if (self.isFullScreenDelegate) {
        [self updateStatisticInfo];
    }

    if (self.isFullScreenDelegate) {
        [self.openGLView displayYUV:rawData mode:DisplayMode_LetterBox mirror:YES];
    } else {
        [self.openGLView displayYUV:rawData mode:DisplayMode_PanAndScan mirror:YES];
    }
    
    if ([rawData canAddRef]) {
        [rawData releaseRef];
    }
}

- (void)onRawDataStatusChanged:(ZoomVideoSDKUserRawdataStatus)userRawdataStatus {
    if (userRawdataStatus == ZoomVideoSDKUserRawdataOn) {
        [self.openGLView removeAvatar];
    } else if (userRawdataStatus == ZoomVideoSDKUserRawdataOff) {
        [self.openGLView addAvatar];
    }
}

- (void)updateStatisticInfo {
    NSString *statisticStr = @"";
    if (self.dataType == ZoomVideoSDKVideoType_VideoData) {
        ZoomVideoSDKVideoStatisticInfo *info = [self.user getVideoStatisticInfo];
        statisticStr = [NSString stringWithFormat:@"%@x%@ %@FPS", @(info.width), @(info.height), @(info.fps)];
    } else {
        ZoomVideoSDKShareStatisticInfo *info = [self.user getShareStatisticInfo];
        statisticStr = [NSString stringWithFormat:@"%@x%@ %@FPS", @(info.width), @(info.height), @(info.fps)];
    }

    dispatch_async(dispatch_get_main_queue(), ^{
        if (![statisticStr isEqualToString:@"0x0 0FPS"]) {
            self.statisticLabel.hidden = NO;
            self.statisticLabel.text = statisticStr;
        } else {
            self.statisticLabel.hidden = YES;
            self.statisticLabel.text = statisticStr;
        }
    });
}
@end

@interface OpenGLViewController () <ZoomVideoSDKDelegate, BottomBarViewDelegate, ChatInputViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIScrollViewDelegate>
@property (strong, nonatomic) TopBarView              *topBarView;
@property (strong, nonatomic) ControlBar              *controlBarView;
@property (strong, nonatomic) ChatInputView           *chatInputView;
@property (strong, nonatomic) BottomBarView           *bottomView;
@property (strong, nonatomic) ChatView                *chatView;
@property (strong, nonatomic) SwitchBtn               *switchShareBtn;
@property (strong, nonatomic) LowerThirdPanel         *lowerThirdPanel;

@property (nonatomic, strong) UIView *shareView;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIImageView *selectImgView;
@property (nonatomic, strong) UIButton *stopShareBtn;

@property (nonatomic, strong) NSMutableArray <OpenGLRawdataRenderer *>*rendererArr;

@property (nonatomic, strong) OpenglView *multipUserView;
@property (nonatomic, strong) OpenGLRawdataRenderer *multipUserRenderer;

// audio
@property (nonatomic, copy) NSString *filePath;
@property (nonatomic, strong) NSTimer *speakerTimer;

@property (nonatomic, strong) UILabel *statisticLabel;

@property (nonatomic, assign) BOOL isReconnecting;

@end

@implementation OpenGLViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.rendererArr = [[NSMutableArray alloc] init];
    
    [ZoomVideoSDK shareInstance].delegate = self;
    
    [self initSubView];
        
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mySelfReactionAction:) name:Notification_mySelfReactionAction object:nil];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    OpenGLRawdataRenderer *fullRenderer = [self getFullViewRenderer];
    if (fullRenderer) {
        OpenglView *view = fullRenderer.openGLView;
        view.frame = self.view.bounds;
        [view setNeedsLayout];
    }
    
    [self.topBarView setNeedsLayout];
    [self.chatView setNeedsLayout];
    
    [self.controlBarView setNeedsLayout];
    if (_bottomView) {
        [self.bottomView setNeedsLayout];
    }
    
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    BOOL landscape = UIInterfaceOrientationIsLandscape(orientation);
    if (landscape) {
        if (orientation == UIInterfaceOrientationLandscapeRight && IPHONE_X) {
            self.switchShareBtn.frame = CGRectMake(SAFE_ZOOM_INSETS+10, Top_Height + 5, 180, 35);
            
        } else {
            self.switchShareBtn.frame = CGRectMake(8, Top_Height + 5, 180, 35);
        }
        self.statisticLabel.frame = CGRectMake(SCREEN_WIDTH - CGRectGetWidth(_topBarView.leaveBtn.frame) - 90 - 30, 23.5, 90, 25);
    } else {
        self.switchShareBtn.frame = CGRectMake(8, (IPHONE_X ? Top_Height + SAFE_ZOOM_INSETS : Top_Height) + 5, 180, 35);
        self.statisticLabel.frame = CGRectMake(SCREEN_WIDTH - 90 - 16, (IPHONE_X ? Top_Height + SAFE_ZOOM_INSETS : Top_Height), 90, 25);
    }

    [self updateLowerThird];
    
    self.shareView.frame = self.view.bounds;
    self.scrollView.frame = self.view.bounds;
    self.selectImgView.frame = self.view.bounds;

    CGFloat bottom = IPHONE_X ? (landscape ? 21.f : 34.f) : 0.0;
    CGFloat right = IPHONE_X ? 44.0 : 0.0;
    CGFloat width = 104.0;
    CGFloat height = 28.0;
    self.stopShareBtn.frame = CGRectMake(SCREEN_WIDTH - width - 16 - right, SCREEN_HEIGHT - 16 - height - bottom, width, height);
}

- (BOOL)shouldAutorotate{
    return YES;
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)sendAction:(NSString *)chatString
{
    NSLog(@"chatString===>%@",chatString);
    
    if (chatString.length == 0) {
        return;
    }
    
    [[[ZoomVideoSDK shareInstance] getChatHelper] SendChatToAll:chatString];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardDidHide:) name:UIKeyboardDidHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onDeviceOrientationChangeNotification:) name:UIDeviceOrientationDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onLowerThirdNotification:) name:kLowerThirdSavedNoti object:nil];
    
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    delegate.canRotation = YES;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [[UIDevice currentDevice] setValue:@(UIInterfaceOrientationPortrait) forKey:@"orientation"];
    [UIViewController attemptRotationToDeviceOrientation];
    
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    delegate.canRotation = NO;
}

- (void)dealloc {
    [UIApplication sharedApplication].idleTimerDisabled = NO;
    [ZoomVideoSDK shareInstance].delegate = nil;
    [[KGModal sharedInstance] hideAnimated:NO];
}

- (void)showReconnectingUI
{
    OpenGLRawdataRenderer *fullRenderer = [self getFullViewRenderer];
    [self stopThumbViewVideo];
    [self.rendererArr removeAllObjects];
    [self.bottomView removeAllThumberViewItem];
    
    ZoomVideoSDKSession *session = [[ZoomVideoSDK shareInstance] getSession];
    if (session) {
        ZoomVideoSDKUser *user = [session getMySelf];
        [user.getVideoPipe subscribeWithDelegate:fullRenderer resolution:ZoomVideoSDKVideoResolution_720];
        fullRenderer.dataType = ZoomVideoSDKVideoType_VideoData;
        fullRenderer.user = user;
        [self.rendererArr addObject:fullRenderer];
    }
    
    [UIView animateWithDuration:0.3 animations:^{
        [self.chatInputView removeFromSuperview];
        [self.chatView removeFromSuperview];
        [self.controlBarView removeFromSuperview];
        self.statisticLabel.alpha = 0.0;
    }];
    
    [self updateTitleIsJoined:NO];
    [self updateLowerThird];
}

- (void)initSubView {
    
    [self initfullScreenRender];
    
    __weak OpenGLViewController *weakSelf = self;
    [self updateTitleIsJoined:NO];
    
    self.topBarView.endOnClickBlock = ^(void) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Are you sure that you want to leave the session?"
                                                                                 message:nil
                                                                          preferredStyle:UIAlertControllerStyleActionSheet];
        
        [alertController addAction:[UIAlertAction actionWithTitle:@"Leave"
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction *action) {
                                                              [[ZoomVideoSDK shareInstance] leaveSession:NO];
                                                              [weakSelf dismissViewControllerAnimated:YES completion:nil];
                                                          }]];
        
        if ([[[[ZoomVideoSDK shareInstance] getSession] getMySelf] isHost]) {
            [alertController addAction:[UIAlertAction actionWithTitle:@"End Session"
                                                                style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction *action) {
                                                                  [[ZoomVideoSDK shareInstance] leaveSession:YES];
                                                              }]];
        }
        
        [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        }]];
        
        UIPopoverPresentationController *popover = alertController.popoverPresentationController;
        if (popover)
        {
            UIButton *btn = weakSelf.topBarView.leaveBtn;
            popover.sourceView = btn;
            popover.sourceRect = btn.bounds;
            popover.permittedArrowDirections = UIPopoverArrowDirectionAny;
        }
        AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        [[appDelegate topViewController] presentViewController:alertController animated:YES completion:nil];
    };
    self.topBarView.sessionInfoOnClickBlock = ^(void) {
        [weakSelf showSessionInfo];
    };
    
    self.lowerThirdPanel = [[LowerThirdPanel alloc] initWithFrame:CGRectMake(8, CGRectGetMaxY(self.topBarView.frame) + 12, 150, 60)];
    
    [self.view addSubview:self.switchShareBtn];
    [self.view addSubview:self.bottomView];
    [self.view addSubview:self.chatView];
    [self.view addSubview:self.statisticLabel];
    [self.view addSubview:self.lowerThirdPanel];
    
    self.chatInputView.hidden = YES;
}

- (void)initfullScreenRender {
    OpenglView *view = [[OpenglView alloc] initWithFrame:self.view.bounds];
    OpenGLRawdataRenderer *renderer = [[OpenGLRawdataRenderer alloc] init];
    renderer.isFullScreenDelegate = YES;
    renderer.dataType = ZoomVideoSDKVideoType_VideoData;
    renderer.openGLView = view;
    renderer.statisticLabel = self.statisticLabel;
    
    [self.view addSubview:view];
    view.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onSingleTap)];
    [view addGestureRecognizer:tapGesture];
    
    ZoomVideoSDKUser *user = [[[ZoomVideoSDK shareInstance] getSession] getMySelf];
    [user.getVideoPipe subscribeWithDelegate:renderer resolution:ZoomVideoSDKVideoResolution_720];
    
    renderer.user = user;
    [self.rendererArr addObject:renderer];
}

- (void)onSingleTap {
    
    if ([self.chatInputView.chatTextField isEditing]) {
        [self.chatInputView hideKeyBoard];
        return;
    }
    
    if (self.chatView.hidden == NO) {
        [UIView animateWithDuration:0.3 animations:^{
            self.chatView.hidden = YES;
            self.controlBarView.hidden = YES;
            self.statisticLabel.alpha = 0.0;
        }];
    } else {
        [UIView animateWithDuration:0.3 animations:^{
            self.chatView.hidden = NO;
            self.controlBarView.hidden = NO;
            self.statisticLabel.alpha = 1.0;
        }];
    }
}

- (void)leave
{
    OpenGLRawdataRenderer *fullRenderer = [self getFullViewRenderer];
    if (fullRenderer) {
        if (fullRenderer.dataType == ZoomVideoSDKVideoType_ShareData) {
            [fullRenderer.user.getSharePipe unSubscribeWithDelegate:fullRenderer];
        } else {
            [fullRenderer.user.getVideoPipe unSubscribeWithDelegate:fullRenderer];
        }
        [self.rendererArr removeObject:fullRenderer];
    }
    
    [self stopThumbViewVideo];
    [self.bottomView removeAllThumberViewItem];
    [self.rendererArr removeAllObjects];
    
    [[SimulateStorage shareInstance] clearUp];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)noVideofailBack {
    ZoomVideoSDKUser *user = [[[ZoomVideoSDK shareInstance] getSession] getMySelf];
    OpenGLRawdataRenderer *fullRenderer = [self getFullViewRenderer];
    if (fullRenderer) {
        [user.getVideoPipe unSubscribeWithDelegate:fullRenderer];
        fullRenderer.user = user;
        fullRenderer.dataType = ZoomVideoSDKVideoType_VideoData;
    } else {
        OpenglView *view = [[OpenglView alloc] initWithFrame:self.view.bounds];
        OpenGLRawdataRenderer *renderer = [[OpenGLRawdataRenderer alloc] init];
        renderer.isFullScreenDelegate = YES;
        renderer.openGLView = view;
        renderer.user = user;
        renderer.statisticLabel = self.statisticLabel;
        
        if (user.getVideoPipe.shareStatus.sharingStatus == ZoomVideoSDKReceiveSharingStatus_Start) {
            renderer.dataType = ZoomVideoSDKVideoType_ShareData;
            [user.getVideoPipe subscribeWithDelegate:renderer resolution:ZoomVideoSDKVideoResolution_720];
        } else {
            renderer.dataType = ZoomVideoSDKVideoType_VideoData;
            [user.getVideoPipe subscribeWithDelegate:renderer resolution:ZoomVideoSDKVideoResolution_720];
        }
    }
    [self updateLowerThird];
}

- (void)addThumberViewWithArr:(NSArray *)userArray helper:(ZoomVideoSDKUserHelper *)helper {
    
    NSUInteger canSubNum = userArray.count;
    if (userArray.count > 3) {
        canSubNum = 3;
    }
    for (int i = 0; i < userArray.count; i++) {
        ZoomVideoSDKUser *user = userArray[i];
        OpenGLRawdataRenderer *thumbRenderer = [self getThumbRendererForUser:user];
        if (thumbRenderer) {
            continue;
        }
        
        OpenglView *view = [[OpenglView alloc] initWithFrame:CGRectZero];
        thumbRenderer = [[OpenGLRawdataRenderer alloc] init];
        thumbRenderer.isFullScreenDelegate = NO;
        thumbRenderer.openGLView = view;
        thumbRenderer.user = user;
        thumbRenderer.dataType = ZoomVideoSDKVideoType_VideoData;
        [self.rendererArr addObject:thumbRenderer];

        if (i < canSubNum) {
            [user.getVideoPipe subscribeWithDelegate:thumbRenderer resolution:ZoomVideoSDKVideoResolution_90];
        }
        
        ViewItem *item = [[ViewItem alloc] init];
        item.user = user;
        item.view = view;
        item.isActive = NO;
        item.itemName = user.getUserName;

        [self.bottomView addThumberViewItem:item];
        
        if (!helper) {
            [self viewItemSelected:item];
        }
    }

    [self.view insertSubview:self.controlBarView aboveSubview:self.bottomView];
}

- (void)showSessionInfo {
    NSLog(@"showSessionInfo");
    [[KGModal sharedInstance] setModalBackgroundColor:[UIColor whiteColor]];
    [[KGModal sharedInstance] setCloseButtonType:KGModalCloseButtonTypeNone];
    [[KGModal sharedInstance] setTapOutsideToDismiss:YES];
    [[KGModal sharedInstance] showWithContentView:[self alertViewOfSessionInfo] andAnimated:YES];
}

- (UIView*)alertViewOfSessionInfo {
    UIView *dialogView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 280, 237)];
    dialogView.layer.masksToBounds = YES;
    
    NSArray *userArr = [[[ZoomVideoSDK shareInstance] getSession] getRemoteUsers];
    ZoomVideoSDKSession *session = [[ZoomVideoSDK shareInstance] getSession];
    
    //Title Label
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(24, 21, 256, 24)];
    titleLabel.text = NSLocalizedString(@"Session Information", @"");
    titleLabel.textColor = RGBCOLOR(0x23, 0x23, 0x23);
    titleLabel.textAlignment = NSTextAlignmentLeft;
    titleLabel.font = [UIFont boldSystemFontOfSize:20];
    [dialogView addSubview:titleLabel];
    
    UILabel *sessionNameTitle = [[UILabel alloc] initWithFrame:CGRectMake(24, CGRectGetMaxY(titleLabel.frame) + 25, 256, 20)];
    sessionNameTitle.text = NSLocalizedString(@"Session name", @"");
    sessionNameTitle.textColor = RGBCOLOR(0x74, 0x74, 0x87);
    sessionNameTitle.textAlignment = NSTextAlignmentLeft;
    sessionNameTitle.font = [UIFont systemFontOfSize:12.0];
    [dialogView addSubview:sessionNameTitle];
    
    UILabel *sessionNameValue = [[UILabel alloc] initWithFrame:CGRectMake(24, CGRectGetMaxY(sessionNameTitle.frame), 256, 16)];
    sessionNameValue.text = session.getSessionName;
    sessionNameValue.textColor = RGBCOLOR(0x23, 0x23, 0x23);
    sessionNameValue.textAlignment = NSTextAlignmentLeft;
    sessionNameValue.font = [UIFont boldSystemFontOfSize:16.0];
    [dialogView addSubview:sessionNameValue];
    
    UILabel *pswTitle = [[UILabel alloc] initWithFrame:CGRectMake(24, CGRectGetMaxY(sessionNameValue.frame) + 20, 256, 20)];
    pswTitle.text = NSLocalizedString(@"Password", @"");
    pswTitle.textColor = RGBCOLOR(0x74, 0x74, 0x87);
    pswTitle.textAlignment = NSTextAlignmentLeft;
    pswTitle.font = [UIFont systemFontOfSize:12.0];
    [dialogView addSubview:pswTitle];
    
    BOOL hasPassword = (session.getSessionPassword && ![session.getSessionPassword isEqualToString:@""]);
    UILabel *pswValue = [[UILabel alloc] initWithFrame:CGRectMake(24, CGRectGetMaxY(pswTitle.frame), 256, 16)];
    pswValue.text = hasPassword ? session.getSessionPassword : @"Not Set";
    pswValue.textColor = hasPassword ? RGBCOLOR(0x23, 0x23, 0x23) : RGBCOLOR(0x74, 0x74, 0x87);
    pswValue.textAlignment = NSTextAlignmentLeft;
    pswValue.font = [UIFont boldSystemFontOfSize:16.0];
    [dialogView addSubview:pswValue];
    
    UILabel *participantsTitle = [[UILabel alloc] initWithFrame:CGRectMake(24, CGRectGetMaxY(pswValue.frame) + 20, 256, 20)];
    participantsTitle.text = NSLocalizedString(@"Participants", @"");
    participantsTitle.textColor = RGBCOLOR(0x74, 0x74, 0x87);
    participantsTitle.textAlignment = NSTextAlignmentLeft;
    participantsTitle.font = [UIFont systemFontOfSize:12.0];
    [dialogView addSubview:participantsTitle];
    
    NSUInteger count = userArr.count + 1;
    UILabel *pValue = [[UILabel alloc] initWithFrame:CGRectMake(24, CGRectGetMaxY(participantsTitle.frame), 256, 16)];
    pValue.text = [NSString stringWithFormat:@"%@", @(count)];
    pValue.textColor = RGBCOLOR(0x23, 0x23, 0x23);
    pValue.textAlignment = NSTextAlignmentLeft;
    pValue.font = [UIFont boldSystemFontOfSize:16.0];
    [dialogView addSubview:pValue];
    
    return dialogView;
}

- (void)showShareOptionView {
    UIAlertController *sheet = [UIAlertController alertControllerWithTitle:@"Share" message:nil preferredStyle: UIAlertControllerStyleActionSheet];
    if (@available(iOS 11.0, *)) {
        [sheet addAction:[UIAlertAction actionWithTitle:@"Share Device Screen"
                                                  style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                                                    if ([[[ZoomVideoSDK shareInstance] getShareHelper] isShareLocked]) {
                                                        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                                                        hud.mode = MBProgressHUDModeText;
                                                        hud.label.text = @"Share is locked by admin";
                                                        // Move to bottm center.
                                                        hud.offset = CGPointMake(0.f, MBProgressMaxOffset);
                                                        [hud hideAnimated:YES afterDelay:2.f];
                                                        return;
                                                    }
                                                    if ([[[ZoomVideoSDK shareInstance] getShareHelper] isOtherSharing]) {
                                                        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                                                        hud.mode = MBProgressHUDModeText;
                                                        hud.label.text = @"Some one is alerady sharing";
                                                        // Move to bottm center.
                                                        hud.offset = CGPointMake(0.f, MBProgressMaxOffset);
                                                        [hud hideAnimated:YES afterDelay:2.f];
                                                        return;
                                                    }
                                                      
                                                    if (@available(iOS 12.0, *)) {
                                                        RPSystemBroadcastPickerView *broadcastView = [[RPSystemBroadcastPickerView alloc] init];
                                                        broadcastView.preferredExtension = kScreenShareBundleId;
                                                        broadcastView.tag = kBroadcastPickerTag;
                                                        [self.view addSubview:broadcastView];
                                                        [self sendTouchDownEventToBroadcastButton];
                                                    } else {
                                                        // Guide page
                                                    }
                                                  }]];
    }
    [sheet addAction:[UIAlertAction actionWithTitle:@"Share a Picture"
                                              style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                                                  [UIView animateWithDuration: 0. delay: 0 options: UIViewAnimationOptionLayoutSubviews  animations:^{

                                                  } completion:^(BOOL finished){
                                                      BOOL isOtherSharing = [[[ZoomVideoSDK shareInstance] getShareHelper] isOtherSharing];
                                                      if (isOtherSharing) {
                                                          MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                                                          hud.mode = MBProgressHUDModeText;
                                                          hud.label.text = @"Others are sharing";
                                                          // Move to bottm center.
                                                          hud.offset = CGPointMake(0.f, MBProgressMaxOffset);
                                                          [hud hideAnimated:YES afterDelay:2.f];
                                                          return;
                                                      }
                                                      
                                                      UIImagePickerController *controller = [[UIImagePickerController alloc] init];
                                                      controller.delegate = self;
                                                      controller.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                                                      [self presentViewController:controller animated:YES completion:NULL];
                                                  } ];
                                              }]];
    [sheet addAction:[UIAlertAction actionWithTitle:@"Close" style:UIAlertActionStyleCancel handler:nil]];
    
    UIPopoverPresentationController *popover = sheet.popoverPresentationController;
    if (popover)
    {
        UIButton *btn = (UIButton*)self.controlBarView.shareBtn;
        popover.sourceView = btn;
        popover.sourceRect = btn.bounds;
        popover.permittedArrowDirections = UIPopoverArrowDirectionAny;
    }
    
    [self presentViewController:sheet animated:YES completion:nil];
}

- (void)sendTouchDownEventToBroadcastButton
{
    if (@available(iOS 12.0, *)) {
        RPSystemBroadcastPickerView *broadcastView = [self.view viewWithTag:kBroadcastPickerTag];
        if (!broadcastView) return;

        
        for (UIView *subView in broadcastView.subviews) {
            if ([subView isKindOfClass:[UIButton class]])
            {
                UIButton *broadcastBtn = (UIButton *)subView;
                [broadcastBtn sendActionsForControlEvents:UIControlEventAllTouchEvents];
                break;
            }
        }
    }
}

#pragma mark - for view tool -
- (void)updateTitleIsJoined:(BOOL)isJoined
{
    BOOL beforeSession = NO;
    ZoomVideoSDKSession *session = [[ZoomVideoSDK shareInstance] getSession];
    if (!session) {
        beforeSession = YES;
    }
    
    if (beforeSession) {
        [self.topBarView updateTopBarWithSessionName:session.getSessionName totalNum:1 password:session.getSessionPassword isJoined:isJoined];
    } else {
        NSArray *allUsers = [session getRemoteUsers]; // all remote user(Except me).
        [self.topBarView updateTopBarWithSessionName:session.getSessionName totalNum:allUsers.count+1 password:session.getSessionPassword isJoined:isJoined];
    }
}

- (OpenGLRawdataRenderer *)getFullViewRenderer
{
    for (OpenGLRawdataRenderer *renderer in self.rendererArr) {
        if (renderer.isFullScreenDelegate) {
            return renderer;
        }
    }
    return nil;
}

- (OpenGLRawdataRenderer *)getThumbRendererForUser:(ZoomVideoSDKUser *)user
{
    for (OpenGLRawdataRenderer *renderer in self.rendererArr) {
        if (!renderer.isFullScreenDelegate && renderer.user == user) {
            return renderer;
        }
    }
    return nil;
}

- (void)removeThumbRendererForUser:(ZoomVideoSDKUser *)user
{
    OpenGLRawdataRenderer *removeRenderer = nil;
    for (OpenGLRawdataRenderer *renderer in self.rendererArr) {
        if (!renderer.isFullScreenDelegate && renderer.user == user) {
            removeRenderer = renderer;
        }
    }

    if (removeRenderer) [self.rendererArr removeObject:removeRenderer];
}

#pragma mark - singleton -
- (TopBarView *)topBarView {
    if (!_topBarView) {
        _topBarView = [[TopBarView alloc] init];
        [self.view addSubview:self.topBarView];
    }
    return _topBarView;
}

- (ChatInputView *)chatInputView {
    if (!_chatInputView) {
        _chatInputView = [[ChatInputView alloc] initWithView:self.view];
        _chatInputView.delegate = self;
    }
    
    return _chatInputView;
}


- (ChatView *)chatView {
    if (!_chatView) {
        _chatView = [[ChatView alloc] init];
        _chatView.userInteractionEnabled = YES;
        UITapGestureRecognizer * tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onSingleTap)];
        [_chatView addGestureRecognizer:tapGesture];
    }
    
    return _chatView;
}

- (BottomBarView *)bottomView {
    if (!_bottomView) {
        _bottomView = [[BottomBarView alloc] initWithDelegate:self];
        _bottomView.frame = CGRectMake(0, SCREEN_HEIGHT - kTableHeight, SCREEN_WIDTH, kTableHeight);
        [self.view addSubview:_bottomView];
    }
    
    return _bottomView;
}

- (ControlBar *)controlBarView {
    if (!_controlBarView) {
        _controlBarView = [[ControlBar alloc] init];
        __weak OpenGLViewController *weakSelf = self;
        _controlBarView.chatOnClickBlock = ^(void) {
            [weakSelf.chatInputView showKeyBoard];
        };
        _controlBarView.shareOnClickBlock = ^(void) {
            if ([[[ZoomVideoSDK shareInstance] getShareHelper] isShareLocked]) {
                MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:weakSelf.view animated:YES];
                hud.mode = MBProgressHUDModeText;
                hud.label.text = @"Share is locked by admin";
                // Move to bottm center.
                hud.offset = CGPointMake(0.f, MBProgressMaxOffset);
                [hud hideAnimated:YES afterDelay:2.f];
                return;
            }
            if ([[[ZoomVideoSDK shareInstance] getShareHelper] isOtherSharing]) {
                MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:weakSelf.view animated:YES];
                hud.mode = MBProgressHUDModeText;
                hud.label.text = @"Some one is alerady sharing";
                // Move to bottm center.
                hud.offset = CGPointMake(0.f, MBProgressMaxOffset);
                [hud hideAnimated:YES afterDelay:2.f];
                return;
            }
            [weakSelf showShareOptionView];
        };
    }
    return _controlBarView;
}

- (SwitchBtn *)switchShareBtn {
    if (!_switchShareBtn) {
        _switchShareBtn = [[SwitchBtn alloc] initWithFrame:CGRectZero];
        [_switchShareBtn setTitle:@"Switch to Share" forState:UIControlStateNormal];
        _switchShareBtn.titleLabel.font = [UIFont boldSystemFontOfSize:15];
        [_switchShareBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _switchShareBtn.backgroundColor = [UIColor colorWithWhite:0 alpha:0.6];
        _switchShareBtn.clipsToBounds = YES;
        _switchShareBtn.layer.cornerRadius = 6;
        [_switchShareBtn addTarget:self action:@selector(switchToShare:) forControlEvents:UIControlEventTouchUpInside];
        _switchShareBtn.hidden = YES;
    }
    
    return _switchShareBtn;
}

- (UILabel *)statisticLabel {
    if (!_statisticLabel) {
        _statisticLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _statisticLabel.backgroundColor = [UIColor colorWithWhite:0 alpha:0.6];
        _statisticLabel.font = [UIFont systemFontOfSize:9.0];
        _statisticLabel.textColor = [UIColor whiteColor];
        _statisticLabel.numberOfLines = 1;
        _statisticLabel.textAlignment = 1;
        _statisticLabel.clipsToBounds = YES;
        _statisticLabel.layer.cornerRadius = 6.0;
        _statisticLabel.hidden = YES;
    }
    return _statisticLabel;
}

#pragma mark - uiimagepicker delegate -
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    self.shareView = [[UIView alloc] initWithFrame:self.view.bounds];
    UIImage *selectPic = info[UIImagePickerControllerOriginalImage];
    self.scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    self.scrollView.backgroundColor = [UIColor blackColor];
    self.scrollView.delegate = self;
    self.scrollView.bounces = NO;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.minimumZoomScale = 1.0;
    self.scrollView.maximumZoomScale = 3.0;
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleShareTap:)];
    doubleTap.numberOfTapsRequired = 2;
    doubleTap.numberOfTouchesRequired = 1;
    [self.scrollView addGestureRecognizer:doubleTap];
    
    self.selectImgView = [[UIImageView alloc] initWithImage:selectPic];
    self.selectImgView.contentMode = UIViewContentModeScaleAspectFit;
    self.selectImgView.frame = self.view.bounds;
    
    [self.scrollView addSubview:self.selectImgView];
    [self.shareView addSubview:self.scrollView];
    [self.view addSubview:self.shareView];
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    BOOL landscape = UIInterfaceOrientationIsLandscape(orientation);
    CGFloat bottom = IPHONE_X ? (landscape ? 21.f : 34.f) : 0.0;
    CGFloat right = IPHONE_X ? 44.0 : 0.0;
    CGFloat width = 104.0;
    CGFloat height = 28.0;
    
    self.stopShareBtn = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - width - 16 - right, SCREEN_HEIGHT - 16 - height - bottom, width, height)];
    [self.stopShareBtn setTitle:@"STOP SHARE" forState:UIControlStateNormal];
    self.stopShareBtn.clipsToBounds = YES;
    self.stopShareBtn.layer.cornerRadius = height * 0.5;
    self.stopShareBtn.titleLabel.font = [UIFont systemFontOfSize:12.0];
    self.stopShareBtn.backgroundColor = [UIColor redColor];
    [self.stopShareBtn addTarget:self action:@selector(stopShareBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.stopShareBtn];
    
    [[[ZoomVideoSDK shareInstance] getShareHelper] startShareWithView:self.shareView];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - for share -
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.selectImgView;
}

- (void)handleDoubleShareTap:(UIGestureRecognizer *)gestureRecognizer
{
    CGFloat zs = self.scrollView.zoomScale;
    zs = (zs == self.scrollView.minimumZoomScale) ? self.scrollView.maximumZoomScale : self.scrollView.minimumZoomScale;
    CGRect zoomRect = [self zoomRectForScale: zs withCenter: [gestureRecognizer locationInView: gestureRecognizer.view]];
    [self.scrollView zoomToRect: zoomRect animated: YES];
}

- (CGRect)zoomRectForScale:(float)scale withCenter:(CGPoint)center
{
    CGRect zoomRect;
    
    CGFloat w = [self.scrollView frame].size.width;
    CGFloat h = [self.scrollView frame].size.height;
    zoomRect.size.height = h / scale;
    zoomRect.size.width  = w / scale;
    
    CGFloat x = center.x - (zoomRect.size.width  / 2.0);
    CGFloat y = center.y - (zoomRect.size.height / 2.0);
    
    CGSize shareSource = self.view.bounds.size;
    CGFloat offsetX = fabs(shareSource.width / scale - w) / 2;
    CGFloat offsetY = fabs(shareSource.height / scale - h) / 2;
    if (x < offsetX) x = 0;
    if (y < offsetY) y = 0;
    if (x > offsetX && (x + zoomRect.size.width) * scale > shareSource.width) x = (shareSource.width - w) / scale;
    if (y > offsetY && (y + zoomRect.size.height) * scale > shareSource.height) y = (shareSource.height - h) / scale;
    zoomRect.origin.x = x;
    zoomRect.origin.y = y;
    
    return zoomRect;
}

- (void)stopShareBtnClicked:(id)sender {
    NSLog(@"stop share");
    [self.shareView removeFromSuperview];
    [self.stopShareBtn removeFromSuperview];
    [[[ZoomVideoSDK shareInstance] getShareHelper] stopShare];
    
    [self pinMyself];
}


#pragma mark - ZoomVideoSDK delegate -
- (void)onError:(ZoomVideoSDKError)ErrorType detail:(NSInteger)details
{
    NSLog(@"ErrorType========%@, %@",@(ErrorType), [self formatErrorString:ErrorType]);
    NSLog(@"ErrorDetails========%@",@(details));
    
    switch (ErrorType) {
        case Errors_Session_Join_Failed:
        {
            [self leave];
        }
            break;
        case Errors_Session_Disconncting:
        {
        }
            break;
        case Errors_Session_Reconncting:
        {
            [self showReconnectingUI];
            self.isReconnecting = YES;
        }
            break;
        default:
            break;
    }
    
    NSString *string = [self formatErrorString:ErrorType];
    if (string) {
        string = [string stringByAppendingFormat:@". Error code: %@", @(details)];
        UIWindow *window = [[UIApplication sharedApplication].windows lastObject];
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:window animated:YES];
        hud.mode = MBProgressHUDModeText;
        hud.label.text = string;
        hud.offset = CGPointMake(0.f, MBProgressMaxOffset);
        [hud hideAnimated:YES afterDelay:4.f];
    }
}

- (void)onSessionJoin {
    NSLog(@"onSessionJoin====>");
    [self.view addSubview:self.controlBarView];
    [self.view addSubview:self.chatInputView];
    self.chatInputView.hidden = NO;
    [self.view addSubview:self.chatView];
    
    [self updateTitleIsJoined:YES];
    
    if (self.isReconnecting) {
        OpenGLRawdataRenderer *fullRenderer = [self getFullViewRenderer];
        [fullRenderer.user.getVideoPipe subscribeWithDelegate:fullRenderer resolution:ZoomVideoSDKVideoResolution_720];
        self.isReconnecting = NO;
    }
    
    ZoomVideoSDKUser *mySelf = [[[ZoomVideoSDK shareInstance] getSession] getMySelf];
    if (mySelf) {
        [self onUserJoin:nil users:@[mySelf]];
    }
}

- (void)onSessionLeave {
    NSLog(@"onSessionLeave====>");

    [self leave];
}

- (void)onUserJoin:(ZoomVideoSDKUserHelper *)helper users:(NSArray<ZoomVideoSDKUser *> *)userArray {
    NSLog(@"onUserJoin====>");
    
    [self addThumberViewWithArr:userArray helper:helper];
    
    [self updateTitleIsJoined:YES];
}

- (void)onUserLeave:(ZoomVideoSDKUserHelper *)helper users:(NSArray<ZoomVideoSDKUser *> *)userArray{
    OpenGLRawdataRenderer *fullRenderer = [self getFullViewRenderer];
    for (int i = 0; i < userArray.count; i++) {
        ZoomVideoSDKUser *user = userArray[i];
        
        OpenGLRawdataRenderer *renderer = [self getThumbRendererForUser:user];
        if (renderer) {
            [user.getVideoPipe unSubscribeWithDelegate:renderer];
            [self removeThumbRendererForUser:user];
        }

        [self.bottomView removeThumberViewItemWithUser:user];
        
        if ([user isEqual:fullRenderer.user]) {
             [self pinMyself];
        }
    }
    
    [self updateTitleIsJoined:YES];
}

- (void)onUserVideoStatusChanged:(ZoomVideoSDKVideoHelper *)helper user:(NSArray<ZoomVideoSDKUser *> *)userArray{
    NSLog(@"onUserVideoStatusChanged====>: %@", userArray);
}

- (void)onUserShareStatusChanged:(ZoomVideoSDKShareHelper *)helper user:(ZoomVideoSDKUser *)user status:(ZoomVideoSDKReceiveSharingStatus)status
{
    NSLog(@"onUserShareStatusChanged====>%@, %@", user, @(status));
    ZoomVideoSDKUser *myUser = [[[ZoomVideoSDK shareInstance] getSession] getMySelf];
    if (user == myUser) {
        return;
    }
    OpenGLRawdataRenderer *fullRenderer = [self getFullViewRenderer];
    [fullRenderer.openGLView removeAvatar];
    
    if (status == ZoomVideoSDKReceiveSharingStatus_Stop ||
        status == ZoomVideoSDKReceiveSharingStatus_None) {
        [fullRenderer.openGLView clearFrame];
        
        if (!user.getVideoPipe.videoStatus.on && (user.getVideoPipe.shareStatus.sharingStatus != ZoomVideoSDKReceiveSharingStatus_Start)) {
            [fullRenderer.openGLView addAvatar];
        }
    }
    
    fullRenderer.user = user;
    OpenGLRawdataRenderer *thumbRenderer = [self getThumbRendererForUser:user];
    if (thumbRenderer) {
        [user.getVideoPipe subscribeWithDelegate:thumbRenderer resolution:ZoomVideoSDKVideoResolution_90];
    }
    if (status == ZoomVideoSDKReceiveSharingStatus_Start) {
        self.switchShareBtn.sharedUser = user;
        
        fullRenderer.dataType = ZoomVideoSDKVideoType_ShareData;
        [user.getSharePipe subscribeWithDelegate:fullRenderer resolution:ZoomVideoSDKVideoResolution_720];
        
        NSArray *viewItems = [self.bottomView getThumberViewItems:user];
        ViewItem *item = [viewItems firstObject];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self stopThumbViewVideo];
            [self.bottomView scrollToVisibleArea:item];
        });
    } else if (status == ZoomVideoSDKReceiveSharingStatus_Stop) {
        self.switchShareBtn.sharedUser = nil;
        fullRenderer.dataType = ZoomVideoSDKVideoType_VideoData;
        [user.getVideoPipe subscribeWithDelegate:fullRenderer resolution:ZoomVideoSDKVideoResolution_720];
    }
    
    for (ViewItem *item in self.bottomView.viewArray) {
        if ([user isEqual:item.user]) {
            [self viewItemSelected:item];
        }
    }
    self.switchShareBtn.hidden = YES;
    [self updateLowerThird];
}

- (void)onUserActiveAudioChanged:(ZoomVideoSDKUserHelper *)helper users:(NSArray<ZoomVideoSDKUser *> *)userArray {
    for (ZoomVideoSDKUser *user in userArray) {
        [self.bottomView activeThumberViewItem:user];
    }

    [self startSpeakerTimer];
}

- (void)onUserAudioStatusChanged:(ZoomVideoSDKAudioHelper *)helper user:(NSArray<ZoomVideoSDKUser *> *)userArray {
// can update audio UI here
    ZoomVideoSDKUser *myUser = [[[ZoomVideoSDK shareInstance] getSession] getMySelf];
    for (ZoomVideoSDKUser *user in userArray) {
        if ([user isEqual:myUser]) {
            if (user.audioStatus.audioType == ZoomVideoSDKAudioType_None) {
                [self.controlBarView.audioBtn setImage:[UIImage imageNamed:@"icon_no_audio"] forState:UIControlStateNormal];
            } else {
                if (!user.audioStatus.isMuted) {
                    [self.controlBarView.audioBtn setImage:[UIImage imageNamed:@"icon_mute"] forState:UIControlStateNormal];
                } else {
                    [self.controlBarView.audioBtn setImage:[UIImage imageNamed:@"icon_unmute"] forState:UIControlStateNormal];
                }
            }
        }
    }
}

- (void)onChatNewMessageNotify:(ZoomVideoSDKChatHelper *)helper message:(ZoomVideoSDKChatMessage *)msg{
    [self.chatView.chatMsgArray addObject:msg];
    [self.chatView.tableView reloadData];
    [self.chatView scrollToBottom];
}

- (void)onSessionNeedPassword:(ZoomVideoSDKError (^)(NSString *password, BOOL leaveSessionIgnorePassword))completion
{
    if (completion) {
        self.joinSessionOrIgnorePasswordBlock = completion;
        
        [self showZoomPasswordAlert:NO];
    }
}

- (void)onSessionPasswordWrong:(ZoomVideoSDKError (^)(NSString *password, BOOL leaveSessionIgnorePassword))completion
{
    if (completion) {
        self.joinSessionOrIgnorePasswordBlock = completion;
        
        [self showZoomPasswordAlert:YES];
    }
}

- (void)onUserHostChanged:(ZoomVideoSDKUserHelper * _Nullable)helper users:(ZoomVideoSDKUser * _Nullable)user
{
    if ([[[[ZoomVideoSDK shareInstance] getSession] getMySelf] isHost]) {
        [[SimulateStorage shareInstance] initFeedbackItem];
    }
}

- (void)onMultiCameraStreamStatusChanged:(ZoomVideoSDKMultiCameraStreamStatus)status parentUser:(ZoomVideoSDKUser *)user videoPipe:(ZoomVideoSDKRawDataPipe *)videoPipe
{
    if (status == ZoomVideoSDKMultiCameraStreamStatus_Joined) {
        self.multipUserView = [[OpenglView alloc] initWithFrame:CGRectMake(100, 100, kTableHeight - 15 * 2, kCellHeight - 10)];
        self.multipUserRenderer = [[OpenGLRawdataRenderer alloc] init];
        self.multipUserRenderer.isFullScreenDelegate = NO;
        self.multipUserRenderer.openGLView = self.multipUserView;
        self.multipUserRenderer.user = user;
        self.multipUserRenderer.dataType = ZoomVideoSDKVideoType_VideoData;
        
        [videoPipe subscribeWithDelegate:self.multipUserRenderer resolution:ZoomVideoSDKVideoResolution_90];
        
        OpenGLRawdataRenderer *fullRenderer = [self getFullViewRenderer];
        [fullRenderer.openGLView addSubview:self.multipUserView];
    } else {
        [videoPipe unSubscribeWithDelegate:self.multipUserRenderer];
        [self.multipUserView removeFromSuperview];
    }
}

- (void)onSystemPermissionRequired:(ZoomVideoSDKSystemPermissionType)permissionType
{
    
    NSString *alertTitle = @"system permission needed";
    switch (permissionType) {
        case ZoomVideoSDKSystemPermissionType_Camera:
            alertTitle = @"Can't Access Camera";
            break;
        case ZoomVideoSDKSystemPermissionType_Microphone:
            alertTitle = @"Can't Access Microphone";
            break;
        default:
            break;
    }
    NSString *alertMsg = @"please turn on the toggle in system settings to grant permission";
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:alertTitle
                                                                             message:alertMsg
                                                                      preferredStyle:UIAlertControllerStyleAlert];

    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)showZoomPasswordAlert:(BOOL)wrongPwd
{
    NSString *message = wrongPwd ? NSLocalizedString(@"Incorrect password, please try again", @"") : NSLocalizedString(@"Please enter your password", @"");
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:message delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Join", nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    
    [alert show];
}

#pragma mark - audio rawdata delegate -
- (void)onMixedAudioRawDataReceived:(ZoomVideoSDKAudioRawData *)rawData
{
    NSLog(@"onMixedAudioRawDataReceived %@", rawData);
}

- (void)onOneWayAudioRawDataReceived:(ZoomVideoSDKAudioRawData *)rawData user:(ZoomVideoSDKUser *)user
{
    NSLog(@"onOneWayAudioRawDataReceived %@", rawData);
}

- (void)onSharedAudioRawDataReceived:(ZoomVideoSDKAudioRawData *)rawData
{
    NSLog(@"onSharedAudioRawDataReceived %@", rawData);
}

#pragma mark - BottomBarViewDelegate -
- (void)stopThumbViewVideo {
    for (OpenGLRawdataRenderer *renderer in self.rendererArr) {
        if (renderer.isFullScreenDelegate) {
            continue;
        }
        if (renderer.dataType == ZoomVideoSDKVideoType_ShareData) {
            [renderer.user.getSharePipe unSubscribeWithDelegate:renderer];
        } else {
            [renderer.user.getVideoPipe unSubscribeWithDelegate:renderer];
        }
    }
}

- (void)startThumbViewVideo {
    NSArray <UITableViewCell *> *cellArray = self.bottomView.thumbTableView.visibleCells;
    for (int i = 0; i < cellArray.count; i++) {
        UITableViewCell *cell = [cellArray objectAtIndex:i];
        NSIndexPath *indexPath = [self.bottomView.thumbTableView indexPathForCell:cell];
        
        ViewItem *item = [self.bottomView.viewArray objectAtIndex:indexPath.row];
        
        for (OpenGLRawdataRenderer *renderer in self.rendererArr) {
            if (renderer.isFullScreenDelegate) {
                continue;
            }
            if ([renderer.user isEqual:item.user]) {
                [renderer.user.getVideoPipe subscribeWithDelegate:renderer resolution:ZoomVideoSDKVideoResolution_90];
            }
        }
    }
}

- (void)pinThumberViewItem:(ViewItem *)item {
    
    if (!item) {
        return;
    }
    [self viewItemSelected:item];
    
    ZoomVideoSDKUser *user = item.user;
    OpenGLRawdataRenderer *fullRenderer = [self getFullViewRenderer];
    
    if (fullRenderer.dataType == ZoomVideoSDKVideoType_ShareData) {
        [fullRenderer.user.getSharePipe unSubscribeWithDelegate:fullRenderer];
    } else {
        [fullRenderer.user.getVideoPipe unSubscribeWithDelegate:fullRenderer];
    }
    
    if (user && fullRenderer) {
        fullRenderer.user = user;
        fullRenderer.dataType = ZoomVideoSDKVideoType_VideoData;
        [user.getVideoPipe subscribeWithDelegate:fullRenderer resolution:ZoomVideoSDKVideoResolution_720];
    }
        
    [self updateTitleIsJoined:YES];
    
    if (self.switchShareBtn.sharedUser) {
        self.switchShareBtn.hidden = NO;
    }
    
    [self updateLowerThird];
}

- (void)scrollToThumberViewItem:(ViewItem *)item {
    if (!item) {
        return;
    }

    for (OpenGLRawdataRenderer *renderer in self.rendererArr) {
        if (renderer.isFullScreenDelegate) {
            continue;
        }
        if ([renderer.user isEqual:item.user]) {
            [[renderer.user getVideoPipe] subscribeWithDelegate:renderer resolution:ZoomVideoSDKVideoResolution_90];
        }
    }
}

- (void)pinMyself {
    ZoomVideoSDKUser *myUser = [[[ZoomVideoSDK shareInstance] getSession] getMySelf];
    for (ViewItem *item in self.bottomView.viewArray) {
        if ([myUser isEqual:item.user]) {
            [self pinThumberViewItem:item];
            [self.bottomView scrollToVisibleArea:item];
        }
    }
}

- (void)viewItemSelected:(ViewItem *)item {
    for (ViewItem *item in self.bottomView.viewArray) {
        item.view.layer.borderColor = [UIColor colorWithWhite:1.0 alpha:0.5].CGColor;
    }
    
    item.view.layer.borderColor = [UIColor greenColor].CGColor;
}

- (void)startSpeakerTimer {
    if ([self.speakerTimer isValid]) {
        [self stopSpeakerTimer];
    }
    if (@available(iOS 10.0, *)) {
        self.speakerTimer = [NSTimer scheduledTimerWithTimeInterval:2.0 repeats:NO
                                                              block:^(NSTimer * _Nonnull timer) {
                                                                  [self speakerOffAll];
                                                              }];
    } else {
        // Fallback on earlier versions
    }
}

- (void)stopSpeakerTimer {
    [self.speakerTimer invalidate];
    self.speakerTimer = nil;
}

- (void)speakerOffAll {
    [self.bottomView deactiveAllThumberView];
}

- (void)switchToShare:(SwitchBtn *)switchShareBtn {
    switchShareBtn.hidden = YES;
    
    if (!switchShareBtn.sharedUser) {
        return;
    }
    
    OpenGLRawdataRenderer *fullRenderer = [self getFullViewRenderer];
    if (fullRenderer.dataType == ZoomVideoSDKVideoType_ShareData) {
        [fullRenderer.user.getSharePipe unSubscribeWithDelegate:fullRenderer];
    } else {
        [fullRenderer.user.getVideoPipe unSubscribeWithDelegate:fullRenderer];
    }
    
    fullRenderer.user = switchShareBtn.sharedUser;
    fullRenderer.dataType = ZoomVideoSDKVideoType_ShareData;
    [switchShareBtn.sharedUser.getSharePipe subscribeWithDelegate:fullRenderer resolution:ZoomVideoSDKVideoResolution_720];
    [fullRenderer.openGLView removeAvatar];
    
    for (ViewItem *item in self.bottomView.viewArray) {
        if ([switchShareBtn.sharedUser isEqual:item.user]) {
            [self viewItemSelected:item];
        }
    }
    
    [self updateLowerThird];
}

- (BOOL)creatFile:(NSString*)filePath{
    if (filePath.length==0) {
        return NO;
    }
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:filePath]) {
        return YES;
    }
    NSError *error;
    NSString *dirPath = [filePath stringByDeletingLastPathComponent];
    BOOL isSuccess = [fileManager createDirectoryAtPath:dirPath withIntermediateDirectories:YES attributes:nil error:&error];

    if (!isSuccess) {
        return isSuccess;
    }
    isSuccess = [fileManager createFileAtPath:filePath contents:nil attributes:nil];
    return isSuccess;
}

- (BOOL)appendData:(NSData*)data withPath:(NSString *)filePath{
    if (filePath.length==0) {
        return NO;
    }
    BOOL result = [self creatFile:filePath];
    if (result) {
        NSFileHandle *handle = [NSFileHandle fileHandleForWritingAtPath:filePath];
        [handle seekToEndOfFile];
        [handle writeData:data];
        [handle synchronizeFile];
        [handle closeFile];
    }
    else{
        NSLog(@"appendData Failed");
    }
    return result;
}

#pragma mark - uialertview -
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (!self.joinSessionOrIgnorePasswordBlock) {
        return;
    }
    
    if (buttonIndex == alertView.firstOtherButtonIndex) {
        //Join
        NSString *password = [alertView textFieldAtIndex: 0].text;
        ZoomVideoSDKError error = self.joinSessionOrIgnorePasswordBlock(password, NO);
        if (error != Errors_Success) {
            [self showZoomPasswordAlert:YES];
        }
        NSLog(@"Input password error code : %@", @(error));
    } else if (buttonIndex == alertView.cancelButtonIndex) {
        //Cancel
        ZoomVideoSDKError error = self.joinSessionOrIgnorePasswordBlock(nil, YES);
        NSLog(@"Cancel error code : %@", @(error));
    }
}

#pragma mark - Notification -
- (void)keyBoardWillShow:(NSNotification *)notification {
    [self.chatInputView keyBoardWillShow:notification];
    self.chatView.hidden = NO;
    self.controlBarView.hidden = NO;
}

- (void)keyBoardDidShow:(NSNotification *)notification {
    [self.chatView updateFrame:NO notification:notification];
}

- (void)keyBoardWillHide:(NSNotification *)notification {
    [self.chatInputView keyBoardWillHide:notification];
}

- (void)keyBoardDidHide:(NSNotification *)notification {
    [self.chatView updateFrame:YES notification:notification];
}

- (void)onDeviceOrientationChangeNotification:(NSNotification *)aNotification {
    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    if ((orientation == UIDeviceOrientationUnknown) || (orientation == UIDeviceOrientationFaceUp) || (orientation == UIDeviceOrientationFaceDown))
    {
        orientation = (UIDeviceOrientation)[[UIApplication sharedApplication] statusBarOrientation];
    }
    
    [[[ZoomVideoSDK shareInstance] getVideoHelper] rotateMyVideo:orientation];
}


- (void)applicationWillResignActive:(NSNotification *)aNotification {
    OpenGLRawdataRenderer *fullRenderer = [self getFullViewRenderer];
    [fullRenderer.openGLView clearFrame];
    
    for (OpenGLRawdataRenderer *thumbRenderer in self.rendererArr) {
        [thumbRenderer.openGLView clearFrame];
    }
}

- (void)applicationDidBecomeActive:(NSNotification *)aNotification {
    NSArray *allUserArray = [[[ZoomVideoSDK shareInstance] getSession] getRemoteUsers];
    OpenGLRawdataRenderer *fullRenderer = [self getFullViewRenderer];

    if (![allUserArray containsObject:fullRenderer.user]) {
        [self pinMyself];
    }
}

- (void)onCommandReceived:(NSString * _Nullable)commandContent sendUser:(ZoomVideoSDKUser * _Nullable)sendUser
{
    NSLog(@"commandContent:%@, sendUser:%@", commandContent, sendUser);
    
    CmdTpye cmd_type = [[SimulateStorage shareInstance] getCmdTypeFromCmd:commandContent];
    if (cmd_type == CmdTpye_Reaction) {
        for (ViewItem *item in self.bottomView.viewArray) {
            if ([item.user isEqual:sendUser]) {
                kTagReactionTpye reaction_type = [[SimulateStorage shareInstance] getReactionTypeFromCmd:commandContent];
                item.reactionImg.image = [[SimulateStorage shareInstance] getReactionImageFromType:reaction_type];
                item.reactionImg.hidden = NO;
                
                NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
                [dict setObject:item.reactionImg forKey:@"reaction_imageview"];
                [dict setObject:commandContent forKey:@"command_content"];
                if ([SimulateStorage shareInstance].reactionType == kTagReactionTpye_Raisehand
                    && reaction_type != kTagReactionTpye_Raisehand
                    && reaction_type != kTagReactionTpye_Lowerhand) {
                    NSTimer *timer = [NSTimer timerWithTimeInterval:5 target:self selector:@selector(handleRaisehandAndThenEmojiTimer:) userInfo:dict repeats:NO];
                    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
                } else if (reaction_type != kTagReactionTpye_Raisehand && reaction_type != kTagReactionTpye_Lowerhand) {
                    NSTimer *timer = [NSTimer timerWithTimeInterval:5 target:self selector:@selector(handleHideTimer:) userInfo:dict repeats:NO];
                    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
                } else if ([SimulateStorage shareInstance].reactionType == kTagReactionTpye_Raisehand && reaction_type == kTagReactionTpye_Lowerhand) {
                    item.reactionImg.hidden = YES;
                }
                [SimulateStorage shareInstance].reactionType = reaction_type;
            }
        }
    } else if (cmd_type == CmdTpye_Feedback_Push) {
        AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        FeedbackPopViewController * vc = [[FeedbackPopViewController alloc] init];
        vc.type = FeedbackPopViewTpye_Receive;
        vc.modalPresentationStyle = UIModalPresentationPageSheet;
        [[appDelegate topViewController] presentViewController:vc animated:YES completion:nil];
    } else if (cmd_type == CmdTpye_Feedback_Submit) {
        [[SimulateStorage shareInstance] processFeedbackData:commandContent sendUser:@(sendUser.getUserID)];
    } else if (cmd_type == CmdTpye_Lowerthird) {
        [[SimulateStorage shareInstance] addLowerThird:commandContent withUser:sendUser];
        [self updateLowerThird];
    }
}

- (void)onCmdChannelConnectResult:(BOOL)success
{
    NSLog(@"[onCmdChannelConnectResult] result:%@",@(success));
    
    if (success)
        [[SimulateStorage shareInstance] sendMyLowerThird];
}

- (void)onLowerThirdNotification:(NSNotification *)aNotification
{
    [self updateLowerThird];
}

- (void)updateLowerThird
{
    if (self.lowerThirdPanel) {
        if (self.switchShareBtn.hidden) {
            self.lowerThirdPanel.frame = CGRectMake(8, CGRectGetMaxY(self.topBarView.frame) + 12, 150, 60);
        } else {
            self.lowerThirdPanel.frame = CGRectMake(8, CGRectGetMaxY(self.switchShareBtn.frame) + 12, 150, 60);
        }
        
        OpenGLRawdataRenderer *fullRenderer = [self getFullViewRenderer];
        LowerThirdCmd *cmd = [[SimulateStorage shareInstance] getUsersLowerThird:fullRenderer.user];
        if ([SimulateStorage isLowerThirdEnabled] && cmd) {
            [self.lowerThirdPanel setLowerThird:cmd];
            self.lowerThirdPanel.hidden = NO;
        } else {
            self.lowerThirdPanel.hidden = YES;
        }
    }
}

- (void)handleHideTimer:(NSTimer *)timer {
    UIImageView *reactionImageView = [[timer userInfo] objectForKey:@"reaction_imageview"];
    reactionImageView.hidden = YES;
}

- (void)handleRaisehandAndThenEmojiTimer:(NSTimer *)timer {
    UIImageView *reactionImageView = [[timer userInfo] objectForKey:@"reaction_imageview"];
    reactionImageView.hidden = NO;
    reactionImageView.image = [UIImage imageNamed:@"reaction_raisehand"];
}

// Simulate yourself receiving your own CMD for local reaction
- (void)mySelfReactionAction:(NSNotification *)notification {
    kTagReactionTpye reaction_type = [notification.object intValue];
    NSString *cmd = [[SimulateStorage shareInstance] generateReactionCmdString:reaction_type];
    if (!cmd) return;
    [self onCommandReceived:cmd sendUser:[[[ZoomVideoSDK shareInstance] getSession] getMySelf]];
}

- (void)onHostAskUnmute
{
    NSLog(@"onHostAskUnmute=>");
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.label.text = @"The host would like you to unmute";
    hud.offset = CGPointMake(0.f, MBProgressMaxOffset);
    [hud hideAnimated:YES afterDelay:2.f];
}

@end
