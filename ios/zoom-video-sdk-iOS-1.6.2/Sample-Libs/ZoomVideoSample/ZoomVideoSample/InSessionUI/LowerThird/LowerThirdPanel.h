//
//  LowerThirdPanel.h
//  ZoomVideoSample
//
//  Created by Zoom on 2022/1/5.
//  Copyright © 2022 Zoom. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SimulateStorage.h"

NS_ASSUME_NONNULL_BEGIN

@interface MarginLabel : UILabel

@end

@interface LowerThirdPanel : UIView
- (void)setLowerThird:(LowerThirdCmd *)cmd;
@end

NS_ASSUME_NONNULL_END
