---
title: GitHub多账号管理踩坑记录
date: 2018-07-24 15:35:31
tags:  
	- git
---

#### 背景
> 新增了一个Github账号，并push过代码，然后用以前的github账号push时，死活push不上去

#### 寻找解决办法
> 使用ssh key

每个账号对应一个key, Github上填写对应的key（如：`id_rsa.github.yl2014.pub`文件内容）

```
# 生成key文件
ssh-keygen -t rsa -f ~/.ssh/id_rsa.github.yl2014 -C "yl2014@xx.com"
ssh-keygen -t rsa -f ~/.ssh/id_rsa.github.test -C "test@xx.com"

# 添加key文件
ssh-add ~/.ssh/id_rsa.github.yl2014
ssh-add ~/.ssh/id_rsa.github.test

# 配置config
vim ~/.ssh/config
Host yl2014
    HostName github.com
    IdentityFile ~/.ssh/id_rsa.github.yl2014
    User git

Host test
    HostName github.com
    IdentityFile ~/.ssh/id_rsa.github.test
    User git

# 测试
ssh -T yl2014
> Hi YL2014! You've successfully authenticated, but GitHub does not provide shell access.

ssh -T test
> Hi test! You've successfully authenticated, but GitHub does not provide shell access.

ssh -T git@github.com
> Hi YL2014! You've successfully authenticated, but GitHub does not provide shell access.
```

如果出现 `ermission denied (publickey)`，则表示key没添加成功，执行
`ssh-add ~/.ssh/id_rsa.github.yl2014`，或用debug模式查看具体出错信息`ssh -vT git@github.com`

如果发现推送时一直是某个GitHub账号，无法切换成另一个，可以采取如下操作：
```
# 删除所有session，并添加需要认证的
$ ssh-add -D
$ ssh-add id_rsa.github.yl2014
```

> 参考：http://www.barretlee.com/blog/2016/03/09/config-in-ssh-after-troubling-git-connection/


