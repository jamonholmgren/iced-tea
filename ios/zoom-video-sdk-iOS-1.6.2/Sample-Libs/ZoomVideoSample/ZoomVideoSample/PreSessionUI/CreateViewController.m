//
//  CreateViewController.m
//  ZoomVideoSample
//
//  Created by Zoom Video Communications on 2019/6/5.
//  Copyright © 2019 Zoom. All rights reserved.
//

#import "CreateViewController.h"
#import "CanvasViewController.h"
#import "OpenGLViewController.h"
#import "MetalViewController.h"
#import <CommonCrypto/CommonDigest.h>
#import "KGModal.h"
#import "RendererSelectView.h"
#import "PreProcessHelper.h"
#import "CameraCaptureAdapter.h"
#import "SendPictureAdapter.h"
#import "SendYUVAdapter.h"
#import "VBViewController.h"

typedef NS_ENUM(NSInteger, ZoomVideoRendererType) {
    ZoomVideoRendererType_Zoom_Canvas      = 0,
    ZoomVideoRendererType_Zoom_OpenGLES,
    ZoomVideoRendererType_Zoom_Metal
};

@interface CreateViewController () <UITextFieldDelegate, ZoomVideoSDKDelegate>
@property (nonatomic, strong) UILabel       *sessionNameLabel;
@property (nonatomic, strong) UITextField   *sessionNameTF;
@property (nonatomic, strong) UITextField   *displayNameTF;
@property (nonatomic, strong) UITextField   *passwordTF;
@property (nonatomic, strong) UILabel       *passwordLabel;
@property (nonatomic, strong) UILabel       *displayNameLabel;
@property (nonatomic, strong) UILabel       *rendererLabel;
@property (nonatomic, strong) UILabel       *rendererResultLabel;
@property (nonatomic, strong) UIImageView   *arrow;
@property (nonatomic, strong) UIButton      *startBtn;

@property (nonatomic, strong) UIView        *line1;
@property (nonatomic, strong) UIView        *line2;
@property (nonatomic, strong) UIView        *line3;
@property (nonatomic, strong) UIView        *line4;

@property (nonatomic, strong) NSArray       *sessionNameArray;

@property (nonatomic, strong) UIButton      *button_copy;

@property (nonatomic, assign) ZoomVideoRendererType    rendererType;
@property (nonatomic, assign) BOOL canRotation;

@property (nonatomic, strong) PreProcessHelper *preProcesser;

@property (nonatomic,strong) CameraCaptureAdapter *cameraAdapter;
@property (nonatomic,strong) SendPictureAdapter *picAdapter;
@property (nonatomic,strong) SendYUVAdapter     *yuvAdapter;

@end

@implementation CreateViewController

- (void)viewDidLoad {
    self.modalPresentationStyle = UIModalPresentationFullScreen;
    [self.navigationController.navigationBar setShadowImage:[[UIImage alloc] init]];
    [self.navigationController.navigationBar setTintColor:RGBCOLOR(0x2D, 0x8C, 0xFF)];
    self.navigationController.navigationBar.translucent = NO;
    
    UIBarButtonItem *moreTestItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"More", @"") style:UIBarButtonItemStylePlain target:self action:@selector(onMoreTestClicked:)];
    [self.navigationItem setRightBarButtonItem:moreTestItem];
    
    self.sessionNameArray = @[@"Chinatown",@"Koreatown",@"Olvera Street",@"Little Tokyo",@"Little Armenia",@"Thai Town",@"Little Ethiopia",@"Historic Filipinotown",@"Pico-Robertson",@"Leimert Park"];
    
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];

    [self initSubView];
    
    [self.sessionNameTF becomeFirstResponder];
    
    self.rendererType = ZoomVideoRendererType_Zoom_Canvas;
    
    if (self.type == ZoomVideoCreateJoinType_Create) {
        self.title = @"Create a Session";
        self.button_copy.hidden = NO;
        [self.startBtn setTitle:@"Create" forState:UIControlStateNormal];
        self.sessionNameTF.text = [[NSString stringWithFormat:@"%@_%@",self.sessionNameArray[arc4random() % self.sessionNameArray.count], [[self stringToMD5:[self currentdateInterval]] substringToIndex:8]] lowercaseString];
    } else if (self.type == ZoomVideoCreateJoinType_Join) {
        self.title = @"Join a Session";
        self.button_copy.hidden = YES;
        [self.startBtn setTitle:@"Join" forState:UIControlStateNormal];
        self.sessionNameTF.text = @"";
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    delegate.canRotation = YES;
    
    UIDeviceOrientation orientation = (UIDeviceOrientation)[[UIApplication sharedApplication] statusBarOrientation];
    self.canRotation = NO;
    if (orientation == UIDeviceOrientationLandscapeLeft ||
        orientation == UIDeviceOrientationLandscapeRight) {
        self.canRotation = YES;
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onDeviceOrientationChangeNotification:) name:UIDeviceOrientationDidChangeNotification object:nil];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (BOOL)shouldAutorotate{
    return self.canRotation;
}

- (void)onDeviceOrientationChangeNotification:(NSNotification *)aNotification {
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    delegate.canRotation = NO;
    self.canRotation = NO;
}

- (NSString *)currentdateInterval {
    NSDate *datenow = [NSDate date];
    NSString *timeSp = [NSString stringWithFormat:@"%ld", (long)[datenow timeIntervalSince1970]];
    return timeSp;
}

- (NSString *)stringToMD5:(NSString *)str {
    const char* input = [str UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(input, (CC_LONG)strlen(input), result);//checked safe
    
    NSMutableString *digest = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for (NSInteger i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [digest appendFormat:@"%02x", result[i]];
    }
    
    return digest;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationPortrait;
}

- (void)initSubView {
    
    float item_hight = 60;
    
    self.sessionNameLabel = [[UILabel alloc] init];
    self.sessionNameLabel.textColor = RGBCOLOR(0x74, 0x74, 0x87);
    self.sessionNameLabel.font = [UIFont systemFontOfSize:15.0];
    self.sessionNameLabel.text = @"Session Name";
    [self.view addSubview:self.sessionNameLabel];
    [self.sessionNameLabel sizeToFit];
    self.sessionNameLabel.frame = CGRectMake(15, 0, Width(self.sessionNameLabel), item_hight);
    
    self.sessionNameTF = [[UITextField alloc] initWithFrame:CGRectMake(MaxX(self.sessionNameLabel)+30, MinY(self.sessionNameLabel), SCREEN_WIDTH-Width(self.sessionNameLabel)-45, item_hight)];
    self.sessionNameTF.textAlignment = NSTextAlignmentLeft;
    self.sessionNameTF.placeholder = @"Required";
    self.sessionNameTF.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.sessionNameTF.textColor = RGBCOLOR(0x23, 0x23, 0x33);;
    self.sessionNameTF.font = [UIFont boldSystemFontOfSize:15.0];
    [self.view addSubview:self.sessionNameTF];
    [self.sessionNameTF addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    self.sessionNameTF.delegate = self;
    
    self.button_copy = [[UIButton alloc] initWithFrame:CGRectMake(MaxX(self.sessionNameTF), MinY(self.sessionNameLabel)+8, 44, 44)];
    [self.button_copy setImage:[UIImage imageNamed:@"copy"] forState:UIControlStateNormal];
    [self.button_copy addTarget:self action:@selector(onCopyClicked:) forControlEvents:UIControlEventTouchUpInside];
    self.button_copy.layer.cornerRadius = 5.0;
    self.button_copy.clipsToBounds = YES;
    [self.view addSubview:self.button_copy];
    
    
    self.line1 = [[UIView alloc] initWithFrame:CGRectMake(15, MaxY(self.sessionNameLabel), SCREEN_WIDTH-30, 1)];
    self.line1.backgroundColor = RGBCOLOR(0xed, 0xed, 0xff);
    [self.view addSubview:self.line1];
    
    self.displayNameLabel = [[UILabel alloc] init];
    self.displayNameLabel.textColor = RGBCOLOR(0x74, 0x74, 0x87);
    self.displayNameLabel.font = [UIFont systemFontOfSize:15.0];
    self.displayNameLabel.text = @"Display Name";
    [self.view addSubview:self.displayNameLabel];
    [self.displayNameLabel sizeToFit];
    self.displayNameLabel.frame = CGRectMake(15, MaxY(self.line1), Width(self.displayNameLabel), item_hight);
    
    self.displayNameTF = [[UITextField alloc] initWithFrame:CGRectMake(MinX(self.sessionNameTF), MinY(self.displayNameLabel), SCREEN_WIDTH-Width(self.sessionNameLabel)-45, item_hight)];
    self.displayNameTF.textAlignment = NSTextAlignmentLeft;
    self.displayNameTF.placeholder = @"Required";
    self.displayNameTF.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.displayNameTF.textColor = RGBCOLOR(0x23, 0x23, 0x33);;
    self.displayNameTF.font = [UIFont boldSystemFontOfSize:15.0];
    [self.view addSubview:self.displayNameTF];
    
    self.displayNameTF.text = [UIDevice currentDevice].name;;
    
    self.line2 = [[UIView alloc] initWithFrame:CGRectMake(15, MaxY(self.displayNameLabel), SCREEN_WIDTH-30, 1)];
    self.line2.backgroundColor = RGBCOLOR(0xed, 0xed, 0xff);
    [self.view addSubview:self.line2];
    
    self.passwordLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, MaxY(self.line2), Width(self.sessionNameLabel), item_hight)];
    self.passwordLabel.numberOfLines = 0;
    self.passwordLabel.textColor = RGBCOLOR(0x74, 0x74, 0x87);
    self.passwordLabel.font = [UIFont systemFontOfSize:15.0];
    self.passwordLabel.text = @"Password";
    [self.view addSubview:self.passwordLabel];
    
    self.passwordTF = [[UITextField alloc] initWithFrame:CGRectMake(MinX(self.sessionNameTF), MinY(self.passwordLabel), SCREEN_WIDTH-Width(self.sessionNameLabel)-45, item_hight)];
    self.passwordTF.textAlignment = NSTextAlignmentLeft;
    self.passwordTF.placeholder = @"Optional";
    self.passwordTF.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.passwordTF.textColor = RGBCOLOR(0x23, 0x23, 0x33);;
    self.passwordTF.font = [UIFont boldSystemFontOfSize:15.0];
    [self.view addSubview:self.passwordTF];
    [self.passwordTF addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    self.passwordTF.delegate = self;
    
    self.line3 = [[UIView alloc] initWithFrame:CGRectMake(15, MaxY(self.passwordLabel), SCREEN_WIDTH-30, 1)];
    self.line3.backgroundColor = RGBCOLOR(0xed, 0xed, 0xff);
    [self.view addSubview:self.line3];
    
    self.rendererLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, MaxY(self.line3), Width(self.sessionNameLabel), item_hight)];
    self.rendererLabel.numberOfLines = 0;
    self.rendererLabel.textColor = RGBCOLOR(0x74, 0x74, 0x87);
    self.rendererLabel.font = [UIFont systemFontOfSize:15.0];
    self.rendererLabel.text = @"Renderer";
    [self.view addSubview:self.rendererLabel];
    
    self.rendererResultLabel = [[UILabel alloc] initWithFrame:CGRectMake(MinX(self.sessionNameTF), MinY(self.line3), SCREEN_WIDTH-Width(self.sessionNameLabel)-45, item_hight)];
    self.rendererResultLabel.numberOfLines = 0;
    self.rendererResultLabel.textColor = RGBCOLOR(0x23, 0x23, 0x33);
    self.rendererResultLabel.font = [UIFont boldSystemFontOfSize:15.0];
    self.rendererResultLabel.text = @"Zoom renderer";
    [self.view addSubview:self.rendererResultLabel];
    self.rendererResultLabel.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onRendererClicked:)];
    [self.rendererResultLabel addGestureRecognizer:tapGesture];
    
    self.arrow = [[UIImageView alloc] initWithFrame:CGRectMake(Width(self.rendererResultLabel) -26, (Height(self.rendererResultLabel)-18)/2, 18, 18)];
    self.arrow.image = [UIImage imageNamed:@"arrow_down"];
    [self.rendererResultLabel addSubview:self.arrow];
    
    
    self.line4 = [[UIView alloc] initWithFrame:CGRectMake(15, MaxY(self.rendererResultLabel), SCREEN_WIDTH-30, 1)];
    self.line4.backgroundColor = RGBCOLOR(0xed, 0xed, 0xff);
    [self.view addSubview:self.line4];
    
    self.startBtn = [[UIButton alloc] initWithFrame:CGRectMake(15, MaxY(self.line4)+20, SCREEN_WIDTH-30, 45)];
    [self.startBtn setBackgroundColor:RGBCOLOR(0x0E, 0x71, 0xEB)];
    [self.startBtn setTitle:@"Create" forState:UIControlStateNormal];
    self.startBtn.titleLabel.font = [UIFont boldSystemFontOfSize:16];
    [self.startBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.startBtn addTarget:self action:@selector(onCreateClicked:) forControlEvents:UIControlEventTouchUpInside];
    self.startBtn.layer.cornerRadius = 10;
    self.startBtn.clipsToBounds = YES;
    [self.view addSubview:self.startBtn];
}

- (BOOL)isInputRule:(NSString *)str {
    NSString *pattern = @"^[A-Za-z0-9_ !#$%&()+-:;<=.>?@\\[\\]^{}|~,]+$";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", pattern];
    BOOL isMatch = [pred evaluateWithObject:str];
    return isMatch;
}

#pragma mark - UITextFieldDelegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if ([self isInputRule:string] || [string isEqualToString:@""]) {
        if ([textField isEqual:self.passwordTF]) {
            if (self.passwordTF.text.length > 9) {
                return NO;
            }
        }
        
        return YES;
    }
    return NO;
}

- (void)textFieldDidChange:(UITextField *)textField
{
    textField.text = [textField.text lowercaseString];
    if (self.sessionNameTF.text.length == 0) {
        self.button_copy.hidden = YES;
    } else {
        self.button_copy.hidden = NO;
    }
}

- (void)onRendererClicked:(id)sender {
    [[KGModal sharedInstance] setModalBackgroundColor:[UIColor whiteColor]];
    [[KGModal sharedInstance] setCloseButtonType:KGModalCloseButtonTypeNone];
    [[KGModal sharedInstance] setTapOutsideToDismiss:YES];
    [[KGModal sharedInstance] showWithContentView:[self showRendererSelect] andAnimated:YES];
}

- (UIView*)showRendererSelect {
    RendererSelectView * selectView = [[RendererSelectView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH-80, 320) selectIndex:(NSInteger)self.rendererType];
    selectView.selectRendererOnClickBlock = ^(NSInteger selectIndex) {
        switch (selectIndex) {
            case 0:
                self.rendererResultLabel.text = @"Zoom renderer";
                self.rendererType = ZoomVideoRendererType_Zoom_Canvas;
                break;
            case 1:
                self.rendererResultLabel.text = @"OpenGL ES renderer";
                self.rendererType = ZoomVideoRendererType_Zoom_OpenGLES;
                break;
            case 2:
                self.rendererResultLabel.text = @"Metal renderer";
                self.rendererType = ZoomVideoRendererType_Zoom_Metal;
                break;
            default:
                break;
        }
        [[KGModal sharedInstance] hide];
    };
    return selectView;
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [self updateFrame];
}

- (void)updateFrame {
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    BOOL landscape = UIInterfaceOrientationIsLandscape(orientation);
    
    float x;
    if (landscape) {
        x = 60;
    } else {
        x = 15;
    }
    float item_hight = 60;
    
    self.sessionNameLabel.frame = CGRectMake(x, 0, Width(self.sessionNameLabel), item_hight);
    self.sessionNameTF.frame = CGRectMake(MaxX(self.sessionNameLabel)+30, MinY(self.sessionNameLabel), SCREEN_WIDTH-Width(self.sessionNameLabel)-x*2-15-70, item_hight);
    self.button_copy.frame = CGRectMake(MaxX(self.sessionNameTF), MinY(self.sessionNameLabel)+8, 44, 44);
    self.line1.frame = CGRectMake(x, MaxY(self.sessionNameLabel), SCREEN_WIDTH-x*2, 1);
    
    self.displayNameLabel.frame = CGRectMake(x, MaxY(self.line1), Width(self.displayNameLabel), item_hight);
    self.displayNameTF.frame = CGRectMake(MinX(self.sessionNameTF), MinY(self.displayNameLabel), Width(self.sessionNameTF), item_hight);
    self.line2.frame = CGRectMake(x, MaxY(self.displayNameLabel), SCREEN_WIDTH-x*2, 1);
    
    self.passwordLabel.frame = CGRectMake(x, MaxY(self.line2), Width(self.sessionNameLabel), item_hight);
    self.passwordTF.frame = CGRectMake(MinX(self.sessionNameTF), MinY(self.passwordLabel), Width(self.sessionNameTF), item_hight);
    self.line3.frame = CGRectMake(x, MaxY(self.passwordLabel), SCREEN_WIDTH-x*2, 1);
    
    self.rendererLabel.frame = CGRectMake(x, MaxY(self.line3), Width(self.sessionNameLabel), item_hight);
    self.rendererResultLabel.frame = CGRectMake(MinX(self.sessionNameTF), MinY(self.rendererLabel), SCREEN_WIDTH-Width(self.passwordLabel)-x*2-15, item_hight);
    self.line4.frame = CGRectMake(x, MaxY(self.rendererLabel), SCREEN_WIDTH-x*2, 1);
    
    self.arrow.frame = CGRectMake(Width(self.rendererResultLabel) -26, (Height(self.rendererResultLabel)-18)/2, 18, 18);
    
    self.startBtn.frame = CGRectMake(x, MaxY(self.line4)+20, SCREEN_WIDTH-x*2, 45);
}

- (void)onCopyClicked:(UIButton *)sender {
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = self.sessionNameTF.text;
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.label.text = @"Copied to clipboard";
    // Move to bottm center.
    hud.offset = CGPointMake(0.f, MBProgressMaxOffset);
    [hud hideAnimated:YES afterDelay:2.f];
}

- (void)onMoreTestClicked:(id)sender
{
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"VB"
                                                                             message:nil
                                                                      preferredStyle:UIAlertControllerStyleActionSheet];

    [alertController addAction:[UIAlertAction actionWithTitle:@"Audio Test"
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction *action) {
        [self audioTest];
                                                      }]];

    [alertController addAction:[UIAlertAction actionWithTitle:@"VB Setting"
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction *action) {
        AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        VBViewController *VC = [[VBViewController alloc] init];
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:VC];
        nav.modalPresentationStyle = UIModalPresentationPageSheet;
        [[appDelegate topViewController] presentViewController:nav animated:YES completion:NULL];
                                                      }]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:nil]];

    UIPopoverPresentationController *popover = alertController.popoverPresentationController;
    if (popover)
    {
        popover.sourceView = self.sessionNameTF;
        popover.sourceRect = self.sessionNameTF.frame;
        popover.permittedArrowDirections = UIPopoverArrowDirectionAny;
    }
    [[appDelegate topViewController] presentViewController:alertController animated:YES completion:nil];
    
}

- (void)audioTest {
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Test Audio"
                                                                             message:nil
                                                                      preferredStyle:UIAlertControllerStyleActionSheet];

    [alertController addAction:[UIAlertAction actionWithTitle:@"Test Mic Recording"
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction *action) {
                                                            ZoomVideoSDKTestAudioDeviceHelper *heler = [[ZoomVideoSDK shareInstance] getTestAudioDeviceHelper];
                                                            ZoomVideoSDKError startMicTestRecordingRet = [heler startMicTest];
                                                            NSLog(@"startMicTestRecordingRet====>%@",@(startMicTestRecordingRet));
                                                        
                                                            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(8 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                                                ZoomVideoSDKError stopMicTestRecordingRet = [heler stopMicTest];
                                                                NSLog(@"stopMicTestRecordingRet====>%@",@(stopMicTestRecordingRet));
                                                        
                                                        
                                                                ZoomVideoSDKError playMicTestRecordingRet = [heler playMicTest];
                                                                NSLog(@"playMicTestRecordingRet====>%@",@(playMicTestRecordingRet));
                                                        
                                                            });
                                                      }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"Test Speaker"
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction *action) {
                                                            ZoomVideoSDKTestAudioDeviceHelper *heler = [[ZoomVideoSDK shareInstance] getTestAudioDeviceHelper];
                                                            ZoomVideoSDKError startSpeakerTestRet = [heler startSpeakerTest];
                                                            NSLog(@"startSpeakerTestRet====>%@",@(startSpeakerTestRet));
                                                            
                                                            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(8 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                                                ZoomVideoSDKError stopSpeakerTestRet = [heler stopSpeakerTest];
                                                                NSLog(@"stopSpeakerTestRet====>%@",@(stopSpeakerTestRet));
                                                            });
                                                      }]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:nil]];
    
    UIPopoverPresentationController *popover = alertController.popoverPresentationController;
    if (popover)
    {
        popover.sourceView = self.sessionNameTF;
        popover.sourceRect = self.sessionNameTF.frame;
        popover.permittedArrowDirections = UIPopoverArrowDirectionAny;
    }
    [[appDelegate topViewController] presentViewController:alertController animated:YES completion:nil];
}

- (void)onCreateClicked:(UIButton *)sender {
    if (_sessionNameTF.text.length == 0) {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeText;
        hud.label.text = @"Input Session Name";
        hud.offset = CGPointMake(0.f, MBProgressMaxOffset);
        [hud hideAnimated:YES afterDelay:2.f];
        return;
    }
    
    if (_displayNameTF.text.length == 0) {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeText;
        hud.label.text = @"Input Display Name";
        hud.offset = CGPointMake(0.f, MBProgressMaxOffset);
        [hud hideAnimated:YES afterDelay:2.f];
        return;
    }
    
    if (_passwordTF.text.length > 10) {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeText;
        hud.label.text = @"Password is too long";
        hud.offset = CGPointMake(0.f, MBProgressMaxOffset);
        [hud hideAnimated:YES afterDelay:2.f];
        return;
    }
    
    ZoomVideoSDKAudioOptions *audioOption = [ZoomVideoSDKAudioOptions new];
    audioOption.connect     = YES;
    audioOption.mute        = NO;
    
    ZoomVideoSDKVideoOptions *videoOption = [ZoomVideoSDKVideoOptions new];
    videoOption.localVideoOn = YES;
    
//    self.preProcesser = [[PreProcessHelper alloc] init];
//    self.cameraAdapter = [[CameraCaptureAdapter alloc] init];
//    self.picAdapter = [[SendPictureAdapter alloc] init];
//    self.yuvAdapter = [[SendYUVAdapter alloc] init];

    ZoomVideoSDKSessionContext *sessionContext = [ZoomVideoSDKSessionContext new];
    sessionContext.sessionName        = _sessionNameTF.text;
    sessionContext.userName        = _displayNameTF.text;
    sessionContext.sessionPassword    = _passwordTF.text;
    sessionContext.audioOption     = audioOption;
    sessionContext.videoOption     = videoOption;
    sessionContext.token           = kAppToken; //[self createJWTAccessToken];
//    sessionContext.preProcessorDelegate = self.preProcesser;
//    sessionContext.externalVideoSourceDelegate  = self.picAdapter;
    
    [ZoomVideoSDK shareInstance].delegate = self;
    ZoomVideoSDKSession *session = [[ZoomVideoSDK shareInstance] joinSession:sessionContext];
    if (!session) {
        return;
    }
    
    if (self.rendererType == ZoomVideoRendererType_Zoom_Canvas) {
        //Present Session Video View
        CanvasViewController * sessionVC = [[CanvasViewController alloc] init];
        sessionVC.modalPresentationStyle = UIModalPresentationFullScreen;
        [self presentViewController:sessionVC animated:YES completion:nil];
    } else if (self.rendererType == ZoomVideoRendererType_Zoom_OpenGLES) {
        //Present Session Video View
        OpenGLViewController * sessionVC = [[OpenGLViewController alloc] init];
        sessionVC.modalPresentationStyle = UIModalPresentationFullScreen;
        [self presentViewController:sessionVC animated:YES completion:nil];
    } else if (self.rendererType == ZoomVideoRendererType_Zoom_Metal) {
        //Present Session Video View
        MetalViewController * sessionVC = [[MetalViewController alloc] init];
        sessionVC.modalPresentationStyle = UIModalPresentationFullScreen;
        [self presentViewController:sessionVC animated:YES completion:nil];
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

- (void)onError:(ZoomVideoSDKError)ErrorType detail:(NSInteger)details
{
    NSLog(@"ErrorType========%@, %@",@(ErrorType), [self formatErrorString:ErrorType]);
    NSLog(@"ErrorDetails========%@",@(details));
}

@end

