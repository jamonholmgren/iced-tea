//
//  SimulateStorage.h
//  ZoomVideoSample
//
//  Created by Zoom on 2022/1/4.
//  Copyright © 2022 Zoom. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FeedbackPopViewController.h"
#import "FeedbackSurveyResultTableViewCell.h"

#define kLowerThirdSavedNoti @"kNoti_LowerThirdSaved"

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

@interface LowerThirdCmd : NSObject
@property (nonatomic, strong) ZoomVideoSDKUser *user;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *desc;
@property (nonatomic, strong) NSString *colorStr;

- (UIColor *)getUsersColor;
@end


@interface SimulateStorage : NSObject

+ (SimulateStorage*)shareInstance;
- (void)clearUp;

- (CmdTpye)getCmdTypeFromCmd:(NSString *)cmdString;

// ****lower Third*******
+ (BOOL)isLowerThirdEnabled;
+ (void)enableLowerThird:(BOOL)enable;

+ (NSString *)myLowerThirdName;
+ (NSString *)myLowerThirdDesc;
+ (UIColor *)myLowerThirdColor;
+ (NSInteger)myLowerThirdColorIndex;

+ (NSArray *)colorArray;
+ (NSString *)lowerThirdColorString:(NSInteger)idx;

+ (BOOL)needBlackColorDesc:(UIColor *)color orColorString:(NSString *)str orIndex:(NSInteger)idx;

- (void)addMyLowerThird:(NSString *)name desc:(NSString *)desc colorIndex:(NSInteger)idx;
- (void)addLowerThird:(NSString *)lowerString withUser:(ZoomVideoSDKUser *)user;
- (LowerThirdCmd *)getUsersLowerThird:(ZoomVideoSDKUser *)user;
- (BOOL)sendMyLowerThird;

// ****reaction*******
@property (nonatomic, assign)   BOOL                    isRaiseHand;
@property (nonatomic, assign)   kTagReactionTpye        reactionType;
- (BOOL)sendReactionCmd:(kTagReactionTpye)type;
- (kTagReactionTpye)getReactionTypeFromCmd:(NSString *)cmdString;
- (UIImage *)getReactionImageFromType:(kTagReactionTpye)type;
- (NSString *)generateReactionCmdString:(kTagReactionTpye)type;


// ****feedback*******
+ (BOOL)hasPopConfirmView;
+ (void)hasPopConfirmView:(BOOL)enable;

@property (nonatomic, strong)   NSMutableArray          *feedbackSource;
- (void)initFeedbackItem;
- (void)processFeedbackData:(NSString *)cmdString sendUser:(NSNumber *)userId;
- (NSString *)generateFeedbackPushCmdString;
- (NSString *)generateFeedbackSubmitCmdString:(kTagFeedbackTpye)type;
- (kTagFeedbackTpye)getFeedbackTypeFromCmd:(NSString *)cmdString;
- (BOOL)sendFeedbackPushCmd;
- (BOOL)sendFeedbackSubmitCmd:(kTagFeedbackTpye)type;
@end

