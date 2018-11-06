//
//  ViewController.m
//  In-App-Purchase_Demo
//
//  Created by YangYongJie on 2018/11/5.
//  Copyright © 2018年 yyj. All rights reserved.
//

#import "ViewController.h"
#import "IAPManager.h"

@interface ViewController ()
<IAPManagerProductInfoReceiver,
IAPManagerPaymentResultReceiver>

/** 向 app server 获取到的产品IDs数组 */
@property (nonatomic, copy) NSArray <NSString *>*productIDs;
/** 向 app store 获取到的产品数组 */
@property (nonatomic, copy) NSArray <SKProduct *>*products;

@end

@implementation ViewController

#pragma mark - life cycle
- (void)viewDidLoad
{
    [super viewDidLoad];
        
    // 1：模拟向App Server请求产品标识符列表。
    // loading productIDs
    
    // 2、根据App Server 返回的productIDs，向App Store获取产品信息
    [[IAPManager shared] setProductInfoReceiver:self];
    [[IAPManager shared] setPaymentResultReceiver:self];
    [[IAPManager shared] fetchProductsInfoWithProductIDs:self.productIDs];
}

#pragma mark - IAPManagerProductInfoReceiver
- (void)fetchProductInfoSuccess:(NSArray<SKProduct *> *)products
{
    if (products.count) {
        self.products = products;
        [self displayProductsUI];
    } else {
        NSLog(@"产品信息为空");
    }
}

- (void)fetchProductInfoFailed:(NSError *)error
{
    NSLog(@"获取产品信息失败：%@", error.domain);
}

#pragma mark - IAPManagerPaymentResultReceiver
- (void)paymentProductSuccess
{
    NSLog(@"购买成功");
}

- (void)paymentProductFailed:(NSError *)error
{
    NSLog(@"购买失败：%@", error.domain);
}

#pragma mark - event response
- (void)productBtnAction:(UIButton *)sender
{
    if ((sender.tag - 100) < self.products.count) {
        
        SKProduct *product = self.products[(sender.tag - 100)];
        // 提交购买请求
        [[IAPManager shared] submitPaymentRequestWithProduct:product];
    }
}

#pragma mark - private memthdos
- (void)displayProductsUI
{
    CGFloat btnWidth = [UIScreen mainScreen].bounds.size.width / 3;
    CGFloat btnHeight = 80;
    
    for (int i = 0; i < self.products.count; i++) {

        UIButton *productBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        CGFloat x = (i % self.products.count) * btnWidth;
        CGFloat y = (i / 3) * btnHeight + 150;
        [productBtn setFrame:CGRectMake(x, y, btnWidth, btnHeight)];
        
        SKProduct *product = self.products[i];
        [productBtn setTitle:product.localizedTitle forState:UIControlStateNormal];
        [productBtn setTag:(100+i)];
        [productBtn addTarget:self action:@selector(productBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    }
}

#pragma mark - getters
- (NSArray <NSString *>*)productIDs
{
    if (_productIDs == nil) {
        // 产品id格式一般为：”com.公司名.项目名_产品名“
        _productIDs = @[
                        @"com.apple.tianqi_001",
                        @"com.apple.tianqi_003",
                        @"com.apple.tianqi_006",
                        @"com.apple.tianqi_008",
                        @"com.apple.tianqi_018"
                        ];
    }
    return _productIDs;
}

@end
