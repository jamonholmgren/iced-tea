//
//  ChatInputHelper.m
//  ZoomVideoSample
//
//  Created by Zoom Video Communications on 2019/5/29.
//  Copyright © 2019 Zoom. All rights reserved.
//

#import "ChatInputView.h"

#define kSendButtonWidth  40
#define kSpaceForLandscape  80

@interface ChatInputView ()<UITextFieldDelegate>
@property (nonatomic, strong) UIButton    *sendBtn;
@property (nonatomic, assign) UIView      *view;

@end

@implementation ChatInputView

- (id)initWithView:(UIView *)view
{
    self = [super init];
    if (self) {
        self.view = view;
        self.backgroundColor = [UIColor clearColor];
        [self initSubView];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didChangeRotate:) name:UIApplicationDidChangeStatusBarFrameNotification object:nil];
    }
    return self;
}

- (void)didChangeRotate:(NSNotification *)aNotification {
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    BOOL landscape = UIInterfaceOrientationIsLandscape(orientation);
    
    if (self.chatTextField.isEditing) {
        [self hideKeyBoard];
    }
    
    if (landscape) {
        if (orientation == UIInterfaceOrientationLandscapeRight && IPHONE_X) {
            self.frame = CGRectMake(SAFE_ZOOM_INSETS, SCREEN_HEIGHT-kInputViewHeight-10, SCREEN_WIDTH - kSpaceForLandscape - SAFE_ZOOM_INSETS, kInputViewHeight);
        } else {
            self.frame = CGRectMake(0, SCREEN_HEIGHT-kInputViewHeight-10, SCREEN_WIDTH - kSpaceForLandscape, kInputViewHeight);
        }
        self.chatTextField.frame = CGRectMake(15, 0, Width(self)-30, 40);
        self.sendBtn.frame = CGRectMake(Width(self)-kSendButtonWidth-15, 0, kSendButtonWidth, kSendButtonWidth);
    } else {
        self.frame = CGRectMake(0, SCREEN_HEIGHT-kInputViewHeight-10, SCREEN_WIDTH, kInputViewHeight);
        self.chatTextField.frame = CGRectMake(15, 0, Width(self)-30, 40);
        self.sendBtn.frame = CGRectMake(Width(self)-kSendButtonWidth-15, 0, kSendButtonWidth, kSendButtonWidth);
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
}

- (void)initSubView
{
    self.frame = CGRectMake(0, SCREEN_HEIGHT-kInputViewHeight-10, SCREEN_WIDTH, kInputViewHeight);
//    self.hidden = YES;
    
    self.chatTextField = [[UITextField alloc]initWithFrame:CGRectMake(15, 0, SCREEN_WIDTH-30, 40)];
    self.chatTextField.leftView     = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 15, 40)];
    self.chatTextField.leftViewMode = UITextFieldViewModeAlways;
    self.chatTextField.rightView    = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 15, 40)];
    self.chatTextField.rightViewMode= UITextFieldViewModeAlways;
    self.chatTextField.textColor = [UIColor whiteColor];
    self.chatTextField.font = [UIFont systemFontOfSize:15];
    NSAttributedString *attrString = [[NSAttributedString alloc] initWithString:@"Type comment" attributes:@{NSForegroundColorAttributeName:RGBCOLOR(0xba, 0xba, 0xcc),NSFontAttributeName:self.chatTextField.font}];
    self.chatTextField.attributedPlaceholder = attrString;
    self.chatTextField.backgroundColor = [UIColor colorWithWhite:0 alpha:0.6];
    self.chatTextField.layer.cornerRadius = 5;
    self.chatTextField.layer.borderColor = [UIColor colorWithWhite:1.0 alpha:0.5].CGColor;
    self.chatTextField.layer.borderWidth = 1.0;
    [self.chatTextField setClipsToBounds:YES];
    
    [self.chatTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    self.chatTextField.returnKeyType = UIReturnKeySend;
    self.chatTextField.delegate = self;
    [self addSubview:self.chatTextField];
    
    self.sendBtn = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-kSendButtonWidth-15, 0, kSendButtonWidth, kSendButtonWidth)];
    [self.sendBtn setBackgroundImage:[UIImage imageNamed:@"send"] forState:UIControlStateNormal];
    [self.sendBtn addTarget: self action: @selector(onSendClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.sendBtn];
    self.sendBtn.hidden = YES;
}



- (void)onSendClicked:(UIButton *)sender {
    [self sendAction];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self sendAction];
    return YES;
}

- (void)sendAction {
    
    if ([self.delegate respondsToSelector:@selector(sendAction:)]) {
        [self.delegate sendAction:self.chatTextField.text];
        
//        [self hideKeyBoard];
        self.chatTextField.text = @"";
//        [self hideSendButton];
    }
}

- (void)textFieldDidChange:(UITextField *)textField
{
    if (self.chatTextField.text.length == 0) {
        [self hideSendButton];
    } else {
        [self showSendButton];
    }
}

- (void)showSendButton {
    [UIView animateWithDuration:0.2 animations:^{
        self.chatTextField.frame = CGRectMake(15, 0, Width(self)-30-kSendButtonWidth-10, 40);
    }completion:^(BOOL finished) {
        self.sendBtn.hidden = NO;
        [self.view bringSubviewToFront:self];
    }];
}

- (void)hideSendButton {
    self.sendBtn.hidden = YES;
    [UIView animateWithDuration:0.2 animations:^{
        self.chatTextField.frame = CGRectMake(15, 0, Width(self)-30, 40);
    }completion:^(BOOL finished) {
    }];
}

- (void)showKeyBoard {
    self.hidden = NO;
    [self.chatTextField becomeFirstResponder];
}

- (void)hideKeyBoard {
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
}

- (void)keyBoardWillShow:(NSNotification *)notification {

    NSDictionary *userInfo = [NSDictionary dictionaryWithDictionary:notification.userInfo];
    CGRect keyBoardBounds  = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat keyBoardHeight = keyBoardBounds.size.height;
    CGFloat animationTime  = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    
    void (^animation)(void) = ^void(void) {
        self.transform = CGAffineTransformMakeTranslation(0, - keyBoardHeight);
    };
    
    if (animationTime > 0) {
        [UIView animateWithDuration:animationTime animations:animation];
    } else {
        animation();
    }
}

- (void)keyBoardWillHide:(NSNotification *)notification {
    NSDictionary *userInfo = [NSDictionary dictionaryWithDictionary:notification.userInfo];
    CGFloat animationTime  = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    
    void (^animation)(void) = ^void(void) {
        self.transform = CGAffineTransformIdentity;
    };
    
    if (animationTime > 0) {
        [UIView animateWithDuration:animationTime animations:animation];
    } else {
        animation();
    }
//    self.hidden = YES;
    [self hideSendButton];
}

@end
