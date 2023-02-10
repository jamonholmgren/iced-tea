//
//  ChatView.m
//  ZoomVideoSample
//
//  Created by Zoom Video Communications on 2019/5/27.
//  Copyright © 2019 Zoom. All rights reserved.
//

#import "ChatView.h"
#import "ChatCell.h"
#import "TopBarView.h"
#import "BottomBarView.h"
#import "ChatInputView.h"

@interface ChatView ()<UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) CAGradientLayer           *gradientLayer;
@end

@implementation ChatView

- (id)init
{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.chatMsgArray = [NSMutableArray array];
        [self initSubView];
    }
    return self;
}

- (void)scrollToBottom {
    if(_chatMsgArray.count > 0){
        NSIndexPath *indexpath = [NSIndexPath indexPathForRow:_chatMsgArray.count-1 inSection:0];
        [_tableView scrollToRowAtIndexPath:indexpath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
}

- (void)updateFrame:(BOOL)keyboardHidden notification:(NSNotification *)notification
{
    NSDictionary *userInfo = [NSDictionary dictionaryWithDictionary:notification.userInfo];
    CGRect keyBoardBounds  = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat keyBoardHeight = keyBoardBounds.size.height;
    
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    BOOL landscape = UIInterfaceOrientationIsLandscape(orientation);
    
    float x = 15;
    float y;
    float w = kChatViewWidth;
    float h = kChatViewHeight;
    
    if (!landscape) {
        if (keyboardHidden) {
            y = SCREEN_HEIGHT - kTableHeight - kChatViewHeight  - kInputViewHeight - 10;
            self.frame = CGRectMake(x, y, w, h);
            self.tableView.frame = CGRectMake(0, 0, w, h);
        } else {
            y = SCREEN_HEIGHT - keyBoardHeight - kInputViewHeight - kChatViewHeight- 10;
            self.frame = CGRectMake(x, y, w, h);
            self.tableView.frame = CGRectMake(0, 0, w, h);
        }
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    float x = 15;
    float y;
    float w;
    float h;
    
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    BOOL landscape = UIInterfaceOrientationIsLandscape(orientation);
    
    if (landscape) {
        if (orientation == UIInterfaceOrientationLandscapeRight && IPHONE_X) {
            x = SAFE_ZOOM_INSETS+10;
        }
        y = Top_Height+10;
        w = SCREEN_WIDTH/2;
        h = SCREEN_HEIGHT - kTableHeight - y - kInputViewHeight;
    } else {
        y = SCREEN_HEIGHT - kTableHeight - kChatViewHeight  - kInputViewHeight - 10;
        w = kChatViewWidth;
        h = kChatViewHeight;
    }
    self.frame = CGRectMake(x, y, w, h);
    self.tableView.frame = CGRectMake(0, 0, w, h);
}

- (void)initSubView {
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kChatViewWidth, kChatViewHeight) style:UITableViewStylePlain];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self addSubview:self.tableView];
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerClass:[ChatCell class] forCellReuseIdentifier:@"ChatCell"];
    self.tableView.backgroundColor = [UIColor clearColor];
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return self.chatMsgArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [ChatCell cellHeight:[_chatMsgArray objectAtIndex:indexPath.row]];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ChatCell" forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    [(ChatCell *)cell setCellValue:[_chatMsgArray objectAtIndex:indexPath.row]];
    return cell;
}

-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        ZoomVideoSDKChatMessage *msg =(ZoomVideoSDKChatMessage *)[_chatMsgArray objectAtIndex:indexPath.row];
        if ([[[ZoomVideoSDK shareInstance] getChatHelper] canChatMessageBeDeleted:msg.messageID]) {
            ZoomVideoSDKError ret = [[[ZoomVideoSDK shareInstance] getChatHelper] deleteChatMessage: msg.messageID];
            NSLog(@"DeleteChatMessageByMsgID : %@ ret:%lu",msg.messageID,(unsigned long)ret);
        }
        else {
            NSLog(@"Error: You can not delete the Message!!!");
        }
    }
}


@end
