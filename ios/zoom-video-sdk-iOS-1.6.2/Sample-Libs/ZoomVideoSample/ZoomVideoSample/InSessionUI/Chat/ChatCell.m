//
//  ChatCell.m
//  ZoomVideoSample
//
//  Created by Zoom Video Communications on 2019/5/30.
//  Copyright © 2019 Zoom. All rights reserved.
//

#import "ChatCell.h"

@interface ChatCell()
@property (nonatomic, strong)   UILabel    *msgLabel;
@end


@implementation ChatCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        self.backgroundColor = [UIColor clearColor];
        self.contentView.backgroundColor = [UIColor clearColor];
        
        _msgbgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH*3/5, 30)];
        _msgbgView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.6];
        UIColor *borderColor = [UIColor colorWithWhite:1 alpha:0.5];
        _msgbgView.layer.borderWidth = 1;
        _msgbgView.layer.borderColor = borderColor.CGColor;
        _msgbgView.layer.cornerRadius = 7;
        [self.contentView addSubview:_msgbgView];
        
        _msgLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH*3/5-20, 30)];
        _msgLabel.backgroundColor = [UIColor clearColor];
        _msgLabel.textColor = [UIColor whiteColor];
        _msgLabel.font = [UIFont systemFontOfSize:15];
        _msgLabel.text = @"";
        _msgLabel.numberOfLines = 0;
        [_msgbgView addSubview:_msgLabel];
        
    }
    return self;
}

- (void)layoutSubviews {
    [self updateFrame];
    [super layoutSubviews];
}

- (void)updateFrame {
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    BOOL landscape = UIInterfaceOrientationIsLandscape(orientation);
    
    float w;
    if (landscape) {
        w = SCREEN_WIDTH/2;
    } else {
        w = SCREEN_WIDTH*3/5;
    }
    
    self.msgLabel.frame = CGRectMake(0, 0, w-20, 30);
    [self.msgLabel sizeToFit];
    self.msgbgView.frame = CGRectMake(0, 0, Width(self.msgLabel)+20, Height(self.msgLabel)+20);
    self.msgLabel.frame = CGRectMake(10, 10, Width(self.msgLabel), Height(self.msgLabel));
}

- (void)setCellValue:(ZoomVideoSDKChatMessage *)msg
{
    ZoomVideoSDKUser *sender = msg.senderUser;
    NSString *sendName = [self isNullObject:sender.getUserName]?@"":sender.getUserName;
    NSString *content = [self isNullObject:msg.content]?@"":msg.content;
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@: %@",sendName,content]];
    [attributedString addAttribute:NSForegroundColorAttributeName value:RGBCOLOR(0xba, 0xba, 0xcc) range:NSMakeRange(0,sendName.length+1)];
    self.msgLabel.attributedText = attributedString;
    
    [self updateFrame];
    
}

-(BOOL)isNullObject:(NSObject *)obj
{
    return obj == nil || [obj isKindOfClass:[NSNull class]];
}


+(CGFloat)cellHeight:(NSDictionary *)itemData{
    ChatCell *cell = [[ChatCell alloc] init];
    [cell setCellValue:itemData];
    [cell layoutSubviews];
    return CGRectGetMaxY(cell.msgbgView.frame)+5;
}

@end
