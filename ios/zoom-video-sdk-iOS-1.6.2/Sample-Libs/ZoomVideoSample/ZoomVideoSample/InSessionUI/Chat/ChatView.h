//
//  ChatView.h
//  ZoomVideoSample
//
//  Created by Zoom Video Communications on 2019/5/27.
//  Copyright © 2019 Zoom. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kChatViewWidth  SCREEN_WIDTH*3/5
#define kChatViewHeight  SCREEN_HEIGHT/3

NS_ASSUME_NONNULL_BEGIN

@interface ChatView : UIView
@property (strong, nonatomic) NSMutableArray          *chatMsgArray;
@property (nonatomic, strong)   UITableView           *tableView;
- (void)scrollToBottom;
- (void)updateFrame:(BOOL)keyboardHidden notification:(NSNotification *)notification;
@end

NS_ASSUME_NONNULL_END
