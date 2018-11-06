//
//  IAPReceiptVerifier.m
//  In-App-Purchase_Demo
//
//  Created by YangYongJie on 2018/11/6.
//  Copyright © 2018年 yyj. All rights reserved.
//

#import "IAPReceiptVerifier.h"

@interface IAPReceiptVerifier ()

@property (nonatomic, assign) IAPReceiptVerifyStatus verifyStatus; // 验证状态
@property (nonatomic, copy) NSString *receiptData; // base64Encoded收据
@property (nonatomic, assign) NSInteger verifyCount; // 记录验证次数
@property (nonatomic, copy) NSString *transactionId; // 交易id

@end


@implementation IAPReceiptVerifier

#pragma mark - public methods
// IAPManager 单例
+ (IAPReceiptVerifier *)shared
{
    static IAPReceiptVerifier *_instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
        _instance.verifyStatus = IAPReceiptVerifyDone;
    });
    return _instance;
}

/**
 启动验证
 
 @param transactionId 交易id
 @param productId 产品id
 @param userId 用户id
 */
- (void)startVerifyWithTransactionId:(NSString *)transactionId productId:(NSString *)productId userId:(NSString *)userId
{
    // 如果正在验证中 或 正在等待下一次验证，则 return
    if (_verifyStatus != IAPReceiptVerifyDone) {
        return;
    }
    
    // 参数不为空
    if (transactionId.length && productId.length && userId.length) {
        
        self.transactionId = transactionId;
        self.verifyCount = 0;
        // 状态改为验证中
        _verifyStatus = IAPReceiptVerifying;
        // 生成验证参数
        
        // 发起验证
        
//        if (verifySuccess) { // 验证成功回调
        
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(receiptVerifySucceedTransactionId:)]) {
            
            [self.delegate receiptVerifySucceedTransactionId:self.transactionId];
        }

//        }
        
//        if (verifyFailed) { // 验证失败回调
        
//            if (self.delegate && [self.delegate respondsToSelector:@selector(receiptVerifyFaildTransactionId:)]) {
//                [self.delegate receiptVerifyFaildTransactionId:self.transactionId];
//            }
//        }
    }
}


@end
