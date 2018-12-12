---
title: openresty(动态)添加nginx模块
date: 2018-12-12 15:35:31
tags:  
    - nginx
---

> 换了服务器后，重新搭建了`nginx`环境，这次使用的是`openrestry`。在配置`https`，开启`http2`的过程中，发现缺少`ngx_http_v2_module`这个`nginx`模块。那么如果添加这个模块呢？

<!-- more -->

在网上查了一番，大概都是重新编译。顺着这个思路来实践下。

首先查看下我们已经安装的模块
```
$ -V
nginx version: openresty/1.13.6.1
built by gcc 5.4.0 20160609 (Ubuntu 5.4.0-6ubuntu1~16.04.9)
built with OpenSSL 1.0.2g  1 Mar 2016
TLS SNI support enabled
configure arguments: --prefix=/usr/local/openresty/nginx --with-cc-opt=-O2 --add-module=../ngx_devel_kit-0.3.0 --add-module=../echo-nginx-module-0.61 --add-module=../xss-nginx-module-0.05 --add-module=../ngx_coolkit-0.2rc3 --add-module=../set-misc-nginx-module-0.31 --add-module=../form-input-nginx-module-0.12 --add-module=../encrypted-session-nginx-module-0.07 --add-module=../srcache-nginx-module-0.31 --add-module=../ngx_lua-0.10.11 --add-module=../ngx_lua_upstream-0.07 --add-module=../headers-more-nginx-module-0.33 --add-module=../array-var-nginx-module-0.05 --add-module=../memc-nginx-module-0.18 --add-module=../redis2-nginx-module-0.14 --add-module=../redis-nginx-module-0.3.7 --add-module=../rds-json-nginx-module-0.15 --add-module=../rds-csv-nginx-module-0.08 --add-module=../ngx_stream_lua-0.0.3 --with-ld-opt=-Wl,-rpath,/usr/local/openresty/luajit/lib --with-stream --with-stream_ssl_module --with-http_ssl_module
```
确实没有`http2`相关模块

之前安装`openrestry`就是下载源码编译安装的，切换到`openrestry`源码目录，重新编译，带上模块参数
```
$ ./configure --with-ngx_http_v2_module -j2
```
结果会报错，`openrestry`没有`ngx_http_v2_module`这个模块，根据提示，执行`./configure --help`，可以查看到支持哪些模块。在现实的列表中发现，`openrestry`的`http2`模块是`http_v2_module`，执行如下命令，重新编译
```
./configure --with-http_v2_module -j2
```

然后执行`make`操作
```
$ make
```

完成后会有如下提示（版本号显示为自己安装的对应版本号）
```
...
make[2]: Leaving directory 'soft/openresty-1.13.6.1/build/nginx-1.13.6'
make[1]: Leaving directory 'soft/openresty-1.13.6.1/build/nginx-1.13.6'
```

重新编译后的`nginx`的二进制文件就在上面提示的目录下面的`objs`下面，查看下系统环境的`nginx`在哪
```
$ which nginx
/usr/local/openresty/nginx/sbin/nginx
```

拷贝编译后的`nginx`二进制文件覆盖系统环境的`nginx`，并重启`nginx`服务
```
$ nginx -s stop
$ cp soft/openresty-1.13.6.1/build/nginx-1.13.6/objs/nginx /usr/local/openresty/nginx/sbin/
```

再看看`nginx`配置
```
server {
    listen 80;
    #listen[::]:80;

    #SSL configuration

    listen 443 ssl http2;
    #listen [::]443 ssl http2;
    ##ssl on;
    ssl_certificate /etc/letsencrypt/live/frontjs.cc/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/frontjs.cc/privkey.pem;

    root /www/html;
    index index.html index.htm index;

    server_name frontjs.cc;

    #force https
    #rewrite ^(.*)$ https://$host$1 permanent;

    location / {
        try_files $uri $uri/ =404;
        #proxy_pass http://127.0.0.1:8000;
    }
}
```

现在执行`nginx -t`就不会报缺少模块的错误了

启动`nginx`服务
```
$ nginx
```

Done~

##### 参考
[https://openresty.org/en/installation.html](https://openresty.org/en/installation.html)



