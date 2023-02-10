//
//  IntroduceViewController.m
//  ZoomVideoSample
//
//  Created by Zoom Video Communications on 2019/5/28.
//  Copyright © 2019 Zoom. All rights reserved.
//

#import "IntroduceViewController.h"
#import "CanvasViewController.h"
#import "JoinViewController.h"
#import "CreateViewController.h"


@interface IntroduceCell()
@property (nonatomic, strong)   UILabel    *titleLabel;
@property (nonatomic, strong)   UILabel    *msgLabel;
@property (nonatomic, strong)   UILabel    *learnMoreLabel;
@property (nonatomic, strong)   UIView     *line;
@end


@implementation IntroduceCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        self.contentView.backgroundColor = [UIColor whiteColor];
        
        self.titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(15, 30, SCREEN_WIDTH-30, 25)];
        self.titleLabel.backgroundColor = [UIColor clearColor];
        self.titleLabel.textColor = RGBCOLOR(0x23, 0x23, 0x23);
        self.titleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:25];
        self.titleLabel.text = @"";
        self.titleLabel.numberOfLines = 1;
        [self.contentView addSubview:self.titleLabel];
        
        self.msgLabel = [[UILabel alloc]initWithFrame:CGRectMake(15, MaxY(self.titleLabel)+10, SCREEN_WIDTH-30, 30)];
        self.msgLabel.backgroundColor = [UIColor clearColor];
        self.msgLabel.textColor = RGBCOLOR(0x23, 0x23, 0x23);
        self.msgLabel.font = [UIFont systemFontOfSize:15];
        self.msgLabel.text = @"";
        self.msgLabel.numberOfLines = 0;
        [self.contentView addSubview:self.msgLabel];
        
        self.learnMoreLabel = [[UILabel alloc]initWithFrame:CGRectMake(15, MaxY(self.msgLabel)+15, SCREEN_WIDTH-30, 25)];
        self.learnMoreLabel.backgroundColor = [UIColor clearColor];
        self.learnMoreLabel.textColor = RGBCOLOR(0x23, 0x23, 0x23);
        self.learnMoreLabel.font = [UIFont systemFontOfSize:15];
        self.learnMoreLabel.text = @"";
        self.learnMoreLabel.numberOfLines = 1;
        [self.contentView addSubview:self.learnMoreLabel];
        self.learnMoreLabel.userInteractionEnabled = YES;
        UITapGestureRecognizer * tgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(learnMoreClick)];
        [self.learnMoreLabel addGestureRecognizer:tgr];
        
        self.line = [[UIView alloc] initWithFrame:CGRectMake(15, MaxY(self.learnMoreLabel)+20, SCREEN_WIDTH-30, 1)];
        self.line.backgroundColor = RGBCOLOR(0xde, 0xde, 0xf4);
        [self.contentView addSubview:self.line];
    }
    return self;
}

- (void)learnMoreClick {
    NSString *urlString = @"https://marketplace.zoom.us/docs/sdk/native-sdks/preface/introducing-zoom-sdk";
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:urlString]]) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
    }
}

- (void)layoutSubviews {
    [self updateFrame];
}

- (void)updateFrame {
    
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    BOOL landscape = UIInterfaceOrientationIsLandscape(orientation);
    
    float x;
    if (landscape) {
        x = 60;
    } else {
        x = 15;
    }
    
    self.titleLabel.frame = CGRectMake(x, 30, SCREEN_WIDTH-x*2, 25);
    
    self.msgLabel.frame = CGRectMake(x, MaxY(self.titleLabel)+10, SCREEN_WIDTH-x*2, 30);
    [self.msgLabel sizeToFit];
    self.msgLabel.frame = CGRectMake(x, MaxY(self.titleLabel)+10, Width(self.msgLabel), Height(self.msgLabel));
    
    [self.learnMoreLabel sizeToFit];
    self.learnMoreLabel.frame = CGRectMake((SCREEN_WIDTH-Width(self.learnMoreLabel))/2, MaxY(_msgLabel)+15, Width(self.learnMoreLabel), Height(self.learnMoreLabel));
    
    self.line.frame = CGRectMake(x, MaxY(self.learnMoreLabel)+20, SCREEN_WIDTH-x*2, 1);
}

- (void)setCellValue:(NSDictionary *)itemData rowIndex:(NSInteger)rowIndex
{
    self.titleLabel.text = [itemData objectForKey:@"title"];
    self.msgLabel.text = [itemData objectForKey:@"introduce"];
    
    if (rowIndex == 1) {
        self.learnMoreLabel.hidden = NO;
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"Learn More(Will open browser)"]];
        [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor orangeColor] range:NSMakeRange(0,10)];
        [attributedString addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:NSMakeRange(0,10)];
        self.learnMoreLabel.attributedText = attributedString;
    } else {
        self.learnMoreLabel.hidden = YES;
    }
    
    
    [self updateFrame];
    
}


+(CGFloat)cellHeight:(NSDictionary *)itemData rowIndex:(NSInteger)rowIndex {
    IntroduceCell *cell = [[IntroduceCell alloc] init];
    [cell setCellValue:itemData rowIndex:rowIndex];
    [cell layoutSubviews];
    return CGRectGetMaxY(cell.line.frame);
}

@end




@interface IntroduceViewController()<UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong)   UITableView         *tableView;
@property (nonatomic, strong)   UIView              *tableViewFooterView;
@property (nonatomic, strong)   NSArray             *tableDataSource;//tableview数据源
@property (nonatomic, strong)   UIButton            *startBtn;
@property (nonatomic, strong)   UIButton            *joinBtn;
@property (nonatomic, strong)   UILabel             *titleLabel;
@end

@implementation IntroduceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];

    self.title = self.titleString;
    self.view.backgroundColor = [UIColor whiteColor];
    
    NSString *sessionType = [[NSUserDefaults standardUserDefaults] objectForKey:@"SESSIONTYPE"];
    if ([sessionType isEqualToString:@"canvas"]) {
    self.tableDataSource = @[
                         @{
                             @"title":@"What is it?",
                             @"introduce":@"Zoom Canvas Renderer, a renderer that is developed by Zoom and highly optimized for Zoom services. It is easy to understand with high usability.\n\n • Less implementation and configuration\n\n • Easy to use"
                             },
                         @{
                             @"title":@"How it works",
                             @"introduce":@"Configure your own video settings and the Zoom Canvas Renderer will take care of the rest."
                             }
                         ];
    } else if ([sessionType isEqualToString:@"opengl"]) {
        self.tableDataSource = @[
                             @{
                                 @"title":@"What is it?",
                                 @"introduce":@"OpenGL ES is a cross-platform graphics API that flavors the embedded systems and makes video rendering possible on mobile devices.\n\n • Works for both Android and iOS\n\n • Possible to do fancy and advanced stuffs with Raw Data"
                                 },
                             @{
                                 @"title":@"How it works",
                                 @"introduce":@"Retrieve YUV420 raw data from SDK and pass it to the OpenGL ES Renderer to render video."
                                 }
                             ];
    } else if ([sessionType isEqualToString:@"metal"]) {
        self.tableDataSource = @[
                             @{
                                 @"title":@"What is it?",
                                 @"introduce":@"Apple’s Metal renderer offers low-level, low-overhead hardware-accelerated graphic and computer shader APIs, and combines functions similar to OpenGL and Open CL.\n\n • Optimized for iOS\n\n • Easy for iOS developers to learn and use"
                                 },
                             @{
                                 @"title":@"How it works",
                                 @"introduce":@"Retrieve CVPixelBufferRef raw data from SDK and pass it to the Apple Metal Renderer to render video."
                                 }
                             ];
    }
    
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT) style:UITableViewStylePlain];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.view addSubview:self.tableView];
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerClass:[IntroduceCell class] forCellReuseIdentifier:@"IntroduceCell"];
    
    
    UIView * footer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 200)];
    
    self.titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(15, 30, SCREEN_WIDTH-30, 25)];
    self.titleLabel.backgroundColor = [UIColor clearColor];
    self.titleLabel.textColor = RGBCOLOR(0x23, 0x23, 0x23);
    self.titleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:25];
    self.titleLabel.text = @"Get Started!";
    self.titleLabel.numberOfLines = 1;
    [footer addSubview:self.titleLabel];
    
    self.startBtn = [[UIButton alloc] initWithFrame:CGRectMake(15, MaxY(self.titleLabel)+30, SCREEN_WIDTH-30, 45)];
    [self.startBtn setBackgroundImage:[UIImage imageNamed:@"button_bg"] forState:UIControlStateNormal];
    [self.startBtn setTitle:@"Create a Session" forState:UIControlStateNormal];
    self.startBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    [self.startBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.startBtn addTarget:self action:@selector(onCreateClicked:) forControlEvents:UIControlEventTouchUpInside];
    self.startBtn.layer.cornerRadius = 12.0;
    self.startBtn.clipsToBounds = YES;
    [footer addSubview:self.startBtn];
    
    self.joinBtn = [[UIButton alloc] initWithFrame:CGRectMake(15, MaxY(self.startBtn)+16, SCREEN_WIDTH-30, 45)];
    [self.joinBtn setBackgroundImage:[UIImage imageNamed:@"button_bg"] forState:UIControlStateNormal];
    [self.joinBtn setTitle:@"Join a Session" forState:UIControlStateNormal];
    self.joinBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    [self.joinBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.joinBtn addTarget:self action:@selector(onJoinClicked:) forControlEvents:UIControlEventTouchUpInside];
    self.joinBtn.layer.cornerRadius = 12.0;
    self.joinBtn.clipsToBounds = YES;
    [footer addSubview:self.joinBtn];

    self.tableView.tableFooterView = footer;
    
    if (@available(iOS 9.0, *)) {
    } else {
        self.startBtn.enabled = NO;
        self.joinBtn.enabled = NO;
    }
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [self updateFrame];
}

- (void)updateFrame {
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    BOOL landscape = UIInterfaceOrientationIsLandscape(orientation);
    
    float x;
    if (landscape) {
        x = 60;
    } else {
        x = 15;
    }
    self.tableView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    
//    [self.tableView reloadData];
    
    self.titleLabel.frame = CGRectMake(x, 30, SCREEN_WIDTH-x*2, 25);
    self.startBtn.frame = CGRectMake(x, MaxY(self.titleLabel)+30, SCREEN_WIDTH-x*2, 45);
    self.joinBtn.frame = CGRectMake(x, MaxY(self.startBtn)+16, SCREEN_WIDTH-x*2, 45);
}

- (BOOL)shouldAutorotate {
    [self updateFrame];
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskLandscapeLeft | UIInterfaceOrientationMaskLandscapeRight;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskLandscapeLeft | UIInterfaceOrientationMaskLandscapeRight;
}

- (void)onCreateClicked:(UIButton *)sender {
    CreateViewController *vc = [[CreateViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)onJoinClicked:(UIButton *)sender {
    JoinViewController *vc = [[JoinViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return _tableDataSource.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [IntroduceCell cellHeight:[_tableDataSource objectAtIndex:indexPath.row] rowIndex:indexPath.row];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"IntroduceCell" forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    [(IntroduceCell *)cell setCellValue:[_tableDataSource objectAtIndex:indexPath.row] rowIndex:indexPath.row];
    return cell;
}

@end
