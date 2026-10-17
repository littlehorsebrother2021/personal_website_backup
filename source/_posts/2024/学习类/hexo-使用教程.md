---
title: hexo 使用教程
date: 2024-01-25 22:17:13
tags: 教程
---
### 创建一个新的文章
``` bash
$ hexo new "My New Post"
```


### 运行服务器

``` bash
$ hexo server /hexo s
```

### 生成可执行文件

``` bash
$ hexo generate /hexo g
```

### 上传博客代码(Gitee)
``` bash
$ hexo deploy
```
### 上传博客代码(GitHub)
``` bash
hexo clean && hexo g && hexo de
```
  代码逐行解读为：
   hexo clean:清理缓存
  hexo g:生成可执行文件
  hexo de:上传博客代码


### 注意!在上传过程中可能会遇到报错：
  "unable to get local issuer certificate"
          ("无法获取本地颁发者证书")
  这是由于当你通过HTTPS访问Git远程仓库的时候，如果服务器上的SSL证书未经过第三方机构认证，git就会报错。原因是因为未知的没有签署过的证书意味着可能存在很大的风险。解决办法就是通过下面的命令将git中的sslverify关掉：
``` bash
git config --global http.sslverify false
 ```

解决方法原文链接：https://blog.csdn.net/qq_36342182/article/details/108668395