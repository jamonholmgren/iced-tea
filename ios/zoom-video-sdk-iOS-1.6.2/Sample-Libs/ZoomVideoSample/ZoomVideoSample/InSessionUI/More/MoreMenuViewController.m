//
//  MoreMenuViewController.m
//  ZoomVideoSample
//
//  Created by Zoom on 2021/12/30.
//  Copyright © 2021 Zoom. All rights reserved.
//

#import "MoreMenuViewController.h"
#import "MoreMenuItemCell.h"
#import "SimulateStorage.h"
#import "FeedbackSurveyResultViewController.h"
#import "FeedbackPopViewController.h"
#import "MoreMenuHelper.h"
#import "LowerThirdSettingViewController.h"

@interface MoreMenuViewController ()<UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong)   UITableView             *tableView;
@property (nonatomic, strong)   NSMutableArray          *dataSource;
@end

@implementation MoreMenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self initUI];
        [self addMenuItem];
    });
}

-(void)handleSingleTap:(UITapGestureRecognizer *)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)initUI {
    UIView *tapView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, SCREEN_HEIGHT-(MenuItem_Height*7+80)-80)];
    tapView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:tapView];
    UITapGestureRecognizer* singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    [tapView addGestureRecognizer:singleTap];
    
    UIView *itemView = [[UIView alloc] initWithFrame:CGRectMake(20, SCREEN_HEIGHT-(MenuItem_Height*7+80)-80, MenuItem_WIDTH, MenuItem_Height*7+80)];
    itemView.backgroundColor = [UIColor whiteColor];
    itemView.layer.cornerRadius = 15;
    [self.view addSubview:itemView];
    
    // *********title**********
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(itemView.frame), MenuItem_Height)];
    headerView.backgroundColor = [UIColor whiteColor];
    headerView.layer.cornerRadius = 15;
    [itemView addSubview:headerView];
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 100, MenuItem_Height)];
    titleLabel.textAlignment = 0;
    titleLabel.font = [UIFont boldSystemFontOfSize:18];
    titleLabel.numberOfLines = 1;
    titleLabel.textColor = RGBCOLOR(0x23, 0x23, 0x23);
    titleLabel.text = @"More";
    [headerView addSubview:titleLabel];
    
    // *********menu table**********
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(headerView.frame), CGRectGetWidth(itemView.frame), MenuItem_Height*6) style:UITableViewStylePlain];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.rowHeight = MenuItem_Height;
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.tableView registerClass:[MoreMenuItemCell class] forCellReuseIdentifier:@"MoreMenuItemCell"];
    self.tableView.backgroundColor = [UIColor whiteColor];
    [itemView addSubview:self.tableView];
    self.tableView.userInteractionEnabled = YES;
    
    // *********reaction view**********
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.tableView.frame), CGRectGetWidth(itemView.frame), MenuItem_Height+30)];
    footerView.layer.cornerRadius = 15;
    [itemView addSubview:footerView];

    int reaction_btn_size = 25;
    UIView *reactionView = [[UIView alloc] initWithFrame:CGRectMake(20, (CGRectGetHeight(footerView.frame)-reaction_btn_size)/2, MenuItem_WIDTH-40, reaction_btn_size)];
    [footerView addSubview:reactionView];
    int space_width = (CGRectGetWidth(reactionView.frame)-6*reaction_btn_size)/12;
    for (int i=0; i<6; i++) {
        UIButton *reactionBtn = [[UIButton alloc] initWithFrame:CGRectMake(space_width + space_width*2*i + reaction_btn_size*i, 0, reaction_btn_size, reaction_btn_size)];
        switch (i) {
            case 0:
                [reactionBtn setBackgroundImage:[UIImage imageNamed:@"reaction_clap"] forState:0];
                reactionBtn.tag = kTagReactionTpye_Clap;
                break;
            case 1:
                [reactionBtn setBackgroundImage:[UIImage imageNamed:@"reaction_thumbsup"] forState:0];
                reactionBtn.tag = kTagReactionTpye_Thumbsup;
                break;
            case 2:
                [reactionBtn setBackgroundImage:[UIImage imageNamed:@"reaction_heart"] forState:0];
                reactionBtn.tag = kTagReactionTpye_Heart;
                break;
            case 3:
                [reactionBtn setBackgroundImage:[UIImage imageNamed:@"reaction_joy"] forState:0];
                reactionBtn.tag = kTagReactionTpye_Joy;
                break;
            case 4:
                [reactionBtn setBackgroundImage:[UIImage imageNamed:@"reaction_hushed"] forState:0];
                reactionBtn.tag = kTagReactionTpye_Hushed;
                break;
            case 5:
                [reactionBtn setBackgroundImage:[UIImage imageNamed:@"reaction_tada"] forState:0];
                reactionBtn.tag = kTagReactionTpye_Tada;
                break;
            default:
                break;
        }
        [reactionBtn addTarget:self action:@selector(onReactionClicked:) forControlEvents:UIControlEventTouchUpInside];
        [reactionView addSubview:reactionBtn];
    }
    [footerView addSubview:reactionView];
}

- (void)addMenuItem {
    self.dataSource = [[NSMutableArray alloc] init];

    MoreMenuItem * itemMute = [[MoreMenuItem alloc] init];
    itemMute.type = kTagMoreMenuTpye_Mute;
    ZoomVideoSDKUser *myUser = [[[ZoomVideoSDK shareInstance] getSession] getMySelf];
    if (myUser.audioStatus.audioType == ZoomVideoSDKAudioType_None) {
        itemMute.title = @"Join Audio";
        itemMute.icon = @"more_noaudio_icon";
    } else {
        if (!myUser.audioStatus.isMuted) {
            itemMute.title = @"Mute";
            itemMute.icon = @"more_mute_icon";
        } else {
            itemMute.title = @"unMute";
            itemMute.icon = @"more_unmute_icon";
        }
    }
    [self.dataSource addObject:itemMute];
    
    MoreMenuItem * itemSpeaker = [[MoreMenuItem alloc] init];
    itemSpeaker.type = kTagMoreMenuTpye_TurnOnoffSpeaker;
    if ([MoreMenuHelper sharedInstance].isSpeaker) {
       itemSpeaker.title = @"Turn off Speaker";
        itemSpeaker.icon = @"more_speaker_on_icon";
    } else {
       itemSpeaker.title = @"Turn on Speaker";
       itemSpeaker.icon = @"more_speaker_off_icon";
    }
    
    [self.dataSource addObject:itemSpeaker];
    
    MoreMenuItem * item3 = [[MoreMenuItem alloc] init];
    item3.type = kTagMoreMenuTpye_SwitchCamera;
    item3.title = @"Switch Camera";
    item3.icon = @"more_switch_camera_icon";
    [self.dataSource addObject:item3];
    
    MoreMenuItem * itemLowerThird = [[MoreMenuItem alloc] init];
    itemLowerThird.type = kTagMoreMenuTpye_LowerThird;
    itemLowerThird.title = @"Lower Third";
    itemLowerThird.icon = @"more_lower_third_icon";
    [self.dataSource addObject:itemLowerThird];
    
    MoreMenuItem * itemPoll = [[MoreMenuItem alloc] init];
    itemPoll.type = kTagMoreMenuTpye_Feedback;
    itemPoll.title = @"Feedback";
    itemPoll.icon = @"more_feedback_icon";
    [self.dataSource addObject:itemPoll];
    
    MoreMenuItem * itemHand = [[MoreMenuItem alloc] init];
    if ([SimulateStorage shareInstance].isRaiseHand == YES) {
        itemHand.type = kTagMoreMenuTpye_RaiseLowerHand;
        itemHand.title = @"Lower Hand";
        itemHand.icon = @"more_raisehand_icon";
    } else {
        itemHand.type = kTagMoreMenuTpye_RaiseLowerHand;
        itemHand.title = @"Raise Hand";
        itemHand.icon = @"more_lowerhand_icon";
    }
    [self.dataSource addObject:itemHand];
}

- (void)onReactionClicked:(UIButton *)sender{
    [[SimulateStorage shareInstance] sendReactionCmd:sender.tag];
    // simulator my self reaction.
    [[NSNotificationCenter defaultCenter] postNotificationName:Notification_mySelfReactionAction object:@(sender.tag)];
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return self.dataSource.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.01;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.01;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MoreMenuItemCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MoreMenuItemCell" forIndexPath:indexPath];
    MoreMenuItem *item = [self.dataSource objectAtIndex:indexPath.row];
    cell.titleLabel.text = item.title;
    cell.iconImageView.image = [UIImage imageNamed:item.icon];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    MoreMenuItem *item = [self.dataSource objectAtIndex:indexPath.row];
    MoreMenuItemCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (item.type == kTagMoreMenuTpye_RaiseLowerHand) {
        if ([SimulateStorage shareInstance].isRaiseHand == YES) {
            [[SimulateStorage shareInstance] sendReactionCmd:kTagReactionTpye_Lowerhand];
            [SimulateStorage shareInstance].isRaiseHand = NO;
            item.type = kTagMoreMenuTpye_RaiseLowerHand;
            item.title = @"Raise Hand";
            item.icon = @"more_lowerhand_icon";
            
            // simulator my self reaction.
            [[NSNotificationCenter defaultCenter] postNotificationName:Notification_mySelfReactionAction object:@(kTagReactionTpye_Lowerhand)];
        } else {
            [[SimulateStorage shareInstance] sendReactionCmd:kTagReactionTpye_Raisehand];
            [SimulateStorage shareInstance].isRaiseHand = YES;
            item.type = kTagMoreMenuTpye_RaiseLowerHand;
            item.title = @"Lower Hand";
            item.icon = @"more_raisehand_icon";
            
            // simulator my self reaction.
            [[NSNotificationCenter defaultCenter] postNotificationName:Notification_mySelfReactionAction object:@(kTagReactionTpye_Raisehand)];
        }
        cell.titleLabel.text = item.title;
        cell.iconImageView.image = [UIImage imageNamed:item.icon];
        [self dismissViewControllerAnimated:YES completion:nil];
    } else if (item.type == kTagMoreMenuTpye_Mute) {
        ZoomVideoSDKUser *myUser = [[[ZoomVideoSDK shareInstance] getSession] getMySelf];
        if (myUser.audioStatus.audioType == ZoomVideoSDKAudioType_None) {
            [[[ZoomVideoSDK shareInstance] getAudioHelper] startAudio];
        } else {
            if (!myUser.audioStatus.isMuted) {
                [[[ZoomVideoSDK shareInstance] getAudioHelper] muteAudio:myUser];
            } else {
                [[[ZoomVideoSDK shareInstance] getAudioHelper] unmuteAudio:myUser];
            }
        }
        [self dismissViewControllerAnimated:YES completion:nil];
    } else if (item.type == kTagMoreMenuTpye_TurnOnoffSpeaker) {
        [[MoreMenuHelper sharedInstance] switchSpeaker];
        [self dismissViewControllerAnimated:YES completion:nil];
    } else if (item.type == kTagMoreMenuTpye_SwitchCamera) {
        [[[ZoomVideoSDK shareInstance] getVideoHelper] switchCamera];
        [self dismissViewControllerAnimated:NO completion:nil];
    } else if (item.type == kTagMoreMenuTpye_Feedback) {
        [self dismissViewControllerAnimated:NO completion:nil];
        if ([[[[ZoomVideoSDK shareInstance] getSession] getMySelf] isHost]) {
            [[SimulateStorage shareInstance] initFeedbackItem];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
                FeedbackSurveyResultViewController * vc = [[FeedbackSurveyResultViewController alloc] init];
                vc.modalPresentationStyle = UIModalPresentationFullScreen;
                [[appDelegate topViewController] presentViewController:vc animated:YES completion:nil];
            });
        } else {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
                FeedbackPopViewController * vc = [[FeedbackPopViewController alloc] init];
                vc.type = FeedbackPopViewTpye_Receive;
                vc.modalPresentationStyle = UIModalPresentationPageSheet;
                [[appDelegate topViewController] presentViewController:vc animated:YES completion:nil];
            });
        }
    } else if (item.type == kTagMoreMenuTpye_LowerThird) {
        [self dismissViewControllerAnimated:NO completion:nil];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            LowerThirdSettingViewController *vc = [[LowerThirdSettingViewController alloc] init];
            vc.isPushed = NO;
            AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
            [[appDelegate topViewController] presentViewController:vc animated:YES completion:nil];
        });
    }
}




@end
