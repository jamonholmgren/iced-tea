//
//  TopBarView.m
//  ZoomVideoSample
//
//  Created by Zoom Video Communications on 2019/5/27.
//  Copyright © 2019 Zoom. All rights reserved.
//

#import "TopBarView.h"

#define kTagButtonEnd           1000

@interface TopBarView ()
@property (strong, nonatomic) CAGradientLayer *gradientLayer;
@property (strong, nonatomic) UIView          *leftView;
@property (strong, nonatomic) UIImageView     *lockedImageView;
@property (strong, nonatomic) UILabel         *sessionName;
@property (strong, nonatomic) UILabel         *sessionNumber;
@end

@implementation TopBarView

- (id)init
{
    self = [super init];
    if (self) {
        self.gradientLayer = [CAGradientLayer layer];
        self.gradientLayer.frame = self.bounds;
        [self.layer addSublayer:self.gradientLayer];
        self.gradientLayer.startPoint = CGPointMake(0.5, 0);
        self.gradientLayer.endPoint = CGPointMake(0.5, 1);
        self.gradientLayer.colors = @[(__bridge id)[UIColor colorWithWhite:0.f alpha:0.6].CGColor,
                                      (__bridge id)[UIColor colorWithWhite:0.f alpha:0.0].CGColor];
        
        [self initSubView];
    }
    return self;
}

- (void)initSubView {
    _leaveBtn = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 16 - 48, IPHONE_X ? (44.0 + 15.0) : 20.0, 90, 32)];
    [_leaveBtn setTitle:@"LEAVE" forState:UIControlStateNormal];
    _leaveBtn.titleLabel.font = [UIFont boldSystemFontOfSize:15];
    [_leaveBtn setTitleColor:RGBCOLOR(224,40,40) forState:UIControlStateNormal];
    _leaveBtn.backgroundColor = [UIColor colorWithWhite:0 alpha:0.6];
    _leaveBtn.layer.cornerRadius = _leaveBtn.frame.size.height/2;
    _leaveBtn.tag = kTagButtonEnd;
    [_leaveBtn addTarget:self action:@selector(onTopButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.leaveBtn];
    
    _leftView = [[UIView alloc] initWithFrame:CGRectMake(8, IPHONE_X ? (SAFE_ZOOM_INSETS + 8.0) : 8.0, 180, 60)];
    _leftView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.6];
    _leftView.clipsToBounds = YES;
    _leftView.layer.cornerRadius = 10;
    
    _leftView.userInteractionEnabled = YES;
    UITapGestureRecognizer * tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onClickedSessionInfo)];
    [_leftView addGestureRecognizer:tapGesture];
    [self addSubview:self.leftView];
    
    UIImage *lockImage = [UIImage imageNamed:@"locked"];
    _sessionName = [[UILabel alloc] initWithFrame:CGRectMake(10, 13, _leftView.frame.size.width - 15 - lockImage.size.width, 19)];
    _sessionName.textColor = [UIColor whiteColor];
    _sessionName.text = @"";
    _sessionName.font = [UIFont boldSystemFontOfSize:16];
    [self.leftView addSubview:_sessionName];
    
    _lockedImageView = [[UIImageView alloc] initWithImage:lockImage];
    _lockedImageView.frame = CGRectMake(CGRectGetMaxX(_sessionName.frame), 9, lockImage.size.width, lockImage.size.height);
    [self.leftView addSubview:_lockedImageView];
    
    _sessionNumber = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMinX(_sessionName.frame), CGRectGetMaxY(_sessionName.frame), _leftView.frame.size.width-10 - _lockedImageView.frame.size.width, 20)];
    _sessionNumber.textColor = [UIColor whiteColor];
    _sessionNumber.text = @"";
    _sessionNumber.font = [UIFont systemFontOfSize:13];
    [self.leftView addSubview:_sessionNumber];
    
}

- (void)dealloc {
    self.gradientLayer = nil;
    _leaveBtn = nil;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self updateFrame];
}

- (void)updateFrame {
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    BOOL landscape = UIInterfaceOrientationIsLandscape(orientation);
    
    if (landscape) {
        self.frame = CGRectMake(0, 0, SCREEN_WIDTH, Top_Height);
        self.leaveBtn.frame = CGRectMake(SCREEN_WIDTH - 16 - 90, 20.0, 90, 32);
        if (orientation == UIInterfaceOrientationLandscapeRight && IPHONE_X) {
            self.leftView.frame =  CGRectMake(SAFE_ZOOM_INSETS+10, 8.0, 180, 60);
        } else {
            self.leftView.frame =  CGRectMake(8, 8.0, 180, 60);
        }
    } else {
        self.frame = CGRectMake(0, 0, SCREEN_WIDTH, IPHONE_X ? Top_Height + SAFE_ZOOM_INSETS : Top_Height);
        self.leftView.frame =  CGRectMake(8, IPHONE_X ? (SAFE_ZOOM_INSETS + 8.0) : 8.0, 180, 60);
        self.leaveBtn.frame = CGRectMake(SCREEN_WIDTH - 16 - 90, IPHONE_X ? SAFE_ZOOM_INSETS + 20.0 : 20.0, 90, 32);
    }
    
    self.gradientLayer.frame = self.bounds;
}

- (void)updateTopBarWithSessionName:(NSString *)sessionName totalNum:(NSUInteger)total password:(NSString *)password isJoined:(BOOL)isJoined{
    _sessionName.text = [NSString stringWithFormat:@"%@", sessionName];
    
    if (isJoined) {
        _sessionNumber.text = [NSString stringWithFormat:@"Participants:%@", @(total)];
    } else {
        _sessionNumber.text = [NSString stringWithFormat:@"Connecting..."];
    }
    
    if (password && password.length > 0) {
        [_lockedImageView setImage:[UIImage imageNamed:@"locked"]];
    } else {
        [_lockedImageView setImage:[UIImage imageNamed:@"unlocked"]];
    }
    
    [self updateFrame];
}

- (void)onTopButtonClicked:(UIButton *)sender
{
    switch (sender.tag) {
        case kTagButtonEnd:
        {
            if (self.endOnClickBlock) {
                self.endOnClickBlock();
            }
        }
        default:
            break;
    }
}

- (void)onClickedSessionInfo {
    if (self.sessionInfoOnClickBlock) {
        self.sessionInfoOnClickBlock();
    }
}

@end

