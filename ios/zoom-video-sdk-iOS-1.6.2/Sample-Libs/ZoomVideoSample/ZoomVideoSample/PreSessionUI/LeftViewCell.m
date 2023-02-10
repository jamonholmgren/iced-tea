//
//  LeftViewCell.m
//  ZoomVideoSample
//
//  Created by Zoom Video Communications on 2019/10/24.
//  Copyright © 2019 Zoom. All rights reserved.
//

#import "LeftViewCell.h"

@implementation LeftViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        self.backgroundColor = [UIColor clearColor];
        
        self.textLabel.font = [UIFont systemFontOfSize:15];
        self.textLabel.textColor = RGBCOLOR(0x23, 0x23, 0x33);

        
        self.separatorView = [UIView new];
        self.separatorView.backgroundColor = RGBCOLOR(0xDE, 0xDE, 0xF4);;
        [self addSubview:self.separatorView];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGRect textLabelFrame = self.textLabel.frame;
    textLabelFrame.origin.x = MaxX(self.imageView)+15;;
    textLabelFrame.size.width = CGRectGetWidth(self.frame) - 16.0;
    self.textLabel.frame = textLabelFrame;
    
    CGFloat height = UIScreen.mainScreen.scale == 1.0 ? 1.0 : 0.5;
    
    self.separatorView.frame = CGRectMake(0.0,
                                          CGRectGetHeight(self.frame)-height,
                                          CGRectGetWidth(self.frame)*0.9,
                                          height);
}


@end

