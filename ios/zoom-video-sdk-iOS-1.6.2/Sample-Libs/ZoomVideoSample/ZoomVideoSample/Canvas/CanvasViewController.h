//
//  CanvasViewController.h
//  ZoomVideoSample
//
//  Created by Zoom Video Communications on 2019/5/27.
//  Copyright © 2019 Zoom. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZoomView : UIView
@property (nonatomic, strong) ZoomVideoSDKUser *user;
@property (nonatomic, assign) ZoomVideoSDKVideoType dataType;
@end


@interface CanvasViewController : UIViewController
@property (nonatomic,copy) ZoomVideoSDKError(^joinSessionOrIgnorePasswordBlock)(NSString *, BOOL);
@end
