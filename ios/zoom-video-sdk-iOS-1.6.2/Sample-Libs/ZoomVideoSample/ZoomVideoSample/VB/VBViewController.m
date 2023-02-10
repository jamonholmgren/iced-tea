//
//  VBViewController.m
//  MobileRTCSample
//
//  Created by Zoom Video Communications on 2022/12/21.
//  Copyright © 2020 Zoom Video Communications, Inc. All rights reserved.
//

#import "VBViewController.h"

@interface VBViewController ()
@property(nonatomic, strong) UIButton *vbButton;
@property(nonatomic, strong) ZoomVideoSDKVirtualBackgroundHelper *vbHelper;
@property (nonatomic, strong) UIView  *fullScreenCanvas;
@end

@implementation VBViewController
@synthesize vbButton;


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationController.navigationBar.translucent = NO;
    
    self.title = @"Virtual Background";
        
    UIBarButtonItem *closeItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(onDone:)];
    [self.navigationItem setLeftBarButtonItem:closeItem];
    [self.navigationItem.leftBarButtonItem setTintColor:RGBCOLOR(0x2D, 0x8C, 0xFF)];
    
    
    _vbHelper = [[ZoomVideoSDK shareInstance] getVirtualBackgroundHelper];
    BOOL supportVB = [_vbHelper isSupportVirtualBackground];
    NSLog(@"[VB Test] isSupportVirtualBG : %@.", @(supportVB));
    if (!supportVB) {
        return;
    }
    
    [self initSubViews];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear: animated];
    ZoomVideoSDKUser *mySelfUser = [[[ZoomVideoSDK shareInstance] getSession] getMySelf];
    [[mySelfUser getVideoCanvas] unSubscribeWithView:self.fullScreenCanvas];
}

- (void)initSubViews {
    self.fullScreenCanvas = [[UIView alloc] initWithFrame:self.view.bounds];
    self.fullScreenCanvas.backgroundColor = [UIColor blackColor];
    [self.view addSubview:self.fullScreenCanvas];
    
    ZoomVideoSDKUser *mySelfUser = [[[ZoomVideoSDK shareInstance] getSession] getMySelf];
    [[mySelfUser getVideoCanvas] subscribeWithView:self.fullScreenCanvas andAspectMode:ZoomVideoSDKVideoAspect_LetterBox];
    
    
    vbButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [vbButton setTitle:NSLocalizedString(@"VB Setting", @"") forState:UIControlStateNormal];
    [vbButton setBackgroundColor:RGBCOLOR(0x66, 0x66, 0x66)];
    [vbButton setTitleColor:RGBCOLOR(45, 200, 255) forState:UIControlStateNormal];
    vbButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:18.0];
    [vbButton addTarget:self action:@selector(onVBButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    vbButton.frame = CGRectMake(100, 100, 150, 50);
    [self.view addSubview:vbButton];
}

- (void)onDone:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)onVBButtonClicked:(id)sender
{
    ZoomVideoSDKVirtualBackgroundHelper *vbHelper = [[ZoomVideoSDK shareInstance] getVirtualBackgroundHelper];
    
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"VB"
                                                                             message:nil
                                                                      preferredStyle:UIAlertControllerStyleActionSheet];

    [alertController addAction:[UIAlertAction actionWithTitle:@"Add VB"
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction *action) {
        ZoomVideoSDKVirtualBackgroundItem *item = [vbHelper addVirtualBackgroundItem:[UIImage imageNamed:@"intro_bg_2"]];
        NSLog(@"[VB Test] add vb : %@.", item);
        NSLog(@"[VB Test] vbList : %@.", [vbHelper getVirtualBackgroundItemList]);
                                                      }]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"Remove VB"
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction *action) {
        
        ZoomVideoSDKVirtualBackgroundItem *item = [[vbHelper getVirtualBackgroundItemList] lastObject];
        if (item.canVirtualBackgroundBeDeleted) {
            ZoomVideoSDKError ret = [vbHelper removeVirtualBackgroundItem:[[vbHelper getVirtualBackgroundItemList] lastObject]];
            NSLog(@"[VB Test] remove vb : %@.", @(ret));
            NSLog(@"[VB Test] vbList : %@.", [vbHelper getVirtualBackgroundItemList]);
        } else {
            NSLog(@"[VB Test] canVirtualBackgroundBeDeleted = NO");
        }
                                                      }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"Set VB None"
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction *action) {
        NSArray *vbList = [vbHelper getVirtualBackgroundItemList];
        
        for (ZoomVideoSDKVirtualBackgroundItem *item in vbList) {
            if (item.type == ZoomVideoSDKVirtualBackgroundDataType_None) {
                ZoomVideoSDKError ret = [vbHelper setVirtualBackgroundItem:item];
                NSLog(@"[VB Test] use none vb : %@.", @(ret));
                return;;
            }
        }
                                                      }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"Set VB Blur"
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction *action) {
        NSArray *vbList = [vbHelper getVirtualBackgroundItemList];
        
        for (ZoomVideoSDKVirtualBackgroundItem *item in vbList) {
            if (item.type == ZoomVideoSDKVirtualBackgroundDataType_Blur) {
                ZoomVideoSDKError ret = [vbHelper setVirtualBackgroundItem:item];
                NSLog(@"[VB Test] use blur vb : %@.", @(ret));
                return;;
            }
        }
                                                      }]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"Set VB Image"
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction *action) {
        NSArray *vbList = [vbHelper getVirtualBackgroundItemList];
        
        for (ZoomVideoSDKVirtualBackgroundItem *item in vbList) {
            if (item.type == ZoomVideoSDKVirtualBackgroundDataType_Image) {
                ZoomVideoSDKError ret = [vbHelper setVirtualBackgroundItem:item];
                NSLog(@"[VB Test] use image vb: %@.", @(ret));
                return;;
            }
        }
                                                      }]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"Get VB List"
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction *action) {
        NSArray *vbList = [vbHelper getVirtualBackgroundItemList];
        NSLog(@"[VB Test] vbList : %@.", vbList);
                                                      }]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"Get Select VB"
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction *action) {
        ZoomVideoSDKVirtualBackgroundItem *item = [vbHelper getSelectedVirtualBackgroundItem];
        NSLog(@"[VB Test] selected vb : %@.", item);
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

@end
