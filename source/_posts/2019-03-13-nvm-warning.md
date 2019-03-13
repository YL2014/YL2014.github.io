---
title: NVM is not compatible with the npm config "prefix" option warning (OS X)
date: 2019-03-13 15:35:31
tags:  
    - nodejs
---

```bash
nvm is not compatible with the npm config "prefix" option: currently set to "/usr/local"
Run `npm config delete prefix` or `nvm use --delete-prefix v8.11.2 --silent` to unset it.
```

最近在`vscode`的终端经常会看到这个警告，`nvm ls`一下，可以看到，IDE里的终端默认使用的`node`指向了`system`。

我们知道，为了开发方便以及版本切换，`nodejs`基本都是用`nvm`来安装了，不会直接去官网下载安装文件进行安装，那么指向`system`的`nodejs`是哪里来的？

OK，我们看看`brew list`，可以看到`node`在`brew`的安装列表里，不过我们并没有通过`brew install node`来安装过`nodejs`。

尝试卸载`system`的`nodejs`, `brew uninstall node`，会得到告警，该`node`是`yarn`的依赖，不能卸载，这就对上了，看看怎么解决这个问题。

- 卸载`yarn`和`node`，然后再安装`yarn`，同时加上去掉依赖安装参数
```bash
$ brew uninstall yarn
$ brew uninstall node
$ brew prune
$ brew install yarn --ignore-dependencies
```

- 清除`system`的`node`残留文件
```bash
$ rm -rf  /usr/local/lib/node_modules
$ rm /usr/local/bin/npm
```

重新打开终端，基本上就不会有这个警告出现了。

> 参考：[https://github.com/creationix/nvm/issues/1245#issuecomment-387460769](https://github.com/creationix/nvm/issues/1245#issuecomment-387460769)
