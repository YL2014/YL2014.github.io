## 博客地址：[https://yl2014.github.io](https://yl2014.github.io)

##### v1：jekyll搭建

项目分支
[https://github.com/YL2014/YL2014.github.io/tree/v1-jekyll](https://github.com/YL2014/YL2014.github.io/tree/v1-jekyll)

##### v2: hexo搭建

[https://github.com/YL2014/YL2014.github.io/tree/v2-hexo](https://github.com/YL2014/YL2014.github.io/tree/v2-hexo)

##### 预览
```
$ npm start
```

##### 生成并发布
```
$ npm run deploy
```

##### 备忘
```
$ npx hexo s // 本地预览
$ npx hexo g // 生成public
$ npx hexo d // copy public to .deploy_git and push to github
$ npx hexo d -g // 生成并部署
```

> 如遇到问题，则删除后重新clone
```
$ rm -rf .deploy_git && git clone git@github.com:YL2014/YL2014.github.io.git .deploy_git
```

