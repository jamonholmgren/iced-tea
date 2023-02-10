//
//  TopBarView.h
//  ZoomVideoSample
//
//  Created by Zoom Video Communications on 2019/5/27.
//  Copyright © 2019 Zoom. All rights reserved.
//

#import <UIKit/UIKit.h>

#define Top_Height               70

NS_ASSUME_NONNULL_BEGIN

@interface TopBarView : UIView
@property (nonatomic,copy) void(^endOnClickBlock)(void);
@property (nonatomic,copy) void(^sessionInfoOnClickBlock)(void);
@property (strong, nonatomic) UIButton        *leaveBtn;

- (void)updateTopBarWithSessionName:(NSString *)sessionName totalNum:(NSUInteger)total password:(NSString *)password isJoined:(BOOL)isJoined;

@end

NS_ASSUME_NONNULL_END
