---
title: 关于javascript函数声明提升和变量声明提升
date: 2016-03-12 17:37:36
tags: 
	- js
---

一直知道javascript变量和函数都会在自己的作用于内声明提升，但是当变量名和函数名相同时，谁会覆盖谁呢？

<!-- more -->

```javascript
alert(a);
var a = 1;
function a(){};
alert(a);
```
>结果：function a(){}    1

```javascript
alert(a);
function a(){};
var a = 1;
alert(a);
```
>结果：function a(){}    1

```javascript
alert(a);
function a(){};
var a;
alert(a);
```
>结果：function a(){}    function a(){}


### 结论：

同一个名称标识a，即有变量声明var a，又有函数声明function a() {}，不管二者声明的顺序，函数声明会覆盖变量声明，也就是说，此时a的值是声明的函数function a() {}。如果在变量声明的同时初始化a，或是之后对a进行赋值，此时a的值就是变量的值