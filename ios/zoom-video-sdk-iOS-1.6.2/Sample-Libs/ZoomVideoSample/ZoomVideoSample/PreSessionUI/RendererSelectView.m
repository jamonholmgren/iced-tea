//
//  RendererSelectView.m
//  ZoomVideoSample
//
//  Created by Zoom Video Communications on 2019/10/29.
//  Copyright © 2019 Zoom. All rights reserved.
//

#import "RendererSelectView.h"
#import "RendererSelectTableViewCell.h"

@interface RendererSelectView()<UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) UITableView         *tableView;
@property (nonatomic, strong) NSMutableArray      *tableDataSource;
@property (nonatomic, assign) NSInteger           selectIndex;
@end

@implementation RendererSelectView

- (id)initWithFrame:(CGRect)frame selectIndex:(NSInteger)selectIndex
{
    self = [super initWithFrame:frame];
    if (self) {
        self.tableDataSource = @[@{@"title":@"Zoom renderer",
                                   @"desc":@"Rendering with Zoom renderer"
                                   },
                                 @{@"title":@"OpenGL ES renderer",
                                   @"desc":@"Rendering YUV420 raw data with OpenGL ES"
                                   },
                                 @{@"title":@"Metal renderer",
                                   @"desc":@"Rendering CVPixelBuffer raw data with Apple Metal"
                                   }];
        
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, self.frame.size.width-30, 70)];
        titleLabel.textAlignment = 0;
        titleLabel.text = @"Renderer Options";
        titleLabel.font = [UIFont boldSystemFontOfSize:20.0];
        titleLabel.numberOfLines = 1;
        titleLabel.textColor = RGBCOLOR(0x23, 0x23, 0x33);
        [self addSubview:titleLabel];

        
        self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, MaxY(titleLabel), self.frame.size.width, self.frame.size.height-80) style:UITableViewStylePlain];
        self.tableView.dataSource = self;
        self.tableView.delegate = self;
        self.tableView.rowHeight = 75;
        self.tableView.scrollEnabled = NO;
        [self addSubview:self.tableView];
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
        self.tableView.backgroundColor = [UIColor whiteColor];
        self.tableView.showsVerticalScrollIndicator = NO;
        [self.tableView registerClass:[RendererSelectTableViewCell class] forCellReuseIdentifier:@"cell"];
        
        self.selectIndex = selectIndex;
    }
    return self;
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    RendererSelectTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    [cell setCellValue:[_tableDataSource objectAtIndex:indexPath.row]];
    if (indexPath.row == self.selectIndex) {
        cell.titleLabel.textColor = RGBCOLOR(0x0E, 0x71, 0xEB);
        cell.descLabel.textColor = RGBCOLOR(0x0E, 0x71, 0xEB);
        cell.selectArrow.hidden = NO;
    } else {
        cell.titleLabel.textColor = RGBCOLOR(0x23, 0x23, 0x33);
        cell.descLabel.textColor = RGBCOLOR(0x74, 0x74, 0x87);
        cell.selectArrow.hidden = YES;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    self.selectIndex = indexPath.row;
    for (NSIndexPath *indexPath in tableView.indexPathsForVisibleRows) {
        RendererSelectTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        cell.titleLabel.textColor = RGBCOLOR(0x23, 0x23, 0x33);
        cell.descLabel.textColor = RGBCOLOR(0x74, 0x74, 0x87);
        cell.selectArrow.hidden = YES;
    }
    RendererSelectTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.titleLabel.textColor = RGBCOLOR(0x0E, 0x71, 0xEB);
    cell.descLabel.textColor = RGBCOLOR(0x0E, 0x71, 0xEB);
    cell.selectArrow.hidden = NO;
    if (self.selectRendererOnClickBlock) {
        self.selectRendererOnClickBlock(indexPath.row);
    }
}


@end
