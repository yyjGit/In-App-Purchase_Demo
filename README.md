# In-App-Purchase_Demo
关于苹果内购(In-App Purchase)的一个demo


###苹果内购流程 ：

1、应用程序向服务器发送请求，以检索产品标识符列表。

2、服务器返回一个产品标识符列表。

3、应用程序向应用程序商店发送请求，以获取产品信息。

4、应用程序商店返回产品信息。

5、应用程序使用产品信息向用户显示商店。

6、用户从商店中选择一个商品。

7、应用程序向应用程序商店发送支付请求。

8、应用程序商店处理付款并返回完成的交易。

9、应用程序从事务中检索接收数据并将其发送到服务器。

10、服务器记录接收数据以建立审计跟踪。

11、服务器将收据数据发送到App Store，以验证这是一个有效的事务。

12、应用程序商店解析收据数据并返回收据和收据是否有效。

13、服务器读取返回的收据数据，以确定用户购买了什么。

14、服务器将购买的内容交付给应用程序。
