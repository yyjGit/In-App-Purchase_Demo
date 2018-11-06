//
//  IAPManager.h
//  In-App-Purchase_Demo
//
//  Created by YangYongJie on 2018/11/5.
//  Copyright © 2018年 yyj. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

/** 获取产品信息错误码 */
typedef NS_ENUM(NSInteger, IAPFetchProductInfoErrorCode) {
    
    // 产品IDs为空（IDs.count == 0）
    IAPFetchProductInfoErrorNoProductIDs = 0,
    
    // 获取产品信息失败(request:didFailWithError:)
    IAPFetchProductInfoErrorFetchProductInfoFailed,
    
    // 没有产品信息(response.products.count == 0)
    IAPFetchProductInfoErrorNoProductInfo
};

/**
 支付错误码
 */
typedef NS_ENUM(NSInteger, IAPPaymentErrorCode) {
    
    // 用户禁止应用内付费购买([SKPaymentQueue canMakePayments] == NO)
    IAPPaymentErrorNotMakePayments = 0,
    // 交易失败 ：SKPaymentTransactionStateFailed
    IAPPaymentErrorTransactionFailed,
    // 验证失败（后台验证交易）
    IAPPaymentErrorTransactionVerifyFailed,
};

/** 获取产品信息接收者 */
@protocol IAPManagerProductInfoReceiver <NSObject>
@required
/**
 获取产品信息成功回调

 @param products  产品信息
 */
- (void)fetchProductInfoSuccess:(NSArray <SKProduct *>*)products;

/**
 获取产品信息失败回调

 @param error 失败信息
 */
- (void)fetchProductInfoFailed:(NSError *)error;
@end

/** 购买产品结果接收者 */
@protocol IAPManagerPaymentResultReceiver <NSObject>
@required
/**
 购买产品成功回调
 */
- (void)paymentProductSuccess;

/**
 购买产品失败回调
 
 @param error 失败信息
 */
- (void)paymentProductFailed:(NSError *)error;
@end


@interface IAPManager : NSObject

/** 产品信息接收代理 (获取产品信息前需要设置)*/
@property (nonatomic, weak) id<IAPManagerProductInfoReceiver> productInfoReceiver;

/** 购买产品结果代理 (购买产品前需要设置)*/
@property (nonatomic, weak) id<IAPManagerPaymentResultReceiver> paymentResultReceiver;


/**
 单例

 @return self
 */
+ (IAPManager *)shared;

/**
 开启监听
 */
- (void)startObserver;

/**
 停止监听
 */
- (void)stopObserver;

/**
 根据productIDs 向 app store 获取产品信息

 @param productIDs 产品ids
 
 important：调用该方法前，需要先遵守 productInfoReceiver 代理
 */
- (void)fetchProductsInfoWithProductIDs:(NSArray <NSString *>*)productIDs;

/**
 提交一个购买请求
 
 @param product 将要购买的产品
 */
- (void)submitPaymentRequestWithProduct:(SKProduct *)product;

@end
