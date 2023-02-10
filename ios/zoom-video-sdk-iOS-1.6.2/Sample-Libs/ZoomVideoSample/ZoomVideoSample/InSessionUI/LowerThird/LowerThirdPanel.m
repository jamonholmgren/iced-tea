//
//  LowerThirdPanel.m
//  ZoomVideoSample
//
//  Created by Zoom on 2022/1/5.
//  Copyright © 2022 Zoom. All rights reserved.
//

#import "LowerThirdPanel.h"

@interface MarginLabel ()
@property (nonatomic, assign) UIEdgeInsets pageMargin;
@end
@implementation MarginLabel

- (instancetype)initWithMargin:(UIEdgeInsets)margin
{
    self = [super init];
    if (self) {
        self.pageMargin = margin;
    }
    return self;
}

- (void)drawTextInRect:(CGRect)rect
{
    [super drawTextInRect:UIEdgeInsetsInsetRect(rect, self.pageMargin)];
}

@end

@interface LowerThirdPanel ()
//@property (strong, nonatomic) UILabel         *sessionNumber;
@end


@implementation LowerThirdPanel

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initSubViews];
    }
    
    return self;
}

- (void)setLowerThird:(LowerThirdCmd *)cmd
{
    if (!cmd) return;
    
    UIView *lineView = [self viewWithTag:31];
    UILabel *nameLabel = [self viewWithTag:32];
    UILabel *descLabel = [self viewWithTag:33];
    UIView *descBgView = [self viewWithTag:34];
    
    lineView.backgroundColor = [cmd getUsersColor];
    
    [descBgView.layer.sublayers[0] removeFromSuperlayer];
    CAShapeLayer *layer = [[CAShapeLayer alloc] init];
    UIBezierPath *bezier = [[UIBezierPath alloc] init];
    [bezier moveToPoint:CGPointMake(0, 0)];
    [bezier addLineToPoint:CGPointMake(descBgView.frame.size.width, 0)];
    [bezier addLineToPoint:CGPointMake(descBgView.frame.size.width - 10, descBgView.frame.size.height)];
    [bezier addLineToPoint:CGPointMake(0, descBgView.frame.size.height)];
    [bezier closePath];
    layer.path = bezier.CGPath;
    layer.fillColor = [cmd getUsersColor].CGColor;
    layer.strokeColor = UIColor.clearColor.CGColor;
    [descBgView.layer addSublayer:layer];
    
    descLabel.textColor = [UIColor whiteColor];
    if ([SimulateStorage needBlackColorDesc:nil orColorString:cmd.colorStr orIndex:0]) {
        descLabel.textColor = [UIColor blackColor];
    }
    
    CGRect frame = self.frame;
    if (cmd.desc && cmd.desc.length > 0)
    {
        frame.size.height = 60;
        self.frame = frame;
        lineView.frame = CGRectMake(10, 8, 4, 40);
        nameLabel.frame = CGRectMake(24, 6, 100, 20);
        descLabel.hidden = NO;
        descBgView.hidden = NO;
    }
    else
    {
        frame.size.height = 48;
        self.frame = frame;
        lineView.frame = CGRectMake(10, 8, 4, 32);
        nameLabel.frame = CGRectMake(24, 10, 100, 25);
        descLabel.hidden = YES;
        descBgView.hidden = YES;
    }
    
    nameLabel.text = cmd.name;
    descLabel.text = cmd.desc;
}

- (void)initSubViews
{
    self.backgroundColor = RGBCOLOR(19, 22, 25);
    [self.layer setCornerRadius:12.0];
    [self setClipsToBounds:NO];
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(10, 8, 4, 40)];
    lineView.backgroundColor = [UIColor blackColor];
    lineView.tag = 31;
    lineView.layer.cornerRadius = 2.0;
    [lineView setClipsToBounds:YES];
    UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(24, 6, 100, 20)];
    nameLabel.textColor = [UIColor whiteColor];
    [nameLabel setFont:[UIFont systemFontOfSize:16]];
    nameLabel.tag = 32;
    
    MarginLabel *descLabel = [[MarginLabel alloc] initWithMargin:UIEdgeInsetsMake(0, 4, 0, 0)];
    descLabel.frame = CGRectMake(24, 30, 150, 18);
    descLabel.textColor = [UIColor whiteColor];
    descLabel.tag = 33;
    descLabel.font = [UIFont systemFontOfSize:13.0];
    
    UIView *descBgView = [[UIView alloc] initWithFrame:descLabel.frame];
    CAShapeLayer *layer = [[CAShapeLayer alloc] init];
    UIBezierPath *bezier = [[UIBezierPath alloc] init];
    [bezier moveToPoint:CGPointMake(0, 0)];
    [bezier addLineToPoint:CGPointMake(descBgView.frame.size.width, 0)];
    [bezier addLineToPoint:CGPointMake(descBgView.frame.size.width - 10, descBgView.frame.size.height)];
    [bezier addLineToPoint:CGPointMake(0, descBgView.frame.size.height)];
    [bezier closePath];
    layer.path = bezier.CGPath;
    layer.fillColor = [UIColor blackColor].CGColor;
    layer.strokeColor = UIColor.clearColor.CGColor;
    [descBgView.layer addSublayer:layer];
    descBgView.layer.cornerRadius = 2.0;
    [descBgView setClipsToBounds:YES];
    descBgView.tag = 34;
    
    [self addSubview:lineView];
    [self addSubview:nameLabel];
    [self addSubview:descBgView];
    [self addSubview:descLabel];
}


@end
