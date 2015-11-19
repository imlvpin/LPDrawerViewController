//
//  ViewController.m
//  childDrawerVCTest
//
//  Created by 吕品 on 15/10/30.
//  Copyright © 2015年 吕品. All rights reserved.
//

#import "ViewController.h"
#import "UIImageView+WebCache.h"
@interface ViewController ()<UITableViewDelegate,UITableViewDataSource,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>

//展示的tableview
@property (nonatomic, strong) UITableView *tableView;
//展示的collectionview
@property (nonatomic, strong) UICollectionView *collectionView;
//抽屉隐藏时的frame
@property (nonatomic, assign) CGRect drawerHiddenRect;
//抽屉显示时的frame
@property (nonatomic, assign) CGRect drawerShowRect;

//装有section头的数组,可能没有.
@property (nonatomic, copy) NSArray *headerArray;
//装有图片网址的数组
@property (nonatomic, strong) NSMutableArray *imageUrlStringArray;
//装有text信息的数组
@property (nonatomic, strong) NSMutableArray *textStringArray;
//装有detail信息的数组
@property (nonatomic, strong) NSMutableArray *detailStringArray;
//显示的样式,有图还是简单样式.
@property (nonatomic, assign) NSInteger drawerVCShowDetailStyle;
//显示边栏方向
@property (nonatomic, assign) NSInteger drawerShowStyle;
//展示类型
@property (nonatomic, assign) NSInteger drawerShowType;
//是否有遮罩
@property (nonatomic, assign) BOOL isWithCoverView;
//需要显示的size
@property (nonatomic, assign) CGSize drawerShowSize;
//遮罩view
@property (nonatomic, strong) UIView *coverView;
//是否能移动
@property (nonatomic, assign) BOOL canMove;
//遮罩隐藏时的frame
@property (nonatomic, assign) CGRect coverViewHiddenRect;
//遮罩显示时的frame
@property (nonatomic, assign) CGRect coverViewShowRect;
//滑动手势
@property (nonatomic, strong) UISwipeGestureRecognizer *swipe;

@end
static NSString *tableViewCellID = @"tableViewCell";
static NSString *collectionViewCellID = @"collectionViewCellID";
#pragma mark tableview自定义cell
//tableview的自定义cell,为了弥补自定义cell的懒加载不足
@interface DrawerTableViewCell()
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIImageView *myImageView;
@property (nonatomic, strong) UILabel *priceLabel;
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)reloadDataAndView
{
    if (_tableView)
    {
        [_tableView reloadData];
    }
    if (_collectionView)
    {
        [_collectionView reloadData];
    }
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}
//返回带有导航栏的vc并算其frame规定好显示的样式
- (UINavigationController *)getDrawerWithNavigationControllerBySize:(CGSize)size forShowStyle:(DrawerViewControllerShowStyle)showStyle andShowType:(DrawerViewControllerShowType)showType withShowDetailStyle:(DrawerViewControllerShowDetailStyle)showDetailStyle isWithCoverView:(BOOL)isWithCoverView canMove:(BOOL)canMove
{
    UINavigationController *NC = [[UINavigationController alloc] initWithRootViewController:self];
    //判断展示样式
    switch (showType)
    {
        case 0://展示为tableview
            self.tableView.hidden = NO;
            break;
        case 1://展示为collectionView
            self.collectionView.hidden = NO;
            break;
    }
    //详情界面的具体样式
    switch (showDetailStyle)
    {
        case 0:
        {
            [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:tableViewCellID];
        }
            break;
        case 1:
        {
            [_tableView registerClass:[DrawerTableViewCell class] forCellReuseIdentifier:tableViewCellID];
        }
            break;
    }
    //判断从哪边展示,计算好frame
    [self showDrawerFrameWithShowStyle:showStyle andSize:size];
    _isWithCoverView = isWithCoverView;
    _drawerVCShowDetailStyle = showDetailStyle;
    _drawerShowType = showType;
    _drawerShowSize = size;
    NC.view.frame = _drawerHiddenRect;
    if (canMove)
    {
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
        [NC.view addGestureRecognizer:pan];
    }
    else
    {
        [NC.view addGestureRecognizer:_swipe];
    }
    return NC;
}

- (void)showDrawerFrameWithShowStyle:(NSInteger)showStyle andSize:(CGSize)size
{
    self.swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(dismissFromView:)];
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    switch (showStyle)
    {
        case 0://左边
        {
            _swipe.direction = UISwipeGestureRecognizerDirectionLeft;
            _drawerHiddenRect = CGRectMake(0 - size.width, 0, size.width, size.height);
            _drawerShowRect = CGRectMake(0, 0, size.width, size.height);
            _coverViewShowRect = CGRectMake(size.width, 0, screenSize.width - size.width, size.height);
        }
            break;
        case 1://右边
        {
            _swipe.direction = UISwipeGestureRecognizerDirectionRight;
            _drawerHiddenRect = CGRectMake(screenSize.width, 0, size.width, size.height);
            _drawerShowRect = CGRectMake(screenSize.width - size.width, 0, size.width, size.height);
            _coverViewShowRect = CGRectMake(0, 0, screenSize.width - size.width, size.height);
        }
            break;
    }
    _drawerShowStyle = showStyle;
    _coverViewHiddenRect = _drawerHiddenRect;
}

//懒加载的遮罩图,在需要的时候显示
- (UIView *)coverView
{
    if (!_coverView)
    {
        _coverView = [[UIView alloc] initWithFrame:_coverViewHiddenRect];
        [self.navigationController.view.superview addSubview:_coverView];
        _coverView.backgroundColor = [UIColor lightGrayColor];
        _coverView.alpha = 0.9f;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissFromView:)];
        [_coverView addGestureRecognizer:tap];
    }
    return _coverView;
}
- (void)pan:(UIPanGestureRecognizer *)pan
{
    CGPoint setoffPoint = [pan translationInView:pan.view];
    pan.view.transform =  CGAffineTransformTranslate(pan.view.transform, setoffPoint.x, setoffPoint.y);
    [pan setTranslation:CGPointZero inView:pan.view];
    if (_drawerShowStyle == DrawerViewControllerShowStyleLeft)
    {
        if (pan.state == UIGestureRecognizerStateEnded)
        {
            if (self.navigationController.view.frame.origin.x >= [UIScreen mainScreen].bounds.size.width - self.navigationController.view.frame.size.width)
            {
                [self showDrawerFrameWithShowStyle:DrawerViewControllerShowStyleRight andSize:_drawerShowSize];
            }
            [self showWithDuration:0.3f];
        }
    }
    else
    {
        if (pan.state == UIGestureRecognizerStateEnded)
        {
            if (self.navigationController.view.frame.origin.x <= 0)
            {
                [self showDrawerFrameWithShowStyle:DrawerViewControllerShowStyleLeft andSize:_drawerShowSize];
            }
            [self showWithDuration:0.3f];
        }
    }
}
//注册简单对象的方法
- (void)setDataArray:(NSArray<NSArray *> *)dataArray withHeaderArray:(NSArray<NSString *>*)headerArray
{
    self.dataArray = dataArray;
    self.headerArray = headerArray;
    self.textStringArray = [NSMutableArray array];
    for (NSArray *arr in dataArray)
    {
        NSMutableArray *array = [NSMutableArray array];
        for (id str in arr)
        {
            if ([str isKindOfClass:[NSString class]])
            {
                [array addObject:str];
            }
        }
        [self.textStringArray addObject:array];
    }
    if (self.dataArray)
    {
        [self reloadDataAndView];
    }
}
//轻浮手势 隐藏
- (void)dismissFromView:(UISwipeGestureRecognizer *)swipeGesture
{
    [self hideWithDuration:0.3f];
}
// 显示
- (void)showWithDuration:(CGFloat)timeInterval
{
    [self showDrawerAnimationWithDuration:timeInterval withDrawerRect:_drawerShowRect withCoverViewRect:_coverViewShowRect];
}
//隐藏
- (void)hideWithDuration:(CGFloat)timeInterval
{
    [self showDrawerAnimationWithDuration:timeInterval withDrawerRect:_drawerHiddenRect withCoverViewRect:_coverViewHiddenRect];
    [self.navigationController popToRootViewControllerAnimated:NO];

}
//显示的私有api
- (void)showDrawerAnimationWithDuration:(CGFloat )timeInterval withDrawerRect:(CGRect)drawerRect withCoverViewRect:(CGRect)coverViewRect
{
    [UIView animateWithDuration:timeInterval animations:^{
        self.navigationController.view.frame = drawerRect;
        if (_isWithCoverView)
        {
            self.coverView.frame = coverViewRect;
        }
    }];
}
//注册复杂对象的方法
- (void)registerModelClass:(Class)modelClass andDataArray:(NSArray *)dataArray andHeaderArray:(NSArray<NSString *> *)headerArray withTextKey:(NSString *)textKey withImageUrlStringKey:(NSString *)urlKey withDetaiStringKey:(NSString *)detailKey
{
    self.dataArray = dataArray;
    self.headerArray = headerArray;
    self.imageUrlStringArray = [NSMutableArray array];
    self.textStringArray = [NSMutableArray array];
    self.detailStringArray = [NSMutableArray array];
    for (NSArray *arr in dataArray)
    {
        NSMutableArray *textArray = [NSMutableArray array];
        NSMutableArray *urlArray = [NSMutableArray array];
        NSMutableArray *detaiArray = [NSMutableArray array];
        for (id model in arr)
        {
            id textString = [model valueForKey:textKey];
            id urlString = [model valueForKey:urlKey];
            id detailString = [model valueForKey:detailKey];
            if ([textString isKindOfClass:[NSString class]])
            {
                [textArray addObject:textString];
            }
            if ([urlString isKindOfClass:[NSString class]])
            {
                [urlArray addObject:urlString];
            }
            if ([detailString isKindOfClass:[NSString class]])
            {
                [detaiArray addObject:detailString];
            }
        }
        [_textStringArray addObject:textArray];
        [_imageUrlStringArray addObject:urlArray];
        [_detailStringArray addObject:detaiArray];
    }
    if (self.dataArray)
    {
        [self reloadDataAndView];
    }
}

#pragma mark 懒加载tableview
- (UITableView *)tableView
{
    if (!_tableView)
    {
        self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        [self.view addSubview:_tableView];
        _tableView.delegate = self;
        _tableView.dataSource = self;
    }
    return _tableView;
}
#pragma mark tableview协议方法
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_dataArray[section] count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (!_headerArray)
    {
        return 1;
    }
    return _headerArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (!_rowHeight)
    {
        return 44;
    }
    return _rowHeight;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DrawerTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:tableViewCellID];
    UITableViewCell *normalCell = [tableView dequeueReusableCellWithIdentifier:tableViewCellID];
    NSArray *textArray = _textStringArray[indexPath.section];
    NSArray *urlArray = _imageUrlStringArray[indexPath.section];
    NSArray *detaiArray = _detailStringArray[indexPath.section];
    if (textArray.count != 0)
    {
        NSString *textString = textArray[indexPath.row];
        if (_drawerVCShowDetailStyle == 0)
        {
            normalCell.textLabel.text = textString;
        }
        else
        {
            cell.titleLabel.text = textString;
        }
    }
    if (detaiArray.count != 0)
    {
        NSString *detailString = detaiArray[indexPath.row];
        if (_drawerVCShowDetailStyle == 0)
        {
            normalCell.detailTextLabel.text = detailString;
        }
        else
        {
            cell.priceLabel.text = detailString;
        }
    }
    if (urlArray.count != 0 )
    {
        NSString *imageUrlString = urlArray[indexPath.row];
        if (_drawerVCShowDetailStyle == 0)
        {
            [normalCell.imageView sd_setImageWithURL:[NSURL URLWithString:imageUrlString]];
        }
        else
        {
            [cell.myImageView sd_setImageWithURL:[NSURL URLWithString:imageUrlString]];
        }
    }
    if (_drawerVCShowDetailStyle == 0)
    {
        return normalCell;
    }
    else
    {
        return cell;
    }
    
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return _headerArray[section];
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self.delegate viewController:self didSelectedRowAtIndexPath:indexPath];
}
#pragma mark 懒加载collectionView
- (UICollectionView *)collectionView
{
    if (!_collectionView)
    {
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        self.collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:flowLayout];
        [self.view addSubview:_collectionView];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
    }
    return _collectionView;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _dataArray.count;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:collectionViewCellID forIndexPath:indexPath];
    
    return cell;
}
@end
@implementation DrawerTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        self.titleLabel = [[UILabel alloc] init];
        _titleLabel.textAlignment = NSTextAlignmentLeft;
        _titleLabel.font = [UIFont systemFontOfSize:15];
        self.myImageView = [[UIImageView alloc] init];
        self.priceLabel = [[UILabel alloc] init];
        _priceLabel.textAlignment = NSTextAlignmentLeft;
        _priceLabel.textColor = [UIColor redColor];
        _myImageView.contentMode = UIViewContentModeScaleAspectFit;
        [self.contentView addSubview:_priceLabel];
        [self.contentView addSubview:_titleLabel];
        [self.contentView addSubview:_myImageView];
    }
    return self;
}
- (void)layoutSubviews
{
    [super layoutSubviews];
    CGFloat width = self.contentView.bounds.size.width / 4;
    CGFloat height = self.contentView.bounds.size.height / 10;
    _myImageView.frame = CGRectMake(0, height, width, height * 8);
    _titleLabel.frame = CGRectMake(width , height, width * 3, height * 4);
    _priceLabel.frame= CGRectMake(width , height * 5, width * 3, height * 4);
}
@end