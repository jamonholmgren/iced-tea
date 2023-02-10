//
//  SimulateStorage.m
//  ZoomVideoSample
//
//  Created by Zoom on 2022/1/4.
//  Copyright © 2022 Zoom. All rights reserved.
//

#import "SimulateStorage.h"
#import "MoreMenuViewController.h"

#define kEnableLowerThird   @"kEnableLowerThird"
#define kLowerThirdName     @"kLowerThirdName"
#define kLowerThirddesc     @"kLowerThirddesc"
#define kLowerThirdColorIndex    @"kLowerThirdColorIndex"

#define kHasPopComfirmView @"kHasPopComfirmView"

#define ZOOM_UD [NSUserDefaults standardUserDefaults]
#define COLORARR @[@"#444B53", @"#1E71D6", @"#FD3D4A", @"#66CC84", @"#FF8422", @"#493AB7", @"#A477FF", @"#FFBF39"]

@interface SimulateStorage ()
@property (nonatomic, strong) NSMutableArray *lowerThirdArr;

+ (UIColor *)colorWithHexString:(NSString *)hexString;
@end

@implementation LowerThirdCmd
- (UIColor *)getUsersColor;
{
    return [SimulateStorage colorWithHexString:_colorStr];
}
@end

@implementation SimulateStorage

+ (SimulateStorage*)shareInstance;
{
    static SimulateStorage *instance = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [SimulateStorage new];
    });
    
    return instance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _lowerThirdArr = [[NSMutableArray alloc] init];
        [self initLowerThirdCmd];
    }
    return self;
}

- (void)initLowerThirdCmd
{
    ZoomVideoSDKSession *session = [[ZoomVideoSDK shareInstance] getSession];
    ZoomVideoSDKUser *my = [session getMySelf];
    if (!my) return;
    
    LowerThirdCmd *cmd = [self getUsersLowerThird:my];
    if (!cmd)
    {
        NSString *name = [SimulateStorage myLowerThirdName];
        NSString *desc = [SimulateStorage myLowerThirdDesc];
        NSInteger idx = [SimulateStorage myLowerThirdColorIndex];
        [self addMyLowerThird:name desc:(desc ? desc : @"") colorIndex:idx];
    }
}

/// for lower third
+ (BOOL)isLowerThirdEnabled;
{
    return [ZOOM_UD boolForKey:kEnableLowerThird];
}

+ (void)enableLowerThird:(BOOL)enable;
{
    [ZOOM_UD setBool:enable forKey:kEnableLowerThird];
    [ZOOM_UD synchronize];
}


+ (void)setLowerThirdName:(NSString *)name desc:(NSString *)description colorIndex:(NSInteger)index;
{
    if (!name || name.length == 0 || !description) {
        return;
    }
    
    [ZOOM_UD setObject:name forKey:kLowerThirdName];
    [ZOOM_UD setObject:description forKey:kLowerThirddesc];
    [ZOOM_UD setInteger:index forKey:kLowerThirdColorIndex];
    [ZOOM_UD synchronize];
    
}

+ (NSString *)myLowerThirdName;
{
    return [ZOOM_UD objectForKey:kLowerThirdName];
}

+ (NSString *)myLowerThirdDesc;
{
    return [ZOOM_UD objectForKey:kLowerThirddesc];
}

+ (NSInteger)myLowerThirdColorIndex;
{
    return [ZOOM_UD integerForKey:kLowerThirdColorIndex];
}

+ (UIColor *)myLowerThirdColor;
{
    NSArray *colorArr = [self colorArray];
    NSInteger colorIndex = [ZOOM_UD integerForKey:kLowerThirdColorIndex];
    if (colorIndex > colorArr.count) {
        return colorArr[0];
    }
    return colorArr[colorIndex];
}

+ (NSString *)lowerThirdColorString:(NSInteger)idx;
{
    NSArray *colorArr = COLORARR;
    if (idx > colorArr.count) {
        return colorArr[0];
    }
    return colorArr[idx];
}

+ (NSArray *)colorArray;
{
    NSArray *colorArr = COLORARR;
    NSMutableArray *colorList = [[NSMutableArray alloc] init];
    for (NSString *colorStr in colorArr) {
        [colorList addObject:[SimulateStorage colorWithHexString:colorStr]];
    }
    return colorList;
}

//#66CC84 3
//#FFBF39 7
//#FF8422 4
+ (BOOL)needBlackColorDesc:(UIColor *)color orColorString:(NSString *)str orIndex:(NSInteger)idx;
{
    if (color) {
        NSArray *colorArr = [self colorArray];
        if ([color isEqual:colorArr[3]] ||
            [color isEqual:colorArr[4]] ||
            [color isEqual:colorArr[7]]) {
            return YES;
        }
        return NO;
    }
    
    if (str) {
        NSArray *colorArr = COLORARR;
        if ([str isEqual:colorArr[3]] ||
            [str isEqual:colorArr[4]] ||
            [str isEqual:colorArr[7]]) {
            return YES;
        }
        return NO;
    }
    
    if (idx == 3  || idx == 4 || idx == 7)
        return YES;
    
    return NO;
}

- (void)addLowerThird:(NSString *)lowerString withUser:(ZoomVideoSDKUser *)user;
{
    if (!lowerString || !user) {
        return;
    }
    
    NSArray *parseArray = [lowerString componentsSeparatedByString:@"|"];
    if (!parseArray || parseArray.count != 4) return;
    
    NSString *typeStr = parseArray[0];
    NSString *name = parseArray[1];
    NSString *desc = parseArray[2];
    NSString *colorStr = parseArray[3];
    
    if (!typeStr || [typeStr integerValue] != CmdTpye_Lowerthird ||
        !name || name.length == 0 ||
        !colorStr || colorStr.length == 0)
        return;
    
    LowerThirdCmd *ltCmd = [LowerThirdCmd new];
    ltCmd.user = user;
    ltCmd.name = name;
    ltCmd.desc = desc;
    ltCmd.colorStr = colorStr;
    
    __block NSInteger objIndex = -1;
    [self.lowerThirdArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        LowerThirdCmd *ltCmd = (LowerThirdCmd *)obj;
        if ([ltCmd.user isEqual:user]) {
            objIndex = idx;
            *stop = YES;
        }
    }];
    
    if (objIndex != -1) [self.lowerThirdArr removeObjectAtIndex:objIndex];
    
    [self.lowerThirdArr addObject:ltCmd];
}

- (void)addMyLowerThird:(NSString *)name desc:(NSString *)desc colorIndex:(NSInteger)idx;
{
    if (!name) return;
    
    ZoomVideoSDKSession *session = [[ZoomVideoSDK shareInstance] getSession];
    ZoomVideoSDKUser *my = [session getMySelf];
    
    __block NSInteger objIndex = -1;
    [self.lowerThirdArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        LowerThirdCmd *ltCmd = (LowerThirdCmd *)obj;
        if ([ltCmd.user isEqual:my]) {
            objIndex = idx;
            *stop = YES;
        }
    }];

    if (objIndex != -1) [self.lowerThirdArr removeObjectAtIndex:objIndex];
    LowerThirdCmd *cmd = [LowerThirdCmd new];
    cmd.user = my;
    cmd.name = name;
    cmd.desc = desc ? desc : @"";
    cmd.colorStr = [SimulateStorage lowerThirdColorString:idx];
    
    [self.lowerThirdArr addObject:cmd];
    
    [SimulateStorage setLowerThirdName:cmd.name desc:cmd.desc colorIndex:idx];
}

- (LowerThirdCmd *)getUsersLowerThird:(ZoomVideoSDKUser *)user;
{
    if (!user)
        return nil;
    
    __block NSInteger objIndex = -1;
    [self.lowerThirdArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        LowerThirdCmd *ltCmd = (LowerThirdCmd *)obj;
        if ([ltCmd.user isEqual:user]) {
            objIndex = idx;
            *stop = YES;
        }
    }];
    
    if (objIndex != -1)
        return [self.lowerThirdArr objectAtIndex:objIndex];
    
    return nil;
}

- (BOOL)sendMyLowerThird
{
    ZoomVideoSDKSession *session = [[ZoomVideoSDK shareInstance] getSession];
    ZoomVideoSDKUser *my = [session getMySelf];
    if (!my)
        return NO;
    
    LowerThirdCmd *cmd = [self getUsersLowerThird:my];
    if (!cmd)
        return NO;
    
    NSString *descString = cmd.desc;
    if (!descString || descString.length == 0)
        descString = @"";
    
    NSString *cmdStr = [NSString stringWithFormat:@"%@|%@|%@|%@", @(CmdTpye_Lowerthird), cmd.name, descString, cmd.colorStr];
    ZoomVideoSDKError ret = [[[ZoomVideoSDK shareInstance] getCmdChannel] sendCommand:cmdStr receiveUser:nil];
    return ret == Errors_Success;
}

+ (UIColor *)colorWithHexString:(NSString *)hexString {
    NSString *cString = [[hexString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    if (cString.length < 6)
    return [UIColor clearColor];
    if ([cString hasPrefix:@"0X"])
    cString = [cString substringFromIndex:2];
    if ([cString hasPrefix:@"#"])
    cString = [cString substringFromIndex:1];
    if (cString.length != 6)
    return [UIColor clearColor];
    NSRange range;
    range.location = 0;
    range.length = 2;
    NSString *rString = [cString substringWithRange:range];
    range.location = 2;
    NSString *gString = [cString substringWithRange:range];
    range.location = 4;
    NSString *bString = [cString substringWithRange:range];
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    return [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1.0];
}

- (CmdTpye)getCmdTypeFromCmd:(NSString *)cmdString
{
    NSArray *parseArray = [cmdString componentsSeparatedByString:@"|"];
    if (!parseArray || parseArray.count < 2) {
        if ([cmdString intValue] == 2) {
            return CmdTpye_Feedback_Push;
        }
        return CmdTpye_None;
    }

    int type = [parseArray[0] intValue];
    CmdTpye cmd_type = CmdTpye_None;
    switch (type) {
        case 1:
            cmd_type = CmdTpye_Reaction;
            break;
        case 2:
            cmd_type = CmdTpye_Feedback_Push;
            break;
        case 3:
            cmd_type = CmdTpye_Feedback_Submit;
            break;
        case 4:
            cmd_type = CmdTpye_Lowerthird;
            break;
        default:
            break;
    }
    
    return cmd_type;
}

// ****reaction*******
- (BOOL)sendReactionCmd:(kTagReactionTpye)type {
    NSString * cmdString = [self generateReactionCmdString:type];
    if (!cmdString) return NO;
    
    ZoomVideoSDKError error = [[[ZoomVideoSDK shareInstance] getCmdChannel] sendCommand:cmdString receiveUser:nil];
    NSLog(@"Reaction::sendCommand===>%@",error == Errors_Success ? @"YES" : @"NO");
    return error == Errors_Success ? YES : NO;
}

- (NSString *)generateReactionCmdString:(kTagReactionTpye)type {
    NSString *cmdString;
    switch (type) {
        case kTagReactionTpye_Clap:
            cmdString = @"1|clap";
            break;
        case kTagReactionTpye_Thumbsup:
            cmdString = @"1|thumbsup";
            break;
        case kTagReactionTpye_Heart:
            cmdString = @"1|heart";
            break;
        case kTagReactionTpye_Joy:
            cmdString = @"1|joy";
            break;
        case kTagReactionTpye_Hushed:
            cmdString = @"1|hushed";
            break;
        case kTagReactionTpye_Tada:
            cmdString = @"1|tada";
            break;
        case kTagReactionTpye_Raisehand:
            cmdString = @"1|raisehand";
            break;
        case kTagReactionTpye_Lowerhand:
            cmdString = @"1|lowerhand";
            break;
        default:
            break;
    }
    return cmdString;
}

- (kTagReactionTpye)getReactionTypeFromCmd:(NSString *)cmdString
{
    NSArray *parseArray = [cmdString componentsSeparatedByString:@"|"];
    if (!parseArray || parseArray.count < 2) {
        return kTagReactionTpye_None;
    }
    
    kTagReactionTpye type = kTagReactionTpye_None;
    NSString * reactionString = parseArray[1];
    if (!reactionString) return kTagReactionTpye_None;
    
    if ([@"clap" isEqualToString:reactionString]) {
        type = kTagReactionTpye_Clap;
    } else if ([@"thumbsup" isEqualToString:reactionString]) {
        type = kTagReactionTpye_Thumbsup;
    } else if ([@"heart" isEqualToString:reactionString]) {
        type = kTagReactionTpye_Heart;
    } else if ([@"joy" isEqualToString:reactionString]) {
        type = kTagReactionTpye_Joy;
    } else if ([@"hushed" isEqualToString:reactionString]) {
        type = kTagReactionTpye_Hushed;
    } else if ([@"tada" isEqualToString:reactionString]) {
        type = kTagReactionTpye_Tada;
    } else if ([@"raisehand" isEqualToString:reactionString]) {
        type = kTagReactionTpye_Raisehand;
    } else if ([@"lowerhand" isEqualToString:reactionString]) {
        type = kTagReactionTpye_Lowerhand;
    }
    
    return type;
}

- (UIImage *)getReactionImageFromType:(kTagReactionTpye)type
{
    UIImage *image = nil;
    switch (type) {
        case kTagReactionTpye_Clap:
            image = [UIImage imageNamed:@"reaction_clap"];
            break;
        case kTagReactionTpye_Thumbsup:
            image = [UIImage imageNamed:@"reaction_thumbsup"];
            break;
        case kTagReactionTpye_Heart:
            image = [UIImage imageNamed:@"reaction_heart"];
            break;
        case kTagReactionTpye_Joy:
            image = [UIImage imageNamed:@"reaction_joy"];
            break;
        case kTagReactionTpye_Hushed:
            image = [UIImage imageNamed:@"reaction_hushed"];
            break;
        case kTagReactionTpye_Tada:
            image = [UIImage imageNamed:@"reaction_tada"];
            break;
        case kTagReactionTpye_Raisehand:
            image = [UIImage imageNamed:@"reaction_raisehand"];
            break;
        default:
            break;
    }
    
    return image;
}

// ****feedback*******
+ (BOOL)hasPopConfirmView
{
    return [ZOOM_UD boolForKey:kHasPopComfirmView];
}

+ (void)hasPopConfirmView:(BOOL)enable
{
    [ZOOM_UD setBool:enable forKey:kHasPopComfirmView];
    [ZOOM_UD synchronize];
}

- (NSString *)generateFeedbackPushCmdString
{
    return @"2";
}

- (NSString *)generateFeedbackSubmitCmdString:(kTagFeedbackTpye)type
{
    NSString *cmdString = nil;
    switch (type) {
        case kTagFeedbackTpye_VerySatisfied:
            cmdString = @"3|verySatisfied";
            break;
        case kTagFeedbackTpye_Satisfied:
            cmdString = @"3|satisfied";
            break;
        case kTagFeedbackTpye_Neutral:
            cmdString = @"3|neutral";
            break;
        case kTagFeedbackTpye_Unsatisfied:
            cmdString = @"3|unsatisfied";
            break;
        case kTagFeedbackTpye_VeryUnsatisfied:
            cmdString = @"3|veryUnsatisfied";
            break;
        default:
            break;
    }
    return cmdString;
}

- (kTagFeedbackTpye)getFeedbackTypeFromCmd:(NSString *)cmdString
{
    NSArray *parseArray = [cmdString componentsSeparatedByString:@"|"];
    if (!parseArray || parseArray.count < 2) {
        return kTagFeedbackTpye_None;
    }

    kTagFeedbackTpye type = kTagFeedbackTpye_None;
    NSString * feedbackString = parseArray[1];
    if (!feedbackString) return kTagFeedbackTpye_None;
    
    if ([@"verySatisfied" isEqualToString:feedbackString]) {
        type = kTagFeedbackTpye_VerySatisfied;
    } else if ([@"satisfied" isEqualToString:feedbackString]) {
        type = kTagFeedbackTpye_Satisfied;
    } else if ([@"neutral" isEqualToString:feedbackString]) {
        type = kTagFeedbackTpye_Neutral;
    } else if ([@"unsatisfied" isEqualToString:feedbackString]) {
        type = kTagFeedbackTpye_Unsatisfied;
    } else if ([@"veryUnsatisfied" isEqualToString:feedbackString]) {
        type = kTagFeedbackTpye_VeryUnsatisfied;
    }
    
    return type;
}

- (BOOL)sendFeedbackPushCmd {
    NSString * cmdString = [self generateFeedbackPushCmdString];
    if (!cmdString) return NO;
    
    ZoomVideoSDKError error = [[[ZoomVideoSDK shareInstance] getCmdChannel] sendCommand:cmdString receiveUser:nil];
    NSLog(@"Feedback::sendCommand===>%@",error == Errors_Success ? @"YES" : @"NO");
    return error == Errors_Success ? YES : NO;
}

- (BOOL)sendFeedbackSubmitCmd:(kTagFeedbackTpye)type {
    NSString * cmdString = [self generateFeedbackSubmitCmdString:type];
    if (!cmdString) return NO;
    
    ZoomVideoSDKError error = [[[ZoomVideoSDK shareInstance] getCmdChannel] sendCommand:cmdString receiveUser:nil];
    NSLog(@"Feedback::sendCommand===>%@",error == Errors_Success ? @"YES" : @"NO");
    return error == Errors_Success ? YES : NO;
}

- (void)clearUp
{
    [self.lowerThirdArr removeAllObjects];
    self.lowerThirdArr = nil;
    
    if (![SimulateStorage shareInstance].feedbackSource) {
        return;
    }
    [self.feedbackSource removeAllObjects];
    self.feedbackSource = nil;
}

- (void)initFeedbackItem
{
    if ([SimulateStorage shareInstance].feedbackSource) {
        return;
    }
    
    [SimulateStorage shareInstance].feedbackSource = [[NSMutableArray alloc] init];
    
    FeedbackSurvey * itemVerySatisfied = [[FeedbackSurvey alloc] init];
    itemVerySatisfied.title = @"Very Satisfied";
    itemVerySatisfied.icon = @"feedback_very_satisfied";
    itemVerySatisfied.responseCount = 0;
    itemVerySatisfied.type = kTagFeedbackTpye_VerySatisfied;
    itemVerySatisfied.responseUserArray = [[NSMutableArray alloc] init];
    [[SimulateStorage shareInstance].feedbackSource addObject:itemVerySatisfied];
    
    FeedbackSurvey * itemSatisfied = [[FeedbackSurvey alloc] init];
    itemSatisfied.title = @"Satisfied";
    itemSatisfied.icon = @"feedback_satisfied";
    itemSatisfied.responseCount = 0;
    itemSatisfied.type = kTagFeedbackTpye_Satisfied;
    itemSatisfied.responseUserArray = [[NSMutableArray alloc] init];
    [[SimulateStorage shareInstance].feedbackSource addObject:itemSatisfied];
    
    FeedbackSurvey * itemNeutral = [[FeedbackSurvey alloc] init];
    itemNeutral.title = @"Neutral";
    itemNeutral.icon = @"feedback_neutral";
    itemNeutral.responseCount = 0;
    itemNeutral.type = kTagFeedbackTpye_Neutral;
    itemNeutral.responseUserArray = [[NSMutableArray alloc] init];
    [[SimulateStorage shareInstance].feedbackSource addObject:itemNeutral];
    
    FeedbackSurvey * itemUnsatisfied = [[FeedbackSurvey alloc] init];
    itemUnsatisfied.title = @"Unsatisfied";
    itemUnsatisfied.icon = @"feedback_unsatisfied";
    itemUnsatisfied.responseCount = 0;
    itemUnsatisfied.type = kTagFeedbackTpye_Unsatisfied;
    itemUnsatisfied.responseUserArray = [[NSMutableArray alloc] init];
    [[SimulateStorage shareInstance].feedbackSource addObject:itemUnsatisfied];
    
    FeedbackSurvey * itemVeryUnsatisfied = [[FeedbackSurvey alloc] init];
    itemVeryUnsatisfied.title = @"Very Unsatisfied";
    itemVeryUnsatisfied.icon = @"feedback_very_unsatisfied";
    itemVeryUnsatisfied.responseCount = 0;
    itemVeryUnsatisfied.type = kTagFeedbackTpye_VeryUnsatisfied;
    itemVeryUnsatisfied.responseUserArray = [[NSMutableArray alloc] init];
    [[SimulateStorage shareInstance].feedbackSource addObject:itemVeryUnsatisfied];
}

- (void)processFeedbackData:(NSString *)cmdString sendUser:(NSNumber *)userId {
    if (!self.feedbackSource) {
        return;
    }
    
    kTagFeedbackTpye feedbackType = [self getFeedbackTypeFromCmd:cmdString];
    
    for (FeedbackSurvey *item in self.feedbackSource) {
        if (item.responseUserArray && [item.responseUserArray containsObject:userId]) {
            item.responseCount --;
            [item.responseUserArray removeObject:userId];
            break;
        }
    }
        
    for (FeedbackSurvey *item in self.feedbackSource) {
        if (item.responseUserArray && item.type == feedbackType) {
            item.responseCount ++;
            [item.responseUserArray addObject:userId];
        }
    }
        
    [[NSNotificationCenter defaultCenter] postNotificationName:Notification_ReceiveFeedbackAction object:nil];
}
@end
