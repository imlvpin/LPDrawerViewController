//
//  ZCAFNetWork.h
//  CarWorld
//
//  Created by dllo on 15/9/1.
//  Copyright (c) 2015年 zhozhicheng. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef enum : NSUInteger {
    ZCData,
    ZCJSON,
    ZCXML,
}ZCResult;

typedef enum : NSUInteger {
    ZCRequestJSON,
    ZCRequestString,
    
} ZCRequestStyle;

@interface ZCAFNetWork : NSObject

/**
 *  Get请求
 *
 *  @param url        网络请求地址
 *  @param body       请求体
 *  @param result     返回的数据类型
 *  @param headerFile 请求头
 *  @param success    网络请求成功回调
 *  @param failure    网络请求失败回调
 */
+(void)getUrl:(NSString *)url
         body:(id)body
       result:(ZCResult)result
   headerFile:(NSDictionary *)headerFile
      success:(void (^)(id result))success
      failure:(void(^)(NSError *error))failure;

/**
 *  Post请求
 *
 *  @param url          网络请求地址
 *  @param body         请求体
 *  @param result       返回的数据类型
 *  @param requestStyle 网络请求body的类型
 *  @param headerFile   请求头
 *  @param success      网络请求成功回调
 *  @param failure      网络请求失败回调
 */
+ (void)postgetUrl:(NSString *)url
             body:(id)body
           result:(ZCResult)result
     requestStyle:(ZCRequestStyle)requestStyle
       headerFile:(NSDictionary *)headerFile
          success:(void (^)(id result))success
          failure:(void(^)(NSError *error))failure;

+ (BOOL)deleteCaches;
+ (float)cachesSize;
@end
