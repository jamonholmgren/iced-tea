//
//  SettingTableViewCell.m
//  ZoomVideoSample
//
//  Created by Zoom Video Communications on 2019/10/28.
//  Copyright © 2019 Zoom. All rights reserved.
//

#import "SettingTableViewCell.h"


@interface SettingTableViewCell()
@end

@implementation SettingTableViewCell



- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
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
        self.contentView.backgroundColor = [UIColor whiteColor];
        
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 20, SCREEN_WIDTH, 20)];
        _titleLabel.textAlignment = 0;
        _titleLabel.text = @"";
        _titleLabel.font = [UIFont boldSystemFontOfSize:15.0];
        _titleLabel.numberOfLines = 1;
        _titleLabel.textColor = RGBCOLOR(0x23, 0x23, 0x33);
        [self.contentView addSubview:_titleLabel];
        
        
        _sendEmailLabel = [[UILabel alloc]initWithFrame:CGRectMake(15, 40, SCREEN_WIDTH-30, 46)];
        _sendEmailLabel.backgroundColor = [UIColor clearColor];
        _sendEmailLabel.textColor = RGBCOLOR(0x74, 0x74, 0x87);
        _sendEmailLabel.font = [UIFont systemFontOfSize:13.0];
        _sendEmailLabel.text = @"Your email account needs to be set up and configured in your OS before using \"Send Logs by Email\"";
        _sendEmailLabel.numberOfLines = 0;
        _sendEmailLabel.textAlignment = 0;
        [self.contentView addSubview:_sendEmailLabel];
            
        
        _arrow = [[UIImageView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH -26, 22.5, 14, 14)];
        _arrow.image = [UIImage imageNamed:@"arrow_right"];
        [self.contentView addSubview:_arrow];
        
        _line = [[UIView alloc] initWithFrame:CGRectMake(15, 59, SCREEN_WIDTH-30, 1)];
        _line.backgroundColor = RGBCOLOR(0xED, 0xED, 0xF4);
        [self.contentView addSubview:_line];
        
    }
    return self;
}


@end
