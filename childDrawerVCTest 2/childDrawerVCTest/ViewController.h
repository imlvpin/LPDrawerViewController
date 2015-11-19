//
//  ViewController.h
//  childDrawerVCTest
//
//  Created by 吕品 on 15/10/30.
//  Copyright © 2015年 吕品. All rights reserved.
//

#import <UIKit/UIKit.h>
//左边还是右边显示
typedef NS_ENUM(NSInteger, DrawerViewControllerShowStyle)
{
    DrawerViewControllerShowStyleLeft = 0,
    DrawerViewControllerShowStyleRight = 1,
};
//展示类型
typedef NS_ENUM(NSInteger, DrawerViewControllerShowType)
{
    DrawerViewControllerShowTypeTableView = 0,
    DrawerViewControllerShowTypeCollectionView = 1,
};
//展示样式,复杂还是简单
typedef NS_ENUM(NSInteger, DrawerViewControllerShowDetailStyle)
{
    DrawerViewControllerShowDetailStyleNormal = 0,
    DrawerViewControllerShowDetailStylePictureWithText = 1,
};
@protocol DrawerViewControllerDelegate <NSObject>
//tableview的点击方法
- (void)viewController:(UIViewController *)viewController didSelectedRowAtIndexPath:(NSIndexPath *)indexPath;
@end
@interface ViewController : UIViewController
//代理
@property (nonatomic, assign) id<DrawerViewControllerDelegate>delegate;
//行高
@property (nonatomic, assign) CGFloat rowHeight;
//装有特定model的数组
@property (nonatomic, copy) NSArray *dataArray;
//动画时间,默认0.3s
//@property (nonatomic, assign) CGFloat animationTimeInterval;
//返回默认带有导航栏的侧边栏,根据输入的size大小显示,和左边显示或者右边显示 或者显示样式为tableview还是collectionView(collectionView暂时没有实现T.T)
- (UINavigationController *)getDrawerWithNavigationControllerBySize:(CGSize)size forShowStyle:( DrawerViewControllerShowStyle)showStyle andShowType:(DrawerViewControllerShowType)showType withShowDetailStyle:(DrawerViewControllerShowDetailStyle)showDetailStyle isWithCoverView:(BOOL)isWithCoverView canMove:(BOOL)canMove;



//注册model类型 装有model类型的数组 header数组 和对应属性的key
- (void)registerModelClass:(Class)modelClass andDataArray:(NSArray<NSArray *> *)dataArray andHeaderArray:(NSArray<NSString *> *)headerArray withTextKey:(NSString *)textKey withImageUrlStringKey:(NSString *)urlKey withDetaiStringKey:(NSString *)detailKey;
- (void)setDataArray:(NSArray<NSArray *> *)dataArray withHeaderArray:(NSArray<NSString *>*)headerArray;

//刷新视图
- (void)reloadDataAndView;
//显示边栏和自定义持续时间
- (void)showWithDuration:(CGFloat)timeInterval;
//隐藏边栏和自定义时间
- (void)hideWithDuration:(CGFloat)timeInterval;

@end
//自定义cell
@interface DrawerTableViewCell : UITableViewCell

@end
