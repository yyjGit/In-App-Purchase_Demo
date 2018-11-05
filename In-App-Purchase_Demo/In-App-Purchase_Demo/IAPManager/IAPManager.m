
//
//  IAPManager.m
//  In-App-Purchase_Demo
//
//  Created by YangYongJie on 2018/11/5.
//  Copyright © 2018年 yyj. All rights reserved.
//

#import "IAPManager.h"


dispatch_queue_t iap_queue() {
    static dispatch_queue_t as_iap_queue;
    static dispatch_once_t onceToken_iap_queue;
    dispatch_once(&onceToken_iap_queue, ^{
        as_iap_queue = dispatch_queue_create("com.iap.queue", DISPATCH_QUEUE_CONCURRENT);
    });
    return as_iap_queue;
}

@interface IAPManager ()
<SKPaymentTransactionObserver,
SKProductsRequestDelegate>


@end

@implementation IAPManager

static IAPManager *_instance;

/**
 调用[[NSObject alloc] init] 方法时，会执行 allocWithZone:（给对象分配空间）
 如果没有重写 allocWithZone：，会导致：
 IAPManager *mng = [IAPManager shared];
 IAPManager *mng2 = [[IAPManager alloc] init];
 mng 和 mng2 不是同一个对象（空间地址不同）
 所以重写 allocWithZone：保证不管通过什么方式创建self，都是同一个对象
 */
+ (id)allocWithZone:(NSZone *)zone
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [super allocWithZone:zone];
    });
    return _instance;
}

#pragma mark - public methods
// IAPManager 单例
+ (IAPManager *)shared
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
    });
    return _instance;
}

/**
 开启监听
 */
- (void)startObserver
{
    dispatch_async(iap_queue(), ^{
        
        // 添加交易观察者
        [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
        
    });
}

/**
 停止监听
 */
- (void)stopObserver
{
    
}

// 获取产品信息
- (void)fetchProductsInfoWithProductIDs:(NSArray <NSString *>*)productIDs
{
    // 如果有productIDs，验证productIDs
    if (productIDs.count) {
        
        // 根据IDs，请求产品信息
        SKProductsRequest *productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:[NSSet setWithArray:productIDs]];
        productsRequest.delegate = self;
        [productsRequest start];
        
    } else { // productIds.count == 0
        
        if (self.productInfoReceiver && [self.productInfoReceiver respondsToSelector:@selector(fetchProductInfofailed:)]) {
            NSError *error = [NSError errorWithDomain:@"没有产品IDs为空" code:IAPFetchProductInfoErrorNoProductIDs userInfo:nil];
            [self.productInfoReceiver fetchProductInfofailed:error];
        }
    }
}

#pragma mark SKProductsRequestDelegate
// 请求产品信息（fetchProductsInfoWithProductIDs:）成功后的回调
- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    // 没有产品信息
    if (response.products.count == 0) {
        
        if (self.productInfoReceiver && [self.productInfoReceiver respondsToSelector:@selector(fetchProductInfofailed:)]) {
            NSError *error = [NSError errorWithDomain:@"没有产品信息或IDs无效" code:IAPFetchProductInfoErrorNoProductInfo userInfo:nil];
            [self.productInfoReceiver fetchProductInfofailed:error];
        }
        
    } else { // 有产品信息
        
        // 调用代理，回调产品数据
        if (self.productInfoReceiver && [self.productInfoReceiver respondsToSelector:@selector(fetchProductInfoSuccess:)]) {
            [self.productInfoReceiver fetchProductInfoSuccess:response.products];
        }

        // 无效的产品IDs（可将无效的产品上报 App Server）
        for (NSString *invalidProductIdentifier in response.invalidProductIdentifiers) {
            NSLog(@"无效的产品id：%@", invalidProductIdentifier);
        }
    }
}

// 请求产品信息（fetchProductsInfoWithProductIDs:）失败后的回调
- (void)request:(SKRequest *)request didFailWithError:(NSError *)error
{
    if (self.productInfoReceiver && [self.productInfoReceiver respondsToSelector:@selector(fetchProductInfofailed:)]) {
        [self.productInfoReceiver fetchProductInfofailed:error];
    }
}



@end
