---
title: ECS上nodejs升级(7.2.0)记录
date: 2016-12-08 17:40:31
tags:  
	- nodejs
	- ecs
	- ubuntu
---

> 更新：此文作废，用nvm就好了，哪那么多破事...

##### 卸载

如果之前是通过 `apt-get install nodejs npm`安装的，直接执行 `apt-get remove nodejs npm -y`卸载，若原来是通过源码编译安装的(我之前就是)，参考这个进行卸载[https://hungred.com/how-to/completely-removing-nodejs-npm/](https://hungred.com/how-to/completely-removing-nodejs-npm/)

##### 安装

<!-- more -->

```
curl -sL https://deb.nodesource.com/setup_7.x | sudo -E bash -
sudo apt-get install -y nodejs
```
> 参考：[https://nodejs.org/en/download/package-manager/#debian-and-ubuntu-based-linux-distributions](https://nodejs.org/en/download/package-manager/#debian-and-ubuntu-based-linux-distributions)

###### 是否成功？
```
root@yl:/etc# node -v
-bash: /usr/local/bin/node: No such file or directory
root@yl:/etc# npm -v
-bash: /usr/local/bin/npm: No such file or directory
```
很明显没成功(注：在真实的ubuntu里，已经成功了，这个是ECS上显示了)

##### 看看node装在哪了
```
root@yl:/etc# which node
/usr/bin/node
root@yl:/etc# which npm
/usr/bin/npm
```
可以看到，其实是安装成功了，只是命令的对应目录不对，这就好办了

##### 软链
```
root@yl:/etc# ln -s /usr/bin/nodejs /usr/local/bin/node
root@yl:/etc# node -v
v7.2.0
root@yl:/etc# ln -s /usr/bin/npm /usr/local/bin/npm
root@yl:/etc# npm -v
3.10.9
```

可以愉快的玩耍了~~