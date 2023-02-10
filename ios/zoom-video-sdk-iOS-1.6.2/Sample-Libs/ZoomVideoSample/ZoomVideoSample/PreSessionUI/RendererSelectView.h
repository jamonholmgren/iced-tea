//
//  RendererSelectView.h
//  ZoomVideoSample
//
//  Created by Zoom Video Communications on 2019/10/29.
//  Copyright © 2019 Zoom. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface RendererSelectView : UIView
- (id)initWithFrame:(CGRect)frame selectIndex:(NSInteger)selectIndex;
@property (nonatomic,copy) void(^selectRendererOnClickBlock)(NSInteger selectIndex);
@end

NS_ASSUME_NONNULL_END
