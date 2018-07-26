---
title: Let's Encrypt 通配符证书配置
date: 2018-03-30 15:35:31
tags:  
	- let's encrype
	- https
---

> 本文只是对配置过程的记录，如有问题，欢迎留言

#### 环境与依赖
<!-- more -->
阿里云ECS ubunt16.0.4
```
$ sudo apt-get update
$ sudo apt-get install software-properties-common
$ sudo add-apt-repository ppa:certbot/certbot
$ sudo apt-get update
$ sudo apt-get install python-certbot-nginx 
```

#### 生成证书
```
$ certbot -d *.frontjs.cc --server https://acme-v02.api.letsencrypt.org/directory --manual --preferred-challenges dns-01 
```
按提示操作，注意事项如下：
![](/images/2018-03-30-1.png)
注意上面做记号的地方，到了这里先不要Enter，先去阿里云上域名解析哪里添加一条解析
![](/images/2018-03-30-2.png)
添加完成后，新开一个窗口测试下是否成功
```
$ dig _acme-challenge.frontjs.cc txt
```
![](/images/2018-03-30-3.png)
如上图所示，表示成功了
然后回到安装的窗口，按Enter
![](/images/2018-03-30-4.png)
OK，证书生成完成

> 证书有效期3个月，设置定时任务来更新证书
- 编写定时任务脚本
```
$ vim /etc/letsencrypt/live/renew.sh
# 内容：certbot renew --pre-hook "service nginx stop" --post-hook "service nginx start"
```
- 设置定时任务
```
$ crontab -e
# 添加如下内容 0 0 1 * * /etc/letsencrypt/live/renew.sh >/dev/null 2>&1
```

#### nginx配置
```
server {
  listen 80;
  listen [::]:80;

  listen 443 ssl;
  # ssl off 支持http和https
  # ssl on;
  ssl_certificate /etc/letsencrypt/live/frontjs.cc/fullchain.pem;
  ssl_certificate_key /etc/letsencrypt/live/frontjs.cc/privkey.pem;

  server_name frontjs.cc;

  # 强制https
  # rewrite ^(.*)$  https://$host$1 permanent;

  location / {
    proxy_pass http://127.0.0.1:7000;
  }
}
```
重启nginx
```
$ service nginx restart
```
##### enjoy yourself!

#### 参考
[https://letsencrypt.org/](https://letsencrypt.org/)
[https://certbot.eff.org/lets-encrypt/ubuntuxenial-nginx](https://certbot.eff.org/lets-encrypt/ubuntuxenial-nginx)
[https://certbot.eff.org/docs/using.html](https://certbot.eff.org/docs/using.html)

