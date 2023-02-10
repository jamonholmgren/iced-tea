//
//  LowerThirdSettingViewController.m
//  ZoomVideoSample
//
//  Created by Zoom on 2021/12/31.
//  Copyright © 2021 Zoom. All rights reserved.
//

#import "LowerThirdSettingViewController.h"
#import "SimulateStorage.h"
#import "LowerThirdPanel.h"


@interface LowerThirdSettingViewController () <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) UIImageView *preview;
@property (nonatomic, strong) LowerThirdPanel *displayPanel;
@property (nonatomic, strong) UIView *settingPanel;
@property (nonatomic, strong) UIButton *saveBtn;
@property (nonatomic, assign) NSInteger selectColorIdx;

@end

@implementation LowerThirdSettingViewController

- (void)viewDidLoad {
    if (self.isPushed) {
        self.modalPresentationStyle = UIModalPresentationFullScreen;
        [self.navigationController.navigationBar setShadowImage:[[UIImage alloc] init]];
        [self.navigationController.navigationBar setTintColor:RGBCOLOR(0x2D, 0x8C, 0xFF)];
        self.navigationController.navigationBar.translucent = NO;
    }
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.frame];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.showsVerticalScrollIndicator = NO;
    tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    tableView.backgroundColor = [UIColor whiteColor];
    [tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.view addSubview:tableView];
    
    [self initNavBarItems];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        BOOL lowerThirdEnabled = [SimulateStorage isLowerThirdEnabled];
        {
            self.displayPanel.hidden = !lowerThirdEnabled;
            self.settingPanel.hidden = !lowerThirdEnabled;
        }
    });
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    if (!self.isPushed) {
        UIView *navBarView = [self.view viewWithTag:91];
        UILabel *titleLabel = [navBarView viewWithTag:95];
        
        navBarView.frame = CGRectMake(0, 0, self.view.bounds.size.width, 64);
        titleLabel.frame = CGRectMake(80, 0, self.view.bounds.size.width - 180, 64);
        self.saveBtn.frame = CGRectMake(self.view.bounds.size.width - 80, 0, 80, 64);
    }
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.01;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.01;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        CGFloat w = self.view.bounds.size.width - 32.0;
        CGFloat h = w * 509.0 / 382.0;
        CGFloat y = 8;
        if (!self.isPushed) {
            y = 72;
        }
        return h + y + 20;
    }
    else
        return 600.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] init];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if (indexPath.row == 0)
        [self initPreview:cell.contentView];
    else
        [self initSettingPanel:cell.contentView];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.view endEditing:YES];
}

- (void)initNavBarItems
{
    UIButton *closeBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 80, 64)];
    [closeBtn setTitle:@"Close" forState:UIControlStateNormal];
    closeBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    [closeBtn setTitleColor:RGBCOLOR(0x0e, 0x72, 0xed) forState:UIControlStateNormal];
    [closeBtn addTarget:self action:@selector(onCancelBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    self.saveBtn = [[UIButton alloc] initWithFrame:CGRectMake(self.view.bounds.size.width - 80, 0, 80, 64)];
    [self.saveBtn setTitle:@"Save" forState:UIControlStateNormal];
    self.saveBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    [self.saveBtn setTitleColor:RGBCOLOR(0x6e, 0x76, 0x80) forState:UIControlStateDisabled];
    [self.saveBtn setTitleColor:RGBCOLOR(0x0e, 0x72, 0xed) forState:UIControlStateNormal];
    [self.saveBtn addTarget:self action:@selector(onSaveBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    if (!self.isPushed) {
        UIView *navBarView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 64)];
        navBarView.backgroundColor = [UIColor whiteColor];
        navBarView.tag = 91;
        [self.view addSubview:navBarView];
        
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(80, 0, self.view.bounds.size.width - 180, 64)];
        titleLabel.text = @"Preview";
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.font = [UIFont boldSystemFontOfSize:17.];
        titleLabel.tag = 95;
        
        [navBarView addSubview:closeBtn];
        [navBarView addSubview:self.saveBtn];
        [navBarView addSubview:titleLabel];
    } else {
        self.navigationItem.title = @"Preview";
        
        UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:closeBtn];
        self.navigationItem.leftBarButtonItem = leftItem;
        
        UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:self.saveBtn];
        self.navigationItem.rightBarButtonItem = rightItem;
    }
}

- (void)initPreview:(UIView *)cell {
    CGFloat w = self.view.bounds.size.width - 32.0;
    CGFloat h = w * 509.0 / 382.0;
    CGFloat y = 8;
    if (!self.isPushed) {
        y = 72;
    }
    self.preview = [[UIImageView alloc] initWithFrame:CGRectMake(16, y, w, h)];
    self.preview.image = [UIImage imageNamed:@"lowerthirdicon"];
    self.preview.backgroundColor = [UIColor blueColor];
    self.preview.userInteractionEnabled = YES;
    [[self.preview layer] setCornerRadius:16.0];
    [self.preview setClipsToBounds:YES];
    
    [cell addSubview:self.preview];
    
    UIView *bottomBar = [[UIView alloc] initWithFrame:CGRectMake(0, self.preview.frame.size.height - 60, self.preview.frame.size.width, 60)];
    bottomBar.backgroundColor = RGBCOLOR(37, 42, 48);
    [self.preview addSubview:bottomBar];
    
    UILabel *lowerLabel = [[UILabel alloc] initWithFrame:CGRectMake(14, 0, 100, 60)];
    lowerLabel.text = @"Lower Third";
    lowerLabel.textColor = [UIColor whiteColor];
    [lowerLabel setFont:[UIFont systemFontOfSize:16.]];
    [bottomBar addSubview:lowerLabel];
    
    UISwitch *enableSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(bottomBar.frame.size.width - 65, 15, 100, 40)];
    [enableSwitch addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventValueChanged];
    enableSwitch.on = [SimulateStorage isLowerThirdEnabled];
    [bottomBar addSubview:enableSwitch];
    
    self.displayPanel = [[LowerThirdPanel alloc] initWithFrame:CGRectMake(16, 16, 150, 48)];
    [self.preview addSubview:self.displayPanel];
    
    ZoomVideoSDKSession *session = [[ZoomVideoSDK shareInstance] getSession];
    ZoomVideoSDKUser *my = [session getMySelf];
    LowerThirdCmd *cmd = [[SimulateStorage shareInstance] getUsersLowerThird:my];
    if (my && cmd) {
        [self.displayPanel setLowerThird:cmd];
    } else {
        LowerThirdCmd *cmd = [LowerThirdCmd new];
        cmd.name = [UIDevice currentDevice].name;
        cmd.user = my;
        cmd.colorStr = [SimulateStorage lowerThirdColorString:0];
        [self.displayPanel setLowerThird:cmd];
    }
}

- (void)initSettingPanel:(UIView *)cell {
    CGFloat y = 10;
    CGFloat w = CGRectGetWidth(self.preview.frame);
    self.settingPanel = [[UIView alloc] initWithFrame:CGRectMake(16, y, w, 400)];
    [cell addSubview:self.settingPanel];
    
    UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 74, 20)];
    nameLabel.text = @"Your Name";
    nameLabel.font = [UIFont systemFontOfSize:14.0];
    nameLabel.textColor = [UIColor blackColor];
    UILabel *redStar = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(nameLabel.frame), 0, 5, 16)];
    redStar.text = @"*";
    redStar.font = [UIFont systemFontOfSize:14.0];
    redStar.textColor = [UIColor redColor];
    [self.settingPanel addSubview:nameLabel];
    [self.settingPanel addSubview:redStar];
    
    UITextField *nameInput = [[UITextField alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(nameLabel.frame) + 5, w, 40)];
    nameInput.layer.cornerRadius = 10.0;
    nameInput.layer.borderColor = RGBCOLOR(110, 118, 128).CGColor;
    nameInput.layer.borderWidth = 1.0;
    nameInput.tag = 20;
    nameInput.textAlignment = NSTextAlignmentLeft;
    nameInput.clearButtonMode = UITextFieldViewModeWhileEditing;
    nameInput.textColor = RGBCOLOR(0x23, 0x23, 0x33);;
    nameInput.font = [UIFont systemFontOfSize:15.0];
    nameInput.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 16, 40)];
    nameInput.leftViewMode = UITextFieldViewModeAlways;
    [nameInput addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [self.settingPanel addSubview:nameInput];
    
    UILabel *descLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(nameInput.frame) + 20, 76, 20)];
    descLabel.text = @"Description";
    descLabel.font = [UIFont systemFontOfSize:14.0];
    descLabel.textColor = [UIColor blackColor];
//    UILabel *redStar2 = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(descLabel.frame), CGRectGetMaxY(nameInput.frame) + 20, 5, 16)];
//    redStar2.text = @"*";
//    redStar2.font = [UIFont systemFontOfSize:14.0];
//    redStar2.textColor = [UIColor redColor];
    [self.settingPanel addSubview:descLabel];
//    [self.settingPanel addSubview:redStar2];
    
    UITextField *descInput = [[UITextField alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(descLabel.frame) + 5, w, 40)];
    descInput.layer.cornerRadius = 10.0;
    descInput.layer.borderColor = RGBCOLOR(110, 118, 128).CGColor;
    descInput.layer.borderWidth = 1.0;
    descInput.tag = 21;
    descInput.textAlignment = NSTextAlignmentLeft;
    descInput.clearButtonMode = UITextFieldViewModeWhileEditing;
    descInput.textColor = RGBCOLOR(0x23, 0x23, 0x33);;
    descInput.font = [UIFont systemFontOfSize:15.0];
    descInput.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 16, 40)];
    descInput.leftViewMode = UITextFieldViewModeAlways;
    descInput.placeholder = @"e.g. Product Manager@Company";
    [descInput addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [self.settingPanel addSubview:descInput];

    
    UILabel *colorLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(descInput.frame) + 20, 100, 20)];
    colorLabel.text = @"Brand Color";
    colorLabel.font = [UIFont systemFontOfSize:14.0];
    colorLabel.textColor = [UIColor blackColor];
    [self.settingPanel addSubview:colorLabel];
    
    NSInteger colorIndex = [SimulateStorage myLowerThirdColorIndex];
    self.selectColorIdx = colorIndex;
    NSArray *colorArr = [SimulateStorage colorArray];
    double panelW = self.view.bounds.size.width - 32;
    for (int i = 0; i < 8; i++) {
        CGFloat x = i*(56+12);
        CGFloat y = CGRectGetMaxY(colorLabel.frame) + 5;
        if (x + 56 > panelW) {
            NSInteger sX = ((NSInteger)x + 56) % (NSInteger)panelW;
            NSInteger yX = (x + 56) / panelW;
            x = sX - (sX % (56 + 12));
            y = y + yX * (56 + 12);
        }
        
        UIColor *bgColor = colorArr[i];
        if(i == 0) {
            bgColor = [UIColor colorWithRed:82/255.0 green:82/255.0 blue:128/255.0 alpha:0.09];
        }
        
        UIButton *colorBtn = [self buttonWithColor:bgColor andFrame:CGRectMake(x, y, 56, 56)];
        if (i == 0) {
            UIImage *img = [UIImage imageNamed:@"colorNone"];
            UIImageView *bgView = [[UIImageView alloc] initWithImage:img];
            CGSize size = img.size;
            bgView.frame = CGRectMake(28 - (size.width/2.0), 28 - (size.height / 2.0), size.width, size.height);
            [colorBtn addSubview:bgView];
        }
        colorBtn.tag = 100 + i;
        colorBtn.layer.borderWidth = 0.0;
        if (i == colorIndex) {
            colorBtn.layer.borderWidth = 2.0;
        }
        [self.settingPanel addSubview:colorBtn];
    }
    
    NSString *lowerName = [SimulateStorage myLowerThirdName];
    NSString *lowerdesc = [SimulateStorage myLowerThirdDesc];
    if (!lowerName)
        lowerName = [UIDevice currentDevice].name;
    nameInput.text = lowerName;
    
    if (lowerdesc) {
        descInput.text = lowerdesc;
    }
}

- (UIImage *)imageWithColor:(UIColor *)color
{
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();

    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);

    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return image;
}

- (UIButton *)buttonWithColor:(UIColor *)color andFrame:(CGRect)rect
{
    CGFloat w = rect.size.width;
    UIButton *btn = [[UIButton alloc] initWithFrame:rect];
    btn.layer.cornerRadius = w/2.0;
    btn.layer.borderColor = RGBCOLOR(0x0e, 0x72, 0xed).CGColor;
    btn.layer.borderWidth = 2.0;
    [btn setClipsToBounds:YES];
    CAShapeLayer *layer = [[CAShapeLayer alloc] init];
    UIBezierPath *bezier = [[UIBezierPath alloc] init];
    [bezier addArcWithCenter:CGPointMake(w/2.0, rect.size.height/2.0) radius:w/2.0 - 5 startAngle:0.0 endAngle:M_PI*2.0 clockwise:YES];
    bezier.lineWidth = 1;
    [color setStroke];
    [bezier stroke];
    layer.path = bezier.CGPath;
    layer.fillColor = color.CGColor;
    [btn.layer addSublayer:layer];
    [btn addTarget:self action:@selector(onColorButtonClicked:) forControlEvents:UIControlEventTouchUpInside];

    return btn;
}

#pragma mark - action -
- (void)onCancelBtnClicked:(id)sender
{
    if (self.isPushed) {
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)onSaveBtnClicked:(id)sender
{
    UITextField *name = [self.settingPanel viewWithTag:20];
    UITextField *desc = [self.settingPanel viewWithTag:21];
    if (name.text && name.text.length > 0)
    {
        [[SimulateStorage shareInstance] addMyLowerThird:name.text desc:(desc.text ? desc.text : @"") colorIndex:self.selectColorIdx];
        [[SimulateStorage shareInstance] sendMyLowerThird];
        
        if (self.isPushed) {
            [self.navigationController popViewControllerAnimated:YES];
        } else {
            [self dismissViewControllerAnimated:YES completion:nil];
        }
        
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        [nc postNotificationName:kLowerThirdSavedNoti object:nil];
    }
}

- (void)onColorButtonClicked:(id)sender
{
    UIButton *btn = (UIButton *)sender;
    self.selectColorIdx = btn.tag - 100;
    NSArray *subviews = [self.settingPanel subviews];
    for (UIView *sub in subviews) {
        if (sub.tag >= 100 && sub.tag < 110) { // 107?
            sub.layer.borderWidth = 0.0;
            if (sub.tag == btn.tag) {
                sub.layer.borderWidth = 2.0;
            }
        }
    }
    [self colorChange:self.selectColorIdx];
}

- (void)colorChange:(NSInteger)colorIndex
{
    UIColor *color = [[SimulateStorage colorArray] objectAtIndex:colorIndex];
    
    UIView *lineView = [self.displayPanel viewWithTag:31];
    UILabel *descLabel = [self.displayPanel viewWithTag:33];
    UIView *descBgView = [self.displayPanel viewWithTag:34];
    
    lineView.backgroundColor = color;
    
    [descBgView.layer.sublayers[0] removeFromSuperlayer];
    CAShapeLayer *layer = [[CAShapeLayer alloc] init];
    UIBezierPath *bezier = [[UIBezierPath alloc] init];
    [bezier moveToPoint:CGPointMake(0, 0)];
    [bezier addLineToPoint:CGPointMake(descBgView.frame.size.width, 0)];
    [bezier addLineToPoint:CGPointMake(descBgView.frame.size.width - 10, descBgView.frame.size.height)];
    [bezier addLineToPoint:CGPointMake(0, descBgView.frame.size.height)];
    [bezier closePath];
    layer.path = bezier.CGPath;
    layer.fillColor = color.CGColor;
    layer.strokeColor = UIColor.clearColor.CGColor;
    [descBgView.layer addSublayer:layer];
    descLabel.textColor = [UIColor whiteColor];
    if ([SimulateStorage needBlackColorDesc:nil orColorString:nil orIndex:colorIndex]) {
        descLabel.textColor = [UIColor blackColor];
    }
}

- (void)textFieldDidChange:(UITextField *)tx
{
    UITextField *name = [self.settingPanel viewWithTag:20];
    UITextField *desc = [self.settingPanel viewWithTag:21];
    
    
    if (name.text.length > 0)
        [self.saveBtn setEnabled:YES];
    else
        [self.saveBtn setEnabled:NO];
    
    UIView *lineView = [self.displayPanel viewWithTag:31];
    UILabel *nameLabel = [self.displayPanel viewWithTag:32];
    UILabel *descLabel = [self.displayPanel viewWithTag:33];
    UIView *descBgView = [self.displayPanel viewWithTag:34];
    
    if (name.text && name.text.length > 0 &&
        desc.text && desc.text.length > 0)
    {
        self.displayPanel.frame = CGRectMake(16, 16, 150, 60);
        lineView.frame = CGRectMake(10, 8, 4, 40);
        nameLabel.frame = CGRectMake(24, 6, 100, 20);
        descLabel.hidden = NO;
        descBgView.hidden = NO;
    }
    else
    {
        self.displayPanel.frame = CGRectMake(16, 16, 150, 48);
        lineView.frame = CGRectMake(10, 8, 4, 32);
        nameLabel.frame = CGRectMake(24, 10, 100, 25);
        descLabel.hidden = YES;
        descBgView.hidden = YES;
    }
    nameLabel.text = name.text;
    descLabel.text = desc.text;
}

- (void)switchAction:(UISwitch *)sw
{
    self.displayPanel.hidden = !sw.on;
    self.settingPanel.hidden = !sw.on;
    [SimulateStorage enableLowerThird:sw.on];
}

@end
