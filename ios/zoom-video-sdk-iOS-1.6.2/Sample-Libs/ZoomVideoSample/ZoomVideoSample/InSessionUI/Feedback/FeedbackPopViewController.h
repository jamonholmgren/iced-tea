//
//  FeedbackPopViewController.h
//  ZoomVideoSample
//
//  Created by Zoom on 2022/1/4.
//  Copyright © 2022 Zoom. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, FeedbackPopViewTpye) {
    FeedbackPopViewTpye_Push,
    FeedbackPopViewTpye_Receive,
    FeedbackPopViewTpye_AfterSubmit
};

typedef NS_ENUM(NSUInteger, kTagFeedbackTpye) {
    kTagFeedbackTpye_None = 2000,
    kTagFeedbackTpye_VerySatisfied,
    kTagFeedbackTpye_Satisfied,
    kTagFeedbackTpye_Neutral,
    kTagFeedbackTpye_Unsatisfied,
    kTagFeedbackTpye_VeryUnsatisfied,
};

@interface FeedbackPopViewController : UIViewController
@property (nonatomic,copy) void(^pushOnClickBlock)(void);
@property (nonatomic, assign) FeedbackPopViewTpye type;
@end
