---
layout: post
title:  "最近一周开发总结(jssdk)"
date:   2016-04-11 00:11
categories: js 微信
permalink: /archivers/20160411/new-job-summary
---

刚换工作不久，这一周总的来说还是蛮充实的，也接触到了一些东西，这里做个简单的记录。

话说接触微信开发是毕业前的第一份工作，当时所做的就是一些微信上的活动推广页面，用到的jssdk就只有微信分享跟网页登录授权吧。记得很久以前微信分享是不需要后端支持的，后来世界变了，不能只靠前端来拯救世界了...

最近一周在新工作做的项目就是微信端的，首先用到的就是jssdk。下面整理几个，还没用上的等用上了再来补充。

首先贴上微信jssdk地址：[http://mp.weixin.qq.com/wiki/7/aaa137b55fb2e0456bf8dd9148dd613f.html](http://mp.weixin.qq.com/wiki/7/aaa137b55fb2e0456bf8dd9148dd613f.html)

### 初始配置

```javascript
function wxConfig(option){
    wx.config({
        debug: false,
        appId: option.appId,
        timestamp: option.timestamp,
        nonceStr: option.nonceStr,
        signature: option.signature,
        jsApiList: [
            'onMenuShareTimeline',
            'onMenuShareAppMessage',
            'onMenuShareQQ',
            'onMenuShareWeibo',
            'onMenuShareQZone',
            'startRecord',
            'stopRecord',
            'onVoiceRecordEnd',
            'playVoice',
            'pauseVoice',
            'stopVoice',
            'onVoicePlayEnd',
            'uploadVoice',
            'downloadVoice',
            'chooseImage',
            'previewImage',
            'uploadImage',
            'downloadImage',
            'translateVoice',
            'getNetworkType',
            'openLocation',
            'getLocation', //获取位置信息
            'hideOptionMenu',
            'showOptionMenu',
            'hideMenuItems',
            'showMenuItems',
            'hideAllNonBaseMenuItem',
            'showAllNonBaseMenuItem',
            'closeWindow',
            'scanQRCode',
            'chooseWXPay', //支付
            'openProductSpecificView',
            'addCard',
            'chooseCard',
            'openCard'
        ]
    });
}
```
> 有 `option` 的参数是后端给的，具体的后端实现可以参考[微信的官方demo](http://demo.open.weixin.qq.com/jssdk/sample.zip)

### 获取位置信息

```javascript
function getLocation(){
    wx.ready(function(){
        wx.getLocation({
            type: 'gcj02',
            success: function (data) {
                var res = data;
                if(data.res){
                    res = data.res;
                }
                var latitude = res.latitude;
                var longitude = res.longitude;
                Utils.setData('position',JSON.stringify({
                    latitude: latitude,
                    longitude: longitude
                }));
                //if(latitude && longitude){
                    getDetailAddr(latitude, longitude);
                //}
            },
            fail: function(res){
                page.location = page.locationFailTip;
            }
        });
    });
}
```
> 以上代码通过微信拿到经纬度后，向后端发起请求拿详细地址(想前端自己拿详细地址，可以借助于百度地图的api，百度地图在微信里能否使用还没做尝试)

### 微信支付

```javascript
function wxPays(option){
    wx.ready(function(){
        wx.chooseWXPay({
            timestamp: option.timeStamp, // 支付签名时间戳，注意微信jssdk中的所有使用timestamp字段均为小写。但最新版的支付后台生成签名使用的timeStamp字段名需大写其中的S字符
            nonceStr: option.nonceStr, // 支付签名随机串，不长于 32 位
            package: option.package, // 统一支付接口返回的prepay_id参数值，提交格式如：prepay_id=***）
            signType: option.signType, // 签名方式，默认为'SHA1'，使用新版支付需传入'MD5'
            paySign: option.paySign, // 支付签名
            success: function (res) {
                // 支付成功后的回调函数,请求服务器查询支付结果
                var prepayId = option.package.split('=')[1];
                checkPayResult(prepayId);
            },
            fail: function(res){}
        });
    });
}
```
> 以上带`option`的参数需服务端提供，发起微信支付后，会自动调出微信支付的面板，完成支付或取消支付会进入相应的回调，根据微信官方提供的[支付文档(业务流程说明)](https://pay.weixin.qq.com/wiki/doc/api/jsapi.php?chapter=7_4)，支付完成后，服务端需确认是否支付成功，所以我们还得向服务端发送一次支付结果确认请求。

当时调支付时一个很小的错误导致支付面板没弹出，就使用了[支付文档](https://pay.weixin.qq.com/wiki/doc/api/jsapi.php?chapter=7_7&index=6)里的示例`demo`，如下

```javascript
function wxPays(option){
    //alert('微信支付配置参数:'+JSON.stringify(option));
    onBridgeReady(option);
    function onBridgeReady(option){
        WeixinJSBridge.invoke(
            'getBrandWCPayRequest', {
                "appId" : option.appId,     //公众号名称，由商户传入
                "timeStamp" : option.timeStamp,         //时间戳，自1970年以来的秒数
                "nonceStr" : option.nonceStr, //随机串
                "package" : option.package,
                "signType" : option.signType,         //微信签名方式：
                "paySign" : option.paySign //微信签名
            },
            function(res){
                // 使用以上方式判断前端返回,微信团队郑重提示：res.err_msg将在用户支付成功后返回    ok，但并不保证它绝对可靠。
                //if(/ok/.test(res.err_msg)) {
                if(res.err_msg == "get_brand_wcpay_request:ok") {
                    var prepayId = option.package.split('=')[1];
                    checkPayResult(prepayId);
                }else{
                    Utils.alert({
                        title: '懂师傅提示您',
                        content: '支付失败，请重新支付',
                        callback: function(){
                            window.location.reload();
                        }
                    });
                }
            }
        );
    }
    if (typeof WeixinJSBridge == "undefined"){
        if( document.addEventListener ){
            document.addEventListener('WeixinJSBridgeReady', onBridgeReady, false);
        }else if (document.attachEvent){
            document.attachEvent('WeixinJSBridgeReady', onBridgeReady);
            document.attachEvent('onWeixinJSBridgeReady', onBridgeReady);
        }
    }else{
        onBridgeReady();
    }
}
```
该方法在`android`机上测试是有效的，在`ios`机上测试是提示`调用jsApi时没有传timeStamp`，不知道是什么鬼，哪位朋友知道怎么解决的，欢迎留言告知，不胜感谢

### 选择图片与上传图片

##### 选择图片

```javascript
function uploadImage(){
    wx.ready(function(){
        wx.chooseImage({
            count: 3-page.photos.length, // 默认9
            sizeType: ['original', 'compressed'], // 可以指定是原图还是压缩图，默认二者都有
            sourceType: ['album', 'camera'], // 可以指定来源是相册还是相机，默认二者都有
            success: function (res) {
                var localIds = res.localIds; // 返回选定照片的本地ID列表，localId可以作为img标签的src属性显示图片
                localIds.forEach(function(item){
                    if(page.photos.indexOf(item) == -1){
                        page.photos.push(item);
                        uploadToWx(item);
                    }
                })
            },
            fail: function(res){}
        });
    });
}
```

##### 上传图片

```javascript
function uploadToWx(localId){
    wx.uploadImage({
        localId: localId, // 需要上传的图片的本地ID，由chooseImage接口获得
        isShowProgressTips: 0, // 默认为1，显示进度提示
        success: function (res) {
            page.serverIds.push(res.serverId); // 返回图片的服务器端ID
        }
    });
}
```

> 感觉微信提供的能够调用手机拍照和相册的方法蛮实用的，一般这个在`app`里才能实现，浏览器一般也只能选择文件。选择了图片后，可以在回调里拿到图片的`id`列表,本地的图片`id`在微信里是可以用来显示图片的，通过该`id`列表的每个`id`(注意，这里是单个`id`，不是列表)，就可以调用微信上传图片的接口，将图片上传到微信服务器上，微信服务器目前对图片的保留时间是3天，上传成功后回调里可以拿到`serverId`，服务端通过`serverId`将微信服务器上的图片资源下载到自己的服务器或第三方进行存储。

目前用的微信jssdk就这几个，后续有用上会再补上。

下面说下最近开发中遇到的问题，避免以后踩同样的坑。

### 关于微信里的刷新

这个问题困扰了好久，也尝试过很多方法。
问题场景：有一个订单状态页面：订单提交成功，接单成功，待支付，支付成功待评价，评价成功。我用了一个页面，通过订单状态值来渲染对应的template，所以用户支付后刷新页面就应该看到待评价的内容，因为支付成功后页面刷新，订单状态值就改变了，评价后刷新是同样的道理。
尝试过的方法：

* window.location.reload();

* window.location.href = window.location.href;

* window.location.href = window.location.href + '&r=' + 时间戳

结果均以失败告终，页面刷新，数据没刷新，通过`fiddler`查看网络请求发现，刷新页面时没有向服务器拿页面，说明拿的只是缓存，这种情况以前确实没遇到过，及时缓存严重，用时间戳的方法也一般可以解决。
后来在一个前端群里求助，得到了解决方法：`window.location.reload(true)`，传`true`强制刷新，好吧，看来还是得多看看基础，一直不知道这个方法还有个参数。这里也要感谢群里的那位朋友。

### 关于js的事件代理

以前一直有用`js`的事件代理，这次场景跟以前稍微有点不同，先看代码

```html
<ul class="equipments-list" @click="toStatusPage($event)">
    <li v-for="item in orders" class="equipments-item" :orderId="item.id">
        <p>
            <span class="order-no" v-text="'单号'+item.orderNo"></span>
            <span class="order-status" v-text="item.statusStr"></span>
        </p>
        <p class="equipments-detail" v-for="subItem in item.equipments">
            <span v-text="subItem.type+'安装'"></span>
            <span v-text="subItem.brand+subItem.productNo"></span>
            <span v-text="subItem.installWay"></span>
            <span v-text="'费用：'+item.price+'元'"></span>
        </p>
        <p v-text="item.createTime+'下单'"></p>
    </li>
</ul>
```


```javascript
toStatusPage: function(event){
            var target = event.target;
            while(target.tagName != 'LI'){
                target = target.parentNode;
            }
            var id = target.getAttribute('orderId');
            window.location.href = Utils.baseUrl + '/html/orderStatus.html?id='+id;
        }
```
> 很简单的一个列表进详情，为了节省内存，使用了代理的方式，用`ul`来代理事件，最初的想法是`li`点击的时候获取他的`orderId`，然后跳转到对应的详情页，当使用代理方式拿到的`target`可能是`span`，也可能是`p`，如果层级很多就很可能是别的什么了。那么这里得想法吧拿到`li`，所以使用了`parentNode`这个东东，去判断`li`在哪，用了一个简单的循环，拿到`li`后结束循环，执行后面的操作，暂时这样解决了，还没有想到更好的方法，有更好的方法的朋友欢迎留言，让大家都学习下，谢啦！

好了，暂时就总结这么多吧，文中如有错误之处麻烦指正，谢谢！

