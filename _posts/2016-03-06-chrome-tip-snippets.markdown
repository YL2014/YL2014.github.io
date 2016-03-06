---
layout: post
title:  "chrome使用技巧之snippets"
date:   2016-03-06 00:16
categories: chrome
permalink: /archivers/20160306/chrome-snippets
---

在平时开发中，使用的最多的工具应该是chrome了(前端而言)，chrome有很多使用技巧，下面我们要聊的正是`snippets`,个人认为比控制台的`console`好用(也只是在某些场景下面)。

例如平时浏览博客园等网站时，看到某些大神写的一些很高大上的代码，想亲手实践下正确性，或是想调试下，那么一般人都会打开`sublime`等开发工具，建一个页面文档，在`script`标签里粘贴或者敲出那一坨`js`(也有可能在js里加几个`console.log`)，然后在浏览器打开，`F12`，看控制台信息，如果需要调试也可能在`source`里找到文件打上断点。

回顾下刚才描述的过程，不免觉得有点麻烦。也有人说直接在浏览器的控制台里进行码代码，`enter`后就可以看到结果了。没错，要看结果这或许是很方便，可是，如果要对代码进行调试呢?

这里就要请出我们的`snippets`了。`snippets`在哪？请看下面截图

<img src="http://7xrl5v.com1.z0.glb.clouddn.com/github%2Fio%2Fblog20160306-fetch.jpg" alt="snippets-pic">

看了上面的图片，各位看官应该已经了了解了如何使用`snippets`了，在空白区域右键选择`new`可以新建文件，右键刚才新建的文件选择`run`可以运行写的测试代码，断点的方法这里就不多介绍了，相信使用`chrome`开发的朋友都应该很熟了。

关于`snippets`就介绍这么多，`chrome`里找不到`snippets`的同学可以去升级一下浏览器。

其实chrome的使用技巧还有很多，比如`workspace`，这里顺带提一下，也不单独弄篇文章讨论了。请看下图

<img src="http://7xrl5v.com1.z0.glb.clouddn.com/github%2Fio%2Fblog20160306-chrome-workspace.jpg" alt="workspace-pic">

没错，找到地方后，右键就可以看到这个workspace了，这个是干嘛的？这个是把你本地的资源加载到当前站点，说明白点就是“`js`”注入(胡乱取的名字)，具体的就不展开了，有兴趣的同学可以去实践下。


