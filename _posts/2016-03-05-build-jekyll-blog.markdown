---
layout: post
title:  "使用jekyll搭建博客及jekyll模板easybook使用方法"
date:   2016-03-05 00:16
categories: other
permalink: /archivers/20160305/jekyllblog
---

网上关于在github上搭建静态博客的文章很多，也很详细，这里只是简单记录下本站的搭建过程。

* 在`github`上创建一个项目，项目名为`username.github.io`，`username`就是你github的名字，然后一步步的按提示操作...
*  不想自己折腾的话可以选择博客模板，刚才在`github`上创建项目并`autoloadpage`后是可以选择模板的，我们也可以在网上找`jekyll`的相关模板，这里我选择的是[`easybook`](https://github.com/laobubu/jekyll-theme-EasyBook)
* 下载[`easybook`](https://github.com/laobubu/jekyll-theme-EasyBook)后，将其文件拷贝到你本地的`username.github.io`下（先要`clone`你刚才在`github`上建的项目）
* 安装`ruby`、`gem`、`jekyll`（自行百度）,然后本地启动查看效果，浏览器打开[127.0.0.1:4000](http://127.0.0.1:4000)就可以看到效果

```ruby
jekyll server
```

### 对easybook模板进行修改 ###

下面按照自己的需求个性化一下这个模板。所谓的个性化，指的是根据刚才显示的效果查看对应的文件，了解页面的显示方式所对应的编写方法（原谅我没有深入的究其原理，只是研究了这套模板而已）。

先看`_config.yml`文件，这里面定义的东东简单理解就是定义的全局的变量，然后其他文件可以使用，这里我也不介绍很仔细了，简单的提下自己改的地方。
`title`:网站标题
`description`:描述，`seo`用的，生成的页面里的`meta`标签里可以看到
`avatar`:头像对应的图片地址，当然也可以将图片放在项目里引入或者直接修改`sidebar.html`里的头像地址
其他对应参数的修改可以看下面我的[`github`][my-jekyll-blog]上该项目的具体修改

### 发布文章

之前看网上的，使用`markdown`语法编写好博客后，还需要执行`jekyll`的相关命令进行生产对应的文档，但是我这里没有这么做。文章在本地写好后使用`jekyll server`进行本地预览，预览成功后，直接将本地修改`push`到`github`上就可以了，直接使用`master`分支，文档的类型是`markdown`不是`md`，否则上传后不显示(`md`类型的文档本地是可以预览显示的，具体原因还不知)，还要注意文档的日期格式。

### 结语

感觉使用`jekyll`来写静态博客还是蛮方便的，这也给了懒人一个写博客的理由 - -

当然，`easybook`里文章的分页以及分类都已经实现了，每篇`md`文档最上边的`categories`就是分类标识，也可以一篇文章处于多个分类里。关于博客的评论功能有时间再看看怎么引入。
希望自己能将这个习惯坚持下去

> 附上修改后的项目的`github`地址，[https://github.com/YL2014/YL2014.github.io][my-jekyll-blog]，欢迎`Star`

[my-jekyll-blog]: https://github.com/YL2014/YL2014.github.io
