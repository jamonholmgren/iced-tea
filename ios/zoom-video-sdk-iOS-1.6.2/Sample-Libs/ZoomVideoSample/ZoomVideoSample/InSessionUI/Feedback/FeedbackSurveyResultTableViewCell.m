//
//  FeedbackSurveyResultTableViewCell.m
//  ZoomVideoSample
//
//  Created by Zoom on 2022/1/4.
//  Copyright © 2022 Zoom. All rights reserved.
//

#import "FeedbackSurveyResultTableViewCell.h"

@implementation FeedbackSurvey

@end

@implementation FeedbackSurveyResultTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        _bgView = [[UIView alloc] initWithFrame:CGRectMake(20, 7, SCREEN_WIDTH-40, cell_result_heght-7*2)];
        _bgView.backgroundColor = RGBCOLOR_With_Alpha(0x52, 0x52, 0x80, 0.09);
        _bgView.layer.cornerRadius = 8;
        _bgView.layer.borderColor = [UIColor colorWithRed:0xe4 green:0xe7 blue:0xec alpha:1].CGColor;
        _bgView.layer.borderWidth = 1;
        [self.contentView addSubview:_bgView];
        
        _iconImg = [[UIImageView alloc] initWithFrame:CGRectMake(20, (CGRectGetHeight(_bgView.frame)-30)/2, 30, 30)];
        _iconImg.image = [UIImage imageNamed:@"feedback_very_satisfied_icon"];
        [_bgView addSubview:_iconImg];
        
        _progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_iconImg.frame)+20, (CGRectGetHeight(_bgView.frame)-3)/2, CGRectGetWidth(_bgView.frame)-20-CGRectGetWidth(_iconImg.frame)-20-20, 3)];
        [_bgView addSubview:_progressView];
        _progressView.progress = 0.5;
       
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(_progressView.frame.origin.x, CGRectGetMinY(_progressView.frame)-25, CGRectGetWidth(_progressView.frame), 25)];
        _titleLabel.textAlignment = 0;
        _titleLabel.font = [UIFont systemFontOfSize:16];
        _titleLabel.numberOfLines = 1;
        _titleLabel.textColor = RGBCOLOR(0x13, 0x16, 0x19);
//        _titleLabel.text = @"Very Satisfied";
        [_bgView addSubview:_titleLabel];
        
        _percentLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_progressView.frame)-100, CGRectGetMinY(_progressView.frame)-25, 100, 25)];
        _percentLabel.textAlignment = 2;
        _percentLabel.font = [UIFont systemFontOfSize:16];
        _percentLabel.numberOfLines = 1;
        _percentLabel.textColor = RGBCOLOR(0x13, 0x16, 0x19);
//        _percentLabel.text = @"0%";
        [_bgView addSubview:_percentLabel];
        
        _responseLabel = [[UILabel alloc] initWithFrame:CGRectMake(_progressView.frame.origin.x, CGRectGetMaxY(_progressView.frame), CGRectGetWidth(_progressView.frame), 25)];
        _responseLabel.textAlignment = 0;
        _responseLabel.font = [UIFont systemFontOfSize:14];
        _responseLabel.numberOfLines = 1;
        _responseLabel.textColor = RGBCOLOR(0x6E, 0x76, 0x80);
//        _responseLabel.text = @"0 responses";
        [_bgView addSubview:_responseLabel];
    }
    return self;
}

@end
