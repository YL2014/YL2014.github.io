---
title: FormData API 上传文件到又拍云
date: 2016-04-25 17:39:33
tags: 
	- js
	- 又拍云
---

最近又遇到了上传文件的需求，以前也写过一篇关于利用formdata上传文件的文章(如需浏览，请点击[这里](http://yl2014.github.io/archivers/20160308/async-js-file-upload))，
这次上传的地址是又拍云，在操作过程中稍微遇到了一些坑，这里简单记录下。

这里使用的是又拍云的[HTTP FORM API](http://docs.upyun.com/api/form_api/)，使用流程大概如下

<!-- more -->

1. 请求客户服务器，生成、获取上传所需的 signature、policy 参数。为了提升上传成功率（避免签名过期）、安全性(设置尽可能短的授权有效期)，我们建议在每次执行上传操作之前，都重新执行本步骤获取相关参数；

2. 请求 UPYUN API 上传文件，校验返回结果/异步回调通知客户服务器；

3. 处理常规客户业务流程。

没错，我们首先要获取上传到又拍云所需要的字段，这个由自己的服务端返回，然后将这两个参数和文件参数一起请求又拍云的api接口即可，如下

```javascript
Utils.ajaxGet('/upload/sign',{mod: 'serverSite'}, function(data){
    /*data {"signature":xxx, "policy":xxxx}*/
    upload(data);
});

function upload(data){
    var file,
        fd = new FormData(),
        xhr = new XMLHttpRequest(),
        loaded, total, pre, url, input;
    if(document.getElementById('myUploadInput')){
        input = document.getElementById('myUploadInput');
    }else{
        input = document.createElement('input');
        input.setAttribute('id', 'myUploadInput');
        input.setAttribute('type', 'file');
        input.setAttribute('name', 'file');
        document.body.appendChild(input);
        input.style.display = 'none';
    }
    url = 'http://v0.api.upyun.com/xxx';

    input.click();
    input.onchange = function(){
        file = input.files[0];
        fd.append('signature', data.signature);
        fd.append('policy', data.policy);
        fd.append('file', file);
        xhr.open('post', url);
        xhr.send(fd);
        xhr.onreadystatechange = function(){
            console.log(xhr);
            if(xhr.status == 200){
                if(xhr.readyState == 4){
                    if(option.callback instanceof Function){
                        console.log(xhr.responseText);
                        if(typeof xhr.responseText == 'string'){
                            option.callback(JSON.parse(xhr.responseText))
                        }else{
                            option.callback(xhr.responseText);
                        }
                        xhr = null;
                    }
                }
            }else{
                Utils.showTips('上传失败')
            }
        };
        xhr.upload.onprogress = function(event){
            loaded = event.loaded;
            total = event.total;
            pre = Math.floor(100 * loaded / total);
            if(option.uploading instanceof Function){
                option.uploading(pre);
            }
        }
    }
}
```

上面代码中`url`中的`xxx`，是又拍云配置里的`bucket-name`，具体的可以查看又拍云的相关api文档。

一切看似很正常，我开始也是这么觉得的，然后，bug发生了。当我们在页面上点击按钮调用上述方法的时候，发现什么也没有发生，按常理应该会打开本地的资源管理器的。
然后在控制台看看，发现只向自己的服务端发送了请求，创建的表单元素的`change`事件没有发生，这个断点可以看到。

为什么`change`没有发生？初步猜测，ajax发起的网络请求会阻塞或者影响浏览器UI层的渲染，然后谷歌查阅相关资料，也找到了相关的解释。

[资料一](http://greengerong.com/blog/2015/10/27/javascript-single-thread-and-browser-event-loop/)

[资料二](http://www.cnblogs.com/lvdabao/p/3744030.html)

既然找到了原因，解决办法也很明显了，如果使用的jQuery的ajax，可以尝试上述资料里的方法，我这里偷了个懒，从服务端获取signature、policy的方法放到了表单元素的`change`事件里。

代码如下

```javascript
Utils.uploadFile = function (option){
    var file,
        fd = new FormData(),
        xhr = new XMLHttpRequest(),
        loaded, total, pre, url, input;
    if(document.getElementById('myUploadInput')){
        input = document.getElementById('myUploadInput');
    }else{
        input = document.createElement('input');
        input.setAttribute('id', 'myUploadInput');
        input.setAttribute('type', 'file');
        input.setAttribute('name', 'file');
        document.body.appendChild(input);
        input.style.display = 'none';
    }
    url = 'http://v0.api.upyun.com/xxx';

    input.click();

    input.onchange = function(){
        var fileType = ['gif','png','jpg','jpge'];
        var type = input.value.split('.').pop();
        if(fileType.indexOf(type.toLocaleLowerCase()) == -1){
            Utils.showTips('该类型文件不支持，请选择图片文件');
            return;
        }
        if(option.maxSize &&  input.files[0].size > option.maxSize * 1024 * 1024){
            Utils.showTips('请上传小于'+option.maxSize+'M的文件');
            return;
        }
        if(option.beforeSend instanceof Function){
            if(option.beforeSend(file) === false){
                return false;
            }
        }
        Utils.ajaxGet('/upload/sign',{mod: 'serverSite'}, function(data){
            file = input.files[0];
            fd.append('signature', data.signature);
            fd.append('policy', data.policy);
            fd.append('file', file);
            xhr.open('post', url);
            xhr.send(fd);
            xhr.onreadystatechange = function(){
                console.log(xhr);
                if(xhr.status == 200){
                    if(xhr.readyState == 4){
                        if(option.callback instanceof Function){
                            console.log(xhr.responseText);
                            if(typeof xhr.responseText == 'string'){
                                option.callback(JSON.parse(xhr.responseText))
                            }else{
                                option.callback(xhr.responseText);
                            }
                            xhr = null;
                        }
                    }
                }else{
                    Utils.showTips('上传失败')
                }
            };
            xhr.upload.onprogress = function(event){
                loaded = event.loaded;
                total = event.total;
                pre = Math.floor(100 * loaded / total);
                if(option.uploading instanceof Function){
                    option.uploading(pre);
                }
            }
        });
    }
}
```

这就完了？ 其实并没有，还遇到一个奇葩问题，也就是刚才说的`change`事件没发生的时候，请求又拍云拿到的`xhr.status`为`0`，
可能是我孤陋寡闻了，还没听过状态码可以为0。只能说明谷歌很强大，马上就找到相关资料了，因为没有`send`。最开始的时候，又拍云的请求路径错了也拿到了为0的status，
以后遇到类似的情况可以从这几个方面去查找原因了。

上传文件到又拍云后，又拍云接口的返回参数里有个url，具体的文件访问路径为 `"http://xxx.b0.upaiyun.com/"+url`，`xxx`为`bucket-name`，
相关文档可以看[这里](http://docs.upyun.com/guide/#_4)。

差不多就这么多了，如有疑问欢迎留言。
