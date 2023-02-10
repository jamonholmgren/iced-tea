//
//  CmdChannelHelper.h
//  ZoomVideoSample
//
//  Created by Zoom on 2021/12/31.
//  Copyright © 2021 Zoom. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FeedbackPopViewController.h"
#import "FeedbackSurveyResultTableViewCell.h"

typedef NS_ENUM(NSUInteger, CmdTpye) {
    CmdTpye_None = 0,
    CmdTpye_Reaction = 1,
    CmdTpye_Feedback_Push = 2,
    CmdTpye_Feedback_Submit = 3,
    CmdTpye_Lowerthird = 4,
};

typedef NS_ENUM(NSUInteger, kTagReactionTpye) {
    kTagReactionTpye_None = 1000,
    kTagReactionTpye_Clap,
    kTagReactionTpye_Thumbsup,
    kTagReactionTpye_Heart,
    kTagReactionTpye_Joy,
    kTagReactionTpye_Hushed,
    kTagReactionTpye_Tada,
    kTagReactionTpye_Raisehand,
    kTagReactionTpye_Lowerhand,
};

@interface CmdChannelHelper : NSObject
+ (CmdChannelHelper *)sharedInstance;

- (CmdTpye)getCmdTypeFromCmd:(NSString *)cmdString;

// ****reaction*******
@property (nonatomic, assign)   BOOL                    isRaiseHand;
@property (nonatomic, assign)   kTagReactionTpye        reactionType;
- (BOOL)sendReactionCmd:(kTagReactionTpye)type;
- (kTagReactionTpye)getReactionTypeFromCmd:(NSString *)cmdString;
- (UIImage *)getReactionImageFromType:(kTagReactionTpye)type;
- (NSString *)generateReactionCmdString:(kTagReactionTpye)type;
// ****lower Third*******



// ****feedback*******
@property (nonatomic, strong)   NSMutableArray          *feedbackSource;
@property (nonatomic, assign) BOOL   hasPush;//for host
@property (nonatomic, assign) BOOL   hasSubmit;//for participant
- (void)initFeedbackItem;
- (void)clearFeedbackItem;
- (void)processFeedbackData:(NSString *)cmdString;
- (NSString *)generateFeedbackPushCmdString;
- (NSString *)generateFeedbackSubmitCmdString:(kTagFeedbackTpye)type;
- (kTagFeedbackTpye)getFeedbackTypeFromCmd:(NSString *)cmdString;
- (BOOL)sendFeedbackPushCmd;
- (BOOL)sendFeedbackSubmitCmd:(kTagFeedbackTpye)type;
@end

