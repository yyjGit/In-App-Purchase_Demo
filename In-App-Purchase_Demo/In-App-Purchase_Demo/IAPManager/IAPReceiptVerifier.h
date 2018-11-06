//
//  IAPReceiptVerifier.h
//  In-App-Purchase_Demo
//
//  Created by YangYongJie on 2018/11/6.
//  Copyright © 2018年 yyj. All rights reserved.
//

#import <Foundation/Foundation.h>
/** 验证状态 */
typedef NS_ENUM(NSInteger, IAPReceiptVerifyStatus) {
    IAPReceiptVerifyDone = 0,        // 验证结束
    IAPReceiptVerifying,             // 验证中
    IAPReceiptWaitingNextVerify      // 等待下次验证
};

/** 验证结果回调代理 */
@protocol IAPReceiptVerifyResutlDelegate <NSObject>
@required
- (void)receiptVerifySucceedTransactionId:(NSString *)tranactionId;
- (void)receiptVerifyFaildTransactionId:(NSString *)tranactionId;
@end

@interface IAPReceiptVerifier : NSObject

/** 验证状态 */
@property (nonatomic, assign, readonly) IAPReceiptVerifyStatus verifyStatus;

/** 验证结果回调 */
@property (nonatomic, weak) id <IAPReceiptVerifyResutlDelegate> delegate;

/**
 单例
 
 @return self
 */
+ (IAPReceiptVerifier *)shared;

/**
 启动验证
 
 @param transactionId 交易id
 @param productId 产品id
 @param userId 用户id
 */
- (void)startVerifyWithTransactionId:(NSString *)transactionId productId:(NSString *)productId userId:(NSString *)userId;

@end
