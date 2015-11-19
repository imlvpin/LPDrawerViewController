//
//  BaseModel.m
//  CarsApp
//
//  Created by dllo on 15/9/21.
//  Copyright (c) 2015年 蓝鸥科技. All rights reserved.
//

#import "BaseModel.h"

@implementation BaseModel
- (instancetype)initWithDic:(NSDictionary *)dic
{
    self = [super init];
    if (self)
    {
        [self setValuesForKeysWithDictionary:dic];
    }
    return self;
}
/**
 *  KVC纠错方法
 *
 *  @param value 未找到Key对应的值
 *  @param key   字典未找到的Key
 */
- (void)setValue:(id)value forUndefinedKey:(NSString *)key
{
    //用uId代替id  防止和系统重名
    if ([key isEqualToString:@"id"])
    {
        self.uId = value;
    }
}
//将解析数据分别用字典,数组进行封装
+ (NSMutableArray *)baseModelByArr:(NSArray *)modelArr
{
    NSMutableArray *arr = [NSMutableArray array];
    for (NSDictionary *dic in modelArr)
    {
        id model = [[self class]baseModelWithDic:dic];
        if (![[[dic objectForKey:@"mediatype"] description] isEqualToString:@"3"])
        {
            [arr addObject:model];
        }
    }
    return arr;
}

+ (instancetype)baseModelWithDic:(NSDictionary *)dic
{
    //采用多态的方式进行对象的创建
    id model = [[[self class] alloc] initWithDic:dic];
    return model;
}
- (id)valueForUndefinedKey:(NSString *)key
{
    return nil;
}
@end
