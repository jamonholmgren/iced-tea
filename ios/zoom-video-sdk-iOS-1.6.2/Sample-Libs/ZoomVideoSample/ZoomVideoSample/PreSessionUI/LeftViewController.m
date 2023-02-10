//
//  LeftViewController.m
//  ZoomVideoSample
//
//  Created by Zoom Video Communications on 2019/10/24.
//  Copyright © 2019 Zoom. All rights reserved.
//

#import "LeftViewController.h"
#import "LeftViewCell.h"
#import "UIViewController+LGSideMenuController.h"
#import "MainViewController.h"
#import "LowerThirdSettingViewController.h"

@interface LeftViewController ()

@property (strong, nonatomic) NSArray *titlesArray;

@end

@implementation LeftViewController

- (id)init {
    self = [super initWithStyle:UITableViewStylePlain];
    if (self) {
        self.titlesArray = @[@"Video SDK Playground",
                             @"",
                             @"Lower Third",
                             @"Zoom Video SDK"];
        
        self.view.backgroundColor = [UIColor clearColor];
        
        [self.tableView registerClass:[LeftViewCell class] forCellReuseIdentifier:@"cell"];
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        self.tableView.contentInset = UIEdgeInsetsMake(44.0, 0.0, 44.0, 0.0);
        self.tableView.showsVerticalScrollIndicator = NO;
        self.tableView.backgroundColor = [UIColor clearColor];
        self.tableView.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
        
#ifndef DEBUG
        UILabel *versionLabel = [[UILabel alloc]initWithFrame:CGRectZero];
        if (IPHONE_X) {
            versionLabel.frame = CGRectMake(0, self.view.frame.size.height-self.navigationController.navigationBar.frame.size.height-40-25-SAFE_ZOOM_INSETS, Width(self.tableView)-100, 25);
        } else {
            versionLabel.frame = CGRectMake(0, self.view.frame.size.height-self.navigationController.navigationBar.frame.size.height-40-25, Width(self.tableView)-100, 25);
        }
        versionLabel.backgroundColor = [UIColor clearColor];
        versionLabel.textColor = RGBCOLOR(0x74, 0x74, 0x87);
        versionLabel.font = [UIFont systemFontOfSize:13.0];
        versionLabel.text = [NSString stringWithFormat:@"Version:%@",[[ZoomVideoSDK shareInstance] getSDKVersion]];
        versionLabel.numberOfLines = 1;
        versionLabel.textAlignment = 1;
        [self.tableView addSubview:versionLabel];
#endif
        
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleDefault;
}

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation {
    return UIStatusBarAnimationFade;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.titlesArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LeftViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    cell.textLabel.text = self.titlesArray[indexPath.row];
    cell.separatorView.hidden = indexPath.row <= 1;
    cell.userInteractionEnabled = (indexPath.row != 0 && indexPath.row != 1);
    
    if (indexPath.row == 0) {
        cell.textLabel.font = [UIFont boldSystemFontOfSize:17.0];
    } else {
        cell.textLabel.font = [UIFont systemFontOfSize:15.0];
    }
    
    if (indexPath.row == 2) {
        cell.imageView.image = [UIImage imageNamed:@"settings_icon"];
    } else if (indexPath.row == 3) {
        cell.imageView.image = [UIImage imageNamed:@"zoom_doc_icon"];
    } else {
        cell.imageView.image = nil;
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return (indexPath.row == 1) ? 22.0 : 44.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    if (indexPath.row == 2) {
        MainViewController *mainViewController = (MainViewController *)self.sideMenuController;
        [mainViewController hideLeftViewAnimated:YES completionHandler:nil];
        UINavigationController *navigationController = (UINavigationController *)mainViewController.rootViewController;
        
        LowerThirdSettingViewController *vc = [[LowerThirdSettingViewController alloc] init];
        vc.isPushed = YES;
        [navigationController pushViewController:vc animated:YES];
    }
    else if (indexPath.row == 3) {
        MainViewController *mainViewController = (MainViewController *)self.sideMenuController;
        [mainViewController hideLeftViewAnimated:YES completionHandler:nil];
        
        NSString *urlString = @"https://marketplace.zoom.us";
        if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:urlString]]) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
        }
    }
}

@end
