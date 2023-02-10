//
//  MoreMenuItemCell.m
//  ZoomVideoSample
//
//  Created by Zoom on 2021/12/30.
//  Copyright © 2021 Zoom. All rights reserved.
//

#import "MoreMenuItemCell.h"

@implementation MoreMenuItem

@end

@implementation MoreMenuItemCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)layoutSubviews {
    [super layoutSubviews];
    [self updateConstraints];
    _iconImageView.frame = CGRectMake(self.bounds.size.width-MenuItem_Height, 0, MenuItem_Height, MenuItem_Height);
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.contentView.backgroundColor = [UIColor whiteColor];
        
        _iconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, MenuItem_Height, MenuItem_Height)];
        [self.contentView addSubview:_iconImageView];
        
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 200, MenuItem_Height)];
        _titleLabel.textAlignment = 0;
        _titleLabel.font = [UIFont systemFontOfSize:15];
        _titleLabel.numberOfLines = 1;
        _titleLabel.textColor = RGBCOLOR(0x23, 0x23, 0x23);
        [self.contentView addSubview:_titleLabel];
    }
    return self;
}

@end
