//
//  RendererSelectTableViewCell.h
//  ZoomVideoSample
//
//  Created by Zoom Video Communications on 2019/10/29.
//  Copyright © 2019 Zoom. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface RendererSelectTableViewCell : UITableViewCell
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *descLabel;
@property (nonatomic, strong) UIImageView *selectArrow;
- (void)setCellValue:(NSDictionary *)itemData;
@end

