//
//  CreateViewController.h
//  ZoomVideoSample
//
//  Created by Zoom Video Communications on 2019/6/5.
//  Copyright © 2019 Zoom. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, ZoomVideoCreateJoinType) {
    ZoomVideoCreateJoinType_Create      = 0,
    ZoomVideoCreateJoinType_Join
};

@interface CreateViewController : UIViewController
@property (nonatomic, assign) ZoomVideoCreateJoinType type;
@end


