//
//  RendererSelectTableViewCell.m
//  ZoomVideoSample
//
//  Created by Zoom Video Communications on 2019/10/29.
//  Copyright © 2019 Zoom. All rights reserved.
//

#import "RendererSelectTableViewCell.h"

@implementation RendererSelectTableViewCell

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
        self.contentView.backgroundColor = [UIColor whiteColor];
        
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 20, self.contentView.frame.size.width-80, 20)];
        _titleLabel.textAlignment = 0;
        _titleLabel.font = [UIFont boldSystemFontOfSize:16.0];
        _titleLabel.numberOfLines = 1;
        _titleLabel.textColor = RGBCOLOR(0x23, 0x23, 0x33);
        [self.contentView addSubview:_titleLabel];
        
        _descLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, MaxY(_titleLabel), self.contentView.frame.size.width-70, 20)];
        _descLabel.textAlignment = 0;
        _descLabel.font = [UIFont systemFontOfSize:12.0];
        _descLabel.numberOfLines = 0;
        _descLabel.textColor = RGBCOLOR(0x74, 0x74, 0x87);
        [self.contentView addSubview:_descLabel];
        
        _selectArrow = [[UIImageView alloc] initWithFrame:CGRectMake(MaxX(_descLabel), 25, 30, 30)];
        _selectArrow.image = [UIImage imageNamed:@"renderer_select"];
        [self.contentView addSubview:_selectArrow];
        
    }
    return self;
}

- (void)setCellValue:(NSDictionary *)itemData {
    self.titleLabel.text = [itemData objectForKey:@"title"];
    self.descLabel.text = [itemData objectForKey:@"desc"];
    [self setLabel:self.descLabel lineSpace:3];
    CGSize size = [self.descLabel sizeThatFits:CGSizeMake(CGRectGetWidth(self.descLabel.frame), MAXFLOAT)];
    CGRect frame2 = self.descLabel.frame;
    frame2.size.height = size.height;
    self.descLabel.frame = frame2;
}

- (void)setLabel:(UILabel *)label lineSpace:(CGFloat)space {
    
    if (!label || !label.text || [@"" isEqualToString:label.text]) {
        return;
    }
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
    paragraphStyle.lineSpacing = space;
    paragraphStyle.lineBreakMode = NSLineBreakByTruncatingTail;
    NSDictionary *attributes = @{NSFontAttributeName:label.font, NSParagraphStyleAttributeName:paragraphStyle};
    label.attributedText = [[NSAttributedString alloc]initWithString:label.text attributes:attributes];
}

@end
