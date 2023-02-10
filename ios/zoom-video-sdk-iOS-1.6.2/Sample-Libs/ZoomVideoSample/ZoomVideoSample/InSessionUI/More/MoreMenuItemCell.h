//
//  MoreMenuItemCell.h
//  ZoomVideoSample
//
//  Created by Zoom on 2021/12/30.
//  Copyright © 2021 Zoom. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

#define MenuItem_Height 50.0f

typedef NS_ENUM(NSUInteger, kTagMoreMenuTpye) {
    kTagMoreMenuTpye_Mute,
    kTagMoreMenuTpye_TurnOnoffSpeaker,
    kTagMoreMenuTpye_SwitchCamera,
    kTagMoreMenuTpye_LowerThird,
    kTagMoreMenuTpye_Feedback,
    kTagMoreMenuTpye_RaiseLowerHand
};

@interface MoreMenuItem : NSObject
@property (nonatomic, assign) kTagMoreMenuTpye type;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *icon;
@end


@interface MoreMenuItemCell : UITableViewCell
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIImageView *iconImageView;
@end

NS_ASSUME_NONNULL_END
