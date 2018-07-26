---
title: 关于js异步上传文件
date: 2016-03-08 17:34:59
tags:
	- js
	- 文件上传
---

> 本文首发在我的博客园：[https://www.cnblogs.com/yuanlong1012/p/5127497.html](https://www.cnblogs.com/yuanlong1012/p/5127497.html)

最近项目里有个需求，上传文件（好吧，这种需求很常见，这也不是第一次遇到了）。当时第一想法就是直接用form表单提交（原谅我以前就是这么干的），不过表单里不仅有文件还有别的信息需要交互，跟后端商量后决定文件单独上传，获取到服务器端返回的文件地址在和表单一起提交。这里就需要异步上传文件。
　　在网上扒了扒相关的内容，发现还真不少，阮一峰老师的这篇文章[文件上传的渐进式增强](http://www.ruanyifeng.com/blog/2012/08/file_upload.html)就介绍的很具体，下面就谈谈自己在实战中遇到的一些问题的感受吧。

<!-- more -->

　　先看看效果，实现了哪些功能

![](https://images2015.cnblogs.com/blog/695097/201601/695097-20160113143715944-686026729.png)（好吧，就一个按钮而已，搞得神神秘秘，嘿嘿）

```html
<button type="button" class="btn" @click="upload">点击上传文件</button>
```

给按钮绑定了一个点击事件，下面看看点击事件方法里做了什么

```javascript
methods: {
    upload: function(){
        myUpload({
            url: window.location.protocol + '//' + window.location.host + '/crm/upload',
            maxSize: 10,
            beforeSend: function(file){

            },
            callback: function(res){
                var data = JSON.parse(res);
                pageCont.attachmentUrl = data.url;
            },
            uploading: function(pre){
                pageCont.uploadCont.display = 'block';
                pageCont.uploadStyle.width = pre * 2 + 'px';
                pageCont.pre = pre;
            }
        });
    }
}
```

按钮绑定的点击事件执行了upload方法，在upload方法里调用了一下myUpload方法，并传递了一些配置信息进去，稍后说下这些配置信息。先看看myUpload的具体实现：

　　初始化了一个FormData对象和一个XMHttpResquest对象，创建一个type为file的input，并触发一次该input的click，如下

```javascript
var fd = new FormData(),
    xhr = new XMLHttpRequest(),
    input;
input = document.createElement('input');
input.setAttribute('id', 'myUploadInput');
input.setAttribute('type', 'file');
input.setAttribute('name', 'file');
document.body.appendChild(input);
input.style.display = 'none';
input.click();
```

监听刚才创建的input的change事件，并作在里面做相应处理

```javascript
input.onchange = function(){
    if(!input.value){return;}
    if(option.maxSize &&  input.files[0].size > option.maxSize * 1024 * 1024){
        dialog({
            title: '提示',
            content: '请上传小于'+option.maxSize+'M的文件',
            okValue: '确定',
            ok: function () {}
        }).showModal();
        return;
    }
    if(option.beforeSend instanceof Function){
        if(option.beforeSend(input) === false){
            return false;
        }
    }
    fd.append('file', input.files[0]);
    xhr.open('post', option.url);
    xhr.onreadystatechange = function(){
        if(xhr.status == 200){
            if(xhr.readyState == 4){
                if(option.callback instanceof Function){
                    option.callback(xhr.responseText);
                }
            }
        }else{
            if(!(dialog.get('uploadfail'))){
                dialog({
                    id: 'uploadfail',
                    title: '提示',
                    content: '上传失败',
                    okValue: '确定',
                    ok: function () {}
                }).showModal();
            }
        }
    }
    xhr.upload.onprogress = function(event){
        var pre = Math.floor(100 * event.loaded / event.total);
        if(option.uploading instanceof Function){
            option.uploading(pre);
        }
    }
    xhr.send(fd);
}
```

解释下上面的代码。input的change事件触发后，首先判断了下当前是否选择了文件

```javascript
if(!input.value){return;}
```

一开始我是没做这个判断的，在后来的测试过程中发现，当上传一次文件后，再次点击按钮上传，打开文件选择框，然后不选择文件，而是点击取消按钮，change事件也触发了，导致后面的代码也会执行，显然这不合理，故加了这个判断。

　　然后限制了下上传文件的大小（这样的事能够前端处理就不要交给服务端来验证了），当文件大小超过最大限制，就会弹框提示

```javascript
if(option.maxSize &&  input.files[0].size > option.maxSize * 1024 * 1024){
    dialog({
        title: '提示',
        content: '请上传小于'+option.maxSize+'M的文件',
        okValue: '确定',
        ok: function () {}
    }).showModal();
    return;
}
```

然后加了一个文件上传前的操作，可以在文件上传前做一些处理，如进度条的显示，图片预览等等

```javascript
if(option.beforeSend instanceof Function){
    if(option.beforeSend(input) === false){
        return false;
    }
}
```

接下来将文件append到formData对象里，使用字段名‘file’，该字段名是服务端接收文件时使用的字段名

```javascript
fd.append('file', input.files[0]);
```

然后就是使用XMLHttpRequest对象向服务端发送数据了

```javascript
xhr.open('post', option.url);
xhr.onreadystatechange = function(){
    if(xhr.status == 200){
        if(xhr.readyState == 4){
            if(option.callback instanceof Function){
                option.callback(xhr.responseText);
            }
        }
    }else{
        if(!(dialog.get('uploadfail'))){
            dialog({
                id: 'uploadfail',
                title: '提示',
                content: '上传失败',
                okValue: '确定',
                ok: function () {}
            }).showModal();
        }
    }
}
xhr.upload.onprogress = function(event){
    var pre = Math.floor(100 * event.loaded / event.total);
    if(option.uploading instanceof Function){
        option.uploading(pre);
    }
}
xhr.send(fd);
```

再向服务端发送数据时，使用了监听了一下progress事件，主要是为了进行上传进度的显示，上述代码中，

```javascript
var pre = Math.floor(100 * event.loaded / event.total);
```

获取上传的百分比，能够拿到这个值，页面上就可以展示各种各样的上传进度效果了。

　　差不多介绍完了，下面补充一下使用中遇到的问题：

　　问题一：文件在上传的过程中，使用JSON.parse()序列化服务端返回的json字符串报错(傻啊，文件还在上传，服务端怎么会返回数据啊)。

事情是这样的，一开始，我在readystatechange里只监听了状态码是否是200，如果是就说明通了，然后执行回调，在回调里处理服务端返回的数据，但是通了不一定代表服务端已经返回了数据，所以就出现了上面的错误，所以后来在判断了status是否为200后，还判断了readyState，以确保服务端已处理完毕并返回数据在执行回调

```javascript
if(xhr.status == 200){
    if(option.callback instanceof Function){
        option.callback(xhr.responseText);
    }
}
```

问题二：重复创建input。每次点击按钮上传文件后，页面都会多一个type=file的input感觉不是很好（个人癖好吧），所以对最开始的初始化代码做了下优化，判断当前页面是否存在刚才创建的input，存在就直接使用，不存在就创建，如下

```javascript
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
```

好了，就这么多了。看看效果
![](https://images2015.cnblogs.com/blog/695097/201601/695097-20160113154319132-891661887.png)
![](https://images2015.cnblogs.com/blog/695097/201601/695097-20160113154331335-1308230912.png)
![](https://images2015.cnblogs.com/blog/695097/201601/695097-20160113154343678-1782738937.png)

刚才加了个需求，限制上传文件类型，作了如下修改：

* myUpload方法，初始化时增加了支持文件类型，如下

```javascript
fileType = ['doc','docx','xls','xlsx','pdf','jpg','png','ppt','pptx']
```

* change发生后，检查文件类型，如下

```javascript
var type = input.value.split('.').pop();
if(fileType.indexOf(type.toLocaleLowerCase()) == -1){
    dialog({
        title: '提示',
        content: '暂不支持该类型的文件，请重新选择!',
        okValue: '确定',
        ok: function () {}
    }).showModal();
    return;
}
```

因个人知识面有限，如有错误，还请指正。