//
//  BottomBarView.m
//  ZoomVideoSample
//
//  Created by Zoom Video Communications on 2019/5/29.
//  Copyright © 2019 Zoom. All rights reserved.
//

#import "BottomBarView.h"
#import "HorizontalTableView.h"
#import "ChatInputView.h"

@implementation ViewItem

- (BOOL)isEqual:(id)object {
    
    if (![object isKindOfClass:[ViewItem class]]) {
        return NO;
    }
    
    ViewItem *newObj = (ViewItem *)object;
    
    if ([_user isEqual:newObj.user] && [_itemName isEqualToString:newObj.itemName] && [_view isEqual:newObj.view]) {
        return YES;
    }
    
    return NO;
}

-(NSString *)description {
    return [NSString stringWithFormat:@"View Item Name:%@, view addr:%@, is active %@", self.itemName, self.view, @(self.isActive)];
}

@end

@implementation LeftLabel

-(void)drawTextInRect:(CGRect)rect
{
    [super drawTextInRect:UIEdgeInsetsInsetRect(rect, UIEdgeInsetsMake(0, 8, 0, 25))];
}


@end

#define kNameTag        11001
#define kSpeakerTag     11002
#define kReactionTag    11003


#define video_reaction_size 25.0f

@interface BottomBarView () <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, assign) id<BottomBarViewDelegate> handle;
@property (nonatomic, strong) CAGradientLayer           *gradientLayer;
@property (nonatomic, assign) CGFloat                   headerHeight;
@end

@implementation BottomBarView

- (instancetype)initWithDelegate:(id<BottomBarViewDelegate>)delegate
{
    self = [super init];
    if (self) {
        _handle = delegate;
        _viewArray = [NSMutableArray array];
        [self.layer addSublayer:self.gradientLayer];
        [self addSubview:self.thumbTableView];
        
        [self.thumbTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.backgroundColor = [UIColor clearColor];
    self.gradientLayer.frame = self.bounds;
    
    self.frame = CGRectMake(0, SCREEN_HEIGHT - kTableHeight - kInputViewHeight, SCREEN_WIDTH, kTableHeight + kInputViewHeight);
    
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    BOOL landscape = UIInterfaceOrientationIsLandscape(orientation);
    
    if (landscape) {
        if (orientation == UIInterfaceOrientationLandscapeRight && IPHONE_X) {
            self.thumbTableView.frame = CGRectMake(SAFE_ZOOM_INSETS+10, 0, kCellHeight*3, kTableHeight);
        } else {
            self.thumbTableView.frame = CGRectMake(0, 0, kCellHeight*3, kTableHeight);
        }
    } else {
        if (IS_IPAD) {
            self.thumbTableView.frame = CGRectMake(0, 0, kCellHeight*3, kTableHeight);
        } else {
            self.thumbTableView.frame = CGRectMake(0, 0, SCREEN_WIDTH, kTableHeight);
        }
    }
    [self updateLayout];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self scrollToRowPosition];
    });
}

- (CAGradientLayer *)gradientLayer {
    if (!_gradientLayer) {
        _gradientLayer = [CAGradientLayer layer];
        _gradientLayer.frame = self.bounds;
        [self.layer addSublayer:_gradientLayer];
        _gradientLayer.startPoint = CGPointMake(0.5, 0);
        _gradientLayer.endPoint = CGPointMake(0.5, 1);
        _gradientLayer.colors = @[(__bridge id)[UIColor colorWithWhite:0.f alpha:0.0].CGColor,
                                      (__bridge id)[UIColor colorWithWhite:0.f alpha:0.75].CGColor];
    }
    return _gradientLayer;
}

- (HorizontalTableView*)thumbTableView
{
    if (!_thumbTableView) {
        _thumbTableView = [[HorizontalTableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _thumbTableView.backgroundColor = [UIColor clearColor];
        _thumbTableView.separatorColor = [UIColor clearColor];
        _thumbTableView.pagingEnabled = NO;
        _thumbTableView.delegate = self;
        _thumbTableView.dataSource = self;
        _thumbTableView.showsVerticalScrollIndicator = NO;
    }
    
    return _thumbTableView;
}

- (void)addThumberViewItem:(ViewItem *)item; {
    if ([self.viewArray containsObject:item]) {
        return;
    }
    
    [self removeThumberViewItemWithUser:item.user];

    LeftLabel *nameLabel = [[LeftLabel alloc] init];
    nameLabel.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.6];
    nameLabel.text = item.itemName;
    nameLabel.textColor = [UIColor whiteColor];
    nameLabel.font = [UIFont systemFontOfSize:12.0];
    nameLabel.tag = kNameTag;
    [item.view addSubview:nameLabel];
    
    UIImageView *littleSpeaker = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"little_speaker"]];
    littleSpeaker.tag = kSpeakerTag;
    [item.view addSubview:littleSpeaker];
    
    UIImageView *reactionImg = [[UIImageView alloc] init];
    reactionImg.tag = kReactionTag;
    [item.view addSubview:reactionImg];
    reactionImg.hidden = YES;
    item.reactionImg = reactionImg;
    
    item.view.layer.cornerRadius = 10.0;
    item.view.layer.borderColor = [UIColor colorWithWhite:1.0 alpha:0.5].CGColor;
    item.view.layer.borderWidth = 1.0;
    [item.view setClipsToBounds:YES];
    
    item.view.transform = CGAffineTransformMakeRotation(M_PI / 2);
    
    [self.viewArray addObject:item];
    [self updateLayout];
}

- (void)removeThumberViewItem:(ViewItem *)item; {
    if (![self.viewArray containsObject:item]) {
        return;
    }
    
    [self.viewArray removeObject:item];
    [self updateLayout];
}

- (void)removeAllThumberViewItem
{
    [self.viewArray removeAllObjects];
    [self updateLayout];
}

- (void)updateItem:(ViewItem *)item withViewItem:(ViewItem *)newItem {
    
    NSUInteger index = [self.viewArray indexOfObject:item];
    if (index == NSNotFound) {
        return;
    }
    
    for (UIView *view in [newItem.view subviews]) {
        if (view.tag == kNameTag) {
            [view removeFromSuperview];
        }
        if (view.tag == kSpeakerTag) {
            [view removeFromSuperview];
        }
    }
    
    LeftLabel *nameLabel = [[LeftLabel alloc] init];
    nameLabel.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.6];
    nameLabel.text = newItem.itemName;
    nameLabel.textColor = [UIColor whiteColor];
    nameLabel.font = [UIFont systemFontOfSize:12.0];
    nameLabel.tag = kNameTag;
    [newItem.view addSubview:nameLabel];
    
    UIImageView *littleSpeaker = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"little_speaker"]];
    littleSpeaker.tag = kSpeakerTag;
    [newItem.view addSubview:littleSpeaker];
    
    newItem.view.layer.cornerRadius = 10.0;
    newItem.view.layer.borderColor = [UIColor colorWithWhite:1.0 alpha:0.5].CGColor;
    newItem.view.layer.borderWidth = 1.0;
    [newItem.view setClipsToBounds:YES];
    
    newItem.view.transform = CGAffineTransformMakeRotation(M_PI / 2);
    
    [self.viewArray replaceObjectAtIndex:index withObject:newItem];
    [self updateLayout];
}

- (void)removeThumberViewItemWithUser:(ZoomVideoSDKUser *)user {

    NSMutableArray *removeItem = [NSMutableArray array];
    for (ViewItem *item in self.viewArray) {
        if ([user isEqual:item.user]) {
            [removeItem addObject:item];
        }
    }
    
    for (ViewItem *item in removeItem) {
        [self.viewArray removeObject:item];
    }

    [self updateLayout];
}

- (void)activeThumberViewItem:(ZoomVideoSDKUser *)user {
    for (ViewItem *item in self.viewArray) {
        if ([user isEqual:item.user]) {
            item.isActive = YES;
        } else {
            item.isActive = NO;
        }
    }
    [self updateLayout];
}

- (void)deactiveAllThumberView {
    for (ViewItem *item in self.viewArray) {
        item.isActive = NO;
    }
    [self updateLayout];
}

- (void)updateLayout {
    self.thumbTableView.transform = CGAffineTransformMakeRotation(-M_PI / 2);
    [self.thumbTableView reloadData];
}

- (NSArray *)getThumberViewItems:(ZoomVideoSDKUser *)user {
    NSMutableArray *items = [NSMutableArray array];
    for (ViewItem *item in self.viewArray) {
        if ([user isEqual:item.user]) {
            [items addObject:item];
        }
    }
    
    return [items copy];
}

- (void)stopThumbViewVideo {
    if (self.handle && [self.handle respondsToSelector:@selector(stopThumbViewVideo)]) {
        [self.handle stopThumbViewVideo];
    }
}

- (void)startThumbViewVideo {
    if (self.handle && [self.handle respondsToSelector:@selector(startThumbViewVideo)]) {
        [self.handle startThumbViewVideo];
    }
}

- (void)scrollToVisibleArea:(ViewItem *)item
{
    if (!item) {
        [self startThumbViewVideo];
        return;
    }
    
    NSInteger index = [self.viewArray indexOfObject:item];
    if (index == NSNotFound) {
        [self startThumbViewVideo];
        return;
    }
    
    CGFloat startX = kCellHeight * index;
    NSInteger rowHeight = kCellHeight;
    NSInteger offsetY = (NSInteger)(self.thumbTableView.contentOffset.y) % rowHeight;
    BOOL visibleCell = offsetY >= kCellHeight/2.0;
    
    NSIndexPath *indexPath = [self.thumbTableView indexPathForRowAtPoint:CGPointMake(self.thumbTableView.contentOffset.x, startX)];
    if (indexPath.row == NSNotFound) {
        [self startThumbViewVideo];
        return;
    }
    
    if (visibleCell)
    {
        indexPath = [NSIndexPath indexPathForRow: indexPath.row+1 inSection: 0];
    }
    
    if (indexPath.row < self.viewArray.count && indexPath.row != NSNotFound) {
        [self.thumbTableView scrollToRowAtIndexPath: indexPath atScrollPosition: UITableViewScrollPositionTop animated: YES];
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self startThumbViewVideo];
    });
}

#pragma mark - scrollView -
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    BOOL scrollToScrollStop = !scrollView.tracking && !scrollView.dragging && !scrollView.decelerating;
    if (scrollToScrollStop) {
        [self scrollViewDidEndScroll];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (!decelerate) {
        BOOL dragToDragStop = scrollView.tracking && !scrollView.dragging && !scrollView.decelerating;
        if (dragToDragStop) {

            [self scrollViewDidEndScroll];
        }
    }
}

- (void)scrollViewDidEndScroll {
    [self stopThumbViewVideo];
    [self startThumbViewVideo];
    [self scrollToRowPosition];
    [self.thumbTableView reloadData];
}

- (void)scrollToRowPosition {
    if (self.headerHeight > 0) {
        return;
    }
    
    NSInteger rowHeight = kCellHeight;
    NSInteger offsetY = (NSInteger)(self.thumbTableView.contentOffset.y) % rowHeight;
    BOOL visibleCell = offsetY >= kCellHeight/2.0;
    
    NSIndexPath *indexPath = [self.thumbTableView indexPathForRowAtPoint:CGPointMake(self.thumbTableView.contentOffset.x, self.thumbTableView.contentOffset.y)];
    if (indexPath.row == NSNotFound) {
        return;
    }
    
    if (visibleCell)
    {
        indexPath = [NSIndexPath indexPathForRow:indexPath.row+1 inSection: 0];
    }
    
    if (indexPath.row < self.viewArray.count && indexPath.row != NSNotFound) {
        [self.thumbTableView scrollToRowAtIndexPath:indexPath atScrollPosition: UITableViewScrollPositionTop animated: YES];
    }
}

#pragma mark - tableView -
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    CGFloat headerHeight = 0;
    CGFloat margin = SCREEN_WIDTH - self.viewArray.count * kCellHeight;
    if (margin > 0) {
        headerHeight = margin * 0.5 - 5;
    }
    
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    BOOL landscape = UIInterfaceOrientationIsLandscape(orientation);
    if (IS_IPAD || landscape) {
        headerHeight = 0;
    }
    
    UIView *header = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kCellHeight, headerHeight)];
    header.backgroundColor = [UIColor clearColor];
    return header;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    BOOL landscape = UIInterfaceOrientationIsLandscape(orientation);
    if (IS_IPAD || landscape) {
        self.headerHeight = 0.0;
        return 0.0;
    }
    
    CGFloat margin = SCREEN_WIDTH - self.viewArray.count * kCellHeight;
    if (margin > 0) {
        self.headerHeight = margin * 0.5 - 5.0;
        return self.headerHeight;
    }
    
    self.headerHeight = 0.0;
    return 0.0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.viewArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kCellHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = [UIColor clearColor];
    
    ViewItem *item = [self.viewArray objectAtIndex:indexPath.row];
    if (!item) {
        return cell;
    }
    NSArray *views = cell.contentView.subviews;
    for (UIView *view in views) {
        if (view.tag == 5001) {
            [view removeFromSuperview];
        }
    }
    
    [item.view setFrame:CGRectMake(15, 10, kTableHeight - 15 * 2, kCellHeight - 10)];
    item.view.tag = 5001;
    
    for (UIView *view in item.view.subviews) {
        if (view.tag == kNameTag) {
            view.frame = CGRectMake(0, kTableHeight - 15 * 2 - 24, kCellHeight - 10, 24);
            [item.view bringSubviewToFront:view];
        }
        if (view.tag == kSpeakerTag) {
            view.frame = CGRectMake(kTableHeight - 15 * 2 - 20, kCellHeight - 10 - 18, 12, 11);
            view.hidden = !item.isActive;
            [item.view bringSubviewToFront:view];
        }
        
        if (view.tag == kReactionTag) {
            view.frame = CGRectMake(10, 10, video_reaction_size, video_reaction_size);
            [item.view bringSubviewToFront:view];
        }
    }
    
    [cell.contentView addSubview:item.view];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (self.handle && [self.handle respondsToSelector:@selector(pinThumberViewItem:)]) {
        ViewItem *item = [self.viewArray objectAtIndex:indexPath.row];
        [self.handle pinThumberViewItem:item];
        
        NSInteger getUserID = [item.user getUserID];
        NSLog(@"UserID Id = %@", @(getUserID));
    }
}


@end
