//
//  IAPManager.h
//  In-App-Purchase_Demo
//
//  Created by YangYongJie on 2018/11/5.
//  Copyright © 2018年 yyj. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

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
- (void)fetchProductInfofailed:(NSError *)error;
@end


@interface IAPManager : NSObject

/** 产品信息接收代理 */
@property (nonatomic, weak) id<IAPManagerProductInfoReceiver> productInfoReceiver;

/**
 单例

 @return self
 */
+ (IAPManager *)shared;


/**
 根据productIDs 向 app store 获取产品信息

 @param productIDs 产品ids
 
 important：调用该方法前，需要先遵守 productInfoReceiver 代理
 */
- (void)fetchProductsInfoWithProductIDs:(NSArray <NSString *>*)productIDs;


@end
