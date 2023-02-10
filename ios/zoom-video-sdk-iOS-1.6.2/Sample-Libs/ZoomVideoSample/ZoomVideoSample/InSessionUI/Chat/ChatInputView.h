//
//  ChatInputHelper.h
//  ZoomVideoSample
//
//  Created by Zoom Video Communications on 2019/5/29.
//  Copyright © 2019 Zoom. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kInputViewHeight  50

NS_ASSUME_NONNULL_BEGIN

@protocol ChatInputViewDelegate <NSObject>

- (void)sendAction:(NSString *)chatString;

@end

@interface ChatInputView : UIView

- (id)initWithView:(UIView *)view;

@property (strong, nonatomic) UITextField             *chatTextField;

@property (nonatomic,assign) id<ChatInputViewDelegate> delegate;

- (void)showKeyBoard;

- (void)hideKeyBoard;

- (void)keyBoardWillShow:(NSNotification *)notification;

- (void)keyBoardWillHide:(NSNotification *)notification;

@end

NS_ASSUME_NONNULL_END
