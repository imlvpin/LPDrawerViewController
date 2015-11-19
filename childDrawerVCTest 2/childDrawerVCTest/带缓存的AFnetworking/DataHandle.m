//
//  DataHandle.m
//  VFL
//
//  Created by 吕品 on 15/10/27.
//  Copyright © 2015年 吕品. All rights reserved.
//

#import "DataHandle.h"
#import "ZCAFNetWork.h"
@implementation DataHandle

+ (void)dataWithUrlString:( NSString *)urlString completion:(void(^)(id object))block
{
    [ZCAFNetWork getUrl:urlString body:nil result:ZCJSON headerFile:nil success:^(id result) {
        block(result);
    } failure:^(NSError *error) {
        NSLog(@"error:%@",error.description);
    }];
}

@end

