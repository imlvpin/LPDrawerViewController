//
//  ZCAFNetWork.m
//  CarWorld
//
//  Created by dllo on 15/9/1.
//  Copyright (c) 2015年 zhozhicheng. All rights reserved.
//

#import "ZCAFNetWork.h"
#import "AFNetworking.h"
@implementation ZCAFNetWork

+(void)getUrl:(NSString *)url
         body:(id)body
       result:(ZCResult)result
   headerFile:(NSDictionary *)headerFile
      success:(void (^)(id result))success
      failure:(void(^)(NSError *error))failure
{
    
    NSString *str = [url stringByReplacingOccurrencesOfString:@"/" withString:@""];
    NSArray *sandBox = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    
    NSString *sandBoxPath = sandBox[0];
    NSString *caches = [sandBoxPath stringByAppendingPathComponent:str];
    

    
    //1.获取网络请求管理类
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    
    //3.给网络请求加请求头
    if (headerFile)
    {
        for (NSString *key in headerFile.allKeys)
        {
            [manager.requestSerializer setValue:headerFile[key] forHTTPHeaderField:key];
        }
    }
    
    //4.设置返回值类型
    switch (result)
    {
        case ZCData:
            manager.responseSerializer = [AFHTTPResponseSerializer serializer];
            break;
        case ZCJSON:
            break;
        case ZCXML:
            manager.responseSerializer = [AFXMLParserResponseSerializer serializer];
            break;
        default:
            break;
    }

    //2.设置网络请求返回值支持的参数类型
    [manager.responseSerializer setAcceptableContentTypes:[NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript",@"text/html",@"text/css",@"text/plain", nil]];
    //5.发送网络请求
//    NSCharacterSet *set = [NSCharacterSet letterCharacterSet];
    [manager GET:[url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]] parameters:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
        if (responseObject)
        {
            //成功回调
            success(responseObject);
            NSString *str = [url stringByReplacingOccurrencesOfString:@"/" withString:@""];
            str = [str stringByAppendingString:@".xml"];
            // 缓存
            NSArray *sandBox = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
            
            NSString *sandBoxPath = [sandBox firstObject];
            NSString *caches = [sandBoxPath stringByAppendingPathComponent:str];
           BOOL boo =  [NSKeyedArchiver archiveRootObject:responseObject toFile:caches];
            NSLog(@"caches:%@",caches);
            if (boo)
            {
                NSLog(@"成功");
            }
            else
            {
                NSLog(@"失败");
            }
        }
        else
        {
            id responseObject = [NSKeyedUnarchiver unarchiveObjectWithFile:caches];
            if (responseObject)
            {
                success(responseObject);
            }
        }
    }
         failure:^(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error)
     {
        if (error)
        {
            id responseObject = [NSKeyedUnarchiver unarchiveObjectWithFile:caches];
            if (responseObject)
            {
                success(responseObject);
            }
        }
    }];
    
    
}

//post请求
+ (void)postgetUrl:(NSString *)url body:(id)body result:(ZCResult)result requestStyle:(ZCRequestStyle)requestStyle headerFile:(NSDictionary *)headerFile success:(void (^)(id))success failure:(void (^)(NSError *))failure
{
    // 1. 获取网络请求管理类
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    // 3. 网络请求请求体的body体类型
    switch (requestStyle)
    {
        case ZCRequestJSON:
            manager.requestSerializer = [AFJSONRequestSerializer serializer];
            break;
        case ZCRequestString:
            [manager.requestSerializer setQueryStringSerializationWithBlock:^NSString *(NSURLRequest *request, id parameters, NSError **error) {
                return parameters;
            }];
            break;
        default:
            break;
    }
    
    // 4. 给网络请求加请求头
    if (headerFile)
    {
        for (NSString *key in headerFile.allKeys)
        {
            [manager.requestSerializer setValue:headerFile[key] forHTTPHeaderField:key];
        }
    }
    // 5. 设置返回值类型
    switch (result)
    {
        case ZCData:
            manager.responseSerializer = [AFHTTPResponseSerializer serializer];
            break;
        case ZCJSON:
            break;
        case ZCXML:
            manager.responseSerializer = [AFXMLParserResponseSerializer serializer];
            break;
        default:
            break;
    }
    // 2. 设置网络请求返回值所支持的参数类型
    [manager.responseSerializer setAcceptableContentTypes:[NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript",@"text/html",@"text/css",@"text/plain", nil]];
    // 6. 发送网络请求
    [manager POST:url  parameters:body constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData)
     {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
        if (responseObject)
        {
            success(responseObject);
        }
    } failure:^(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error) {
        if (error)
        {
            failure(error);
        }
    }];

}
+ (BOOL)deleteCaches
{
    NSString *cachesPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];

    NSFileManager *manager = [NSFileManager defaultManager];

    NSError *error = nil;
    [manager removeItemAtPath:cachesPath error:&error];
    BOOL fileBool = [manager fileExistsAtPath:cachesPath];
    if (error == nil) {
        return YES;
    }
    else if (fileBool == YES)
    {
        NSLog(@"%@", error);
        return NO;
    }
    else
    {
        return NO;
    }
}
+ (float)cachesSize
{
    NSString *cachesPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    NSFileManager *manager = [NSFileManager defaultManager];
    unsigned long long size = [manager attributesOfItemAtPath:cachesPath
                                          error:nil].fileSize;
    return size / 1024.0 / 1024.0;
}
@end
