//
//  FeedbackPopViewController.m
//  ZoomVideoSample
//
//  Created by Zoom on 2022/1/4.
//  Copyright © 2022 Zoom. All rights reserved.
//

#import "FeedbackPopViewController.h"
#import "SimulateStorage.h"
#import "MoreMenuViewController.h"

@interface FeedbackPopViewController ()
@property (nonatomic, strong) UIButton *closeBtn;

@property (nonatomic, strong) UIView *submitBeforeBgView;
@property (nonatomic, strong) UIView *submitAftergView;
@property (nonatomic, strong) UIButton *submitBtn;

@property (nonatomic, strong) UIView *shadowView;
@property (nonatomic, strong) UILabel *descLabel;

@property (nonatomic, strong) UIView *pushBtnView;
@property (nonatomic, strong) UIView *receiveBtnView;

@property (nonatomic, strong) NSMutableArray *feedbackBtnArray;
@end

@implementation FeedbackPopViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self initBeforeSubmitUI];
        
        [self initAfterSubmitUI];
        
        [self showUIType:_type];
    });
}

- (void)showUIType:(FeedbackPopViewTpye)type {
    switch (type) {
        case FeedbackPopViewTpye_Push:
            _submitBeforeBgView.hidden = NO;
            _submitAftergView.hidden = YES;
            
            _closeBtn.hidden = YES;
            _shadowView.backgroundColor = RGBCOLOR_With_Alpha(0x52, 0x52, 0x80, 0.09);
            _descLabel.hidden = NO;
            _pushBtnView.hidden = NO;
            _receiveBtnView.hidden = YES;
            
            for (UIButton *btn in _feedbackBtnArray) {
                [btn setEnabled:NO];
            }
            break;
        case FeedbackPopViewTpye_Receive:
            _submitBeforeBgView.hidden = NO;
            _submitAftergView.hidden = YES;
            
            _closeBtn.hidden = NO;
            _shadowView.backgroundColor = [UIColor clearColor];
            _descLabel.hidden = YES;
            _pushBtnView.hidden = YES;
            _receiveBtnView.hidden = NO;
            
            for (UIButton *btn in _feedbackBtnArray) {
                [btn setEnabled:YES];
            }
          
            break;
        case FeedbackPopViewTpye_AfterSubmit:
            _submitBeforeBgView.hidden = YES;
            _submitAftergView.hidden = NO;
            break;
        default:
            break;
    }
}

- (void)initAfterSubmitUI {
    _submitAftergView = [[UIView alloc] initWithFrame:CGRectMake(20, SCREEN_HEIGHT-370, MenuItem_WIDTH, 290)];
    _submitAftergView.backgroundColor = [UIColor whiteColor];
    _submitAftergView.layer.cornerRadius = 15;
    [self.view addSubview:_submitAftergView];
    
    UIImageView * doneImg = [[UIImageView alloc] initWithFrame:CGRectMake((CGRectGetWidth(_submitAftergView.frame)-35)/2, 40, 35, 35)];
    doneImg.image = [UIImage imageNamed:@"feedback_done"];
    [_submitAftergView addSubview:doneImg];
    
    UILabel *thankLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(doneImg.frame)+30, CGRectGetWidth(_submitAftergView.frame), 40)];
    thankLabel.textColor = RGBCOLOR(0x13, 0x16, 0x19);
    thankLabel.text = @"Thank you for your feedback";
    thankLabel.font = [UIFont boldSystemFontOfSize:20];
    thankLabel.textAlignment = 1;
    thankLabel.numberOfLines = 0;
    [_submitAftergView addSubview:thankLabel];
    
    UIButton *doneBtn = [[UIButton alloc] initWithFrame:CGRectMake(20, CGRectGetHeight(_submitAftergView.frame)-45-30, CGRectGetWidth(_shadowView.frame), 45)];
    [doneBtn setBackgroundColor:RGBCOLOR(0x0E, 0x71, 0xEB)];
    [doneBtn setTitle:@"Done" forState:UIControlStateNormal];
    doneBtn.titleLabel.font = [UIFont boldSystemFontOfSize:16];
    [doneBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [doneBtn addTarget:self action:@selector(onCloseClicked:) forControlEvents:UIControlEventTouchUpInside];
    doneBtn.layer.cornerRadius = 10;
    doneBtn.clipsToBounds = YES;
    [_submitAftergView addSubview:doneBtn];
}

- (void)initBeforeSubmitUI {
    _submitBeforeBgView = [[UIView alloc] initWithFrame:CGRectMake(20, SCREEN_HEIGHT-370, MenuItem_WIDTH, 290)];
    _submitBeforeBgView.backgroundColor = [UIColor whiteColor];
    _submitBeforeBgView.layer.cornerRadius = 15;
    [self.view addSubview:_submitBeforeBgView];
    
    _shadowView = [[UIView alloc] initWithFrame:CGRectMake(15, 15, MenuItem_WIDTH-30, 160)];
    _shadowView.backgroundColor = RGBCOLOR_With_Alpha(0x52, 0x52, 0x80, 0.09);
    _shadowView.layer.cornerRadius = 10;
    [_submitBeforeBgView addSubview:_shadowView];
    
    _closeBtn = [[UIButton alloc] initWithFrame:CGRectMake(MenuItem_WIDTH-15-25, 15, 25, 25)];
    [_closeBtn setBackgroundImage:[UIImage imageNamed:@"feedback_close_icon"] forState:0];
    [_closeBtn addTarget:self action:@selector(onCloseClicked:) forControlEvents:UIControlEventTouchUpInside];
    [_submitBeforeBgView addSubview:_closeBtn];
    
    UILabel *FeedbBacktitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(_shadowView.frame), 80)];
    FeedbBacktitleLabel.textColor = RGBCOLOR(0x13, 0x16, 0x19);
    FeedbBacktitleLabel.text = @"How would you rate this\nsession?";
    FeedbBacktitleLabel.font = [UIFont boldSystemFontOfSize:20];
    FeedbBacktitleLabel.textAlignment = 1;
    FeedbBacktitleLabel.numberOfLines = 0;
    [_shadowView addSubview:FeedbBacktitleLabel];

    _feedbackBtnArray = [[NSMutableArray alloc] init];
    int feedback_btn_size = 35;
    UIView *feedbackView = [[UIView alloc] initWithFrame:CGRectMake(15, CGRectGetMaxY(FeedbBacktitleLabel.frame), CGRectGetWidth(_shadowView.frame)-30, 80)];
    [_shadowView addSubview:feedbackView];
    int space_width = (CGRectGetWidth(feedbackView.frame)-5*feedback_btn_size)/10;
    for (int i=0; i<5; i++) {
        UIButton *feedbackBtn = [[UIButton alloc] initWithFrame:CGRectMake(space_width + space_width*2*i + feedback_btn_size*i, (CGRectGetHeight(feedbackView.frame)-feedback_btn_size)/2, feedback_btn_size, feedback_btn_size)];
        switch (i) {
            case 0:
                [feedbackBtn setBackgroundImage:[UIImage imageNamed:@"feedback_very_satisfied_unselect"] forState:UIControlStateNormal];
                [feedbackBtn setBackgroundImage:[UIImage imageNamed:@"feedback_very_satisfied"] forState:UIControlStateSelected];
                feedbackBtn.tag = kTagFeedbackTpye_VerySatisfied;
                break;
            case 1:
                [feedbackBtn setBackgroundImage:[UIImage imageNamed:@"feedback_satisfied_unselect"] forState:UIControlStateNormal];
                [feedbackBtn setBackgroundImage:[UIImage imageNamed:@"feedback_satisfied"] forState:UIControlStateSelected];
                feedbackBtn.tag = kTagFeedbackTpye_Satisfied;
                break;
            case 2:
                [feedbackBtn setBackgroundImage:[UIImage imageNamed:@"feedback_neutral_unselect"] forState:UIControlStateNormal];
                [feedbackBtn setBackgroundImage:[UIImage imageNamed:@"feedback_neutral"] forState:UIControlStateSelected];
                feedbackBtn.tag = kTagFeedbackTpye_Neutral;
                break;
            case 3:
                [feedbackBtn setBackgroundImage:[UIImage imageNamed:@"feedback_unsatisfied_unselect"] forState:UIControlStateNormal];
                [feedbackBtn setBackgroundImage:[UIImage imageNamed:@"feedback_unsatisfied"] forState:UIControlStateSelected];
                feedbackBtn.tag = kTagFeedbackTpye_Unsatisfied;
                break;
            case 4:
                [feedbackBtn setBackgroundImage:[UIImage imageNamed:@"feedback_very_unsatisfied_unselect"] forState:UIControlStateNormal];
                [feedbackBtn setBackgroundImage:[UIImage imageNamed:@"feedback_very_unsatisfied"] forState:UIControlStateSelected];
                feedbackBtn.tag = kTagFeedbackTpye_VeryUnsatisfied;
                break;
            default:
                break;
        }
        [feedbackBtn addTarget:self action:@selector(onFeedbackClicked:) forControlEvents:UIControlEventTouchUpInside];
        [feedbackView addSubview:feedbackBtn];
        [_feedbackBtnArray addObject:feedbackBtn];
    }
    
    _descLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, CGRectGetMaxY(_shadowView.frame), CGRectGetWidth(_shadowView.frame), 40)];
    _descLabel.textColor = RGBCOLOR(0x13, 0x16, 0x19);
    _descLabel.text = @"Push this survey to all participants";
    _descLabel.font = [UIFont systemFontOfSize:14];
    _descLabel.textAlignment = 1;
    _descLabel.numberOfLines = 0;
    [_submitBeforeBgView addSubview:_descLabel];
    
    _pushBtnView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_descLabel.frame), CGRectGetWidth(_shadowView.frame), 45)];
    [_submitBeforeBgView addSubview:_pushBtnView];
    
    float btn_width = (CGRectGetWidth(_pushBtnView.frame)-20)/2;
    
    UIButton *cancelBtn = [[UIButton alloc] initWithFrame:CGRectMake(20, 0, btn_width, 45)];
    [cancelBtn setBackgroundColor:RGBCOLOR(0xF1, 0xF4, 0xF6)];
    [cancelBtn setTitle:@"Cancel" forState:UIControlStateNormal];
    cancelBtn.titleLabel.font = [UIFont boldSystemFontOfSize:16];
    [cancelBtn setTitleColor:RGBCOLOR(0x13, 0x16, 0x19) forState:UIControlStateNormal];
    [cancelBtn addTarget:self action:@selector(onCloseClicked:) forControlEvents:UIControlEventTouchUpInside];
    cancelBtn.layer.cornerRadius = 10;
    cancelBtn.clipsToBounds = YES;
    [_pushBtnView addSubview:cancelBtn];
    
    UIButton *pushBtn = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMaxX(cancelBtn.frame)+20, 0, btn_width, 45)];
    [pushBtn setBackgroundColor:RGBCOLOR(0x0E, 0x71, 0xEB)];
    [pushBtn setTitle:@"Push" forState:UIControlStateNormal];
    pushBtn.titleLabel.font = [UIFont boldSystemFontOfSize:16];
    [pushBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [pushBtn addTarget:self action:@selector(onPushClicked:) forControlEvents:UIControlEventTouchUpInside];
    pushBtn.layer.cornerRadius = 10;
    pushBtn.clipsToBounds = YES;
    [_pushBtnView addSubview:pushBtn];
    
    _receiveBtnView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_descLabel.frame), CGRectGetWidth(_shadowView.frame), 45)];
    [_submitBeforeBgView addSubview:_receiveBtnView];
    
    _submitBtn = [[UIButton alloc] initWithFrame:CGRectMake(20, 0, CGRectGetWidth(_shadowView.frame), 45)];
    [_submitBtn setBackgroundImage:[self imageWithColor:RGBCOLOR(0x0E, 0x71, 0xEB)] forState:UIControlStateNormal];
    [_submitBtn setBackgroundImage:[self imageWithColor:RGBCOLOR(0xF1, 0xF4, 0xF6)] forState:UIControlStateDisabled];
    [_submitBtn setTitle:@"Submit" forState:UIControlStateNormal];
    _submitBtn.titleLabel.font = [UIFont boldSystemFontOfSize:16];
    [_submitBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_submitBtn setTitleColor:RGBCOLOR(0x6E, 0x76, 0x80) forState:UIControlStateDisabled];
    [_submitBtn addTarget:self action:@selector(onSubmitClicked:) forControlEvents:UIControlEventTouchUpInside];
    _submitBtn.layer.cornerRadius = 10;
    _submitBtn.clipsToBounds = YES;
    [_receiveBtnView addSubview:_submitBtn];
    [_submitBtn setEnabled:NO];
}

- (UIImage *)imageWithColor:(UIColor *)color {
   CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
   UIGraphicsBeginImageContext(rect.size);
   CGContextRef context = UIGraphicsGetCurrentContext();

   CGContextSetFillColorWithColor(context, [color CGColor]);
   CGContextFillRect(context, rect);

   UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
   UIGraphicsEndImageContext();

   return image;
}

- (void)onSubmitClicked:(UIButton *)sender
{
    kTagFeedbackTpye type = kTagFeedbackTpye_None;
    for (UIButton *btn in _feedbackBtnArray) {
        if (btn.isSelected) {
            type = btn.tag;
        }
    }
    if (type != kTagFeedbackTpye_None) {
        [[SimulateStorage shareInstance] sendFeedbackSubmitCmd:type];
        [self showUIType:FeedbackPopViewTpye_AfterSubmit];
    }
}

- (void)onPushClicked:(UIButton *)sender
{
    [[SimulateStorage shareInstance] sendFeedbackPushCmd];
    [self dismissViewControllerAnimated:YES completion:nil];
    self.pushOnClickBlock();
}

- (void)onCloseClicked:(UIButton *)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)onFeedbackClicked:(UIButton *)sender
{
    for (UIButton *btn in _feedbackBtnArray) {
        [btn setSelected:NO];
    }
    [sender setSelected:YES];
    [_submitBtn setEnabled:YES];
}


@end
