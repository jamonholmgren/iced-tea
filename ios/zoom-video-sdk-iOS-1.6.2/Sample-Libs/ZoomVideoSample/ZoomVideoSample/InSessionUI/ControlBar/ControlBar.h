//
//  ControlBar.h
//  ZoomVideoSample
//
//  Created by Zoom Video Communications on 2019/5/27.
//  Copyright © 2019 Zoom. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ControlBar : UIView
@property (strong, nonatomic) UIButton          *shareBtn;
@property (strong, nonatomic) UIButton          *audioBtn;
@property (nonatomic,copy) void(^chatOnClickBlock)(void);
@property (nonatomic,copy) void(^shareOnClickBlock)(void);
@end

NS_ASSUME_NONNULL_END
