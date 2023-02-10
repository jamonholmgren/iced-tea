//
//  MetalView.h
//  ZoomVideoSDKSample
//
//  Created by Zoom Video Communications on 2019/1/29.
//  Copyright © 2019 Zoom Video Communications. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MetalView : UIView
- (void)displayMetal:(CVPixelBufferRef)pixelBuffer rotation:(ZoomVideoSDKVideoRawDataRotation)rotation display:(DisplayMode)mode mirror:(BOOL)mirror;

- (void)addAvatar;
- (void)removeAvatar;
@end

NS_ASSUME_NONNULL_END
