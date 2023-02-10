//
//  MoreMenuHelper.h
//  ZoomVideoSample
//
//  Created by Zoom on 2022/1/6.
//  Copyright © 2022 Zoom. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MoreMenuHelper : NSObject
+ (MoreMenuHelper *)sharedInstance;
@property (nonatomic, assign) BOOL              isSpeaker;
- (void)switchSpeaker;
@end

NS_ASSUME_NONNULL_END
