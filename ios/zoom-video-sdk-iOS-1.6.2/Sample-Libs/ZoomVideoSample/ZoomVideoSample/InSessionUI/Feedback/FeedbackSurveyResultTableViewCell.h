//
//  FeedbackSurveyResultTableViewCell.h
//  ZoomVideoSample
//
//  Created by Zoom on 2022/1/4.
//  Copyright © 2022 Zoom. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FeedbackPopViewController.h"

#define cell_result_heght 100.0f

@interface FeedbackSurvey : NSObject
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *icon;
@property (nonatomic, assign) int      responseCount;
@property (nonatomic, assign) kTagFeedbackTpye type;
@property (nonatomic, strong) NSMutableArray *responseUserArray;
@end

@interface FeedbackSurveyResultTableViewCell : UITableViewCell
@property (nonatomic, strong) UIView *bgView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIImageView *iconImg;
@property (nonatomic, strong) UIProgressView *progressView;
@property (nonatomic, strong) UILabel *responseLabel;
@property (nonatomic, strong) UILabel *percentLabel;
@end

