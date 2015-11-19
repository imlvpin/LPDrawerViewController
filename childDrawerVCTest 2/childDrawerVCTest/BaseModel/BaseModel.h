//
//  BaseModel.h
//  CarsApp
//
//  Created by dllo on 15/9/21.
//  Copyright (c) 2015年 蓝鸥科技. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BaseModel : NSObject

-(instancetype)initWithDic:(NSDictionary *)dic;

@property(nonatomic,copy)NSString *uId;

+ (NSMutableArray *)baseModelByArr:(NSArray *)modelArr;

@end
