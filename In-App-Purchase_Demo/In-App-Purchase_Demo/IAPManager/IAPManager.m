
//
//  IAPManager.m
//  In-App-Purchase_Demo
//
//  Created by YangYongJie on 2018/11/5.
//  Copyright © 2018年 yyj. All rights reserved.
//

#import "IAPManager.h"
#import "IAPReceiptVerifier.h"

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
SKProductsRequestDelegate,
IAPReceiptVerifyResutlDelegate>

@property (nonatomic, copy) NSArray <SKProduct *>*products; // 可购买的产品集合

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

// 开启监听
- (void)startObserver
{
    dispatch_async(iap_queue(), ^{
        // 添加观察者
        [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
        // 设置验证器代理
        [[IAPReceiptVerifier shared] setDelegate:self];
        // 检查本地是否有未验证的对象
        [self checkDB];
    });
}

// 停止监听
- (void)stopObserver
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
    });
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
        
        if (self.productInfoReceiver && [self.productInfoReceiver respondsToSelector:@selector(fetchProductInfoFailed:)]) {
            NSError *error = [NSError errorWithDomain:@"没有产品IDs为空" code:IAPFetchProductInfoErrorNoProductIDs userInfo:nil];
            [self.productInfoReceiver fetchProductInfoFailed:error];
        }
    }
}

// 提交一个购买请求
 - (void)submitPaymentRequestWithProduct:(SKProduct *)product
{
    // 判断设备是否允许应用内购买
    if ([SKPaymentQueue canMakePayments]) {
        
        if (product && [self.products containsObject:product]) {
            // 生成支付对象
            SKMutablePayment *payment = [SKMutablePayment paymentWithProduct:product];            
            // 添加到支付队列
            [[SKPaymentQueue defaultQueue] addPayment:payment];
        }
    } else {
        
        // [SKPaymentQueue canMakePayments] == NO， 回调
        if (self.paymentResultReceiver &&
            [self.paymentResultReceiver respondsToSelector:@selector(paymentProductFailed:)]) {
            
            NSError *error = [[NSError alloc] initWithDomain:@"用户禁止应用内付费购买" code:IAPPaymentErrorNotMakePayments userInfo:nil];
            [self.paymentResultReceiver paymentProductFailed:error];
        }
    }
}

#pragma mark SKProductsRequestDelegate
// 请求产品信息（fetchProductsInfoWithProductIDs:）成功后的回调
- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    // 没有产品信息
    if (response.products.count == 0) {
        
        if (self.productInfoReceiver && [self.productInfoReceiver respondsToSelector:@selector(fetchProductInfoFailed:)]) {
            NSError *error = [NSError errorWithDomain:@"没有产品信息或IDs无效" code:IAPFetchProductInfoErrorNoProductInfo userInfo:nil];
            [self.productInfoReceiver fetchProductInfoFailed:error];
        }
        
    } else { // 有产品信息
        
        self.products = response.products;
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
    if (self.productInfoReceiver && [self.productInfoReceiver respondsToSelector:@selector(fetchProductInfoFailed:)]) {
        [self.productInfoReceiver fetchProductInfoFailed:error];
    }
}

#pragma mark - SKPaymentTransactionObserver
// 提交购买(submitPaymentRequestWithProduct:)后的回调
- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(nonnull NSArray<SKPaymentTransaction *> *)transactions
{
    for (SKPaymentTransaction *transaction in transactions) {
        
        switch (transaction.transactionState) {
                
            case SKPaymentTransactionStatePurchasing: //正在交易
            {
                NSLog(@"已添加到交易队列中");
            }
                break;
                
            case SKPaymentTransactionStatePurchased: //交易完成
            {
                // 1、查看本地是否保存有该交易，没有则保存

                // 2、向 App Server 验证收据
                [[IAPReceiptVerifier shared] startVerifyWithTransactionId:transaction.transactionIdentifier
                                                                productId:transaction.payment.productIdentifier
                                                                   userId:@"用户id"];            
            }
                break;
                
            case SKPaymentTransactionStateFailed: // 交易失败
            {
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                NSString *errorMsg = transaction.error.userInfo[@"NSLocalizedDescription"];
                if (self.paymentResultReceiver &&
                    [self.paymentResultReceiver respondsToSelector:@selector(paymentProductFailed:)]) {
                    NSError *error = [NSError errorWithDomain:errorMsg code:IAPPaymentErrorTransactionFailed userInfo:nil];
                    [self.paymentResultReceiver paymentProductFailed:error];
                }
            }
                break;
                
            case SKPaymentTransactionStateRestored: // 已经购买过该商品
            {
                NSLog(@"已经购买过该商品");
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
            }
                break;
                
            default:
                break;
        }
    }
}

#pragma mark - IAPReceiptVerifyResutlDelegate
- (void)receiptVerifySucceedTransactionId:(NSString *)tranactionId
{
    for (SKPaymentTransaction *transaction in [SKPaymentQueue defaultQueue].transactions) {
        
        if ([transaction.transactionIdentifier isEqualToString:tranactionId]) {
            // 交易完成，关闭
            [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
            // 支付成功回到
            if (self.paymentResultReceiver &&
                [self.paymentResultReceiver respondsToSelector:@selector(paymentProductSuccess)]) {
                [self.paymentResultReceiver paymentProductSuccess];
            }
            break;
        }
    }
    // 从本地数据库中删除该条交易
//     [db deleteTransactionById:tranactionId];
    // 检查数据库中是否还有未验证的交易，
//    [self checkDB];
}

- (void)receiptVerifyFaildTransactionId:(NSString *)tranactionId
{
    if (self.paymentResultReceiver &&
        [self.paymentResultReceiver respondsToSelector:@selector(paymentProductFailed:)]) {

        NSError *error = [[NSError alloc] initWithDomain:@"验证失败" code:IAPPaymentErrorTransactionVerifyFailed userInfo:nil];
        [self.paymentResultReceiver paymentProductFailed:error];
    }
}


#pragma mark - private methods
- (void)checkDB
{
    // 1、获取所有未验证交易对象
    
    // 2、有，则去验证
//    [IAPReceiptVerifier shared] startVerifyWithTransactionId:<#(NSString *)#> productId:<#(NSString *)#> userId:<#(NSString *)#>]
}


@end
