//
//  DataHandle.h
//  VFL
//
//  Created by 吕品 on 15/10/27.
//  Copyright © 2015年 吕品. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DataHandle : NSObject
+ (void)dataWithUrlString:( NSString *)urlString completion:(void(^)(id object))block;
@end
