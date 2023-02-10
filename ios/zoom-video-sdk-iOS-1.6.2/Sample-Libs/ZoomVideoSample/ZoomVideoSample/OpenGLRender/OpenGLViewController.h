//
//  OpenGLViewController.h
//  ZoomVideoSample
//
//  Created by Zoom Video Communications on 2019/5/27.
//  Copyright © 2019 Zoom. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OpenglView.h"

@interface OpenGLRawdataRenderer : NSObject
@property (nonatomic, assign) ZoomVideoSDKVideoType dataType;
@property (nonatomic, assign) BOOL isFullScreenDelegate;
@property (nonatomic, strong) OpenglView *openGLView;
@property (nonatomic, strong) ZoomVideoSDKUser *user;
@property (nonatomic, strong) UILabel *statisticLabel;

@end

@interface OpenGLViewController : UIViewController
@property (nonatomic,copy) ZoomVideoSDKError(^joinSessionOrIgnorePasswordBlock)(NSString *, BOOL);
@end
