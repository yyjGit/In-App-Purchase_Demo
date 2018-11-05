//
//  ViewController.m
//  In-App-Purchase_Demo
//
//  Created by YangYongJie on 2018/11/5.
//  Copyright © 2018年 yyj. All rights reserved.
//

#import "ViewController.h"
#import "IAPManager.h"

@interface ViewController () <IAPManagerProductInfoReceiver>

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

- (void)fetchProductInfofailed:(NSError *)error
{
    NSLog(@"获取产品信息失败：%@", error.domain);
}

#pragma mark - private memthdos
- (void)displayProductsUI
{
    
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
