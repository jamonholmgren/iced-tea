//
//  FeedbackSurveyResultViewController.m
//  ZoomVideoSample
//
//  Created by Zoom on 2022/1/4.
//  Copyright © 2022 Zoom. All rights reserved.
//

#import "FeedbackSurveyResultViewController.h"
#import "FeedbackSurveyResultTableViewCell.h"
#import "FeedbackPopViewController.h"
#import "SimulateStorage.h"
#import "MoreMenuViewController.h"


@interface FeedbackSurveyResultViewController ()<UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong)   UITableView             *tableView;
@property (nonatomic, strong)  UIButton * publishBtn;
@property (nonatomic, strong)  UILabel  * descLabel;
@property (nonatomic, strong)  UILabel  * tipsLabel;

@property (nonatomic, strong)  NSTimer  * timer;
@property (nonatomic, assign)  int count;
@end


@implementation FeedbackSurveyResultViewController



- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.view.backgroundColor = [UIColor whiteColor];

    [self initUI];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveFeedbackActionAction:) name:Notification_ReceiveFeedbackAction object:nil];
    
    int total = 0;
    for (FeedbackSurvey *feedback in [SimulateStorage shareInstance].feedbackSource) {
        total += feedback.responseCount;
    }
    _descLabel.text = [NSString stringWithFormat:@"%d responses",total];
}

- (void)receiveFeedbackActionAction:(NSNotification *)notification {
    [self.tableView reloadData];
}


- (UIImage *)imageWithColor:(UIColor *)color {
   CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
   UIGraphicsBeginImageContext(rect.size);
   CGContextRef context = UIGraphicsGetCurrentContext();

   CGContextSetFillColorWithColor(context, [color CGColor]);
   CGContextFillRect(context, rect);

   UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
   UIGraphicsEndImageContext();

   return image;
}

- (void)initUI {
    UIButton *cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 50, 100, 44)];
    [cancelButton setTitle:@"Close" forState:UIControlStateNormal];
    cancelButton.titleLabel.font = [UIFont systemFontOfSize:18];
    [cancelButton setTitleColor:RGBCOLOR(0x0E, 0x71, 0xEB) forState:UIControlStateNormal];
    [cancelButton addTarget:self action:@selector(onCloseBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:cancelButton];

    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake((SCREEN_WIDTH-200)/2, cancelButton.frame.origin.y, 200, 44)];
    titleLabel.textColor = RGBCOLOR(0x13, 0x16, 0x19);
    titleLabel.text = @"Feedback Survey";
    titleLabel.font = [UIFont boldSystemFontOfSize:18];
    titleLabel.textAlignment = 1;
    [self.view addSubview:titleLabel];
    
    UIView *descView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(titleLabel.frame), SCREEN_WIDTH, 30)];
    descView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:descView];
    
    _descLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, CGRectGetWidth(descView.frame)-40, CGRectGetHeight(descView.frame))];
    _descLabel.textColor = RGBCOLOR(0x6E, 0x76, 0x80);
    _descLabel.text = @"0 responses";
    _descLabel.font = [UIFont systemFontOfSize:14];
    _descLabel.textAlignment = 0;
    _descLabel.numberOfLines = 0;
    [descView addSubview:_descLabel];
    
    UIView *FeedbBacktitleView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(descView.frame), SCREEN_WIDTH, 50)];
    FeedbBacktitleView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:FeedbBacktitleView];
    
    UILabel *FeedbBacktitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, CGRectGetWidth(FeedbBacktitleView.frame)-40, CGRectGetHeight(FeedbBacktitleView.frame))];
    FeedbBacktitleLabel.textColor = RGBCOLOR(0x13, 0x16, 0x19);
    FeedbBacktitleLabel.text = @"How would you rate this session?";
    FeedbBacktitleLabel.font = [UIFont boldSystemFontOfSize:20];
    FeedbBacktitleLabel.textAlignment = 0;
    FeedbBacktitleLabel.numberOfLines = 0;
    [FeedbBacktitleView addSubview:FeedbBacktitleLabel];
        
    _publishBtn = [[UIButton alloc] initWithFrame:CGRectMake(30, SCREEN_HEIGHT-45-30, SCREEN_WIDTH-60, 45)];
//    [publishBtn setBackgroundColor:RGBCOLOR(0x0E, 0x71, 0xEB)];
    [_publishBtn setBackgroundImage:[self imageWithColor:RGBCOLOR(0x0E, 0x71, 0xEB)] forState:UIControlStateNormal];
    [_publishBtn setBackgroundImage:[self imageWithColor:RGBCOLOR(0xF1, 0xF4, 0xF6)] forState:UIControlStateDisabled];
    [_publishBtn setTitle:@"Push Feedback Survey" forState:UIControlStateNormal];
    _publishBtn.titleLabel.font = [UIFont boldSystemFontOfSize:16];
    [_publishBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_publishBtn setTitleColor:RGBCOLOR(0x6E, 0x76, 0x80) forState:UIControlStateDisabled];
    [_publishBtn addTarget:self action:@selector(onPublishClicked:) forControlEvents:UIControlEventTouchUpInside];
    _publishBtn.layer.cornerRadius = 10;
    _publishBtn.clipsToBounds = YES;
    [self.view addSubview:_publishBtn];
    
    _tipsLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, CGRectGetMinY(_publishBtn.frame)-30, SCREEN_WIDTH-40, 20)];
    _tipsLabel.textColor = RGBCOLOR(0x6E, 0x76, 0x80);
    _tipsLabel.text = @"The survey has been pushed. Re-push in 59s.";
    _tipsLabel.font = [UIFont systemFontOfSize:14];
    _tipsLabel.textAlignment = 1;
    _tipsLabel.numberOfLines = 0;
    [self.view addSubview:_tipsLabel];
    _tipsLabel.hidden = YES;
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(FeedbBacktitleView.frame), SCREEN_WIDTH, SCREEN_HEIGHT-290) style:UITableViewStylePlain];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.rowHeight = cell_result_heght;
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.separatorColor = [UIColor clearColor];
    self.tableView.scrollEnabled = YES;
    [self.tableView registerClass:[FeedbackSurveyResultTableViewCell class] forCellReuseIdentifier:@"FeedbackSurveyResultTableViewCell"];
    [self.view addSubview:self.tableView];
//    self.tableView.backgroundColor = [UIColor redColor];
}

- (void)onCloseBtnClicked:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];}

- (void)onPublishClicked:(id)sender
{
    BOOL hasPopConfirmView = [SimulateStorage hasPopConfirmView];
    
    if (hasPopConfirmView) {
        [[SimulateStorage shareInstance] sendFeedbackPushCmd];
        [self beginTimer];
    } else {
        [SimulateStorage hasPopConfirmView:YES];
        
        AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        FeedbackPopViewController * vc = [[FeedbackPopViewController alloc] init];
        vc.type = FeedbackPopViewTpye_Push;
        vc.modalPresentationStyle = UIModalPresentationPageSheet;
        __weak FeedbackSurveyResultViewController *weakSelf = self;
        vc.pushOnClickBlock = ^(void) {
            [weakSelf beginTimer];
        };
        [[appDelegate topViewController] presentViewController:vc animated:YES completion:nil];
    }
}

- (void)beginTimer {
    _tipsLabel.hidden = NO;
    [self.publishBtn setEnabled:NO];
    self.count = 60;
    self.timer = [NSTimer timerWithTimeInterval:1.0 target:self selector:@selector(countDown) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
}

- (void)countDown {
    self.count--;
    _tipsLabel.text = [NSString stringWithFormat:@"The survey has been pushed. Re-push in %ds.",self.count];
    
    if (self.count == 0) {
        [self.publishBtn setEnabled:YES];
        [self.timer invalidate];
         self.timer = nil;
    }
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [SimulateStorage shareInstance].feedbackSource.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.01;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.01;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FeedbackSurveyResultTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FeedbackSurveyResultTableViewCell" forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    FeedbackSurvey *item = [[SimulateStorage shareInstance].feedbackSource objectAtIndex:indexPath.row];
    cell.titleLabel.text = item.title;
    cell.iconImg.image = [UIImage imageNamed:item.icon];
    cell.responseLabel.text = [NSString stringWithFormat:@"%d responses", item.responseCount];
    
    float total = 0.00f;
    for (FeedbackSurvey *feedback in [SimulateStorage shareInstance].feedbackSource) {
        total += feedback.responseCount;
    }
    float percent = 0.00f;
    if (total != 0) {
        percent = item.responseCount/total;
    }
    cell.percentLabel.text = [NSString stringWithFormat:@"%.0f%%",percent*100];
    cell.progressView.progress = percent;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
