---
layout: post
title:  "ubuntu上搭建ftp服务器"
date:   2016-06-13 00:00
categories: linux ecs
permalink: /archivers/20160613/ubuntu-ftp
---

买阿里云的ECS有段时间了，也折腾了一段时间，过段时间写一写折腾的一些东东。昨天有个想法，服务器上已经搭建了一些东西，如果需要合作开发，必然需要给团队的开发人员服务器的账号和密码。但是这里涉及到一个权限问题，比如，当某个项目的前端开发人员只需要将前端代码上传到服务器，就没必要给服务器的所有权限。脑海中第一反应就是ftp了，刚使用ECS也是用ftp来管理文件的。当然，jekins的自动化部署也能解决这样的需求，这个以后有时间在写一篇。

在网上找了一些资料，以及查阅ECS的官方文档，也确实找到了我想要的东西，例如这个
[Linux下如何进行FTP设置](https://help.aliyun.com/knowledge_detail/5973912.html)，还有这个[ECS Linux配置vsftpd限制FTP账户访问其它目录](https://help.aliyun.com/knowledge_detail/5990158.html?spm=5176.788314853.2.1.mVyePK)。

看完这两篇文章，发现没什么好写的，只剩下实践了。所以我打算在本地先测试一遍，如果没问题，然后就在ECS上去添加ftp用户，并设置访问权限，下面开始实践。

按照刚才给出的第一份文档，

```
root@yl:/# apt-get install vsftpd -y
root@yl:/# useradd -d /usr/yl -m -s /usr/sbin/nologin test
root@yl:/# passwd test
输入新的 UNIX 密码： 
重新输入新的 UNIX 密码： 
passwd：已成功更新密码
root@yl:/# chown -R test.test /usr/yl
```

然后就是修改vsftpd.conf和shells文件

```
root@yl:/# vim /etc/vsftpd.conf
root@yl:/# vim /etc/shells
```

shells文件的修改，在文件后面加上`/usr/sbin/nologin
`，vsftpd.conf的关键修改如下，

```
chroot_local_user=YES
chroot_list_enable=YES
# (default follows)
chroot_list_file=/etc/vsftpd.chroot_list
```

这里简单说明下(来源于网络)：
chroot_local_user=YES       #是否将所有用户锁定在主目录,YES为启用 NO禁用.(包括注释掉也为禁用)
chroot_list_enable=YES     #是否启动锁定用户的名单 YES为启用  NO禁用(包括注释掉也为禁用)
chroot_list_file=/etc/vsftpd.chroot_list     #禁用的列表名单  格式为一行一个用户, 如果名单里面有一个ftpuser的用户, 则ftpuser用户不会锁定在主目录,用户将可以自由切换目录.

然后重启ftp服务

```
root@yl:/# service vsftpd restart
```

尝试连接

```
root@yl:/usr# ftp 127.0.0.1
Connected to 127.0.0.1.
220 (vsFTPd 3.0.2)
Name (127.0.0.1:yl): test
331 Please specify the password.
Password:
500 OOPS: vsftpd: refusing to run with writable root inside chroot()
Login failed.
```

好吧，看到报500了，哈哈。针对这个问题，chrome了一番，得到的答案是最新的vsftp对受限用户的主目录不能设置writable权限。那么问题来了，我们创建用户并只允许其访问自己的主目录，这里又不能给他可写的权限，好像矛盾了。没错，确实矛盾了。既然官方说了不能给主目录可写权限，那么我们可以给他的子目录可写的权限，用户在子目录里进行对应的操作就可以了，如下

```
root@yl:/# chmod a-w /usr/yl
root@yl:/# cd /usr/yl
root@yl:/usr/yl# mkdir www
root@yl:/usr/yl# ls
www
root@yl:/usr/yl# chmod 777 www
```

我们再来连接试试

```
root@yl:/usr# ftp 127.0.0.1
Connected to 127.0.0.1.
220 (vsFTPd 3.0.2)
Name (127.0.0.1:yl): test
331 Please specify the password.
Password:
230 Login successful.
Remote system type is UNIX.
Using binary mode to transfer files.
ftp> 
```

连接成功！

然后我使用xftp在windows里使用刚才新建的账号连接虚拟机里的服务器也正常连接了，并且只能访问自己的主目录，不能跳出当前目录，权限也跟刚才设置的一样，只能在子目录里上传文档。剩下的就是把这些操作在ECS上copy一次了，如果遇到了新的问题会在留言里贴出，如有疑问，欢迎留言。








