//
//  ChatCell.h
//  ZoomVideoSample
//
//  Created by Zoom Video Communications on 2019/5/30.
//  Copyright © 2019 Zoom. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ChatCell : UITableViewCell
- (void)setCellValue:(NSDictionary *)itemData;
+(CGFloat)cellHeight:(NSDictionary *)itemData;
@property (nonatomic, strong)   UIView    *msgbgView;
@end

NS_ASSUME_NONNULL_END
