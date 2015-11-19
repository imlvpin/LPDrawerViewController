//
//  DrawerViewController.m
//  childDrawerVCTest
//
//  Created by 吕品 on 15/10/30.
//  Copyright © 2015年 吕品. All rights reserved.
//

#import "DrawerViewController.h"
#import "ViewController.h"
#import "DataHandle.h"
#import "Model.h"
#import "TestViewController.h"
#import "Test2ViewController.h"
@interface DrawerViewController ()<DrawerViewControllerDelegate>
{
    ViewController *vc;
    UINavigationController *NC;
    
    ViewController *vc1;
    UINavigationController *NC1;
    
}
@end

@implementation DrawerViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"000000";
    self.automaticallyAdjustsScrollViewInsets = NO;
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    button.frame = CGRectMake(100, 100, 100, 100);
    button.backgroundColor = [UIColor greenColor];
    [button setTitle:@"推出1" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(push1) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];

    UIButton *button1 = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    button1.frame = CGRectMake(100, 200, 100, 100);
    button1.backgroundColor = [UIColor redColor];
    [button1 setTitle:@"回收" forState:UIControlStateNormal];
    [button1 addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button1];
    
    UIButton *button2 = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    button2.frame = CGRectMake(100, 300, 100, 100);
    button2.backgroundColor = [UIColor yellowColor];
    [button2 setTitle:@"推出2" forState:UIControlStateNormal];
    [button2 addTarget:self action:@selector(push2) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button2];
    
#pragma mark 1.实例化VC对象
    vc = [[ViewController alloc] init];
#pragma mark 2.通过给定方法返回一个导航控制器
    NC = [vc getDrawerWithNavigationControllerBySize:CGSizeMake(220, [UIScreen mainScreen].bounds.size.height) forShowStyle:DrawerViewControllerShowStyleLeft andShowType:DrawerViewControllerShowTypeTableView withShowDetailStyle:DrawerViewControllerShowDetailStylePictureWithText isWithCoverView:NO canMove:NO] ;
#pragma mark 3.添加视图的层级关系(必须)
    [self.view addSubview:NC.view];
    [self addChildViewController:NC];
    vc.navigationItem.title = @"11111";

    vc1 = [[ViewController alloc] init];
    NC1 =  [vc1 getDrawerWithNavigationControllerBySize:CGSizeMake(220, [UIScreen mainScreen].bounds.size.height) forShowStyle:DrawerViewControllerShowStyleRight andShowType:DrawerViewControllerShowTypeTableView withShowDetailStyle:DrawerViewControllerShowDetailStyleNormal isWithCoverView:YES canMove:YES] ;
    [self.view addSubview:NC1.view];
    [self addChildViewController:NC1];
    vc1.title = @"22222";
#pragma mark 4.行高和代理
   vc.rowHeight = 80;
    vc.delegate = self;
    vc1.rowHeight = 50;
    vc1.delegate = self;
    
    [self handleData];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self back];
}

- (void)handleData
{
    [DataHandle dataWithUrlString:@"http://app.api.autohome.com.cn/autov5.0.0/club/clubsseries-pm1-st635815584624897817.json" completion:^(id object)
    {
        NSArray *arr    = [[object objectForKey:@"result"] objectForKey:@"list"];
        NSMutableArray *dataArray = [NSMutableArray array];
        NSMutableArray *letterArray = [NSMutableArray array];
        for (NSDictionary *dict in arr)
        {
            Model *model = [[Model alloc] init];
            [model setValuesForKeysWithDictionary:dict];
            if (![letterArray containsObject:model.letter])
            {
                [letterArray addObject:model.letter];
                NSMutableArray *modelArray = [NSMutableArray array];
                [modelArray addObject:model];
                [dataArray addObject:modelArray];
            }
            else
            {
                NSMutableArray *arr = [dataArray lastObject];
                [arr addObject:model];
            }
        }
#pragma mark 5.传一个装有model数组的数组 如果只有一组也是传一个带有数组的数组,以后字段可以为空
        //给定一个装有model数组的数组,和header数组(字符串类型)相应属性对应的key.
        [vc registerModelClass:[Model class] andDataArray:dataArray andHeaderArray:letterArray withTextKey:@"brandname" withImageUrlStringKey:@"brandimg" withDetaiStringKey:nil];
    }];
    
    [DataHandle dataWithUrlString:@"http://app.api.autohome.com.cn/autov5.0.0/club/clubstheme-pm2-st635435459960905592.json" completion:^(id object) {
        NSArray *arr    = [[object objectForKey:@"result"] objectForKey:@"list"];
        NSMutableArray *array = [NSMutableArray array];
        for (NSDictionary *dict in arr)
        {
            NSString *str = dict[@"bbsname"];
            [array addObject:str];
        }
#pragma mark 5. 如果只是装有简单对象的数组就调用这个方法.
        [vc1 setDataArray:@[array] withHeaderArray:nil];
    }];
}
#pragma mark 显示的方法
- (void)push1
{
    [vc showWithDuration:0.3f];
}

- (void)push2
{
    [vc1 showWithDuration:0.3];
}

#pragma mark 隐藏的方法
- (void)back
{
    [vc hideWithDuration:0.3f];
    [vc1 hideWithDuration:0.3f];
    self.navigationController.navigationBarHidden = NO;
}
#pragma mark 7抽屉的点击方法
- (void)viewController:(UIViewController *)viewController didSelectedRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (viewController == vc)
    {
        NSLog(@"vc: section = %ld  row = %ld",indexPath.section,indexPath.row);
        TestViewController *testVC = [[TestViewController alloc] init];
        [NC pushViewController:testVC animated:YES];
    }
    if (viewController == vc1)
    {
        NSLog(@"vc: section = %ld  row = %ld",indexPath.section,indexPath.row);
        Test2ViewController *test2VC = [[Test2ViewController alloc] init];
        [NC1 pushViewController:test2VC animated:YES];
    }
}
@end
